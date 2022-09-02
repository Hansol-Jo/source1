*&---------------------------------------------------------------------*
*& Include          ZC1R250008_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_hotspot FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_column_id
          e_row_id,
      on_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_column
          e_row.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_hotspot.

    PERFORM on_hotspot USING e_column_id e_row_id.

  ENDMETHOD.
  METHOD on_double_click.

    PERFORM on_double_click USING e_column e_row.

  ENDMETHOD.
ENDCLASS.
