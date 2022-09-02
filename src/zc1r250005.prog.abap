*&---------------------------------------------------------------------*
*& Report ZC1R250005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250005_top                          .    " Global Data

INCLUDE zc1r250005_s01                          .  " Selection Screen
INCLUDE zc1r250005_c01                          .  " Local Class
INCLUDE zc1r250005_o01                          .  " PBO-Modules
INCLUDE zc1r250005_i01                          .  " PAI-Modules
INCLUDE zc1r250005_f01                          .  " FORM-Routines

START-OF-SELECTION.
  PERFORM get_bom_data.
  PERFORM set_makts.

  CALL SCREEN '0100'.
