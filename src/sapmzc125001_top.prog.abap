*&---------------------------------------------------------------------*
*& Include SAPMZC125001_TOP                         - Module Pool      SAPMZC125001
*&---------------------------------------------------------------------*
PROGRAM sapmzc125001 MESSAGE-ID zmcsa25.

DATA: BEGIN OF gs_data,
        matnr TYPE ztsa2503-matnr,  "Material
        werks TYPE ztsa2503-werks,  "Plant
        mtart TYPE ztsa2503-mtart,  "Mat.Type
        matkl TYPE ztsa2503-matkl,  "Mat.Group
        menge TYPE ztsa2503-menge,  "Quantity
        meins TYPE ztsa2503-meins,  "Unit
        dmbtr TYPE ztsa2503-dmbtr,  "Price
        waers TYPE ztsa2503-waers,  "Currency
      END OF gs_data,

      gt_data   LIKE TABLE OF gs_data,

      gv_okcode TYPE sy-ucomm.

*----ALV Variable
DATA: gcl_container TYPE REF TO cl_gui_custom_container,
      gcl_grid      TYPE REF TO cl_gui_alv_grid,
      gs_fcat       TYPE lvc_s_fcat,
      gt_fcat       LIKE TABLE OF gs_fcat,
      gs_layout     TYPE lvc_s_layo,
      gs_variant    TYPE disvariant.
