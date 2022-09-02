*&---------------------------------------------------------------------*
*& Include          YCL121_002_O01
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
*& Module ALV_100 OUTPUT
*&---------------------------------------------------------------------*
MODULE ALV_100 OUTPUT.

  IF GR_ALV IS BOUND.
    PERFORM REFRESH_GRID_0100.
  ELSE.
    PERFORM CREATE_OBJECT_0100.
    PERFORM SET_ALV_LAYOUT_0100.
    PERFORM SET_ALV_FIELDCAT_0100.
    PERFORM DISPLAY_ALV_0100.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID_0100 .

  CHECK GR_ALV IS BOUND.

  GR_ALV->REFRESH_TABLE_DISPLAY(
    EXPORTING
      IS_STABLE      = VALUE #( ROW = 'X' COL = 'X' )
      I_SOFT_REFRESH = SPACE
    EXCEPTIONS
      FINISHED       = 1                " Display was Ended (by Export)
      OTHERS         = 2
  ).

ENDFORM.
