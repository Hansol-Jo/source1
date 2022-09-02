*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_EXAM01_F01
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
  SELECT *
    FROM ztspfli_a25
    INTO CORRESPONDING FIELDS OF TABLE gt_fli
   WHERE carrid IN so_car
     AND connid IN so_con.
*------------------------------------------------------------
  LOOP AT gt_fli INTO gs_fli.
    "I&D 정보 취득
    IF gs_fli-countryfr <> gs_fli-countryto.
      gs_fli-ftype = 'I'.
    ELSE.
      gs_fli-ftype = 'D'.
    ENDIF.

    "Flight Type Icon
*    IF gs_fli-fltype = 'X'.
*      gs_fli-ficon = 'Charter'.
*      gs_styl-fieldname = 'FICON'.
*      gs_styl-style = cl_gui_alv_grid=>mc_style_button.
*      APPEND gs_styl TO gs_fli-it_styl.
*    ENDIF.

    IF gs_fli-fltype = 'X'.
      gs_fli-ficon = icon_ws_plane.
    ENDIF.

    "Airpfrom Time zone
    SELECT SINGLE time_zone
      FROM sairport
      INTO gs_fli-timefrom
     WHERE id = gs_fli-airpfrom.

    "Airpto Time zone
    SELECT SINGLE time_zone
    FROM sairport
    INTO gs_fli-timeto
   WHERE id = gs_fli-airpto.

    "I&D 색 변경
    IF gs_fli-ftype = 'D'.
      gs_color-fname = 'FTYPE'.
      gs_color-color-col = col_total.
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_fli-it_color.
    ELSEIF gs_fli-ftype = 'I'.
      gs_color-fname = 'FTYPE'.
      gs_color-color-col = col_positive.
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_fli-it_color.
    ENDIF.

    "Exception Handling
    IF gs_fli-period >= 2.
      gs_fli-light = 1.
    ELSEIF gs_fli-period = 1.
      gs_fli-light = 2.
    ELSE.
      gs_fli-light = 3.
    ENDIF.

    MODIFY gt_fli FROM gs_fli.
    CLEAR gs_fli.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_fieldcatalog .
*---Flight Time, Departure Time 수정 가능 모드로 변경--------------
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'FLTIME'.
  gs_fcat-edit = p_edit.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'DEPTIME'.
  gs_fcat-edit = p_edit.
  APPEND gs_fcat TO gt_fcat.
*---Field 추가, 기존 Flitype 숨김 & 아이콘 Field 추가----------------
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'FTYPE'.
  gs_fcat-coltext = 'I&D'.
  gs_fcat-col_pos = 5.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'FICON'.
  gs_fcat-coltext = 'Flight'.
  gs_fcat-col_pos = 9.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'FLTYPE'.
  gs_fcat-no_out = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'TIMEFROM'.
  gs_fcat-ref_table = 'SAIRPORT'.
  gs_fcat-ref_field = 'TIME_ZONE'.
  gs_fcat-col_pos = 18.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'TIMETO'.
  gs_fcat-ref_table = 'SAIRPORT'.
  gs_fcat-ref_field = 'TIME_ZONE'.
  gs_fcat-col_pos = 19.
  APPEND gs_fcat TO gt_fcat.
*---ARRTIME, PERIOD Field Color 변경----------------------------------
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'ARRTIME'.
  gs_fcat-emphasize = 'C710'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PERIOD'.
  gs_fcat-emphasize = 'C710'.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_variant .
  gs_variant-variant = p_layout.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_layout .
  gs_layout-sel_mode = 'D'.
  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-grid_title = 'Flight Schedule Report'.

*  gs_layout-stylefname = 'IT_STYL'.    "Button
  gs_layout-ctab_fname = 'IT_COLOR'.   "Cell Color

  "Exception Handling
  gs_layout-excp_fname = 'LIGHT'.
  gs_layout-excp_led = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_toolbar .
  APPEND cl_gui_alv_grid=>mc_fc_check TO gt_exct.
*  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exct.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO gt_exct.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fltime_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> LS_MOD_CELLS
*&---------------------------------------------------------------------*
FORM fltime_change  USING    p_data_changed TYPE REF TO cl_alv_changed_data_protocol
                             p_mod_cells TYPE lvc_s_modi.
*---변수 선언------------------------------------------------
  DATA: lv_fltime  TYPE ztspfli_a25-fltime,
        lv_deptime TYPE ztspfli_a25-deptime,
        lv_timefr  TYPE sairport-time_zone,
        lv_timeto  TYPE sairport-time_zone,
        lv_arrive  TYPE ztspfli_a25-arrtime,
        lv_period  TYPE n.

*--- 수정한 셀의 row id 정보를 이용하여 read table----------------
  READ TABLE gt_fli INTO gs_fli INDEX p_mod_cells-row_id.
