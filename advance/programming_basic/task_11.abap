*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK11
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task11.
TYPES: BEGIN OF gty_sflight,
         carrid     TYPE sflight-carrid,
         connid     TYPE sflight-connid,
         fldate     TYPE sflight-fldate,
         price      TYPE sflight-price,
         currency   TYPE sflight-currency,
         planetype  TYPE sflight-planetype,
         seatsmax   TYPE sflight-seatsmax,
         seatsocc   TYPE sflight-seatsocc,
         paymentsum TYPE sflight-paymentsum,
       END OF gty_sflight.

DATA: gt_sflight        TYPE TABLE OF gty_sflight,
      gt_sflight_origin LIKE gt_sflight,
      gs_result LIKE LINE OF gt_sflight.
DATA: alv_table TYPE REF TO cl_salv_table. " Đối tượng ALV

START-OF-SELECTION.

  "1. Create a standard internal table and fill above data into itself
*  SELECT sflight~carrid,
*    sflight~connid,
*    sflight~fldate,
*    sflight~price,
*    sflight~currency,
*    sflight~planetype,
*    sflight~seatsmax,
*    sflight~seatsocc,
*    sflight~paymentsum
*    FROM sflight
*    INTO TABLE @gt_sflight.
  APPEND VALUE #( carrid = 'AA' connid = 17 fldate = '20130529' price = '0.00'
                   currency = '' planetype = '146-300' seatsmax = 128
                   seatsocc = 30 paymentsum = '0.00' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'AA' connid = 17 fldate = '20130626' price = '422.94'
                  currency = 'USD' planetype = '747-400' seatsmax = 385
                  seatsocc = 250 paymentsum = '195174.31' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'AA' connid = 17 fldate = '20130724' price = '422.94'
                  currency = 'USD' planetype = '747-400' seatsmax = 385
                  seatsocc = 100 paymentsum = '189143.42' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'AA' connid = 17 fldate = '20130821' price = '0.00'
                  currency = '' planetype = '146-200' seatsmax = 112
                  seatsocc = 80 paymentsum = '0.00' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'JL' connid = 407 fldate = '20140502' price = '106.13'
                  currency = 'JPY' planetype = 'DC-10-10' seatsmax = 380
                  seatsocc = 4 paymentsum = '10393.88' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'JL' connid = 407 fldate = '20140530' price = '106.13'
                  currency = 'JPY' planetype = 'DC-10-10' seatsmax = 380
                  seatsocc = 4 paymentsum = '201.65' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'JL' connid = 408 fldate = '20140504' price = '106.13'
                  currency = 'JPY' planetype = '747-400' seatsmax = 385
                  seatsocc = 4 paymentsum = '47964.95' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'UA' connid = 941 fldate = '20130627' price = '879.82'
                  currency = 'USD' planetype = 'A319' seatsmax = 220
                  seatsocc = 4 paymentsum = '225126.97' ) TO gt_sflight.

  APPEND VALUE #( carrid = 'UA' connid = 3517 fldate = '20140526' price = '611.01'
                  currency = 'USD' planetype = '747-400' seatsmax = 385
                  seatsocc = 4 paymentsum = '18513.63' ) TO gt_sflight.
  MOVE-CORRESPONDING gt_sflight TO gt_sflight_origin.

  " 2. Sort internal table in exercise 1 by CARRID CONNID ascending and FLDATE descending, and then output screen

  "PERFORM show_list_sort.


  "3. Delete records in internal table in exercise 1 where CARRID = 'JL' and FLDATE < 30/05/2014

  "PERFORM show_list_after_delete.

  "4. Find and output screen record in internal table in exercise 1 at index 7
   gs_result = gt_sflight_origin[ 7 ].
  WRITE: / 'Gia tri tai vi tri index bang 7 la: carrid -', gs_result-carrid,
         / 'connid: ', gs_result-connid,
         / 'fldate: ', gs_result-fldate,
         / 'price: ', gs_result-price,
         / 'currency: ', gs_result-price.
  "5. Create a sort internal table with unique key CARRID CONNID FLDATE and fill above data into itself
  DATA: gt_sort_sflight TYPE SORTED TABLE OF gty_sflight WITH UNIQUE KEY CARRID CONNID FLDATE.
  MOVE-CORRESPONDING gt_sflight_origin TO gt_sort_sflight.

  "6. Find and output screen records in internal table in exercise 5 with key CARRID = 'AA' and CONNID = 17
  READ TABLE gt_sflight_origin INTO gs_result with key CARRID = 'AA' connid = 17.
  IF sy-subrc = 0.
    WRITE: / 'Tim thay ban ghi CARRID = AA and CONNID = 17: chi tiet carrid: ', gs_result-carrid,
           / 'connid: ', gs_result-connid.
  ELSE.
    MESSAGE 'Khong tim thay ban ghi CARRID = AA and CONNID = 17' TYPE 'E'.
  ENDIF.

  "7. Create a hash internal table with key CARRID CONNID FLDATE and fill above data into itself
  DATA: gt_hash_sflight TYPE HASHED TABLE OF gty_sflight WITH UNIQUE KEY CARRID CONNID FLDATE.
  MOVE-CORRESPONDING gt_sflight_origin TO gt_hash_sflight.

  "8.Get and output screen total amount of records in internal table in exercise 7 with CARRID = 'UA' and FLDATE in 2014
  DATA: lv_total TYPE i VALUE 0.
  LOOP at gt_hash_sflight INTO gs_result.
    IF gs_result-carrid = 'UA' and gs_result-fldate+0(4) = '2014'.
      lv_total = lv_total + 1.
    ENDIF.
  ENDLOOP.
  WRITE: / 'Tong so ban ghi CARRID = UA and FLDATE in 2014 la: ', lv_total.


FORM show_list_sort .
  SORT gt_sflight BY carrid ASCENDING connid ASCENDING fldate DESCENDING.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = alv_table
                              CHANGING  t_table      = gt_sflight ).

      alv_table->display( ). " Hiển thị ALV
    CATCH cx_salv_msg INTO DATA(lx_msg).
      WRITE: / 'Error displaying ALV:', lx_msg->get_text( ).
  ENDTRY.
ENDFORM.


FORM show_list_after_delete .
  DELETE gt_sflight WHERE carrid = 'JL' AND fldate < '20140530'.

  " Tạo đối tượng ALV và hiển thị bảng
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = alv_table
                              CHANGING  t_table      = gt_sflight ).

      alv_table->display( ). " Hiển thị ALV
    CATCH cx_salv_msg INTO DATA(lx_msg).
      WRITE: / 'Error displaying ALV:', lx_msg->get_text( ).
  ENDTRY.
ENDFORM.
