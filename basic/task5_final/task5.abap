*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_FINAL_FI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_ruby_final_fi.
TABLES sscrfields.

INCLUDE zpg_ruby_final_fi_top.
INCLUDE zpg_ruby_final_fi_f01.
INCLUDE zpg_ruby_final_fi_f02.

INITIALIZATION.
  DATA(ls_dyntxt) = VALUE smp_dyntxt( icon_id = icon_intensify icon_text = TEXT-021
   quickinfo = TEXT-020 ).
  sscrfields-functxt_01 = ls_dyntxt.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    "Display input field based on selected radio button
    IF p_r_view = 'X'.
      IF screen-group1 = 'G2'.
        screen-active = 0. " Hide input2 when radio1 is selected
      ELSEIF screen-group1 = 'G1'.
        screen-active = 1. " Show input1 when radio1 is selected
      ENDIF.
    ELSEIF p_r_up = 'X'.
      IF screen-group1 = 'G1'.
        screen-active = 0. " Hide input1 when radio2 is selected
      ELSEIF screen-group1 = 'G2'.
        screen-active = 1. " Show input2 when radio2 is selected
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
    CONTINUE.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

AT SELECTION-SCREEN.
  IF sscrfields-ucomm = 'FC01'.
    PERFORM export_template.
  ENDIF.

START-OF-SELECTION.
  IF p_r_up = 'X'.
    IF p_file IS INITIAL.
      MESSAGE TEXT-017 TYPE 'E'.
    ELSE.
      PERFORM upload_file. "Xu ly voi upload file
    ENDIF.
  ELSE.
    PERFORM load_data_table_z. "Xu ly voi action View
    PERFORM load_vendor_data. "Load bank account cua vendor
    PERFORM load_document_to_paid. "Load cac document number chua thanh toan
  ENDIF.

END-OF-SELECTION.
  IF p_r_view = 'X'.
    PERFORM display_data_alv_table.
  ELSE.
    PERFORM display_data_alv.
  ENDIF.
