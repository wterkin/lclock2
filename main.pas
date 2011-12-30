unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DateUtils,
  tlib,tstr,tcfg;

{$i const.inc}

type

  { TfmMain }

  TfmMain = class(TForm)
    lbTime: TLabel;
    lbDate: TLabel;
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
  private
    { private declarations }
    msMonthsFile : String;
    //***** Clock
    masMonths : array[1..12] of String;
  public
    { public declarations }

    //procedure FormatDate;
    procedure ReadConfig;
    procedure DisplayDate;
    procedure DisplayTime;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

procedure TfmMain.FormActivate(Sender: TObject);
begin

  OnActivate:=Nil;
  ReadConfig;
  DisplayTime;
  DisplayDate;
end;


procedure TfmMain.ReadConfig;
var liIdx : Integer;
begin

  //***** Общие параметры
  IniOpen(g_sProgrammFolder+'etc'+ccSlashChar+csIniFileName);
  msMonthsFile:=IniReadString('main','monthsfile','etc'+ccSlashChar+'months_en.ini');
  IniClose;

  //***** Названия месяцев
  IniOpen(g_sProgrammFolder+'etc'+ccSlashChar+msMonthsFile);
  for liIdx:=1 to 12 do begin
    masMonths[liIdx]:=IniReadString('main','month'+IntToStr(liIdx));
  end;
  IniClose;
end;


procedure TfmMain.DisplayDate;
var ldtNow : TDateTime;
begin
  ldtNow:=Now;
  lbDate.Caption:=AlignRight(IntToStr(DayOf(ldtNow)),2,'0')+' '+
                  masMonths[MonthOf(ldtNow)]+' '+
                  IntToStr(YearOf(ldtNow));
end;


procedure TfmMain.DisplayTime;
var lwClockHours,
    lwClockMinutes,
    lwClockSeconds,
    lwClockMSeconds : Word;
    ldtNow          : TDateTime;
begin

  ldtNow:=Now;
  DecodeTime(ldtNow,lwClockHours,lwClockMinutes,lwClockSeconds,lwClockMSeconds);
  lbTime.Caption:=IntToStr(lwClockHours)+':'+
                   AlignRight(IntToStr(lwClockMinutes),2,'0')+':'+
                   AlignRight(IntToStr(lwClockSeconds),2,'0');
end;

end.

