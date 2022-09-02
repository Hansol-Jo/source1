*&---------------------------------------------------------------------*
*& Report ZC1R250008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250008_top                          .    " Global Data

INCLUDE zc1r250008_c01                          .  " Local Class
INCLUDE zc1r250008_s01                          .  " Selection Screen
INCLUDE zc1r250008_o01                          .  " PBO-Modules
INCLUDE zc1r250008_i01                          .  " PAI-Modules
INCLUDE zc1r250008_f01                          .  " FORM-Routines

START-OF-SELECTION.

  PERFORM get_flight_data.

  CALL SCREEN '0100'.
