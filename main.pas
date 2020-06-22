unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, utils;

type

  { TScreenRec }

  TScreenRec = class(TForm)
    Label7: TLabel;
    Second: TLabel;
    Minute: TLabel;
    PlayBtn: TButton;
    KillBtn: TButton;
    StopBtn: TButton;
    RecBtn: TButton;
    FLVFile: TEdit;
    Label6: TLabel;
    RecSize: TComboBox;
    CopyYBtn: TButton;
    Label5: TLabel;
    RecX: TEdit;
    RecY: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PageControl1: TPageControl;
    Proc: TProcess;
    RecTab: TTabSheet;
    Timer: TTimer;
    VBoxTab: TTabSheet;
    VBoxY: TEdit;
    VCButton: TButton;
    procedure CopyYBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KillBtnClick(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure RecBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure VCButtonClick(Sender: TObject);
  private
    FMinute, FSecond: Integer;
    procedure AddOption(const o,p: string);
    procedure startRecording;
    function generateFileName: string;
  public

  end;

var
  ScreenRec: TScreenRec;

implementation

{$R *.lfm}

{ TScreenRec }

procedure TScreenRec.VCButtonClick(Sender: TObject);
var
  i: integer;
begin
  i:=StrToInt(VBoxY.Text);
  VBoxY.Text:=IntToStr(GetVBoxY(i));
end;

procedure TScreenRec.AddOption(const o, p: string);
begin
  Proc.Parameters.Add(o);
  Proc.Parameters.Add(p);
end;

procedure TScreenRec.startRecording;
begin
  if Proc.Active then
    Exit;
  Proc.Executable:='/usr/bin/ffmpeg';
  Proc.Parameters.Clear;
  AddOption('-f','pulse');
  AddOption('-ac','2');
  AddOption('-i','record-n-play.monitor');
  AddOption('-f','x11grab');
  AddOption('-r','10');
  AddOption('-s',RecSize.Text);
  AddOption('-i',Concat(':0.0+',RecX.Text,',',RecY.Text));
  AddOption('-c:v','libx264');
  AddOption('-pix_fmt','yuv420p');
  AddOption('-preset','ultrafast');
  AddOption('-g','20');
  AddOption('-b:v','2500k');
  AddOption('-c:a','libmp3lame');
  AddOption('-ar','44100');
  AddOption('-threads','0');
  AddOption('-bufsize','512k');
  AddOption('-f','flv');
  Proc.Parameters.Add(FLVFile.Text);
  Proc.Active:=True;
  RecBtn.Enabled:=False;
  PlayBtn.Enabled:=False;
  FMinute:=0;
  FSecond:=0;
  Minute.Caption:='0';
  Second.Caption:='00';
  Timer.Enabled:=True;
end;

function TScreenRec.generateFileName: string;
var
  i: integer;
  FOk: boolean;
  fname: string;
begin
  i:=1;
  FOk:=False;
  repeat
    fname:=Concat('/tmp/video_',IntToStr(i),'.flv');
    if not FileExists(fname) then
      FOk:=True;
    Inc(i);
  until FOk;
  Result:=fname;
end;

procedure TScreenRec.FormCreate(Sender: TObject);
begin
  Proc.Options:=[poNewConsole];
  FLVFile.Text:=generateFileName;
end;

procedure TScreenRec.KillBtnClick(Sender: TObject);
begin
  if Proc.Running then
    Proc.Active:=False
  else
    ShowMessage('Not Running.');
end;

procedure TScreenRec.PlayBtnClick(Sender: TObject);
begin
  if Proc.Active then
    Exit;
  Proc.Executable:='/usr/bin/mplayer';
  Proc.Parameters.Clear;
  Proc.Parameters.Add(FLVFile.Text);
  RecBtn.Enabled:=False;
  Proc.Active:=True;
end;

procedure TScreenRec.RecBtnClick(Sender: TObject);
begin
  if FileExists(FLVFile.Text) then
    FLVFile.Text:=generateFileName;
  if (RecX.Text = '') or (RecY.Text = '') then
    Exit;
  startRecording;
end;

procedure TScreenRec.StopBtnClick(Sender: TObject);
var
  c: string[1];
  i: integer;
begin
  i:=0;
  c:='q';
  {if Proc.Running then
    Proc.Input.Write(c[1], 1);
  repeat
    if i = 100 then
    begin
      Proc.Input.Write(c[1], 1);
      i:=0;
    end;
    Inc(i);
    Application.ProcessMessages;
  until Not Proc.Running;}
  RecBtn.Enabled:=True;
  PlayBtn.Enabled:=True;
end;

procedure TScreenRec.TimerTimer(Sender: TObject);
begin
  if Not Proc.Running then
  begin
    Timer.Enabled:=False;
    ShowMessage('Recording has stopped!');
    Exit;
  end;
  Inc(FSecond);
  if FSecond = 60 then
  begin
    Inc(FMinute);
    FSecond:=0;
  end;
  Minute.Caption:=IntToStr(FMinute);
  Second.Caption:=IntToStr(FSecond);
end;

procedure TScreenRec.CopyYBtnClick(Sender: TObject);
begin
  RecY.Text:=VBoxY.Text;
end;

end.

