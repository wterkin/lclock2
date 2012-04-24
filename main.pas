unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, DateUtils, IntfGraphics, FPImage, LCLClasses,
  Config,
  tlib,tstr,tcfg,tlcl;

{$i const.inc}

type

  { TfmMain }

  TfmMain = class(TForm)
    lbTime: TLabel;
    lbDate: TLabel;
    pmiSetup: TMenuItem;
    pmiExit: TMenuItem;
    Panel1: TPanel;
    ClockTimer: TTimer;
    popMain: TPopupMenu;
    sbClose: TSpeedButton;
    sbMinimize: TSpeedButton;
    TrayIcon: TTrayIcon;
    procedure ClockTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbDateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbTimeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pmiExitClick(Sender: TObject);
    procedure pmiSetupClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
    procedure sbMinimizeClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
  private
    { private declarations }

    //***** Локаль
    msLocaleFolder      : String;

    //***** Тема
    msThemeFolder,
    msMicroCloseGlyph,
    msMicroMinimizeGlyph,
    msButtonOkGlyph,
    msButtonCancelGlyph : String;

    //***** Clock
    masMonths          : array[1..ciMonthCount] of String;
    masWeekDays        : array[1..ciWeekDayCount] of String;
    msClockTimeHint    : String;
    msClockDateHint    : String;
    mwClockYear,
    mwClockMonth,
    mwClockDay,
    mwClockWeekDay,
    mwClockHours,
    mwClockMinutes,
    mwClockSeconds,
    mwClockMSeconds    : Word;

    //***** Форма
    mlFormerX,
    mlFormerY          : LongInt;


    //***** Конфигурация
    mblStickyFlag      : Boolean;
    miStickyMargin     : Integer;

    miNormalTimeWidth  : Integer;
    miNormalDateLeft   : Integer;
    miNoTimeDateLeft   : Integer;

    //mblTransparentFlag : Boolean;
    //miTransparentValue : Integer;
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
    procedure getDateAndTimeDefaultPosition;
    procedure adjustDateAndTimePosition;
    //procedure  localeComponent(poComp : TLCLComponent; psDefault : String = '');
    //procedure  localeComponent(poComp : TControl; psDefault : String = '');
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

procedure TfmMain.FormActivate(Sender: TObject);
begin

  OnActivate:=Nil;
  // Обработка ошибок!
  Hide;
  getDateAndTimeDefaultPosition;
  readConfig; //
  setConfig;
  readLocale; //
  readTheme;
  applyTheme;
  askSystemDateAndTime;
  displayTime;
  displayDate;
  Show;
  //fmMain.
end;


procedure TfmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  WriteConfig;
end;


procedure TfmMain.FormCreate(Sender: TObject);
begin

end;


procedure TfmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  {ifdef __WINDOWS__}
  if Sender is TLabel then begin
    mlFormerX:=X;
    mlFormerY:=Y+24;
  end else begin
    mlFormerX:=X;
    mlFormerY:=Y;
  end;
  Cursor:=crSizeAll;
  {endif}
end;


procedure TfmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Sender is TLabel) and (Cursor=crSizeAll) then
  begin
    MouseCapture:=True;
  end;

  {ifdef __WINDOWS__}
  if MouseCapture then begin
    fmMain.Left:=Mouse.CursorPos.X-mlFormerX;
    fmMain.Top:=Mouse.CursorPos.Y-mlFormerY;
    if mblStickyFlag then begin
      if fmMain.Left<=miStickyMargin then
        fmMain.Left:=0;
      if fmMain.Left>=Screen.DesktopWidth-(fmMain.Width+miStickyMargin) then
        fmMain.Left:=Pred(Screen.DesktopWidth-fmMain.Width);

      if fmMain.Top<=miStickyMargin then
        fmMain.Top:=0;
      if fmMain.Top>=Screen.DesktopHeight-(fmMain.Height+miStickyMargin) then
        fmMain.Top:=Pred(Screen.DesktopHeight-fmMain.Height);

    end;
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


procedure TfmMain.lbDateMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  mlFormerX:=X+lbDate.Left;
  mlFormerY:=Y+lbDate.Top;
  Cursor:=crSizeAll;
end;


