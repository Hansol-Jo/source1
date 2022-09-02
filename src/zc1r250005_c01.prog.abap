*&---------------------------------------------------------------------*
*& Include          ZC1R250005_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* Inheritance   : 상속성 (클래스가 부모 클래스의 속성을 상속받아서 사용할 수 있음)
* Encapsulation : 캡슐화 (하나의 기능을 가진 것이 아니라 여러 메소드와 스테틱 속성, 어트리뷰트 등 여러가지 기능이 들어있음)
* Polymorphism  : 다형성 (a라는 메소드를 여러개 만들 수 있음 -> 리턴타입이나 파라미터 갯수가 달라야 한다는 조건이 있음)

CLASS lcl_event_handler DEFINITION FINAL.   "final: 마지막 클래스 -> 다른 클래스에서 상속받을 수 없음
  PUBLIC SECTION.
    METHODS :
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column,
      handle_hotspot FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_row_id
          e_column_id.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_double_click.

    PERFORM handle_double_click USING e_row e_column.

  ENDMETHOD.

  METHOD handle_hotspot.

    PERFORM handle_hotspot USING e_row_id e_column_id.

  ENDMETHOD.

ENDCLASS.
