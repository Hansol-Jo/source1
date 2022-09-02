*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_ALV_CLASS
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.     "event 정의
  PUBLIC SECTION.
    CLASS-METHODS:
      on_doubleclick FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,
      on_hotspot FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,
      on_toolbar FOR EVENT toolbar
        OF cl_gui_alv_grid
        IMPORTING e_object,
      on_user_command FOR EVENT user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_button_click FOR EVENT button_click
        OF cl_gui_alv_grid
        IMPORTING es_col_id es_row_no,
      on_context_menu_request FOR EVENT context_menu_request
        OF cl_gui_alv_grid
        IMPORTING e_object,
      on_before_user_com FOR EVENT before_user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_data_changed FOR EVENT data_changed
        OF cl_gui_alv_grid
        IMPORTING er_data_changed.

ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.    "event 구현
  METHOD on_data_changed.
    DATA: ls_mod_cells TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
      CASE ls_mod_cells-fieldname.
        WHEN 'PLANETYPE'.
          PERFORM planetype_change USING er_data_changed
                                         ls_mod_cells.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
  METHOD on_before_user_com.
    CASE e_ucomm.
      WHEN cl_gui_alv_grid=>mc_fc_detail.
        CALL METHOD go_alv_grid->set_user_command
          EXPORTING
            i_ucomm = 'SCHE'.      "flight schedule report
    ENDCASE.
  ENDMETHOD.
  METHOD on_context_menu_request.

*    CALL METHOD e_object->add_separator.
*
*    CALL METHOD cl_ctmenu=>load_gui_status    "static methods
*      EXPORTING
*        program    = sy-cprog
*        status     = 'CT_MENU'
**        disable    =     "메뉴가 비활성화 되는 기능
*        menu       = e_object
*      EXCEPTIONS
*        read_error = 1
*        OTHERS     = 2
*            .
*    IF sy-subrc <> 0.
**     Implement suitable error handling here
*    ENDIF.
    DATA: lv_col_id TYPE lvc_s_col,
          lv_row_id TYPE lvc_s_row.

    CALL METHOD go_alv_grid->get_current_cell
      IMPORTING
*       e_row     =
*       e_value   =
*       e_col     =
        es_row_id = lv_row_id
        es_col_id = lv_col_id
*       es_row_no =
      .
    IF lv_col_id-fieldname = 'CARRID'.
      CALL METHOD e_object->add_separator.

      CALL METHOD e_object->add_function
        EXPORTING
          fcode = 'CARR_NAME'
          text  = 'Display Airline'
*         icon  =
*         ftype =
*         disabled          =
*         hidden            =
*         checked           =
*         accelerator       =
*         insert_at_the_top = SPACE
        .
    ENDIF.
  ENDMETHOD.
  METHOD on_button_click.
    CASE es_col_id-fieldname.
      WHEN 'BTN_TEXT'.
        READ TABLE gt_flt INTO gs_flt INDEX es_row_no-row_id.

        IF ( gs_flt-seatsmax <> gs_flt-seatsocc )
          OR ( gs_flt-seatsmax_f <> gs_flt-seatsocc_f ).
          MESSAGE i000(zt03_msg) WITH '다른 등급의 좌석을 예약하세요.'.
        ELSE.
          MESSAGE i000(zt03_msg) WITH '모든 좌석이 예약되었습니다.'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_user_command.
    DATA: lv_occp     TYPE i,
          lv_capa     TYPE i,
          lv_perct    TYPE p LENGTH 8 DECIMALS 1,
          lv_text(20).

    DATA: lt_rows TYPE lvc_t_roid,
          ls_rows LIKE LINE OF lt_rows.

    DATA: lv_col_id TYPE lvc_s_col,
          lv_row_id TYPE lvc_s_row.

    CLEAR lv_text.
    CALL METHOD go_alv_grid->get_current_cell
      IMPORTING
*       e_row     =
*       e_value   =
*       e_col     =
        es_row_id = lv_row_id
        es_col_id = lv_col_id