procedure TfmMain.lbTimeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  mlFormerX:=X+lbTime.Left;
  mlFormerY:=Y+lbTime.Top;
  Cursor:=crSizeAll;
end;


procedure TfmMain.pmiExitClick(Sender: TObject);
begin
  Close;
end;


procedure TfmMain.pmiSetupClick(Sender: TObject);
begin

  fmConfig.ShowModal;
  getConfig;
  writeConfig;
end;


procedure TfmMain.sbCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TfmMain.sbMinimizeClick(Sender: TObject);
begin

  fmMain.Hide;
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

    //***** Прилипание к краям экрана
    mblStickyFlag:=IniReadBool(csConfigSection,csStickyFlag);
    miStickyMargin:=IniReadInt(csConfigSection,csStickyMargin);

    //***** Прозрачность
    Self.AlphaBlend:=IniReadBool(csConfigSection,csTransparentFlag);
    Self.AlphaBlendValue:=IniReadInt(csConfigSection,csTransparentValue);

    //***** Кнопка минимизации
    sbMinimize.Visible:=IniReadBool(csConfigSection,csMinimizeBtnVisible);

    //***** Кнопка закрытия
    sbClose.Visible:=IniReadBool(csConfigSection,csCloseBtnVisible);

    //***** Показывать время
    lbTime.Visible:=IniReadBool(csConfigSection,csVisibleTimeFlag);

    //***** Показывать дату
    lbDate.Visible:=IniReadBool(csConfigSection,csVisibleDateFlag);

    //***** Скорректируем позиции даты и времени
    adjustDateAndTimePosition;

    IniClose;
    Result:=True;
  end;

  //***** Параметры окон
  if Result and IniOpen(g_sProgrammFolder+csEtcFolder+csWinIniFileName) then begin

    IniReadForm(fmMain);
    IniReadForm(fmConfig);
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
  IniOpen(g_sProgrammFolder+csEtcFolder+csIniFileName);

  //***** Прилипание к краям экрана
  IniWriteBool(csConfigSection,csStickyFlag,mblStickyFlag);
  IniWriteInt(csConfigSection,csStickyMargin,miStickyMargin);

  //***** Прозрачность
  IniWriteBool(csConfigSection,csTransparentFlag,AlphaBlend);
  IniWriteInt(csConfigSection,csTransparentValue,AlphaBlendValue);

  //***** Кнопка минимизации
  IniWriteBool(csConfigSection,csMinimizeBtnVisible,sbMinimize.Visible);

  //***** Кнопка закрытия
  IniWriteBool(csConfigSection,csCloseBtnVisible,sbClose.Visible);

  //***** Показывать время
  IniWriteBool(csConfigSection,csVisibleTimeFlag,lbTime.Visible);

  //***** Показывать дату
  IniWriteBool(csConfigSection,csVisibleDateFlag,lbDate.Visible);

  IniClose();

  //***** Параметры окон
  if IniOpen(g_sProgrammFolder+csEtcFolder+csWinIniFileName) then begin
    IniSaveForm(fmMain);
    IniSaveForm(fmConfig);
    IniClose;
    Result:=True;
  end;
end;


procedure TfmMain.setConfig;
begin

  //***** Прилипание к краям экрана
  fmConfig.chbStickyFlag.Checked:=mblStickyFlag;
  fmConfig.edStickyMargin.Text:=IntToStr(miStickyMargin);

  //***** Прозрачность
  fmConfig.chbTransparent.Checked:=AlphaBlend;  //mblTransparentFlag;
  fmConfig.trbTransparent.Position:=AlphaBlendValue; //miTransparentValue;

  //***** Кнопка минимизации
  fmConfig.chbMinimizeBtnVisible.Checked:=sbMinimize.Visible;

  //***** Кнопка закрытия
  fmConfig.chbCloseBtnVisible.Checked:=sbClose.Visible;

  //***** Показывать время
  fmConfig.chbShowTime.Checked:=lbTime.Visible;

  //***** Показывать дату
  fmConfig.chbShowDate.Checked:=lbDate.Visible;

end;


