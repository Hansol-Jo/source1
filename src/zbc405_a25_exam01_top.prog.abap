*&---------------------------------------------------------------------*
*& Include ZBC405_A25_EXAM01_TOP                    - Report ZBC405_A25_EXAM01
*&---------------------------------------------------------------------*
REPORT zbc405_a25_exam01.

TABLES ztspfli_a25.

*---Selection Screen--------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_car FOR ztspfli_a25-carrid,
                  so_con FOR ztspfli_a25-connid.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 2(15) TEXT-t02.
    PARAMETERS p_layout TYPE disvariant-variant.

    SELECTION-SCREEN COMMENT 50(10) TEXT-t03.
    PARAMETERS p_edit AS CHECKBOX.

    SELECTION-SCREEN COMMENT 79(13) TEXT-t04.
    PARAMETERS p_screen AS CHECKBOX.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.
*---Data 선언-----------------------------------------------------
DATA: ok_code TYPE sy-ucomm.

TYPES: BEGIN OF gty_fli.
         INCLUDE TYPE ztspfli_a25.
TYPES:   ftype    TYPE c LENGTH 1,
         ficon    TYPE c LENGTH 10,
         timefrom TYPE sairport-time_zone,
         timeto   TYPE sairport-time_zone,
*         it_styl  TYPE lvc_t_styl,
         it_color TYPE lvc_t_scol,
         light    TYPE c LENGTH 1,
         modified TYPE c LENGTH 1,
       END OF gty_fli.

DATA: gt_fli TYPE TABLE OF gty_fli,
      gs_fli LIKE LINE OF gt_fli.

"Screen 200 관련 변수 선언
TYPES : BEGIN OF typ_car,
          sign   TYPE ddsign,
          option TYPE ddoption,
          low    TYPE s_carr_id,
          high   TYPE s_carr_id,
        END OF typ_car.
TYPES: BEGIN OF typ_con,
         sign   TYPE ddsign,
         option TYPE ddoption,
         low    TYPE s_conn_id,
         high   TYPE s_conn_id,
       END OF typ_con.

DATA: gs_socar TYPE typ_car,
      gt_socar LIKE TABLE OF gs_socar,
      gs_socon TYPE typ_con,
      gt_socon LIKE TABLE OF gs_socon.
*---ALV 변수------------------------------------------------------
DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

DATA: gs_variant TYPE disvariant,
      gs_layout  TYPE lvc_s_layo,
      gt_fcat    TYPE lvc_t_fcat,
      gs_fcat    LIKE LINE OF gt_fcat,
*      gs_styl    TYPE lvc_s_styl,
      gs_color   TYPE lvc_s_scol,
      gt_exct    TYPE ui_functions,
      gt_sort    TYPE lvc_t_sort,
      gs_sort    LIKE LINE OF gt_sort.
