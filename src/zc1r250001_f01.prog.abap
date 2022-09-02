*&---------------------------------------------------------------------*
*& Include          ZC1R250001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_param
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_param .

  pa_carr = 'KA'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  CLEAR   gs_data.
  REFRESH gt_data.

  SELECT carrid connid fldate price currency planetype
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM sflight
   WHERE carrid  = pa_carr
     AND connid IN so_conn.

  IF sy-subrc <> 0.
    MESSAGE i001(zmcsa25).
    LEAVE LIST-PROCESSING.   "STOP
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat_layout .

  gs_layout-zebra      = 'X'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-cwidth_opt = 'X'.

  IF gt_fcat IS INITIAL.
    PERFORM set_fcat USING :
  " PK, FIELDNAME, COLTEXT, REF_TABLE, REF_FIELD
    'X' 'CARRID'    ' ' 'SFLIGHT' 'CARRID',   "레퍼런스 필드를 넣어줘서 컬럼 텍스트를 안넣어도 나옴(다국어 지원 가능), 만약 칼럼 텍스트를 주면 이게 우선임
    'X' 'CONNID'    ' ' 'SFLIGHT' 'CONNID',
    'X' 'FLDATE'    ' ' 'SFLIGHT' 'FLDATE',
    ' ' 'PRICE'     ' ' 'SFLIGHT' 'PRICE',
    ' ' 'CURRENCY'  ' ' 'SFLIGHT' 'CURRENCY',
    ' ' 'PLANETYPE' ' ' 'SFLIGHT' 'PLANETYPE'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat  USING pv_key pv_field pv_text pv_ref_table pv_ref_field.
*--- 신문법
  gs_fcat = VALUE #( key       = pv_key
                     fieldname = pv_field
                     coltext   = pv_text
                     ref_table = pv_ref_table
                     ref_field = pv_ref_field ).

  CASE pv_field.
    WHEN 'PRICE'.
      gs_fcat-cfieldname = 'CURRENCY'.
  ENDCASE.

*--- 구문법
*  gs_fcat-key       = pv_key.
*  gs_fcat-fieldname = pv_field.
*  gs_fcat-coltext   = pv_text.
*  gs_fcat-ref_table = pv_ref_table.
*  gs_fcat-ref_field = pv_ref_field.
*
  APPEND gs_fcat TO gt_fcat.
*  CLEAR gs_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .

* = IF gcl_container is INITIAL.
  IF gcl_container IS NOT BOUND. "인스턴스 : 클래스를 참조하고 있는 변수 , create obj로 생성을 한다음에 사용해야 함 --> 오브젝트를 생성한 상태를 바운드 되었다고 함
    CREATE OBJECT gcl_container
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
*       side      = cl_gui_docking_container=>dock_at_left    "도킹 컨테이너에 있는 상수, 스테틱으로 되어있음
        side      = gcl_container->dock_at_left
        extension = 3000.

    CREATE OBJECT gcl_grid
      EXPORTING
        i_parent = gcl_container.

    gs_variant-report = sy-repid.

    CALL METHOD gcl_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_data
        it_fieldcatalog = gt_fcat.


  ENDIF.

ENDFORM.