procedure TfmMain.getConfig;
begin

  //***** Прилипание к краям экрана
  mblStickyFlag:=fmConfig.chbStickyFlag.Checked;
  miStickyMargin:=StrToIntDef(fmConfig.edStickyMargin.Text,0);
  if miStickyMargin<2 then
    mblStickyFlag:=False;

  //***** Прозрачность
  Self.AlphaBlend:=fmConfig.chbTransparent.Checked;
  Self.AlphaBlendValue:=fmConfig.trbTransparent.Position;

  //***** Кнопка минимизации
  sbMinimize.Visible:=fmConfig.chbMinimizeBtnVisible.Checked;

  //***** Кнопка закрытия
  sbClose.Visible:=fmConfig.chbCloseBtnVisible.Checked;

  //***** Показывать время
  lbTime.Visible:=fmConfig.chbShowTime.Checked;

  //***** Показывать дату
  lbDate.Visible:=fmConfig.chbShowDate.Checked;

  //***** Скорректируем позиции даты и времени
  adjustDateAndTimePosition;

end;


function TfmMain.readLocale : Boolean;
var liIdx : Integer;
begin

  Result:=False;
  if IniOpen(g_sProgrammFolder+csLocaleFolder+msLocaleFolder+csMainLocaleFilename) then begin

    //***** Названия месяцев
    for liIdx:=1 to ciMonthCount do begin
      masMonths[liIdx]:=IniReadString('months','month'+IntToStr(liIdx));
    end;

    //***** Названия дней недели
    for liIdx:=1 to ciWeekDayCount do begin
      masWeekDays[liIdx]:=IniReadString('weekdays','weekday'+IntToStr(liIdx));
    end;

    IniClose;

    if IniOpen(g_sProgrammFolder+csLocaleFolder+msLocaleFolder+csFormsLocaleFilename) then begin
      //localeComponent(fmMain.pmiExit,'*Exit*');
      //localeComponent(fmMain.pmiSetup,'*Setup*');
      //localeComponent(fmConfig.chbStickyFlag,'*Sticky edges*');
      //localeComponent(fmConfig.labStickyMargin,'*Margin*');
      //localeComponent(fmConfig.chbTransparent,'**');
      //localeComponent(fmConfig,'');

      pmiExit.Caption:=IniReadString(Self.Name,pmiExit.Name,'*Exit*');
      pmiSetup.Caption:=IniReadString(Self.Name,pmiSetup.Name,'*Setup*');
      fmConfig.chbStickyFlag.Caption:=IniReadString(fmConfig.Name,fmConfig.chbStickyFlag.Name,'*Sticky edges*');
      fmConfig.labStickyMargin.Caption:=IniReadString(fmConfig.Name,fmConfig.labStickyMargin.Name,'*Margin*');
      fmConfig.chbTransparent.Caption:=IniReadString(fmConfig.Name,fmConfig.chbTransparent.Name,'*Transparent*');
      IniClose;
      Result:=True;
    end;
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
    msMicroMinimizeGlyph:=lsMicroPath+IniReadString(csMicroSection,'minimize','blue.png');

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


procedure TfmMain.getDateAndTimeDefaultPosition;
begin

  miNormalDateLeft:=lbDate.Left;
  miNormalTimeWidth:=lbTime.Width;
end;


procedure TfmMain.adjustDateAndTimePosition;
begin

  if lbTime.Visible then begin

    lbTime.Width:=miNormalTimeWidth;
    lbDate.Left:=miNormalDateLeft;

  end else begin

    lbTime.Width:=1;
    lbDate.Left:=ciNoTimeDateLeft;
  end;
end;


procedure TfmMain.applyTheme;
begin

  if sbClose.Glyph.IsFileExtensionSupported(ExtractFileExt(msMicroCloseGlyph)) then
    sbClose.Glyph.LoadFromFile(g_sProgrammFolder+msMicroCloseGlyph);

  if sbMinimize.Glyph.IsFileExtensionSupported(ExtractFileExt(msMicroMinimizeGlyph)) then
    sbMinimize.Glyph.LoadFromFile(g_sProgrammFolder+msMicroMinimizeGlyph);
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

{
procedure localeComponent(poComp : TLCLComponent; psDefault : String='');
begin

  //poComp.Caption:=IniReadString(poComp.Owner.Name,poComp.Name,psDefault);
end;
 }
end.

