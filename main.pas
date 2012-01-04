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
    ClockTimer: TTimer;
    TrayIcon1: TTrayIcon;
    procedure ClockTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    { private declarations }
    msLocaleFolder : String;
    //***** Clock
    masMonths   : array[1..ciMonthCount] of String;
    masWeekDays : array[1..ciWeekDayCount] of String;
    msClockTimeHint : String;
    msClockDateHint : String;

    mwClockYear,
    mwClockMonth,
    mwClockDay,
    mwClockWeekDay,
    mwClockHours,
    mwClockMinutes,
    mwClockSeconds,
    mwClockMSeconds : Word;
  public
    { public declarations }

    //procedure FormatDate;
    function ReadConfig : Boolean;
    function ReadLocale : Boolean;

    procedure AskSystemDateAndTime;
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
  AskSystemDateAndTime;
  DisplayTime;
  DisplayDate;
end;


procedure TfmMain.TrayIcon1Click(Sender: TObject);
begin

  TrayIcon1.BalloonHint:=msClockDateHint+LF+msClockTimeHint;
  TrayIcon1.ShowBalloonHint;
end;


procedure TfmMain.TrayIcon1DblClick(Sender: TObject);
begin

  if fmMain.Visible then
    fmMain.Hide
  else
    fmMain.Show;
end;


procedure TfmMain.ClockTimerTimer(Sender: TObject);
var   ldtNow     : TDateTime;
      lsTrayHint : String;
begin

  //***** Минуту еще не натикало?
  if mwClockSeconds<ciMaxSecond then begin

    //DecodeTime(Time,m_wClockHours,m_wClockMinutes,m_wClockSeconds,m_wClockMSeconds);
    inc(mwClockSeconds);
    fmMain.Update;
  end else begin

    //***** Уже натикало
    mwClockSeconds:=0;


    //***** Час еще не натикало?
    if mwClockMinutes<ciMaxMinute then begin

      //inc(mwClockMinutes)
      AskSystemDateAndTime;
      DisplayTime;
      DisplayDate;

    end else begin

      //***** Уже натикало
      mwClockMinutes:=0;

      //***** Сутки не натикали еще?
      if mwClockHours<ciMaxHour then begin

        inc(mwClockHours);
      end else begin

        //***** Уже натикали
        mwClockHours:=0;
      end;

    end;
  end;
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
      masWeekDays[liIdx]:=IniReadString('weekdays','weekday'+IntToStr(liIdx));
    end;

    IniClose;
    Result:=True;
  end;
end;


procedure TfmMain.AskSystemDateAndTime;
var ldtNow : TDateTime;
begin

  ldtNow:=Now;
  DecodeTime(ldtNow,mwClockHours,mwClockMinutes,mwClockSeconds,mwClockMSeconds);
  DecodeDate(ldtNow,mwClockYear,mwClockMonth,mwClockDay);
  mwClockWeekDay:=DayOfTheWeek(ldtNow);
end;


procedure TfmMain.DisplayDate;
begin

  msClockDateHint:=AlignRight(IntToStr(mwClockDay),2,'0')+' '+
                  masMonths[mwClockMonth]+' '+
                  IntToStr(mwClockYear);
  lbDate.Caption:=msClockDateHint;
end;


procedure TfmMain.DisplayTime;
begin

  msClockTimeHint:=IntToStr(mwClockHours)+':'+
                   AlignRight(IntToStr(mwClockMinutes),2,'0')+':'+
                   AlignRight(IntToStr(mwClockSeconds),2,'0');
  lbTime.Caption:=msClockTimeHint;
end;


end.

