program teleprompters;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LResources
  { you can add units after this }, LazOpenGLContext, dialog, Animation,
  richmemopackage, GlTileBitmap;

{$IFDEF WINDOWS}{$R manifest.rc}{$ENDIF}

{$IFDEF WINDOWS}{$R teleprompters.rc}{$ENDIF}

begin
   {$I teleprompters.lrs}
  Application.Title:='Teleprompters';
  Application.Initialize;
  Application.CreateForm(TFormDialog, FormDialog);
  Application.Run;
end.

