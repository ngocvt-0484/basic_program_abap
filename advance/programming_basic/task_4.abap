*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task4.

"1.Declare a TYPE as a character with 10 positions.
DATA: lv_char TYPE c LENGTH 10.

"2. Declare an integer.
DATA: lv_integer TYPE i.

"3. Declare a type as a number with 7 positions.
TYPES: ty_number TYPE numc7.

"4. Declare a date type.
TYPES: ty_date TYPE d.

"5. Declare a time type.
TYPES: ty_time TYPE t.

"6. Declare a structure type with 5 fields, each field with the same types from exercises 1 to 5.
TYPES: BEGIN OF ty_structure,
         field1 TYPE c LENGTH 10,
         field2 TYPE i,
         field3 TYPE numc7,
         field4 TYPE t,
         field5 TYPE d,
       END OF ty_structure.
"7. Declare a type using the global structure SFLIGHT
TYPES: ty_sflight TYPE sflight.

"8. Declare a structure type with the following components of the global structure SFLIGHT:
"CARRID, CONNID, FLDATE, PRICE, CURRENCY, PLANETYPE, SEATSMAX and SEATSOCC.

TYPES: BEGIN OF ty_structure2,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
         currency TYPE sflight-currency,
         plantype TYPE sflight-planetype,
         seatmax  TYPE sflight-seatsmax,
         seatsocc TYPE sflight-seatsocc,
       END OF ty_structure2.
"9. Declare a structure type with the following components of the global structure SBOOK:
"CARRID, CONNID, FLDATE, BOOKID, CUSTOMID.

TYPES: BEGIN OF ty_structure3,
         carrid   TYPE sbook-carrid,
         connid   TYPE sbook-connid,
         fldate   TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         customid TYPE sbook-customid,
       END OF ty_structure3.

"10. Declare a structure containing all the fields mentioned in exercises 8 and 9.  Check it using the ABAP Debugger.

TYPES: BEGIN OF ty_structure4,
         include  TYPE ty_structure2,
         carrid2  TYPE sbook-carrid,
         connid2  TYPE sbook-connid,
         fldate2  TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         customid TYPE sbook-customid,
       END OF ty_structure4.
DATA: lv_test TYPE ty_structure4.
WRITE: 'ahihi'.
"11. Declare a table type of integers
"Cach 1:
TYPES: BEGIN OF ty_integer,
         num1 TYPE i,
       END OF ty_integer.

TYPES: gt_integer TYPE TABLE OF ty_integer.

"12. Declare a table type with all components of the global structure SFLIGHT
TYPES: gtt_sflight TYPE STANDARD TABLE OF sflight.

"13. Declare a table type using the structure type created in exercise 8.
TYPES: gtt_exercise8 TYPE STANDARD TABLE OF ty_structure2.

"14.Declare a table type with the following components of the table SBOOK:
" CARRID, CONNID, FLDATE, BOOKID, CUSTOMID but using CUSTOMID as part of the table key

TYPES: BEGIN OF ty_book,
         carrid   TYPE sbook-carrid,
         connid   TYPE sbook-connid,
         fldate   TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         customid TYPE sbook-customid,
       END OF ty_book.

TYPES: tt_book TYPE SORTED TABLE OF ty_book WITH UNIQUE KEY customid.

"15. Declare a variable of type character with 10 positions and give it ‘Hello ABAP’ as an initial value.

DATA: lv_char2 TYPE c LENGTH 10 VALUE 'hello ABAP'.

"16. Declare a variable of numeric type with 4 positions and initial value 1234
DATA: lv_number2 TYPE numc4 VALUE '1234'.

"17. Declare a variable of type integer with initial value 42.
DATA: lv_number3 TYPE i VALUE '42'.

"18. Declare a variable of type integer with initial value 12.72.
DATA: lv_decimal TYPE decfloat16 VALUE '12.72'.

"19. Declare a variable of type date and give it halloween day
DATA: lv_halloween TYPE d VALUE '20231031'.

"20. Declare a packed number variable with 7 decimal places.\
DATA: lv_packed_number TYPE p LENGTH 8 DECIMALS 7.

"21. Declare a variable of type S_CARR_ID.
DATA: lv_carr_id TYPE s_carr_id.

"22. Declare a variable of the same type of field carrid from table SPFLI.
DATA: lv_carrid TYPE spfli-carrid.

"23. Declare a variable of the same type of field FLDATE table SFLIGHT.
DATA: lv_fldate TYPE sflight-fldate.

"24. Declare a structure of the same type of SBOOK.
DATA: ls_sbook TYPE sbook.

"25. Declare a structure with fields of the table SFLIGHT carrid, CONNID, FLDATE, PRICE, CURRENCY, PLANETYPE, and SEATSMAX SEATSOCC.
TYPES: BEGIN OF ty_sflight2,
         carrid    TYPE sflight-carrid,
         connid    TYPE sflight-connid,
         fldate    TYPE sflight-fldate,
         price     TYPE sflight-price,
         currency  TYPE sflight-currency,
         planetype TYPE sflight-planetype,
         seatsmax  TYPE sflight-seatsmax,
         seatsocc  TYPE sflight-seatsocc,
       END OF ty_sflight2.
