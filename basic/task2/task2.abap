*&---------------------------------------------------------------------*
*& Report ZPG_RUBY_TEST_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_ruby_test_4.

INCLUDE ZPG_RUBY_TEST_4_TOP. "Data decleration"
INCLUDE ZPG_RUBY_TEST_4_F01. "Subroutine"

* Start of selection
START-OF-SELECTION.
  "get data subject
  PERFORM GET_DATA_SUBJECT USING s_su[] CHANGING gt_subject.

  "get data student
  PERFORM GET_DATA_STUDENT USING p_stu CHANGING gs_student.

  "get data score
  PERFORM GET_DATA_SCORE USING p_stu CHANGING gt_score.

END-OF-SELECTION.
  " list output data
  PERFORM DISPLAY_DATA_SUBJECT.
  PERFORM DISPLAY_DATA_STUDENT.
  PERFORM DISPLAY_DATA_SCORE.
