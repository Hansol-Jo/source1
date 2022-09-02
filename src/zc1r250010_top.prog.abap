*&---------------------------------------------------------------------*
*& Include ZC1R250010_TOP                           - Report ZC1R250010
*&---------------------------------------------------------------------*
REPORT zc1r250010 MESSAGE-ID zmcsa25.

TABLES ztsa2504.

DATA: BEGIN OF gs_emp,
        mark,
        pernr    TYPE ztsa2504-pernr,
        ename    TYPE ztsa2504-ename,
        entdt    TYPE ztsa2504-entdt,
        gender   TYPE ztsa2504-gender,
        depid    TYPE ztsa2504-depid,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        style    TYPE lvc_t_styl,
      END OF gs_emp,

      gt_emp     LIKE TABLE OF gs_emp,
      gt_emp_del LIKE TABLE OF gs_emp.

*-----ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       LIKE TABLE OF gs_fcat,
      gs_layout     TYPE lvc_s_layo,
      gs_variant    TYPE disvariant,
      gs_stable     TYPE lvc_s_stbl.

DATA: gt_rows TYPE lvc_t_row,   "사용자가 선택한 행의 정보를 저장할 itab
      gs_row  TYPE lvc_s_row.

DATA: gv_okcode     TYPE sy-ucomm.
