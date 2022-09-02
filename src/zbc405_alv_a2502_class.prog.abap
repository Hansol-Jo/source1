*&---------------------------------------------------------------------*
*& Include          ZBC405_ALV_A2502_CLASS
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    "class-를 붙여서 methods를 static화 시킴, 변수 선언하지 않고 그냥 쓸 수 있음
    CLASS-METHODS:
      on_doubleclick
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,
      on_toolbar
        FOR EVENT toolbar
        OF cl_gui_alv_grid
        IMPORTING e_object,
      on_usercommand
        FOR EVENT user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
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
  METHOD on_doubleclick.
    DATA: lv_carrname TYPE scarr-carrname.
    CASE e_column-fieldname.
      WHEN 'CARRID'.
        READ TABLE gt_sbook INTO gs_sbook
             INDEX e_row-index.
        IF sy-subrc = 0.
          SELECT SINGLE carrname
            FROM scarr
            INTO lv_carrname
           WHERE carrid = gs_sbook-carrid.
          IF sy-subrc = 0.
            MESSAGE i000(zmcsa25) WITH lv_carrname.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_toolbar.
    DATA: wa_button TYPE stb_button.
    wa_button-butn_type = '3'.      "seperator
    INSERT wa_button INTO TABLE e_object->mt_toolbar.

    CLEAR wa_button..
    wa_button-butn_type = '0'.    "normal button
    wa_button-function = 'GOTOFL'.     "flight connection
    wa_button-icon = icon_flight.
    wa_button-quickinfo = 'Go To Flight Connection'.
    wa_button-text = 'Flight'.
    INSERT wa_button INTO TABLE e_object->mt_toolbar.
  ENDMETHOD.
  METHOD on_usercommand.
    DATA: ls_col  TYPE lvc_s_col,
          ls_roid TYPE lvc_s_roid.
    "클릭하는 순간의 column과 row 정보 취득
    CALL METHOD go_alv->get_current_cell
      IMPORTING
        es_col_id = ls_col
        es_row_no = ls_roid.

    CASE e_ucomm.
      WHEN 'GOTOFL'.
        READ TABLE gt_sbook INTO gs_sbook INDEX ls_roid-row_id.   "row 정보만 거름 -> field는 어디를 선택하는 상관x
        IF sy-subrc = 0.
          SET PARAMETER ID 'CAR' FIELD gs_sbook-carrid.  "sap memory
          SET PARAMETER ID 'CON' FIELD gs_sbook-connid.
          "다른 프로그램과 연결
          CALL TRANSACTION 'SAPBC405CAL'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD on_data_changed.

    FIELD-SYMBOLS <fs> LIKE gt_sbook.

    DATA: ls_mod_cells TYPE lvc_s_modi,
          ls_ins_cells TYPE lvc_s_moce,
          ls_del_cells TYPE lvc_s_moce.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells. "er 안에서 받아온 여러 속성 중 good~을 돌건데 그건 테이블 타입, ls_mod가 스트럭쳐
      CASE ls_mod_cells-fieldname.
        WHEN 'CUSTOMID'.
          PERFORM customer_change_part USING er_data_changed    "data changed event의 parameter, class type
                                             ls_mod_cells.
      ENDCASE.
    ENDLOOP.

**----INSERTED PARTS    필드심볼: 메모리로 데이터를 기억하는 공간, 실제 공간을 갖지 않더라도 어싸인하면 공간이 정해짐, 가상의 메모리공간에서 필드의 이름과 값을 기억함
    IF er_data_changed->mt_inserted_rows IS NOT INITIAL.

      ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
      "MP_MOD_ROWS: 새로 추가된 ROW의 정보가 쌓임(FS), 얘를 데이터 테이블에 넣어줘야 함, 필드심볼에 어사인 되는 순간 GT_SBOOK이 됨

      IF sy-subrc = 0.
        APPEND LINES OF <fs> TO gt_sbook. "append하면 데이터가 가장 아래쪽에 쌓임

        LOOP AT er_data_changed->mt_inserted_rows INTO ls_ins_cells.  "추가한 row에 대해 화면을 어떻게 구성할 것인지 설정하는 부분, 핸들링, 추가한 row의 개수만큼 돎
          READ TABLE gt_sbook INTO gs_sbook INDEX ls_ins_cells-row_id.
          IF sy-subrc = 0.
            PERFORM insert_parts USING er_data_changed
                                       ls_ins_cells.
          ENDIF.
        ENDLOOP.
        CLEAR <fs>.
      ENDIF.

    ENDIF.

*------DELETE PARTS
    IF er_data_changed->mt_deleted_rows IS NOT INITIAL.
      LOOP AT er_data_changed->mt_deleted_rows INTO ls_del_cells.
        READ TABLE gt_sbook INTO gs_sbook INDEX ls_del_cells-row_id.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING gs_sbook to dw_sbook.
          APPEND dw_sbook TO dl_sbook.    "delete 할 대상을 담은 임시공간, delete는 pai로직을 타기 때문에 글로벌로 선언해야함
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD on_data_changed_finish.
    DATA: ls_mod_cells TYPE lvc_s_modi.

    CHECK e_modified = 'X'.    "데이터가 수정되면 e_modified에 X가 옴, check:조건이 참일 때만 아래 로직을 수행한다, 거짓이면 method를 빠져나감
    LOOP AT et_good_cells INTO ls_mod_cells.
      PERFORM modify_check USING ls_mod_cells.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
