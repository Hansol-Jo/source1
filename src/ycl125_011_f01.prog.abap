*&---------------------------------------------------------------------*
*& Include          YCL121_002_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0100
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0100 .

  CREATE OBJECT GR_CON
    EXPORTING
      CONTAINER_NAME              = 'MY_CON'     " Name of the Screen CustCtrl Name to Link Container
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  CREATE OBJECT GR_ALV
    EXPORTING
      I_PARENT                = GR_CON           " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE       = 1                " Error when creating the control
      ERROR_CNTL_INIT         = 2                " Error While Initializing Control
      ERROR_CNTL_LINK         = 3                " Error While Linking Control
      ERROR_DP_CREATE         = 4                " Error While Creating DataProvider Control
      OTHERS                  = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  REFRESH GT_SCARR.

  RANGES LR_CARRID   FOR SCARR-CARRID.
  RANGES LR_CARRNAME FOR SCARR-CARRNAME.


  IF SCARR-CARRID IS INITIAL AND
     SCARR-CARRNAME IS INITIAL.
    " ID 와 이름이 둘다 공란인 경우

  ELSEIF SCARR-CARRID IS INITIAL.
    " 이름은 공란이 아닌 경우
    LR_CARRNAME-SIGN = 'I'.
    LR_CARRNAME-OPTION = 'EQ'.      " eq = 같음
    LR_CARRNAME-LOW = SCARR-CARRNAME.
    APPEND LR_CARRNAME.
    CLEAR  LR_CARRNAME.
  ELSEIF SCARR-CARRNAME IS INITIAL.
    " ID 가 공란이 아닌 경우
    LR_CARRID-SIGN = 'I'.     " I / E : Include / Exclude : 포함 / 제외
    LR_CARRID-OPTION = 'EQ'.
    LR_CARRID-LOW = SCARR-CARRID.
    APPEND LR_CARRID.
    CLEAR  LR_CARRID.
  ELSE.
    " ID와 이름이 둘다 공란이 아닌 경우
    " 이름은 공란이 아닌 경우
    LR_CARRNAME-SIGN = 'I'.
    LR_CARRNAME-OPTION = 'EQ'.      " eq = 같음
    LR_CARRNAME-LOW = SCARR-CARRNAME.
    APPEND LR_CARRNAME.
    CLEAR  LR_CARRNAME.

    " ID 가 공란이 아닌 경우
    LR_CARRID-SIGN = 'I'.     " I / E : Include / Exclude : 포함 / 제외
    LR_CARRID-OPTION = 'EQ'.
    LR_CARRID-LOW = SCARR-CARRID.
    APPEND LR_CARRID.
    CLEAR  LR_CARRID.
  ENDIF.

  SELECT *
    FROM SCARR
   WHERE CARRID   IN @LR_CARRID
     AND CARRNAME IN @LR_CARRNAME
    INTO TABLE @GT_SCARR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_LAYOUT_0100
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0100 .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA = ABAP_ON.
  GS_LAYOUT-SEL_MODE = 'D'.
  GS_LAYOUT-CWIDTH_OPT = ABAP_ON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  DATA LT_FIELDCAT TYPE KKBLO_T_FIELDCAT.

  REFRESH GT_FCAT.

  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'
    EXPORTING
      I_CALLBACK_PROGRAM     = SY-REPID     " Internal table declaration program
*      I_TABNAME              =             " Name of table to be displayed
      I_STRUCNAME            = 'SCARR'
      I_INCLNAME             = SY-REPID
      I_BYPASSING_BUFFER     = ABAP_ON      " Ignore buffer while reading
      I_BUFFER_ACTIVE        = ABAP_OFF
    CHANGING
      CT_FIELDCAT            = LT_FIELDCAT  " Field Catalog with Field Descriptions
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      OTHERS                 = 2.

  IF LT_FIELDCAT[] IS INITIAL.
    MESSAGE 'ALV 필드 카탈로그 구성이 실패했습니다.' TYPE 'E'.
  ELSE.
    CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
      EXPORTING
        IT_FIELDCAT_KKBLO         = LT_FIELDCAT
      IMPORTING
        ET_FIELDCAT_LVC           = GT_FCAT
      EXCEPTIONS
        IT_DATA_MISSING           = 1
        OTHERS                    = 2.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100 .

  CALL METHOD GR_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT        " Layout
    CHANGING
      IT_OUTTAB                     = GT_SCARR[]       " Output Table
      IT_FIELDCATALOG               = GT_FCAT[]        " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

ENDFORM.
