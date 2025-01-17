*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_TEST_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_ruby_test_3.

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

IF p_stu IS INITIAL.
  MESSAGE 'please enter data student.' TYPE 'E'.
ENDIF.



SELECT subject~subject_id,
  subject~name_subject,
  class~teacher_id,
  teacher~fullname,
  class~hyear,
  class~period,
  COUNT( DISTINCT score~student_id ) AS count_student
  FROM ztb_class_ruby AS class
  INNER JOIN ztb_subject_ruby AS subject ON class~subject_id = subject~subject_id
  INNER JOIN ztb_teacher_ruby AS teacher ON class~teacher_id = teacher~teacher_id
  INNER JOIN ztb_score_ruby AS score ON class~class_id = score~class_id
  WHERE subject~subject_id IN @s_su
  GROUP BY subject~subject_id, subject~name_subject, class~teacher_id, teacher~fullname, class~hyear, class~period
  ORDER BY subject~subject_id ASCENDING
  INTO TABLE @gt_subject.

WRITE: / '---- Danh sach mon hoc: -------------'.

IF sy-subrc = 0.
  WRITE: / 'STT', 5 'Ma mon hoc', 30 'Ten mon hoc', 50 'Ma giao vien', 70 'Ten giao vien', 90 'Nam hoc', 110 'Hoc ky', 130 'So hoc sinh'.
  lv_seq = 0.
  LOOP AT gt_subject INTO gs_subject.
    ADD 1 TO lv_seq.

    WRITE: / lv_seq,
    5 gs_subject-subject_id,
    30 gs_subject-name_subject,
    50 gs_subject-teacher_id,
    70 gs_subject-fullname,
    90 gs_subject-hyear,
    110 gs_subject-period,
    130 gs_subject-count_student.
  ENDLOOP.
ENDIF.

SKIP 4.
WRITE: / '------Data diem hoc sinh:--------------------'.

SELECT SINGLE
  student~student_id,
  student~fullname,
  student~date_of_birth
  FROM ztb_student_ruby AS student INTO @gs_student WHERE student_id = @p_stu.

IF sy-subrc = 0.
  WRITE: / 'Ma sinh vien: ' && gs_student-student_id.
  WRITE: / 'Ho va ten: ' && gs_student-fullname.
  WRITE: / 'Ngay sinh: '.
  WRITE: / gs_student-date_of_birth .
ENDIF.
SKIP 4.

SELECT subject~subject_id,
  subject~name_subject,
  score~score15_1,
  score~score15_2,
  score~score15_3,
  score~score15_4,
  score~score45_1,
  score~score45_5
  FROM ztb_score_ruby AS score
  INNER JOIN ztb_class_ruby AS class ON score~class_id = class~class_id
  INNER JOIN ztb_subject_ruby AS subject ON class~subject_id = subject~subject_id
  WHERE score~student_id = @p_stu
  ORDER BY subject~subject_id ASCENDING
  INTO CORRESPONDING FIELDS OF TABLE @gt_score.

IF sy-subrc = 0.
  WRITE: / 'STT',
    7 'Ma mon hoc',
    22 'Ten mon hoc',
    38 'Diem 15p_1',
    53 'Diem 15p_2',
    67  'Diem 15p_3',
    81 'Diem 15p_4',
    95 'Diem 45p_1',
    110 'Diem 45p_5',
    125 'DiemTB',
    140 'KQ'.

  lv_seq = 0.
  lv_average = 0.
  LOOP AT gt_score INTO gs_score.
    ADD 1 TO lv_seq.
    gs_score-score_average = ( gs_score-score15_1 + gs_score-score15_2 + gs_score-score15_3 + gs_score-score15_4 +
      ( gs_score-score45_1 + gs_score-score45_5 ) * 2 ) / 8.
    lv_average = ( gs_score-score15_1 + gs_score-score15_2 + gs_score-score15_3 + gs_score-score15_4 +
      ( gs_score-score45_1 + gs_score-score45_5 ) * 2 ) / 8.

    IF gs_score-score15_1 < 2 OR
      gs_score-score15_2 < 2 OR
      gs_score-score15_3 < 2 OR
      gs_score-score15_4 < 2 OR
      gs_score-score45_1 < 4 OR
      gs_score-score45_5 < 4.

      gs_score-result = TEXT-t01.

    ELSE.
      IF gs_score-score_average >= 5 AND gs_score-score_average < 7.
        gs_score-result = TEXT-t02.
      ELSEIF gs_score-score_average >= 7 AND gs_score-score_average < tmp_point_85 AND gs_score-score45_1 > tmp_point_65 AND gs_score-score45_5 > tmp_point_65.
        gs_score-result = TEXT-t03.
      ELSEIF  gs_score-score_average >= tmp_point_85 AND gs_score-score45_1 > tmp_point_75 AND gs_score-score45_5 > tmp_point_75.
        gs_score-result = TEXT-t04.
      ELSE.
        gs_score-result = TEXT-t05.
      ENDIF.
    ENDIF.

    WRITE: / lv_seq,
      7 gs_score-subject_id,
      22 gs_score-name_subject,
      38 gs_score-score15_1,
      53 gs_score-score15_2,
      67 gs_score-score15_3,
      81 gs_score-score15_4,
      95 gs_score-score45_1,
      110 gs_score-score45_5,
      125 gs_score-score_average,
      140 gs_score-result.

  ENDLOOP.
ENDIF.
