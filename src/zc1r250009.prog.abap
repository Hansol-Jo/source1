*&---------------------------------------------------------------------*
*& Report ZC1R250009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250009_top                          .    " Global Data

INCLUDE zc1r250009_s01                          .  " Selection Screen
INCLUDE zc1r250009_c01                          .  " Local Class
INCLUDE zc1r250009_o01                          .  " PBO-Modules
INCLUDE zc1r250009_i01                          .  " PAI-Modules
INCLUDE zc1r250009_f01                          .  " FORM-Routines

INITIALIZATION.
  PERFORM init_param.

START-OF-SELECTION.
  PERFORM get_belnr.

  CALL SCREEN '0100'.
