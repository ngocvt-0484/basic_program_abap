*&---------------------------------------------------------------------*
*& Report ZSYR002_RUBY_TASK2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr002_ruby_task2.
TABLES: zruby_sflight.

CLASS lcl_sflight DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_air TYPE zruby_sflight-carrid
                            iv_con TYPE ztt_ruby_connid_rang,
      check_validate,
      print_info,
      print_info_group.
  PRIVATE SECTION.
    TYPES: BEGIN OF lty_sflight,
             carrid     TYPE zruby_sflight-carrid,
             connid     TYPE zruby_sflight-connid,
             fldate     TYPE zruby_sflight-fldate,
             price      TYPE zruby_sflight-price,
             currency   TYPE zruby_sflight-currency,
             seatsmax   TYPE zruby_sflight-seatsmax,
             seatsocc   TYPE zruby_sflight-seatsocc,
             seatsmax_b TYPE zruby_sflight-seatsmax_b,
             seatsocc_b TYPE zruby_sflight-seatsocc_b,
             seatsmax_f TYPE zruby_sflight-seatsmax_f,
             seatsocc_f TYPE zruby_sflight-seatsocc_f,
             carrname   TYPE zruby_scarr-carrname,
           END OF lty_sflight.
    DATA:
      mv_air    TYPE zruby_sflight-carrid,
      mv_con    TYPE ztt_ruby_connid_rang,
      mv_result TYPE TABLE OF lty_sflight.
ENDCLASS.

CLASS lcl_sflight IMPLEMENTATION.
  METHOD constructor.
    mv_air = iv_air.
    mv_con = iv_con.
  ENDMETHOD.

  METHOD check_validate.
    IF mv_air IS NOT INITIAL.
      SELECT SINGLE carrid
        FROM zruby_sflight
        WHERE carrid = @mv_air
        INTO @DATA(lv_air).
      IF sy-subrc <> 0.
        MESSAGE 'Airline Code is not exists. Please input again' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD print_info.
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
   WHERE zruby_sflight~carrid = @mv_air
     AND zruby_sflight~connid IN @mv_con
   INTO TABLE @mv_result.

    IF sy-subrc <> 0.
      MESSAGE 'No data exists in Flight table' TYPE 'E'.
    ENDIF.

    FORMAT COLOR COL_HEADING.
    WRITE: /4 'Airline code', 20 'Airline name', 40 'Flight number', 60 'Flight date', 80 'Price', 100 'Vacant Seat Economy', 120 'Vacant Seat Bussiness', 140 'Vacant Seat First'.
    FORMAT COLOR OFF.
    LOOP AT mv_result INTO DATA(ls_result).
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
  ENDMETHOD.

  METHOD print_info_group.
    ULINE.
    WRITE: / 'Perform displaying prices of each Airline Code and Flight Number.'.

    DATA: gv_total TYPE i.

    LOOP AT mv_result INTO DATA(ls_result)
      GROUP BY ( airline_code = ls_result-carrid flight_number = ls_result-connid )
      ASSIGNING FIELD-SYMBOL(<fs_group>).
      gv_total = 0.

      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_sflight>).
        gv_total = gv_total + <fs_sflight>-price.
      ENDLOOP.
      WRITE: / 'Airline Code: ', <fs_group>-airline_code,
             / 'Flight Number: ', <fs_group>-flight_number,
             / 'Total price: ', gv_total.
      ULINE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.
PARAMETERS: p_air TYPE zruby_sflight-carrid OBLIGATORY.
SELECT-OPTIONS: p_con FOR zruby_sflight-connid.
SELECTION-SCREEN END OF BLOCK b01.

DATA: lo_sflight TYPE REF TO lcl_sflight.

START-OF-SELECTION.
  CREATE OBJECT lo_sflight
    EXPORTING
      iv_air = p_air
      iv_con = p_con[].


  lo_sflight->check_validate( ).

  lo_sflight->print_info( ).
  lo_sflight->print_info_group( ).
