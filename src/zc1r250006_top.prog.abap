*&---------------------------------------------------------------------*
*& Include ZC1R250006_TOP                           - Report ZC1R250006
*&---------------------------------------------------------------------*
REPORT zc1r250006 MESSAGE-ID zmcsa25.

*----Common Variable
TABLES mast.

DATA: gv_okcode TYPE sy-ucomm,
      gv_tabix  TYPE sy-tabix.

DATA: BEGIN OF gs_mara,
        matnr TYPE mast-matnr,
        maktx TYPE makt-maktx,
        stlan TYPE mast-stlan,
        stlnr TYPE mast-stlnr,
        stlal TYPE mast-stlal,
        mtart TYPE mara-mtart,
        matkl TYPE mara-matkl,
      END OF gs_mara,
      gt_mara  LIKE TABLE OF gs_mara,

      gs_makt TYPE makt,
      gt_makt LIKE TABLE OF gs_makt.

*----ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_layout     TYPE lvc_s_layo,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       LIKE TABLE OF gs_fcat,
      gs_variant    TYPE disvariant.
