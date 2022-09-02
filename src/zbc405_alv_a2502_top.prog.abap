*&---------------------------------------------------------------------*
*& Include ZBC405_ALV_A2502_TOP                     - Report ZBC405_ALV_A2502
*&---------------------------------------------------------------------*
REPORT zbc405_alv_a2502.

TABLES ztsbook_a25.
*-----------------------------------------------
*-Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_car FOR ztsbook_a25-carrid OBLIGATORY MODIF ID car,
                  so_con FOR ztsbook_a25-connid MODIF ID con,
                  so_fld FOR ztsbook_a25-fldate,
                  so_cus FOR ztsbook_a25-customid.
  SELECTION-SCREEN SKIP.
  PARAMETERS p_edit AS CHECKBOX.
  "체크박스에 체크는 'x'값임 -> 불린을 사용하는 속성(edit)에서 쓸 쑤 있음
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP.

PARAMETERS: p_layout TYPE disvariant-variant.   "variant 선택창

DATA: gt_custom TYPE TABLE OF ztscustom_a25,
      gs_custom LIKE LINE OF gt_custom.
*---------------------------------------------------
TYPES: BEGIN OF gty_sbook.
         INCLUDE TYPE ztsbook_a25.
TYPES:   light     TYPE c LENGTH 1,
         telephone TYPE ztscustom_a25-telephone,
         email     TYPE ztscustom_a25-email,
         row_color TYPE c LENGTH 4,
         it_color  TYPE lvc_t_scol,
         bt        TYPE lvc_t_styl,
         modified  TYPE c LENGTH 1,    "recode가 변경되면 'X'값이 들어올 공간
       END OF gty_sbook.

DATA: gt_sbook TYPE TABLE OF gty_sbook,
      gs_sbook LIKE LINE OF gt_sbook,
*      dl_sbook TYPE TABLE OF gty_sbook.   "for deleted records
      dl_sbook TYPE TABLE OF ztsbook_a25,
      dw_sbook LIKE LINE OF dl_sbook.
DATA: ok_code TYPE sy-ucomm.

*-------------------------------------------------
*-ALV 변수
DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

DATA: gs_variant TYPE disvariant,
      gs_layout  TYPE lvc_s_layo,
      gt_sort    TYPE lvc_t_sort,
      gs_sort    LIKE LINE OF gt_sort,
      gs_color   TYPE lvc_s_scol,
      gt_exct    TYPE ui_functions,    "값을 직접 append하기 떄문에 workarea가 필요없음
      gt_fcat    TYPE lvc_t_fcat,
      gs_fcat    LIKE LINE OF gt_fcat.

DATA: rt_tab TYPE zz_range_type,
      rs_tab TYPE zst03_carrid.
