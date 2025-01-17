*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_ALV_OOP_MM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPG_RUBY_ALV_OOP_MM.

INCLUDE ZPG_RUBY_ALV_OOP_MM_TOP.
INCLUDE ZPG_RUBY_ALV_OOP_MM_F01.

START-OF-SELECTION.
  PERFORM get_po_data.
END-OF-SELECTION.

  PERFORM display_data.
