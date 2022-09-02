*&---------------------------------------------------------------------*
*& Report ZRSA25_005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_005.

TABLES: sflight, sbook.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     pa_car   TYPE sflight-carrid OBLIGATORY DEFAULT 'AA'.
  SELECT-OPTIONS so_con   FOR sflight-connid  OBLIGATORY DEFAULT '0017'.
  PARAMETERS     pa_ptype TYPE sflight-planetype AS LISTBOX VISIBLE LENGTH 20 DEFAULT '747-400'.
  SELECT-OPTIONS so_bkid  FOR sbook-bookid.
SELECTION-SCREEN END OF BLOCK b1.

"parameter에 f4기능 추가

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_car.
  PERFORM f4_carrid.

  "select-options에 f4기능 추가 -> low와 high를 구분해서 적어줘야 함 / 인터널테이블이기 때문

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bkid-low.
  PERFORM f4_bookid.
*&---------------------------------------------------------------------*
*& Form f4_carrid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_carrid .

  DATA: BEGIN OF ls_carrid,
          carrid   TYPE scarr-carrid,
          carrname TYPE scarr-carrname,
          currcode TYPE scarr-currcode,
          url      TYPE scarr-url,
        END OF ls_carrid,

        lt_carrid LIKE TABLE OF ls_carrid.

  REFRESH lt_carrid.

  "f4 기능에 넣어줄 인터널테이블의 data 가져오기
  SELECT carrid carrname currcode url
  INTO CORRESPONDING FIELDS OF TABLE lt_carrid
  FROM scarr.

  "위에서 만든 인터널 테이블을 F4 기능으로 만들어주는 function
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'CARRID'        "파서블 엔트리에서 더블클릭했을 때 화면에 세팅될 값 / 선택하면 화면으로 세팅할 GT_DATA의 필드ID
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'PA_CARR'       "셀렉션 스크린의 어느 필드에 던져줄 건지 / 서치헬프 화면에서 선택한 데이터가 세팅될 화면의 필드ID
      window_title = 'Airline List'  "파서블 엔트리의 타이틀 / TEXT-T02 라고 텍스트 엘리먼트를 사용해줘도 됨
      value_org    = 'S'             "C로 하면 더블클릭이 안들어감, 반드시 S로 해주기
      display      = ''             "default=' '  ->  x를 해주면 f4기능이 비활성화 됨, edit 모드에서만 f4기능을 사용하도록 제한할 때 씀
                                     "선택한 데이터가 세팅될 화면의 필드에 세팅 되는 것을 막음 -> display전용으로 바뀜
    TABLES
      value_tab    = lt_carrid.      "내가 만든 f4 인터널테이블


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_bookid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_bookid .

ENDFORM.
