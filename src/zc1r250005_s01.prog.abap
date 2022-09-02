*&---------------------------------------------------------------------*
*& Include          ZC1R250005_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     pa_werks TYPE mast-werks DEFAULT '1010' OBLIGATORY.
  SELECT-OPTIONS so_matnr FOR mast-matnr.
SELECTION-SCREEN END OF BLOCK bl1.