*--- 수정한 셀의 정보 읽기--------------------------------------
  CALL METHOD p_data_changed->get_cell_value
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'FLTIME'
    IMPORTING
      e_value     = lv_fltime.

  CALL METHOD p_data_changed->get_cell_value
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'DEPTIME'
    IMPORTING
      e_value     = lv_deptime.
*---data 가져오기--------------------------------------------
  lv_timefr = gs_fli-timefrom.
  lv_timeto = gs_fli-timeto.

  IF lv_fltime IS NOT INITIAL.
    CALL FUNCTION 'ZBC405_CALC_ARRTIME'
      EXPORTING
        iv_fltime       = lv_fltime
        iv_deptime      = lv_deptime
        iv_utc          = lv_timefr
        iv_utc1         = lv_timeto
      IMPORTING
        ev_arrival_time = lv_arrive
        ev_period       = lv_period.
  ENDIF.
*---arrival time, period 값 수정-----------------------------
  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'ARRTIME'
      i_value     = lv_arrive.

  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'PERIOD'
      i_value     = lv_period.

  gs_fli-arrtime = lv_arrive.
  gs_fli-period = lv_period.

  MODIFY gt_fli FROM gs_fli INDEX p_mod_cells-row_id.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_save .
  LOOP AT gt_fli INTO gs_fli WHERE modified = 'X'.
    UPDATE ztspfli_a25
       SET fltime = gs_fli-fltime
           deptime = gs_fli-deptime
           arrtime = gs_fli-arrtime
           period = gs_fli-period
     WHERE carrid = gs_fli-carrid
       AND connid = gs_fli-connid.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_check USING p_ls_mod_cells TYPE lvc_s_modi.
  READ TABLE gt_fli INTO gs_fli INDEX p_ls_mod_cells-row_id.
  IF sy-subrc = 0.
    gs_fli-modified = 'X'.
    MODIFY gt_fli FROM gs_fli INDEX p_ls_mod_cells-row_id.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_sort .
  CLEAR gs_sort.
  gs_sort-fieldname = 'CARRID'.
  gs_sort-up = 'X'.
  gs_sort-spos = 1.
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.
  gs_sort-fieldname = 'CONNID'.
  gs_sort-up = 'X'.
  gs_sort-spos = 2.
  APPEND gs_sort TO gt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form exception_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> LS_MOD_CELLS
*&---------------------------------------------------------------------*
FORM exception_change  USING    p_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                p_mod_cells TYPE lvc_s_modi.
*---Data 선언----------------------------------------
  DATA: lv_period TYPE n,
        lv_light  LIKE gs_fli-light.
*---Read Table--------------------------------------
  READ TABLE gt_fli INTO gs_fli INDEX p_mod_cells-row_id.
*---수정한 셀의 정보 읽기--------------------------------
  CALL METHOD p_data_changed->get_cell_value
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'PERIOD'
    IMPORTING
      e_value     = lv_period.

*---Exception Handling 값 수정------------------------
  IF lv_period >= 2.
    lv_light = 1.
  ELSEIF lv_period = 1.
    lv_light = 2.
  ELSE.
    lv_light = 3.
  ENDIF.

  gs_fli-light = lv_light.

  MODIFY gt_fli FROM gs_fli INDEX p_mod_cells-row_id.

  CALL METHOD go_alv->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_checkdata
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_checkdata .
  LOOP AT gt_fli INTO gs_fli.
    "I&D 정보 취득
    IF gs_fli-countryfr <> gs_fli-countryto.
      gs_fli-ftype = 'I'.
    ELSE.
      gs_fli-ftype = 'D'.
    ENDIF.

    "flitype icon
    IF gs_fli-fltype = 'X'.
      gs_fli-ficon = icon_ws_plane.
    ENDIF.

    "Airpfrom Time zone
    SELECT SINGLE time_zone
      FROM sairport
      INTO gs_fli-timefrom
     WHERE id = gs_fli-airpfrom.

    "Airpto Time zone
    SELECT SINGLE time_zone
    FROM sairport
    INTO gs_fli-timeto
   WHERE id = gs_fli-airpto.

    "I&D 색 변경
    IF gs_fli-ftype = 'D'.
      gs_color-fname = 'FTYPE'.
      gs_color-color-col = col_total.
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_fli-it_color.
    ELSEIF gs_fli-ftype = 'I'.
      gs_color-fname = 'FTYPE'.
      gs_color-color-col = col_positive.
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_fli-it_color.
    ENDIF.

    "Exception Handling
    IF gs_fli-period >= 2.
      gs_fli-light = 1.
    ELSEIF gs_fli-period = 1.
      gs_fli-light = 2.
    ELSE.
      gs_fli-light = 3.
    ENDIF.

    MODIFY gt_fli FROM gs_fli.
    CLEAR gs_fli.
  ENDLOOP.
ENDFORM.
