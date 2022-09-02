*&---------------------------------------------------------------------*
*& Report ZBC401_A25_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_a25_01.

"icon ref
TYPE-POOLS icon.   "type group을 가져다 쓰는 구문 (icon, symbol, column 등의 그룹이 있음)
"constants를 글로벌로 선언해서 사용하고 싶을 때 type group에서 만들어서 사용할 수 있음 ex) pie 3.14

CLASS lcl_airplane DEFINITION.    "정의
  PUBLIC SECTION.
    METHODS:
      set_attributes
        IMPORTING iv_name      TYPE string
                  iv_planetype TYPE saplane-planetype,
      display_attributes,
      constructor
        IMPORTING  iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
        EXCEPTIONS wrong_planetype.

    CLASS-METHODS: display_n_o_airplanes.
    CLASS-METHODS: get_n_o_airplanes RETURNING VALUE(rv_count) TYPE i.
    CLASS-METHODS: class_constructor.

  PRIVATE SECTION.
    "Instance variable
    DATA: mv_name      TYPE string,
          mv_planetype TYPE saplane-planetype,
          mv_weight    TYPE saplane-weight,
          mv_tankcap   TYPE saplane-tankcap.
    "Static variable
    TYPES: ty_planetype TYPE TABLE OF saplane.
    CLASS-DATA: gv_n_o_airplanes TYPE i,
                gv_planetypes    TYPE ty_planetype.
    "Constant variable
    CONSTANTS: c_pos_i TYPE i VALUE 30.

    CLASS-METHODS:
      get_technical_attributes
        IMPORTING  iv_type    TYPE saplane-planetype
        EXPORTING  ev_weight  TYPE saplane-weight
                   ev_tankcap TYPE saplane-tankcap
        EXCEPTIONS wrong_planetype.

ENDCLASS.
CLASS lcl_airplane IMPLEMENTATION.    "구현
  METHOD get_technical_attributes.
    DATA ls_planetype TYPE saplane.

    READ TABLE gv_planetypes INTO ls_planetype WITH KEY planetype = iv_type.

    IF sy-subrc = 0.
      ev_weight = ls_planetype-weight.
      ev_tankcap = ls_planetype-tankcap.
    ELSE.
      RAISE wrong_planetype.
    ENDIF.
  ENDMETHOD.
  METHOD class_constructor.
    SELECT *
      FROM saplane
      INTO TABLE gv_planetypes.
  ENDMETHOD.
  "set_attribute의 기능과 exception 체크 로직을 포함하는 method
  METHOD constructor.
    DATA ls_planetype TYPE saplane.

    mv_name = iv_name.
    mv_planetype = iv_planetype.

*    SELECT SINGLE *
*      FROM saplane
*      INTO ls_planetype
*     WHERE planetype = iv_planetype.
*
*    IF sy-subrc <> 0.
*      RAISE wrong_planetype.
*    ELSE.
*      mv_weight = ls_planetype-weight.
*      mv_tankcap = ls_planetype-tankcap.
*
*      gv_n_o_airplanes = gv_n_o_airplanes + 1.
*    ENDIF.
    CALL METHOD get_technical_attributes
      EXPORTING
        iv_type         = iv_planetype
      IMPORTING
        ev_weight       = mv_weight
        ev_tankcap      = mv_tankcap
      EXCEPTIONS
        wrong_planetype = 1.
    IF sy-subrc = 0.
      gv_n_o_airplanes = gv_n_o_airplanes + 1.
    ELSE.
      RAISE wrong_planetype.
    ENDIF.

  ENDMETHOD.
  "에어라인의 갯수를 세는 메소드
  METHOD get_n_o_airplanes.
    rv_count = gv_n_o_airplanes.
  ENDMETHOD.
  METHOD set_attributes.
    mv_name = iv_name.
    mv_planetype = iv_planetype.

    gv_n_o_airplanes = gv_n_o_airplanes + 1.    "누적 변수
  ENDMETHOD.
  METHOD display_attributes.
    WRITE: / icon_ws_plane AS ICON,
           / 'Name of airplane', AT c_pos_i mv_name,
           / 'Type of airplane', AT c_pos_i mv_planetype,
           / 'Weight & Tank capacity', AT c_pos_i mv_weight, mv_tankcap.
  ENDMETHOD.
  METHOD display_n_o_airplanes.   "Static Method
    WRITE: /'Number of Airplanes', AT c_pos_i gv_n_o_airplanes.
  ENDMETHOD.
ENDCLASS.


DATA: go_airplane TYPE REF TO lcl_airplane,
      gt_airplane TYPE TABLE OF REF TO lcl_airplane.

START-OF-SELECTION.

  CALL METHOD lcl_airplane=>display_n_o_airplanes. "아랫줄이랑 같은 의미
*  lcl_airplane=>display_n_o_airplanes( ).            "call method 생략



  CREATE OBJECT go_airplane
  "constructor로 create 하는 구문, append 할 때 if문으로 subrc를 확인해줘야함
    EXPORTING
      iv_name         = 'LH Berlin'
      iv_planetype    = 'A321'
    EXCEPTIONS
      wrong_planetype = 1.
  "set_attribute로 call 하는 구문, append 할 때 if문 필요 없음
*  CALL METHOD go_airplane->set_attributes
*    EXPORTING
*      iv_name      = 'LH Berlin'
*      iv_planetype = 'A321'.
  IF sy-subrc = 0.
    APPEND go_airplane TO gt_airplane.
  ENDIF.


  CREATE OBJECT go_airplane
    EXPORTING
      iv_name         = 'AA New York'
      iv_planetype    = '747-400'
    EXCEPTIONS
      wrong_planetype = 1.

*  CALL METHOD go_airplane->set_attributes
*    EXPORTING
*      iv_name      = 'AA New York'
*      iv_planetype = '747-400'.
  IF sy-subrc = 0.
    APPEND go_airplane TO gt_airplane.
  ENDIF.

  CREATE OBJECT go_airplane
    EXPORTING
      iv_name         = 'US Hercules'
      iv_planetype    = 'A747-200F'
    EXCEPTIONS
      wrong_planetype = 1.
*  CALL METHOD go_airplane->set_attributes
*    EXPORTING
*      iv_name      = 'US Hercules'
*      iv_planetype = 'A747-200F'.
  IF sy-subrc = 0.
    APPEND go_airplane TO gt_airplane.
  ENDIF.

  LOOP AT gt_airplane INTO go_airplane.
    CALL METHOD go_airplane->display_attributes.
  ENDLOOP.

  DATA gv_count TYPE i.

  gv_count = lcl_airplane=>get_n_o_airplanes( ).
  WRITE: / 'Number of airplane', gv_count.
