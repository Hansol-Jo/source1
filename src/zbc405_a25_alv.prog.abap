*&---------------------------------------------------------------------*
*& Report ZBC405_A25_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc405_a25_alv.

TYPES: BEGIN OF typ_flt.
         INCLUDE TYPE sflight.
TYPES:   changes_possible TYPE icon-id,
         total_occ        TYPE i,
         tankcap          TYPE saplane-tankcap,
         cap_unit         TYPE saplane-cap_unit,
         weight           TYPE saplane-weight,
         wei_unit         TYPE saplane-wei_unit,
         btn_text         TYPE c LENGTH 10,
         light            TYPE c LENGTH 1,
         row_color        TYPE c LENGTH 4,   "row-color: row-color 값을 가지고 있는 필드는 색을 변경함
         it_color         TYPE lvc_t_scol,    "cell 단위의 color를 담는 변수를 선언
         it_styl          TYPE lvc_t_styl,
       END OF typ_flt.

DATA: gt_flt TYPE TABLE OF typ_flt, "sflight,
      gs_flt LIKE LINE OF gt_flt.
DATA ok_code LIKE sy-ucomm.

"   ALV DATA 선언 - work area
DATA: go_container TYPE REF TO cl_gui_custom_container,   "class를 reference 함
      go_alv_grid  TYPE REF TO cl_gui_alv_grid,            "class를 reference 함
      gv_variant   TYPE disvariant,       "variant
      gv_save      TYPE c LENGTH 1,          "variant
      gs_layout    TYPE lvc_s_layo,        "layout
      gt_sort      TYPE lvc_t_sort,          "sort
      gs_sort      LIKE LINE OF gt_sort,     "sort
      gs_color     TYPE lvc_s_scol,         "cell color
      gt_exct      TYPE ui_functions,        "toolbar exclude
      gt_fcat      TYPE lvc_t_fcat,          "field category
      gs_fcat      LIKE LINE OF gt_fcat,     "field category
      gs_styl      TYPE lvc_s_styl.          "style

"Refresh Parameters에 들어가는 변수
DATA: gs_stable       TYPE lvc_s_stbl,
      gv_soft_refresh TYPE abap_bool.

INCLUDE ZBC405_A25_ALV_class.                               "Class

"   Selection-Screen
SELECT-OPTIONS: so_car FOR gs_flt-carrid MEMORY ID car,
                so_con FOR gs_flt-connid MEMORY ID con,
                so_dat FOR gs_flt-fldate.

SELECTION-SCREEN SKIP 1.
PARAMETERS: p_date TYPE sy-datum DEFAULT '20201201'.
PARAMETERS: pa_lv TYPE disvariant-variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_lv.  "pa_lv에 F4기능 이벤트를 추가 -> variant로 어떤 것을 저장했는지 f4기능 만들기

  gv_variant-report = sy-cprog.
  "gv_variant의 프로그램(report)에 현재 프로그램을 넣어줌
  "29번 라인은 이벤트를 타야지만 실행됨, f4기능을 사용하지 않으면 안탐 -> f4기능을 사용하지 않을 경우에도 프로그램을 알려줘야 되기 때문에 스크린에서도 또 알려줌
  "두번 안쓰고 한번만 쓰고 싶으면 initialization에서 적어주면 됨

  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load     = 'F'   "S: save, F:f4, L: load
    CHANGING
      cs_variant      = gv_variant
    EXCEPTIONS
      not_found       = 1
      wrong_input     = 2
      fc_not_complete = 3
      OTHERS          = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here

  ELSE.
    pa_lv = gv_variant-variant.
  ENDIF.

START-OF-SELECTION.

  PERFORM get_data.

  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA: utab TYPE ui_functions.

  "save와 delete 버튼을 전부 다 숨기는 방법
