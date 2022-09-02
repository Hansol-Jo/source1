*&---------------------------------------------------------------------*
*& Include          ZBC405_ALV_A2502_E01
*&---------------------------------------------------------------------*
INITIALIZATION.

  gs_variant-report = sy-cprog.   "sy-repid를 넣어도 됨


  rs_tab-low = 'AA'.
  rs_tab-sign = 'I'.
  rs_tab-option = 'EQ'.
  APPEND rs_tab TO rt_tab.

*  rs_tab-low = 'LH'.
*  rs_tab-sign = 'I'.
*  rs_tab-option = 'EQ'.
*  APPEND rs_tab TO rt_tab.
*
*  rs_tab-low = 'AZ'.
*  rs_tab-sign = 'I'.
*  rs_tab-option = 'EQ'.
*  APPEND rs_tab TO rt_tab.

  so_car[] = rt_tab[].

*-Call Variant Function
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load = 'F'    "S, L
    CHANGING
      cs_variant  = gs_variant.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    p_layout = gs_variant-variant.
  ENDIF.


START-OF-SELECTION.

  PERFORM get_data.

  CALL SCREEN 100.
