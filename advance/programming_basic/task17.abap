*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK17
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task17.

DATA: gdf_check TYPE char1,
      gv_text   TYPE string,
      gv_action TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_ra1 RADIOBUTTON GROUP grp1,
            p_ra2 RADIOBUTTON GROUP grp1,
            p_ra3 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_air   TYPE sflight-carrid OBLIGATORY, "Airline code
            p_con   TYPE sflight-connid OBLIGATORY, " Flight No
            p_fdate TYPE sflight-fldate OBLIGATORY,  " Flight Date
            p_pri   TYPE sflight-price, "Airfare
            p_cur   TYPE sflight-currency,  " Currency
            p_type  TYPE sflight-planetype,  " Plane type
            p_sm    TYPE sflight-seatsmax, " Available seats
            p_sc    TYPE sflight-seatsocc,   " Reserved seats
            p_smb   TYPE sflight-seatsmax_b,  " Available seats (Business)
            p_scb   TYPE sflight-seatsocc_b,  " Reserved seats (Business)
            p_smf   TYPE sflight-seatsmax_f,  " Available seats (First Class)
            p_scf   TYPE sflight-seatsocc_f. " Reserved seats (First Class)

SELECTION-SCREEN END OF BLOCK b02.

AT SELECTION-SCREEN.
  SELECT SINGLE carrid
  FROM scarr
  WHERE scarr~carrid = @p_air
  INTO @DATA(lv_carrid).
  IF sy-subrc <> 0.
    MESSAGE e000(zyinc_ruby_task17).
  ENDIF.

  SELECT SINGLE connid
  FROM sflight
  WHERE sflight~connid = @p_con
  INTO @DATA(lv_connid).
  IF sy-subrc <> 0.
    MESSAGE e001(zyinc_ruby_task17) WITH p_air p_con.
  ENDIF.

  IF p_cur IS NOT INITIAL.
    SELECT SINGLE currkey
    FROM scurx
    WHERE scurx~currkey = @p_cur
    INTO @DATA(lv_cur).

    IF sy-subrc <> 0.
      MESSAGE e002(zyinc_ruby_task17) WITH p_cur.
    ENDIF.
  ENDIF.

  IF p_type IS NOT INITIAL.
    SELECT SINGLE planetype
    FROM saplane
    WHERE saplane~planetype = @p_type
    INTO @DATA(p_type).

    IF  sy-subrc <> 0.
      MESSAGE e003(zyinc_ruby_task17) WITH p_type.
    ENDIF.
  ENDIF.

  IF p_pri IS NOT INITIAL AND p_cur IS NOT INITIAL.
    DATA: lv_price TYPE bapicurr-bapicurr,
          lv_curr  TYPE tcurc-waers.
    lv_price = p_pri.
    lv_curr = p_cur.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        currency             = lv_curr
        amount_external      = lv_price
        max_number_of_digits = 15
      IMPORTING
        amount_internal      = p_pri
      EXCEPTIONS
        OTHERS               = 2.

    IF sy-subrc <> 0.
      MESSAGE 'Convert price to internal failed' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  IF p_ra3 = 'X'.
    WRITE: / 'List of data can be created / updated / deleted.'.
    WRITE: / 'Airline code: ', p_air,
           / 'Fligh no:', p_con,
           / 'Flight date:', p_fdate,
           / 'Price: ', p_pri CURRENCY p_cur,
           / 'Currency: ', p_cur,
           / 'Plan type: ', p_type,
           / 'Total Economy cl seat: ', p_sm,
           / 'Economy cl reserved seat: ', p_sc,
           / 'Total Bussiness cl seat: ', p_smb,
           / 'Bussiness reserved seat: ', p_scb,
           / 'Total first class seat: ', p_smf,
           / 'First cl reserved seat: ', p_scf.
  ELSEIF p_ra1 = 'X'.
    SELECT SINGLE sflight~carrid
      FROM sflight
      WHERE sflight~carrid = @p_air
        AND sflight~connid = @p_con
        AND sflight~fldate = @p_fdate
     INTO @DATA(lv_carrid_sflight).

    IF sy-subrc = 0.
      gv_text = 'Would you like to update data'.
      gv_action = 'update'.
    ELSE.
      gv_text = 'Would you like to create data'.
      gv_action = 'create'.
    ENDIF.

    PERFORM popup_confirm.
  ELSEIF p_ra2 = 'X'.
    gv_text = 'Would you like to delete data'.
    gv_action = 'delete'.
    PERFORM popup_confirm.
  ENDIF.

END-OF-SELECTION.
  WRITE: / |{ gv_action } process is successful|,
         / 'Airline code:', p_air,
         / 'Flight No:', p_con,
         / 'Flight Date:', p_fdate.

FORM popup_confirm.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = gv_text
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = gdf_check.

  IF gdf_check = '1'. "action choose Yes
    IF gv_action = 'create'.
      INSERT sflight FROM @(
         VALUE #(
           carrid = p_air connid = p_con fldate = p_fdate currency = p_cur price = p_pri
           planetype = p_type seatsmax = p_sm seatsocc = p_sc
           seatsmax_b = p_smb seatsocc_b = p_scb seatsmax_f = p_smf seatsocc_f = p_scf
         )
       ).
    ELSEIF gv_action = 'update'.
      UPDATE sflight FROM @(
         VALUE #(
           carrid = p_air connid = p_con fldate = p_fdate currency = p_cur price = p_pri
           planetype = p_type seatsmax = p_sm seatsocc = p_sc
           seatsmax_b = p_smb seatsocc_b = p_scb seatsmax_f = p_smf seatsocc_f = p_scf
         )
       ).
    ELSE.
      DELETE sflight FROM @( VALUE #( carrid = p_air connid = p_con fldate = p_fdate ) ).
    ENDIF.

    IF sy-subrc <> 0.
      MESSAGE 'There are some errors when create/update/delete flight data!' TYPE 'E'.
      RETURN.
    ENDIF.
  ENDIF.
ENDFORM.
