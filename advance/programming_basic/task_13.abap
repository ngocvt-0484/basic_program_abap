*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK13
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task13.
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
  gt_gender   TYPE TABLE OF gty_gender,
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
LOOP AT gt_employee INTO gs_employee.
  DATA(lv_gender_desc) = VALUE #( gt_gender[ gender_key = gs_employee-gender ]-gender_desc OPTIONAL ).
  DATA(lv_nationality_desc) = VALUE #( gt_nation[ nationality = gs_employee-nationality ]-nationality_desc OPTIONAL ).
  SKIP 1.
  WRITE: / 'Employee ID: ', gs_employee-id,
         / 'Full name: ', gs_employee-full_name,
         / 'Birthday: ', gs_employee-birthday DD/MM/YYYY,
         / 'Gender: ', lv_gender_desc,
         / 'nationality: ', lv_nationality_desc.
ENDLOOP.

"Total of people group by gender and output screen
ULINE.
SORT gt_employee BY gender.
WRITE: / 'Total of people group by gender and output screen: '.

LOOP AT gt_employee INTO gs_employee.
  AT NEW gender.
    gv_count = 0.
    DATA(gs_gender) = gt_gender[ gender_key = gs_employee-gender ].
    WRITE: / 'Gender :',  gs_gender-gender_desc.
  ENDAT.

  gv_count = gv_count + 1.

  AT END OF gender.
    WRITE: / 'Total count for gender: ', gv_count.
  ENDAT.
ENDLOOP.

"Total of age, group by Nationality & Gender, and output screen

SORT gt_employee BY gender nationality.
ULINE.
CLEAR: gv_age.

LOOP AT gt_employee INTO gs_employee.
  AT NEW nationality.
    READ TABLE gt_nation INTO DATA(gs_nation) WITH KEY nationality = gs_employee-nationality.
  ENDAT.

  AT NEW gender.
    READ TABLE gt_gender INTO gs_gender WITH KEY gender_key = gs_employee-gender.
  ENDAT.

  DATA(lv_age) = ( sy-datum - gs_employee-birthday ) / 365.
  gv_age = gv_age + lv_age.

  AT END OF nationality.
    WRITE: / |Nationality: { gs_nation-nationality_desc }, Gender: { gs_gender-gender_desc } Total age: { gv_age } |.
    gv_age = 0.
  ENDAT.
ENDLOOP.

"Use one loop with LOOP - AT…ENDAT to execute exercise 2 and 3.
ULINE.
CLEAR: gv_age, gv_count.

LOOP AT gt_employee INTO gs_employee.
  AT NEW nationality.
    READ TABLE gt_nation INTO gs_nation WITH KEY nationality = gs_employee-nationality.
  ENDAT.

  AT NEW gender.
    gv_count = 0.
    READ TABLE gt_gender INTO gs_gender WITH KEY gender_key = gs_employee-gender.
    WRITE: / 'Gender: ', gs_gender-gender_desc.
  ENDAT.


  lv_age = ( sy-datum - gs_employee-birthday ) / 365.
  gv_age = gv_age + lv_age.

  gv_count = gv_count + 1.

  AT END OF nationality.
    WRITE: / |Nationality: { gs_nation-nationality_desc }, Gender: { gs_gender-gender_desc } Total age: { gv_age } |.
    gv_age = 0.
  ENDAT.

  AT END OF gender.
    WRITE: / 'Total count by gender: ', gv_count.
  ENDAT.
ENDLOOP.
