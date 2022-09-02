*&---------------------------------------------------------------------*
*& Include          ZC1R250006_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_FCAT_LAYOUT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_fcat_layout OUTPUT.
  PERFORM set_fcat_layout.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_screen OUTPUT.
  PERFORM display_screen.
ENDMODULE.
