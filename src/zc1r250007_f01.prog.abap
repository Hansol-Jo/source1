*&---------------------------------------------------------------------*
*& Include          ZC1R250007_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_flight_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_flight_list .

  _clear gs_list gt_list.

  SELECT carrid connid fldate price currency planetype paymentsum
    INTO CORRESPONDING FIELDS OF TABLE gt_list
    FROM sflight
   WHERE carrid IN so_carr.

  IF sy-subrc NE 0.
    MESSAGE s001.
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
    'X'  'CARRID'      ' '  'SFLIGHT'  'CARRID',
    'X'  'CONNID'      ' '  'SFLIGHT'  'CONNID',
    'X'  'FLDATE'      ' '  'SFLIGHT'  'FLDATE',
    ' '  'CARRNAME'    ' '  'SCARR'    'CARRNAME',
    ' '  'PRICE'       ' '  'SFLIGHT'  'PRICE',
    ' '  'CURRENCY'    ' '  'SFLIGHT'  'CURRENCY',
    ' '  'PLANETYPE'   ' '  'SFLIGHT'  'PLANETYPE',
    ' '  'PAYMENTSUM'  ' '  'SFLIGHT'  'PAYMENTSUM'.
  ENDIF.

  IF gt_sort IS INITIAL.
    PERFORM set_sort.
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
FORM set_fcat  USING  pv_key pv_field pv_text pv_ref_table pv_ref_field.

  gs_fcat = VALUE #( key      = pv_key
                     fieldname = pv_field
                     coltext   = pv_text
                     ref_table = pv_ref_table
                     ref_field = pv_ref_field ).

  CASE pv_field.
    WHEN 'PRICE'.
      gs_fcat = VALUE #( BASE gs_fcat
                         cfieldname = 'CURRENCY'
                         do_sum     = 'X' ).    "do_sum: 해당 field의 total를 내줌

    WHEN 'PAYMENTSUM'.
      gs_fcat = VALUE #( BASE gs_fcat
                         cfieldname = 'CURRENCY' ).
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

    SET HANDLER : lcl_event_handler=>handle_double_click FOR gcl_grid.

    CALL METHOD gcl_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_list
        it_fieldcatalog = gt_fcat
        it_sort         = gt_sort.

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

  READ TABLE gt_list INTO gs_list INDEX ps_row-index.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CASE ps_column-fieldname.
    WHEN 'CARRID'.
      IF gs_list-carrid IS INITIAL.
        EXIT.
      ENDIF.

      PERFORM get_airline_info USING gs_list-carrid.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_airline_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST_CARRID
*&---------------------------------------------------------------------*
FORM get_airline_info  USING pv_carrid TYPE scarr-carrid.

  _clear gs_scarr gt_scarr.

  SELECT carrid carrname currcode url
    INTO CORRESPONDING FIELDS OF TABLE gt_scarr
    FROM scarr
   WHERE carrid = pv_carrid.

  IF sy-subrc NE 0.
    MESSAGE s000 WITH TEXT-m01.
    EXIT.   "pbo를 가야하기 때문에 100번 스크린에서는 stop을쓰면 안됨
  ENDIF.

  CALL SCREEN '0101' STARTING AT 20 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_layout_pop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat_layout_pop .

  gs_layout_pop-zebra      = 'X'.
  gs_layout_pop-cwidth_opt = 'X'.
  gs_layout_pop-sel_mode   = 'D'.
  gs_layout_pop-no_toolbar = 'X'.    "ALV의 툴바를 없애줌

  IF gt_fcat_pop IS INITIAL.
    PERFORM set_fcat_pop USING :
    'X'  'CARRID'      ' '  'SCARR'  'CARRID',
    ' '  'CARRNAME'    ' '  'SCARR'  'CARRNAME',
    ' '  'CURRCODE'    ' '  'SCARR'  'CURRCODE',
    ' '  'URL'         ' '  'SCARR'  'URL'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_pop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat_pop  USING pv_key pv_field pv_text pv_ref_table pv_ref_field.

  gt_fcat_pop = VALUE #( BASE gt_fcat_pop
                          (
                            key       = pv_key
                            fieldname = pv_field
                            coltext   = pv_text
                            ref_table = pv_ref_table
                            ref_field = pv_ref_field
                           )
                          ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen_pop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen_pop .

  IF gcl_container_pop IS NOT BOUND.

    CREATE OBJECT gcl_container_pop
      EXPORTING
        container_name = 'GCL_CONTAINER_POP'.

    CREATE OBJECT gcl_grid_pop
      EXPORTING
        i_parent = gcl_container_pop.

    CALL METHOD gcl_grid_pop->set_table_for_first_display
      EXPORTING
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout_pop
      CHANGING
        it_outtab       = gt_scarr
        it_fieldcatalog = gt_fcat_pop.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort .
  "sort에 fieldname을 넣을 때 알파벳순으로 로직 입력해야함  ->  알파벳 순으로 안하면 덤프 오류 발생
  gt_sort = VALUE #(
                     (
                       spos      = 1
                       fieldname = 'CARRID'
                       up        = 'X'
                       subtot    = 'X'   "carrid 기준으로 subtotal
                     )
                     (
                       spos      = 2
                       fieldname = 'CONNID'
                       up        = 'X'
                     )
                   ).

*  gs_sort-spos = 1.
*  gs_sort-fieldname = 'CARRID'.
*  gs_sort-up = 'X'.
*  gs_sort-subtot = 'X'.
*  APPEND gs_sort TO gt_sort.
*
*  gs_sort-spos = 2.
*  gs_sort-fieldname = 'CONNID'.
*  gs_sort-up = 'X'.
*  APPEND gs_sort TO gt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_carrname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_carrname .

  DATA: lv_tabix    TYPE sy-tabix,
        lt_scarr    TYPE zc1tt25001,
        ls_scarr    LIKE LINE OF lt_scarr,
        lv_code,
        lv_msg(100).

  IF gcl_scarr IS NOT BOUND.  "확장성 고려해서 바운드 체크해줌
    CREATE OBJECT gcl_scarr.
  ENDIF.

  LOOP AT gt_list INTO gs_list.
    lv_tabix = sy-tabix.

    _clear ls_scarr lt_scarr.
    CLEAR: lv_code, lv_msg.

    CALL METHOD gcl_scarr->get_airline_info
      EXPORTING
        pi_carrid  = gs_list-carrid
      IMPORTING
        pe_code    = lv_code
        pe_msg     = lv_msg
      CHANGING
        et_airline = lt_scarr.

    IF lv_code EQ 'S'.
      READ TABLE lt_scarr INTO ls_scarr WITH KEY carrid = gs_list-carrid.
      IF sy-subrc EQ 0.
        gs_list-carrname = ls_scarr-carrname.

        MODIFY gt_list FROM gs_list INDEX lv_tabix
        TRANSPORTING carrname.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
