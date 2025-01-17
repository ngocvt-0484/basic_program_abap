*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_TEST_5_F01
*&---------------------------------------------------------------------*
FORM build_fieldcat USING VALUE(p_rowpos)
                          VALUE(p_colpos)
                          VALUE(p_fieldname)
                          VALUE(p_header_text)
                          VALUE(p_length).
  gs_catalog-row_pos = p_rowpos.
  gs_catalog-col_pos = p_colpos.
  gs_catalog-fieldname = p_fieldname.
  gs_catalog-tabname = 'REPORT'.
  gs_catalog-outputlen = p_length.
  gs_catalog-seltext_m = p_header_text.
  gs_catalog-cfieldname = 'currency'.

  APPEND gs_catalog TO gt_catalog.
  CLEAR gs_catalog.
ENDFORM.


FORM get_all_condition_data.
  SELECT prcd~knumv AS doc_con, "Doc condition"
        prcd~kposn AS item_id, "Item id"
        t685t~kschl AS con_type, "Condition type"
        t685t~vtext AS con_name, "Condition name"
        prcd~kawrt AS basic_val, "Condition basic value"
        prcd~kbetr AS rate, "Condition rate",
        prcd~kwert AS con_val, "Condition value -> show total amount"
        prcd~waers AS cur "Currency"
        FROM prcd_elements AS prcd
        INNER JOIN t685t ON prcd~kschl = t685t~kschl AND t685t~spras = @sy-langu AND prcd~kappl = t685t~kappl
        INTO TABLE @gt_con.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_DATA
FORM get_data .
  SELECT DISTINCT ekpo~ebeln AS pur_doc, "Purchasing doc"
  ekpo~ebelp AS item,  "Item - PO item ID"
  ekpo~menge AS quality,  "Quality"
  ekpo~bprme AS uom,  "UOM - Order price unit"
  t024~eknam AS pur_name, "Purchasing group name",
  makt~maktx AS mat_desc, "Material description"
  ekpo~werks AS plant, "Plant"
  t001w~name1 AS plant_desc, "Plant descripton"
  ekpo~effwr AS amount, "Amount",
  ekko~waers AS currency, "Currency key",
  but000~type AS bp_type, "to take vendor name"
  but000~name_last AS name_last,
  but000~name_first AS name_first,
  but000~name_org1 AS nam1,
  but000~name_org2 AS name2,
  but000~name_org3 AS name3,
  but000~name_org4 AS name4,
  ekko~knumv AS doc_con,
  ekko~lifnr AS vendor_id,
  ekko~bukrs AS company_code,
  ekpo~netpr AS price
  FROM ekpo
  INNER JOIN ekko ON ekpo~ebeln = ekko~ebeln
  INNER JOIN t024 ON ekko~ekgrp = t024~ekgrp
  LEFT JOIN makt ON ekpo~matnr = makt~matnr
  INNER JOIN t001w ON ekpo~werks = t001w~werks
  INNER JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
  INNER JOIN ibpsupplier ON ibpsupplier~supplier = lfa1~lifnr
  INNER JOIN but000 ON ibpsupplier~businesspartner = but000~partner
  WHERE makt~spras = @sy-langu
    AND ekko~lifnr IN @s_sup
    AND ekko~ekorg IN @s_org
    AND ekko~ekgrp IN @s_pu_gr
    AND ekpo~ematn IN @s_ma
    AND ekko~ebeln IN @s_pur_do
    AND ekpo~ebelp IN @s_item
    AND ekko~bedat IN @s_d_date
    AND ekko~bstyp = @gc_doc_cat_po "Loc Type là standard PO"
  ORDER BY pur_doc
  INTO CORRESPONDING FIELDS OF TABLE @gt_item.

  IF gt_item IS NOT INITIAL.
    LOOP AT gt_item INTO gs_item.
      " Xu ly vendor name "
      IF gs_item-bp_type = 1.
        CONCATENATE gs_item-name_last gs_item-name_first INTO gs_item-vendor_name SEPARATED BY space.
      ELSEIF gs_item-name2 IS NOT INITIAL OR gs_item-name3 IS NOT INITIAL OR gs_item-name4 IS NOT INITIAL.
        CONCATENATE gs_item-name2 gs_item-name3 gs_item-name4 INTO gs_item-vendor_name SEPARATED BY space.
      ELSE.
        gs_item-vendor_name = gs_item-nam1.
      ENDIF.

      "Xu ly condition name"
      IF gt_con IS NOT INITIAL.
        DATA: lt_con     TYPE ztt_po_condition_ruby,
              lv_con_des TYPE string.

        SELECT * FROM @gt_con AS gt_con WHERE doc_con = @gs_item-doc_con AND item_id = @gs_item-item INTO TABLE @lt_con.
        LOOP AT lt_con ASSIGNING FIELD-SYMBOL(<ls_con_detail>).
          CONCATENATE <ls_con_detail>-con_name ' || ' INTO lv_con_des SEPARATED BY space.
          gs_item-con_desc = gs_item-con_desc && lv_con_des.
        ENDLOOP.
