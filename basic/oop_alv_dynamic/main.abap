*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_DYNAMIC_ALV
*&---------------------------------------------------------------------*
*& T-code: ZTC_RUBY_DYNAMIC_ALV
*&---------------------------------------------------------------------*
REPORT zpg_ruby_dynamic_alv.

TYPES: BEGIN OF gty_total_per_year,
         company_code   TYPE bsak-bukrs,
         vendor         TYPE bsak-lifnr,
         fiscal_year    TYPE bsak-gjahr,    " Năm tài chính
         total_document TYPE i,    " Tổng số document dã clear
       END OF gty_total_per_year,
       BEGIN OF gty_vendor,
         company_code TYPE bsak-bukrs,
         vendor       TYPE bsak-lifnr,
       END OF gty_vendor.

DATA: gt_total_per_year TYPE TABLE OF gty_total_per_year,  " Bảng nội bộ lưu kết quả nhóm theo năm tài chính
      gs_total_per_year TYPE gty_total_per_year,           " Biến lưu từng dòng kết quả
      gt_vendor         TYPE TABLE OF gty_vendor,
      gs_vendor         TYPE gty_vendor,
      gv_from_year      TYPE i,
      gv_to_year        TYPE i.

DATA: gd_sel_year TYPE bsak-gjahr,
      gd_sel_comp TYPE bsak-bukrs,
      gd_sel_ven  TYPE bsak-lifnr.


DATA: gt_fldcat TYPE lvc_t_fcat,
      gs_fldcat TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo.

* for dynamic table
" khai báo các field-symbols trong ABAP, chúng hoạt động như các con trỏ linh hoạt, cho phép bạn trỏ đến các vùng nhớ hoặc bảng nội bộ mà không cần biết kiểu dữ liệu chính xác trước đó.
FIELD-SYMBOLS: <dyn_table> TYPE STANDARD TABLE,  " <dyn_table> là một field-symbol có kiểu là bảng nội bộ tiêu chuẩn (STANDARD TABLE), nhưng không xác định trước được kiểu của bảng
               <dyn_wa>, " Nó có thể trỏ đến một work area (vùng làm việc), tức là một bản ghi từ một bảng nội bộ nào đó.
               <fs_field>. "Đây là một field-symbol khác không có kiểu dữ liệu xác định trước, và nó có thể được sử dụng để trỏ đến các trường (fields) cụ thể của work area hoặc các cấu trúc. Bạn có thể sử dụng <fs1> để trỏ đến từng trường cụ thể của

* Create the dynamic internal table

DATA: new_table TYPE REF TO data,
      new_line  TYPE REF TO data.

DATA: fieldname(20)  TYPE c,
      fieldvalue(60) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b001 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_comp FOR gd_sel_comp  NO-EXTENSION.
SELECT-OPTIONS: s_ven FOR gd_sel_ven  NO-EXTENSION.
SELECT-OPTIONS: s_year FOR gd_sel_year OBLIGATORY NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b001.

START-OF-SELECTION.
  LOOP AT s_year.
    gv_from_year = s_year-low.
    gv_to_year = s_year-high.
  ENDLOOP.

  IF gv_from_year IS INITIAL OR gv_to_year IS INITIAL.
    MESSAGE: 'Please fill from year and to year' TYPE 'E'.
  ENDIF.
  PERFORM get_data.
  PERFORM build_dynamic_table.
  PERFORM build_data.
  PERFORM display_data_alv.

END-OF-SELECTION.


FORM get_data.
  SELECT bsak~bukrs AS company_code,
         bsak~lifnr AS vendor,
         bsak~gjahr AS fiscal_year,
         COUNT( * ) AS total_document
  FROM bsak
  WHERE bsak~gjahr IN @s_year
    AND bsak~bukrs IN @s_comp
    AND bsak~lifnr IN @s_ven
  GROUP BY  bsak~bukrs, bsak~lifnr, bsak~gjahr
  INTO CORRESPONDING FIELDS OF TABLE @gt_total_per_year.

  IF sy-subrc <> 0.
    MESSAGE 'Data not found' TYPE 'E'.
  ENDIF.

  LOOP AT gt_total_per_year INTO gs_total_per_year.
    gs_vendor-vendor = gs_total_per_year-vendor.
    gs_vendor-company_code = gs_total_per_year-company_code.

    APPEND gs_vendor TO gt_vendor.
  ENDLOOP.
  SORT gt_vendor BY company_code vendor.
  DELETE ADJACENT DUPLICATES FROM gt_vendor COMPARING company_code vendor. " Loai bo gia tri trung lap
ENDFORM.