"26. Declare a structure with all fields of the table SBOOK and the field TELEPHONE from SCUSTOM table.
DATA: BEGIN OF ls_sbook_custom,
        " Fields from SBOOK
        carrid     TYPE sbook-carrid,
        connid     TYPE sbook-connid,
        fldate     TYPE sbook-fldate,
        bookid     TYPE sbook-bookid,
        customid   TYPE sbook-customid,
        custtype   TYPE sbook-custtype,
        smoker     TYPE sbook-smoker,
        lugweight  TYPE sbook-luggweight,
        wunit      TYPE sbook-wunit,
        invoice    TYPE sbook-invoice,
        class      TYPE sbook-class,
        forcuram   TYPE sbook-forcuram,
        forcurkey  TYPE sbook-forcurkey,
        loccuram   TYPE sbook-loccuram,
        loccurkey  TYPE sbook-loccurkey,
        order_date TYPE sbook-order_date,
        counter    TYPE sbook-counter,
        agencynum  TYPE sbook-agencynum,
        cancelled  TYPE sbook-cancelled,
        reserved   TYPE sbook-reserved,
        passname   TYPE sbook-passname,
        passform   TYPE sbook-passform,
        passbirth  TYPE sbook-passbirth,

        " Additional field from SCUSTOM
        telephone  TYPE scustom-telephone,
      END OF ls_sbook_custom.
"27. Declare an internal table with fields of the table SBOOK CARRID, CONNID, FLDATE, BOOKID, CUSTOMID.
TYPES: BEGIN OF ty_sbook,
         carrid   TYPE sbook-carrid,
         connid   TYPE sbook-connid,
         fldate   TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         customid TYPE sbook-customid,
       END OF ty_sbook.

DATA: lt_sbook TYPE TABLE OF ty_sbook.

"28. Declare an internal table with all table fields from table SCARR.
DATA: lt_scarr TYPE TABLE OF scarr.
"29. Declare an internal table with all table fields SPFLI.
DATA: lt_spfli TYPE TABLE OF spfli.
"30. Declare an internal table with all table fields from SCARR and the field TELEPHONE from table SCUSTOM.
TYPES: BEGIN OF ty_combined,
         " Fields from SCARR
         carrid    TYPE scarr-carrid,
         carrname  TYPE scarr-carrname,
         currcode  TYPE scarr-currcode,
         url       TYPE scarr-url,
         " Field from SCUSTOM
         telephone TYPE scustom-telephone,
       END OF ty_combined.
DATA: lt_combined TYPE TABLE OF ty_combined.
"31. Declare a constant which contains your name
CONSTANTS: gc_my_name TYPE string VALUE 'VU THI NGOC'.

"32. Declare two constants which contain the values 'X' (true) and ' ' (false). Note: This is a common practice as ABAP does not contain a boolean primitive type.
CONSTANTS: gc_true  TYPE abap_bool VALUE 'X',
           gc_false TYPE abap_bool VALUE ''.

"33. Declare a constants which contains the 5 first decimals of Pi.
CONSTANTS: gc_pi TYPE p DECIMALS 5 VALUE '3.14159'.

"34. Declare a work area of constants. All components must be integers.
CONSTANTS: BEGIN OF gc_integers,
             constant1 TYPE i VALUE 10,
             constant2 TYPE i VALUE 20,
             constant3 TYPE i VALUE 30,
           END OF gc_integers.
"35. Declare a work area of 5 constant components. All of them should have different primitive types.
CONSTANTS: BEGIN OF c_work_area,
             int_type   TYPE i          VALUE 100,              " Integer
             char_type  TYPE c LENGTH 5 VALUE 'HELLO',          " Character
             float_type TYPE f          VALUE '123.45',         " Floating point
             date_type  TYPE d          VALUE '20231025',       " Date (YYYYMMDD)
             time_type  TYPE t          VALUE '153000',         " Time (HHMMSS)
           END OF c_work_area.
"36. Is it possible to declare an internal table of constants? => NO
"37. Declare all types and constants from type-pools ABAP and ICON.

TYPE-POOLS: abap, icon.

" Khai báo biến sử dụng kiểu từ ABAP type-pool
DATA: lv_char1 TYPE abap_char1,      " Kiểu ký tự
      lv_bool  TYPE abap_bool.      " Kiểu boolean
" Khai báo hằng số từ ABAP type-pool
CONSTANTS: lc_true  TYPE abap_bool VALUE abap_true,  " Hằng số TRUE
           lc_false TYPE abap_bool VALUE abap_false. " Hằng số FALSE
CONSTANTS: lc_icon TYPE icon_2 VALUE icon_okay.
"38. Declare a constant which type is the same of another constant.
CONSTANTS: lc_first_constant TYPE i VALUE 100.
CONSTANTS: lc_second_constant LIKE lc_first_constant VALUE 200.

"39. Declare a type which is used in another type, variable, work area, internal table and constant.
" Step 1: Declare a type
TYPES: BEGIN OF ty_person,
         id   TYPE i,          " ID of the person
         name TYPE string,     " Name of the person
         age  TYPE i,          " Age of the person
       END OF ty_person.

" Step 2: Declare a variable using the type
DATA: lv_person TYPE ty_person.

" Step 3: Declare a work area using the type
DATA: ls_person TYPE ty_person.

" Step 4: Declare an internal table using the type
DATA: lt_persons TYPE TABLE OF ty_person.

" Step 5: Declare a constant using the type
CONSTANTS: BEGIN OF gc_person,
             id   TYPE i VALUE 1,
             name TYPE string VALUE 'Ngoc Vu',
             age  TYPE i VALUE 30,
           END OF gc_person.
"40. Declare a variable which is used in another variable, type, work area, internal table and constant.

DATA: lv_base TYPE i VALUE 1.
DATA: lv_other_base LIKE lv_base VALUE 10.

TYPES: BEGIN OF ty_person2,
         id   LIKE lv_base,
         name TYPE string,
       END OF ty_person2.

DATA: ls_person1 TYPE ty_person2.
DATA: lt_person1 TYPE TABLE OF ty_person2.
CONSTANTS: lc_defaut LIKE lv_base VALUE 100.
