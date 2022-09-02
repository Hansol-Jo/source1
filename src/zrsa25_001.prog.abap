*&---------------------------------------------------------------------*
*& Report ZRSA25_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_001.
*-----Variable---------------------------------------------------------------------
*DATA: gv_num1 TYPE c LENGTH 20,
*      gv_num2 TYPE p LENGTH 5 DECIMALS 2,
*      gv_num3 TYPE n LENGTH 8,
*      gv_num4 TYPE c LENGTH 10,
*      gv_num5 TYPE n LENGTH 10,
*      gv_num6 TYPE i,
*      gv_num7 TYPE p LENGTH 3 DECIMALS 2.
*
*gv_num7 = '0.25'.
*WRITE gv_num7.

*-----Internal Talble & Work Area--------------------------------------------------
*DATA: gs_emp TYPE ztsa2501,
*      gt_emp LIKE TABLE OF gs_emp.
*
*DATA: BEGIN OF gs_mara,
*        matnr TYPE mara-matnr,
*        werks TYPE marc-werks,
*        mtart TYPE mara-mtart,
*        matkl TYPE mara-matkl,
*        ekgrp TYPE marc-ekgrp,
*        pstat TYPE marc-pstat,
*      END OF gs_mara.
*DATA gt_mara LIKE TABLE OF gs_mara.

*-----Select & Modify------------------------------------------------------------
*DATA: gs_sbook TYPE sbook,
*      gt_sbook LIKE TABLE OF gs_sbook,
*      lv_tabix TYPE sy-tabix.
*
*CLEAR gs_sbook.
*REFRESH gt_sbook.
*
*SELECT carrid connid fldate bookid customid custtype invoice class smoker
*  FROM sbook
*  INTO CORRESPONDING FIELDS OF TABLE gt_sbook
* WHERE carrid     = 'DL'
*   AND custtype   = 'P'
*   AND order_date = '20201227'.
*
*IF sy-subrc NE 0.
*  MESSAGE i001(zmcsa25).
*  LEAVE TO LIST-PROCESSING.  "=STOP  *screen에서는 stop을 쓰지 말도록!
*ENDIF.
*
*LOOP AT gt_sbook INTO gs_sbook.
*  lv_tabix = sy-tabix.
*
*  CASE gs_sbook-smoker.
*    WHEN 'X'.
*      CASE gs_sbook-invoice.
*        WHEN 'X'.
*          gs_sbook-class = 'F'.
*          MODIFY gt_sbook FROM gs_sbook INDEX lv_tabix
*          TRANSPORTING class. "이렇게 modify하는게 가장 안전함, 수정한 필드는 항상 transporting에 추가해줘야함
*      ENDCASE.
*  ENDCASE.
*
*
**  IF gs_sbook-smoker  = 'X' AND
**     gs_sbook-invoice = 'X'.
**
**    gs_sbook-class = 'F'.
**
**    MODIFY gt_sbook FROM gs_sbook INDEX lv_tabix  "sy-tabix: 현재 움직인 스트럭쳐의 인덱스
**    TRANSPORTING class.
**    "로직 중간에 read table로 인덱스를 읽어올 경우 현재의 인덱스가 바뀌기 때문에 sy-tabix를 변수로 선언해서 쓰는게 좋음
**  ENDIF.
*ENDLOOP.
*
*cl_demo_output=>display_data( gt_sbook ).

*-----------------------------------------------------------------------------
*DATA: BEGIN OF gs_fli,
*        carrid     TYPE sflight-carrid,
*        connid     TYPE sflight-connid,
*        fldate     TYPE sflight-fldate,
*        currency   TYPE sflight-currency,
*        planetype  TYPE sflight-planetype,
*        seatsocc_b TYPE sflight-seatsocc_b,
*      END OF gs_fli,
*      gt_fli LIKE TABLE OF gs_fli.
*
*DATA lv_tabix TYPE sy-tabix.
*
*SELECT carrid connid fldate currency planetype seatsocc_b
*  FROM sflight
*  INTO CORRESPONDING FIELDS OF TABLE gt_fli
* WHERE currency  = 'USD'
*   AND planetype = '747-400'.
*
*IF sy-subrc <> 0.
*  MESSAGE i001(zmcsa25).
*  LEAVE TO LIST-PROCESSING.
*ENDIF.
*
*LOOP AT gt_fli INTO gs_fli.
*  lv_tabix = sy-tabix.
*
*  CASE gs_fli-carrid.
*    WHEN 'UA'.
*      gs_fli-seatsocc_b = gs_fli-seatsocc_b + 5.
*  ENDCASE.
*
*  MODIFY gt_fli FROM gs_fli INDEX lv_tabix TRANSPORTING seatsocc_b.
*  CLEAR gs_fli.
*ENDLOOP.
*
*cl_demo_output=>display_data( gt_fli ).

