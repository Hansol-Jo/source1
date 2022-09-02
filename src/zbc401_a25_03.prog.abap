*&---------------------------------------------------------------------*
*& Report ZBC401_A25_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_a25_03.

CLASS cl_1 DEFINITION.
  PUBLIC SECTION.
    DATA num1 TYPE i.

    METHODS: pro IMPORTING num2 TYPE i.

    EVENTS: cutoff, cutoff2.
ENDCLASS.
CLASS cl_1 IMPLEMENTATION.
  METHOD pro.
    num1 = num2.
    IF num2 >= 5.         "언제 event를 띄워줄 건지 정의함
      RAISE EVENT cutoff.
    ELSE.
      RAISE EVENT cutoff2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS cl_event DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handling_cutoff
        FOR EVENT cutoff
        OF cl_1,
      handling_cutoff2
        FOR EVENT cutoff2
        OF cl_1.
ENDCLASS.
CLASS cl_event IMPLEMENTATION.
  METHOD handling_cutoff.
    WRITE 'Handling the Cutoff'.
    WRITE / 'Event has been processed'.
  ENDMETHOD.
  METHOD handling_cutoff2.
    WRITE 'Handling the Cutoff2222 NEwwwwwwwwwwwwwwwww'.
    WRITE / 'Event has been processed'.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA: main1    TYPE REF TO cl_1,
        event_h1 TYPE REF TO cl_event.
  PARAMETERS pa_cnt TYPE i.

  CREATE OBJECT main1.
  CREATE OBJECT event_h1.

  SET HANDLER event_h1->handling_cutoff FOR main1.
  SET HANDLER event_h1->handling_cutoff2 FOR main1.
  main1->pro( pa_cnt ).
