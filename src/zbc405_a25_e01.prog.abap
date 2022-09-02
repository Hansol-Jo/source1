*&---------------------------------------------------------------------*
*& Include          ZBC405_A25_E01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
CASE 'X'.
  WHEN pa_rad1.
   SELECT *
     FROM dv_flights
     INTO gs_info
    WHERE carrid IN so_carr
      AND connid IN so_conn
      AND fldate IN so_fldat.

     WRITE: / gs_info-carrid,
              gs_info-connid,
              gs_info-fldate,
              gs_info-countryfr,
              gs_info-cityfrom,
              gs_info-airpfrom,
              gs_info-countryto,
              gs_info-cityto,
              gs_info-airpto,
              gs_info-seatsmax,
              gs_info-seatsocc.
   ENDSELECT.
  WHEN pa_rad2.
   SELECT *
     FROM dv_flights
     INTO gs_info
    WHERE carrid IN so_carr[]
      AND connid IN so_conn[]
      AND fldate IN so_fldat[]
      AND countryto = dv_flights~countryfr.
     WRITE: / gs_info-carrid,
              gs_info-connid,
              gs_info-fldate,
              gs_info-countryfr,
              gs_info-cityfrom,
              gs_info-airpfrom,
              gs_info-countryto,
              gs_info-cityto,
              gs_info-airpto,
              gs_info-seatsmax,
              gs_info-seatsocc.
   ENDSELECT.
  WHEN pa_rad3.
   SELECT *
     FROM dv_flights
     INTO gs_info
    WHERE carrid IN so_carr[]
      AND connid IN so_conn[]
      AND fldate IN so_fldat[]
      AND countryto <> dv_flights~countryfr.
     WRITE: / gs_info-carrid,
              gs_info-connid,
              gs_info-fldate,
              gs_info-countryfr,
              gs_info-cityfrom,
              gs_info-airpfrom,
              gs_info-countryto,
              gs_info-cityto,
              gs_info-airpto,
              gs_info-seatsmax,
              gs_info-seatsocc.
   ENDSELECT.
ENDCASE.












*SELECT *
*  FROM dv_flights
*  INTO gs_flight.
*
*WRITE: /10(5) gs_flight-carrid,
*        16(5) gs_flight-connid,
*        22(10) gs_flight-fldate,
*         gs_flight-price CURRENCY gs_flight-currency,
*         gs_flight-currency.
*
*ENDSELECT.
