FORM display_data_alv .
  CLEAR gt_catalog.
  gs_catalog-row_pos = 1.
  gs_catalog-col_pos = 1.
  gs_catalog-fieldname = 'FLAG'.
  gs_catalog-input = 'X'.
  gs_catalog-edit = 'X'.
  gs_catalog-checkbox = 'X'.
  gs_catalog-seltext_m = TEXT-t16.

  APPEND gs_catalog TO gt_catalog.
  CLEAR gs_catalog.

  PERFORM build_fieldcat USING '1' '2' 'pay_doc_num' TEXT-t01 '20'.
  PERFORM build_fieldcat USING '1' '3' 'doc_date' TEXT-t02 '12'.
  PERFORM build_fieldcat USING '1' '4' 'pos_date' TEXT-t03 '12'.
  PERFORM build_fieldcat USING '1' '5' 'doc_type' TEXT-t04 '7'.
  PERFORM build_fieldcat USING '1' '6' 'comp_code' TEXT-t05 '5'.
  PERFORM build_fieldcat USING '1' '7' 'cur' TEXT-t06 '12'.
  PERFORM build_fieldcat USING '1' '8' 'bank_acct' TEXT-t07 '12'.
  PERFORM build_fieldcat USING '1' '9' 'amount' TEXT-t08 '10'.
  PERFORM build_fieldcat USING '1' '10' 'vendor' TEXT-t09 '20'.
  PERFORM build_fieldcat USING '1' '11' 'ref_doc_no' TEXT-t10 '12'.
  PERFORM build_fieldcat USING '1' '12' 'status' TEXT-t11 '12'.
  PERFORM build_fieldcat USING '1' '13' 'message' TEXT-t12 '20'.

  gv_layout-zebra = 'X'.
  gv_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout                = gv_layout
      it_fieldcat              = gt_catalog
      i_callback_program       = sy-repid
      i_callback_user_command  = 'SET_USER_COMMAND'
      i_callback_pf_status_set = 'SET_PF_STATUS' "Xu ly custom menu vs title"
      i_save                   = 'X' "Save lai layout"
    TABLES
      t_outtab                 = gt_file
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  CLEAR gv_layout.
ENDFORM.


FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'SALV_STANDARD'.
  SET TITLEBAR 'ZSUN_CREATE_DOCUMENT'.
ENDFORM.

FORM build_fieldcat USING VALUE(p_rowpos)
                          VALUE(p_colpos)
                          VALUE(p_fieldname)
                          VALUE(p_header_text)
                          VALUE(p_length).
  gs_catalog-row_pos = p_rowpos.
  gs_catalog-col_pos = p_colpos.
  gs_catalog-fieldname = p_fieldname.
  gs_catalog-tabname = 'REPORT'.
  gs_catalog-outputlen = p_length.
  gs_catalog-seltext_m = gs_catalog-seltext_l = p_header_text.
*  gs_catalog-edit = 'X'.
*  gs_catalog-cfieldname = 'cur'.

  APPEND gs_catalog TO gt_catalog.
  CLEAR gs_catalog.
ENDFORM.

