*&---------------------------------------------------------------------*
*& Report ZC1R250001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250001_top                          .    " Global Data

INCLUDE zc1r250001_s01                          .  " Selection Screen
INCLUDE zc1r250001_o01                          .  " PBO-Modules
INCLUDE zc1r250001_i01                          .  " PAI-Modules
INCLUDE zc1r250001_f01                          .  " FORM-Routines

INITIALIZATION.
  PERFORM init_param.

START-OF-SELECTION.                                "PAI
  PERFORM get_data.

  CALL SCREEN '0100'.
