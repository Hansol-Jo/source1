class ZCL_EX_BC425_PX_BADI_A25 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_BC425_FILTER_BADI .
  interfaces IF_EX_BC425_00_PX_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EX_BC425_PX_BADI_A25 IMPLEMENTATION.


  method IF_BC425_FILTER_BADI~WRITE_ADDITIONAL_COLS.
    write : is_spfli-distance, is_spfli-DISTID.
  endmethod.
ENDCLASS.
