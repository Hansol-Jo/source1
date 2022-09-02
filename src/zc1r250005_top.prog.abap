*&---------------------------------------------------------------------*
*& Include ZC1R250005_TOP                           - Report ZC1R250005
*&---------------------------------------------------------------------*
REPORT zc1r250005 MESSAGE-ID zmcsa25.

CLASS lcl_event_handler DEFINITION DEFERRED.  "글로벌타입으로 참조할 수 있도록 해줌

TABLES: mast.

DATA: BEGIN OF gs_data,  "OCCURS 0 : 헤더라인이 있는 스트럭쳐 선언
        matnr TYPE mast-matnr,
        maktx TYPE makt-maktx,
        stlan TYPE mast-stlan,
        stlnr TYPE mast-stlnr,
        stlal TYPE mast-stlal,
        mtart TYPE mara-mtart,
        matkl TYPE mara-matkl,
      END OF gs_data,

      gt_data LIKE TABLE OF gs_data.

*----ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gcl_handler   TYPE REF TO lcl_event_handler,
      gcl_maktx     TYPE REF TO zclc125_0002,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       TYPE lvc_t_fcat,
      gs_layout     TYPE lvc_s_layo,
      gs_variant    TYPE disvariant.

DATA: gv_okcode TYPE sy-ucomm.


DEFINE _clear.

  CLEAR   &1.
  REFRESH &1.

END-OF-DEFINITION.
