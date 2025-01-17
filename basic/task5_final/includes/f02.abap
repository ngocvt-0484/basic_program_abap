*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_FINAL_FI_F02
*&---------------------------------------------------------------------*
FORM display_data_alv_table.
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

  PERFORM build_fieldcat USING '1' '2' 'pay_doc_num' TEXT-t01 '40'.
  PERFORM build_fieldcat USING '1' '3' 'doc_date' TEXT-t02 '12'.
  PERFORM build_fieldcat USING '1' '4' 'pos_date' TEXT-t03 '12'.
  PERFORM build_fieldcat USING '1' '5' 'doc_type' TEXT-t04 '7'.
  PERFORM build_fieldcat USING '1' '6' 'comp_code' TEXT-t05 '5'.
  PERFORM build_fieldcat USING '1' '7' 'cur' TEXT-t06 '12'.
  PERFORM build_fieldcat USING '1' '8' 'bank_acct' TEXT-t07 '12'.
  PERFORM build_fieldcat USING '1' '9' 'amount' TEXT-t08 '10'.
  PERFORM build_fieldcat USING '1' '10' 'vendor' TEXT-t09 '20'.
  PERFORM build_fieldcat USING '1' '11' 'ref_doc_no' TEXT-t10 '12'.
  PERFORM build_fieldcat USING '1' '12' 'status' TEXT-t11 '20'.
  PERFORM build_fieldcat USING '1' '13' 'message' TEXT-t12 '30'.
  PERFORM build_fieldcat USING '1' '14' 'creator' TEXT-t13 '10'.
  PERFORM build_fieldcat USING '1' '15' 'created_doc' TEXT-t14 '10'.
  PERFORM build_fieldcat USING '1' '16' 'reserve_doc' TEXT-t15 '10'.

  gv_layout-zebra = 'X'.
  gv_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout                = gv_layout
      it_fieldcat              = gt_catalog
      i_callback_program       = sy-repid
      i_callback_user_command  = 'SET_USER_COMMAND_TABLE'
      i_callback_pf_status_set = 'SET_PF_STATUS_TABLE' "Xu ly custom menu vs title"
      i_save                   = 'X' "Save lai layout"
    TABLES
      t_outtab                 = gt_fi_doc
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  CLEAR gv_layout.

ENDFORM.

FORM set_pf_status_table USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'SALV_STANDARD2'.
  SET TITLEBAR 'ZSUN_CREATE_DOCUMENT'.
ENDFORM.

FORM set_user_command_table USING p_ucomm TYPE sy-ucomm
                       p_selflddetails TYPE slis_selfield.
  CASE p_ucomm.
    WHEN  '&SEL_ALL'. "Select all record
      LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc>).
        <fs_fi_doc>-flag = 'X'. "set checked"
      ENDLOOP.
    WHEN '&UNSEL_ALL'. "Unselect all record
      LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_unsel>).
        <fs_fi_doc_unsel>-flag = ''. "set unchecked"
      ENDLOOP.
    WHEN '&SAV_DOC'. "Save document to DB F-53
      PERFORM update_alv_to_table.
      PERFORM post_doc.
    WHEN '&RESER_DOC'. "Reserve document
      PERFORM update_alv_to_table.
      PERFORM reserve_doc.
    WHEN '&DEL_DOC'. "Delete document from table Z
      PERFORM update_alv_to_table.
      PERFORM delete_doc.
    WHEN '&EXPORT_EX'. "Export excel
      PERFORM update_alv_to_table.
      PERFORM export_excel.
    WHEN '&IC1'.
      READ TABLE gt_fi_doc INTO DATA(gs_fi_doc) INDEX p_selflddetails-tabindex.
      IF gs_fi_doc-created_doc IS INITIAL.
        SET PARAMETER ID 'BLN' FIELD gs_fi_doc-pay_doc_num. "chua post thi xem document can thanh toan
      ELSEIF gs_fi_doc-reserve_doc IS INITIAL.
        SET PARAMETER ID 'BLN' FIELD gs_fi_doc-created_doc. "da post thi xem document thanh toan
      ELSE.
        SET PARAMETER ID 'BLN' FIELD gs_fi_doc-reserve_doc. "da reserve thi xem document reserve
      ENDIF.

      SET PARAMETER ID 'BUK' FIELD gs_fi_doc-comp_code.
      SET PARAMETER ID 'GJR' FIELD gs_fi_doc-pos_date(4).
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

  p_selflddetails-refresh = 'X'. "Setting refresh ALV to update
  p_selflddetails-row_stable = 'X'. "Setting refresh ALV to update
  p_selflddetails-col_stable = 'X'. "Setting refresh ALV to update
