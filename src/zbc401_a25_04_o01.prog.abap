*&---------------------------------------------------------------------*
*& Include          ZBC401_A25_04_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
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
        container_name = 'CONT'.
    "Create Grid
    IF sy-subrc = 0.
      CREATE OBJECT go_alv
        EXPORTING
          i_parent = go_container.
    ENDIF.
    "Call ALV Method
    IF sy-subrc = 0.

      PERFORM make_layout.
      PERFORM make_fieldcatalog.

      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
*         i_buffer_active  =
*         i_bypassing_buffer            =
*         i_consistency_check           =
          i_structure_name = 'ZTSPFLI_T03'
*         is_variant       =
*         i_save           =
*         i_default        = 'X'
          is_layout        = gs_layout
*         is_print         =
*         it_special_groups             =
*         it_toolbar_excluding          =
*         it_hyperlink     =
*         it_alv_graphics  =
*         it_except_qinfo  =
*         ir_salv_adapter  =
        CHANGING
          it_outtab        = gt_fli
          it_fieldcatalog  = gt_fcat
*         it_sort          =
*         it_filter        =
*  EXCEPTIONS
*         invalid_parameter_combination = 1
*         program_error    = 2
*         too_many_lines   = 3
*         others           = 4
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDIF.
  ENDIF.
ENDMODULE.
