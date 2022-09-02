*&---------------------------------------------------------------------*
*& Include          ZC1R250005_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_bom_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bom_data .

  CLEAR gs_data.
  _clear gt_data.

  SELECT a~matnr a~stlan a~stlal a~stlnr
         b~mtart b~matkl
*         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM mast AS a
   INNER JOIN mara AS b
      ON a~matnr = b~matnr
*    LEFT OUTER JOIN makt AS c
*      ON a~matnr = c~matnr
*     AND c~spras = sy-langu
   WHERE a~werks = pa_werks
     AND a~matnr IN so_matnr.

  IF sy-subrc <> 0.
    MESSAGE i001.
    LEAVE LIST-PROCESSING.
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
    'X' 'MATNR' ' ' 'MAST' 'MATNR',
    ' ' 'MAKTX' ' ' 'MAKT' 'MAKTX',
    ' ' 'STLAN' ' ' 'MAST' 'STLAN',
    ' ' 'STLNR' ' ' 'MAST' 'STLNR',
    ' ' 'STLAL' ' ' 'MAST' 'STLAL',
    ' ' 'MTART' ' ' 'MARA' 'MTART',
    ' ' 'MATKL' ' ' 'MARA' 'MATKL'.
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
FORM set_fcat  USING pv_key pv_name pv_text pv_table pv_field.

  gs_fcat = VALUE #(
                      key       = pv_key
                      fieldname = pv_name
                      coltext   = pv_text
                      ref_table = pv_table
                      ref_field = pv_field
                    ).
  CASE pv_field.
    WHEN 'STLNR'.
      gs_fcat-hotspot = 'X'.
  ENDCASE.


*  gs_fcat-key       = pv_key.
*  gs_fcat-fieldname = pv_name.
*  gs_fcat-coltext   = pv_text.
*  gs_fcat-ref_table = pv_table.
*  gs_fcat-ref_field = pv_field.
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

  IF gcl_container IS NOT BOUND.
    CREATE OBJECT gcl_container
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = gcl_container->dock_at_left   "cl_gui_docking_container=>dock_at_left
        extension = 3000.

    CREATE OBJECT gcl_grid
      EXPORTING
        i_parent = gcl_container.

    gs_variant-report = sy-repid.

    "Local Instance Methods Setting
    IF gcl_handler IS NOT BOUND.
      CREATE OBJECT gcl_handler.
    ENDIF.

    SET HANDLER : gcl_handler->handle_double_click FOR gcl_grid,
                  gcl_handler->handle_hotspot      FOR gcl_grid.
    "Call Display Method
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
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM handle_double_click  USING ps_row    TYPE lvc_s_row
                                ps_column TYPE lvc_s_col.
  READ TABLE gt_data INTO gs_data INDEX ps_row-index.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  CASE ps_column-fieldname.
    WHEN 'MATNR'.
      IF gs_data-matnr IS INITIAL.
        EXIT.
      ENDIF.

      SET PARAMETER ID : 'MAT' FIELD gs_data-matnr.

      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot  USING ps_row_id    TYPE lvc_s_row
                           ps_column_id TYPE lvc_s_col.

  READ TABLE gt_data INTO gs_data INDEX ps_row_id-index.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CASE ps_column_id-fieldname.
    WHEN 'STLNR'.
      IF gs_data-stlnr IS INITIAL.
        EXIT.
      ENDIF.

      SET PARAMETER ID : 'MAT' FIELD gs_data-matnr,
                         'WRK' FIELD pa_werks,
                         'CSV' FIELD gs_data-stlan.

      CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_makts
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_makts .

  DATA: lv_tabix    TYPE sy-tabix,
        lv_code,
        lv_msg(100),
        lv_maktx    TYPE makt-maktx.

  IF gcl_maktx IS NOT BOUND.
    CREATE OBJECT gcl_maktx.
  ENDIF.

  LOOP AT gt_data INTO gs_data.
    lv_tabix = sy-tabix.

    CLEAR lv_maktx.
    CALL METHOD gcl_maktx->get_meterial_text
      EXPORTING
        pi_matnr = gs_data-matnr
      IMPORTING
        pe_code  = lv_code
        pe_msg   = lv_msg
        pe_maktx = lv_maktx. "gs_data-maktx

    IF lv_code = 'S'.
      gs_data-maktx = lv_maktx.

      MODIFY gt_data FROM gs_data INDEX lv_tabix
      TRANSPORTING maktx.
    ENDIF.
  ENDLOOP.

ENDFORM.
