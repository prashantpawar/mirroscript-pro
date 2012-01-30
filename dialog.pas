unit dialog;

{$mode objfpc}{$H+}

interface

uses
   {$ifdef windows}
   windows, shfolder,
   {$endif}
   Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
   StdCtrls, ComCtrls, ExtCtrls, RichMemo, Process, Dos;

type

  { TFormDialog }

  TFormDialog = class(TForm)
     BtnStart: TButton;
     BtnSave: TButton;
     BtnLoad: TButton;
     BtnNew: TButton;
     BtnSaveAs: TButton;
     ChkHorizontal: TCheckBox;
     ChkVertical: TCheckBox;
     ChkCenter: TCheckBox;
     CmbBackColor: TComboBox;
     CmbFontColor: TComboBox;
     CmbFontSize: TComboBox;
     ColorDialog1: TColorDialog;
     ComboBox1: TComboBox;
     CmbSpeed: TComboBox;
     CmbTextColor: TComboBox;
     EdtInsert: TEdit;
     GroupBox1: TGroupBox;
     GroupBox2: TGroupBox;
     GroupBox3: TGroupBox;
     GroupBox4: TGroupBox;
     Label1: TLabel;
     Label10: TLabel;
     Label11: TLabel;
     Label2: TLabel;
     Label3: TLabel;
     Label4: TLabel;
     Label5: TLabel;
     Label6: TLabel;
     Label7: TLabel;
     Label8: TLabel;
     Label9: TLabel;
     MmoText: TRichMemo;
     OpenDialog1: TOpenDialog;
     Panel1: TPanel;
     BtnBold: TToggleBox;
     BtnItalic: TToggleBox;
     Panel2: TPanel;
     SaveDialog1: TSaveDialog;
     TmrAnimate: TTimer;
     TmrEnable: TTimer;
     procedure BtnLoadClick(Sender: TObject);
     procedure BtnNewClick(Sender: TObject);
     procedure BtnSaveAsClick(Sender: TObject);
     procedure BtnSaveClick(Sender: TObject);
     procedure BtnStartClick(Sender: TObject);
     procedure ColorChanged(Sender: TObject);
     procedure FormShow(Sender: TObject);
     procedure MmoTextKeyPress(Sender: TObject; var Key: char);
     procedure MmoTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
     procedure TmrAnimateTimer(Sender: TObject);
     procedure TmrEnableTimer(Sender: TObject);
     procedure UpdateToolbar(Sender: TObject);
     procedure UpdateEditFont(Sender: TObject);
     function  CheckSave:Boolean;
     function  DoSaveText:Boolean;
     procedure AddFormatStrings(var sl:tstringlist);
     procedure StringListToText(var sl:tstringlist);
     procedure StringListToVars(var sl:tstringlist);
     procedure FillVars(var sl:TStringlist);
     procedure GetVars;
     procedure SetVars;
     procedure ExecProcess(const cmd, param: string);
  private
    { private declarations }
  public
    { public declarations }
  end; 

const
   ColorList: array [0..15] of TColor = (clBlack,clMaroon,clGreen,clOlive,clNavy,clPurple,clTeal,clGray,
                                         clSilver,clRed,clLime,clYellow,clBlue,clFuchsia,clAqua,clWhite);
   LightColorList: array [0..15] of TColor = ($00505050,clMaroon,clGreen,clOlive,$00FFCC66,clPurple,clTeal,clGray,
                                         clSilver,clRed,clLime,clYellow,clBlue,clFuchsia,clAqua,clWhite);
   FontSizeList: array [0..5] of Integer = (16,32,46,64,72,127);
   SectionEnd: string = '[!SECTIONEND@]';

var
  FormDialog: TFormDialog;
  ShouldSave:Boolean = False;
  TextFileName:string = '';
  MmoTextSl:TStringList;
  CommFileName:string;

implementation

{ TFormDialog }

uses animation;

