*&---------------------------------------------------------------------*
*& Include          ZC1R250009_F01
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

  pa_bukrs = '1010'.
  pa_gjahr = '2021'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_belnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_belnr .

  _clear gs_data gt_data.

  SELECT a~blart a~budat a~waers
         b~belnr b~buzei b~shkzg b~dmbtr b~hkont
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM bkpf AS a
   INNER JOIN bseg AS b
      ON a~bukrs = b~bukrs
     AND a~belnr = b~belnr
     AND a~gjahr = b~gjahr
   WHERE a~bukrs = pa_bukrs
     AND a~gjahr = pa_gjahr
     AND a~belnr IN so_belnr
     AND a~blart IN so_blart.

  IF sy-subrc NE 0.
    MESSAGE s001.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_fcat .

  CLEAR gs_layout.

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-sel_mode   = 'D'.

  IF gt_fcat IS INITIAL.
    PERFORM set_fcat USING :
    'X'  'BELNR'  ' '  'BSEG'  'BELNR',    "key로 지정하면 틀고정 됨
    'X'  'BUZEI'  ' '  'BSEG'  'BUZEI',
    ' '  'BLART'  ' '  'BKPF'  'BLART',
    ' '  'BUDAT'  ' '  'BKPF'  'BUDAT',
    ' '  'SHKZG'  ' '  'BSEG'  'SHKZG',
    ' '  'DMBTR'  ' '  'BSEG'  'DMBTR',
    ' '  'WAERS'  ' '  'BKPF'  'WAERS',
    ' '  'HKONT'  ' '  'BSEG'  'HKONT'.
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
FORM set_fcat  USING pv_key pv_fname pv_text pv_ref_t pv_ref_f.

  gs_fcat = VALUE #( key       = pv_key
                     fieldname = pv_fname
                     coltext   = pv_text
                     ref_table = pv_ref_t
                     ref_field = pv_ref_f ).

  CASE pv_fname.
    WHEN 'DMBTR'.
      gs_fcat-cfieldname = 'WAERS'.

    WHEN 'BELNR'.
      gs_fcat-hotspot = 'X'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form diplay_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM diplay_screen .

  IF gcl_container IS NOT BOUND.

    CREATE OBJECT gcl_container
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = gcl_container->dock_at_left
        extension = 3000.

    CREATE OBJECT gcl_grid
      EXPORTING
        i_parent = gcl_container.

    gs_variant-report = sy-repid.

    "Instance Method 연결
    "스크린이 여러개면 어디에서 생성될지 모르기 때문에 핸들러가 바운드 되었는지 확인해줘야 함
    IF gcl_handler IS NOT BOUND.
      CREATE OBJECT gcl_handler.
    ENDIF.

    SET HANDLER : gcl_handler->handle_hotspot FOR gcl_grid.

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
*&---------------------------------------------------------------------*
*& Form handle_hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN_ID
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot  USING ps_col_id TYPE lvc_s_col
                           ps_row_id TYPE lvc_s_row.

  READ TABLE gt_data INTO gs_data INDEX ps_row_id-index.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CASE ps_col_id-fieldname.
    WHEN 'BELNR'.
      IF gs_data-belnr IS INITIAL.
        EXIT.
      ENDIF.

      SET PARAMETER ID : 'BLN' FIELD gs_data-belnr,
                         'BUK' FIELD pa_bukrs,
                         'GJR' FIELD pa_gjahr.

      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.