*       es_row_no =
      .

    CASE e_ucomm.
      WHEN 'SCHE'.     "goto flight schedule report
        READ TABLE gt_flt INTO gs_flt INDEX lv_row_id-index.
        IF sy-subrc = 0.
          SUBMIT bc405_event_d4 AND RETURN   "a프로그램에서 b프로그램을 부르고, back을 누르면 이전 화면으로 돌아옴
            WITH so_car = gs_flt-carrid
            WITH so_con = gs_flt-connid.
        ENDIF.
      WHEN 'PERCENTAGE'.
        LOOP AT gt_flt INTO gs_flt.
          lv_occp = lv_occp + gs_flt-seatsocc.
          lv_capa = lv_capa + gs_flt-seatsmax.
        ENDLOOP.
        lv_perct = lv_occp / lv_capa * 100.
        lv_text = lv_perct.
        CONDENSE lv_text.

        MESSAGE i000(zt03_msg) WITH 'Percentage of occupied seats (%) :' lv_text.
      WHEN 'PERCENTAGE_MARKED'.
        CALL METHOD go_alv_grid->get_selected_rows
          IMPORTING
*           et_index_rows =
            et_row_no = lt_rows.
        IF lines( lt_rows ) > 0.
          LOOP AT lt_rows INTO ls_rows.
            READ TABLE gt_flt INTO gs_flt INDEX ls_rows-row_id.
            IF sy-subrc = 0.
              lv_occp = lv_occp + gs_flt-seatsocc.
              lv_capa = lv_capa + gs_flt-seatsmax.
            ENDIF.
          ENDLOOP.
          lv_perct = lv_occp / lv_capa * 100.
          lv_text = lv_perct.
          CONDENSE lv_text.

          MESSAGE i000(zt03_msg) WITH 'Percentage of Marked occupied seats (%) :' lv_text.
        ELSE.
          MESSAGE i000(zt03_msg) WITH 'Please select at least one line.'.
        ENDIF.
      WHEN 'CARR_NAME'.
        IF lv_col_id-fieldname = 'CARRID'.
          READ TABLE gt_flt INTO gs_flt INDEX lv_row_id-index.
          IF sy-subrc = 0.
            CLEAR lv_text.
            SELECT SINGLE carrname
              FROM scarr
              INTO lv_text
             WHERE carrid = gs_flt-carrid.
            IF sy-subrc = 0.
              MESSAGE i000(zt03_msg) WITH lv_text.
            ELSE.
              MESSAGE i000(zt03_msg) WITH 'No found!'.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE i000(zt03_msg) WITH '항공사를 선택하세요.'.
          EXIT.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_toolbar.
    DATA: ls_button TYPE stb_button.

    CLEAR: ls_button.
    ls_button-function = 'PERCENTAGE'.
*    ls_button-icon =
    ls_button-quickinfo = 'Occupied Percentage'.
    ls_button-butn_type = '0'.     "Normal button
    ls_button-text = 'Percentage'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR: ls_button.
    ls_button-butn_type = '3'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR: ls_button.
    ls_button-function = 'PERCENTAGE_MARKED'.
*    ls_button-icon =
    ls_button-quickinfo = 'Occupied Marked Percentage'.
    ls_button-butn_type = '0'.     "Normal button
    ls_button-text = 'Marked Percentage'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR: ls_button.
    ls_button-function = 'CARR_NAME'.
    ls_button-quickinfo = 'Carrier Name'.
    ls_button-icon = icon_ws_plane.
    ls_button-butn_type = '0'.     "Normal button
    ls_button-text = 'Carrier Name'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.
  ENDMETHOD.
  METHOD on_hotspot.
    DATA: lv_carrname TYPE scarr-carrname.

    CASE e_column_id-fieldname.
      WHEN 'CARRID'.
        READ TABLE gt_flt INTO gs_flt INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          SELECT SINGLE carrname
            FROM scarr
            INTO lv_carrname
           WHERE carrid = gs_flt-carrid.
          IF sy-subrc = 0.
            MESSAGE i000(zt03_msg) WITH lv_carrname.
          ELSE.
            MESSAGE i000(zt03_msg) WITH 'No found!'.
          ENDIF.
        ELSE.
          MESSAGE i075(bc405_408).
          EXIT.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_doubleclick.
    DATA: lv_total   TYPE i,
          lv_total_c TYPE c LENGTH 10.

    CASE e_column-fieldname.
      WHEN 'CHANGES_POSSIBLE'.
        READ TABLE gt_flt INTO gs_flt INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          lv_total = gs_flt-seatsocc + gs_flt-seatsocc_b + gs_flt-seatsocc_f.
          lv_total_c = lv_total.
          CONDENSE lv_total_c.   "문자 왼쪽 정렬, 숫자 오른쪽 정렬 자동으로 해줌
          MESSAGE i000(zt03_msg) WITH 'Total number of bookings:' lv_total_c.
        ELSE.
          MESSAGE i075(bc405_408).
          EXIT.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
