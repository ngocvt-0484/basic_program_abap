*&---------------------------------------------------------------------*
*& Report ZSYR001_RUBY_TASK15
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsyr001_ruby_task15.
DATA: gt_sflight TYPE TABLE OF zruby_sflight,
      gt_scarr   TYPE TABLE OF zruby_scarr,
      gt_sbook   TYPE TABLE OF zruby_sbook.

gt_scarr = VALUE #(
  ( carrid = 'SLI' carrname = 'Lufthansa' currcode = 'EUR' url = 'http://www.lufthansa.com' )
  ( carrid = 'SD' carrname = 'Singapore Airlines' currcode = 'SSO' url = 'http://www.singaporeair.com' )
).

gt_sflight = VALUE #(
  ( carrid = 'LH' connid = '400' fldate = '19950220' price = '950.00' currency = 'DEM' planetype = 'A319' seatsmax = 350 seatsocc = 3 paymentsum = '2635.00' )
  ( carrid = 'LH' connid = '454' fldate = '19951117' price = '1499.00' currency = 'DEM' planetype = 'A319' seatsmax = 350 seatsocc = 2 paymentsum = '2943.00' )
  ( carrid = 'LH' connid = '455' fldate = '19950619' price = '1190.00' currency = 'USD' planetype = 'A319' seatsmax = 220 seatsocc = 1 paymentsum = '1499.00' )
  ( carrid = 'LH' connid = '3577' fldate = '19950421' price = '5000.00' currency = 'LHT' planetype = 'A319' seatsmax = 220 seatsocc = 1 paymentsum = '600.00' )
  ( carrid = 'SD' connid = '25' fldate = '19950220' price = '849.00' currency = 'DEM' planetype = 'DC-10-10' seatsmax = 380 seatsocc = 2 paymentsum = '1684.00' )
).

