*&---------------------------------------------------------------------*
*& Include          ZC1R250006_C01
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_double_click
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING e_row e_column,

      on_hotspot
        FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id.
ENDCLASS.
CLASS lcl_handler IMPLEMENTATION.
  METHOD on_double_click.

    PERFORM double_click USING e_row e_column.

  ENDMETHOD.
  METHOD on_hotspot.

    PERFORM hotspot USING e_row_id e_column_id.

  ENDMETHOD.
ENDCLASS.
