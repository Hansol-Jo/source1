*&---------------------------------------------------------------------*
*& Include          ZC1R250001_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.

  PARAMETERS: pa_carr TYPE sflight-carrid OBLIGATORY.
  SELECT-OPTIONS: so_conn FOR sflight-connid.

SELECTION-SCREEN END OF BLOCK bl1.