procedure TFormDialog.GetVars;
begin
   //BACK COLOR
   BACKCOLOR:=clBlack;
   if ((CmbBackColor.ItemIndex>=0) and (CmbBackColor.ItemIndex<=15)) then BACKCOLOR:=ColorList[CmbBackColor.ItemIndex];
   if ((CmbBackColor.ItemIndex>=0) and (CmbBackColor.ItemIndex<=15)) then LIGHTBACKCOLOR:=LightColorList[CmbBackColor.ItemIndex];
   //FONT COLOR
   FONTCOLOR:=clWhite;
   if ((CmbFontColor.ItemIndex>=0) and (CmbFontColor.ItemIndex<=15)) then FONTCOLOR:=ColorList[CmbFontColor.ItemIndex];
   //FONTSIZE
   FONTSIZE:=46;
   if ((CmbFontSize.ItemIndex>=0) and (CmbFontSize.ItemIndex<=5)) then FONTSIZE:=FontSizeList[CmbFontSize.ItemIndex];
   //INITIAL SPEED
   INITIALSPEED:=chr(ord('0')+CmbSpeed.ItemIndex);
   //CENTER TEXT
   CENTERTEXT:=ChkCenter.Checked;
   //FLIP
   FLIPHORIZONTAL:=ChkHorizontal.Checked;
   FLIPVERTICAL:=ChkVertical.Checked;
end;

procedure TFormDialog.FillVars(var sl:TStringlist);
begin
   GetVars;
   //CREATE MAIN STRINGLIST
   sl:=TStringList.Create;
   sl.Add(IntToStr(BACKCOLOR));
   sl.Add(IntToStr(FONTCOLOR));
   sl.Add(IntToStr(FONTSIZE));
   sl.Add(INITIALSPEED);
   if CENTERTEXT then sl.Add('1') else sl.Add('0');
   if FLIPHORIZONTAL then sl.Add('1') else sl.Add('0');
   if FLIPVERTICAL then sl.Add('1') else sl.Add('0');
end;

procedure TFormDialog.StringListToVars(var sl:TStringList);
begin
   //BACK COLOR
   BACKCOLOR:=StrToIntDef(sl[0],0);
   sl.Delete(0);
   //FONT COLOR
   FONTCOLOR:=StrToIntDef(sl[0],0);
   sl.Delete(0);
   //FONTSIZE
   FONTSIZE:=StrToIntDef(sl[0],0);
   sl.Delete(0);
   //INITIAL SPEED
   INITIALSPEED:=sl[0][1];
   sl.Delete(0);
   //CENTER TEXT
   CENTERTEXT:=(sl[0]='1');
   sl.Delete(0);
   //FLIP
   FLIPHORIZONTAL:=(sl[0]='1');
   sl.Delete(0);
   FLIPVERTICAL:=(sl[0]='1');
   sl.Delete(0);
end;

procedure TFormDialog.SetVars;
var
   i:integer;
begin
   //BACK COLOR
   for i:=0 to 15 do if BACKCOLOR=ColorList[i] then begin CmbBackColor.ItemIndex:=i; break; end;
   //FONT COLOR
   for i:=0 to 15 do if FONTCOLOR=ColorList[i] then begin CmbFontColor.ItemIndex:=i; break; end;
   //FONTSIZE
   for i:=0 to 5 do if FONTSIZE=FontSizeList[i] then begin CmbFontSize.ItemIndex:=i; break; end;
   //INITIAL SPEED
   CmbSpeed.ItemIndex:=ord(INITIALSPEED)-ord('0');
   //CENTER TEXT
   ChkCenter.Checked:=CENTERTEXT;
   //FLIP
   ChkHorizontal.Checked:=FLIPHORIZONTAL;
   ChkVertical.Checked:=FLIPVERTICAL;
end;

procedure TFormDialog.ExecProcess(const cmd, param: string);
   {$IFDEF Linux}