ENDFORM.

FORM post_doc.

  DATA: lv_input            TYPE char10,
        lv_output           TYPE char10,
        lv_amount_internal  TYPE bapiaccr09-amt_doccur,
        lv_obj_type         TYPE bapiache09-obj_type, "OBJ_TYPE
        lv_obj_key          TYPE bapiache09-obj_key, " OBJ_KEY
        lv_obj_sys          TYPE  bapiache09-obj_sys,
        lv_year             TYPE char10,
        ls_fi_doc_db        TYPE ztb_fi_doc_ruby,
        ls_document_payment TYPE gty_payment, "Document can thanh toan
        lt_extension        TYPE STANDARD TABLE OF bapiacextc, "Extension1
        lt_ausz1            TYPE STANDARD TABLE OF ausz1 , "Clearing information
        lt_ausz2            TYPE STANDARD TABLE OF ausz2. " clearing type.

  LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_data>) WHERE flag = 'X'.
    IF <fs_fi_doc_data>-created_doc IS INITIAL.
      "Bo sung: Validate so tien, currency, cong ty, vendor phai mapping vs document thanh toan
      READ TABLE gt_payment INTO gs_payment WITH KEY pay_doc_num = <fs_fi_doc_data>-pay_doc_num.
      IF sy-subrc <> 0.
        <fs_fi_doc_data>-message = TEXT-018.
        <fs_fi_doc_data>-status = gc_error.

        MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
        MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.
        CLEAR: gs_payment, ls_fi_doc_db.
        CONTINUE.
      ENDIF.

      PERFORM convert_amount USING <fs_fi_doc_data>-amount <fs_fi_doc_data>-cur
                             CHANGING lv_amount_internal.
      IF gs_payment-amount <> lv_amount_internal OR
        gs_payment-cur <> <fs_fi_doc_data>-cur OR
        gs_payment-comp_code <> <fs_fi_doc_data>-comp_code OR
        gs_payment-vendor <> <fs_fi_doc_data>-vendor OR
        gs_payment-debit_or_credit <> gc_credit.
        <fs_fi_doc_data>-message = TEXT-019.
        <fs_fi_doc_data>-status = gc_error.

        MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
        MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.
        CLEAR: gs_payment, ls_fi_doc_db.
        CONTINUE.
      ENDIF.
      "Thong tin documentheader
      gs_header-username = sy-uname. "Ai thuc hien but toan
      gs_header-doc_date = <fs_fi_doc_data>-doc_date. " Ngay chung tu
      gs_header-doc_type = <fs_fi_doc_data>-doc_type. " Document Type: Loai but toan (KR: Vendor invoice)
      gs_header-comp_code = <fs_fi_doc_data>-comp_code. " Company code
      gs_header-pstng_date = <fs_fi_doc_data>-pos_date. "Ngay ghi so
      lv_year = <fs_fi_doc_data>-pos_date(4).
      gs_header-ref_doc_no = <fs_fi_doc_data>-ref_doc_no. "Số chứng từ tham chiếu (tuỳ chọn)

      "Thong tin tai khaon thanh toan - AccountGL
      gs_item_gl-itemno_acc = '0000000001'. "So khoan muc
      lv_input = <fs_fi_doc_data>-bank_acct.

      PERFORM convert_alpha_input USING lv_input CHANGING lv_output.

      gs_item_gl-gl_account = lv_output. "Tai khoan thanh toan
      gs_item_gl-comp_code = <fs_fi_doc_data>-comp_code.
      gs_item_gl-acct_type = 'S'. "Loai general ledger
      APPEND:   gs_item_gl TO gt_item_gl.

      "Thong tin TK dai dien NCC - AccountPayable
      READ TABLE gt_vendor INTO gs_vendor WITH KEY vendor = <fs_fi_doc_data>-vendor
                                                   comp_code = <fs_fi_doc_data>-comp_code.
      gs_item_vi-itemno_acc = '0000000002'. "So khoan muc
      lv_input = <fs_fi_doc_data>-vendor.
      PERFORM convert_alpha_input USING lv_input CHANGING lv_output.
      gs_item_vi-vendor_no = lv_output. " Vendor Account "LAF1
      gs_item_vi-comp_code = <fs_fi_doc_data>-comp_code.
      gs_item_vi-gl_account = gs_vendor-vendor_acct. "Lay tu bang LFB1-AKONT - Reconciliation acct
      APPEND:   gs_item_vi TO gt_item_vi.

      "Thong tin tien ung voi cac itemno
      " ------ tru tien vao tk thanh toan
      gs_item_currency-itemno_acc = '0000000001'.
      gs_item_currency-amt_doccur =  0 - <fs_fi_doc_data>-amount.
      gs_item_currency-currency = <fs_fi_doc_data>-cur.
      APPEND:  gs_item_currency TO gt_item_currency.
      CLEAR gs_item_currency.

      "------ cong lai tien vao tk NCC
      gs_item_currency-itemno_acc = '0000000002'.
      gs_item_currency-amt_doccur =  <fs_fi_doc_data>-amount.
      gs_item_currency-currency = <fs_fi_doc_data>-cur.
      APPEND:  gs_item_currency TO gt_item_currency.
      CLEAR gs_item_currency.

      "Modify table Z
      MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.

      "Modify posting key to 25: outgoing payment - f-53
      CONCATENATE 'ZACC_HANA' '0000000002' '25' INTO DATA(lv_extension) SEPARATED BY '|'.
      APPEND VALUE #( field1 = lv_extension ) TO lt_extension.

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = gs_header
        IMPORTING
          obj_key        = lv_obj_key     "so chung tu duoc tao
          obj_type       = lv_obj_type
          obj_sys        = lv_obj_sys
        TABLES
          accountgl      = gt_item_gl
          accountpayable = gt_item_vi
          currencyamount = gt_item_currency
          extension1     = lt_extension
          return         = gt_return.

      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        IF sy-msgno = 605.
          <fs_fi_doc_data>-message = TEXT-012 && lv_obj_key(10).
          <fs_fi_doc_data>-status = gc_success.
          <fs_fi_doc_data>-created_doc = lv_obj_key(10).
          <fs_fi_doc_data>-obj_key = lv_obj_key.
          <fs_fi_doc_data>-obj_type = lv_obj_type.
          <fs_fi_doc_data>-obj_sys = lv_obj_sys.
          lv_input = <fs_fi_doc_data>-pay_doc_num.
          PERFORM convert_alpha_input USING lv_input CHANGING lv_output.

          APPEND VALUE #( belnr = lv_output
                          bukrs = <fs_fi_doc_data>-comp_code
                          gjahr = lv_year
                          buzei = 1 )
                                          TO lt_ausz1.
          APPEND VALUE #( belnr = <fs_fi_doc_data>-created_doc
                          bukrs =  <fs_fi_doc_data>-comp_code
                          gjahr = lv_year
                          buzei = 2 )
                                         TO lt_ausz1.
          APPEND VALUE #( bukrs = <fs_fi_doc_data>-comp_code
                          augbl = <fs_fi_doc_data>-pay_doc_num
                          aktio = 'c'
                          augdt = sy-datum
                          auggj = lv_year )
                                          TO lt_ausz2.
          APPEND VALUE #( bukrs = <fs_fi_doc_data>-comp_code
                          augbl = <fs_fi_doc_data>-created_doc
                          aktio = 'c'
                          augdt = sy-datum
                          auggj = lv_year )
                                           TO lt_ausz2.

          CALL FUNCTION 'CLEAR_DOCUMENTS'
            TABLES
              t_ausz1 = lt_ausz1
              t_ausz2 = lt_ausz2.
        ENDIF.
      ELSE.
        LOOP AT gt_return INTO DATA(gs_return) WHERE type = 'E' OR type = 'A' .
          <fs_fi_doc_data>-message = gs_return-message.
          <fs_fi_doc_data>-status = gc_error.
        ENDLOOP.
      ENDIF.
    ELSE.
      <fs_fi_doc_data>-message = TEXT-011.
      <fs_fi_doc_data>-status = gc_error.
    ENDIF.

    MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
    MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.

    CLEAR: gs_fi_doc, gs_header, gt_item_gl, gt_item_vi, gt_item_currency,
        gt_return, gs_vendor, lv_input, lv_output, ls_fi_doc_db, lv_obj_key.
  ENDLOOP.

