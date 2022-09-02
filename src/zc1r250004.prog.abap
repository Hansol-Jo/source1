*&---------------------------------------------------------------------*
*& Report ZC1R250004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zc1r250004.

TABLES: mara, marc.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS: pa_werks TYPE mkal-werks DEFAULT '1010',
              pa_berid TYPE pbid-berid DEFAULT '1010',
              pa_pbdnr TYPE pbid-pbdnr,
              pa_versb TYPE pbid-versb DEFAULT '00'.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 3(10) TEXT-t04 FOR FIELD pa_crt.
    PARAMETERS: pa_crt  RADIOBUTTON GROUP ra1 DEFAULT 'X' USER-COMMAND mod.

    SELECTION-SCREEN COMMENT pos_low(10) TEXT-t05 FOR FIELD pa_disp.
    PARAMETERS: pa_disp RADIOBUTTON GROUP ra1.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-t03.
  SELECT-OPTIONS: so_matnr FOR mara-matnr MODIF ID mar,
                  so_mtart FOR mara-mtart MODIF ID mar,
                  so_matkl FOR mara-matkl MODIF ID mar,
                  so_ekgrp FOR marc-ekgrp MODIF ID mac.
  PARAMETERS: pa_dispo TYPE marc-dispo MODIF ID mac,
              pa_dismm TYPE marc-dismm MODIF ID mac.
SELECTION-SCREEN END OF BLOCK bl3.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

*&---------------------------------------------------------------------*
*& Form modify_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'PA_PBDNR' OR 'PA_VERSB'.
        screen-input = 0.       "input mode를 끔(0)
        MODIFY SCREEN.
    ENDCASE.

    CASE 'X'.
      WHEN pa_crt.
        CASE screen-group1.
          WHEN 'MAC'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.

      WHEN pa_disp.
        CASE screen-group1.
          WHEN 'MAR'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
