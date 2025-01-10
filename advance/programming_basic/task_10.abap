*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK10
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSYR001_RUBY_TASK10.

DATA: lv_index   TYPE i VALUE 0,      " Chỉ số để duyệt qua chuỗi
      lv_letter  TYPE c LENGTH 1,     " Ký tự hiện tại
      lv_alphabet TYPE string VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'. " Bảng chữ cái

START-OF-SELECTION.

  WHILE lv_index < strlen( sy-abcde ). " Lặp qua từng ký tự trong bảng chữ cái, dung sy-abcde thay the bien lv_alphabet
    lv_letter = sy-abcde+lv_index(1). " Lấy ký tự tại vị trí hiện tại
    WRITE: / lv_letter.                  " Xuất ký tự ra màn hình
    lv_index = lv_index + 1.             " Tăng chỉ số lên 1
  ENDWHILE.
