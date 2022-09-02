*&---------------------------------------------------------------------*
*& Include          ZC1R250006_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT a~matnr a~stlan a~stlnr a~stlal
         b~mtart b~matkl
         c~maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
    FROM mast AS a
   INNER JOIN mara AS b
      ON a~matnr = b~matnr
    LEFT OUTER JOIN makt AS c
      ON b~matnr = c~matnr
     AND c~spras = sy-langu
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
  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-sel_mode = 'D'.

  PERFORM set_fcat USING :
  "KEY FIELDNAME COLTEXT REF_TABLE REF_FIELD
  'X' 'MATNR' ' ' 'MAST' 'MATNR',
  ' ' 'MAKTX' ' ' 'MAKT' 'MAKTX',
  ' ' 'STLAN' ' ' 'MAST' 'STLAN',
  ' ' 'STLNR' ' ' 'MAST' 'STLNR',
  ' ' 'STLAL' ' ' 'MAST' 'STLAL',
  ' ' 'MTART' ' ' 'MARA' 'MTART',
  ' ' 'MATKL' ' ' 'MARA' 'MATKL'.
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

  CLEAR gs_fcat.
  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_name.
  gs_fcat-coltext = pv_text.
  gs_fcat-ref_table = pv_table.
  gs_fcat-ref_field = pv_field.

  CASE pv_field.
    WHEN 'STLNR'.
      gs_fcat-hotspot = 'X'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.

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
  IF gcl_container IS INITIAL.
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

    SET HANDLER lcl_handler=>on_double_click FOR gcl_grid.
    SET HANDLER lcl_handler=>on_hotspot      FOR gcl_grid.

    CALL METHOD gcl_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_mara
        it_fieldcatalog = gt_fcat.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN
*&      --> E_ROW
*&---------------------------------------------------------------------*
FORM double_click USING pv_row    TYPE lvc_s_row
                        pv_column TYPE lvc_s_col.

  CASE pv_column-fieldname.
    WHEN 'MATNR'.
      READ TABLE gt_mara INTO gs_mara INDEX pv_row-index.
      IF sy-subrc = 0.
        SET PARAMETER ID 'MAT' FIELD gs_mara-matnr.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hotspot USING pv_row    TYPE lvc_s_row
                   pv_column TYPE lvc_s_col.

  CASE pv_column-fieldname.
    WHEN 'STLNR'.
      READ TABLE gt_mara INTO gs_mara INDEX pv_row-index.

      IF sy-subrc = 0.
        SET PARAMETER ID 'MAT' FIELD gs_mara-matnr.
        SET PARAMETER ID 'WRK' FIELD pa_werks.
        SET PARAMETER ID 'CSV' FIELD gs_mara-stlan.

        CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.
