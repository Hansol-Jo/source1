*&---------------------------------------------------------------------*
*& Include          ZBC405_ALV_A2502_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA gt_temp   TYPE TABLE OF gty_sbook.  "임시테이블 생성

  SELECT *
    FROM ztsbook_a25
    INTO CORRESPONDING FIELDS OF TABLE gt_sbook
   WHERE carrid IN so_car
     AND connid IN so_con
     AND fldate IN so_fld
     AND customid IN so_cus.

  "scustom table에 있는 정보를 취득
  IF sy-subrc = 0.   "빈공간을 가지고 돌면 퍼포먼스에 영향을 미치기 떄문에 데이터가 있는 것을 꼮 확인

    gt_temp = gt_sbook.   "sbook table 내용을 temp에 넣음
    DELETE gt_temp WHERE customid = space.

    SORT gt_temp BY customid.  "customid 순서로 정렬
    DELETE ADJACENT DUPLICATES FROM gt_temp COMPARING customid. "중복값 삭제

    SELECT *
      FROM ztscustom_a25
      INTO TABLE gt_custom
       FOR ALL ENTRIES IN gt_temp
      WHERE id = gt_temp-customid.
  ENDIF.

*----------------------------------------------------------------
  LOOP AT gt_sbook INTO gs_sbook.
*-------------------------------------------
    "Exception Handling
    IF gs_sbook-luggweight > 25.
      gs_sbook-light = 1.    "red
    ELSEIF gs_sbook-luggweight > 15.
      gs_sbook-light = 2.    "yellow
    ELSE.
      gs_sbook-light = 3.    "green
    ENDIF.
*--------------------------------------------
    "Set Row Color Set
    IF gs_sbook-class = 'F'.    "First Class
      gs_sbook-row_color = 'C710'.
    ENDIF.
*--------------------------------------------
    "'SMOKER'cell에 색 넣기
    IF gs_sbook-smoker = 'X'.
      gs_color-fname = 'SMOKER'.
      gs_color-color-col = col_negative.
      gs_color-color-int = '1'.
      gs_color-color-inv = '0'.
      APPEND gs_color TO gs_sbook-it_color.
    ENDIF.
*---------------------------------------------
    "scustom table의 정보 넣기
    READ TABLE gt_custom INTO gs_custom
          WITH KEY id = gs_sbook-customid.
    IF sy-subrc = 0.
      gs_sbook-telephone = gs_custom-telephone.
      gs_sbook-email = gs_custom-email.
    ENDIF.

    MODIFY gt_sbook FROM gs_sbook.
    CLEAR gs_sbook.
  ENDLOOP.
*-----------------------------------------------------------------
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
  gs_variant-variant = p_layout.
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
  gs_layout-sel_mode = 'D'.   "A, B, C, D
  gs_layout-excp_fname = 'LIGHT'.     "exception handling
  gs_layout-excp_led = 'X'.           "icon 모양이 하나짜리 뭉툭하게 바뀜
  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'X'.         "title도 포함해서 최대길이에 맞춰서 길이 압축

  gs_layout-info_fname = 'ROW_COLOR'.   "row color 필드 설정
  gs_layout-ctab_fname = 'IT_COLOR'.    "it_color가 색을 넣는 변수라는 것을 알려줌
  gs_layout-stylefname = 'BT'.
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
  gs_sort-up = 'X'.
  gs_sort-spos = 1.
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.
  gs_sort-fieldname = 'CONNID'.
  gs_sort-up = 'X'.
  gs_sort-spos = 2.
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.       "기존에 있던 내용을 지워야 어센딩했던게 안들어감
  gs_sort-fieldname = 'FLDATE'.
  gs_sort-down = 'X'.
  gs_sort-spos = 3.
  APPEND gs_sort TO gt_sort.
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
  "i_structure에서 사용하는 것 외에 다른 필드를 추가하거나, 기존 필드를 수정하고 싶을 때 사용
*----------------------------------------------
  "exception title 수정
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'LIGHT'.
  gs_fcat-coltext = 'Info'.
  APPEND gs_fcat TO gt_fcat.