*        SHIFT gs_item-con_desc BY 3 PLACES RIGHT.
      ENDIF.

      MODIFY gt_item FROM gs_item.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data_alv .

  DATA: ls_exclude TYPE LINE OF slis_t_extab,
        lt_exclude TYPE slis_t_extab.

  CLEAR gt_catalog.

  PERFORM build_fieldcat USING '1' '1' 'pur_doc' 'Purchasing doc' '12'.
  PERFORM build_fieldcat USING '1' '2' 'item' 'Item' '12'.
  PERFORM build_fieldcat USING '1' '3' 'quality' 'Quanlity' '7'.
  PERFORM build_fieldcat USING '1' '4' 'uom' 'UOM' '5'.
  PERFORM build_fieldcat USING '1' '5' 'pur_name' 'Purchasing group name' '12'.
  PERFORM build_fieldcat USING '1' '6' 'vendor_name' 'Vendor name' '12'.
  PERFORM build_fieldcat USING '1' '7' 'con_desc' 'Condition type description' '10'.
  PERFORM build_fieldcat USING '1' '8' 'mat_desc' 'Material description' '20'.
  PERFORM build_fieldcat USING '1' '9' 'plant' 'Plant' '12'.
  PERFORM build_fieldcat USING '1' '10' 'plant_desc' 'Plant description' '20'.
  PERFORM build_fieldcat USING '1' '11' 'amount' 'Amount' '12'.
  PERFORM build_fieldcat USING '1' '12' 'currency' 'Currency' '10'.

  gv_layout-zebra = 'X'.
  gv_layout-colwidth_optimize = 'X'.

  ls_exclude-fcode = '&OUP'. "function code cua button sx tang dan - check se41"
  APPEND ls_exclude TO lt_exclude.
  CLEAR ls_exclude.

  ls_exclude-fcode = '&ODN'. "function code cua button sx giam dan - check se41"
  APPEND ls_exclude TO lt_exclude.
  CLEAR ls_exclude.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout                = gv_layout
      it_fieldcat              = gt_catalog
      "it_excluding = lt_exclude
      i_callback_program       = sy-repid
      i_callback_user_command  = 'SET_USER_COMMAND'
      i_callback_pf_status_set = 'SET_PF_STATUS' "Xu ly custom menu vs title"
      i_save                   = 'X' "Save lai layout"
    TABLES
      t_outtab                 = gt_item
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  CLEAR gv_layout.
  CLEAR lt_exclude.
ENDFORM.

FORM set_user_command USING p_ucomm TYPE sy-ucomm
                       p_selflddetails TYPE slis_selfield.
  DATA: lt_con TYPE ztt_po_condition_ruby.

  CASE p_ucomm.
      READ TABLE gt_item INTO DATA(gs_item) INDEX p_selflddetails-tabindex.

    WHEN '&IC1'. "Click vào row"
      SET PARAMETER ID 'BES' FIELD gs_item-pur_doc.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN .

      " Cach xu ly khac: hien thi ra man hinh ALV khac
      "DATA: lt_ekpo TYPE TABLE OF ekpo.

      "SELECT * FROM ekpo INTO TABLE lt_ekpo WHERE ebeln = gs_item-pur_doc.