var
   AProcess: TProcess;
   {$ENDIF}
begin
   {$IFDEF Windows}
   ShellExecute(0, 'open', pchar(cmd), pchar(param), nil, SW_SHOW);
   {$ENDIF}
   {$IFDEF Darwin}
   Sysutils.ExecuteProcess(cmd, param);
   {$ENDIF}
   {$IFDEF Linux}
   AProcess:=TProcess.Create(nil);
   AProcess.CommandLine := cmd+' '+param;
   AProcess.Execute;
   AProcess.Free;
   {$ENDIF}
end;

procedure TFormDialog.BtnStartClick(Sender: TObject);
var
   OldShouldSave:Boolean;
   OldTextFileName:string;
   cmd, param: string;
begin
   BtnStart.Visible:=False;
   OldShouldSave:=ShouldSave;
   OldTextFileName:=TextFilename;
   TextFileName:=CommFileName;
   DoSaveText;
   cmd:=ParamStr(0);
   param:='"'+TextFileName+'" /A';
   //showmessage(cmd+' '+param);
   ExecProcess(cmd,param);

   ShouldSave:=OldShouldSave;
   TextFileName:=OldTextFilename;
   TmrEnable.Enabled:=True;
end;

procedure TFormDialog.UpdateEditFont(Sender: TObject);
var
   fp:TFontParams;
begin
   MmoText.GetTextAttributes(MmoText.SelStart,fp);
   fp.Style:=[];
   if BtnBold.Checked then fp.Style:=fp.Style+[fsBold];
   if BtnItalic.Checked then fp.Style:=fp.Style+[fsItalic];
   fp.Color:=ColorList[CmbTextColor.ItemIndex];
   MmoText.SetTextAttributes(MmoText.SelStart,MmoText.SelLength,fp);
end;

procedure TFormDialog.BtnLoadClick(Sender: TObject);
var
   sl:TStringList;
   fn:string;
begin
   if not CheckSave then exit;
   if not OpenDialog1.Execute then exit;
   fn:=OpenDialog1.FileName;
   if not FileExists(fn) then exit;
   sl:=TStringList.Create;
   try
      sl.LoadFromFile(fn); //Utf8ToAnsi is required for windows
      StringListToVars(sl);
      SetVars;
      StringListToText(sl);
      ShouldSave:=False;
      TextFileName:=fn;
   finally
      sl.Free;
   end;
end;

procedure TFormDialog.BtnNewClick(Sender: TObject);
begin
   if not CheckSave then exit;
   MmoText.Lines.Clear;
   TextFileName:='';
end;

procedure TFormDialog.BtnSaveAsClick(Sender: TObject);
begin
   SaveDialog1.FileName:='';
   if not SaveDialog1.Execute then exit;
   TextFileName:=SaveDialog1.FileName;
   DoSaveText;
end;

procedure TFormDialog.BtnSaveClick(Sender: TObject);
begin
   if not DoSaveText then begin
      BtnSaveAsClick(nil);
   end;
end;

procedure TFormDialog.ColorChanged(Sender: TObject);
var
   fp:TFontParams;
   selstart,sellength:integer;
begin
   GetVars();
   //DEBUG WIN ERROR MmoText.Font.Color:=FONTCOLOR;
   {$IFDEF WINDOWS}
   SendMessage(MmoText.Handle, EM_SETBKGNDCOLOR, 0, LIGHTBACKCOLOR);
   {$ELSE}
   MmoText.Color:=LIGHTBACKCOLOR;
   {$ENDIF}

   selstart:=MmoText.SelStart;
   sellength:=MmoText.SelLength;
   MmoText.GetTextAttributes(MmoText.SelStart,fp);
   fp.Style:=[];
   fp.Color:=FONTCOLOR;
   MmoText.SelectAll;
   MmoText.SetTextAttributes(MmoText.SelStart,MmoText.SelLength,fp);
   MmoText.SelStart:=selstart;
   MmoText.SelLength:=sellength;
