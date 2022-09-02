*&---------------------------------------------------------------------*
*& Include          YCL100_001_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

*  IF GR_CON IS INITIAL. " 변수가 초기상태인가?
*    " 초기상태 이므로 생성과정
*
*  ELSE.
*    " 이미 만들어진 상태 이므로 새로고침 로직
*  ENDIF.

  IF GR_CON IS BOUND. " 참조변수에 연결된 객체가 있는가?
    " 이미 만들어진 상태 이므로 새로고침 로직
  ELSE.
    " 초기상태 이므로 생성과정
    PERFORM CREATE_OBJECT_0100.    " Container , ALV 참조변수 객체생성
    PERFORM SET_ALV_LAYOUT_0100.   " ALV Layout 설정
    PERFORM SET_ALV_FIELDCAT_0100. " ALV Field Catalog 설정
    PERFORM DISPLAY_ALV_0100.
  ENDIF.

ENDMODULE.