FORM build_dynamic_table.
  DATA: lv_temp TYPE i,
        lv_text TYPE char4.
  lv_temp  = gv_from_year.

  CLEAR gs_fldcat.
  gs_fldcat-fieldname = 'COMPANY_CODE'.
  gs_fldcat-coltext = 'Company Code'.
  gs_fldcat-datatype = 'CHAR'.
  gs_fldcat-outputlen = '18'.

  APPEND gs_fldcat TO  gt_fldcat.

  CLEAR gs_fldcat.
  gs_fldcat-fieldname = 'VENDOR'.
  gs_fldcat-coltext = 'Vendor'.
  gs_fldcat-datatype = 'CHAR'.
  gs_fldcat-outputlen = '18'.

  APPEND gs_fldcat TO  gt_fldcat.

  DO.

    CLEAR gs_fldcat.
    lv_text = CONV char4( lv_temp ).

    CONCATENATE  'YEAR_' lv_text INTO gs_fldcat-fieldname.
    CONCATENATE 'Year_' lv_text INTO gs_fldcat-coltext.
    gs_fldcat-datatype = 'CHAR'.
    gs_fldcat-outputlen = '18'.

    APPEND gs_fldcat TO  gt_fldcat.

    IF lv_temp = gv_to_year.
      EXIT.
    ELSE.
      lv_temp = lv_temp + 1.
    ENDIF.
  ENDDO.
  BREAK-POINT.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
*     i_style_table   =
      it_fieldcatalog = gt_fldcat
*     i_length_in_byte          =
    IMPORTING
      ep_table        = new_table
*     e_style_fname   =
*      EXCEPTIONS
*     generate_subpool_dir_full = 1
*     others          = 2
    .
  IF sy-subrc <> 0.
*     Implement suitable error handling here
  ENDIF.
  BREAK-POINT.

  ASSIGN new_table->* TO <dyn_table>.
  CREATE DATA new_line LIKE LINE OF <dyn_table>.
  ASSIGN new_line->* TO <dyn_wa>.
  BREAK-POINT.

  gs_layout-cwidth_opt = abap_on. "ABAP_ON = 'X' la hang so
  gs_layout-zebra = abap_on.
ENDFORM.


FORM build_data.
  DATA: lv_temp TYPE i,
        lv_text TYPE char4.
  DATA: ls_vendor_data TYPE gty_total_per_year.

  LOOP AT gt_vendor INTO gs_vendor.
    lv_temp = gv_from_year.

    CLEAR: fieldname, fieldvalue.
    fieldname = 'COMPANY_CODE'.
    fieldvalue = gs_vendor-company_code.
    CONDENSE fieldvalue. "Loai bo khong trang dau cuoi neu co o fieldvalue
    ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs_field>. " Dòng này sử dụng lệnh ASSIGN để ánh xạ một trường của cấu trúc <dyn_wa> vào một field-symbol <fs1>.
    <fs_field> = fieldvalue. "Sau khi ánh xạ thành công, dòng này gán giá trị từ biến fieldvalue vào field-symbol <fs1>.
    "Kết quả là giá trị của company_code được gán vào trường tương ứng trong cấu trúc <dyn_wa>.


    CLEAR: fieldname, fieldvalue.
    fieldname = 'VENDOR'.
    fieldvalue = gs_vendor-vendor.
    CONDENSE fieldvalue.
    ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs_field>.
    <fs_field> = fieldvalue.

    DO.
      CLEAR: fieldname, fieldvalue, lv_text.
      lv_text = CONV char4( lv_temp ).
      CONCATENATE  'YEAR_' lv_text INTO fieldname.

      READ TABLE gt_total_per_year WITH KEY vendor = gs_vendor-vendor company_code = gs_vendor-company_code fiscal_year = lv_temp INTO ls_vendor_data.
      IF sy-subrc = 0.
        fieldvalue = ls_vendor_data-total_document.
      ELSE.
        fieldvalue = 0.
      ENDIF.
      CONDENSE fieldvalue.
      ASSIGN COMPONENT fieldname OF STRUCTURE <dyn_wa> TO <fs_field>.
      <fs_field> = fieldvalue.

      IF lv_temp = gv_to_year.
        EXIT.
      ELSE.
        lv_temp = lv_temp + 1.
      ENDIF.
    ENDDO.

    APPEND <dyn_wa> TO <dyn_table>.
  ENDLOOP.

ENDFORM.

FORM display_data_alv.
  DATA: lo_alv_table TYPE REF TO cl_gui_alv_grid.
  lo_alv_table = NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).


  CALL METHOD lo_alv_table->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layout
    CHANGING
      it_outtab                     = <dyn_table>
      it_fieldcatalog               = gt_fldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL SCREEN 9000.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ALV_GUI'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
