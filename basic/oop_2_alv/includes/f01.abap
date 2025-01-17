*&---------------------------------------------------------------------*
*& Include          ZPG_RUBY_ALV_OOP_MM_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_po_data .
  SELECT ekko~ebeln AS po_number,
         ekko~bukrs AS company_code,
         ekko~lifnr AS vendor_code,
         ekko~waers AS currency,
         SUM( ekpo~menge * ekpo~netpr ) AS total_amount
    FROM ekko
    INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
    WHERE ekko~ebeln IN @s_ponum
      AND ekko~bukrs IN @s_comp
    GROUP BY ekko~ebeln,
             ekko~bukrs,
             ekko~lifnr,
             ekko~waers
    INTO CORRESPONDING FIELDS OF TABLE @gt_po_head.

  IF sy-subrc <> 0.
    MESSAGE 'Data not found' TYPE 'E'.
  ENDIF.
ENDFORM.


FORM get_po_item_data USING u_po_number TYPE ekko-ebeln
                      CHANGING ct_po_item TYPE tt_po_item.
  SELECT ekpo~ebeln AS po_number,
         ekpo~ebelp AS po_item,
         ekpo~matnr AS material_number,
         ekpo~menge AS quantity,
         ekpo~meins AS unit,
         ekpo~netpr AS net_price
           FROM ekpo
           WHERE ebeln = @u_po_number
           INTO CORRESPONDING FIELDS OF TABLE @ct_po_item.

  IF sy-subrc <> 0.
    MESSAGE 'Data not found' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .
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
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*

FORM create_alv_object  CHANGING p_lo_alv_table.
  DATA(lo_container) = NEW cl_gui_custom_container(
    container_name          = 'ALVHEAD'
  ).

  p_lo_alv_table = NEW cl_gui_alv_grid( i_parent = lo_container ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT_ITEM
*&---------------------------------------------------------------------*

FORM create_alv_object_item  CHANGING p_lo_alv_table.
  DATA(lo_container) = NEW cl_gui_custom_container(
    container_name          = 'ALVITEM'
  ).

  p_lo_alv_table = NEW cl_gui_alv_grid( i_parent = lo_container ).
ENDFORM.


*&---------------------------------------------------------------------*
*& Form PREPARE_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FIELDCAT
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_alv  CHANGING p_lt_fieldcat TYPE lvc_t_fcat
                           p_ls_layout TYPE lvc_s_layo.
  DATA: ls_fieldcat TYPE LINE OF lvc_t_fcat.

  CLEAR: p_lt_fieldcat,  p_ls_layout.

  ls_fieldcat-fieldname = 'po_number'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Purchasing doc'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'company_code'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Company code'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'vendor_code'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Vendor code'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'currency'.
  ls_fieldcat-datatype = 'cuky'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Currency'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'total_amount'.
  ls_fieldcat-datatype = 'curr'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Total amount'.
  APPEND ls_fieldcat TO p_lt_fieldcat.


  p_ls_layout-cwidth_opt = abap_on. "ABAP_ON = 'X' la hang so
  p_ls_layout-zebra = abap_on.
ENDFORM.


FORM prepare_alv_item  CHANGING p_lt_fieldcat TYPE lvc_t_fcat
                                p_ls_layout TYPE lvc_s_layo.
  DATA: ls_fieldcat TYPE LINE OF lvc_t_fcat.

  CLEAR: p_lt_fieldcat,  p_ls_layout.

  ls_fieldcat-fieldname = 'po_number'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Purchasing doc'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'po_item'.
  ls_fieldcat-datatype = 'numc'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Item'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'material_number'.
  ls_fieldcat-datatype = 'char'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Material number'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'quantity'.
*  ls_fieldcat-datatype = 'cuky'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-qfieldname = 'unit'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Quanlity'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'unit'.
*  ls_fieldcat-datatype = 'cuky'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Unit'.
  APPEND ls_fieldcat TO p_lt_fieldcat.

  ls_fieldcat-fieldname = 'net_price'.
  ls_fieldcat-datatype = 'curr'.
  ls_fieldcat-outputlen = '12'.
  ls_fieldcat-scrtext_s = ls_fieldcat-scrtext_m = ls_fieldcat-scrtext_l = 'Net price'.
  APPEND ls_fieldcat TO p_lt_fieldcat.


  p_ls_layout-cwidth_opt = abap_on. "ABAP_ON = 'X' la hang so
  p_ls_layout-zebra = abap_on.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FIELDCAT
*&      <-- LS_LAYOUT
*&      <-- LO_ALV_TABLE
*&---------------------------------------------------------------------*
FORM display_alv  CHANGING p_lt_fieldcat TYPE lvc_t_fcat
                           p_ls_layout TYPE lvc_s_layo
                           p_lo_alv_table TYPE REF TO cl_gui_alv_grid.
  CALL METHOD p_lo_alv_table->set_table_for_first_display
    EXPORTING
      is_layout                     = p_ls_layout
    CHANGING
      it_outtab                     = gt_po_head
      it_fieldcatalog               = p_lt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Phai xu ly event truoc khi call screen 9000
  DATA(lo_alv_item_handler) = NEW lcl_alv_handler( po_head = gt_po_head ).
  SET HANDLER lo_alv_item_handler->handle_dbclick FOR p_lo_alv_table.
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

CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD constructor.
    me->_t_po_head = gt_po_head.
  ENDMETHOD.


  METHOD handle_dbclick.
    DATA: lt_fieldcat TYPE lvc_t_fcat,
          ls_layout   TYPE lvc_s_layo.

    READ TABLE me->_t_po_head INTO DATA(ls_po_head)
      INDEX es_row_no-row_id.

    IF sy-subrc = 0.
      PERFORM get_po_item_data USING ls_po_head-po_number CHANGING me->_t_po_item.
      IF me->_o_alv_table IS NOT BOUND. "Kiem tra da co gia tri chua
        PERFORM create_alv_object_item CHANGING me->_o_alv_table.
        PERFORM prepare_alv_item CHANGING lt_fieldcat ls_layout.

        CALL METHOD me->_o_alv_table->set_table_for_first_display
          EXPORTING
            is_layout                     = ls_layout
          CHANGING
            it_outtab                     = me->_t_po_item
            it_fieldcatalog               = lt_fieldcat
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
        me->_o_alv_table->refresh_table_display(
        EXCEPTIONS
           finished = 1
           OTHERS = 2
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
