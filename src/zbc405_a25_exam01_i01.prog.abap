*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_EXAM01_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA p_ans TYPE c LENGTH 1.
  CASE ok_code.
    WHEN 'SAVE'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Data Save'
          text_question  = 'Do you want to save?'
          text_button_1  = 'Yes'(001)
          text_button_2  = 'No'(002)
        IMPORTING
          answer         = p_ans
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        IF p_ans = '1'.
          PERFORM data_save.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Data Save'
          text_question  = 'Do you want to save?'
          text_button_1  = 'Yes'(001)
          text_button_2  = 'No'(002)
        IMPORTING
          answer         = p_ans
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        IF p_ans = '1'.
          PERFORM data_save.
        ENDIF.
      ENDIF.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CONDITION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_condition INPUT.
  CLEAR: gt_socar, gt_socon.
  IF ztspfli_a25-carrid IS NOT INITIAL.
    gs_socar-low = ztspfli_a25-carrid.
    gs_socar-sign = 'I'.
    gs_socar-option = 'EQ'.
    APPEND gs_socar TO gt_socar.
  ELSE.
    CLEAR gt_socar.
  ENDIF.

  IF ztspfli_a25-connid IS NOT INITIAL.
    gs_socon-low = ztspfli_a25-connid.
    gs_socon-sign = 'I'.
    gs_socon-option = 'EQ'.
    APPEND gs_socon TO gt_socon.
  ELSE.
    CLEAR gt_socon.
  ENDIF.

  SELECT *
    FROM ztspfli_a25
    INTO CORRESPONDING FIELDS OF TABLE gt_fli
   WHERE carrid IN gt_socar
     AND connid IN gt_socon.

  PERFORM get_checkdata.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CREATE_DROPDOWN_BOX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_dropdown_box INPUT.
  TYPES: BEGIN OF typ_conline,
           conn TYPE ztspfli_a25-connid,
         END OF typ_conline.
  DATA gt_conlist TYPE TABLE OF typ_conline.

  SELECT connid
    FROM ztspfli_a25
    INTO TABLE gt_conlist
   WHERE carrid = ztspfli_a25-carrid.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      retfield        = 'CONNID'
*     PVALKEY         = ' '
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'ZTSPFLI_A25-CONNID'
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      value_org       = 'S'    "C
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
* IMPORTING
*     USER_RESET      =
    TABLES
      value_tab       = gt_conlist
*     FIELD_TAB       =
*     RETURN_TAB      =
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDMODULE.
