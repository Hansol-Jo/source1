*&---------------------------------------------------------------------*
*& Report ZRSA25_004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_004.

TABLES: sflight, sbook.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     pa_car   TYPE sflight-carrid OBLIGATORY DEFAULT 'AA'.
  SELECT-OPTIONS so_con   FOR sflight-connid  OBLIGATORY DEFAULT '0017'.
  PARAMETERS     pa_ptype TYPE sflight-planetype AS LISTBOX VISIBLE LENGTH 20 DEFAULT '747-400'.
  SELECT-OPTIONS so_bkid  FOR sbook-bookid.
SELECTION-SCREEN END OF BLOCK b1.

DATA: BEGIN OF gs_data,
        carrid    TYPE sflight-carrid,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        planetype TYPE sflight-planetype,
        currency  TYPE sflight-currency,
        bookid    TYPE sbook-bookid,
        customid  TYPE sbook-customid,
        custtype  TYPE sbook-custtype,
        class     TYPE sbook-class,
        agencynum TYPE sbook-agencynum,
      END OF gs_data,
      gt_data LIKE TABLE OF gs_data,

      BEGIN OF gs_sort,
        carrid    TYPE sflight-carrid,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        bookid    TYPE sbook-bookid,
        customid  TYPE sbook-customid,
        custtype  TYPE sbook-custtype,
        agencynum TYPE sbook-agencynum,
      END OF gs_sort,
      gt_sort LIKE TABLE OF gs_sort.

REFRESH: gt_data, gt_sort.

SELECT a~carrid a~connid   a~fldate   a~planetype a~currency
       b~bookid b~customid b~custtype b~class     b~agencynum
  INTO CORRESPONDING FIELDS OF TABLE gt_data
  FROM sflight AS a
 INNER JOIN sbook AS b
    ON a~carrid = b~carrid
   AND a~connid = b~connid
   AND a~fldate = b~fldate
 WHERE a~carrid    = pa_car
   AND a~connid   IN so_con
   AND a~planetype = pa_ptype
   AND b~bookid   IN so_bkid.

IF sy-subrc <> 0.
  MESSAGE i001(zmcsa25).
  LEAVE LIST-PROCESSING.
ENDIF.

"gt_sort에 gt_data의 데이터를 넣어주기
LOOP AT gt_data INTO gs_data.
  CASE gs_data-custtype.
    WHEN 'B'.
      MOVE-CORRESPONDING gs_data TO gs_sort.
      APPEND gs_sort TO gt_sort.
      CLEAR gs_sort.
  ENDCASE.

  IF sy-subrc <> 0.
    MESSAGE i001(zmcsa25).
  ENDIF.
ENDLOOP.

SORT gt_sort BY carrid connid fldate.
DELETE ADJACENT DUPLICATES FROM gt_sort COMPARING carrid connid fldate.
"중복을 제거할 때는 반드시 정렬한 순서대로 써줘야 함

cl_demo_output=>display_data( gt_sort ).
