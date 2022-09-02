*&---------------------------------------------------------------------*
*& Include          ZC1R250002_F01
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
  pa_werks = '1010'.
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
  CLEAR   gs_mara.
  REFRESH gt_mara.

  SELECT a~matnr a~mtart a~matkl a~meins a~tragr
         b~pstat b~dismm b~ekgrp
    FROM mara AS a
   INNER JOIN marc AS b
      ON a~matnr = b~matnr
    INTO CORRESPONDING FIELDS OF TABLE gt_mara
   WHERE b~werks = pa_werks
     AND a~matnr IN so_matnr
     AND a~mtart IN so_mtart
     AND b~ekgrp IN so_ekgrp.

  IF sy-subrc <> 0.
    MESSAGE i001(zmcsa25).
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
  'X' 'MATNR' ' ' 'MARA' 'MATNR',
  ' ' 'MTART' ' ' 'MARA' 'MTART',
  ' ' 'MATKL' ' ' 'MARA' 'MATKL',
  ' ' 'MEINS' ' ' 'MARA' 'MEINS',
  ' ' 'TRAGR' ' ' 'MARA' 'TRAGR',
  ' ' 'PSTAT' ' ' 'MARC' 'PSTAT',
  ' ' 'DISMM' ' ' 'MARC' 'DISMM',
  ' ' 'EKGRP' ' ' 'MARC' 'EKGRP'.

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
  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_name.
  gs_fcat-coltext   = pv_text.
  gs_fcat-ref_table = pv_table.
  gs_fcat-ref_field = pv_field.
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

    gs_variant-report = sy-repid.   "variant의 report program이 현재 프로그램이라고 알려주는것?

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
