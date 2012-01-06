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
  TfmSetup = class(TForm)
    bbtOk: TBitBtn;
    bbtCancel: TBitBtn;
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
    chbStick: TCheckBox;
    Label3: TLabel;
    edMargin: TEdit;
    udMargin: TUpDown;
    bbtAutoStart: TBitBtn;
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
  fmSetup: TfmSetup;
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


{$R *.lfm}



end.