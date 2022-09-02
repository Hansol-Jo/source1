*&---------------------------------------------------------------------*
*& Include          ZBC405_ALV_A2502_O01
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
*& Module CREATE_ALV_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_object OUTPUT.
  IF go_container IS INITIAL.
    "Create Container
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'MY_CONTROL_AREA'.
    "Create Grid
    IF sy-subrc = 0.     "container가 만들어지면 아래 구문을 실행
      CREATE OBJECT go_alv
        EXPORTING
          i_parent = go_container.
    ENDIF.
    "Call Display Method
    IF sy-subrc = 0. "grid가 만들어지면 아래 구문 실행


      PERFORM make_variant.
      PERFORM make_layout.
      PERFORM make_sort.
      PERFORM make_fieldcatalog.
*------------------------------------------------
      "Data Changed
      "셀을 변경할 때 잘 적용되게 하려면 값이 엔터칠떄 바로 바뀔지, 기다렸다 바뀔지 설정해줘야함 ->변경하는 순간을 설정
      CALL METHOD go_alv->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.
      "mc_evt_enter: 엔터치면 반영, mc_evt_modified: 수정되는 순간 반영
*------------------------------------------------
      APPEND cl_gui_alv_grid=>mc_fc_filter TO gt_exct.  "필터버튼 숨김 mc_fc_filter:attribute
      APPEND cl_gui_alv_grid=>mc_fc_info TO gt_exct.    "인포버튼 숨김
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exct.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO gt_exct.

      SET HANDLER: lcl_handler=>on_doubleclick FOR go_alv,
                   lcl_handler=>on_toolbar FOR go_alv,
                   lcl_handler=>on_usercommand FOR go_alv,
                   lcl_handler=>on_data_changed FOR go_alv,
                   lcl_handler=>on_data_changed_finish FOR go_alv.



      "이중화살은 class static method
      "한줄화살은 creat object로 만들어진 instance
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
*         i_buffer_active      =
*         i_bypassing_buffer   =
*         i_consistency_check  =
          i_structure_name     = 'ZTSBOOK_A25'
          is_variant           = gs_variant
          i_save               = 'A'  "A:글로벌,유저스페~ 가능, X:글로벌, 디폴트 설정가능, U:글로벌불가, 유저가능, Space:변경가능, 저장불가
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
          it_outtab            = gt_sbook
          it_fieldcatalog      = gt_fcat
          it_sort              = gt_sort
*         it_filter            =
*        EXCEPTIONS
*         invalid_parameter_combination = 1
*         program_error        = 2
*         too_many_lines       = 3
*         others               = 4
        .
      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.
    ENDIF.
  ELSE.
    "Refresh ALV Method
    DATA: gs_stable       TYPE lvc_s_stbl,
          gv_soft_refresh TYPE abap_bool.

    gv_soft_refresh = 'X'.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD go_alv->refresh_table_display
      EXPORTING
        is_stable      = gs_stable
        i_soft_refresh = gv_soft_refresh
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.

  ENDIF.
ENDMODULE.
