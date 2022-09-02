*&---------------------------------------------------------------------*
*& Report ZC1R250007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250007_top                          .    " Global Data

INCLUDE zc1r250007_s01                          .  " Selection Screen
INCLUDE zc1r250007_c01                          .  " Local Class
INCLUDE zc1r250007_o01                          .  " PBO-Modules
INCLUDE zc1r250007_i01                          .  " PAI-Modules
INCLUDE zc1r250007_f01                          .  " FORM-Routines

START-OF-SELECTION.

  PERFORM get_flight_list.
  PERFORM set_carrname.

  CALL SCREEN '0100'.
