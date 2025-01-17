*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_TEST_5_TOP
*&---------------------------------------------------------------------*
REPORT zpg_ruby_alv_oop_flow_event.

*TYPES:
*  BEGIN OF ty_item,
*    pur_doc     TYPE ekko-ebeln, "Purchasing doc"
*    item        TYPE ekpo-ebelp, "Item"
*    quality     TYPE ekpo-menge, "Quality"
*    uom         TYPE ekpo-bprme, "UOM - Order price unit"
*    pur_name    TYPE t024-eknam, "Purchasing group name"
*    mat_desc    TYPE makt-maktx, "Material description"
*    plant       TYPE ekpo-werks, "Plant"
*    plant_desc  TYPE t001w-name1, "Plant description"
*    amount      TYPE ekpo-effwr, "Amount"
*    currency    TYPE ekko-waers, "Curency",
*    bp_type     TYPE but000-type,
*    name_last   TYPE but000-name_last,
*    name_first  TYPE but000-name_first,
*    name1       TYPE but000-name_org1,
*    name2       TYPE but000-name_org2,
*    name3       TYPE but000-name_org3,
*    name4       TYPE but000-name_org4,
*    vendor_name TYPE string,
*    con_desc    TYPE string,
*    vendor_id TYPE  ekko-lifnr,
*    company_code TYPE ekko-BUKRS,
*    doc_con     TYPE ekko-knumv,
*  END OF ty_item,

*  BEGIN OF ty_condition,
*    doc_con TYPE prcd_elements-knumv,
*    item_id TYPE prcd_elements-kposn,
*    con_type  TYPE t685t-kschl,
*    con_name  TYPE t685t-vtext,
*    basic_val TYPE prcd_elements-kawrt,
*    rate      TYPE prcd_elements-kbetr,
*    con_val TYPE prcd_elements-kwert,
*    cur TYPE prcd_elements-waers,
*  END OF ty_condition.

 TYPES:
    BEGIN OF ty_vendor,
      vendor_id   TYPE lfa1-lifnr,
      email       TYPE adr6-smtp_addr,
      city        TYPE adrc-city1,
      street      TYPE adrc-street,
      add_country TYPE adrc-county,
      phone       TYPE adrc-tel_number,
    END OF ty_vendor.

DATA: v_supplier      TYPE ekko-lifnr,
      v_pur_org       TYPE ekko-ekorg,
      v_pur_gr        TYPE ekko-ekgrp,
      v_material      TYPE ekpo-ematn,
      v_pur_document  TYPE ekko-ebeln,
      v_item          TYPE ekpo-ebelp,
      v_document_date TYPE ekko-bedat,
      gt_item         TYPE ztt_po_item_ruby,
      gs_item         TYPE zst_po_item_ruby,
      gt_con TYPE ztt_po_condition_ruby,
      gt_po_items TYPE ztt_po_condition_ruby,
      gs_con TYPE zst_po_condition_ruby,
      gs_vendor  TYPE ty_vendor,
      gs_company TYPE zst_company_ruby.

DATA: gt_catalog TYPE slis_t_fieldcat_alv,
      gs_catalog TYPE slis_fieldcat_alv,
      gv_layout TYPE slis_layout_alv,
      gt_pop_cat TYPE slis_t_fieldcat_alv,
      gv_pop_cat_line TYPE i.

CONSTANTS:
  gc_doc_cat_po TYPE c VALUE 'F'.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.
SELECT-OPTIONS s_sup FOR v_supplier NO-EXTENSION.
SELECT-OPTIONS s_org FOR v_pur_org NO-EXTENSION.
SELECT-OPTIONS s_pu_gr FOR v_pur_gr NO-EXTENSION.
SELECT-OPTIONS s_ma FOR v_material NO-EXTENSION.
SELECT-OPTIONS s_pur_do FOR v_pur_document NO-EXTENSION.
SELECT-OPTIONS s_item FOR v_item NO-EXTENSION.
SELECT-OPTIONS s_d_date FOR v_document_date NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b01.
