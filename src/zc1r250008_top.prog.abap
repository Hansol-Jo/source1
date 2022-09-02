*&---------------------------------------------------------------------*
*& Include ZC1R250008_TOP                           - Report ZC1R250008
*&---------------------------------------------------------------------*
REPORT zc1r250008 MESSAGE-ID zmcsa25.

TABLES: scarr, sflight.

DATA: BEGIN OF gs_fli,
        carrid    TYPE scarr-carrid,
        carrname  TYPE scarr-carrname,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        planetype TYPE sflight-planetype,
        price     TYPE sflight-price,
        currency  TYPE sflight-currency,
        url       TYPE scarr-url,
      END OF gs_fli,

      gt_fli LIKE TABLE OF gs_fli,

      BEGIN OF gs_saplane,
        planetype TYPE saplane-planetype,
        seatsmax  TYPE saplane-seatsmax,
        consum    TYPE saplane-consum,
        con_unit  TYPE saplane-con_unit,
        tankcap   TYPE saplane-tankcap,
        cap_unit  TYPE saplane-cap_unit,
        weight    TYPE saplane-weight,
        wei_unit  TYPE saplane-wei_unit,
      END OF gs_saplane,

      gt_saplane LIKE TABLE OF gs_saplane,

      BEGIN OF gs_sbook,
        carrid      TYPE sbook-carrid,
        connid      TYPE sbook-connid,
        fldate      TYPE sbook-fldate,
        bookid      TYPE sbook-bookid,
        customid    TYPE sbook-customid,
        custtype    TYPE sbook-custtype,
        luggweight TYPE sbook-luggweight,
        wunit       TYPE sbook-wunit,
      END OF gs_sbook,

      gt_sbook LIKE TABLE OF gs_sbook.


*----ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_docking_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_variant    TYPE disvariant,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       LIKE TABLE OF gs_fcat,
      gs_layout     TYPE lvc_s_layo,
      gv_okcode     TYPE sy-ucomm.

*----Planetype Popup ALV Variable
DATA: gcl_container_pop1 TYPE REF TO cl_gui_custom_container,
      gcl_grid_pop1      TYPE REF TO cl_gui_alv_grid,
      gs_fcat_pop1       TYPE lvc_s_fcat,
      gt_fcat_pop1       LIKE TABLE OF gs_fcat,
      gs_layout_pop1     TYPE lvc_s_layo.

*----Sbook Popup ALV Variable
DATA: gcl_container_pop2 TYPE REF TO cl_gui_custom_container,
      gcl_grid_pop2      TYPE REF TO cl_gui_alv_grid,
      gs_fcat_pop2       TYPE lvc_s_fcat,
      gt_fcat_pop2       LIKE TABLE OF gs_fcat,
      gs_layout_pop2     TYPE lvc_s_layo.
