class ZCL_SPC_EXP_GEN_DATA_SPPLR definition
  public
  inheriting from /PLMI/CL_SPC_EXP_GEN_DATA_SNGL
  final
  create public .

public section.
protected section.
  methods PROCESS_TABLE_DATA
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_SPC_EXP_GEN_DATA_SPPLR IMPLEMENTATION.


METHOD process_table_data.

  DATA:
    ls_vatcust              TYPE /plmb/s_spc_val_action_vatcust,
    lv_failed               TYPE /plmb/spi_failed_ind,
    lv_fieldname            TYPE abap_compname,
    lv_additional_info      TYPE string,
    lv_additional_info_part TYPE string,
    lv_property_tree_text   TYPE string,
    lr_metadata_line        TYPE REF TO data,
    lo_spi_connector_spc    TYPE REF TO /plmb/if_spi_appl_access,
    lv_insert_index         TYPE sy-tabix.

  FIELD-SYMBOLS:
    <ls_table_meta_data> TYPE ty_s_table_meta_data,
    <ls_table_data>      TYPE /plmb/s_exp_table_data_export,
    <ls_any_table_data>  TYPE /plmb/s_exp_table_data_export,
    <lt_table_data>      TYPE STANDARD TABLE,
    <lt_any_table_data>  TYPE STANDARD TABLE,
    <ls_table_line>      TYPE any,
    <ls_any_table_line>  TYPE any,
    <ls_metadata_line>   TYPE any,
    <lv_data>            TYPE any,
    <ls_vatcust>         TYPE /plmb/s_spc_val_conf_sp.

  super->process_table_data(
    EXPORTING
      iv_node_name        = iv_node_name
      iv_target_node_name = iv_target_node_name
      iv_technical_estcat = iv_technical_estcat
      iv_esttype          = iv_esttype
    CHANGING
      ct_table_data       = ct_table_data
      ct_table_meta_data  = ct_table_meta_data
  ).

  IF iv_target_node_name <> /plmb/if_spc_attr=>gc_node_valuation.
    RETURN.
  ENDIF.

  READ TABLE ct_table_meta_data
    ASSIGNING <ls_table_meta_data>
    WITH KEY engine_value_assignment_type = iv_technical_estcat
             target_node_name             = iv_target_node_name.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  READ TABLE ct_table_data ASSIGNING <ls_table_data>
    WITH KEY table_no = <ls_table_meta_data>-table_no.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  ASSIGN <ls_table_data>-table_data->* TO <lt_table_data>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CALL METHOD /plmb/cl_spi_connector=>create_instance
    EXPORTING
      iv_abbid     = /plmb/if_abbid_c=>gc_spc
    IMPORTING
      eo_connector = lo_spi_connector_spc.
  IF lo_spi_connector_spc IS NOT BOUND.
    RETURN.
  ENDIF.

  LOOP AT ct_table_data ASSIGNING <ls_any_table_data>.
    ASSIGN <ls_any_table_data>-table_data->* TO <lt_any_table_data>.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    LOOP AT <lt_any_table_data> ASSIGNING <ls_any_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_any_table_line> TO <lv_data>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <lv_data> <> /plmb/if_exp_c=>gc_data_type-tabledata.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'SUBCAT' OF STRUCTURE <ls_any_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> IS NOT INITIAL.
        lv_property_tree_text = <lv_data>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_property_tree_text IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_property_tree_text IS NOT INITIAL.
    LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <lv_data> <> /plmb/if_exp_c=>gc_data_type-tabledata.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0.
        <lv_data> = lv_property_tree_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
    IF sy-subrc = 0 AND <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> = 5.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  lo_spi_connector_spc->action(
    EXPORTING
      iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation
      iv_action_name = /plmb/if_spc_attr=>gc_actions_val-get_vat_customizing
    IMPORTING
      ev_failed      = lv_failed
      eg_param       = ls_vatcust
  ).
  IF lv_failed = abap_true OR ls_vatcust-vat_customizing IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
    IF sy-subrc = 0 AND <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> = 4.
        CREATE DATA lr_metadata_line LIKE <ls_table_line>.
        ASSIGN lr_metadata_line->* TO <ls_metadata_line>.
        <ls_metadata_line> = <ls_table_line>.
        lv_insert_index = sy-tabix + 1.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF <ls_metadata_line> IS NOT ASSIGNED.
    RETURN.
  ENDIF.

  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = 1.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = 5.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = iv_technical_estcat.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = iv_esttype.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = 5.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    <lv_data> = 'Additional Information'.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    CLEAR <lv_data>.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    CLEAR <lv_data>.
  ENDIF.
  ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_metadata_line> TO <lv_data>.
  IF sy-subrc = 0.
    CLEAR <lv_data>.
  ENDIF.

  LOOP AT ls_vatcust-vat_customizing ASSIGNING <ls_vatcust>
    WHERE estcat = iv_technical_estcat.
    CLEAR: lv_additional_info,
           lv_additional_info_part.

    IF <ls_vatcust>-flg_is_no_single_value = abap_true.
      lv_additional_info = 'Multiple values allowed'.
    ELSE.
      lv_additional_info = 'Single value'.
    ENDIF.

    IF <ls_vatcust>-flg_is_no_single_value = 'D'.
      CONCATENATE lv_additional_info 'Predefined list (dropdown)' INTO lv_additional_info SEPARATED BY '; '.
    ENDIF.

    CASE <ls_vatcust>-atfor.
      WHEN 'NUM' OR 'CURR'.
        ASSIGN COMPONENT 'FLG_INTERVAL_VALUES_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'FLG_INTERVAL_VALS_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'FLG_INTERVAL_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'ATINT' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc = 0.
          IF <lv_data> IS INITIAL OR <lv_data> = abap_false.
            CONCATENATE lv_additional_info 'Interval vals not allowed' INTO lv_additional_info SEPARATED BY '; '.
          ELSE.
            CONCATENATE lv_additional_info 'Interval vals allowed' INTO lv_additional_info SEPARATED BY '; '.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'FLG_NEGATIVE_VALUES_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'FLG_NEGATIVE_VALS_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'FLG_NEG_VALUES_ALLOWED' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'ATVOR' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc = 0.
          IF <lv_data> IS INITIAL OR <lv_data> = abap_false.
            CONCATENATE lv_additional_info 'Negative Vals not allowed' INTO lv_additional_info SEPARATED BY '; '.
          ELSE.
            CONCATENATE lv_additional_info 'Negative Vals Allowed' INTO lv_additional_info SEPARATED BY '; '.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'FLG_RESTRICTABLE' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'FLG_IS_RESTRICTABLE' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc <> 0.
          ASSIGN COMPONENT 'ATKLE' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        ENDIF.
        IF sy-subrc = 0.
          IF <lv_data> IS INITIAL OR <lv_data> = abap_false.
            CONCATENATE lv_additional_info 'Not restrictable' INTO lv_additional_info SEPARATED BY '; '.
          ELSE.
            CONCATENATE lv_additional_info 'Restrictable' INTO lv_additional_info SEPARATED BY '; '.
          ENDIF.
        ENDIF.

        IF <ls_vatcust>-flg_input_required = abap_true.
          CONCATENATE lv_additional_info 'Entry required' INTO lv_additional_info SEPARATED BY '; '.
        ELSE.
          CONCATENATE lv_additional_info 'Entry not required' INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.

        IF <ls_vatcust>-anzst IS NOT INITIAL.
          lv_additional_info_part = <ls_vatcust>-anzst.
          SHIFT lv_additional_info_part LEFT DELETING LEADING space.
          CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.

        ASSIGN COMPONENT 'ANZDZ' OF STRUCTURE <ls_vatcust> TO <lv_data>.
        IF sy-subrc = 0 AND <lv_data> IS NOT INITIAL.
          lv_additional_info_part = <lv_data>.
          SHIFT lv_additional_info_part LEFT DELETING LEADING space.
          CONCATENATE 'Decimal places' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.

        CONCATENATE lv_additional_info 'Numeric value' INTO lv_additional_info SEPARATED BY '; '.
        IF <ls_vatcust>-msehi IS NOT INITIAL.
          lv_additional_info_part = <ls_vatcust>-msehi.
          CONCATENATE 'Default UoM (' lv_additional_info_part ')' INTO lv_additional_info_part.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
      WHEN 'DATE'.
        IF <ls_vatcust>-flg_input_required = abap_true.
          CONCATENATE lv_additional_info 'Entry required' INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
        IF <ls_vatcust>-anzst IS NOT INITIAL.
          lv_additional_info_part = <ls_vatcust>-anzst.
          SHIFT lv_additional_info_part LEFT DELETING LEADING space.
          CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
        CONCATENATE lv_additional_info 'Date format YYYYMMDD' INTO lv_additional_info SEPARATED BY '; '.
      WHEN 'CHAR'.
        IF <ls_vatcust>-flg_input_required = abap_true.
          CONCATENATE lv_additional_info 'Entry required' INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
        IF <ls_vatcust>-anzst IS NOT INITIAL.
          lv_additional_info_part = <ls_vatcust>-anzst.
          SHIFT lv_additional_info_part LEFT DELETING LEADING space.
          CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
        CONCATENATE lv_additional_info 'Character value' INTO lv_additional_info SEPARATED BY '; '.
      WHEN OTHERS.
        IF <ls_vatcust>-flg_input_required = abap_true.
          CONCATENATE lv_additional_info 'Entry required' INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
        IF <ls_vatcust>-anzst IS NOT INITIAL.
          lv_additional_info_part = <ls_vatcust>-anzst.
          SHIFT lv_additional_info_part LEFT DELETING LEADING space.
          CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
          CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
        ENDIF.
    ENDCASE.

    lv_fieldname = <ls_vatcust>-atnam.
    TRANSLATE lv_fieldname USING '-_'.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_metadata_line> TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = lv_additional_info.
    ENDIF.
  ENDLOOP.

  IF lv_insert_index IS INITIAL.
    APPEND <ls_metadata_line> TO <lt_table_data>.
  ELSE.
    INSERT <ls_metadata_line> INTO <lt_table_data> INDEX lv_insert_index.
  ENDIF.

ENDMETHOD.
ENDCLASS.