*------------------------------------------------------------------------------------
*DATA: BEGIN OF gs_mara,
*        matnr TYPE mara-matnr,
*        maktx TYPE makt-maktx,
*        mtart TYPE mara-mtart,
*        matkl TYPE mara-matkl,
*      END OF gs_mara,
*      gt_mara LIKE TABLE OF gs_mara,
*
*      BEGIN OF gs_makt,
*        matnr TYPE makt-matnr,
*        maktx TYPE makt-maktx,
*      END OF gs_makt,
*      gt_makt  LIKE TABLE OF gs_makt,
*
*      gv_tabix TYPE sy-tabix.
*
*CLEAR: gs_mara, gs_makt.
*REFRESH: gt_mara, gt_makt.
*
*SELECT *
*  FROM mara
*  INTO CORRESPONDING FIELDS OF TABLE gt_mara.
*
*SELECT *
*  FROM makt
*  INTO CORRESPONDING FIELDS OF TABLE gt_makt
* WHERE spras = sy-langu.
*
*
*LOOP AT gt_mara INTO gs_mara.
*  gv_tabix = sy-tabix.
*
*  READ TABLE gt_makt INTO gs_makt WITH KEY matnr = gs_mara-matnr.
*  IF sy-subrc = 0.
*    gs_mara-maktx = gs_makt-maktx.
*    MODIFY gt_mara FROM gs_mara INDEX gv_tabix TRANSPORTING maktx.
*  ENDIF.
*ENDLOOP.
*
*cl_demo_output=>display_data( gt_mara ).

*----------------------------------------------------------------------------

*DATA: BEGIN OF gs_spfli,
*        carrid   TYPE spfli-carrid,
*        carrname TYPE scarr-carrname,
*        url      TYPE scarr-url,
*        connid   TYPE spfli-connid,
*        airpfrom TYPE spfli-airpfrom,
*        airpto   TYPE spfli-airpto,
*        deptime  TYPE spfli-deptime,
*        arrtime  TYPE spfli-arrtime,
*      END OF gs_spfli,
*      gt_spfli LIKE TABLE OF gs_spfli,
*
*      BEGIN OF gs_scarr,
*        carrid   TYPE scarr-carrid,
*        carrname TYPE scarr-carrname,
*        url      TYPE scarr-url,
*      END OF gs_scarr,
*      gt_scarr LIKE TABLE OF gs_scarr,
*
*      gv_tabix TYPE sy-tabix.
*
*
*SELECT carrid connid airpfrom airpto deptime arrtime
*  FROM spfli
*  INTO CORRESPONDING FIELDS OF TABLE gt_spfli.
*
*SELECT carrid carrname url
*  FROM scarr
*  INTO CORRESPONDING FIELDS OF TABLE gt_scarr.
*
*LOOP AT gt_spfli INTO gs_spfli.
*  gv_tabix = sy-tabix.
*
*  READ TABLE gt_scarr INTO gs_scarr WITH KEY carrid = gs_spfli-carrid.
*
*  IF sy-subrc = 0.
*    gs_spfli-carrname = gs_scarr-carrname.
*    gs_spfli-url      = gs_scarr-url.
*    MODIFY gt_spfli FROM gs_spfli INDEX gv_tabix TRANSPORTING carrname url.
*  ENDIF.
*ENDLOOP.
*
*cl_demo_output=>display_data( gt_spfli ).

*-------------------------------------------------------------------------

