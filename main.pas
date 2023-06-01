unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, DateUtils, IntfGraphics, FPImage, // LCLClasses,
  ComCtrls, Config
  {, tlib}, tapp, tstr, tini;

{$i const.inc}

type

  { TfmMain }
  TMonthsArray = array[1..ciMonthCount] of String;

  TfmMain = class(TForm)
    Bevel1 : TBevel;
    Bevel2 : TBevel;
    lbDate : TLabel;
    lbTime : TLabel;
    pmiSetup: TMenuItem;
    pmiExit: TMenuItem;
    ClockTimer: TTimer;
    popMain: TPopupMenu;
    sbClose: TSpeedButton;
    sbMinimize: TSpeedButton;
    TrayIcon: TTrayIcon;
    procedure ClockTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender : TObject);
    procedure FormMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure FormMouseUp(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure lbDateMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure lbTimeMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
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
    msMicroBtnPath,
    msMicroCloseGlyph,
    msMicroMinimizeGlyph : String;
    //msButtonPath,
    //msButtonOkGlyph
    //msButtonCancelGlyph

    //***** Clock
    masMonths          : TMonthsArray;
    //masWeekDays        : array[1..ciWeekDayCount] of String;
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
    //miNoTimeDateLeft   : Integer;
    msThemeName        : String;

    //mblTransparentFlag : Boolean;
    //miTransparentValue : Integer;
  public
    { public declarations }

    //procedure FormatDate;
    function  readConfig() : Boolean;
    function  writeConfig() : Boolean;
    procedure setConfig();
    procedure getConfig();
    function  readLocale() : Boolean;
    function  readTheme() : Boolean;
    function  writeTheme() : Boolean;
    procedure applyTheme();
    procedure askSystemDateAndTime();
    procedure displayDate();
    procedure displayTime();
    procedure getDateAndTimeDefaultPosition();
    //procedure adjustDateAndTimePosition();
    //procedure  localeComponent(poComp : TLCLComponent; psDefault : String = '');
    //procedure  localeComponent(poComp : TControl; psDefault : String = '');
  end;

const
         ciAlLeft          = 1;
         ciAlRight         = 2;
         ciAlCenter        = 3;
         casMonthsArray : TMonthsArray = ('января', 'февраля', 'марта',
                                          'апреля', 'мая', 'июня',
                                          'июля', 'августа', 'сентября',
                                          'октября', 'ноября', 'декабря');
var
  fmMain: TfmMain;

implementation

{$R *.lfm}


function alignFill(psLine : String; piWidth : Integer; piAlign : Integer = ciAlLeft; pcFill : Char = ' ') : String;
var lsLine  : String;
    liWdt,
    liLen,
    liHalf  : Integer;
begin

  lsLine:=Trim(psLine);
  liLen:=Length(lsLine);
  if liLen>0 then begin

    if liLen<piWidth then begin

      liWdt:=piWidth-liLen;
      if piAlign=ciAlCenter then begin

        liHalf:=liWdt div 2;
        lsLine:=StringOfChar(pcFill,liHalf)+lsLine+StringOfChar(pcFill,liWdt-liHalf);
      end else begin

        if piAlign=ciAlLeft then begin

          lsLine:=lsLine+StringOfChar(pcFill,liWdt);
        end else begin

          if piAlign=ciAlRight then begin

            lsLine:=StringOfChar(pcFill,liWdt)+lsLine;
          end;
        end
      end;
    end;
  end else begin

    lsLine:=StringOfChar(#32,piWidth);
  end;
  Result:=lsLine;
end;


function alignRight(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlRight,pcFill);
end;


function alignLeft(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlLeft,pcFill);
end;


function alignCenter(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlCenter,pcFill);
end;


procedure TfmMain.FormActivate(Sender: TObject);
begin

  OnActivate:=Nil;
  // ToDo: Обработка ошибок!
  Hide;
  // ### getDateAndTimeDefaultPosition;
  readConfig;
  setConfig;
  // readLocale; // пока закомментим
  readTheme;
  applyTheme;
  askSystemDateAndTime;
  displayTime;
  displayDate;
  Show;
end;


procedure TfmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  writeConfig;
end;

procedure TfmMain.FormCreate(Sender : TObject);
begin

  masMonths := casMonthsArray;
end;


procedure TfmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  {ifdef __WINDOWS__}
  if Sender is TLabel then
  begin

    mlFormerX:=X;
    mlFormerY:=Y+24;
  end else
  begin

    mlFormerX:=X;
    mlFormerY:=Y;
  end;
  Cursor := crSizeAll;
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
  if MouseCapture then
  begin

    fmMain.Left:=Mouse.CursorPos.X-mlFormerX;
    fmMain.Top:=Mouse.CursorPos.Y-mlFormerY;
    if mblStickyFlag then
    begin

      if fmMain.Left<=miStickyMargin then
      begin

        fmMain.Left:=0;
      end;
      if fmMain.Left>=Screen.DesktopWidth-(fmMain.Width+miStickyMargin) then
      begin

        fmMain.Left:=Pred(Screen.DesktopWidth-fmMain.Width);
      end;
      if fmMain.Top<=miStickyMargin then
      begin

        fmMain.Top:=0;
      end;
      if fmMain.Top>=Screen.DesktopHeight-(fmMain.Height+miStickyMargin) then
      begin

        fmMain.Top:=Pred(Screen.DesktopHeight-fmMain.Height);
      end;
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
  getConfig();
  writeConfig();
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
  begin

    fmMain.Hide
  end else
  begin

    fmMain.Show;
  end;
end;


procedure TfmMain.ClockTimerTimer(Sender: TObject);
// var // ldtNow     : TDateTime;
    // lsTrayHint : String;
begin

  //***** Минуту еще не натикало?
  if mwClockSeconds<ciMaxSecond then
  begin

    inc(mwClockSeconds);
    DisplayTime;
    fmMain.Update;
  end else
  begin

    //***** Уже натикало
    mwClockSeconds:=0;
    //***** Час еще не натикало?
    if mwClockMinutes<ciMaxMinute then
    begin

      //inc(mwClockMinutes)
      AskSystemDateAndTime;
      DisplayTime;
      DisplayDate;

    end else
    begin

      //***** Уже натикало
      mwClockMinutes:=0;

      //***** Сутки не натикали еще?
      if mwClockHours<ciMaxHour then
      begin

        inc(mwClockHours);
      end else
      begin

        //***** Уже натикали
        mwClockHours:=0;
      end;
    end;
  end;
end;


function TfmMain.readConfig() : Boolean;
var loIniMgr      : TEasyIniManager;
begin

  Result:=False;
  //***** Общие параметры
  loIniMgr := TEasyIniManager.Create(getAPPFolder()+csEtcFolder+csIniFileName);

  msLocaleFolder:=loIniMgr.read(csMainSection,'locale',csLocaleFolder+'en_US');
  addSeparator(msLocaleFolder);
  msThemeFolder:=loIniMgr.read(csMainSection,'theme',csThemeFolder+'main');
  addSeparator(msThemeFolder);

  //***** Прилипание к краям экрана
  mblStickyFlag:=loIniMgr.read(csConfigSection,csStickyFlag, False);
  miStickyMargin:=loIniMgr.read(csConfigSection,csStickyMargin, 0);

  //***** Прозрачность
  Self.AlphaBlend:=loIniMgr.read(csConfigSection,csTransparentFlag, False);
  Self.AlphaBlendValue:=loIniMgr.read(csConfigSection,csTransparentValue, 255);

  //***** Кнопка минимизации
  sbMinimize.Visible:=loIniMgr.read(csConfigSection,csMinimizeBtnVisible, True);

  //***** Кнопка закрытия
  sbClose.Visible:=loIniMgr.read(csConfigSection,csCloseBtnVisible, True);

  //***** Показывать время
  lbTime.Visible:=loIniMgr.read(csConfigSection,csVisibleTimeFlag, True);

  //***** Показывать дату
  lbDate.Visible:=loIniMgr.read(csConfigSection,csVisibleDateFlag, True);

  //***** Шрифт времени
  // !!! loIniMgr.read(csConfigSection,csTimeFontValue,lbTime.Font); // Шрифт по умолчанию!

  //***** Шрифт даты
  // !!! loIniMgr.read(csConfigSection,csDateFontValue,lbDate.Font);

  //***** Цвет времени
  lbTime.Font.Color:=loIniMgr.read(csConfigSection,csTimeColorValue,ciDefaultTimeColor);

  //***** Цвет даты
  lbDate.Font.Color:=loIniMgr.read(csConfigSection,csDateColorValue,ciDefaultDateColor);

  //***** Выбранная тема
  msThemeName:=loIniMgr.read(csConfigSection,csThemeNameValue,csDefaultThemeName);

  //***** Скорректируем позиции даты и времени
  //adjustDateAndTimePosition;

  FreeAndNil(loIniMgr);
  Result:=True;
  //***** Параметры окон
  loIniMgr := TEasyIniManager.Create(getAPPFolder()+csEtcFolder+csWinIniFileName);
  loIniMgr.LoadForm(fmMain);
  loIniMgr.LoadForm(fmConfig);
  FreeAndNil(loIniMgr);
end;


function TfmMain.writeConfig() : Boolean;
var // liIdx : Integer;
    loIniMgr      : TEasyIniManager;
begin

  Result:=False;
  //***** Общие параметры
  loIniMgr := TEasyIniManager.Create(getAPPFolder()+csEtcFolder+csWinIniFileName);

  //***** Прилипание к краям экрана
  loIniMgr.write(csConfigSection,csStickyFlag,mblStickyFlag);
  loIniMgr.write(csConfigSection,csStickyMargin,miStickyMargin);

  //***** Прозрачность
  loIniMgr.write(csConfigSection,csTransparentFlag,AlphaBlend);
  loIniMgr.write(csConfigSection,csTransparentValue,AlphaBlendValue);

  //***** Кнопка минимизации
  loIniMgr.write(csConfigSection,csMinimizeBtnVisible,sbMinimize.Visible);

  //***** Кнопка закрытия
  loIniMgr.write(csConfigSection,csCloseBtnVisible,sbClose.Visible);

  //***** Показывать время
  loIniMgr.write(csConfigSection,csVisibleTimeFlag,lbTime.Visible);

  //***** Показывать дату
  loIniMgr.write(csConfigSection,csVisibleDateFlag,lbDate.Visible);

  //***** Шрифт времени
  // !!! loIniMgr.write(csConfigSection,csTimeFontValue,lbTime.Font);

  //***** Шрифт даты
  // !!! loIniMgr.write(csConfigSection,csDateFontValue,lbDate.Font);

  //***** Цвет времени
  loIniMgr.write(csConfigSection,csTimeColorValue,lbTime.Font.Color);

  //***** Цвет даты
  loIniMgr.write(csConfigSection,csDateColorValue,lbDate.Font.Color);

  //***** Выбранная тема
  loIniMgr.write(csConfigSection,csThemeNameValue,msThemeName);

  FreeAndNil(loIniMgr);

  //***** Параметры окон
  loIniMgr := TEasyIniManager.Create(getAPPFolder()+csEtcFolder+csWinIniFileName);
  loIniMgr.SaveForm(fmMain);
  loIniMgr.SaveForm(fmConfig);
  FreeAndNil(loIniMgr);
end;


procedure TfmMain.setConfig();
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

  //***** Шрифт времени
  fmConfig.dlgTimeFont.Font.Assign(lbTime.Font);

  //***** Шрифт даты
  fmConfig.dlgDateFont.Font.Assign(lbDate.Font);

  //***** Цвет времени
  fmConfig.dlgTimeColor.Color:=lbTime.Font.Color;

  //***** Цвет даты
  fmConfig.dlgDateColor.Color:=lbDate.Font.Color;
end;


procedure TfmMain.getConfig();
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

  //***** Шрифт времени
  lbTime.Font.Assign(fmConfig.dlgTimeFont.Font);

  //***** Шрифт даты
  lbDate.Font.Assign(fmConfig.dlgDateFont.Font);

  //***** Цвет времени
  lbTime.Font.Color:=fmConfig.dlgTimeColor.Color;

  //***** Цвет даты
  lbDate.Font.Color:=fmConfig.dlgDateColor.Color;

  //***** Скорректируем позиции даты и времени
  //adjustDateAndTimePosition;
end;


function TfmMain.readLocale() : Boolean;
//var liIdx : Integer;
begin
  Result:=False;
  (*
  if IniOpen(getAPPFolder()+csLocaleFolder+msLocaleFolder+csMainLocaleFilename) then begin

    //***** Названия месяцев
    for liIdx:=1 to ciMonthCount do begin
      masMonths[liIdx]:=IniReadString('months','month'+IntToStr(liIdx));
    end;

    //***** Названия дней недели
    for liIdx:=1 to ciWeekDayCount do begin
      masWeekDays[liIdx]:=IniReadString('weekdays','weekday'+IntToStr(liIdx));
    end;

    IniClose;

    if IniOpen(getAPPFolder()+csLocaleFolder+msLocaleFolder+csFormsLocaleFilename) then begin
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
*)
end;


function  TfmMain.readTheme() : Boolean;
begin
  Result:=False;
  (*
  if IniOpen(g_sProgrammFolder+csThemeFolder+msThemeFolder+msThemeName) then begin

    //***** Глифы микрокнопок
    msMicroBtnPath:=IniReadString(csMicroSection,'path',csDefaultMicroFolder);
    addSeparator(msMicroBtnPath);
    msMicroCloseGlyph:=IniReadString(csMicroSection,'close','red.png');
    msMicroMinimizeGlyph:=IniReadString(csMicroSection,'minimize','blue.png');

    //***** Глифы обычных кнопок
    msButtonPath:=IniReadString(csButtonsSection,'path',csDefaultMicroFolder);
    addSeparator(msButtonPath);
    msButtonOkGlyph:=IniReadString(csButtonsSection,'ok','dialog-ok-apply.png');
    msButtonCancelGlyph:=IniReadString(csButtonsSection,'cancel','dialog-cancel.png');
    IniClose;
    Result:=FileExists(g_sProgrammFolder+msMicroBtnPath+msMicroCloseGlyph) and
            FileExists(g_sProgrammFolder+msMicroBtnPath+msMicroCloseGlyph) and
            FileExists(g_sProgrammFolder+msButtonPath+msButtonOkGlyph) and
            FileExists(g_sProgrammFolder+msButtonPath+msButtonOkGlyph);
  end;
  *)
end;


function  TfmMain.writeTheme() : Boolean;
//var lsMicroPath,
    //lsButtonPath : String;
begin

  Result:=False;
  (*
  if IniOpen(g_sProgrammFolder+csThemeFolder+msThemeFolder+msThemeName) then begin

    //***** Глифы микрокнопок
    IniWriteString(csMicroSection,'close',msMicroCloseGlyph);
    IniWriteString(csMicroSection,'minimize',msMicroMinimizeGlyph);

    //***** Глифы обычных кнопок
    IniWriteString(csButtonsSection,'ok',msButtonOkGlyph);
    IniWriteString(csButtonsSection,'cancel',msButtonCancelGlyph);
    IniClose;

    Result:=True;
  end;
  *)
end;


procedure TfmMain.applyTheme();
begin

  if sbClose.Glyph.IsFileExtensionSupported(ExtractFileExt(msMicroCloseGlyph)) then
  begin

    sbClose.Glyph.LoadFromFile(getAPPFolder()+msMicroBtnPath+msMicroCloseGlyph);
  end;

  if sbMinimize.Glyph.IsFileExtensionSupported(ExtractFileExt(msMicroMinimizeGlyph)) then
  begin

    sbMinimize.Glyph.LoadFromFile(getAPPFolder()+msMicroBtnPath+msMicroMinimizeGlyph);
  end;
end;


procedure TfmMain.getDateAndTimeDefaultPosition();
begin

  miNormalDateLeft:=lbDate.Left;
  miNormalTimeWidth:=lbTime.Width;
end;

(*
procedure TfmMain.adjustDateAndTimePosition();
begin

  if lbTime.Visible then
  begin

    lbTime.Width:=miNormalTimeWidth;
    lbDate.Left:=miNormalDateLeft;
  end else
  begin

    lbTime.Width:=1;
    lbDate.Left:=ciNoTimeDateLeft;
  end;
end;
*)

procedure TfmMain.askSystemDateAndTime();
var ldtNow : TDateTime;
begin

  ldtNow:=Now;
  DecodeTime(ldtNow,mwClockHours,mwClockMinutes,mwClockSeconds,mwClockMSeconds);
  DecodeDate(ldtNow,mwClockYear,mwClockMonth,mwClockDay);
  mwClockWeekDay:=DayOfTheWeek(ldtNow);
end;


procedure TfmMain.displayDate();
begin

  msClockDateHint:=AlignRight(IntToStr(mwClockDay),2,'0')+' '+
                  masMonths[mwClockMonth]+' '+
                  IntToStr(mwClockYear);
  lbDate.Caption:=msClockDateHint;
end;


procedure TfmMain.displayTime();
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

