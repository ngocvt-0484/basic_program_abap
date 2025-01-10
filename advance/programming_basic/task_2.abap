*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task2.
TYPES: te_n2 TYPE n LENGTH 2.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.
PARAMETERS: p_num01 TYPE te_n2 OBLIGATORY,
            p_num02 TYPE te_n2 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b01.

START-OF-SELECTION.
  DATA(lv_compare) = COND string( WHEN p_num01 > p_num02 THEN '>'
                                  WHEN p_num01 < p_num02 THEN '<'
                                  ELSE '='
                                 ).
  DATA(lv_result) = p_num02 * ( p_num01 + p_num01 * p_num02 ).
  WRITE: | P_NUM01 { lv_compare } P_NUM02|.
  SKIP 1.
  WRITE: | P_NUM02 * ( P_NUM01 + P_NUM01 * P_NUM02 ) = { lv_result } |.