*DATA: BEGIN OF gs_data,
*        matnr TYPE mara-matnr,
*        maktx TYPE makt-maktx,
*        mtart TYPE mara-mtart,
*        mtbez TYPE t134t-mtbez,
*        mbrsh TYPE mara-mbrsh,
*        mbbez TYPE t137t-mbbez,
*        tragr TYPE mara-tragr,
*        vtext TYPE ttgrt-vtext,
*      END OF gs_data,
*      gt_data  LIKE TABLE OF gs_data,
*
*      gs_t134t TYPE t134t,
*      gt_t134t LIKE TABLE OF gs_t134t,
*
*      gs_t137t TYPE t137t,
*      gt_t137t LIKE TABLE OF gs_t137t,
*
*      gs_ttgrt TYPE ttgrt,
*      gt_ttgrt LIKE TABLE OF gs_ttgrt,
*
*      gv_tabix TYPE sy-tabix.
*
*SELECT a~matnr a~mtart a~mbrsh a~tragr b~maktx
*  FROM mara AS a
* INNER JOIN makt AS b
*    ON a~matnr = b~matnr
*  INTO CORRESPONDING FIELDS OF TABLE gt_data
* WHERE b~spras = sy-langu.
*
*SELECT mtart mtbez
*  FROM t134t
*  INTO CORRESPONDING FIELDS OF TABLE gt_t134t
* WHERE spras = sy-langu.
*
*SELECT mbrsh mbbez
*  FROM t137t
*  INTO CORRESPONDING FIELDS OF TABLE gt_t137t
* WHERE spras = sy-langu.
*
*SELECT tragr vtext
*  FROM ttgrt
*  INTO CORRESPONDING FIELDS OF TABLE gt_ttgrt
* WHERE spras = sy-langu.
*
*LOOP AT gt_data INTO gs_data.
*  gv_tabix = sy-tabix.
*
*  "Get MTBEZ
*  READ TABLE gt_t134t INTO gs_t134t WITH KEY mtart = gs_data-mtart.
*  IF sy-subrc = 0.
*    gs_data-mtbez = gs_t134t-mtbez.
*
*    MODIFY gt_data FROM gs_data INDEX gv_tabix
*    TRANSPORTING mtbez.
*  ENDIF.
*
*  "Get MBBEZ
*  READ TABLE gt_t137t INTO gs_t137t WITH KEY mbrsh = gs_data-mbrsh.
*  IF sy-subrc = 0.
*    gs_data-mbbez = gs_t137t-mbbez.
*
*    MODIFY gt_data FROM gs_data INDEX gv_tabix
*    TRANSPORTING mbbez.
*  ENDIF.
*
*  "Get VTEXT
*  READ TABLE gt_ttgrt INTO gs_ttgrt WITH KEY tragr = gs_data-tragr.
*  IF sy-subrc = 0.
*    gs_data-vtext = gs_ttgrt-vtext.
*
*    MODIFY gt_data FROM gs_data INDEX gv_tabix
*    TRANSPORTING vtext.
*  ENDIF.
*
*ENDLOOP.
*
*cl_demo_output=>display_data( gt_data ).

*-----------------------------------------------------------------------------------

DATA: BEGIN OF gs_data,
        ktopl TYPE ska1-ktopl,
        ktplt TYPE t004t-ktplt,
        saknr TYPE ska1-saknr,
        txt20 TYPE skat-txt20,
        ktoks TYPE ska1-ktoks,
        txt30 TYPE t077z-txt30,
      END OF gs_data,
      gt_data  LIKE TABLE OF gs_data,

      gs_t004t TYPE t004t,
      gt_t004t LIKE TABLE OF gs_t004t,

      gs_skat  TYPE skat,
      gt_skat  LIKE TABLE OF gs_skat,

      gs_t077z TYPE t077z,
      gt_t077z LIKE TABLE OF gs_t077z,

      gv_tabix TYPE sy-tabix.

SELECT ktopl saknr ktoks
  FROM ska1
  INTO CORRESPONDING FIELDS OF TABLE gt_data
 WHERE ktopl = 'WEG'.

SELECT ktopl ktplt
  FROM t004t
  INTO CORRESPONDING FIELDS OF TABLE gt_t004t
 WHERE spras = sy-langu.

SELECT saknr txt20
  FROM skat
  INTO CORRESPONDING FIELDS OF TABLE gt_skat
 WHERE spras = sy-langu.

SELECT ktoks txt30
  FROM t077z
  INTO CORRESPONDING FIELDS OF TABLE gt_t077z
 WHERE spras = sy-langu.

LOOP AT gt_data INTO gs_data.
  gv_tabix = sy-tabix.

  READ TABLE gt_t004t INTO gs_t004t WITH KEY ktopl = gs_data-ktopl.
  IF sy-subrc = 0.
    gs_data-ktplt = gs_t004t-ktplt.
    MODIFY gt_data FROM gs_data INDEX gv_tabix TRANSPORTING ktplt.
  ENDIF.

  READ TABLE gt_skat INTO gs_skat WITH KEY saknr = gs_data-saknr.
  IF sy-subrc = 0.
    gs_data-txt20 = gs_skat-txt20.
    MODIFY gt_data FROM gs_data INDEX gv_tabix TRANSPORTING txt20.
  ENDIF.

  READ TABLE gt_t077z INTO gs_t077z WITH KEY ktoks = gs_data-ktoks.
  IF sy-subrc = 0.
    gs_data-txt30 = gs_t077z-txt30.
    MODIFY gt_data FROM gs_data INDEX gv_tabix TRANSPORTING txt30.
  ENDIF.

ENDLOOP.

cl_demo_output=>display_data( gt_data ).
