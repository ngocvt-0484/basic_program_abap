*&---------------------------------------------------------------------*
*& Report ZSYR003_RUBY_TASK1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr003_ruby_task1.
TABLES: zruby_sflight.
TYPES: BEGIN OF gty_result,
        carrid TYPE zruby_sflight-carrid,
        connid TYPE zruby_sflight-connid,
        fldate TYPE zruby_sflight-fldate,
        price TYPE zruby_sflight-price,
        currency TYPE zruby_sflight-currency,
        seatsmax TYPE zruby_sflight-seatsmax,
        seatsocc TYPE zruby_sflight-seatsocc,
        seatsmax_b TYPE zruby_sflight-seatsmax_b,
        seatsocc_b TYPE zruby_sflight-seatsocc_b,
        seatsmax_f TYPE zruby_sflight-seatsmax_f,
        seatsocc_f TYPE zruby_sflight-seatsocc_f,
        carrname  TYPE zruby_scarr-carrname,
        economy TYPE I,
        business TYPE I,
        first TYPE I,
       END OF gty_result.
DATA: gt_catalog TYPE  slis_t_fieldcat_alv,
      gv_layout TYPE slis_layout_alv,
      gt_result TYPE TABLE OF gty_result.

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
  INTO CORRESPONDING FIELDS OF TABLE @gt_result.

  IF sy-subrc <> 0.
    MESSAGE 'No data exists in Flight table' TYPE 'E'.
  ENDIF.

  LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
    <fs_result>-economy = <fs_result>-seatsmax - <fs_result>-seatsocc.
    <fs_result>-business = <fs_result>-seatsmax_b - <fs_result>-seatsocc_b.
    <fs_result>-first = <fs_result>-seatsmax_f - <fs_result>-seatsocc_f.
  ENDLOOP.

  PERFORM display_alv.
*  ULINE.
*  WRITE: / 'Perform displaying prices of each Airline Code and Flight Number.'.

*  DATA: gv_total TYPE i.
*
*  LOOP AT gt_result INTO DATA(ls_result)
*    GROUP BY ( airline_code = ls_result-carrid flight_number = ls_result-connid )
*    ASSIGNING FIELD-SYMBOL(<fs_group>).
*    gv_total = 0.
*
*    LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_sflight>).
*      gv_total = gv_total + <fs_sflight>-price.
*    ENDLOOP.
*    WRITE: / 'Airline Code: ', <fs_group>-airline_code,
*           / 'Flight Number: ', <fs_group>-flight_number,
*           / 'Total price: ', gv_total.
*    ULINE.
*  ENDLOOP.

*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv .
  clear gt_catalog.
  gt_catalog = VALUE #(
  ( row_pos = 1 col_pos = 1 fieldname = 'carrid' outputlen = '10' seltext_m = 'Airline code' )
  ( row_pos = 1 col_pos = 2 fieldname = 'carrname' outputlen = '10' seltext_m = 'Airline name' )
  ( row_pos = 1 col_pos = 3 fieldname = 'connid' outputlen = '10' seltext_m = 'Flight number' )
  ( row_pos = 1 col_pos = 4 fieldname = 'fldate' outputlen = '10' seltext_m = 'Flight date' )
  ( row_pos = 1 col_pos = 5 fieldname = 'price' outputlen = '10' seltext_m = 'Price' cfieldname = 'currency' )
  ( row_pos = 1 col_pos = 6 fieldname = 'economy' outputlen = '10' seltext_m = 'Vacant Seat Economy' )
  ( row_pos = 1 col_pos = 7 fieldname = 'business' outputlen = '10' seltext_m = 'Vacant Seat Bussiness' )
  ( row_pos = 1 col_pos = 8 fieldname = 'first' outputlen = '10' seltext_m = 'Vacant Seat First' )
  ).

  gv_layout-zebra = 'X'.
  gv_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout                = gv_layout
      it_fieldcat              = gt_catalog
      "it_excluding = lt_exclude
      i_callback_program       = sy-repid
*      i_callback_user_command  = 'SET_USER_COMMAND'
      i_callback_pf_status_set = 'SET_PF_STATUS' "Xu ly custom menu vs title"
      i_save                   = 'X' "Save lai layout"
    TABLES
      t_outtab                 = gt_result
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTATUS_ZSYR003'.
  SET TITLEBAR 'ZSYR003_TITLE'.
ENDFORM.
