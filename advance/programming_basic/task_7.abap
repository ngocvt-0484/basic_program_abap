*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK7
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task7.

DATA: str1      TYPE string VALUE 'System Applications and Products',
      str2      TYPE string VALUE 'in',
      str3      TYPE string VALUE 'Data Processing',
      str4 TYPE string VALUE '   Hello     World     ',
      lv_result TYPE string,
      lv_length TYPE i,
      lv_condensed TYPE string,
      lv_condensed_no_gap TYPE string,
      lv_position TYPE i,
      lv_substring TYPE string,
      s1 TYPE string,
      s2 TYPE string,
      s3 TYPE string,
      s4 TYPE string,
      s5 TYPE string,
      s6 TYPE string,
      s7 TYPE string.

"Use CONCATENATE statement and display result on screen
CONCATENATE str1 str2 str3 INTO lv_result.
WRITE: / 'Use CONCATENATE: ', lv_result.

"Use CONCATENATE with Space statement and display result on screen
CONCATENATE str1 str2 str3 INTO lv_result SEPARATED BY ' '.
WRITE: / 'Use CONCATENATE statement with space: ', lv_result.

"Use STRLEN statement
lv_length = STRLEN( str2 ).
WRITE: / 'Length str2: ', lv_length.

"use Condense: loai bo khoang trang thua dau cuoi
CONDENSE str4.
lv_condensed = str4.

" no-gap: loai bo tat ca khoang trang bao gom khoang trang o giua

CONDENSE str4 NO-GAPS.
lv_condensed_no_gap = str4.

WRITE: / 'Sau khi condense: ', lv_condensed, '!',
       / 'Sau khi condense co no-gap: ', lv_condensed_no_gap, '!'.

"Use SEARCH statement with keyword 'SAP' for ② and display result on screen
SEARCH lv_result FOR 'SAP'.
  IF sy-subrc = 0.
    lv_position = sy-fdpos + 1. " Vị trí bắt đầu từ 1
    WRITE: / 'Chuỗi con được tìm thấy tại vị trí:', lv_position.
  ELSE.
    WRITE: / 'Chuỗi con không được tìm thấy.'.
  ENDIF.

" Use SPLIT statement get 'Products' string and display result on screen
SPLIT lv_result at ' ' INTO s1 s2 s3 s4 s5 s6 s7.
WRITE: / 's1: ', s1,
       / 's2: ', s2,
       / 's3: ', s3,
       / 's4: ', s4,
       / 's5: ', s5,
       / 's6: ', s6,
       / 's7: ', s7.

" Use Substring get 'Application' string in  ② and display result on screen
lv_substring = substring( val = lv_result off = 7 len = 11 ).
WRITE: / 'Chuoi con substring: ', lv_substring.
