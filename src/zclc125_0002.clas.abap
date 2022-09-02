class ZCLC125_0002 definition
  public
  final
  create public .

public section.

  methods GET_METERIAL_TEXT
    importing
      !PI_MATNR type MATNR
    exporting
      !PE_CODE type CHAR1
      !PE_MSG type CHAR100
      !PE_MAKTX type MAKT-MAKTX .
protected section.
private section.
ENDCLASS.



CLASS ZCLC125_0002 IMPLEMENTATION.


  METHOD get_meterial_text.

    IF pi_matnr IS INITIAL.
      pe_code = 'E'.
      pe_msg  = TEXT-e01.
      EXIT.
    ENDIF.

    SELECT SINGLE maktx
      FROM makt
      INTO pe_maktx
     WHERE matnr = pi_matnr
       AND spras = sy-langu.

    IF sy-subrc NE 0.
      pe_code = 'E'.
      pe_msg  = TEXT-e02.
      EXIT.
    ELSE.
      pe_code = 'S'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
