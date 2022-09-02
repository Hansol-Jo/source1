class ZCL_IM_BC425IM_A25 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_BOOK25 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BC425IM_A25 IMPLEMENTATION.


  method IF_EX_BADI_BOOK25~CHANGE_VLINE.
    c_pos = c_pos + 45.
  endmethod.


  METHOD if_ex_badi_book25~output.
    DATA: lv_name   TYPE s_custname,
          lv_STREET TYPE s_street.

    SELECT SINGLE name id
      FROM scustom
      INTO ( lv_name, lv_STREET )
     WHERE id = i_booking-customid.

    WRITE: lv_name, lv_STREET.
  ENDMETHOD.
ENDCLASS.
