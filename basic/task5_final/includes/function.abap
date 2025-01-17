FUNCTION zfm_ruby_rwbapi01.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_ACCIT STRUCTURE  ACCIT
*"      IT_ACCR STRUCTURE  ACCCR
*"      RETURN STRUCTURE  BAPIRET2
*"      EXTENSION STRUCTURE  BAPIACEXTC
*"      IT_ACCWT STRUCTURE  ACCIT_WT
*"      IT_ACCTX STRUCTURE  ACCBSET
*"----------------------------------------------------------------------

  DATA : wa_extension TYPE bapiacextc.
  CLEAR: wa_extension.
  LOOP AT extension INTO wa_extension.
    SPLIT wa_extension-field1 AT '|' INTO: DATA(lv_key) DATA(lv_itemno) DATA(lv_posting_key).
    IF lv_key <> 'ZACC_RUBY'.
      EXIT.
    ENDIF.

    READ TABLE it_accit WITH KEY posnr = lv_itemno.
    IF sy-subrc EQ 0.
      it_accit-bschl = lv_posting_key.
      MODIFY it_accit INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