* APPEND 'SAVE' TO utab.
* APPEND 'DELE' TO utab.
* SET PF-STATUS 'S100' EXCLUDING utab.

  SET PF-STATUS 'S100' EXCLUDING 'SAVE'.  "SAVE 버튼을 숨김
  SET TITLEBAR 'T100' WITH sy-datum sy-uname.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_alv_grid->free.
      CALL METHOD go_container->free.

      FREE: go_alv_grid, go_container.   "메모리 확보를 위해 release 해줌, 안해줘도 문제는 없지만 잔여? 아무튼 그런걸 없애줌
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_object OUTPUT.
  "cl_gui_custom_container    [class]
  IF go_container IS INITIAL.
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'MY_CONTROL_AREA'
      EXCEPTIONS
        OTHERS         = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    "cl_gui_alv_grid    [class]
    CREATE OBJECT go_alv_grid
      EXPORTING
        i_parent = go_container
      EXCEPTIONS
        OTHERS   = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM make_variant.
    PERFORM make_layout.
    PERFORM make_sort.
    PERFORM make_fieldcatalog.

    "  APPLICATION TOOLBAR EXCLUDING
    APPEND cl_gui_alv_grid=>mc_fc_filter TO gt_exct.   "=>: class의 attribute를 직접 참조한다는 뜻
    APPEND cl_gui_alv_grid=>mc_fc_info TO gt_exct.

*  APPEND cl_gui_alv_grid=>mc_fc_excl_all to gt_exct.   "전체 toolbar를 사라지게 함

    SET HANDLER: lcl_handler=>on_doubleclick FOR go_alv_grid,
                 lcl_handler=>on_hotspot FOR go_alv_grid,
                 lcl_handler=>on_toolbar FOR go_alv_grid,
                 lcl_handler=>on_user_command FOR go_alv_grid,
                 lcl_handler=>on_button_click FOR go_alv_grid,
                 lcl_handler=>on_context_menu_request FOR go_alv_grid,
                 lcl_handler=>on_before_user_com FOR go_alv_grid,
                 lcl_handler=>on_data_changed FOR go_alv_grid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
*       i_buffer_active               =
*       i_bypassing_buffer            =
*       i_consistency_check           =
        i_structure_name              = 'SFLIGHT'     "어떤 internal table에서 data를 가져오는지
        is_variant                    = gv_variant    "variant를 어디에 저장할 건지
        i_save                        = gv_save       "variant 저장 타입 (A, X, U, Space)
        i_default                     = 'X'           "variant defalut 설정, 빈공간으로 놓으면 default를 설정할 수 있는 박스가 사라짐
        is_layout                     = gs_layout     "layout 설정
*       is_print                      =
*       it_special_groups             =
        it_toolbar_excluding          = gt_exct "TABLE을 만들어서 여기 넣으면 툴바를 숨길 수 있음
*       it_hyperlink                  =
*       it_alv_graphics               =
*       it_except_qinfo               =
*       ir_salv_adapter               =
      CHANGING
        it_outtab                     = gt_flt
        it_fieldcatalog               = gt_fcat  "structure_name에 들어있는 변수가 fieldcatalog에 또 나올 경우 fieldcatalog에 있는 내용으로 수정됨
        it_sort                       = gt_sort
*       it_filter                     =
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
*      Implement suitable error handling here
    ENDIF.

  ELSE.
    "go_alv_grid->refresh_table_display 해주면 좋음 : pai가 전부 끝나도 alv화면이 처음으로 돌아가지 않게 해줌
*   ON CHANGE OF gt_flt.    "on - endon 은 넣어줘도 되고 안넣어줘도 됨
    gv_soft_refresh = 'X'.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD go_alv_grid->refresh_table_display
      EXPORTING
        is_stable      = gs_stable
        i_soft_refresh = gv_soft_refresh
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
*      Implement suitable error handling here
    ENDIF.
