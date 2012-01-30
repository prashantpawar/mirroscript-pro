unit GlTileBitmap;

{$mode objfpc}{$H+}

interface

uses
   Classes, SysUtils, gl, glu, glut, Graphics, LCLIntf, IntfGraphics, math, glext,
   {$ifdef darwin}
   opengl,
   {$endif}
   CTypes;

type
TOpenGLTileBitmap = class(TObject)
  private
    fTextures : array of GLuint;
    Count     : integer;
    fWidth    : Integer;
    fHeight   : Integer;
    fHCount   : Integer;
    fVCount   : Integer;
    fHPart    : single;
    fVPart    : single;
  public
    destructor Destroy; override;
    procedure Init(ABitmap: TBitmap);
    procedure DrawTiles(x,y, wx, wy: single);
    procedure Clear;
    property Width: integer read fWidth;
    property Height: integer read fHeight;
  end;


implementation

uses animation;

destructor TOpenGLTileBitmap.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure DrawTile(x,y,w,h: single;u,v: single); inline;
begin
   glBegin(GL_QUADS);
   glTexCoord2f(0, v); glVertex2d(x,   y);
   glTexCoord2f(0, 0); glVertex2d(x,   y+h);
   glTexCoord2f(u, 0); glVertex2d(x+w, y+h);
   glTexCoord2f(u, v); glVertex2d(x+w, y);
   glEnd;
end;

procedure BindTexture2D(texName: integer); inline;
begin
   glBindTexture(GL_TEXTURE_2D, texName);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
end;

procedure TOpenGLTileBitmap.DrawTiles(x, y, wx, wy: single);
var
   i     : integer;
   j, k  : integer;
   ox,oy : single;
begin
   ox := x;
   oy := y;
   glEnable(GL_TEXTURE_2D);
   for j := 0 to fVCount - 2 do begin
      x := ox;
      for k := 0 to fHCount - 2 do begin
         BindTexture2D(fTextures[j*fHCount+k]);
         DrawTile(x,y,wx,wy, 1, 1);
         x := x + wx;
      end;
      y := y + wy;
   end;
   x := ox + (fHCount-1) * wx;
   y := oy;
   i := fHCount-1;
   for k := 0 to fVCount - 2 do begin
      BindTexture2D(fTextures[i]);
      DrawTile(x,y, wx, wy, 1, 1);
      inc(i, fHCount);
      y:=y+wy;
   end;
   i := fHCount * (fVCount - 1);
   x := ox;
   y := oy + (fVCount-1) * wy;
   for k := 0 to fHCount - 2 do begin
      BindTexture2D(fTextures[i]);
      DrawTile(x,y, wx, wy, 1, 1);
      x:=x+wy;
      inc(i);
   end;
   x := ox + (fHCount-1) * wx;
   y := oy + (fVCount-1) * wy;
   BindTexture2D(fTextures[fHCount*fVCount - 1]);
   DrawTile(x,y, wx, wy, 1, 1);
end;

procedure TOpenGLTileBitmap.Clear;
begin
   if length(fTextures)>0 then begin
      glDeleteTextures(length(fTextures), @fTextures[0]);
      SetLength(fTextures, 0);
   end;
end;

procedure TOpenGLTileBitmap.Init(ABitmap: TBitmap);
var
   h,v,w : Integer;
   x,y   : Integer;
   image : TLazIntfImage;
   bmp   : TBitmap;
   i, j  : Integer;
   line  : PByteArray;
   r,g,b,a: byte;
   data  : array of byte;
begin
   Clear;
   if not Assigned(ABitmap) or (ABitmap.Width = 0) or (ABitmap.Height=0) then Exit;
   bmp := TBitmap.Create;
   image := nil;
   try
      bmp.Assign(ABitmap);
      bmp.PixelFormat := pf32bit;
      bmp.Width := ABitmap.Width;
      bmp.Height := ABitmap.Height;
      bmp.Canvas.FillRect(Bounds(0,0,ABitmap.Width,ABitmap.Height) );
      bmp.Canvas.Brush.Color:=clBlack;
      bmp.Canvas.Brush.Style:=bsSolid;
      bmp.Canvas.Draw(0,0,ABitmap);
      fHCount := bmp.Width div TileX;
      fVCount := bmp.Height div TileY;
      if bmp.Width mod TileX > 0 then inc(fHCount);
      if bmp.Height mod TileY > 0 then inc(fVCount);
      fHPart := (bmp.Width mod TileX) / TileX;
      fVPart := (bmp.Height mod TileY) / TileY;
      count := fHCount*fVCount;
      if count=0 then Exit;
      fWidth  := bmp.Width;
      fHeight := bmp.Height;
      SetLength(fTextures, count);
      image := bmp.CreateIntfImage;
      SetLength(data, TileX*TileY*4);
      SetLength(fTextures, count);
      glGenTextures(count, @fTextures[0]);
      for i := 0 to count - 1 do begin
         x := i mod fHCount;
         y := i div fHCount;
         v := y * TileX;
         h := x * TileX;
         if (h + TileX) > bmp.Width then
            w := bmp.Width - h
         else
            w := TileX;
         w:=w*4;
         j := length(data)-TileX*4;
         FillChar(data[0], length(data), 0);
         for v := v to Min(v+TileY, bmp.Height)-1 do begin
            line := image.GetDataLineStart(v);
            System.Move(line^[h*4], data[j], w);
            dec(j, TileX*4);
         end;
         {$ifdef darwin}
         j := 0;
         while j < length(data) do begin
            a:=data[j];
            r:=data[j+1];
            g:=data[j+2];
            b:=data[j+3];
            data[j] := b;
            data[j+1] := g;
            data[j+2] := r;
            data[j+3] := a;
            inc(j, 4);
         end;
         {$endif}
         glEnable(GL_TEXTURE_2D);
         glBindTexture(GL_TEXTURE_2D, fTextures[i]);
         glTexImage2D(GL_TEXTURE_2D, 0, 4, TileX, TileY, 0, GL_BGRA, GL_UNSIGNED_BYTE, @data[0]);
      end;
   finally
      image.Free;
      bmp.Free;
   end;
end;

end.

