unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, DateUtils, IntfGraphics, FPImage,
  Config,
  tlib,tstr,tcfg,tlcl;

{$i const.inc}

type

  { TfmMain }

  TfmMain = class(TForm)
    lbTime: TLabel;
    lbDate: TLabel;
    miExit: TMenuItem;
    Panel1: TPanel;
    ClockTimer: TTimer;
    popMain: TPopupMenu;
    sbClose: TSpeedButton;
    TrayIcon: TTrayIcon;
    procedure ClockTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miExitClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
  private
    { private declarations }

    //***** Локаль
    msLocaleFolder      : String;

    //***** Тема
    msThemeFolder,
    msMicroCloseGlyph,
    msButtonOkGlyph,
    msButtonCancelGlyph : String;

    //***** Clock
    masMonths       : array[1..ciMonthCount] of String;
    masWeekDays     : array[1..ciWeekDayCount] of String;
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

    //***** Форма
    mlFormerX,
    mlFormerY       : LongInt;

    //***** Конфигурация
    mblStickyFlag    : Boolean;
    mblStickyMargin  : Integer;
  public
    { public declarations }

    //procedure FormatDate;
    function  readConfig : Boolean;
    function  writeConfig : Boolean;
    procedure setConfig;
    procedure getConfig;
    function  readLocale : Boolean;
    function  readTheme : Boolean;
    procedure applyTheme;

    procedure askSystemDateAndTime;
    procedure displayDate;
    procedure displayTime;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

procedure TfmMain.FormActivate(Sender: TObject);
begin

  OnActivate:=Nil;
  // Обработка ошибок!
  readConfig; //
  readLocale; //
  readTheme;
  applyTheme;
  askSystemDateAndTime;
  displayTime;
  displayDate;
  //fmMain.
end;


procedure TfmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  WriteConfig;
end;


procedure TfmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  {ifdef __WINDOWS__}
  mlFormerX:=X;
  mlFormerY:=Y;
  Cursor:=crSizeAll;
  {endif}
end;


procedure TfmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  {ifdef __WINDOWS__}
  if MouseCapture then begin
    Left:=Mouse.CursorPos.X-mlFormerX;
    Top:=Mouse.CursorPos.Y-mlFormerY;
  end;
  {endif}
end;


procedure TfmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  {ifdef __WINDOWS__}
   Cursor:=crDefault;
  {endif}
end;


procedure TfmMain.miExitClick(Sender: TObject);
begin
  Close;
end;


procedure TfmMain.sbCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TfmMain.TrayIconClick(Sender: TObject);
begin

  TrayIcon.BalloonHint:=msClockDateHint+LF+msClockTimeHint;
  TrayIcon.ShowBalloonHint;
end;


procedure TfmMain.TrayIconDblClick(Sender: TObject);
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

    inc(mwClockSeconds);
    DisplayTime;
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


function TfmMain.readConfig : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  //***** Общие параметры
  if IniOpen(g_sProgrammFolder+csEtcFolder+csIniFileName) then begin

    msLocaleFolder:=IniReadString('main','locale',csLocaleFolder+'en_US');
    Slashit(msLocaleFolder);
    msThemeFolder:=IniReadString('main','theme',csThemeFolder+'main');
    Slashit(msThemeFolder);
    IniClose;
    Result:=True;
  end;

  //***** Параметры окон
  if Result and IniOpen(g_sProgrammFolder+csEtcFolder+csWinIniFileName) then begin

    IniReadForm(fmMain);
    IniClose;
    Result:=True;
  end else begin

    Result:=False;
  end;

end;


function TfmMain.writeConfig : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  //***** Общие параметры
  //IniOpen();

  //***** Прилипание к краям экрана

  //IniClose();

  //***** Параметры окон
  if IniOpen(g_sProgrammFolder+csEtcFolder+csWinIniFileName) then begin
    IniSaveForm(fmMain);
    IniClose;
    Result:=True;
  end;
end;


procedure TfmMain.setConfig;
begin

  //***** Прилипание к краям экрана
  fmConfig.chbStickyFlag.Checked:=mblStickyFlag;
  fmConfig.edStickyMargin.Text:=IntToStr(miStickyMargin);
end;


procedure TfmMain.getConfig;
begin

  //***** Прилипание к краям экрана
  mblStickyFlag:=fmConfig.chbStickyFlag;
  miStickyMargin:=StrToIntDef(fmConfig.edStickyMargin.Text,0);
  if miStickyMargin<2 then
    mblStickyFlag:=False;
end;


function TfmMain.readLocale : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  if IniOpen(g_sProgrammFolder+csLocaleFolder+msLocaleFolder+'main.ini') then begin

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


function  TfmMain.readTheme : Boolean;
var lsMicroPath,
    lsButtonPath : String;
begin

  Result:=False;
  if IniOpen(g_sProgrammFolder+csThemeFolder+msThemeFolder+'theme.ini') then begin

    //***** Глифы микрокнопок
    lsMicroPath:=IniReadString(csMicroSection,'path',csDefaultMicroFolder);
    SlashIt(lsMicroPath);
    msMicroCloseGlyph:=lsMicroPath+IniReadString(csMicroSection,'close','red.png');

    //***** Глифы обычных кнопок
    lsButtonPath:=IniReadString(csButtonsSection,'path',csDefaultMicroFolder);
    SlashIt(lsButtonPath);
    msButtonOkGlyph:=lsButtonPath+IniReadString(csButtonsSection,'ok','dialog-ok-apply.png');
    msButtonCancelGlyph:=lsButtonPath+IniReadString(csButtonsSection,'cancel','dialog-cancel.png');
    IniClose;
    Result:=FileExists(msMicroCloseGlyph) and
            FileExists(msButtonOkGlyph) and
            FileExists(msButtonOkGlyph);
  end;
end;


procedure TfmMain.applyTheme;
begin

  if sbClose.Glyph.IsFileExtensionSupported(ExtractFileExt(msMicroCloseGlyph)) then
    sbClose.Glyph.LoadFromFile(g_sProgrammFolder+msMicroCloseGlyph);
end;


procedure TfmMain.askSystemDateAndTime;
var ldtNow : TDateTime;
begin

  ldtNow:=Now;
  DecodeTime(ldtNow,mwClockHours,mwClockMinutes,mwClockSeconds,mwClockMSeconds);
  DecodeDate(ldtNow,mwClockYear,mwClockMonth,mwClockDay);
  mwClockWeekDay:=DayOfTheWeek(ldtNow);
end;


procedure TfmMain.displayDate;
begin

  msClockDateHint:=AlignRight(IntToStr(mwClockDay),2,'0')+' '+
                  masMonths[mwClockMonth]+' '+
                  IntToStr(mwClockYear);
  lbDate.Caption:=msClockDateHint;
end;


procedure TfmMain.displayTime;
begin

  msClockTimeHint:=IntToStr(mwClockHours)+':'+
                   AlignRight(IntToStr(mwClockMinutes),2,'0')+':'+
                   AlignRight(IntToStr(mwClockSeconds),2,'0');
  lbTime.Caption:=msClockTimeHint;
end;


end.

