unit RSign.Core.Constants;

interface

const
  _APP_NAME       = 'RSign';
  _APP_VERSION    = '0.1.0';

  _INI_FILE_NAME  = 'RSign.ini';
  _LOG_FILE_NAME  = 'RSign.log';


  _DEFAULT_CERTIFICATE_NAME                     = 'RSignAutoCert';
  _DEFAULT_CERTIFICATE_PASSWORD                 = '123456';
  _DEFAULT_CERTIFICATE_FOLDER                   = 'Certificados';
  _DEFAULT_CERTIFICATE_EXPIRATION_WARNING_DAYS  = 30;

  _DEFAULT_TIMESTAMP_URL        = 'http://timestamp.digicert.com';
  _DEFAULT_INPUT_FOLDER         = 'Entrada';
  _DEFAULT_OUTPUT_FOLDER        = 'Saida';
  _DEFAULT_LOG_FOLDER           = 'Logs';

  _INI_SECTION_CERTIFICATE_PROFILE  = 'CertificateProfile';
  _INI_SECTION_SIGNING_SETTINGS     = 'SigningSettings';
  _INI_SECTION_PATHS                = 'Paths';
  _INI_SECTION_LOG                  = 'Log';
  _INI_SECTION_UI                   = 'UI';

  _SUPPORTED_EXTENSIONS = '.exe;.dll;.msi;.cab;.cat';

  _DEFAULT_CUSTOM_COMBOBOX_COLOR_BACKGROUND     = $FFD2D8CE;
  _DEFAULT_CUSTOM_COMBOBOX_COLOR_BORDER         = $FF7A8570;
  _DEFAULT_CUSTOM_COMBOBOX_COLOR_FONT           = $FF6D7868;

  _PROCESSOR_ARCHITECTURE_ARM64 = 12;

  //UI Loading
  _LOADING_OVERLAY_BACKGROUND     = $C8101510;
  _LOADING_CARD_BACKGROUND        = $FF141A12;
  _LOADING_CARD_BORDER            = $FF3D4D30;
  _LOADING_CARD_WIDTH             = 240;
  _LOADING_CARD_HEIGHT            = 140;
  _LOADING_BRAND_NAME_COLOR       = $FFC8D4AE;
  _LOADING_STATUS_LABEL_COLOR     = $FF65734F;
  _LOADING_MESSAGE_TEXT_COLOR     = $FF9AAA80;
  _LOADING_DOT_COLOR              = $FF65734F;
  _LOADING_DOT_SIZE               = 8.0;
  _LOADING_DOT_SPACING            = 5.0;
  _LOADING_STATUS                 = 'AGUARDE';

implementation

end.
