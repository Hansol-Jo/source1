*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_EXAM01_CLASS
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_toolbar
        FOR EVENT toolbar
        OF cl_gui_alv_grid
        IMPORTING e_object,
      on_usercommand
        FOR EVENT user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_double_click
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,
      on_data_changed
        FOR EVENT data_changed
        OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      on_data_changed_finish
        FOR EVENT data_changed_finished
        OF cl_gui_alv_grid
        IMPORTING e_modified et_good_cells.
ENDCLASS.
CLASS lcl_handler IMPLEMENTATION.
  METHOD on_data_changed_finish.
    DATA ls_mod_cells TYPE LVC_s_MODI.

    CHECK e_modified = 'X'.

    LOOP AT et_good_cells INTO ls_mod_cells.
      PERFORM modify_check USING ls_mod_cells.    "수정 여부 체크
    ENDLOOP.
  ENDMETHOD.
  METHOD on_data_changed.
    DATA: ls_mod_cells TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
      CASE ls_mod_cells-fieldname.
        WHEN 'FLTIME' OR 'DEPTIME'.
          PERFORM fltime_change USING er_data_changed
                                      ls_mod_cells.
          PERFORM exception_change USING er_data_changed
                                         ls_mod_cells.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.
  METHOD on_double_click.
    "carrid 또는 connid 더블 클릭 시 새로운 프로그램 호출
    CASE e_column-fieldname.
      WHEN 'CARRID' OR 'CONNID'.
        READ TABLE gt_fli INTO gs_fli INDEX e_row-index.
        IF sy-subrc = 0.
*          MESSAGE i000(zmcsa25) WITH 'Test'.
          SUBMIT bc405_event_s4 AND RETURN
          WITH so_car = gs_fli-carrid
          WITH so_con = gs_fli-connid.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_usercommand.
    "get_current_cell 변수 선언
    DATA: ls_rowid TYPE lvc_s_row,
          ls_colid TYPE lvc_s_col,
          lv_text  TYPE c LENGTH 20.
    "get_selected_rows 변수 선언
    DATA: lt_rows TYPE lvc_t_roid,
          ls_rows LIKE LINE OF lt_rows.
    "Fliinfo temp table 생성
    DATA: lt_spfli TYPE TABLE OF spfli,
          ls_spfli LIKE LINE OF lt_spfli.

    "선택한 cell의 정보 취득
    CALL METHOD go_alv->get_current_cell
      IMPORTING
*       e_row     =
*       e_value   =
*       e_col     =
        es_row_id = ls_rowid
        es_col_id = ls_colid
*       es_row_no =
      .

    CASE e_ucomm.
      WHEN 'FLIGHT'.
        IF ls_colid-fieldname = 'CARRID'.
          READ TABLE gt_fli INTO gs_fli INDEX ls_rowid-index.
          IF sy-subrc = 0.
            "항공사명 취득(carrid cell을 선택해야 함)
            CLEAR lv_text.
            SELECT SINGLE carrname
              FROM scarr
              INTO lv_text
             WHERE carrid = gs_fli-carrid.
            IF sy-subrc = 0.
              MESSAGE i000(zmcsa25) WITH lv_text.  "취득 성공 시 항공사명 표시
            ELSE.
              MESSAGE i000(zmcsa25) WITH 'Data is not found!'.  "취득 실패 시 info 표시
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE i000(zmcsa25) WITH 'Please choose airline.'.
          EXIT.
        ENDIF.

      WHEN 'FLTINFO'.
        "선택된 cell의 row 정보 취득
        CALL METHOD go_alv->get_selected_rows
          IMPORTING
*           et_index_rows =
            et_row_no = lt_rows.

        LOOP AT lt_rows INTO ls_rows.
          READ TABLE gt_fli INTO gs_fli INDEX ls_rows-row_id.

          MOVE-CORRESPONDING gs_fli TO ls_spfli.
          APPEND ls_spfli TO lt_spfli.
        ENDLOOP.

        IF sy-subrc = 0.
          EXPORT mem_it_spfli FROM lt_spfli TO MEMORY ID 'BC405'.
          SUBMIT bc405_call_flights AND RETURN.
        ENDIF.

      WHEN 'FLTDATA'.
        READ TABLE gt_fli INTO gs_fli INDEX ls_rowid-index.
        IF sy-subrc = 0.
          SET PARAMETER ID 'CAR' FIELD gs_fli-carrid.
          SET PARAMETER ID 'CON' FIELD gs_fli-connid.
          SET PARAMETER ID 'DAY' FIELD ''.
          CALL TRANSACTION 'SAPBC410A_INPUT_FIEL'.
        ENDIF.
    ENDCASE.

  ENDMETHOD.
  METHOD on_toolbar.
    DATA: ls_button TYPE stb_button.

    CLEAR ls_button.
    ls_button-butn_type = '3'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = '0'.
    ls_button-function = 'FLIGHT'.
    ls_button-icon = icon_flight.
    ls_button-quickinfo = 'Airline Information'.
    ls_button-text = 'Flight'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = '0'.
    ls_button-function = 'FLTINFO'.
    ls_button-quickinfo = 'Flight Information'.
    ls_button-text = 'Flight Info'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = '0'.
    ls_button-function = 'FLTDATA'.
    ls_button-quickinfo = 'Flight Data'.
    ls_button-text = 'Flight Data'.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.
  ENDMETHOD.
ENDCLASS.
