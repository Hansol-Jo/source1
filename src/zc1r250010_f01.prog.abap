*&---------------------------------------------------------------------*
*& Include          ZC1R250010_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init .

  so_pernr-low = '20220001'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_emp_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_emp_data .

  CLEAR   gs_emp.
  REFRESH gt_emp.

  SELECT pernr ename entdt gender depid
    FROM ztsa2504
    INTO CORRESPONDING FIELDS OF TABLE gt_emp
   WHERE pernr IN so_pernr.

*  IF sy-subrc NE 0.
*    MESSAGE e001.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_fcat .

  gs_layout-zebra      = 'X'.
*  gs_layout-cwidth_opt = 'X'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-stylefname = 'STYLE'.

  PERFORM set_fcat USING :
   'X'  'PERNR'      ' '  'ZTSA2504'  'PERNR'   'X' 10,
   ' '  'ENAME'      ' '  'ZTSA2504'  'ENAME'   'X' 20,
   ' '  'ENTDT'      ' '  'ZTSA2504'  'ENTDT'   'X' 10,
   ' '  'GENDER'     ' '  'ZTSA2504'  'GENDER'  'X' 5,
   ' '  'DEPID'      ' '  'ZTSA2504'  'DEPID'   'X' 8,
   ' '  'CARRID'     ' '  'ZTSA2504'  'CARRID'     'X' 10,
   ' '  'CARRNAME'   ' '  'SCARR'     'CARRNAME'   ' ' 20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat  USING pv_key
                     pv_fname
                     pv_text
                     pv_ref_t
                     pv_ref_f
                     pv_edit
                     pv_length.

  gt_fcat = VALUE #( BASE gt_fcat
                     (
                        key       = pv_key
                        fieldname = pv_fname
                        coltext   = pv_text
                        ref_table = pv_ref_t
                        ref_field = pv_ref_f
                        edit      = pv_edit
                        outputlen = pv_length
                     )
                   ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .

  IF gcl_container IS INITIAL.

    CREATE OBJECT gcl_container
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = gcl_container->dock_at_left
        extension = 3000.

    CREATE OBJECT gcl_grid
      EXPORTING
        i_parent = gcl_container.

    gs_variant-report = sy-repid.

    SET HANDLER : lcl_event_handler=>handle_data_changed    FOR gcl_grid,
                  lcl_event_handler=>handle_change_finished FOR gcl_grid.

    CALL METHOD gcl_grid->register_edit_event    "changed event 하기 위한 method
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.

    CALL METHOD gcl_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_emp
        it_fieldcatalog = gt_fcat.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_row .

  CLEAR  gs_emp.
  APPEND gs_emp TO gt_emp.

  PERFORM refresh_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_grid .

  gs_stable-row = 'X'.
  gs_stable-col = 'X'.

  CALL METHOD gcl_grid->refresh_table_display
    EXPORTING
      is_stable      = gs_stable
      i_soft_refresh = space.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_emp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_emp .

  DATA: lt_save  TYPE TABLE OF ztsa2504,
        lt_del   TYPE  TABLE OF ztsa2504,
        lv_cnt   TYPE i,   "commit을 한번만 하려고 만든 변수 / dbcnt의 값을 넣음
        lv_dml,
        lv_error.

  REFRESH: lt_save, lt_del.

  CALL METHOD gcl_grid->check_changed_data. "ALV변경사항을 ITAB에 반영하는 METHOD

  CLEAR: lv_error, lv_cnt, lv_dml.

  LOOP AT gt_emp INTO gs_emp.

    IF gs_emp-pernr IS INITIAL.  "필수 입력값 입력 여부 체크
      MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE 'E'.
      lv_error = 'X'.   "에러발생 했을 경우 저장 플로우 수행방지 위해서 값 세팅
      EXIT.             "현재 수행중인 루틴을 빠져나감 : 지금은 LOOP를 빠져나감
    ENDIF.

    "Delete
    IF gt_emp_del IS INITIAL.

      LOOP AT gt_emp_del INTO DATA(ls_del).

        lt_del = VALUE #( BASE lt_del
                          ( pernr = ls_del-pernr )
                        ).
      ENDLOOP.

      DELETE ztsa2504 FROM TABLE lt_del.

      IF sy-dbcnt > 0.
*        COMMIT WORK AND WAIT.
*        lv_cnt = lv_cnt + sy-dbcnt.
        lv_dml = 'X'.
      ENDIF.

    ENDIF.

    lt_save = VALUE #( BASE lt_save   "에러가 없는 데이터는 저장할 ITAB에 데이터 저장
                       (
                          pernr  = gs_emp-pernr
                          ename  = gs_emp-ename
                          entdt  = gs_emp-entdt
                          gender = gs_emp-gender
                          depid  = gs_emp-depid
                       )
                     ).
  ENDLOOP.

*  CHECK lv_error IS INITIAL.   "조건을 만족할 때만 아래 구문을 실행함 -> 아래 if문과 같은 기능 / 에러가 없으면 아래 로직 수행
  IF lv_error IS NOT INITIAL.   "에러가 있으면 현재 루틴을 빠져나감(EXIT)
    EXIT.
  ENDIF.

  IF lt_save IS NOT INITIAL.
    MODIFY ztsa2504 FROM TABLE lt_save.  "lt_save에 있는 데이터를 ztsa2504에 수정 또는 입력해라

    IF sy-dbcnt > 0.
