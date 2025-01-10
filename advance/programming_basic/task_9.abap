*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK9
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task9.

DATA: lv_counter TYPE i.
DATA: lv_number   TYPE i, " Current number being checked
      lv_divisor  TYPE i, " Divisor for checking primality
      lv_is_prime TYPE abap_bool. " Flag to indicate if the number is prime

START-OF-SELECTION.
  DO 21 TIMES.
    lv_counter = sy-index - 1. "sy-index start tu 1
    "WRITE: / 'Sy-index', sy-index.
    WRITE: / 'Number', lv_counter.
  ENDDO.


  " Loop from 0 to 20
  DO 21 TIMES.
    lv_number = sy-index - 1. " Adjust to start from 0
    lv_is_prime = abap_true. " Assume the number is prime

    " Skip checking for numbers less than 2 (not prime)
    IF lv_number < 2.
      CONTINUE.
    ENDIF.

    " Check divisors from 2 to (lv_number - 1)
    DO lv_number - 2 TIMES.
      lv_divisor = sy-index + 1. " Start divisors from 2
      IF lv_number MOD lv_divisor = 0.
        lv_is_prime = abap_false. " Not a prime number
        EXIT. " Exit the inner loop as the number is not prime
      ENDIF.
    ENDDO.

    " Output the number if it is prime
    IF lv_is_prime = abap_true.
      WRITE: / 'Prime number:', lv_number.
    ENDIF.
  ENDDO.
