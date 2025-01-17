*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_TEST_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_ruby_test_5.
INCLUDE zpg_ruby_test_5_top. "Data decleration"
INCLUDE zpg_ruby_test_5_f01. "Subroutine"

START-OF-SELECTION.
  PERFORM get_all_condition_data.
  PERFORM get_data.

END-OF-SELECTION.

  PERFORM display_data_alv.