gt_sbook = VALUE #(
  ( carrid = 'SQ' connid = '25' fldate = '19950220' bookid = '1' customid = '245' custtype = 'JP' luggweight = '226.000' invoice = 'X' class = 'G' forcuram = '2004.74' forcurkey = 'AUD' loccuram = '4408.08' loccurkey = 'SSO' order_date = '20120612'
counter = '188' agencynum = '189' passname = 'Qatar: Koslovski' )
  ( carrid = 'SQ' connid = '25' fldate = '19950220' bookid = '2' customid = '351' custtype = 'JP' luggweight = '186.000' invoice = 'X' class = 'G' forcuram = '2046.00' forcurkey = 'EUR' loccuram = '4640.08' loccurkey = 'SSO' order_date = '20120409'
counter = '189' agencynum = '189' passname = 'Hua Yule' )
  ( carrid = 'SQ' connid = '25' fldate = '19950220' bookid = '3' customid = '253' custtype = 'JP' luggweight = '188.000' invoice = 'X' class = 'G' forcuram = '4840.08' forcurkey = 'EUR' loccuram = '4640.08' loccurkey = 'SSO' order_date = '20121224'
counter = '189' agencynum = '189' passname = 'Wanet Helier' )
  ( carrid = 'SQ' connid = '25' fldate = '19950220' bookid = '4' customid = '252' custtype = 'JP' luggweight = '152.000' invoice = 'X' class = 'G' forcuram = '2663.80' forcurkey = 'EUR' loccuram = '4408.08' loccurkey = 'SSO' order_date = '20120311'
counter = '189' agencynum = '189' passname = 'Ulla Lastenbach' )
  ( carrid = 'SQ' connid = '25' fldate = '19950220' bookid = '5' customid = '442' custtype = 'JP' luggweight = '104.000' invoice = 'X' class = 'G' forcuram = '7940.13' forcurkey = 'AUD' loccuram = '3842.02' loccurkey = 'SSO' order_date = '20121219'
counter = '189' agencynum = '189' passname = 'Simon Rahn' )
  ( carrid = 'LH' connid = '400' fldate = '19950220' bookid = '6' customid = '36' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '7982.79' forcurkey = 'GBP' loccuram = '1265.40' loccurkey = 'EUR' order_date = '20130305'
counter = '189' agencynum = '189' passname = 'Christine Picard' )
  ( carrid = 'LH' connid = '400' fldate = '19950220' bookid = '7' customid = '240' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '1983.70' forcurkey = 'SSO' loccuram = '1198.00' loccurkey = 'EUR' order_date = '20130325'
counter = '189' agencynum = '189' passname = 'Jana Sunford' )
  ( carrid = 'LH' connid = '400' fldate = '19950220' bookid = '8' customid = '250' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '1992.20' forcurkey = 'EUR' loccuram = '1132.20' loccurkey = 'EUR' order_date = '20130423'
counter = '189' agencynum = '189' passname = 'Thino Domerech' )
  ( carrid = 'LH' connid = '400' fldate = '19950220' bookid = '9' customid = '115' custtype = 'JP' luggweight = '28.000' invoice = 'X' class = 'G' forcuram = '702.30' forcurkey = 'GBP' loccuram = '1132.20' loccurkey = 'EUR' order_date = '20130207'
counter = '189' agencynum = '189' passname = 'Thomas Sommer' )
  ( carrid = 'LH' connid = '400' fldate = '19950220' bookid = '10' customid = '452' custtype = 'JP' luggweight = '186.000' invoice = 'X' class = 'G' forcuram = '1332.00' forcurkey = 'GBP' loccuram = '1332.00' loccurkey = 'EUR' order_date = '20121205'
counter = '189' agencynum = '189' passname = 'Claire Helier' )
  ( carrid = 'LH' connid = '455' fldate = '19950619' bookid = '11' customid = '36' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '7984.78' forcurkey = 'GBP' loccuram = '1285.40' loccurkey = 'EUR' order_date = '20130305'
counter = '189' agencynum = '189' passname = 'Christine Picard' )
  ( carrid = 'LH' connid = '455' fldate = '19950619' bookid = '12' customid = '240' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '1983.70' forcurkey = 'SSO' loccuram = '1198.00' loccurkey = 'EUR' order_date = '20130325'
counter = '189' agencynum = '189' passname = 'Jana Sunford' )
  ( carrid = 'LH' connid = '464' fldate = '19950619' bookid = '13' customid = '352' custtype = 'JP' luggweight = '202.000' invoice = 'X' class = 'G' forcuram = '1932.20' forcurkey = 'EUR' loccuram = '1132.20' loccurkey = 'EUR' order_date = '20130423'
counter = '189' agencynum = '189' passname = 'Thino Domerech' )
  ( carrid = 'LH' connid = '454' fldate = '19950619' bookid = '14' customid = '115' custtype = 'JP' luggweight = '28.000' invoice = 'X' class = 'G' forcuram = '702.30' forcurkey = 'GBP' loccuram = '1132.20' loccurkey = 'EUR' order_date = '20130207'
counter = '189' agencynum = '189' passname = 'Thomas Sommer' )
  ( carrid = 'LH' connid = '3577' fldate = '19950421' bookid = '15' customid = '452' custtype = 'JP' luggweight = '186.000' invoice = 'X' class = 'G' forcuram = '1332.00' forcurkey = 'EUR' loccuram = '1332.00' loccurkey = 'EUR' order_date = '20121209'
counter = '189' agencynum = '189' passname = 'Claire Helier' )
).

" Chèn dữ liệu vào các bảng
DELETE FROM zruby_sflight.
DELETE FROM zruby_scarr.
DELETE FROM zruby_sbook.
INSERT zruby_sflight FROM TABLE gt_sflight.
INSERT zruby_scarr FROM TABLE gt_scarr.
INSERT zruby_sbook FROM TABLE gt_sbook.

IF sy-subrc = 0.
  WRITE: / 'Data inserted successfully.'.
ELSE.
  WRITE: / 'Error inserting data.'.
ENDIF.
