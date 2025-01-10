*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task3.
DATA: v_date TYPE sflight-fldate.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_carrid TYPE scarr-carrid DEFAULT 'AA' OBLIGATORY,
            p_conni  TYPE sflight-connid.
SELECT-OPTIONS: s_date FOR v_date OBLIGATORY NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_check AS CHECKBOX.
PARAMETERS: p_from TYPE spfli-cityfrom,
            p_to   TYPE spfli-cityto.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_ra1 RADIOBUTTON GROUP grp1 DEFAULT 'X',
            p_ra2 RADIOBUTTON GROUP grp1,
            p_ra3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b03.

AT SELECTION-SCREEN.
  IF p_check = 'X' AND p_from IS INITIAL AND p_to IS INITIAL.
    "MESSAGE TEXT-004 TYPE 'E'.
    MESSAGE e001(zyinc_ruby_task8) WITH 'City from' 'City to'.
  ENDIF.

START-OF-SELECTION.
  DATA(lv_seat) = COND string( WHEN p_ra1 = 'X' THEN 'Economy class'
                               WHEN p_ra2 = 'X' THEN 'Bussiness class'
                               WHEN p_ra3 = 'X' THEN 'First class'
                             ).
  WRITE: / 'Airline Code: ', p_carrid.
  WRITE: / 'Flight No: ', p_conni.
  IF p_from IS NOT INITIAL.
    WRITE: / 'City from: ', p_from.
  ENDIF.

  IF p_to IS NOT INITIAL.
    WRITE: / 'City to: ', p_to.
  ENDIF.
  WRITE: / 'Class of seats: ', lv_seat.
  WRITE: / 'Execution date:', s_date-low.
  WRITE: / 'Execution time:', sy-uzeit.
