*&---------------------------------------------------------------------*
*& Include          ZC1R250008_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_flight_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_flight_data .

  CLEAR   gs_fli.
  REFRESH gt_fli.

  SELECT a~carrid a~carrname a~url
         b~connid b~fldate   b~planetype b~price b~currency
    FROM scarr AS a
   INNER JOIN sflight AS b
      ON a~carrid = b~carrid
    INTO CORRESPONDING FIELDS OF TABLE gt_fli
   WHERE a~carrid IN so_car
     AND b~connid IN so_con
     AND b~planetype IN so_ptype.

  IF sy-subrc NE 0.
    MESSAGE i001.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_display_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display_fcat .

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-sel_mode   = 'D'.

  IF gs_fcat IS INITIAL.
    PERFORM set_fcat USING :
    'X'  'CARRID'     ' '  'SCARR'    'CARRID'    ' ',
    ' '  'CARRNAME'   ' '  'SCARR'    'CARRNAME'  ' ',
    ' '  'CONNID'     ' '  'SFLIGHT'  'CONNID'    ' ',
    ' '  'FLDATE'     ' '  'SFLIGHT'  'FLDATE'    ' ',
    ' '  'PLANETYPE'  ' '  'SFLIGHT'  'PLANETYPE' ' ',
    ' '  'PRICE'      ' '  'SFLIGHT'  'PRICE'     'CURRENCY',
    ' '  'CURRENCY'   ' '  'SFLIGHT'  'CURRENCY'  ' ',
    ' '  'URL'        ' '  'SCARR'    'URL'       ' '.
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
FORM set_fcat  USING pv_key pv_field pv_text
                     pv_ref_table pv_ref_field pv_cfieldname.

  gs_fcat = VALUE #( key = pv_key
                     fieldname = pv_field
                     coltext   = pv_text
                     ref_table = pv_ref_table
                     ref_field = pv_ref_field
                     cfieldname = pv_cfieldname ).

*  CASE pv_field.
*    WHEN 'PRICE'.
*      gs_fcat = VALUE #( BASE gs_fcat
*                         cfieldname = 'CURRENCY' ).
*  ENDCASE.

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

    SET HANDLER: lcl_event_handler=>on_double_click FOR gcl_grid.

    CALL METHOD gcl_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_fli
        it_fieldcatalog = gt_fcat.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_display_fcat_pop1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display_fcat_pop1 .
  gs_layout_pop1-zebra      = 'X'.
  gs_layout_pop1-cwidth_opt = 'X'.
  gs_layout_pop1-sel_mode   = 'D'.
  gs_layout_pop1-no_toolbar = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN_ID
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM on_hotspot  USING ps_column_id TYPE lvc_s_col
                       ps_row_id TYPE lvc_s_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN
*&      --> E_ROW
*&---------------------------------------------------------------------*
FORM on_double_click  USING ps_column TYPE lvc_s_col
                            ps_row TYPE lvc_s_row.

  READ TABLE gt_fli INTO gs_fli INDEX ps_row-index.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  IF ps_column-fieldname NE 'PLANETYPE'.

    CLEAR   gs_sbook.
    REFRESH gt_sbook.

    SELECT carrid connid fldate bookid customid custtype luggweight wunit
      FROM sbook
      INTO CORRESPONDING FIELDS OF TABLE gt_sbook
     WHERE carrid = gs_fli-carrid
       AND connid = gs_fli-connid
       AND fldate = gs_fli-fldate.

    IF sy-subrc NE 0.
      MESSAGE s001.
      EXIT.
    ENDIF.

    CALL SCREEN '0102' STARTING AT 20 3.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_layout_pop2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat_layout_pop2  USING pv_key pv_field
                                 pv_ref_table pv_ref_field pv_qunt.

  gt_fcat_pop2 = VALUE #( BASE gt_fcat_pop2
                          ( key = pv_key
                            fieldname = pv_field
                            ref_table = pv_ref_table
                            ref_field = pv_ref_field
                            quantity  = pv_qunt )
                         ).

ENDFORM.
