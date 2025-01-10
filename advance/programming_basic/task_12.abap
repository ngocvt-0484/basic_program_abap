*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSYR001_RUBY_TASK12.

TYPES: BEGIN OF gty_sflight,
       carrid TYPE sflight-carrid,
       connid TYPE sflight-connid,
       fldate TYPE sflight-fldate,
       price TYPE sflight-price,
       currency TYPE sflight-currency,
       planetype TYPE sflight-planetype,
       seatsmax TYPE sflight-seatsmax,
       END OF GTY_SFLIGHT.
DATA: gt_sflight TYPE TABLE OF gty_sflight,
      gs_sflight TYPE gty_sflight.

" Create a standard internal table with line type is SFLIGHT, and fill following data into it:
    gs_sflight-carrid = 'JL'.
    gs_sflight-connid = '4070'.
    gs_sflight-fldate = '20200720'.
    gs_sflight-price = '100000'.
    gs_sflight-currency = 'JPY'.
    gs_sflight-planetype = 'DC-10-10'.
    gs_sflight-seatsmax = 380.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200721'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200722'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200723'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200724'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200725'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200726'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200727'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200728'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200729'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200730'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200731'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200801'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200802'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200803'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200804'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200805'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200806'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200807'.
    APPEND gs_sflight TO gt_sflight.

    gs_sflight-fldate = '20200808'.
    APPEND gs_sflight TO gt_sflight.

" 2. From 1st aug 2020, change data of Japan Airlines for following: Airfare raise to 150000 JPY, Maximum capacity in economy class reduced to 300

    LOOP at gt_sflight INTO gs_sflight WHERE fldate >= '20200801'.
        gs_sflight-price = 150000.
        gs_sflight-seatsmax = 300.
        MODIFY gt_sflight FROM gs_sflight.
    ENDLOOP.

 "3. Create a standard internal table with line type is SBOOK, and move data from internal table in exercise 1 to it. with condition Flight date in August, and then output screen.
 DATA: gt_sbook TYPE TABLE OF sbook,
       gs_sbook TYPE sbook.
 DATA: alv_table TYPE REF TO cl_salv_table. " Đối tượng ALV



 LOOP AT gt_sflight INTO gs_sflight.
   if gs_sflight-fldate+4(2) = '08'.
     MOVE-CORRESPONDING gs_sflight to gs_sbook.
     APPEND gs_sbook TO gt_sbook.
   ENDIF.
 ENDLOOP.

 TRY.
    cl_salv_table=>factory( IMPORTING r_salv_table = alv_table
                            CHANGING  t_table      = gt_sbook ).

    alv_table->display( ). " Hiển thị ALV
  CATCH cx_salv_msg INTO DATA(lx_msg).
    WRITE: / 'Error displaying ALV:', lx_msg->get_text( ).
ENDTRY.
