*&---------------------------------------------------------------------*
*& Include          ZC1R250008_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_DISPLAY_FCAT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_display_fcat OUTPUT.

  PERFORM set_display_fcat.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_screen OUTPUT.

  PERFORM display_screen.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'S0101'.
  SET TITLEBAR 'T0101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_DISPLAY_FCAT_POP1 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_display_fcat_pop1 OUTPUT.

  PERFORM set_display_fcat_pop1.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS 'S0102'.
  SET TITLEBAR 'T0102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_FCAT_LAYOUT_POP2 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_fcat_layout_pop2 OUTPUT.

  gs_layout_pop2-zebra      = 'X'.
  gs_layout_pop2-sel_mode   = 'D'.
  gs_layout_pop2-no_toolbar ='X'.

  PERFORM set_fcat_layout_pop2 USING :
   'X'  'CARRID'      'SBOOK'  'CARRID' ' ',
   'X'  'CONNID'      'SBOOK'  'CONNID' ' ',
   'X'  'FLDATE'      'SBOOK'  'FLDATE' ' ',
   'X'  'BOOKID'      'SBOOK'  'BOOKID' ' ',
   ' '  'CUSTOMID'    'SBOOK'  'CUSTOMID'  ' ',
   ' '  'CUSTTYPE'    'SBOOK'  'CUSTTYPE'  ' ',
   ' '  'LUGGWEIGHT'  'SBOOK'  'LUGGWEIGHT' ' ',
   ' '  'WUNIT'       'SBOOK'  'WUNIT' ' '.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_SCREEN_POP2 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_screen_pop2 OUTPUT.

  IF gcl_container_pop2 IS NOT BOUND.

    CREATE OBJECT gcl_container_pop2
      EXPORTING
        container_name = 'GCL_CONTAINER_POP2'.

    CREATE OBJECT gcl_grid_pop2
      EXPORTING
        i_parent = gcl_container_pop2.

    CALL METHOD gcl_grid_pop2->set_table_for_first_display
      EXPORTING
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout_pop2
      CHANGING
        it_outtab       = gt_sbook
        it_fieldcatalog = gt_fcat_pop2.

  ENDIF.

ENDMODULE.
