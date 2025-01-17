*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_TEST_4_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA_SUBJECT
*&---------------------------------------------------------------------*
FORM get_data_subject USING VALUE(uv_s_su) TYPE gty_subject_ids
      CHANGING VALUE(ct_subject) LIKE gt_subject.

  DATA: lt_subject TYPE TABLE OF ty_subject.

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
  WHERE subject~subject_id IN @uv_s_su
  GROUP BY subject~subject_id, subject~name_subject, class~teacher_id, teacher~fullname, class~hyear, class~period
  ORDER BY subject~subject_id ASCENDING
  INTO TABLE @lt_subject.

  IF lt_subject IS NOT INITIAL.
    ct_subject = lt_subject.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_DATA_SCORE
*&---------------------------------------------------------------------*
FORM get_data_score USING VALUE(uv_p_stu) TYPE zde_student_id_ruby
      CHANGING VALUE(ct_score) LIKE gt_score.
  DATA: lt_score TYPE STANDARD TABLE OF ty_score.

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
  WHERE score~student_id = @uv_p_stu
  ORDER BY subject~subject_id ASCENDING
  INTO CORRESPONDING FIELDS OF TABLE @lt_score.

  IF lt_score IS NOT INITIAL.
    ct_score = lt_score.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SUBJECT
*&---------------------------------------------------------------------*
FORM display_data_subject .
  WRITE: / '---- Danh sach mon hoc: -------------'.

  IF gt_subject IS NOT INITIAL.
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
ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_SCORE
*&---------------------------------------------------------------------*
FORM display_data_score .
  IF gt_score IS NOT INITIAL.
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_STUDENT
*&---------------------------------------------------------------------*
FORM get_data_student USING VALUE(uv_p_stu) TYPE zde_student_id_ruby
      CHANGING VALUE(ct_student) LIKE gs_student.
  DATA: lt_student TYPE ty_student.

  SELECT SINGLE
    student~student_id,
    student~fullname,
    student~date_of_birth
    FROM ztb_student_ruby AS student INTO @lt_student WHERE student_id = @uv_p_stu.

  IF lt_student IS NOT INITIAL.
    ct_student = lt_student.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_STUDENT
*&---------------------------------------------------------------------*
FORM display_data_student .
  DATA: lv_date_of_birth TYPE c LENGTH 10.

  CALL FUNCTION 'ZFM_RUBY_FORMAT_DATE'
    EXPORTING
      iv_date = gs_student-date_of_birth
    IMPORTING
      ev_date = lv_date_of_birth.

  IF gs_student IS NOT INITIAL.
    ULINE.
    skip 4.
    WRITE: / '------Data diem hoc sinh:--------------------'.
    WRITE: / 'Ma sinh vien: ', gs_student-student_id.
    WRITE: / 'Ho va ten: ', gs_student-fullname.
    WRITE: / 'Ngay sinh: ', lv_date_of_birth .
    SKIP 4.
  ELSE.
    ULINE.
    skip 4.
    WRITE: / 'Khong tim thay hoc sinh voi ID: ', p_stu.
  ENDIF.
ENDFORM.
