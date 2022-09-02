*&---------------------------------------------------------------------*
*& Report ZRSA25_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrsa25_002.

TABLES sbuspart.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS pa_bus TYPE sbuspart-buspartnum OBLIGATORY.
  SELECT-OPTIONS so_cont FOR sbuspart-contact NO INTERVALS.

  SELECTION-SCREEN ULINE.   "중간에 line 추가

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 3(10) FOR FIELD pa_ta.
    SELECTION-SCREEN POSITION 1.   "변수명과 라디오버튼 위치 전환
    PARAMETERS pa_ta RADIOBUTTON GROUP ra1 DEFAULT 'X'.

    SELECTION-SCREEN COMMENT pos_low(10) FOR FIELD pa_fc.
    PARAMETERS pa_fc RADIOBUTTON GROUP ra1.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl1.

DATA: gs_sbus TYPE sbuspart,
      gt_sbus LIKE TABLE OF gs_sbus,
      gv_type TYPE sbuspart-buspatyp.
*--------IF문---------------------------------------------------
*IF pa_ta IS NOT INITIAL.
*IF pa_ta NE space.
*IF pa_ta EQ 'X'.
*IF pa_ta = 'X'.
*  SELECT buspartnum contact contphono buspatyp
*    FROM sbuspart
*    INTO CORRESPONDING FIELDS OF TABLE gt_sbus
*   WHERE buspartnum =  pa_bus
*     AND contact    IN so_cont
*     AND buspatyp = 'TA'.
*ELSE.
*  pa_fc = 'X'.
*  SELECT buspartnum contact contphono buspatyp
*    FROM sbuspart
*    INTO CORRESPONDING FIELDS OF TABLE gt_sbus
*   WHERE buspartnum =  pa_bus
*     AND contact    IN so_cont
*     AND buspatyp = 'FC'.
*ENDIF.
*---------CASE문-------------------------------------------------
*CASE 'X'.
*  WHEN pa_ta.
*    SELECT buspartnum contact contphono buspatyp
*      FROM sbuspart
*      INTO CORRESPONDING FIELDS OF TABLE gt_sbus
*     WHERE buspartnum =  pa_bus
*       AND contact    IN so_cont
*       AND buspatyp = 'TA'.
*  WHEN pa_fc.
*    SELECT buspartnum contact contphono buspatyp
*      FROM sbuspart
*      INTO CORRESPONDING FIELDS OF TABLE gt_sbus
*     WHERE buspartnum =  pa_bus
*       AND contact    IN so_cont
*       AND buspatyp = 'FC'.
*ENDCASE.

*-------select문 한번만 쓰기-------------------------------------
CASE 'X'.
  WHEN pa_ta.
    gv_type = 'TA'.
  WHEN pa_fc.
    gv_type = 'FC'.
ENDCASE.

SELECT buspartnum contact contphono buspatyp
  FROM sbuspart
  INTO CORRESPONDING FIELDS OF TABLE gt_sbus
 WHERE buspartnum =  pa_bus
   AND contact    IN so_cont
   AND buspatyp = gv_type.


cl_demo_output=>display_data( gt_sbus ).