ENDFORM.

FORM reserve_doc.
  DATA: lv_bus_act       TYPE bapiache09-bus_act,
        lv_obj_type      TYPE bapiache09-obj_type, "OBJ_TYPE
        lv_obj_key       TYPE bapiache09-obj_key, " OBJ_KEY
        lv_obj_sys       TYPE  bapiache09-obj_sys,
        lt_return        TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
        lt_return_commit TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
        ls_return        TYPE bapiret2,
        ls_fi_doc_db     TYPE ztb_fi_doc_ruby.

  LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_data>) WHERE flag = 'X'.
    IF <fs_fi_doc_data>-created_doc <> '' AND <fs_fi_doc_data>-reserve_doc IS INITIAL.
      " RESET CLEARING DOCUMENT
      CALL FUNCTION 'CALL_FBRA'
        EXPORTING
          i_augbl = <fs_fi_doc_data>-created_doc
          i_augdt = sy-datum
          i_bukrs = <fs_fi_doc_data>-comp_code
          i_gjahr = sy-datum+0(4)
        EXCEPTIONS
          OTHERS  = 1.

      IF sy-subrc <> 0.
        <fs_fi_doc_data>-message = TEXT-009.
        <fs_fi_doc_data>-status = gc_error.
      ELSE.
        DATA(ls_reversal) = VALUE bapiacrev( obj_type = <fs_fi_doc_data>-obj_type
                                             obj_key = <fs_fi_doc_data>-obj_key
                                             obj_sys = <fs_fi_doc_data>-obj_sys
                                             obj_key_r = <fs_fi_doc_data>-obj_key
                                             pstng_date = sy-datum
                                             reason_rev = '04' ).
        lv_bus_act = 'RFBU'.

        CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
          EXPORTING
            reversal = ls_reversal
            bus_act  = lv_bus_act
          IMPORTING
            obj_type = lv_obj_type
            obj_key  = lv_obj_key
            obj_sys  = lv_obj_sys
          TABLES
            return   = lt_return.

        LOOP AT lt_return INTO ls_return.
          IF ls_return-type = 'E' OR ls_return-type = 'A'.
            <fs_fi_doc_data>-message = ls_return-message.
            <fs_fi_doc_data>-status = gc_error.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'. " Đảm bảo quá trình commit diễn ra đồng bộ

            <fs_fi_doc_data>-message = TEXT-010 && lv_obj_key(10).
            <fs_fi_doc_data>-status = gc_success.
            <fs_fi_doc_data>-reserve_doc = lv_obj_key(10).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      <fs_fi_doc_data>-message = TEXT-009.
      <fs_fi_doc_data>-status = gc_error.
    ENDIF.


    MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
    MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.
  ENDLOOP.