*      COMMIT WORK AND WAIT.
*      MESSAGE s000 WITH TEXT-s01.
      lv_cnt += sy-dbcnt.
      lv_dml = 'X'.
    ENDIF.
  ENDIF.

  IF lv_cnt > 0.
    COMMIT WORK AND WAIT.
    MESSAGE s000 WITH TEXT-s01.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_row .

  REFRESH gt_rows.

  CALL METHOD gcl_grid->get_selected_rows  "사용자가 선택한 행의 정보를 가져옴
    IMPORTING
      et_index_rows = gt_rows.

  IF gt_rows IS INITIAL.   "행을 선택했는지 체크
    MESSAGE s000 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "선택된 행에 mark를 넣어서 지우는 방법
*  LOOP AT gt_rows INTO gs_row.
*
*    READ TABLE gt_emp INTO gs_emp INDEX gs_row-index.
*
*    IF sy-subrc EQ 0.
*      gs_emp-mark = 'X'.
*      MODIFY gt_emp FROM gs_emp INDEX gs_row-index
*      TRANSPORTING mark.
*    ENDIF.
*
*  ENDLOOP.
*
*  DELETE gt_emp WHERE mark = 'X'.
*  DELETE gt_emp WHERE mark IS NOT INITIAL.


  "선택된 행을 내림차순으로 정렬해서 뒤에서부터 지우는 방법  -> 이게 퍼포먼스가 더 좋음
  SORT gt_rows BY index DESCENDING.   "지우기로 선택한 row들을 내림차순으로 정렬함 -> 뒤에서부터 지워야 제대로 행이 지워짐

  LOOP AT gt_rows INTO gs_row.

    "ITAP에서 삭제하기 전에 DB TABLE에서도 삭제해야 하므로 삭제 대상을 따로 보관
    READ TABLE gt_emp INTO gs_emp INDEX gs_row-index.   "선택한 행의 정보 조회

    IF sy-subrc = 0.

      APPEND gs_emp TO gt_emp_del.    "삭제 대상을 삭제 ITAB에 보관

    ENDIF.

    DELETE gt_emp INDEX gs_row-index.   "사용자가 선택한 행을 직접 삭제

  ENDLOOP.


  PERFORM refresh_grid.  "변경된 ITAB을 ALV에 반영


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_style .

  DATA: lv_tabix TYPE sy-tabix,
        ls_style TYPE lvc_s_styl.

*    ls_style-fieldname = 'PERNR'.
*    ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
  ls_style = VALUE #( fieldname = 'PERNR'
                      style     = cl_gui_alv_grid=>mc_style_disabled ).

  "table에서 가지고 온 데이터의 pk 변경 방지를 위해서 편집금지 모드를 만듦
  LOOP AT gt_emp INTO gs_emp.
    lv_tabix = sy-tabix.

    REFRESH gs_emp-style.

    APPEND ls_style TO gs_emp-style.

    MODIFY gt_emp FROM gs_emp INDEX lv_tabix
    TRANSPORTING style.
  ENDLOOP.

ENDFORM.
*FORM set_style_table.
*
*  DATA: lv_tabix TYPE sy-tabix,
*        ls_style TYPE lvc_s_styl.
*
*"구문법
**    ls_style-fieldname = 'PERNR'.
**    ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
**    APPEND ls_sytle TO lt_style.
*
*"신문법: 스트럭쳐 사용시
**  ls_style = VALUE #( fieldname = 'PERNR'
**                      style     = cl_gui_alv_grid=>mc_style_disabled ).
**    APPEND ls_sytle TO lt_style.
*
*  lt_style = VALUE #(
*                      (
*                        fieldname = 'PERNR'
*                        style     = cl_gui_alv_grid=>mc_style_disabled
*                      )
*                    ).
*
*  "table에서 가지고 온 데이터의 pk 변경 방지를 위해서 편집금지 모드를 만듦
*  LOOP AT gt_emp INTO gs_emp.
*    lv_tabix = sy-tabix.
*
*    REFRESH gs_emp-style.
*
*    APPEND LINES OF lt_style TO gs_emp-style.
**    gs_emp-style = lt_style.
**    MOVE-CORRESPONDING lt_style TO gs_emp-style.
*
*    MODIFY gt_emp FROM gs_emp INDEX lv_tabix
*    TRANSPORTING style.
*  ENDLOOP.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM handle_data_changed  USING pcl_data_changed TYPE REF TO
                                cl_alv_changed_data_protocol.

  LOOP AT pcl_data_changed->mt_mod_cells INTO DATA(ls_modi).

*    READ TABLE gt_emp INTO gs_emp INDEX ls_modi-row_id.
*
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ENDIF.
*
*    SELECT SINGLE carrname
*      INTO gs_emp-carrname
*      FROM scarr
*     WHERE carrid = ls_modi-value.   "새로운 값을 가지고 있는 ls_modi에서 값을 비교해줘야함
*
*    IF sy-subrc NE 0.
*      CLEAR gs_emp-carrname.
*    ENDIF.
*
*    MODIFY gt_emp FROM gs_emp INDEX ls_modi-row_id
*    TRANSPORTING carrname.

  ENDLOOP.

*  PERFORM refresh_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_change_finished
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM handle_change_finished  USING    pv_modified
                                      pt_good_cells TYPE lvc_t_modi.

  LOOP AT pt_good_cells INTO DATA(ls_modi).

    READ TABLE gt_emp INTO gs_emp INDEX ls_modi-row_id.

    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    SELECT SINGLE carrname
      INTO gs_emp-carrname
      FROM scarr
     WHERE carrid = gs_emp-carrid. "ls_modi-value.   "새로운 값을 가지고 있는 ls_modi에서 값을 비교해줘야함

    IF sy-subrc NE 0.
      CLEAR gs_emp-carrname.
    ENDIF.

    MODIFY gt_emp FROM gs_emp INDEX ls_modi-row_id
    TRANSPORTING carrname.

  ENDLOOP.

  PERFORM refresh_grid.

ENDFORM.
