*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_ALV_OOP_MM_TOP
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Declarations - Types
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF gty_po_head,
    po_number    TYPE ekko-ebeln, "Purchasing doc"
    company_code TYPE ekko-bukrs,
    vendor_code  TYPE ekko-lifnr,
    currency     TYPE  ekko-waers,
    total_amount TYPE curr23_2,
  END OF gty_po_head,

  BEGIN OF gty_po_item,
    po_number       TYPE ekpo-ebeln,
    po_item         TYPE ekpo-ebelp,
    material_number TYPE ekpo-matnr,
    quantity        TYPE ekpo-menge,
    unit            TYPE ekpo-meins,
    net_price       TYPE ekpo-netpr,
  END OF gty_po_item,
  tt_po_head TYPE STANDARD TABLE OF gty_po_head,
  tt_po_item TYPE STANDARD TABLE OF gty_po_item.

*&---------------------------------------------------------------------*
*& Declarations - Data
*&---------------------------------------------------------------------*
DATA: gt_po_head TYPE TABLE OF gty_po_head,
      gt_po_item TYPE TABLE OF gty_po_item.

DATA: gd_sel_po_number    TYPE ekko-ebeln, "Only use for select-options
      gd_sel_company_code TYPE ekko-lifnr. "Only use for select-options

*&---------------------------------------------------------------------*
*& Declarations - Class
*&---------------------------------------------------------------------*
CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
    METHODS constructor "Tu dong goi khi tao object
      IMPORTING po_head TYPE tt_po_head.

    METHODS handle_dbclick
        FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: _t_po_head TYPE  tt_po_head. "Load data 1 lan
    DATA: _t_po_item TYPE tt_po_item. "Moi lan click load lai 1 lan
    DATA: _o_alv_table TYPE REF TO cl_gui_alv_grid. "Load data 1 lan
ENDCLASS.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b001 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_ponum FOR gd_sel_po_number.
SELECT-OPTIONS: s_comp FOR gd_sel_company_code.
SELECTION-SCREEN END OF BLOCK b001.
