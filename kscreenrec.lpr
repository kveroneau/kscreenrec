program kscreenrec;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, utils
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Kevin''s Screen Recorder';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TScreenRec, ScreenRec);
  Application.Run;
end.

