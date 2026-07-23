class /PLMI/CL_SPC_EXP_GEN_DATA_SNGL definition
  public
  inheriting from /PLMI/CL_SPC_EXP_GEN_DATA_ABS
  create public .

public section.
protected section.

  methods CONVERT_AND_APPEND_DATA
    redefinition .
  methods CHECK_NUMBER_OF_OBJECTS
    redefinition .
private section.
ENDCLASS.



CLASS /PLMI/CL_SPC_EXP_GEN_DATA_SNGL IMPLEMENTATION.


METHOD check_number_of_objects.

  DATA:
        ls_spi_message TYPE /plmb/s_spi_msg.

  CASE lines( it_objects ).

    WHEN 0.
      " there is no input data -> technical error
      ASSERT 0 = 1.

    WHEN 1.
      " object number 1 is expected in case of single selection
      RETURN.

    WHEN OTHERS.
      " message shall be displayed in case of multiple selection
      " and the message is not there already
      ls_spi_message-msgty = 'E'.
      ls_spi_message-msgid = '/PLMB/BA_EXP'.
      ls_spi_message-msgno = 016.
      READ TABLE ct_message INTO ls_spi_message
        WITH KEY msgty = ls_spi_message-msgty
                 msgid = ls_spi_message-msgid
                 msgno = ls_spi_message-msgno.
      IF sy-subrc <> 0.
        ls_spi_message-msgv1 = lines( it_objects ).
        ls_spi_message-msgv2 = iv_variant_id.
        APPEND ls_spi_message TO ct_message.
      ENDIF.
      " set failed indicator
      ev_failed = abap_true.
      " set severity
      IF cv_severity NA /plmb/if_spi_c=>gs_c_severity_category-error_or_worse.
        cv_severity = 'E'.
      ENDIF.

  ENDCASE.

ENDMETHOD.


METHOD CONVERT_AND_APPEND_DATA.

  /plmb/cl_exp_tools=>convert_and_append_data(
    EXPORTING
      iv_xstring_conversion = abap_true    " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
      iv_table_no           = iv_table_no    " Natural Number
      ir_out_data           = ir_out_data    " Data to be converted
    CHANGING
      ct_table_data         = ct_table_data    " Table Data for Download
  ).

ENDMETHOD.
ENDCLASS.