ENDFORM.

FORM delete_doc.
  DATA: ls_fi_doc_db     TYPE ztb_fi_doc_ruby.

  LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_data>) WHERE flag = 'X'.
    IF <fs_fi_doc_data>-created_doc IS INITIAL OR <fs_fi_doc_data>-reserve_doc IS NOT INITIAL.

      DELETE FROM ztb_fi_doc_ruby WHERE pay_doc_num = <fs_fi_doc_data>-pay_doc_num.

      IF sy-subrc = 0.
        DELETE gt_fi_doc INDEX sy-tabix.
      ELSE.
        <fs_fi_doc_data>-status = gc_error.
        <fs_fi_doc_data>-message = TEXT-007.
        MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
        MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.
      ENDIF.
    ELSE.
      <fs_fi_doc_data>-status = gc_error.
      <fs_fi_doc_data>-message = TEXT-006.

      MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_fi_doc_db.
      MODIFY ztb_fi_doc_ruby FROM  ls_fi_doc_db.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM export_excel.
  TYPES: BEGIN OF lty_head,
           h(30) TYPE c,
         END OF lty_head,
         BEGIN OF lty_excel,
           pay_doc_num TYPE ztb_fi_doc_ruby-pay_doc_num,
           doc_date    TYPE bapiache09-doc_date,
           pos_date    TYPE bapiache09-pstng_date,
           doc_type    TYPE bapiache09-doc_type,
           comp_code   TYPE bapiache09-comp_code,
           cur         TYPE bapiaccr09-currency,
           bank_acct   TYPE bapiacgl09-gl_account,
           amount      TYPE bapiaccr09-amt_doccur,
           vendor      TYPE bapiacap09-vendor_no,
           ref_doc_no  TYPE bapiache09-ref_doc_no,
           status      TYPE ztb_fi_doc_ruby-status,
           message     TYPE ztb_fi_doc_ruby-message,
           creator     TYPE ztb_fi_doc_ruby-creator,
           created_doc TYPE ztb_fi_doc_ruby-created_doc,
           reserve_doc TYPE ztb_fi_doc_ruby-reserve_doc,
         END OF lty_excel.

  DATA: lt_data_export TYPE TABLE OF lty_excel,
        ls_data_export TYPE lty_excel,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lt_head        TYPE TABLE OF lty_head WITH HEADER LINE,
        lv_fullpath    TYPE string.

  APPEND VALUE #( h = TEXT-t01 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t02 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t03 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t04 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t05 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t06 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t07 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t08 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t09 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t10 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t11 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t12 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t13 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t14 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t15 ) TO lt_head.

  LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_data>) WHERE flag = 'X'.
    MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_data_export.
    APPEND ls_data_export TO lt_data_export.
  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = 'Select File to Save' ##NO_TEXT
      default_extension    = 'XLS'
      file_filter          = 'Excel Files (*.xls, *.xlsx) | *.xls; *.xlsx;' ##NO_TEXT
    CHANGING
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_fullpath
      filetype                = 'ASC'        " Định dạng file, 'ASC' cho file .csv hoặc .txt
      write_field_separator   = 'X'          " Sử dụng dấu phân cách giữa các trường
    TABLES
      data_tab                = lt_data_export
      fieldnames              = lt_head[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc <> 0.
    MESSAGE TEXT-008 TYPE 'E'.
  ELSE.
    MESSAGE TEXT-013 && lv_fullpath TYPE 'S'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOAD_DATA_TABLE_Z
*&---------------------------------------------------------------------*
FORM load_data_table_z .
  DATA: lv_output_low  TYPE char10,
        lv_output_high TYPE char10.

  LOOP AT s_pay_do INTO DATA(ls_pay_do).
    PERFORM convert_alpha_input USING ls_pay_do-low CHANGING lv_output_low.
    PERFORM convert_alpha_input USING ls_pay_do-high CHANGING lv_output_high.
    ls_pay_do-low = lv_output_low.
    ls_pay_do-high = lv_output_high.

    MODIFY s_pay_do FROM ls_pay_do.
  ENDLOOP.

  SELECT doc~doc_date, "Document date"
      doc~pos_date, "Posting date"
      doc~doc_type, "Document type"
      doc~comp_code, "Company code "
      doc~cur, "Currency
      doc~bank_acct, "Bank account
      doc~amount, "Amount
      doc~vendor, "Vendor
      doc~ref_doc_no, "Reference document number
      doc~status, "Status
      doc~message, "Mesage
      doc~creator,
      doc~created_doc,
      doc~reserve_doc,
      doc~obj_key,
      doc~obj_type,
      doc~obj_sys,
      doc~pay_doc_num
      FROM ztb_fi_doc_ruby AS doc
      WHERE doc~vendor IN @s_ven AND doc~bank_acct IN @s_bank
                                 AND doc~comp_code IN @s_comp
                                 AND doc~pos_date IN @s_pos_d
                                 AND doc~pay_doc_num IN @s_pay_do
      ORDER BY doc~pay_doc_num
      INTO CORRESPONDING FIELDS OF TABLE @gt_fi_doc.
  IF sy-subrc = 4.
    MESSAGE TEXT-005 TYPE 'E' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOAD_VENDOR_DATA
*&---------------------------------------------------------------------*
FORM load_vendor_data .
  SELECT lfb1~lifnr AS vendor,
       lfb1~bukrs AS comp_code,
       lfb1~akont AS vendor_acct
       FROM lfb1
       WHERE lfb1~lifnr IN @s_ven AND lfb1~bukrs IN @s_comp
       INTO TABLE @gt_vendor.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOAD_DOCUMENT_TO_PAID
*&---------------------------------------------------------------------*
FORM load_document_to_paid .
  SELECT bsik~bukrs AS comp_code,
    bsik~lifnr AS vendor,
    bsik~belnr AS pay_doc_num,
    bsik~waers AS cur,
    bsik~wrbtr AS amount,
    bsik~shkzg AS debit_or_credit
  FROM bsik
  WHERE bsik~lifnr IN @s_ven AND bsik~bukrs IN @s_comp
  INTO TABLE @gt_payment.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXPORT_TEMPLATE
*&---------------------------------------------------------------------*
FORM export_template .
  TYPES: BEGIN OF lty_head,
           h(30) TYPE c,
         END OF lty_head,
         BEGIN OF lty_excel,
           flag        TYPE string,
           pay_doc_num TYPE ztb_fi_doc_ruby-pay_doc_num,
           doc_date    TYPE bapiache09-doc_date,
           pos_date    TYPE bapiache09-pstng_date,
           doc_type    TYPE bapiache09-doc_type,
           comp_code   TYPE bapiache09-comp_code,
           cur         TYPE bapiaccr09-currency,
           bank_acct   TYPE bapiacgl09-gl_account,
           amount      TYPE bapiaccr09-amt_doccur,
           vendor      TYPE bapiacap09-vendor_no,
           ref_doc_no  TYPE bapiache09-ref_doc_no,
         END OF lty_excel.

  DATA: lt_data_export TYPE TABLE OF lty_excel,
        ls_data_export TYPE lty_excel,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lt_head        TYPE TABLE OF lty_head WITH HEADER LINE,
        lv_fullpath    TYPE string.

  APPEND VALUE #( h = '' ) TO lt_head.
  APPEND VALUE #( h = TEXT-t01 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t02 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t03 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t04 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t05 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t06 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t07 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t08 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t09 ) TO lt_head.
  APPEND VALUE #( h = TEXT-t10 ) TO lt_head.

  ls_data_export-flag = ''.
  ls_data_export-pay_doc_num = '5200140'.
  ls_data_export-doc_date = '20241010'.
  ls_data_export-pos_date = '20241010'.
  ls_data_export-doc_type = 'KR'.
  ls_data_export-comp_code = 'MD01'.
  ls_data_export-cur = 'VND'.
  ls_data_export-bank_acct = '111100'.
  ls_data_export-amount = '39600'.
  ls_data_export-vendor = '8010000150'.

  APPEND ls_data_export TO lt_data_export.
  CLEAR ls_data_export.

  LOOP AT gt_fi_doc ASSIGNING FIELD-SYMBOL(<fs_fi_doc_data>) WHERE flag = 'X'.
    MOVE-CORRESPONDING <fs_fi_doc_data> TO ls_data_export.
    APPEND ls_data_export TO lt_data_export.
  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = 'Select File to Save' ##NO_TEXT
      default_extension    = 'XLS'
      file_filter          = 'Excel Files (*.xls, *.xlsx) | *.xls; *.xlsx;' ##NO_TEXT
    CHANGING
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_fullpath
      filetype                = 'ASC'        " Định dạng file, 'ASC' cho file .csv hoặc .txt
      write_field_separator   = 'X'          " Sử dụng dấu phân cách giữa các trường
    TABLES
      data_tab                = lt_data_export
      fieldnames              = lt_head[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc <> 0.
    MESSAGE TEXT-008 TYPE 'E'.
  ELSE.
    MESSAGE TEXT-013 && lv_fullpath TYPE 'S'.
  ENDIF.
ENDFORM.
