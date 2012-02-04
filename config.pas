unit config;

{$MODE Delphi}

{$i profile.inc}
interface


uses
  {$ifdef __WINDOWS__}
  Windows, MMSystem,ActiveX,ShlObj,ComObj,
  {$endif}

  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, Buttons, ExtCtrls, IniFiles,


  {$ifdef __WINDOWS__}
  twin,
  {$endif}

  tlib,tstr,tcfg

   {Shedules};


const c_sSystemSectn     = 'SYSTEM';
      c_sTimerSectn      = 'TIMER';
      csIniFile         = 'tinyclock.ini';
      //c_sXMLFile         = 'tinyclock.xml';
      c_sVersion         = '1.4';
      c_sFontDelim       = ';';
      c_sDefaultFont     = 'Arial;204;-13;D;10;3';
      c_iBaseYear        = 2000;


type

  { TfmConfig }

  TfmConfig = class(TForm)
    bbtAutoStart: TBitBtn;
    bbtOk: TBitBtn;
    bbtCancel: TBitBtn;
    edStickyMargin: TEdit;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    tsTheme: TTabSheet;
    tpcSetup: TPageControl;
    tbsCommon: TTabSheet;
    GroupBox4: TGroupBox;
    chbOnTop: TCheckBox;
    tbsClock: TTabSheet;
    grbClockConfig: TGroupBox;
    chbSignal: TCheckBox;
    bbtClockColor: TBitBtn;
    bbtSelectWave: TBitBtn;
    chbShowClock: TCheckBox;
    bbtApply: TBitBtn;
    ilBkgList: TImageList;
    OpenDialog: TOpenDialog;
    dlgColor: TColorDialog;
    tbsAbout: TTabSheet;
    bbtTestClockSnd: TBitBtn;
    bbtClockFont: TBitBtn;
    dlgFontSelect: TFontDialog;
    tbsLicense: TTabSheet;
    meLicense: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblSite: TLabel;
    lblEmail: TLabel;
    chbShowDate: TCheckBox;
    grbDateConfig: TGroupBox;
    bbtDateColor: TBitBtn;
    bbtDateFont: TBitBtn;
    grbTimerConfig: TGroupBox;
    bbtTimerSignal: TBitBtn;
    bbtTestTimerSnd: TBitBtn;
    chbUseTimer: TCheckBox;
    chbCloseBtn: TCheckBox;
    chbTimerBtn: TCheckBox;
    chbMinBtn: TCheckBox;
    chbTransparent: TCheckBox;
    trbAlpha: TTrackBar;
    chbStickyFlag: TCheckBox;
    udMargin: TUpDown;
    procedure bbtAutoStartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    {
    function GetConfig : Boolean;
    function PutConfig : Boolean;
    function FindFileInList(p_sFileName : String) : Integer;}
    //function ReadConfigFromXml : Boolean;
    //function WriteConfigToXml : Boolean;
    //                               function AutoStart : Boolean;
  end;


const        c_eCtlAlt         : TShiftState = [ssCtrl,ssAlt];


var
  fmConfig: TfmConfig;
//  g_rConfig : TConfig;
  {
function SerializeFont(p_oFont : TFont) : String;
function DeSerializeFont(p_oFont : TFont;p_sLine : String) : Boolean;
function DefaultConfig : Boolean;
function ApplyConfig : Boolean;
function ShowCloseButton(p_blShow : Boolean) : Boolean;
function WriteConfigToXml : Boolean;
function ReadConfigFromXml : Boolean;

   }
implementation


uses Main, Math,{timer,}Calendar{, list};

{ TfmConfig }

procedure TfmConfig.bbtAutoStartClick(Sender: TObject);
var lsAutoRunFolder : String;
begin

  {$ifdef __WINDOWS__}
  lsAutoRunFolder:=GetSystemFolder(CSIDL_STARTUP);
  if not CreateLink(ParamStr(0),
                    ExtractFilePath(ParamStr(0)),
                    csProgramName+' '+csVersion,
                    ParamStr(0),0,
                    lsAutoRunFolder+'lclock.lnk') then begin
    FatalError('Ошибка!',
              ' Программу не удалось поместить в Автозапуск');

  end;
  {$endif}
end;


procedure TfmConfig.FormActivate(Sender: TObject);
begin
  {$ifdef __WINDOWS__}
  bbtAutoStart.Enabled:=True;
  {$endif}
end;


{$R *.lfm}



end.