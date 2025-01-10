*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task1.

START-OF-SELECTION.
  ULINE AT 80(60). "Ve duong gach ngang bat dau tu cot thu 80, do dai 60

  WRITE: /, 80 TEXT-001.

  WRITE: /, 80 TEXT-002, sy-datum COLOR COL_NEGATIVE .
  WRITE: /, 80 TEXT-003, sy-uzeit COLOR COL_NEGATIVE .
  WRITE: /, 80 TEXT-004, sy-uname COLOR COL_NEGATIVE .
  SKIP 1.
  ULINE AT 80(60).
