*&---------------------------------------------------------------------*
*& Report ZC1R250003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zc1r250003.

DATA: ls_data     TYPE zssa25com,
      lt_data     LIKE TABLE OF ls_data,
      lt_data_h   LIKE TABLE OF ls_data WITH HEADER LINE,
      ls_data_tmp LIKE ls_data.

DATA: lv_loekz TYPE eloek,
      lv_statu TYPE astat.
DATA: lv_bpumz TYPE ekpo-bpumz,
      lv_bpumn TYPE ekpo-bpumn.

DATA: lv_loekz2 LIKE lv_loekz,
      lv_staut2 LIKE lv_statu,
      lv_bpumz2 LIKE lv_bpumz,
      lv_bpumn2 LIKE lv_bpumn.


ls_data-bukrs = '0001'.
ls_data-belnr = 'D00001'.
APPEND ls_data TO lt_data.
CLEAR ls_data.

lt_data_h-bukrs = '0001'.
lt_data_h-belnr = 'D00001'.
APPEND lt_data_h TO lt_data_h[].
CLEAR lt_data_h.

lt_data_h-bukrs = '0002'.
lt_data_h-belnr = 'D00002'.
APPEND lt_data_h TO lt_data_h[].
CLEAR lt_data_h.

*cl_demo_output=>display( lt_data ).
*cl_demo_output=>display( lt_data_h[] ).

*----------------------------------------------------------

DATA: BEGIN OF gs_fli,
        carrid     TYPE sflight-carrid,
        connid     TYPE sflight-connid,
        currency   TYPE sflight-currency,
        planetype  TYPE sflight-planetype,
        seatsocc_b TYPE sflight-seatsocc_b,
      END OF gs_fli,

      gt_fli   LIKE TABLE OF gs_fli,

      gv_tabix TYPE sy-tabix.

SELECT carrid connid currency planetype seatsocc_b
  FROM sflight
  INTO CORRESPONDING FIELDS OF TABLE gt_fli
 WHERE currency = 'USD'
   AND planetype =  '747-400'.

IF sy-subrc <> 0.
  MESSAGE i001(zmcsa25).
  LEAVE LIST-PROCESSING.
ENDIF.

LOOP AT gt_fli INTO gs_fli.

  gv_tabix = sy-tabix.

  CASE gs_fli-carrid.
    WHEN 'UA'.
      gs_fli-seatsocc_b = gs_fli-seatsocc_b + 10.

      MODIFY gt_fli FROM gs_fli INDEX gv_tabix TRANSPORTING seatsocc_b.
  ENDCASE.

ENDLOOP.

*cl_demo_output=>display( gt_fli ).

*----New Syntax--------------------------------------------------------

SELECT carrid, connid, currency, planetype, seatsocc_b
  INTO TABLE @DATA(gt_fli2)
  FROM sflight
 WHERE currency = 'USD'
   AND planetype = '747-400'.

IF sy-subrc <> 0.
  MESSAGE i001(zmcsa25).
  LEAVE LIST-PROCESSING.
ENDIF.

cl_demo_output=>display( gt_fli2 ).