*      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*        EXPORTING
*          i_callback_program = ' '
*          i_structure_name   = 'EKPO'
*        TABLES
*          t_outtab           = lt_ekpo
*        EXCEPTIONS
*          program_error      = 1
*          OTHERS             = 2.
    WHEN 'SEL_CON'. "Click vào icon show condition"
      IF gt_con IS NOT INITIAL.
        SELECT * FROM @gt_con AS gt_con WHERE doc_con = @gs_item-doc_con AND item_id = @gs_item-item INTO TABLE @lt_con.
      ENDIF.

      DATA :  g_exit(1) TYPE c.
      DESCRIBE TABLE gt_pop_cat LINES gv_pop_cat_line.
      IF gv_pop_cat_line = 0.
        APPEND VALUE #( fieldname = 'con_type' seltext_s = 'Type' col_pos = 1 ) TO gt_pop_cat.
        APPEND VALUE #( fieldname = 'con_name' seltext_s = 'Condition' seltext_l = 'Condition description' col_pos = 2 outputlen = 22  ) TO gt_pop_cat.
        APPEND VALUE #( fieldname = 'basic_val' seltext_s = 'Basic value' seltext_l = 'Basic value' col_pos = 3 outputlen = 25 cfieldname = 'cur') TO gt_pop_cat.
        APPEND VALUE #( fieldname = 'rate' seltext_m = 'Condition rate' seltext_l = 'Condition rate' col_pos = 4 outputlen = 22 cfieldname = 'cur') TO gt_pop_cat.
        APPEND VALUE #( fieldname = 'con_val' seltext_m = 'Condition Value' seltext_l = 'Condition Value' col_pos = 4 outputlen = 22 cfieldname = 'cur' ) TO gt_pop_cat.
      ENDIF.
      CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
        EXPORTING
          i_title               = 'Condition detail'
          i_tabname             = 'gt_cond'
          it_fieldcat           = gt_pop_cat
          i_screen_start_column = 10
          i_screen_start_line   = 20
          i_screen_end_column   = 100
          i_screen_end_line     = 40
        IMPORTING
          e_exit                = g_exit
        TABLES
          t_outtab              = lt_con.
    WHEN 'SEL_PRI'. "Click vao print"
      CLEAR lt_con.
      IF gt_con IS NOT INITIAL.
        SELECT * FROM @gt_con AS gt_con WHERE doc_con = @gs_item-doc_con INTO TABLE @lt_con.
      ENDIF.

      DATA: lv_fm_name  TYPE rs38l_fnam,
            lv_total    TYPE  ekpo-effwr,
            lt_po_items TYPE ztt_po_item_ruby.

      SELECT SINGLE lfa1~lifnr AS vendor_id,
       adr6~smtp_addr AS email,
       adrc~city1 AS city,
       adrc~street AS street,
       adrc~country AS add_country,
       adrc~tel_number AS phone
       FROM lfa1
       LEFT JOIN adrc ON lfa1~adrnr = adrc~addrnumber
       LEFT JOIN adr6 ON lfa1~adrnr = adr6~addrnumber
       WHERE lfa1~lifnr = @gs_item-vendor_id
       INTO CORRESPONDING FIELDS OF @gs_vendor.

      SELECT SINGLE t001~bukrs AS company_code,
        adr6~smtp_addr AS company_email,
        adrc~city1 AS company_city,
        adrc~street AS company_street,
        adrc~country AS company_country,
        adrc~tel_number AS company_phone,
        t001~butxt AS company_name
        FROM t001
        LEFT JOIN adrc ON t001~adrnr = adrc~addrnumber
        LEFT JOIN adr6 ON t001~adrnr = adr6~addrnumber
        WHERE t001~bukrs = @gs_item-company_code
        INTO CORRESPONDING FIELDS OF  @gs_company.

      gs_company-company_address = gs_company-company_street && gs_company-company_city && gs_company-company_country.
      lv_total = 0.

      LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<gs_item_detail>).
        IF <gs_item_detail>-pur_doc = gs_item-pur_doc.
          lv_total = lv_total + <gs_item_detail>-amount.
          APPEND <gs_item_detail> TO lt_po_items.
        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZSF_SMARTFORM_RUBY'
          variant            = ' '
          direct_call        = ' '
        IMPORTING
          fm_name            = lv_fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION lv_fm_name
        EXPORTING
          iv_vendor_name    = gs_item-vendor_name
          iv_vendor_id      = gs_vendor-vendor_id
          iv_vendor_email   = gs_vendor-email
          iv_vendor_phone   = gs_vendor-phone
          iv_vendor_address = gs_vendor-street && gs_vendor-city && gs_vendor-add_country
          iv_company_info   = gs_company
          iv_currency       = gs_item-currency
          iv_total          = lv_total
        TABLES
          gt_po_items       = lt_po_items
          gt_conditions     = lt_con.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSALV_STANDARD'.
  SET TITLEBAR 'ZSUN_RUBY_REPORT'.
ENDFORM.
