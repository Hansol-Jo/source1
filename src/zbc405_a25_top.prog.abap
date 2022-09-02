*&---------------------------------------------------------------------*
*& Include ZBC405_A25_TOP                           - Report ZBC405_A25
*&---------------------------------------------------------------------*
REPORT zbc405_a25.

DATA: gv_carr TYPE sflight-carrid,
      gv_conn TYPE sflight-connid,
      gv_fldat TYPE sflight-fldate.

DATA gs_info TYPE dv_flights.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t04.
  SELECT-OPTIONS: so_carr FOR gv_carr MEMORY ID car,
                  so_conn FOR gv_conn,
                  so_fldat FOR gv_fldat NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t05.
 SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 2(5) TEXT-t01.
  PARAMETERS pa_rad1 RADIOBUTTON GROUP rd1.

  SELECTION-SCREEN COMMENT pos_low(8) TEXT-t02.
  PARAMETERS pa_rad2 RADIOBUTTON GROUP rd1.

  SELECTION-SCREEN COMMENT pos_high(14) TEXT-t03.
  PARAMETERS pa_rad3 RADIOBUTTON GROUP rd1.
 SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.


INITIALIZATION.
*
*MOVE: 'AA' TO so_carr-low,
*      'QF' TO so_carr-high,
*      'BT' TO so_carr-option,
*      'I' TO so_carr-sign.
*APPEND so_carr.
*CLEAR so_carr.
*MOVE: 'AZ' TO so_carr-low.





*DATA: gs_flight TYPE dv_flights.
*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.  "블럭 이름 :t01은 유니크하게 줘야함
*
* PARAMETERS p_carr TYPE dv_flights-carrid VALUE CHECK.
*
* SELECT-OPTIONS: s_fldate FOR gs_flight-fldate.
*
* PARAMETERS p_str TYPE string LOWER CASE MODIF ID mod.
*
*SELECTION-SCREEN END OF BLOCK b1.
*
** Check Box & Radio Button
** MODIF ID
*PARAMETERS p_chk AS CHECKBOX DEFAULT 'X' MODIF ID mod.
*
*PARAMETERS: p_rad1 RADIOBUTTON GROUP rd1,
*            p_rad2 RADIOBUTTON GROUP rd1,
*            p_rad3 RADIOBUTTON GROUP rd1.
*
*INITIALIZATION.  "프로그램 시작 후 딱 한번만 실행
*
*LOOP AT SCREEN.
*  IF screen-group1 = 'MOD'.
*    screen-input = 0.
*    screen-output = 1.
*    MODIFY SCREEN.
*  ENDIF.
*ENDLOOP.
