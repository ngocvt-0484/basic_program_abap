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
  "*****OOP
  DATA: lo_alv_table TYPE REF TO cl_gui_alv_grid.
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        ls_layout   TYPE lvc_s_layo.

  "Create ALV table object
  PERFORM create_alv_object CHANGING lo_alv_table.
  PERFORM prepare_alv CHANGING lt_fieldcat
                               ls_layout.
  PERFORM display_alv CHANGING lt_fieldcat
                               ls_layout
                               lo_alv_table.
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
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_TABLE
*&---------------------------------------------------------------------*
FORM create_alv_object  CHANGING co_alv_table.

  co_alv_table = new cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ). " parent: container de xd no thuoc ve container nao neu co nhieu ALV. o day setting chi co 1 ALV cho don gian

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PREPARE_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FIELDCAT
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_alv  CHANGING ct_fieldcat TYPE lvc_t_fcat
                           cs_layout TYPE lvc_s_layo.
  DATA: ls_fieldcat TYPE LINE OF lvc_t_fcat.
  CLEAR: ct_fieldcat, ls_fieldcat.
  ls_fieldcat-fieldname = 'pur_doc'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Purchasing doc'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'item'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Item'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'quality'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Quanlity'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'uom'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'UOM'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'pur_name'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Purchasing group name'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'vendor_name'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Vendor name'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'con_desc'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Condition type description'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'mat_desc'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Material description'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'plant'.
*  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Plant'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'plant_desc'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Plant description'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'amount'.
  ls_fieldcat-datatype = 'curr'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-cfieldname = 'currency'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Amount'.
  APPEND ls_fieldcat TO ct_fieldcat.

  ls_fieldcat-fieldname = 'currency'.
  ls_fieldcat-datatype = 'cuky'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Currency'.
  APPEND ls_fieldcat TO ct_fieldcat.


  cs_layout-cwidth_opt = abap_on. "ABAP_ON = 'X' la hang so
  cs_layout-zebra = abap_on.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FIELDCAT
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM display_alv  CHANGING ct_fieldcat TYPE lvc_t_fcat
                           cs_layout TYPE lvc_s_layo
                           co_alv_table TYPE REF TO cl_gui_alv_grid.

  CALL METHOD co_alv_table->set_table_for_first_display
    EXPORTING
      is_layout                     = cs_layout
    CHANGING
      it_outtab                     = gt_item
      it_fieldcatalog               = ct_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Phai xu ly event truoc khi call screen 9000

  CALL SCREEN 9000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'ALV_GUI'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
