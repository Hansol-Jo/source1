*&---------------------------------------------------------------------*
*& Include ZBC401_A25_04_TOP                        - Report ZBC401_A25_04
*&---------------------------------------------------------------------*
REPORT zbc401_a25_04.

*----Common Variable
DATA: ok_code TYPE sy-ucomm.

TYPES: BEGIN OF typ_fli.
         INCLUDE TYPE ztspfli_t03.
TYPES:   wtg_sum TYPE ztspfli_t03-wtg001.
TYPES: END OF typ_fli.

DATA: gs_fli TYPE typ_fli,
      gt_fli LIKE TABLE OF gs_fli.
"Fiedl Symbol
DATA: gv_sum TYPE c LENGTH 20,
      gv_num   TYPE n LENGTH 3.
FIELD-SYMBOLS <fs> TYPE any.
*----ALV Variable
DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

DATA: gs_layout TYPE lvc_s_layo,
      gt_fcat   TYPE lvc_t_fcat,
      gs_fcat   LIKE LINE OF gt_fcat.