*----------------------------------------------
  "smoker, invoice, cancel field 수정
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'SMOKER'.
  gs_fcat-checkbox = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'INVOICE'.
  gs_fcat-checkbox = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CANCELLED'.
  gs_fcat-checkbox = 'X'.
  gs_fcat-edit = p_edit.      "'X'.
  APPEND gs_fcat TO gt_fcat.
*------------------------------------------------
  "scustom table에 있는 email, telephone field를 추가
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'TELEPHONE'.
  gs_fcat-ref_table = 'ZTSCUSTOM_A25'.
  gs_fcat-ref_field = 'TELEPHONE'.
  gs_fcat-col_pos = '30'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'EMAIL'.
  gs_fcat-ref_table = 'ZTSCUSTOM_A25'.
  gs_fcat-ref_field = 'EMAIL'.
  gs_fcat-col_pos = '31'.
  APPEND gs_fcat TO gt_fcat.
*------------------------------------------------
  "emphasize 활용해서 field의 key 색상 변경, 수정 가능한 필드로 변경
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CUSTOMID'.
*  gs_fcat-emphasize = 'C400'.
  "catalog에서 edit하면 설정한 field만 열리고, layout에서 하면 전체가 다 열림
  gs_fcat-edit = p_edit.    "'X'
  APPEND gs_fcat TO gt_fcat.
*------------------------------------------------
ENDFORM.
*&---------------------------------------------------------------------*
*& Form customer_change_part
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> LS_MOD_CELLS
*&---------------------------------------------------------------------*
FORM customer_change_part  USING    p_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                    p_mod_cells TYPE lvc_s_modi.
  "type을 안적어주면 서로 다른 타입이라고 오류가 남 -> 타입도 함께 적어주기

  DATA: l_customid TYPE ztsbook_a25-customid,
        l_phone    TYPE ztscustom_a25-telephone,
        l_email    TYPE ztscustom_a25-email,
        l_name     TYPE ztscustom_a25-name.

  READ TABLE gt_sbook INTO gs_sbook INDEX p_mod_cells-row_id.

  "현재 cell의 value를 읽음
  CALL METHOD p_data_changed->get_cell_value
    EXPORTING
      i_row_id    = p_mod_cells-row_id    "내가 클릭한 셀의 row를 알려줌
*     i_tabix     =
      i_fieldname = 'CUSTOMID'   "내가 클릭한 셀의 field를 알려줌
    IMPORTING
      e_value     = l_customid.

  "값을 제대로 찾으면 아래 로직 실행
  IF l_customid IS NOT INITIAL.
    READ TABLE gt_custom INTO gs_custom
         WITH KEY id = l_customid.
    IF sy-subrc = 0.
      l_phone = gs_custom-telephone.
      l_email = gs_custom-email.
      l_name = gs_custom-name.
    ELSE.
      SELECT SINGLE telephone email name     "value table을 관리하고 있기 때문에 잘못된 정보를 사용자가 수정 입력하면 오류라고 뜸 -> 메시지 박스 안띄워도됨
        FROM ztscustom_a25
        INTO ( l_phone, l_email, l_name )
       WHERE id = l_customid.
    ENDIF.
  ELSE.
    CLEAR: l_email, l_phone, l_name.
  ENDIF.
  "cell의 정보를 수정함, 화면에 있는 내용을 수정
  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'TELEPHONE'
      i_value     = l_phone.

  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'EMAIL'
      i_value     = l_email.

  CALL METHOD p_data_changed->modify_cell
    EXPORTING
      i_row_id    = p_mod_cells-row_id
