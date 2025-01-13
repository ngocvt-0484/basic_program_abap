*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK14
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task14.
TYPES:
  BEGIN OF gty_employee,
    gender      TYPE gesch,
    nationality TYPE natsl,
    id          TYPE persno,
    full_name   TYPE pad_name2,
    birthday    TYPE gbdat,
  END OF gty_employee,
  BEGIN OF gty_nationality,
    nationality      TYPE natsl,
    nationality_desc TYPE natio50,
  END OF gty_nationality,
  BEGIN OF gty_gender,
    gender_key  TYPE gesch,
    gender_desc TYPE val_text,
  END OF gty_gender,
  BEGIN OF gty_result,
    id               TYPE persno,
    full_name        TYPE pad_name2,
    birthday         TYPE gbdat,
    gender_desc      TYPE val_text,
    nationality_desc TYPE natio50,
  END OF gty_result.

DATA:
  gt_employee TYPE TABLE OF gty_employee,
  gs_employee TYPE gty_employee,
  gt_nation   TYPE TABLE OF gty_nationality,
  gs_nation   TYPE gty_nationality,
  gt_gender   TYPE TABLE OF gty_gender,
  gs_gender   TYPE gty_gender,
  gv_count    TYPE i,
  gv_age      TYPE i.

" ---------------fill data to internal table:
" Chèn dữ liệu vào bảng gt_employee
APPEND VALUE #( id = 1441 full_name = 'Rilke' birthday = '19590622' gender = 2  nationality = 'DE' ) TO gt_employee.
APPEND VALUE #( id = 14999 full_name = 'Bee Hua' birthday = '19800214' gender = 2  nationality = 'MY' ) TO gt_employee.
APPEND VALUE #( id = 50000 full_name = 'Schmidt' birthday = '15641026' gender = 2  nationality = 'DE'  ) TO gt_employee.
APPEND VALUE #( id = 100080 full_name = 'Harris' birthday = '16560816' gender = 1  nationality = 'US' ) TO gt_employee.
APPEND VALUE #( id = 100301 full_name = 'Patricia' birthday = '19500214' gender = 2  nationality = 'US' ) TO gt_employee.
APPEND VALUE #( id = 109561 full_name = 'Ethel Ballman' birthday = '19521020' gender = 2  nationality = 'US'  ) TO gt_employee.

* Cach 2 insert nhieu gia tri cung luc
*gt_employee = VALUE #(
*  ( id = 1419 full_name = 'Silke' birthday = '19590622' gender = 2 nationality = 'DE' )
*  ( id = 1499 full_name = 'Bee Hua' birthday = '19800214' gender = 2 nationality = 'MY' )
*  ( id = 50000 full_name = 'Schmidt' birthday = '19641026' gender = 2 nationality = 'DE' )
*  ( id = 100080 full_name = 'Harris' birthday = '19560816' gender = 1 nationality = 'US' )
*  ( id = 100301 full_name = 'Patricia' birthday = '19500214' gender = 2 nationality = 'US' )
*  ( id = 109551 full_name = 'Ethel Ballman' birthday = '19521020' gender = 2 nationality = 'US' )
*).

APPEND VALUE #( nationality = 'DE' nationality_desc = 'German' ) TO gt_nation.
APPEND VALUE #( nationality = 'MY' nationality_desc = 'Malaysia' ) TO gt_nation.
APPEND VALUE #( nationality = 'US' nationality_desc = 'American' ) TO gt_nation.

APPEND VALUE #( gender_key = '' gender_desc = 'unknown' ) TO gt_gender.
APPEND VALUE #( gender_key = '1' gender_desc = 'Male' ) TO gt_gender.
APPEND VALUE #( gender_key = '2' gender_desc = 'Female' ) TO gt_gender.

"Output screen information about: ID, Full name, Birthday, Gender (description), Nationality (description) of all employees
WRITE: / 'Output screen information about: ID, Full name, Birthday, Gender (description), Nationality (description) of all employees: '.
FORMAT COLOR COL_HEADING.
WRITE: /3 'ID', 15 'Full name', 40 'Birthday', 55 'Gender', 70 'Nationality'.
FORMAT COLOR OFF.

LOOP AT gt_employee INTO gs_employee.
  DATA(lv_gender_desc) = VALUE #( gt_gender[ gender_key = gs_employee-gender ]-gender_desc OPTIONAL ).
  DATA(lv_nationality_desc) = VALUE #( gt_nation[ nationality = gs_employee-nationality ]-nationality_desc OPTIONAL ).
  SKIP 1.
  WRITE: /3 gs_employee-id,
         15 gs_employee-full_name,
         40 gs_employee-birthday DD/MM/YYYY,
         55 lv_gender_desc,
         70 lv_nationality_desc.
ENDLOOP.

"Total of people group by gender and output screen
ULINE.
SORT gt_employee BY gender.
WRITE: / 'Total of people group by gender and output screen: '.

LOOP AT gt_employee INTO gs_employee
  GROUP BY ( gender = gs_employee-gender )
  ASSIGNING FIELD-SYMBOL(<fs_group>).

  gv_count = 0.
  READ TABLE gt_gender INTO gs_gender WITH KEY gender_key = <fs_group>-gender.
  LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_employee>).
    gv_count = gv_count + 1.
  ENDLOOP.

  WRITE: / 'Gender: ', gs_gender-gender_desc,
         / 'Total people: ', gv_count.
ENDLOOP.
ULINE.

"Total of age, group by Nationality & Gender, and output screen
WRITE: / 'Total of age, group by Nationality & Gender, and output screen:'.
LOOP AT gt_employee INTO gs_employee
  GROUP BY ( gender = gs_employee-gender nationality = gs_employee-nationality )
  ASSIGNING FIELD-SYMBOL(<fs_group_new>).
  READ TABLE gt_nation INTO gs_nation WITH KEY nationality = <fs_group_new>-nationality.
  READ TABLE gt_gender INTO gs_gender WITH KEY gender_key = <fs_group_new>-gender.

  LOOP AT GROUP <fs_group_new> ASSIGNING FIELD-SYMBOL(<fs_employee_new>).
    DATA(lv_age) = ( sy-datum - <fs_employee_new>-birthday ) / 365.
    gv_age = gv_age + lv_age.
  ENDLOOP.

  WRITE: / |Nationality: { gs_nation-nationality_desc }, Gender: { gs_gender-gender_desc } Total age: { gv_age } |.
  gv_age = 0.
ENDLOOP.
