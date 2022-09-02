*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_EXAM01_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF p_edit = 'X'.
    SET PF-STATUS 'S100'.
  ELSE.
    SET PF-STATUS 'S100' EXCLUDING 'SAVE'.
  ENDIF.
  SET TITLEBAR 'T100' WITH sy-datum sy-uname.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREAT_ALV_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE creat_alv_object OUTPUT.
  IF go_container IS INITIAL.
    "Create Container
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'MY_CONTROL_AREA'.
    "Create Grid
    IF sy-subrc = 0.
      CREATE OBJECT go_alv
        EXPORTING
          i_parent = go_container.
*          i_appl_events = 'X'.  "X이면 PBO, PAI를 타게하는 설정, 열어놓으면 리프레쉬를 계속 타기 떄문에 필요없으면 쓰지 않는게 좋음
    ENDIF.
    "Call Display Method
    IF sy-subrc = 0.

      PERFORM make_fieldcatalog.
      PERFORM make_variant.
      PERFORM make_layout.
      PERFORM exclude_toolbar.
      PERFORM make_sort.

      CALL METHOD go_alv->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.

      SET HANDLER: lcl_handler=>on_toolbar FOR go_alv,
                   lcl_handler=>on_usercommand FOR go_alv,
                   lcl_handler=>on_double_click FOR go_alv,
                   lcl_handler=>on_data_changed FOR go_alv,
                   lcl_handler=>on_data_changed_finish FOR go_alv.

      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
*         i_buffer_active      =
*         i_bypassing_buffer   =
*         i_consistency_check  =
          i_structure_name     = 'ZTSPFLI_A25'
          is_variant           = gs_variant
          i_save               = 'A'
          i_default            = 'X'
          is_layout            = gs_layout
*         is_print             =
*         it_special_groups    =
          it_toolbar_excluding = gt_exct
*         it_hyperlink         =
*         it_alv_graphics      =
*         it_except_qinfo      =
*         ir_salv_adapter      =
        CHANGING
          it_outtab            = gt_fli
          it_fieldcatalog      = gt_fcat
          it_sort              = gt_sort
*         it_filter            =
*       EXCEPTIONS
*         invalid_parameter_combination = 1
*         program_error        = 2
*         too_many_lines       = 3
*         others               = 4
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.
  ELSE.
    CALL METHOD go_alv->refresh_table_display.
*    CALL METHOD go_alv->refresh_table_display
**      EXPORTING
**        is_stable      =
**        i_soft_refresh =
**      EXCEPTIONS
**        finished       = 1
**        others         = 2
*            .
*    IF sy-subrc <> 0.
**     Implement suitable error handling here
*    ENDIF.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  IF p_edit = 'X'.
    SET PF-STATUS 'S200'.
  ELSE.
    SET PF-STATUS 'S200' EXCLUDING 'SAVE'.
  ENDIF.
  SET TITLEBAR 'T200' WITH sy-datum sy-uname.
ENDMODULE.
