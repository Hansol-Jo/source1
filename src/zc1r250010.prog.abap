*&---------------------------------------------------------------------*
*& Report ZC1R250010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc1r250010_top                          .    " Global Data

INCLUDE zc1r250010_s01                          .  " Selection Screen
INCLUDE zc1r250010_c01                          .  " Local Class
INCLUDE zc1r250010_o01                          .  " PBO-Modules
INCLUDE zc1r250010_i01                          .  " PAI-Modules
INCLUDE zc1r250010_f01                          .  " FORM-Routines

START-OF-SELECTION.
  PERFORM get_emp_data.
  PERFORM set_style.

  CALL SCREEN '0100'.