end;

procedure TFormDialog.FormShow(Sender: TObject);
   {$IFDEF Windows}
var
   temppath: array [0..MAX_PATH] of char;
   {$ENDIF}
begin
   MmoText.Text:=StringReplace(MmoText.Text,LineEnding+LineEnding,'<NL>',[rfReplaceAll]);
   MmoText.Text:=StringReplace(MmoText.Text,LineEnding,'',[rfReplaceAll]);
   MmoText.Text:=StringReplace(MmoText.Text,'<NL>',LineEnding+LineEnding,[rfReplaceAll]);
   ColorChanged(nil);
   //
   {$IFDEF Windows}
   SHGetFolderPath(0,CSIDL_LOCAL_APPDATA,0,0,@temppath[0]);
   CommFileName:=IncludeTrailingPathDelimiter(temppath)+'temp.tmp';
   {$ENDIF}
   {$IFDEF Unix}
   CommFileName:=IncludeTrailingPathDelimiter(GetEnv('HOME'));
   if length(trim(CommFileName))=0 then begin
      showmessage('FATAL ERROR: no $HOME variable defined!');
      halt(0);
   end else begin
      CommFileName:=IncludeTrailingPathDelimiter(CommFileName)+'.temp.tmp';
   end;
   {$ENDIF}
   //START ANIMATION IF CALLED WITH PARAMETER
   if ParamStr(2)<>'/A' then exit;
   {$ifdef TP_USEOPENGL}
   Application.CreateForm(TFormScroll, FormScroll);
   FormScroll.Show;
   FormScroll.WindowState:=wsMaximized;
   Application.ProcessMessages;
   FormScroll.BringToFront;
   {$endif}
   TmrAnimate.Enabled:=True;
end;

procedure TFormDialog.UpdateToolbar(Sender: TObject);
var
   fp:TFontParams;
   i:integer;
begin
   MmoText.GetTextAttributes(MmoText.SelStart,fp);
   BtnBold.Checked:=fsBold in fp.Style;
   BtnItalic.Checked:=fsItalic in fp.Style;
   for i:=0 to 15 do begin
      if fp.Color=ColorList[i] then begin
         CmbTextColor.ItemIndex:=i;
         break;
      end;
   end;
end;

procedure TFormDialog.MmoTextKeyPress(Sender: TObject; var Key: char);
begin
   ShouldSave:=True;
end;

procedure TFormDialog.MmoTextKeyUp(Sender: TObject; var Key: Word;
   Shift: TShiftState);
begin
   UpdateToolbar(nil);
end;

procedure TFormDialog.TmrAnimateTimer(Sender: TObject);
begin
   TmrAnimate.Enabled:=False;
   MmoTextSl:=TStringList.Create;
   MmoTextSl.LoadFromFile(ParamStr(1));
   StringListToVars(MmoTextSl);
   ShowAnimation(Screen.Width,Screen.Height);
end;

procedure TFormDialog.TmrEnableTimer(Sender: TObject);
begin
   TmrEnable.Enabled:=False;
   BtnStart.Visible:=True;
end;

function TFormDialog.DoSaveText:Boolean;
var
   sl:TStringList;
begin
   result:=False;
   if TextFileName='' then exit;
   sl:=TStringList.Create;
   try
      FillVars(sl);
      AddFormatStrings(sl);
      sl.SaveToFile(TextFileName);
      result:=True;
      ShouldSave:=False;
   finally
      sl.Free;
   end;
end;

function TFormDialog.CheckSave:Boolean;
var
   md:integer;
begin
   result:=False;
   if not ShouldSave then begin
      result:=True;
      exit;
   end;
   md:=MessageDlg('Text is not saved, do you want to save it now?',mtWarning,[mbYes,mbNo,mbCancel],0);
   if md=mrYes then begin
      BtnSaveClick(nil);
      result:= not ShouldSave;
   end;
   if md=mrNo then result:=True;
   if md=mrCancel then result:=False;
