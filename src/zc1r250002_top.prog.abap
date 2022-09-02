*&---------------------------------------------------------------------*
*& Include ZC1R250002_TOP                           - Report ZC1R250002
*&---------------------------------------------------------------------*
REPORT zc1r250002.

DATA: BEGIN OF gs_mara,
        matnr TYPE mara-matnr,
        mtart TYPE mara-mtart,
        matkl TYPE mara-matkl,
        meins TYPE mara-meins,
        tragr TYPE mara-tragr,
        pstat TYPE marc-pstat,
        dismm TYPE marc-dismm,
        ekgrp TYPE marc-ekgrp,
      END OF gs_mara,

      gt_mara   LIKE TABLE OF gs_mara.
*------ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_layout     TYPE lvc_s_layo,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       TYPE lvc_t_fcat,
      gs_variant    TYPE disvariant,
      gv_okcode TYPE sy-ucomm.
