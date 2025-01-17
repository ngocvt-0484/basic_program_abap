*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_TEST_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_ruby_alv_oop.
INCLUDE ZPG_RUBY_ALV_OOP_TOP.
INCLUDE ZPG_RUBY_ALV_OOP_F01.

START-OF-SELECTION.
  PERFORM get_all_condition_data.
  PERFORM get_data.

END-OF-SELECTION.

  PERFORM display_data_alv.
