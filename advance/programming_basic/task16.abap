*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK16
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task16.
TABLES: zruby_sflight.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.
PARAMETERS: p_air TYPE zruby_sflight-carrid OBLIGATORY.
SELECT-OPTIONS: p_con FOR zruby_sflight-connid.
SELECTION-SCREEN END OF BLOCK b01.

AT SELECTION-SCREEN.
  IF  p_air IS NOT INITIAL.
    SELECT SINGLE zruby_sflight~carrid
      FROM zruby_sflight
      WHERE carrid = @p_air
      INTO @DATA(lv_air).
    IF sy-subrc <> 0.
      MESSAGE 'Airline Code is not exists. Please input again' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  SELECT
    zruby_sflight~carrid,
    zruby_sflight~connid,
    zruby_sflight~fldate,
    zruby_sflight~price,
    zruby_sflight~currency,
    zruby_sflight~seatsmax,
    zruby_sflight~seatsocc,
    zruby_sflight~seatsmax_b,
    zruby_sflight~seatsocc_b,
    zruby_sflight~seatsmax_f,
    zruby_sflight~seatsocc_f,
    zruby_scarr~carrname
  FROM zruby_sflight
  LEFT JOIN zruby_scarr
    ON zruby_sflight~carrid = zruby_scarr~carrid
  WHERE zruby_sflight~carrid = @p_air
    AND zruby_sflight~connid IN @p_con
  INTO TABLE @DATA(gt_result).

  IF sy-subrc <> 0.
    MESSAGE 'No data exists in Flight table' TYPE 'E'.
  ENDIF.

  FORMAT COLOR COL_HEADING.
  WRITE: /4 'Airline code', 20 'Airline name', 40 'Flight number', 60 'Flight date', 80 'Price', 100 'Vacant Seat Economy', 120 'Vacant Seat Bussiness', 140 'Vacant Seat First'.
  FORMAT COLOR OFF.
  LOOP AT gt_result INTO DATA(ls_result).
    DATA(lv_economy) = ls_result-seatsmax - ls_result-seatsocc.
    DATA(lv_business) = ls_result-seatsmax_b - ls_result-seatsocc_b.
    DATA(lv_first) = ls_result-seatsmax_f - ls_result-seatsocc_f.
    WRITE: / ls_result-carrid UNDER 'Airline code',
             ls_result-carrname UNDER 'Airline name',
             ls_result-connid UNDER 'Flight number',
             ls_result-fldate UNDER 'Flight date',
             ls_result-price CURRENCY ls_result-currency UNDER 'Price',
             lv_economy UNDER 'Vacant Seat Economy',
             lv_business UNDER 'Vacant Seat Bussiness',
             lv_first UNDER 'Vacant Seat First'.
  ENDLOOP.

  ULINE.
  WRITE: / 'Perform displaying prices of each Airline Code and Flight Number.'.

  DATA: gv_total TYPE i.

  loop at gt_result INTO ls_result
    GROUP BY ( airline_code = ls_result-carrid flight_number = ls_result-connid )
    ASSIGNING FIELD-SYMBOL(<fs_group>).
    gv_total = 0.

    loop at GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_sflight>).
      gv_total = gv_total + <fs_sflight>-price.
    ENDLOOP.
    WRITE: / 'Airline Code: ', <fs_group>-airline_code,
           / 'Flight Number: ', <fs_group>-flight_number,
           / 'Total price: ', gv_total.
    ULINE.
  ENDLOOP.
