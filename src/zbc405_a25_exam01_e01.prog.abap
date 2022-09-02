*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_EXAM01_E01
*&---------------------------------------------------------------------*
INITIALIZATION.
*---Varient 설정---------------------
  gs_variant-report = sy-cprog.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load = 'F'
    CHANGING
      cs_variant  = gs_variant.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    p_layout = gs_variant-variant.
  ENDIF.

START-OF-SELECTION.
PERFORM get_data.
"Screen Mode 선택 시 Screen 200 Call
  IF p_screen = 'X'.
    CALL SCREEN 200.
  ELSE.
    CALL SCREEN 100.
  ENDIF.