*     i_tabix     =
      i_fieldname = 'PASSNAME'
      i_value     = l_name.

  gs_sbook-email = l_email.
  gs_sbook-telephone = l_phone.
  gs_sbook-passname = l_name.

  MODIFY gt_sbook FROM gs_sbook INDEX p_mod_cells-row_id.   "인터널 테이블을 수정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_parts
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> LS_INS_CELLS
*&---------------------------------------------------------------------*
FORM insert_parts  USING rr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                         Rs_ins_cells TYPE lvc_s_moce.


  gs_sbook-carrid = so_car-low.
  gs_sbook-connid = so_con-low.
  gs_sbook-fldate = so_fld-low.


  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'CARRID'
      i_value     = gs_sbook-carrid.  "기본값을 넣어줌


  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'CONNID'
      i_value     = gs_sbook-connid.


  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'FLDATE'
      i_value     = gs_sbook-fldate.


  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'ORDER_DATE'
      i_value     = sy-datum.


  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'CUSTTYPE'
      i_value     = 'P'.

  CALL METHOD rr_data_changed->modify_cell
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = 'CLASS'
      i_value     = 'C'.


  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'CONNID'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'FLDATE'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'CUSTTYPE'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'CLASS'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'DISCOUNT'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'SMOKER'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'LUGGWEIGHT'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'WUNIT'.
  PERFORM modify_style USING rr_data_changed
                            Rs_ins_cells
                            'INVOICE'.
  PERFORM modify_style USING rr_data_changed
                            Rs_ins_cells
                            'FORCURAM'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'FORCURKEY'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'LOCCURAM'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'LOCCURKEY'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'ORDER_DATE'.
  PERFORM modify_style USING rr_data_changed
                             Rs_ins_cells
                             'AGENCYNUM'.

  MODIFY gt_sbook FROM gs_sbook INDEX Rs_ins_cells-row_id .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RR_DATA_CHANGED
*&      --> RS_INS_CELLS
*&      --> P_
*&---------------------------------------------------------------------*
FORM modify_style  USING  rr_data_changed  TYPE REF TO cl_alv_changed_data_protocol
                          Rs_ins_cells TYPE lvc_s_moce
                          VALUE(p_val).

  CALL METHOD rr_data_changed->modify_style
    EXPORTING
      i_row_id    = Rs_ins_cells-row_id
      i_fieldname = p_val
      i_style     = cl_gui_alv_grid=>mc_style_enabled.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS
*&---------------------------------------------------------------------*
FORM modify_check  USING p_ls_mod_cells TYPE lvc_s_modi.

  READ TABLE gt_sbook INTO gs_sbook INDEX p_ls_mod_cells-row_id.
  IF sy-subrc = 0.
    gs_sbook-modified = 'X'.
    MODIFY gt_sbook FROM gs_sbook INDEX p_ls_mod_cells-row_id.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_save .
  DATA: ins_sbook TYPE TABLE OF ztsbook_a25,
        wa_sbook  LIKE LINE OF ins_sbook.

  CLEAR ins_sbook.
  REFRESH ins_sbook.

  "Update
  LOOP AT gt_sbook INTO gs_sbook WHERE modified = 'X'.
    UPDATE ztsbook_a25
       SET customid = gs_sbook-customid
           cancelled = gs_sbook-cancelled
           passname = gs_sbook-passname
     WHERE carrid = gs_sbook-carrid
       AND connid = gs_sbook-connid
       AND fldate = gs_sbook-fldate
       AND bookid = gs_sbook-bookid.
  ENDLOOP.

  "Insert
  DATA: next_number TYPE s_book_id,
        ret_code    TYPE inri-returncode,
        l_tabix     LIKE sy-tabix.

  LOOP AT gt_sbook INTO gs_sbook WHERE bookid IS INITIAL.
    l_tabix = sy-tabix.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZBOOKIDA25'
        subobject               = gs_sbook-carrid
        ignore_buffer           = ' '
      IMPORTING
        number                  = next_number
        returncode              = ret_code
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      IF next_number IS NOT INITIAL.
        gs_sbook-bookid = next_number.

        MOVE-CORRESPONDING gs_sbook TO wa_sbook.

        APPEND wa_sbook TO ins_sbook.

        MODIFY gt_sbook FROM gs_sbook INDEX l_tabix TRANSPORTING bookid.   "현재의 l_tabix의 위치에 bookid만...?
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF ins_sbook IS NOT INITIAL.
    INSERT ztsbook_a25 FROM TABLE ins_sbook.
  ENDIF.
ENDFORM.
