*&---------------------------------------------------------------------*
*& Include          YCL100_001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  REFRESH GT_SCARR. " Internal Table 초기화

  SELECT *
    FROM SCARR
   WHERE CARRID   IN @S_CARRID
     AND CARRNAME IN @S_CARRNM
    INTO TABLE @GT_SCARR.

  SORT GT_SCARR BY CARRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0100
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0100 .

  CREATE OBJECT GR_CON
    EXPORTING
      REPID                       = SY-REPID         " Report to Which This Docking Control is Linked
      DYNNR                       = SY-DYNNR         " Screen to Which This Docking Control is Linked
      EXTENSION                   = 5000             " Control Extension
    EXCEPTIONS
      CNTL_ERROR                  = 1                " Invalid Parent Control
      CNTL_SYSTEM_ERROR           = 2                " System Error
      CREATE_ERROR                = 3                " Create Error
      LIFETIME_ERROR              = 4                " Lifetime Error
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  CREATE OBJECT GR_SPLIT
    EXPORTING
      PARENT                  = GR_CON             " Parent Container
      ROWS                    = 2                  " Number of Rows to be displayed
      COLUMNS                 = 1                  " Number of Columns to be Displayed
    EXCEPTIONS
      CNTL_ERROR              = 1                  " See Superclass
      CNTL_SYSTEM_ERROR       = 2                  " See Superclass
      OTHERS                  = 3.

*  CALL METHOD GR_SPLIT->GET_CONTAINER
*    EXPORTING
*      ROW       = 1                " Row
*      COLUMN    = 1                " Column
*    RECEIVING
*      CONTAINER = GR_CON_TOP             " Container
*    .

*  GR_SPLIT->GET_CONTAINER(
*    EXPORTING
*      ROW       = 1                " Row
*      COLUMN    = 1                " Column
*    RECEIVING
*      CONTAINER = GR_CON_TOP                 " Container
*  ).

  GR_SPLIT->SET_ROW_HEIGHT(
    EXPORTING
      ID                = 1                " Row ID
      HEIGHT            = 10               " Height
    EXCEPTIONS
      CNTL_ERROR        = 1                " See CL_GUI_CONTROL
      CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
      OTHERS            = 3
  ).

  GR_CON_TOP = GR_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GR_CON_ALV = GR_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  CREATE OBJECT GR_ALV
    EXPORTING
      I_PARENT          = GR_CON_ALV " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1 " Error when creating the control
      ERROR_CNTL_INIT   = 2 " Error While Initializing Control
      ERROR_CNTL_LINK   = 3 " Error While Linking Control
      ERROR_DP_CREATE   = 4 " Error While Creating DataProvider Control
      OTHERS            = 5.

*  GR_ALV = NEW CL_GUI_ALV_GRID( I_PARENT = GR_CON_ALV ).
*  GR_ALV = NEW #( I_PARENT = GR_CON_ALV ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_LAYOUT_0100
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0100 .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA      = ABAP_ON.
  GS_LAYOUT-SEL_MODE   = 'D'. " A: 행열, B:단일행, C:복수행, D:셀단위
  GS_LAYOUT-CWIDTH_OPT = ABAP_ON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  DATA LT_FIELDCAT TYPE KKBLO_T_FIELDCAT.

  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'    "'K_KKB_FIELDCAT_MERGE'
    EXPORTING
      I_CALLBACK_PROGRAM     = SY-REPID " Internal table declaration program
*      I_TABNAME              = ''                 " Name of table to be displayed
      I_STRUCNAME            = 'SCARR'
      I_INCLNAME             = SY-REPID
      I_BYPASSING_BUFFER     = ABAP_ON  " Ignore buffer while reading
      I_BUFFER_ACTIVE        = ABAP_OFF
    CHANGING
      CT_FIELDCAT            = LT_FIELDCAT " Field Catalog with Field Descriptions
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      OTHERS                 = 2.

  IF LT_FIELDCAT[] IS INITIAL.
    MESSAGE '필드 카탈로그 구성 중 오류가 발생했습니다.' TYPE 'E'.
  ELSE.
    CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
      EXPORTING
        IT_FIELDCAT_KKBLO         = LT_FIELDCAT
      IMPORTING
        ET_FIELDCAT_LVC           = GT_FIELDCAT
      EXCEPTIONS
        IT_DATA_MISSING           = 1
        OTHERS                    = 2
      .
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100 .

  CALL METHOD GR_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT     " Layout
    CHANGING
      IT_OUTTAB                     = GT_SCARR[]    " Output Table
      IT_FIELDCATALOG               = GT_FIELDCAT[] " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1 " Wrong Parameter
      PROGRAM_ERROR                 = 2 " Program Errors
      TOO_MANY_LINES                = 3 " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.

ENDFORM.
