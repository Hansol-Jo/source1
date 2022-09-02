*&---------------------------------------------------------------------*
*& Report ZRSA25_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_003.

TABLES sbook.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     pa_car  TYPE sbook-carrid   OBLIGATORY DEFAULT 'AA'.
  SELECT-OPTIONS so_con  FOR  sbook-connid   OBLIGATORY.
  PARAMETERS     pa_cust TYPE sbook-custtype OBLIGATORY
                 AS LISTBOX VISIBLE LENGTH 20 DEFAULT 'B'.

  SELECTION-SCREEN SKIP 1.

  SELECT-OPTIONS: so_fdate FOR sbook-fldate DEFAULT sy-datum, "sy-datlo: 현지날짜, sy-uzeit:현재시간, sy-timlo: 현지시간
                  so_book  FOR sbook-bookid,
                  so_cuid  FOR sbook-customid NO INTERVALS NO-EXTENSION. "parameter인데 필수값은 아닐때 사용, parameter로 선언하면 공백으로 둘 경우 공백을 찾음
SELECTION-SCREEN END OF BLOCK bl1.

DATA: BEGIN OF gs_sbook,
        carrid   TYPE sbook-carrid,
        connid   TYPE sbook-connid,
        fldate   TYPE sbook-fldate,
        customid TYPE sbook-customid,
        custtype TYPE sbook-custtype,
        invoice  TYPE sbook-invoice,
        class    TYPE sbook-class,
      END OF gs_sbook,
      gt_sbook LIKE TABLE OF gs_sbook,

      gv_tabix TYPE sy-tabix.

REFRESH gt_sbook.

SELECT carrid connid fldate customid custtype class invoice
  FROM sbook
  INTO CORRESPONDING FIELDS OF TABLE gt_sbook
 WHERE carrid   =  pa_car
   AND connid   IN so_con
   AND custtype =  pa_cust
   AND fldate   IN so_fdate
   AND bookid   IN so_book
   AND customid IN so_cuid.

IF sy-subrc <> 0.
  MESSAGE i001(zmcsa25).
  LEAVE LIST-PROCESSING.  "STOP
ENDIF.

  LOOP AT gt_sbook INTO gs_sbook.
    gv_tabix = sy-tabix.

    CASE gs_sbook-invoice.
      WHEN 'X'.
        gs_sbook-class = 'F'.
        MODIFY gt_sbook FROM gs_sbook INDEX gv_tabix TRANSPORTING class.
    ENDCASE.
  ENDLOOP.

  cl_demo_output=>display_data( gt_sbook ).
