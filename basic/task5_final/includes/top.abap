*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_FINAL_FI_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF gty_file,
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
         status      TYPE ztb_fi_doc_ruby-status,
         message     TYPE ztb_fi_doc_ruby-message,
         creator     TYPE ztb_fi_doc_ruby-creator,
         created_doc TYPE ztb_fi_doc_ruby-created_doc,
         reserve_doc TYPE ztb_fi_doc_ruby-reserve_doc,
         obj_key     TYPE ztb_fi_doc_ruby-obj_key,
         obj_type    TYPE ztb_fi_doc_ruby-obj_type,
         obj_sys     TYPE ztb_fi_doc_ruby-obj_sys,
       END OF gty_file,
       BEGIN OF gty_vendor,
         vendor      TYPE lfb1-lifnr,
         comp_code   TYPE lfb1-bukrs,
         vendor_acct TYPE lfb1-akont,
       END OF gty_vendor,
       BEGIN OF gty_payment,
         comp_code       TYPE  bsik-bukrs,
         vendor          TYPE bsik-lifnr,
         pay_doc_num     TYPE bsik-belnr,
         cur             TYPE bsik-waers,
         amount          TYPE bsik-wrbtr,
         debit_or_credit TYPE bsik-shkzg,
       END OF gty_payment.

DATA: gt_fieldcat      TYPE lvc_t_fcat,
      gs_fieldcat      TYPE lvc_s_fcat,
      gs_layout        TYPE lvc_s_layo,
      gt_catalog       TYPE slis_t_fieldcat_alv,
      gs_catalog       TYPE slis_fieldcat_alv,
      gv_layout        TYPE slis_layout_alv,
      gt_pop_cat       TYPE slis_t_fieldcat_alv,
      gv_pop_cat_line  TYPE i,
      gt_file          TYPE STANDARD TABLE OF gty_file,
      gs_file          TYPE gty_file,
      gt_raw           TYPE truxs_t_text_data,
      gt_item_gl       TYPE TABLE OF bapiacgl09,  "G/L Items
      gt_item_vi       TYPE TABLE OF bapiacap09,   "Vendor Items.
      gt_item_currency TYPE TABLE OF bapiaccr09, "bang chua du lieu tien: Currency items
      gt_return        TYPE TABLE OF bapiret2, "Return messages.
      gs_return        TYPE bapiret2,
      gs_header        TYPE bapiache09, "Thông tin header cua but toan"
      gs_item_gl       TYPE bapiacgl09,
      gs_item_vi       TYPE bapiacap09,
      gs_item_currency TYPE bapiaccr09,
      gs_item_tax      TYPE bapiactx09,
      gv_comp_code     TYPE bapiache09-comp_code,
      gv_pos_date      TYPE bapiache09-pstng_date,
      gv_vendor        TYPE bapiacap09-vendor_no,
      gv_bank          TYPE bapiacgl09-gl_account,
      gv_pay_doc       TYPE ztb_fi_doc_ruby-pay_doc_num,
      gt_fi_doc        TYPE TABLE OF gty_file,
      gs_fi_doc        TYPE gty_file,
      gt_vendor        TYPE TABLE OF gty_vendor,
      gs_vendor        TYPE gty_vendor,
      gs_payment       TYPE gty_payment,
      gt_payment       TYPE TABLE OF gty_payment.

CONSTANTS:
  gc_success   TYPE c VALUE 'S',
  gc_error     TYPE c VALUE 'E',
  gc_no_action TYPE c VALUE 'NULL',
  gc_credit    TYPE c VALUE 'H'.

SELECTION-SCREEN: FUNCTION KEY 1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
" Khai báo radio button
PARAMETERS: p_r_view RADIOBUTTON GROUP grp DEFAULT 'X' USER-COMMAND rad,
            p_r_up   RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-001.
"Declare Input Fields
SELECT-OPTIONS: s_comp FOR gv_comp_code MODIF ID g1 NO-EXTENSION,
                s_pos_d FOR gv_pos_date MODIF ID g1 NO-EXTENSION,
                s_ven FOR gv_vendor MODIF ID g1 NO-EXTENSION,
                s_bank FOR gv_bank MODIF ID g1 NO-EXTENSION,
                s_pay_do FOR gv_pay_doc MODIF ID g1 NO-EXTENSION.

PARAMETERS: p_file   TYPE localfile MODIF ID g2.
SELECTION-SCREEN END OF BLOCK b2.
