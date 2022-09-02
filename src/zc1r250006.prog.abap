*&---------------------------------------------------------------------*
*& Report ZC1R250006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250006_top                          .    " Global Data

INCLUDE zc1r250006_s01                          .  " Selection Screen
INCLUDE zc1r250006_c01                          .  " Class
INCLUDE zc1r250006_o01                          .  " PBO-Modules
INCLUDE zc1r250006_i01                          .  " PAI-Modules
INCLUDE zc1r250006_f01                          .  " FORM-Routines

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN '0100'.
