REPORT  zbc425_iep_fm_template_a25.

PARAMETERS: netprice TYPE bc425_price,
            discount TYPE i.

DATA: fullprice TYPE bc425_price,
      discprice TYPE bc425_price.


* Calling the enhanced function module
...
CALL FUNCTION 'BC425_25_CALC_PRICE'
  EXPORTING
    im_netprice  = netprice
    im_discount  = discount
  IMPORTING
    ex_fullprice = fullprice
    ex_discprice = discprice.



WRITE: / 'Full price :',     18 fullprice,
       / 'Discount price :', 18 discprice.
