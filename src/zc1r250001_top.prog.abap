*&---------------------------------------------------------------------*
*& Include ZC1R250001_TOP                           - Report ZC1R250001
*&---------------------------------------------------------------------*
REPORT zc1r250001 MESSAGE-ID zmcsa25.

TABLES sflight.

DATA: BEGIN OF gs_data,
        carrid    TYPE sflight-carrid,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        price     TYPE sflight-price,
        currency  TYPE sflight-currency,
        planetype TYPE sflight-planetype,
      END OF gs_data,

      gt_data LIKE TABLE OF gs_data.

*---- ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,   "콘테이너를 그리지 않아도 숫자를 주면 그만큼 커짐 / 콘테이너는 보통 팝업을 띄울 때 씀
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       TYPE lvc_t_fcat,  "table type이 존재하기 때문에 lvc_t_fcat을 참조하는 것으로 만듦
      gs_layout     TYPE lvc_s_layo,
      gs_variant    TYPE disvariant.

DATA: gv_okcode TYPE sy-ucomm.