*   ENDON.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_flt
   WHERE carrid IN so_car
     AND connid IN so_con
     AND fldate IN so_dat.

  "신호등 설정
  LOOP AT gt_flt INTO gs_flt.
    IF gs_flt-seatsocc < 5.
      gs_flt-light = 1.   "red
    ELSEIF gs_flt-seatsocc < 100.
      gs_flt-light = 2.   "yellow
    ELSE.
      gs_flt-light = 3.    "green
    ENDIF.

    "ROW COLOR 변경
    IF gs_flt-fldate+4(2) = sy-datum+4(2).
      gs_flt-row_color = 'C110'.  "Color number + intensified on(1) or off(0) + inverse on(1) or off(0)
    ENDIF.

    "CELL COLOR 변경
    IF gs_flt-planetype = '747-400'.
      gs_color-fname = 'PLANETYPE'.
      gs_color-color-col = col_total.   "노란색
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_flt-it_color.
    ENDIF.

    IF gs_flt-seatsocc_b = 0.
      gs_color-fname = 'SEATSOCC_B'.
      gs_color-color-col = col_negative.  "빨간색
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_flt-it_color.
    ENDIF.

    IF gs_flt-fldate < p_date.
      gs_flt-changes_possible = icon_space.
    ELSE.
      gs_flt-changes_possible = icon_okay.
    ENDIF.

    IF gs_flt-seatsmax_b = gs_flt-seatsocc_b.
      gs_flt-btn_text = 'FullSeats!'.

      gs_styl-fieldname = 'BTN_TEXT'.
      gs_styl-style = cl_gui_alv_grid=>mc_style_button.
      APPEND gs_styl TO gs_flt-it_styl.
    ENDIF.

    SELECT SINGLE tankcap cap_unit weight wei_unit
    FROM saplane
    INTO CORRESPONDING FIELDS OF gs_flt
   WHERE planetype = gs_flt-planetype.

    MODIFY gt_flt FROM gs_flt.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_variant .
  "   VARIANT
  gv_variant-report = sy-cprog. "프로그램 이름을 넣어줌
  gv_variant-variant = pa_lv.
  gv_save = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_layout .
  "   LAYOUT
  gs_layout-zebra = 'X'.  "layout을 얼룩말 무늬로 설정함
  gs_layout-cwidth_opt = 'X'.    "column의 너비를 변수의 length에 맞춰서 자동 조정 / fieldcat col_opt 역할, col_opt는 지정한 field만 조정됨
  gs_layout-sel_mode = 'D'.
  "A: Multiple Colunm & Row 선택 가능 & Selection 버튼 있음 & cell 선택 가능 & Multiple cell 선택 불가,
  "B: Multiple Colunm 선택 & Selection 버튼 없음,
  "C: Multiple colunm & row 선택 가능 & Selection 버튼 없음 & cell 선택 불가,
  "D: 전부 다 가능,
  "Space

  gs_layout-excp_fname = 'LIGHT'.   "exception handling field 설정 - > 세개짜리 신호등 설정
  gs_layout-excp_led = 'X'.     "하나짜리 신호등으로 변경 (신호등 모양 변경)

  gs_layout-info_fname = 'ROW_COLOR'.  "row table name을 넣어줌
  gs_layout-ctab_fname = 'IT_COLOR'.   "color table name을 넣어줌

  gs_layout-stylefname = 'IT_STYL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_sort .
  CLEAR gs_sort.
  gs_sort-fieldname = 'CARRID'.
  gs_sort-up = 'X'.   "오름차순
  gs_sort-spos = 1.   "sort 순서
  APPEND gs_sort TO gt_sort.

  gs_sort-fieldname = 'CONNID'.
  gs_sort-up = 'X'.
  gs_sort-spos = 2.
  APPEND gs_sort TO gt_sort.

  gs_sort-fieldname = 'FLDATE'.
  gs_sort-down = 'X'.  "내림차순
  gs_sort-spos = 3.
  APPEND gs_sort TO gt_sort.

*  gs_sort-fieldname = 'PLANETYPE'.
*  gs_sort-up = 'X'.  "내림차순
*  gs_sort-spos = 4.
*  APPEND gs_sort TO gt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_fieldcatalog .
  gs_fcat-fieldname = 'LIGHT'.
  gs_fcat-coltext = 'Info'.
  APPEND gs_fcat TO gt_fcat.

*  CLEAR gs_fcat.
*  gs_fcat-fieldname = 'PRICE'.
*  gs_fcat-hotspot = 'X'.       "밑줄 생기고 클릭할 수 있게 손가락 모양이 나옴
**  gs_fcat-no_out = 'X'.       "field를 숨김
*  gs_fcat-emphasize = 'C610'.  "field 강조
*  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CARRID'.
*  gs_fcat-hotspot = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CHANGES_POSSIBLE'.
  gs_fcat-coltext = 'Chang.Poss'.
  gs_fcat-col_opt = 'X'.
  gs_fcat-col_pos = 5.  "위치를 지정해주지 않으면 default는 0 -> 맨 첫번째 field로 감
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'SEATSOCC'.
  gs_fcat-do_sum = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PAYMENTSUM'.
  gs_fcat-no_out = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PRICE'.
  gs_fcat-col_opt = 'X'.
