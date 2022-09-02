*&---------------------------------------------------------------------*
*& Include          ZSYPALV002_CLASS
*&---------------------------------------------------------------------*
CLASS : lcl_handler DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS :
      on_double_click  FOR EVENT double_click OF
        cl_gui_alv_grid
        IMPORTING es_row_no e_column e_row,
      on_toolbar  FOR EVENT toolbar OF
        cl_gui_alv_grid
        IMPORTING e_object,

      on_user_command  FOR EVENT user_command OF
        cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_DATA_CHANGED
        FOR EVENT data_changed  OF cl_gui_alv_grid
        IMPORTING er_data_changed.


ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_data_changed.

    DATA : ls_mod_cells TYPE lvc_s_modi,
           ls_cells     TYPE lvc_s_modi,
           ls_del_cells TYPE lvc_s_moce,
           ls_ins_cells TYPE lvc_s_moce.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.

      CASE ls_mod_cells-fieldname.
        WHEN 'FLTIME' OR 'DEPTIME'.
          PERFORM  FLTIME_change_part       USING er_data_changed
                                                      ls_mod_cells.

      ENDCASE.


    ENDLOOP.


    "handle_data_changed
  ENDMETHOD.



  METHOD on_user_command.

    DATA : lv_row   TYPE i,
           lv_value TYPE c,
           lv_scol  TYPE lvc_s_col.

    DATA : ev_carrname TYPE scarr-carrname.
    DATA : lv_message_text TYPE c LENGTH 70,
           lv_form         TYPE scustom-form,
           lv_name         TYPE scustom-name,
           lv_city         TYPE scustom-city.

    DATA : lt_rows  TYPE lvc_t_row,
           ls_row   TYPE lvc_s_row,
           lt_spfli TYPE TABLE OF spfli,
           ls_spfli TYPE          spfli.

    CALL METHOD go_alv_grid->get_current_cell
      IMPORTING
        e_row     = lv_row
*       e_value   =
*       e_col     =
*       es_row_id =
        es_col_id = lv_scol
*       es_row_no =
      .

    CASE e_ucomm.

      WHEN 'FLTDATA'.
        CLEAR : ls_tab.
        READ TABLE gt_tab INTO Ls_tab
            INDEX lv_row.

        SET PARAMETER ID 'CAR' FIELD ls_tab-carrid.
        SET PARAMETER ID 'CON' FIELD ls_tab-connid.
        SET PARAMETER ID 'DAY' FIELD space.
        CALL TRANSACTION 'SAPBC410A_INPUT_FIEL'.




      WHEN 'MULTI_ROWS'.

        CLEAR : lt_spfli. REFRESH : lt_spfli.
        CALL METHOD go_alv_grid->get_selected_rows
          IMPORTING
            et_index_rows = lt_rows.
*            et_row_no = et_row.

        LOOP AT lt_rows INTO ls_row.
          READ TABLE gt_tAB INTO ls_TAB
             INDEX ls_row-index.

          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING ls_tab TO ls_spfli.
            APPEND ls_spfli TO lt_spfli.
          ENDIF.
        ENDLOOP.
        IF sy-subrc EQ 0.
          EXPORT mem_it_spfli FROM lt_spfli TO MEMORY ID 'BC405'.
          SUBMIT bc405_call_flights AND RETURN.

        ELSE.
          MESSAGE i000(zt03_msg) WITH 'Please select lines!'.
        ENDIF.




      WHEN 'DISP_CARRIER'.
*
        IF lv_scol-fieldname = 'CARRID'.

          READ TABLE gt_TAB INTO ls_tab
               INDEX lv_row.

          IF sy-subrc EQ 0.
            SELECT SINGLE carrname INTO ev_carrname
                  FROM scarr
                WHERE carrid = Ls_TAB-carrid.

            IF sy-subrc EQ 0.
              MESSAGE i000(zt03_msg) WITH ev_carrname.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE i000(zt03_msg) WITH
             'Please select Carrier!'.

        ENDIF.

    ENDCASE.


  ENDMETHOD.

  METHOD on_double_click.

    CASE e_column-fieldname.

      WHEN 'CARRID' OR 'CONNID'.
        READ TABLE gt_tab INTO ls_tab INDEX es_row_no-row_id.
        CHECK sy-subrc EQ 0.

        SUBMIT bc405_event_s4 AND RETURN
                WITH so_car EQ ls_tab-carrid
                WITH so_con EQ ls_tab-connid.

      WHEN OTHERS.
        MESSAGE i000(zt03_msg) WITH 'Double click for Carrid&Connid!'.
    ENDCASE.


  ENDMETHOD.

  METHOD on_toolbar.

    DATA : ls_button TYPE stb_button.

    ls_button-function = 'DISP_CARRIER'.
    ls_button-icon = icon_flight.
    ls_button-quickinfo = 'Get Airline Name'.
    ls_button-butn_type = 0.
    ls_button-text = 'Flight'.

    INSERT ls_button INTO TABLE  e_object->mt_toolbar.




    ls_button-function = 'MULTI_ROWS'.     "Flight 정보를위한 버튼
    ls_button-icon = ' '.
    ls_button-quickinfo = 'GoTo Flight info list'.
    ls_button-butn_type = 0.
    ls_button-text = 'FlightInfo'.

    INSERT ls_button INTO TABLE  e_object->mt_toolbar.


    ls_button-function = 'FLTDATA'.
    ls_button-icon = ' '.
    ls_button-quickinfo = 'GoTo Maintain Flight Data'.
    ls_button-butn_type = 0.
    ls_button-text = 'Flight Data'.

    INSERT ls_button INTO TABLE  e_object->mt_toolbar.



  ENDMETHOD.
ENDCLASS.
