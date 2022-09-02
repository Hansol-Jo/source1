*&---------------------------------------------------------------------*
*& Report ZBC405_OM_A25
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc405_om_a25.

TABLES spfli.

SELECT-OPTIONS: so_car FOR spfli-carrid MEMORY ID car,
                so_con FOR spfli-connid MEMORY ID con.

DATA: gt_spfli TYPE TABLE OF spfli,
      gs_spfli LIKE LINE OF gt_spfli.

DATA: go_alv TYPE REF TO cl_salv_table,
      go_func TYPE REF TO cl_salv_functions_list,
      go_disp TYPE REF TO cl_salv_display_settings,
      go_columns TYPE REF TO cl_salv_columns_table,   "field catalog 역할을 해주는 class
      go_column TYPE REF TO cl_salv_column_table,
      go_cols TYPE REF TO cl_salv_column,   "get columns
      go_layout TYPE REF TO cl_salv_layout,
      go_selc TYPE REF TO cl_salv_selections.


START-OF-SELECTION.

  SELECT *
    FROM spfli
    INTO CORRESPONDING FIELDS OF TABLE gt_spfli
   WHERE carrid IN so_car
     AND connid IN so_con.

"get: salv의 상태를 알려주는 오브젝트를 리턴 -> 전부 다 클래스 타입  (cl_salv_table의 methods)
   TRY.   "salv를 쓸 때 의도치 않은 덤프를 방지하는 구문 - try-catch-endtry  (가능하면 쓰는 게 좋음)
   CALL METHOD cl_salv_table=>factory
     EXPORTING
       list_display   = ''      "IF_SALV_C_BOOL_SAP=>FALSE   "화면이 어떻게 보이는지, X로 설정하면 리스트 형식으로 테이블이 바뀜, 공란이면 기본 alv화면
*       r_container    =
*       container_name =
     IMPORTING
       r_salv_table   = go_alv   "선언한 go_alv를 위한 인스턴스를 만들어 주는것
     CHANGING
       t_table        = gt_spfli  "출력할 인터널 테이블
       .
     CATCH cx_salv_msg.
   ENDTRY.

"go_func: salv에 펑션으로 현재의 버튼들의 정보를 알려줌 이것만 가져오면 버튼이 비어있는 상태이기 때문에 functions_list class 에 있는 filter, sort 오브젝트를 추가해줌
   CALL METHOD go_alv->get_functions
     RECEIVING
       value  = go_func.     "function을 go_func에 넣어줌

*--toolbar setting
*---cl_salv_functions_list의 methods
*    CALL METHOD go_func->set_filter        "filter 버튼 생성
**      EXPORTING
**        value  = IF_SALV_C_BOOL_SAP=>TRUE
*        .
*    CALL METHOD go_func->set_sort_asc      "ascending 버튼 생성
**      EXPORTING
**        value  = IF_SALV_C_BOOL_SAP=>TRUE
*        .
*    CALL METHOD go_func->set_sort_desc     "descending 버튼 생성
**      EXPORTING
**        value  = IF_SALV_C_BOOL_SAP=>TRUE
*        .
   CALL METHOD go_func->set_all    "전체 버튼 생성
*     EXPORTING
*       value  = IF_SALV_C_BOOL_SAP=>TRUE
        .

*--display setting
   CALL METHOD go_alv->get_display_settings
     RECEIVING
       value  = go_disp.
*--salv title
   CALL METHOD go_disp->set_list_header
     EXPORTING
       value  = 'SALV DEMO'.
*--zebra pattern
   CALL METHOD go_disp->set_striped_pattern
     EXPORTING
       value  = 'X'.

*--columns의 정보를 가져옴
   CALL METHOD go_alv->get_columns
     RECEIVING
       value  = go_columns.
*--cloumns를 length에 맞게 압축  = col_opt 기능과 같음
   CALL METHOD go_columns->set_optimize
*     EXPORTING
*       value  = IF_SALV_C_BOOL_SAP~TRUE
       .
*--mandt의 columns 정보를 찾기
   TRY.
   CALL METHOD go_columns->get_column
     EXPORTING
       columnname = 'MANDT'
     RECEIVING
       value      = go_cols.
     CATCH cx_salv_not_found.
   ENDTRY.

*--column을 숨겨주는 기능
*-- 1번 부모-자식이 다를 때
*go_column ?= go_cols.
*  "casting: 부모-자식 간 type이 달라도 구문 오류 없이 인정해줌
*  "set_technical을 하려면 원래 go_cols에 받아야 하는데, 같은 부모 밑에 있는 go_column에 넣어도 된다고 인정해줘서 아래 method에 go_column에 넣을 수 있게 해줌
*CALL METHOD go_column->set_technical
**  EXPORTING
**    value  = IF_SALV_C_BOOL_SAP=>TRUE
*    .
*-- 2번 부모-자식이 같을 때
CALL METHOD go_cols->set_technical
*  EXPORTING
*    value  = IF_SALV_C_BOOL_SAP=>TRUE
    .

*--fltime columns 정보 취득
TRY.
CALL METHOD go_columns->get_column
  EXPORTING
    columnname = 'FLTIME'
  RECEIVING
    value      = go_cols.
    .
  CATCH cx_salv_not_found.
ENDTRY.

*-- set color
DATA: g_color TYPE lvc_s_colo.
go_column ?= go_cols.   "casting 구문, 부모가 다르더라도 method 사용가능

g_color-col = '5'.
g_color-int = '1'.
g_color-inv = '0'.

CALL METHOD go_column->set_color
  EXPORTING
    value  = g_color.

*--fltime columns 정보 취득
TRY.
CALL METHOD go_columns->get_column
  EXPORTING
    columnname = 'COUNTRYFR'
  RECEIVING
    value      = go_cols.
    .
  CATCH cx_salv_not_found.
ENDTRY.

*-- set color
DATA: g_color2 TYPE lvc_s_colo.
go_column ?= go_cols.

g_color2-col = '6'.
g_color2-int = '1'.
g_color2-inv = '0'.

CALL METHOD go_column->set_color
  EXPORTING
    value  = g_color2.

*--variant 설정
*---layout 설정
CALL METHOD go_alv->get_layout
  RECEIVING
    value  = go_layout.
*---layout key 가져오기
DATA g_program TYPE salv_s_layout_key.
g_program-report = sy-cprog.

CALL METHOD go_layout->set_key
  EXPORTING
    value  = g_program.
*---variant 기능? 설정 (i_save = 'A' 과 같은 기능)
CALL METHOD go_layout->set_save_restriction
  EXPORTING
    value  = if_salv_c_layout=>restrict_none.
*---set variant default
CALL METHOD go_layout->set_default
  EXPORTING
    value  = 'X'.

*--select mode
CALL METHOD go_alv->get_selections
  RECEIVING
    value  = go_selc.

CALL METHOD go_selc->set_selection_mode
  EXPORTING
    value  = if_salv_c_selection_mode=>row_column.   "none, cell, row_column, single, multiple 다섯 가지 설정 있음 / 중복도 가능

CALL METHOD go_selc->set_selection_mode
  EXPORTING
    value  = if_salv_c_selection_mode=>cell.

   CALL METHOD go_alv->display.   "display는 항상 하단에 위치
