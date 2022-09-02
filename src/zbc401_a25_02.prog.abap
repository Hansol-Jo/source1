*&---------------------------------------------------------------------*
*& Report ZBC401_A25_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_a25_02.

*----interface 정의-----------------------------------
INTERFACE intf.
  DATA: ch1 TYPE i,
        ch2 TYPE i.

  METHODS met1.    "정의만 interface에서 하고, 구현은 class의 implementation에서 함
ENDINTERFACE.
*----CLASS 1 정의 및 구현-------------------------------
CLASS cl1 DEFINITION.
  PUBLIC SECTION.
    INTERFACES intf.     "interface는 항상 public에서 선언
ENDCLASS.
CLASS cl1 IMPLEMENTATION.
  METHOD intf~met1.    "intf라는 interface의 met1이라는 method를 사용

    DATA: rel TYPE i.

    rel = intf~ch1 + intf~ch2.

    WRITE : / 'Result + :', rel.
  ENDMETHOD.
ENDCLASS.
*----CLASS 2 정의 및 구현--------------------------------
CLASS cl2 DEFINITION.
  PUBLIC SECTION.
    INTERFACES intf.

    ALIASES multi_intf FOR intf~met1.    "Interface의 Method에 별칭(Aliases) 붙여줌

    ALIASES int_char1 FOR intf~ch1.
    ALIASES int_char2 FOR intf~ch2.    "Interface의 attribute에도 별칭을 붙여줄 수 있음
ENDCLASS.
CLASS cl2 IMPLEMENTATION.
  METHOD intf~met1.

    DATA: rel TYPE i.

*    rel = intf~ch1 * intf~ch2.
    rel = int_char1 * int_char2.

    WRITE : / 'Result * :', rel.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  "Class1
  DATA clobj TYPE REF TO cl1.

  CREATE OBJECT clobj.
  clobj->intf~ch1 = 10.
  clobj->intf~ch2 = 20.

  CALL METHOD clobj->intf~met1.

  "Class2
  DATA clobj1 TYPE REF TO cl2.

  CREATE OBJECT clobj1.
  clobj->intf~ch1 = 10.
  clobj->intf~ch2 = 20.

*  CALL METHOD clobj1->intf~met1.
  CALL METHOD clobj1->multi_intf.
