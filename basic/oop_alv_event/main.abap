*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_TEST_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zpg_ruby_alv_oop_flow_top.
INCLUDE zpg_ruby_alv_oop_flow_f01.

START-OF-SELECTION.
  PERFORM get_all_condition_data.
  PERFORM get_data.

END-OF-SELECTION.

  PERFORM display_data_alv.
