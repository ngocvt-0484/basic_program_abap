*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_TEST_4_TOP
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_subject,
    subject_id    TYPE zde_subject_id_ruby,
    name_subject  TYPE zde_name_subject_ruby,
    teacher_id    TYPE zde_teacher_id_ruby,
    fullname      TYPE zde_teacher_fullname_ruby,
    hyear         TYPE zde_hyear_ruby,
    period        TYPE zde_period_ruby,
    count_student TYPE i,
  END OF ty_subject,

  BEGIN OF ty_student,
    student_id TYPE zde_student_id_ruby,
    fullname   TYPE zde_student_fullname_ruby,
    date_of_birth TYPE zde_student_date_of_birth_ruby,
  END OF ty_student,

  BEGIN OF ty_score,
    subject_id    TYPE zde_subject_id_ruby,
    name_subject  TYPE zde_name_subject_ruby,
    score15_1     TYPE zde_score15_1_ruby,
    score15_2     TYPE zde_score15_2_ruby,
    score15_3     TYPE zde_score15_3_ruby,
    score15_4     TYPE zde_score15_4_ruby,
    score45_1     TYPE zde_score45_1_ruby,
    score45_5     TYPE zde_score45_5_ruby,
    score_average TYPE p DECIMALS 2,
    result        TYPE string,
  END OF ty_score.

TYPES: gty_subject_ids TYPE RANGE OF zde_subject_id_ruby.

DATA: v_subject  TYPE zde_subject_id_ruby,
      gt_subject TYPE STANDARD TABLE OF ty_subject,
      gs_subject TYPE ty_subject,
      gs_student TYPE ty_student,
      gt_score   TYPE STANDARD TABLE OF ty_score,
      gs_score   TYPE ty_score,
      lv_seq     TYPE numc3,
      lv_average TYPE p DECIMALS 2.

CONSTANTS:
  tmp_point_65 TYPE p DECIMALS 1 VALUE '6.5',
  tmp_point_75 TYPE p DECIMALS 1 VALUE '7.5',
  tmp_point_85 TYPE p DECIMALS 1 VALUE '8.5'.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.
PARAMETERS: p_stu TYPE zde_student_id_ruby DEFAULT 'S1' OBLIGATORY.
SELECT-OPTIONS s_su FOR v_subject.
SELECTION-SCREEN END OF BLOCK b01.
