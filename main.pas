unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DateUtils,
  Config,
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
    msLocaleFolder : String;
    //***** Clock
    masMonths : array[1..ciMonthCount] of String;
    masWeekDays : array[1..ciWeekDayCount] of String;
  public
    { public declarations }

    //procedure FormatDate;
    function ReadConfig : Boolean;
    function ReadLocale : Boolean;

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
  ReadConfig; //
  ReadLocale; //
  DisplayTime;
  DisplayDate;
end;


function TfmMain.ReadConfig : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  if true then begin end;
  //***** Общие параметры
  if IniOpen(g_sProgrammFolder+csEtcFolder+csIniFileName) then begin
    msLocaleFolder:=IniReadString('main','locale',csEtcFolder+'en_US');
    IniClose;
    Slashit(msLocaleFolder);
    Result:=True;
  end;

end;


function TfmMain.ReadLocale : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  if IniOpen(g_sProgrammFolder+csLocalePath+msLocaleFolder+'main.ini') then begin

    //***** Названия месяцев
    for liIdx:=1 to ciMonthCount do begin
      masMonths[liIdx]:=IniReadString('months','month'+IntToStr(liIdx));
    end;

    //***** Названия дней недели
    for liIdx:=1 to ciWeekDayCount do begin
      masMonths[liIdx]:=IniReadString('weekdays','weekday'+IntToStr(liIdx));
    end;

    IniClose;
    Result:=True;
  end;
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