*  gs_fcat-edit = 'X'.  "필드 전체가 입력, 변경할 수 있게 됨
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'BTN_TEXT'.
  gs_fcat-coltext = 'Status'.
  gs_fcat-col_pos = 12.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'TANKCAP'.
  gs_fcat-ref_table = 'SAPLANE'.
  gs_fcat-ref_field = 'TANKCAP'.
  gs_fcat-qfieldname = 'CAP_UNIT'. "qfieldname: 단위를 나타내는 필드의 이름, cfieldname: 통화를 나타내는 필드의 이름
  gs_fcat-col_pos = 20.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CAP_UNIT'.
  gs_fcat-ref_table = 'SAPLANE'.
  gs_fcat-ref_field = 'CAP_UNIT'.
  gs_fcat-qfieldname = 'CAP_UNIT'.
  gs_fcat-col_pos = 21.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'WEIGHT'.
  gs_fcat-ref_table = 'SAPLANE'.
  gs_fcat-ref_field = 'WEIGHT'.
  gs_fcat-qfieldname = 'WEI_UNIT'.
  gs_fcat-col_pos = 22.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'WEI_UNIT'.
  gs_fcat-ref_table = 'SAPLANE'.
  gs_fcat-ref_field = 'WEI_UNIT'.
  gs_fcat-qfieldname = 'WEI_UNIT'.
  gs_fcat-col_pos = 23.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PLANETYPE'.
  gs_fcat-edit = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'TOTAL_OCC'.
  gs_fcat-coltext = 'Total Occupied'.
  gs_fcat-col_opt = 'X'.
  gs_fcat-col_pos = 10.
  APPEND gs_fcat TO gt_fcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form planetype_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> LS_MOD_CELLS
*&---------------------------------------------------------------------*
FORM planetype_change  USING    p_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                p_mod_cells TYPE lvc_s_modi.
*--- 변수 선언-------------------------------------------------
  DATA: l_planetype TYPE sflight-planetype,
        l_occ_e     TYPE sflight-seatsmax,
        l_occ_b     TYPE sflight-seatsmax_b,
        l_occ_f     TYPE sflight-seatsmax_f.
  DATA: gt_plane TYPE TABLE OF saplane,
        gs_plane LIKE LINE OF gt_plane.

*--- 선택한 셀의 row id 정보를 이용하여 read table------------------
  READ TABLE gt_flt INTO gs_flt INDEX p_mod_cells-row_id.

*--- 선택한 셀의 value 정보 읽기----------------------------------
  CALL METHOD p_data_changed->get_cell_value
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'PLANETYPE'
    IMPORTING
      e_value     = l_planetype.

*--- data 가져오기----------------------------------------
  IF l_planetype IS NOT INITIAL.
    READ TABLE gt_plane INTO gs_plane WITH KEY planetype = l_planetype.
    IF sy-subrc = 0.
      l_occ_e = gs_plane-seatsmax.
      l_occ_b = gs_plane-seatsmax_b.
      l_occ_b = gs_plane-seatsmax_f.
    ELSE.
      SELECT SINGLE seatsmax seatsmax_b seatsmax_f
        FROM saplane
        INTO ( l_occ_e, l_occ_b, l_occ_f )
       WHERE planetype = l_planetype.
    ENDIF.
  ELSE.
    CLEAR: l_occ_e, l_occ_b, l_occ_f.
  ENDIF.

*---셀의 내용 수정-----------------------------------------------
  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'SEATSMAX'
      i_value     = l_occ_e.

  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'SEATSMAX_B'
      i_value     = l_occ_b.

  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'SEATSMAX_F'
      i_value     = l_occ_f.

  MODIFY gt_flt FROM gs_flt INDEX p_mod_cells-row_id.

ENDFORM.
