class ZCLC125_0001 definition
  public
  final
  create public .

public section.

  methods GET_AIRLINE_INFO
    importing
      !PI_CARRID type SCARR-CARRID
    exporting
      !PE_CODE type CHAR1
      !PE_MSG type CHAR100
    changing
      !ET_AIRLINE type ZC1TT25001 .
protected section.
private section.
ENDCLASS.



CLASS ZCLC125_0001 IMPLEMENTATION.


  METHOD get_airline_info.

    IF pi_carrid IS INITIAL.
      pe_code = 'E'.
      pe_msg  = TEXT-e01.
      EXIT.
    ENDIF.

    SELECT carrid carrname currcode url
      FROM scarr
      INTO CORRESPONDING FIELDS OF TABLE et_airline
     WHERE carrid = pi_carrid.

    IF sy-subrc NE 0.
      pe_code = 'E'.
      pe_msg  = TEXT-e02.
      EXIT.
    ELSE.
      pe_code = 'S'.  "Return code로 성공 여부를 피드백 해줘야 함
    ENDIF.

  ENDMETHOD.
ENDCLASS.