FORM set_user_command USING p_ucomm TYPE sy-ucomm
                       p_selflddetails TYPE slis_selfield.
  CASE p_ucomm.
    WHEN  '&SEL'. "Select all record
      LOOP AT gt_file INTO gs_file.
        gs_file-flag = 'X'. "set checked"
        MODIFY gt_file INDEX sy-tabix FROM gs_file TRANSPORTING flag.
      ENDLOOP.
    WHEN '&DEL'. "Delete record
      DELETE gt_file INDEX p_selflddetails-tabindex.
    WHEN '&ADD1'. "Add record
      CLEAR gs_file.
      APPEND gs_file TO gt_file.
    WHEN '&COPY'. "COPY record
      READ TABLE gt_file INTO gs_file INDEX p_selflddetails-tabindex.
      APPEND gs_file TO gt_file.

    WHEN '&SAV'. "Save record to table Z
      PERFORM update_alv_to_table.

      DATA: ls_fi_doc_db TYPE ztb_fi_doc_ruby,
            lv_output    TYPE char10.

      LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_gs_file>) WHERE flag = 'X'.
        IF <fs_gs_file>-pay_doc_num IS INITIAL OR
          <fs_gs_file>-cur IS INITIAL OR
          <fs_gs_file>-doc_date IS INITIAL OR
          <fs_gs_file>-pos_date IS INITIAL OR
          <fs_gs_file>-doc_type IS INITIAL OR
          <fs_gs_file>-comp_code IS INITIAL OR
          <fs_gs_file>-bank_acct IS INITIAL OR
          <fs_gs_file>-amount IS INITIAL OR
          <fs_gs_file>-vendor IS INITIAL.
          <fs_gs_file>-status = gc_error.
          <fs_gs_file>-message = TEXT-016.
        ELSE.
          CLEAR ls_fi_doc_db.
          MOVE-CORRESPONDING <fs_gs_file> TO ls_fi_doc_db.
          TRANSLATE ls_fi_doc_db-comp_code TO UPPER CASE.
          TRANSLATE ls_fi_doc_db-cur TO UPPER CASE.

          PERFORM convert_alpha_input USING ls_fi_doc_db-pay_doc_num CHANGING lv_output.
          ls_fi_doc_db-pay_doc_num = lv_output.

          PERFORM convert_alpha_input USING ls_fi_doc_db-bank_acct CHANGING lv_output.
          ls_fi_doc_db-bank_acct = lv_output.

          ls_fi_doc_db-status = gc_no_action.
          ls_fi_doc_db-message = ''.
          ls_fi_doc_db-creator = sy-uname.
          ls_fi_doc_db-created_doc = ''.
          ls_fi_doc_db-reserve_doc = ''.
          ls_fi_doc_db-obj_key = ''.
          ls_fi_doc_db-obj_type = ''.
          ls_fi_doc_db-obj_sys = ''.

          INSERT INTO ztb_fi_doc_ruby VALUES ls_fi_doc_db.

          IF sy-subrc = 0.
            <fs_gs_file>-status = gc_success.
            <fs_gs_file>-message = TEXT-014.
            MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'S'.
          ELSE.
            <fs_gs_file>-status = gc_error.
            <fs_gs_file>-message = TEXT-015.
            MESSAGE TEXT-004 TYPE 'E' DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  p_selflddetails-refresh = 'X'. "Setting refresh ALV to update
  p_selflddetails-row_stable = 'X'. "Setting refresh ALV to update
  p_selflddetails-col_stable = 'X'. "Setting refresh ALV to update

ENDFORM.

FORM convert_alpha_input USING p_input TYPE char10 CHANGING p_output TYPE char10.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = p_output.
ENDFORM.

FORM convert_amount USING p_amount TYPE  bapiaccr09-amt_doccur
                          p_currency TYPE tcurc-waers
                          CHANGING p_output  TYPE  bapiaccr09-amt_doccur.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'  "Conversion of Currency Amounts into Internal Data Format
    EXPORTING
      currency             = p_currency
      amount_external      = p_amount
      max_number_of_digits = 23
    IMPORTING
      amount_internal      = p_output.
ENDFORM.

FORM update_alv_to_table.
  DATA: grid_object TYPE REF TO cl_gui_alv_grid.
  " Gọi hàm GET_GLOBALS_FROM_SLVC_FULLSCR để lấy dữ liệu toàn cục
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = grid_object.  " Lấy đối tượng grid đang hiển thị ALV

  " Kiểm tra xem grid_object đã được lấy hay chưa
  IF grid_object IS NOT INITIAL.
    " Lấy dữ liệu từ grid (dữ liệu người dùng có thể đã thay đổi)
    CALL METHOD grid_object->check_changed_data.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPLOAD_FILE
*&---------------------------------------------------------------------*
FORM upload_file .
  DATA: lv_input  TYPE char10,
        lv_output TYPE bapidoccur.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = abap_true
      i_tab_raw_data       = gt_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_file
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
