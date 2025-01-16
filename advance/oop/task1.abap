*&---------------------------------------------------------------------*
*& Report ZSYR002_RUBY_TASK1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr002_ruby_task1.
CLASS lcl_comparison DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_num1 TYPE n
                            iv_num2 TYPE n,
      compare_numbers,
      calculation.
  PRIVATE SECTION.
    DATA:
      mv_num1 TYPE n LENGTH 2,
      mv_num2 TYPE n LENGTH 2.
ENDCLASS.

CLASS lcl_comparison IMPLEMENTATION.
  METHOD constructor.
    mv_num1 = iv_num1.
    mv_num2 = iv_num2.
  ENDMETHOD.

  METHOD compare_numbers.
    IF mv_num1 > mv_num2.
      WRITE: / 'P_NUM01 is greater than P_NUM02'.
    ELSEIF mv_num1 < mv_num2.
      WRITE: / 'P_NUM01 is less than P_NUM02'.
    ELSE.
      WRITE: / 'P_NUM01 is equal to P_NUM02'.
    ENDIF.
  ENDMETHOD.

  METHOD calculation.
    DATA: lv_result TYPE i.
    lv_result = mv_num2 * ( mv_num1 + mv_num1 * mv_num2 ).
    WRITE: / 'The result of P_NUM02 * (P_NUM01 + P_NUM01 * P_NUM02) is:', lv_result.
  ENDMETHOD.
ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_num01 TYPE n LENGTH 2 OBLIGATORY,
            p_num02 TYPE n LENGTH 2 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  DATA: lo_calculator TYPE REF TO lcl_comparison.

  CREATE OBJECT lo_calculator
    EXPORTING
      iv_num1 = p_num01
      iv_num2 = p_num02.

  lo_calculator->compare_numbers( ).
  lo_calculator->calculation( ).