end;

procedure TFormDialog.AddFormatStrings(var sl:tstringlist);
var
   oldss,oldsl,selstart,sellength,ofs,len:Integer;
   fp:TFontParams;
   fptext:string;
begin
   MmoText.SetFocus;
   oldss:=MmoText.SelStart;
   oldsl:=MmoText.SelLength;
   selstart:=0;
   sellength:=0;
   ofs:=0;
   len:=0;
   while (ofs+len)<length(MmoText.Text) do begin
      MmoText.GetStyleRange(selstart,ofs,len);
      if (ofs=SelStart) and (len=SelLength) then begin
         ofs:=ofs+len;
         MmoText.GetStyleRange(ofs,ofs,len);
      end;
      selstart:=ofs;
      sellength:=len;

      //SAVE SECTION
      MmoText.GetTextAttributes(ofs,fp);
      fptext:='[@$'+format('%08.8x',[fp.Color]);
      if fsBold in fp.Style then fptext:=fptext+'B' else fptext:=fptext+' ';
      if fsItalic in fp.Style then fptext:=fptext+'I' else fptext:=fptext+' ';
      fptext:=fptext+'!]';
      sl.Text:=sl.Text+fptext+copy(MmoText.Text,ofs+1,len)+SectionEnd;
   end;
   MmoText.SelStart:=oldss;
   MmoText.SelLength:=oldsl;
end;

procedure TFormDialog.StringListToText(var sl:TStringList);
type
   TFormatArr = record
      color:TColor;
      style:TFontStyles;
      ofs,len:integer;
   end;
var
   formatpos,ofs,ofs1,len:integer;
   formatstr:string;
   s:string;
   FormatArr:array of TFormatArr;
   p:integer;
   fp:TFontParams;
begin
   MmoText.Lines.Clear;
   SetLength(FormatArr,0);
   len:=15;

   repeat
      ofs:=pos('[@$',sl.Text);
      if ofs>0 then begin
         p:=length(FormatArr);
         SetLength(FormatArr,p+1);
         //PROCESS FORMAT [@$00000000BI!] AND REMOVE
         //               123456789012345
         formatstr:=copy(sl.Text,ofs,len);
         FormatArr[p].Color:=clWhite;
         FormatArr[p].Style:=[];
         if copy(formatstr,12,1)='B' then FormatArr[p].Style:=FormatArr[p].Style+[fsBold];
         if copy(formatstr,13,1)='I' then FormatArr[p].Style:=FormatArr[p].Style+[fsItalic];
         formatstr:=copy(formatstr,3,9);
         try
            FormatArr[p].Color:=StrToIntDef(formatstr,0);
         finally
         end;
         sl.Text:=copy(sl.Text,ofs+len,length(sl.Text));
         //FIND END AND CUT TEXT
         ofs1:=pos(SectionEnd,sl.Text);
         if ofs1=0 then begin
            s:=sl.Text;
            sl.Text:='';
         end else begin
            s:=copy(sl.Text,1,ofs1-1);
            sl.Text:=copy(sl.text,length(s),length(sl.Text));
         end;
         //ADD TEXT AND SAVE FORMAT
         formatpos:=length(MmoText.Text);
         MmoText.Text:=MmoText.Text+s;
         FormatArr[p].ofs:=formatpos;
         FormatArr[p].len:=length(s);
      end;
   until ofs=0;
   //FORMAT EVERYTHING
   for p:=0 to length(FormatArr)-1 do begin
      MmoText.GetTextAttributes(ofs,fp);
      fp.Color:=FormatArr[p].color;
      fp.Style:=FormatArr[p].style;
      MmoText.SetTextAttributes(FormatArr[p].ofs,FormatArr[p].len,fp);
   end;
end;


initialization
  {$I dialog.lrs}

end.
