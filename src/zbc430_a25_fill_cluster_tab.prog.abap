*&---------------------------------------------------------------------*
*& Report  SAPBC430S_FILL_CLUSTER_TAB                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  ZBC430_A25_FILL_CLUSTER_TAB                                  .

DATA wa_scarr  TYPE scarr.
DATA wa_spfli  TYPE spfli.
DATA wa_flight TYPE sflight.
data wa_plane type saplane.

DATA my_error TYPE i VALUE 0.


START-OF-SELECTION.

* Replace # by Your user-number and remove all * from here

  DELETE FROM ztsaplane_a25.
*  DELETE FROM ztspfli_a25.
*  DELETE FROM ztsflight_a25.


  SELECT * FROM saplane INTO wa_plane.
    INSERT INTO ztsaplane_a25 VALUES wa_plane.
  ENDSELECT.

*  IF sy-subrc = 0.
*    SELECT * FROM spfli INTO wa_spfli.
*      INSERT INTO ztspfli_a25 VALUES wa_spfli.
*    ENDSELECT.
*
*    IF sy-subrc = 0.
*
*      SELECT * FROM sflight INTO wa_flight.
*        INSERT INTO ztsflight_a25 VALUES wa_flight.
*      ENDSELECT.
*      IF sy-subrc <> 0.
*        my_error = 1.
*      ENDIF.
*    ELSE.
*      my_error = 2.
*    ENDIF.
*  ELSE.
*    my_error = 3.
*  ENDIF.

  IF my_error = 0.
    WRITE / 'Data transport successfully finished'.
  ELSE.
    WRITE: / 'ERROR:', my_error.
  ENDIF.
