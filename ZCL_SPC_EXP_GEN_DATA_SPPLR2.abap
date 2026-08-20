CLASS zcl_spc_exp_gen_data_spplr2 DEFINITION
  PUBLIC
  INHERITING FROM /plmi/cl_spc_exp_gen_data_sngl
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /plmb/if_exp_generic_data~get_definition
        REDEFINITION .
    METHODS /plmb/if_exp_generic_data~get_export_data
        REDEFINITION .
  PROTECTED SECTION.
    METHODS process_table_data
        REDEFINITION .
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_group_export_row,
        engine_key_col TYPE i,
        engine_key_row TYPE i,
        estcat         TYPE eseestcat,
        estcat_desc    TYPE string,
        esttype        TYPE eseesttype,
        node_name      TYPE /plmb/spi_node_name,
        node_desc      TYPE string,
        datatype       TYPE string,
        line_no        TYPE string,
        specid         TYPE string,
        instance       TYPE string,
        sort_seq       TYPE string,
        usage          TYPE string,
        ref_qty        TYPE string,
        recn           TYPE string,
        actn           TYPE string,
        recnroot       TYPE string,
        recnparent     TYPE string,
        estcat_value   TYPE eseestcat,
        recn_vp        TYPE string,
        actn_vp        TYPE string,
        subid          TYPE string,
        grp_subid      TYPE string,
        ident1         TYPE string,
        ident1_desc    TYPE string,
      END OF ty_s_group_export_row,
      ty_t_group_export_row TYPE STANDARD TABLE OF ty_s_group_export_row WITH DEFAULT KEY.

    CONSTANTS gc_debug_marker TYPE string VALUE 'ZSPPLR_DEBUG_20260819_INSTANCE_001'.
    METHODS ensure_show_all_groups
      CHANGING
        !ct_add_info TYPE /plmb/t_exp_additional_info .
    METHODS append_supplier_group_defs
      CHANGING
        !ct_table_definition TYPE /plmb/t_exp_table_definition .
    METHODS append_supplier_group_rows
      IMPORTING
        !it_objects          TYPE /plmb/t_gos_internal_key
        !it_table_data       TYPE /plmb/t_exp_table_data_export
        !iv_technical_estcat TYPE eseestcat
        !iv_esttype          TYPE eseesttype
        !iv_specid           TYPE string
        !iv_description      TYPE string
        !iv_recn_group       TYPE char30
      CHANGING
        !ct_table_data       TYPE /plmb/t_exp_table_data_export .
    METHODS remove_first_sheet_group_rows
      CHANGING
        !ct_table_data TYPE /plmb/t_exp_table_data_export .
    METHODS fetch_supplier_group_rows
      IMPORTING
        !it_objects          TYPE /plmb/t_gos_internal_key
        !it_table_data       TYPE /plmb/t_exp_table_data_export
        !iv_technical_estcat TYPE eseestcat
        !iv_esttype          TYPE eseesttype
        !iv_specid           TYPE string
        !iv_description      TYPE string
        !iv_recn_group       TYPE char30
      CHANGING
        !ct_rows             TYPE ty_t_group_export_row .
    METHODS default_export_defaults
      CHANGING
        !ct_rows             TYPE ty_t_group_export_row .
    METHODS get_add_info_value
      IMPORTING
        !it_add_info    TYPE /plmb/t_exp_additional_info
        !iv_fname       TYPE fieldname
      RETURNING
        VALUE(rv_value) TYPE char30 .
    METHODS get_component_string
      IMPORTING
        !is_data        TYPE any
        !iv_component   TYPE string
      RETURNING
        VALUE(rv_value) TYPE string .
    METHODS has_first_sheet_hidden_vat
      IMPORTING
        !is_data        TYPE any
      RETURNING
        VALUE(rv_value) TYPE abap_bool .
    METHODS deserialize_selection_xml
      IMPORTING
        !iv_selection TYPE string
      EXPORTING
        !et_selection TYPE /plmb/t_spc_exp_ptree_select .
ENDCLASS.



CLASS zcl_spc_exp_gen_data_spplr2 IMPLEMENTATION.


  METHOD /plmb/if_exp_generic_data~get_definition.

    DATA lt_add_info TYPE /plmb/t_exp_additional_info.

    lt_add_info = it_add_info.
    me->ensure_show_all_groups(
      CHANGING
        ct_add_info = lt_add_info
    ).

    super->/plmb/if_exp_generic_data~get_definition(
      EXPORTING
        it_objects             = it_objects
        iv_variant_id          = iv_variant_id
        iv_selection           = iv_selection
        it_add_info            = lt_add_info
      IMPORTING
        et_table_definition    = et_table_definition
        et_table_definition_ui = et_table_definition_ui
      CHANGING
        ct_message             = ct_message
        cv_severity            = cv_severity
    ).

    " ZSPPLR_DEBUG_20260814_001: keep base definition metadata; the XSL hides group rows from the Data sheet.

    me->append_supplier_group_defs(
      CHANGING
        ct_table_definition = et_table_definition
    ).

  ENDMETHOD.


  METHOD /plmb/if_exp_generic_data~get_export_data.

    DATA:
      lt_add_info           TYPE /plmb/t_exp_additional_info,
      lt_base_data          TYPE /plmb/t_exp_table_data_export,
      lt_table_definition   TYPE /plmb/t_exp_table_definition,
      lt_definition         TYPE /plmb/t_exp_table_definition,
      lt_selection          TYPE /plmb/t_spc_exp_ptree_select,
      lt_def_message        TYPE /plmb/t_spi_msg,
      lv_allerg_grp         TYPE char30,
      lv_diet_group         TYPE char30,
      lv_relig_group        TYPE char30,
      lv_genmod_grp         TYPE char30,
      lv_def_severity       TYPE /plmb/spi_msg_severity,
      lv_property_tree_text TYPE string,
      lv_instance_field     TYPE string,
      lo_table_type         TYPE REF TO cl_abap_tabledescr,
      lr_table_data         TYPE REF TO data.

    FIELD-SYMBOLS:
      <ls_definition> TYPE /plmb/s_exp_table_definition,
      <ls_table_data> TYPE /plmb/s_exp_table_data_export,
      <lt_table_data> TYPE STANDARD TABLE,
      <lt_xstring>    TYPE /plmb/t_exp_xstring,
      <ls_xstring>    TYPE /plmb/s_exp_xstring,
      <ls_table_line> TYPE any,
      <ls_selection>  TYPE /plmb/s_spc_exp_ptree_select,
      <lv_component>  TYPE any.

    lt_add_info = it_add_info.
    me->ensure_show_all_groups(
      CHANGING
        ct_add_info = lt_add_info
    ).
    lv_allerg_grp = me->get_add_info_value(
      it_add_info = lt_add_info
      iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-allergen
    ).
    lv_diet_group = me->get_add_info_value(
      it_add_info = lt_add_info
      iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-diet
    ).
    lv_relig_group = me->get_add_info_value(
      it_add_info = lt_add_info
      iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-religious
    ).
    lv_genmod_grp = me->get_add_info_value(
      it_add_info = lt_add_info
      iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-gen_mod
    ).

    me->/plmb/if_exp_generic_data~get_definition(
      EXPORTING
        it_objects          = it_objects
        iv_variant_id       = iv_variant_id
        iv_selection        = iv_selection
        it_add_info         = lt_add_info
      IMPORTING
        et_table_definition = lt_table_definition
      CHANGING
        ct_message          = lt_def_message
        cv_severity         = lv_def_severity
    ).

    super->/plmb/if_exp_generic_data~get_export_data(
      EXPORTING
        it_objects    = it_objects
        iv_variant_id = iv_variant_id
        iv_selection  = iv_selection
        it_add_info   = lt_add_info
      IMPORTING
        et_table_data = et_table_data
      CHANGING
        ct_message    = ct_message
        cv_severity   = cv_severity
    ).

    me->deserialize_selection_xml(
      EXPORTING
        iv_selection = iv_selection
      IMPORTING
        et_selection = lt_selection
    ).
    READ TABLE lt_selection INDEX 1 ASSIGNING <ls_selection>.
    IF sy-subrc = 0.
      lv_property_tree_text = <ls_selection>-property_tree.
    ENDIF.

    " ZSPPLR_DEBUG_20260817_001: keep Prop tree type from lt_selection-property_tree.
    LOOP AT et_table_data ASSIGNING <ls_table_data>.
      IF <ls_table_data>-table_data IS NOT BOUND.
        CONTINUE.
      ENDIF.

      ASSIGN <ls_table_data>-table_data->* TO <lt_table_data>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR lv_instance_field.
      LOOP AT lt_table_definition ASSIGNING <ls_definition>
        WHERE table_no = <ls_table_data>-table_no
          AND new_page = abap_false
          AND table_text IS INITIAL.
        IF <ls_definition>-fieldname = 'INSTANCE' OR
           <ls_definition>-fieldtext = 'Instance'.
          lv_instance_field = <ls_definition>-fieldname.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_instance_field IS INITIAL.
        lv_instance_field = 'INSTANCE'.
      ENDIF.

      ASSIGN <ls_table_data>-table_data->* TO <lt_xstring>.
      IF sy-subrc = 0.
        CLEAR lt_definition.
        LOOP AT lt_table_definition ASSIGNING <ls_definition>
          WHERE table_no = <ls_table_data>-table_no
            AND new_page = abap_false
            AND table_text IS INITIAL.
          APPEND <ls_definition> TO lt_definition.
        ENDLOOP.
        IF lt_definition IS INITIAL.
          CONTINUE.
        ENDIF.

        CLEAR lo_table_type.
        /plmb/cl_exp_tools=>create_struct_and_table_type(
          EXPORTING
            it_definition = lt_definition
          IMPORTING
            eo_table_type = lo_table_type
        ).
        IF lo_table_type IS NOT BOUND.
          CONTINUE.
        ENDIF.

        CREATE DATA lr_table_data TYPE HANDLE lo_table_type.
        ASSIGN lr_table_data->* TO <lt_table_data>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_xstring> ASSIGNING <ls_xstring>.
          CLEAR <lt_table_data>.
          IMPORT xstring = <lt_table_data>
            FROM DATA BUFFER <ls_xstring>-xstring.

          LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
            ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_component>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            IF <lv_component> <> /plmb/if_exp_c=>gc_data_type-tabledata.
              CONTINUE.
            ENDIF.

            ASSIGN COMPONENT lv_instance_field OF STRUCTURE <ls_table_line> TO <lv_component>.
            IF sy-subrc = 0 AND <lv_component> IS INITIAL.
              <lv_component> = '1'.
            ENDIF.

            IF lv_property_tree_text IS INITIAL.
              CONTINUE.
            ENDIF.

            ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_table_line> TO <lv_component>.
            IF sy-subrc = 0.
              <lv_component> = lv_property_tree_text.
            ENDIF.
          ENDLOOP.

          EXPORT xstring = <lt_table_data>
            TO DATA BUFFER <ls_xstring>-xstring
            COMPRESSION OFF.
        ENDLOOP.
        CONTINUE.
      ENDIF.

      LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_component>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <lv_component> <> /plmb/if_exp_c=>gc_data_type-tabledata.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT lv_instance_field OF STRUCTURE <ls_table_line> TO <lv_component>.
        IF sy-subrc = 0 AND <lv_component> IS INITIAL.
          <lv_component> = '1'.
        ENDIF.

        IF lv_property_tree_text IS INITIAL.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_table_line> TO <lv_component>.
        IF sy-subrc = 0.
          <lv_component> = lv_property_tree_text.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    lt_base_data = et_table_data.
    me->remove_first_sheet_group_rows(
      CHANGING
        ct_table_data = et_table_data
    ).

    me->append_supplier_group_rows(
      EXPORTING
        it_objects          = it_objects
        it_table_data       = lt_base_data
        iv_technical_estcat = 'SAP_RMS_1012_021'
        iv_esttype          = 'RMS_D'
        iv_specid           = ''
        iv_description      = 'Allergens'
        iv_recn_group       = lv_allerg_grp
      CHANGING
        ct_table_data       = et_table_data
    ).
    me->append_supplier_group_rows(
      EXPORTING
        it_objects          = it_objects
        it_table_data       = lt_base_data
        iv_technical_estcat = 'SAP_RMS_1012_010'
        iv_esttype          = 'RMS_D'
        iv_specid           = ''
        iv_description      = 'Diet Suitability'
        iv_recn_group       = lv_diet_group
      CHANGING
        ct_table_data       = et_table_data
    ).
    me->append_supplier_group_rows(
      EXPORTING
        it_objects          = it_objects
        it_table_data       = lt_base_data
        iv_technical_estcat = 'SAP_RMS_1012_022'
        iv_esttype          = 'B'
        iv_specid           = ''
        iv_description      = 'Religious Certificate Compliance'
        iv_recn_group       = lv_relig_group
      CHANGING
        ct_table_data       = et_table_data
    ).
    me->append_supplier_group_rows(
      EXPORTING
        it_objects          = it_objects
        it_table_data       = lt_base_data
        iv_technical_estcat = 'SAP_RMS_1012_025'
        iv_esttype          = 'RMS_D'
        iv_specid           = ''
        iv_description      = 'Genetically Modified Ingredients'
        iv_recn_group       = lv_genmod_grp
      CHANGING
        ct_table_data       = et_table_data
    ).

  ENDMETHOD.


  METHOD ensure_show_all_groups.

    DATA:
      lt_fields   TYPE STANDARD TABLE OF fieldname,
      lv_field    TYPE fieldname,
      lr_show_all TYPE REF TO data,
      lv_show_all TYPE char30,
      ls_add_info TYPE /plmb/s_exp_additional_info.

    FIELD-SYMBOLS:
      <ls_add_info> TYPE /plmb/s_exp_additional_info,
      <lv_value>    TYPE any.

    APPEND /plmi/if_spc_exp_c=>gc_additional_info-nutrient  TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-diet      TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-allergen  TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-religious TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-gen_mod   TO lt_fields.

    LOOP AT lt_fields INTO lv_field.
      UNASSIGN: <ls_add_info>,
                <lv_value>.
      READ TABLE ct_add_info ASSIGNING <ls_add_info> WITH KEY fname = lv_field.

      IF <ls_add_info> IS ASSIGNED.
        IF <ls_add_info>-value IS BOUND.
          ASSIGN <ls_add_info>-value->* TO <lv_value>.
          IF sy-subrc = 0 AND <lv_value> IS NOT INITIAL.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_show_all = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all.
      CREATE DATA lr_show_all TYPE char30.
      ASSIGN lr_show_all->* TO <lv_value>.
      <lv_value> = lv_show_all.

      IF <ls_add_info> IS ASSIGNED.
        <ls_add_info>-value = lr_show_all.
      ELSE.
        CLEAR ls_add_info.
        ls_add_info-fname = lv_field.
        ls_add_info-value = lr_show_all.
        APPEND ls_add_info TO ct_add_info.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD remove_first_sheet_group_rows.

    DATA:
      ls_table_data TYPE /plmb/s_exp_table_data_export,
      lv_index      TYPE sy-tabix.

    FIELD-SYMBOLS:
      <lt_export_rows> TYPE STANDARD TABLE,
      <ls_export_row>  TYPE any.

    LOOP AT ct_table_data INTO ls_table_data.
      IF ls_table_data-table_data IS NOT BOUND.
        CONTINUE.
      ENDIF.

      UNASSIGN <lt_export_rows>.
      ASSIGN ls_table_data-table_data->* TO <lt_export_rows>.
      IF sy-subrc <> 0 OR <lt_export_rows> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      lv_index = lines( <lt_export_rows> ).
      WHILE lv_index > 0.
        READ TABLE <lt_export_rows> ASSIGNING <ls_export_row> INDEX lv_index.
        IF sy-subrc <> 0.
          lv_index = lv_index - 1.
          CONTINUE.
        ENDIF.

        IF me->has_first_sheet_hidden_vat( is_data = <ls_export_row> ) = abap_true.
          DELETE <lt_export_rows> INDEX lv_index.
        ENDIF.

        lv_index = lv_index - 1.
      ENDWHILE.
    ENDLOOP.

  ENDMETHOD.


  METHOD append_supplier_group_defs.

    DATA:
      lv_table_no TYPE int4,
      ls_def      TYPE /plmb/s_exp_table_definition.

    FIELD-SYMBOLS <ls_existing_def> TYPE /plmb/s_exp_table_definition.

    LOOP AT ct_table_definition ASSIGNING <ls_existing_def>.
      IF <ls_existing_def>-table_no > lv_table_no.
        lv_table_no = <ls_existing_def>-table_no.
      ENDIF.
    ENDLOOP.

    DO 4 TIMES.
      lv_table_no = lv_table_no + 1.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-table_text     = 'Supplier Group'.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_false.
      ls_def-rowkey         = abap_false.
      ls_def-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_key_col.
      ls_def-fieldtext      = space.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_key_col.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_false.
      ls_def-rowkey         = abap_false.
      ls_def-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_key_row.
      ls_def-fieldtext      = space.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_key_row.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ESTCAT'.
      ls_def-fieldtext      = 'Value Assignment Type'.
      ls_def-fieldtype_name = 'ESEESTCAT'.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ESTCAT_DESC'.
      ls_def-fieldtext      = 'Value Assignment Type Description'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ESTTYPE'.
      ls_def-fieldtext      = 'Value Assignment Category'.
      ls_def-fieldtype_name = 'ESEESTTYPE'.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'NODE_NAME'.
      ls_def-fieldtext      = 'Node Name'.
      ls_def-fieldtype_name = '/PLMB/SPI_NODE_NAME'.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'NODE_DESC'.
      ls_def-fieldtext      = 'Node Description'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'DATATYPE'.
      ls_def-fieldtext      = 'Data Type'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'LINE_NO'.
      ls_def-fieldtext      = 'Line No.'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'SPECID'.
      ls_def-fieldtext      = 'Specification'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'INSTANCE'.
      ls_def-fieldtext      = 'Instance'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'SORT_SEQ'.
      ls_def-fieldtext      = 'Sort Sequence'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'USAGE'.
      ls_def-fieldtext      = 'Usage'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'REF_QTY'.
      ls_def-fieldtext      = 'Reference Quantity'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'RECN'.
      ls_def-fieldtext      = 'Record Number'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ACTN'.
      ls_def-fieldtext      = 'Change Number'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'RECNROOT'.
      ls_def-fieldtext      = 'Root Record'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'RECNPARENT'.
      ls_def-fieldtext      = 'Parent Record'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ESTCAT_VALUE'.
      ls_def-fieldtext      = 'Value Assignment Type'.
      ls_def-fieldtype_name = 'ESEESTCAT'.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'RECN_VP'.
      ls_def-fieldtext      = 'Value Record'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'ACTN_VP'.
      ls_def-fieldtext      = 'Value Change Number'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'SUBID'.
      ls_def-fieldtext      = 'Specification'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'GRP_SUBID'.
      ls_def-fieldtext      = 'Group'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'IDENT1'.
      ls_def-fieldtext      = 'Identifier'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.

      CLEAR ls_def.
      ls_def-table_no       = lv_table_no.
      ls_def-nodedisplay    = abap_true.
      ls_def-rowkey         = abap_true.
      ls_def-fieldname      = 'IDENT1_DESC'.
      ls_def-fieldtext      = 'Identifier Description'.
      ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_def TO ct_table_definition.
    ENDDO.

  ENDMETHOD.


  METHOD append_supplier_group_rows.

    DATA:
      lt_rows       TYPE ty_t_group_export_row,
      lr_rows       TYPE REF TO data,
      ls_table_data TYPE /plmb/s_exp_table_data_export,
      lv_table_no   TYPE int4,
      lv_line_no    TYPE string.

    FIELD-SYMBOLS <lt_rows> TYPE ty_t_group_export_row.

    me->fetch_supplier_group_rows(
      EXPORTING
        it_objects          = it_objects
        it_table_data       = it_table_data
        iv_technical_estcat = iv_technical_estcat
        iv_esttype          = iv_esttype
        iv_specid           = iv_specid
        iv_description      = iv_description
        iv_recn_group       = iv_recn_group
      CHANGING
        ct_rows             = lt_rows
    ).

    IF lt_rows IS INITIAL.
      APPEND VALUE ty_s_group_export_row(
        engine_key_col = 1
        engine_key_row = 1
        estcat       = iv_technical_estcat
        estcat_desc  = iv_description
        esttype      = iv_esttype
        node_name    = 'ZSUPPLIER_GROUP'
        node_desc    = 'Supplier Group'
        datatype     = /plmb/if_exp_c=>gc_data_type-metadata
        line_no      = 1
        specid       = 'META_SPEC_ID'
        instance     = 'META_INSTANCE'
        sort_seq     = 'META_SORT'
        usage        = 'META_USAGE'
        ref_qty      = 'ADDITIONAL_FIELD_REF_QTY_UI'
        recn         = 'RECN'
        actn         = 'ACTN'
        recnroot     = 'RECNROOT'
        recnparent   = 'RECNPARENT'
        estcat_value = 'ESTCAT'
        recn_vp      = 'RECN_VP'
        actn_vp      = 'ACTN_VP'
        subid        = 'SUBID'
        grp_subid    = 'GRP_SUBID'
        ident1       = 'IDENT1'
        ident1_desc  = 'IDENT1_DESC' ) TO lt_rows.
      APPEND VALUE ty_s_group_export_row(
        engine_key_col = 1
        engine_key_row = 2
        estcat       = iv_technical_estcat
        estcat_desc  = iv_description
        esttype      = iv_esttype
        node_name    = 'ZSUPPLIER_GROUP'
        node_desc    = 'Supplier Group'
        datatype     = /plmb/if_exp_c=>gc_data_type-metadata
        line_no      = 2
        specid       = 'Specification'
        instance     = 'Instance'
        sort_seq     = 'Sort Sequence (Instance)'
        usage        = 'Usage'
        ref_qty      = 'Reference Quantity'
        subid        = 'Specification'
        grp_subid    = 'Group'
        ident1       = 'Identifier'
        ident1_desc  = 'Identifier Description' ) TO lt_rows.
      APPEND VALUE ty_s_group_export_row(
        engine_key_col = 1
        engine_key_row = 3
        estcat       = iv_technical_estcat
        estcat_desc  = iv_description
        esttype      = iv_esttype
        node_name    = 'ZSUPPLIER_GROUP'
        node_desc    = 'Supplier Group'
        datatype     = /plmb/if_exp_c=>gc_data_type-metadata
        line_no      = 3
        specid       = 'BF'
        instance     = 'TF'
        sort_seq     = 'TF'
        usage        = 'BF'
        ref_qty      = 'BF'
        subid        = 'BF'
        grp_subid    = 'BF'
        ident1       = 'BF'
        ident1_desc  = 'BF' ) TO lt_rows.
      APPEND VALUE ty_s_group_export_row(
        engine_key_col = 1
        engine_key_row = 4
        estcat       = iv_technical_estcat
        estcat_desc  = iv_description
        esttype      = iv_esttype
        node_name    = 'ZSUPPLIER_GROUP'
        node_desc    = 'Supplier Group'
        datatype     = /plmb/if_exp_c=>gc_data_type-metadata
        line_no      = 4
        specid       = 'S'
        instance     = 'I'
        sort_seq     = 'I'
        usage        = 'S'
        ref_qty      = 'S'
        subid        = 'S'
        grp_subid    = 'S'
        ident1       = 'S'
        ident1_desc  = 'S' ) TO lt_rows.
      APPEND VALUE ty_s_group_export_row(
        engine_key_col = 1
        engine_key_row = 5
        estcat       = iv_technical_estcat
        estcat_desc  = iv_description
        esttype      = iv_esttype
        node_name    = 'ZSUPPLIER_GROUP'
        node_desc    = 'Supplier Group'
        datatype     = /plmb/if_exp_c=>gc_data_type-tabledata
        line_no      = '1'
        specid       = iv_specid
        instance     = '1'
        sort_seq     = '1'
        estcat_value = iv_technical_estcat
        subid        = gc_debug_marker
        ident1       = 'NO_SUPPLIER_GROUP_ROWS'
        ident1_desc  = gc_debug_marker ) TO lt_rows.
    ENDIF.

    lv_line_no = lines( lt_rows ) + 1.
    APPEND VALUE ty_s_group_export_row(
      engine_key_col = 1
      engine_key_row = lv_line_no
      estcat       = iv_technical_estcat
      estcat_desc  = iv_description
      esttype      = iv_esttype
      node_name    = 'ZSUPPLIER_GROUP'
      node_desc    = 'Supplier Group'
      datatype     = /plmb/if_exp_c=>gc_data_type-tabledata
      line_no      = lv_line_no
      specid       = gc_debug_marker
      instance     = '1'
      sort_seq     = lv_line_no
      estcat_value = iv_technical_estcat
      subid        = gc_debug_marker
      ident1       = 'CODE_MARKER'
      ident1_desc  = gc_debug_marker ) TO lt_rows.

    me->default_export_defaults(
      CHANGING
        ct_rows = lt_rows
    ).

    CREATE DATA lr_rows LIKE lt_rows.
    ASSIGN lr_rows->* TO <lt_rows>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    <lt_rows> = lt_rows.
    lv_table_no = lines( ct_table_data ) + 1.

    me->convert_and_append_data(
      EXPORTING
        iv_table_no   = lv_table_no
        ir_out_data   = lr_rows
      CHANGING
        ct_table_data = ct_table_data
    ).

  ENDMETHOD.


  METHOD default_export_defaults.

    DATA:
      lt_metadata TYPE ty_t_group_export_row,
      lt_data     TYPE ty_t_group_export_row,
      lt_marker   TYPE ty_t_group_export_row,
      lt_seen  TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
      lv_index TYPE sy-tabix,
      lv_line_no TYPE i,
      lv_key   TYPE string,
      ls_row   TYPE ty_s_group_export_row.

    FIELD-SYMBOLS <ls_row> TYPE ty_s_group_export_row.

    LOOP AT ct_rows ASSIGNING <ls_row>
      WHERE datatype = /plmb/if_exp_c=>gc_data_type-tabledata.
      IF <ls_row>-instance IS INITIAL.
        <ls_row>-instance = '1'.
      ENDIF.
      IF <ls_row>-ref_qty IS INITIAL.
        <ls_row>-ref_qty = '1'.
      ENDIF.
    ENDLOOP.

    lv_index = 1.
    WHILE lv_index <= lines( ct_rows ).
      READ TABLE ct_rows ASSIGNING <ls_row> INDEX lv_index.
      IF sy-subrc <> 0.
        lv_index = lv_index + 1.
        CONTINUE.
      ENDIF.

      IF <ls_row>-datatype <> /plmb/if_exp_c=>gc_data_type-tabledata OR
         <ls_row>-ident1 = 'CODE_MARKER'.
        lv_index = lv_index + 1.
        CONTINUE.
      ENDIF.

      lv_key = <ls_row>-estcat_value && '|' &&
               <ls_row>-subid && '|' &&
               <ls_row>-ident1.

      READ TABLE lt_seen TRANSPORTING NO FIELDS WITH KEY table_line = lv_key.
      IF sy-subrc = 0.
        DELETE ct_rows INDEX lv_index.
        CONTINUE.
      ENDIF.

      INSERT lv_key INTO TABLE lt_seen.
      lv_index = lv_index + 1.
    ENDWHILE.

    LOOP AT ct_rows INTO ls_row.
      IF ls_row-datatype <> /plmb/if_exp_c=>gc_data_type-tabledata.
        APPEND ls_row TO lt_metadata.
      ELSEIF ls_row-ident1 = 'CODE_MARKER'.
        APPEND ls_row TO lt_marker.
      ELSE.
        APPEND ls_row TO lt_data.
      ENDIF.
    ENDLOOP.

    SORT lt_data BY estcat_desc subid ident1 ident1_desc.

    CLEAR ct_rows.
    APPEND LINES OF lt_metadata TO ct_rows.

    CLEAR lv_line_no.
    LOOP AT lt_data INTO ls_row.
      lv_index = lines( ct_rows ) + 1.
      lv_line_no = lv_line_no + 1.
      ls_row-engine_key_row = lv_index.
      ls_row-line_no = lv_line_no.
      ls_row-sort_seq = lv_line_no.
      APPEND ls_row TO ct_rows.
    ENDLOOP.

    LOOP AT lt_marker INTO ls_row.
      ls_row-engine_key_row = lines( ct_rows ) + 1.
      APPEND ls_row TO ct_rows.
    ENDLOOP.

  ENDMETHOD.


  METHOD fetch_supplier_group_rows.

    TYPES:
      BEGIN OF ty_s_group_member_db,
        group_subid TYPE c LENGTH 30,
        group_type  TYPE c LENGTH 30,
        ord         TYPE n LENGTH 4,
        child_recn  TYPE n LENGTH 20,
        child_subid TYPE c LENGTH 30,
        child_type  TYPE c LENGTH 30,
      END OF ty_s_group_member_db,
      ty_t_group_member_db TYPE STANDARD TABLE OF ty_s_group_member_db WITH DEFAULT KEY.

    DATA:
      lo_connector_rsp   TYPE REF TO /plmb/if_spi_appl_access,
      lo_connector_spc   TYPE REF TO /plmb/if_spi_appl_access,
      lo_metadata_rsp    TYPE REF TO /plmb/if_spi_metadata_output,
      lo_metadata_spc    TYPE REF TO /plmb/if_spi_metadata_output,
      lo_table_type      TYPE REF TO cl_abap_tabledescr,
      lo_cfg_table_type  TYPE REF TO cl_abap_tabledescr,
      lo_id_table_type   TYPE REF TO cl_abap_tabledescr,
      lo_val_table_type  TYPE REF TO cl_abap_tabledescr,
      lr_qual_rows       TYPE REF TO data,
      lr_qual_rows_tmp   TYPE REF TO data,
      lr_val_rows        TYPE REF TO data,
      lr_qual_ids        TYPE REF TO data,
      lr_group_cfg       TYPE REF TO data,
      ls_param           TYPE /plmb/s_rsp_spc_actions,
      ls_param_estcat    TYPE /plmb/s_spc_val_action_estcat,
      lt_cfg             TYPE STANDARD TABLE OF /plmb/s_spc_qua_cfg_sp,
      ls_cfg             TYPE /plmb/s_spc_qua_cfg_sp,
      ls_row             TYPE ty_s_group_export_row,
      lt_val_ids         TYPE /plmb/t_spc_val_id_sp,
      lt_val_id_temp     TYPE /plmb/t_spc_val_id_sp,
      ls_val_id          TYPE /plmb/s_spc_val_id_sp,
      ls_table_data      TYPE /plmb/s_exp_table_data_export,
      lv_object          TYPE /plmb/gos_internal_key,
      lt_spc_id          TYPE /plmb/t_spc_id_sp,
      lt_spc_id_temp     TYPE /plmb/t_spc_id_sp,
      ls_spc_id          TYPE /plmb/s_spc_id_sp,
      lt_spc_data        TYPE /plmb/t_spc_bas_header_sp,
      lt_prop_tree       TYPE /plmb/t_spc_bas_tree_sp,
      lt_prop_tree_id    TYPE /plmb/t_spc_bas_tree_id_sp,
      ls_prop_tree_id    TYPE /plmb/s_spc_bas_tree_id_sp,
      lt_prop_node       TYPE /plmb/t_spc_bas_node_sp,
      lt_prop_node_id    TYPE /plmb/t_spc_bas_node_id_sp,
      ls_prop_node_id    TYPE /plmb/s_spc_bas_node_id_sp,
      lt_index_failed    TYPE /plmb/t_spi_rtr_index_failed,
      lv_row_vat         TYPE string,
      lv_row_node        TYPE string,
      lv_row_sample      TYPE string,
      lt_recn_group      TYPE STANDARD TABLE OF char30,
      lv_recn_group      TYPE char30,
      lv_group_recn      TYPE char30,
      lv_group_recn_db   TYPE n LENGTH 20,
      lv_group_subid     TYPE string,
      lv_group_subid_db  TYPE c LENGTH 30,
      lv_child_subcat_db TYPE c LENGTH 30,
      lv_group_ident     TYPE string,
      lt_group_keys      TYPE STANDARD TABLE OF char30,
      lv_group_key       TYPE char30,
      lt_group_members   TYPE ty_t_group_member_db,
      ls_group_member    TYPE ty_s_group_member_db,
      lv_items_found     TYPE abap_bool,
      lv_cfg_count       TYPE string,
      lv_group_cfg_count TYPE string,
      lv_val_id_count    TYPE string,
      lv_diag            TYPE string,
      lv_line_no         TYPE i,
      lv_failed          TYPE /plmb/spi_failed_ind.

    FIELD-SYMBOLS:
      <lt_qual_ids>      TYPE STANDARD TABLE,
      <lt_qual_rows>     TYPE STANDARD TABLE,
      <lt_qual_rows_tmp> TYPE STANDARD TABLE,
      <lt_val_rows>      TYPE STANDARD TABLE,
      <lt_group_cfg>     TYPE STANDARD TABLE,
      <lt_spc_group>     TYPE STANDARD TABLE,
      <lt_export_rows>   TYPE STANDARD TABLE,
      <ls_prop_tree>     TYPE /plmb/s_spc_bas_tree_sp,
      <ls_prop_node>     TYPE /plmb/s_spc_bas_node_sp,
      <ls_group_cfg>     TYPE any,
      <ls_spc_group>     TYPE any,
      <ls_export_row>    TYPE any,
      <ls_val_row>       TYPE any,
      <ls_qual_row>      TYPE any.

    CALL METHOD /plmb/cl_spi_connector=>create_instance
      EXPORTING
        iv_abbid     = /plmb/if_spc_attr=>gc_abbid_rsp_spc
      IMPORTING
        eo_connector = lo_connector_rsp
        eo_metadata  = lo_metadata_rsp.

    CALL METHOD /plmb/cl_spi_connector=>create_instance
      EXPORTING
        iv_abbid     = /plmb/if_abbid_c=>gc_spc
      IMPORTING
        eo_connector = lo_connector_spc
        eo_metadata  = lo_metadata_spc.

    IF lo_connector_rsp IS NOT BOUND OR lo_metadata_rsp IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_metadata_rsp->get_node_details(
      EXPORTING
        iv_node_name            = /plmb/if_spc_attr=>gc_node_rsp_qual_li
      IMPORTING
        eo_node_id_table_rtti   = lo_id_table_type
        eo_node_data_table_rtti = lo_table_type
    ).

    lo_metadata_rsp->get_node_details(
      EXPORTING
        iv_node_name            = /plmb/if_spc_attr=>gc_node_rsp_config
      IMPORTING
        eo_node_data_table_rtti = lo_cfg_table_type
    ).

    IF lo_table_type IS NOT BOUND OR lo_id_table_type IS NOT BOUND OR lo_cfg_table_type IS NOT BOUND.
      RETURN.
    ENDIF.

    CREATE DATA lr_qual_ids TYPE HANDLE lo_id_table_type.
    CREATE DATA lr_qual_rows TYPE HANDLE lo_table_type.
    CREATE DATA lr_qual_rows_tmp TYPE HANDLE lo_table_type.
    CREATE DATA lr_group_cfg TYPE HANDLE lo_cfg_table_type.
    ASSIGN lr_qual_ids->* TO <lt_qual_ids>.
    ASSIGN lr_qual_rows->* TO <lt_qual_rows>.
    ASSIGN lr_qual_rows_tmp->* TO <lt_qual_rows_tmp>.
    ASSIGN lr_group_cfg->* TO <lt_group_cfg>.
    IF <lt_qual_ids> IS NOT ASSIGNED OR <lt_qual_rows> IS NOT ASSIGNED OR
       <lt_qual_rows_tmp> IS NOT ASSIGNED OR <lt_group_cfg> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT it_table_data INTO ls_table_data.
      IF ls_table_data-table_data IS NOT BOUND.
        CONTINUE.
      ENDIF.

      UNASSIGN <lt_export_rows>.
      ASSIGN ls_table_data-table_data->* TO <lt_export_rows>.
      IF sy-subrc <> 0 OR <lt_export_rows> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      LOOP AT <lt_export_rows> ASSIGNING <ls_export_row>.

        lv_row_vat = me->get_component_string(
          is_data      = <ls_export_row>
          iv_component = /plmb/if_exp_c=>gc_component_key-engine_v_a_type
        ).
        IF lv_row_vat IS INITIAL.
          lv_row_vat = me->get_component_string( is_data = <ls_export_row> iv_component = 'ESTCAT' ).
        ENDIF.
        IF me->get_component_string(
             is_data      = <ls_export_row>
             iv_component = /plmb/if_exp_c=>gc_component_key-engine_datatype
           ) = /plmb/if_exp_c=>gc_data_type-metadata.
          CONTINUE.
        ENDIF.
        IF lv_row_vat IS NOT INITIAL AND lv_row_vat <> iv_technical_estcat.
          CONTINUE.
        ENDIF.
        lv_row_node = me->get_component_string(
          is_data      = <ls_export_row>
          iv_component = /plmb/if_exp_c=>gc_component_key-engine_node_name
        ).
        IF lv_row_node IS NOT INITIAL AND lv_row_node <> 'INSTANCES'.
          CONTINUE.
        ENDIF.

        CLEAR ls_val_id.
        ls_val_id-recn       = me->get_component_string( is_data = <ls_export_row> iv_component = 'RECN' ).
        ls_val_id-actn       = me->get_component_string( is_data = <ls_export_row> iv_component = 'ACTN' ).
        ls_val_id-recnroot   = me->get_component_string( is_data = <ls_export_row> iv_component = 'RECNROOT' ).
        ls_val_id-recnparent = me->get_component_string( is_data = <ls_export_row> iv_component = 'RECNPARENT' ).
        ls_val_id-estcat     = me->get_component_string( is_data = <ls_export_row> iv_component = 'ESTCAT' ).
        IF ls_val_id-estcat IS INITIAL.
          ls_val_id-estcat = iv_technical_estcat.
        ENDIF.
        ls_val_id-recn_vp    = me->get_component_string( is_data = <ls_export_row> iv_component = 'RECN_VP' ).
        ls_val_id-actn_vp    = me->get_component_string( is_data = <ls_export_row> iv_component = 'ACTN_VP' ).

        IF ls_val_id-recn IS NOT INITIAL AND ls_val_id-estcat = iv_technical_estcat.
          APPEND ls_val_id TO lt_val_ids.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT lt_val_ids BY recn actn recnroot recnparent estcat recn_vp actn_vp.
    DELETE ADJACENT DUPLICATES FROM lt_val_ids COMPARING recn actn recnroot recnparent estcat recn_vp actn_vp.

    IF lt_val_ids IS INITIAL AND lo_connector_spc IS BOUND AND lo_metadata_spc IS BOUND.
      LOOP AT it_objects INTO lv_object.
        CLEAR ls_spc_id.
        /plmb/cl_gos_cnv_tools=>split_intern_to_key(
          EXPORTING
            iv_internal_key = lv_object
          IMPORTING
            es_key          = ls_spc_id
        ).
        APPEND ls_spc_id TO lt_spc_id.
      ENDLOOP.

      ls_param_estcat-estcat = iv_technical_estcat.
      ls_param_estcat-is_property = abap_true.
      lo_connector_spc->action(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation
          iv_action_name = /plmb/if_spc_attr=>gc_actions_val-change_structure_def
          is_param       = ls_param_estcat
        IMPORTING
          ev_failed      = lv_failed
      ).

      IF lv_failed <> abap_true.
        lo_metadata_spc->get_node_details(
          EXPORTING
            iv_node_name            = /plmb/if_spc_attr=>gc_node_valuation
          IMPORTING
            eo_node_data_table_rtti = lo_val_table_type
        ).

        IF lo_val_table_type IS BOUND.
          CREATE DATA lr_val_rows TYPE HANDLE lo_val_table_type.
          ASSIGN lr_val_rows->* TO <lt_val_rows>.
        ENDIF.

        IF <lt_val_rows> IS NOT ASSIGNED.
          lv_row_sample = 'NO_VAL_RTTI'.
        ENDIF.

        IF <lt_val_rows> IS ASSIGNED.
          LOOP AT lt_spc_id INTO ls_spc_id.
            CLEAR: lv_failed,
                   lt_index_failed,
                   lt_spc_id_temp,
                   lt_spc_data,
                   lt_prop_tree.
            APPEND ls_spc_id TO lt_spc_id_temp.

            lo_connector_spc->retrieve(
              EXPORTING
                iv_node_name = /plmb/if_spc_attr=>gc_node_basic_header
                it_node_id   = lt_spc_id_temp
              IMPORTING
                ev_failed    = lv_failed
                et_index_failed = lt_index_failed
                et_node_data = lt_spc_data
            ).
            IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
              CONTINUE.
            ENDIF.

            CLEAR: lv_failed,
                   lt_index_failed.
            lo_connector_spc->retrieve(
              EXPORTING
                iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header
                iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree_list
                it_node_id          = lt_spc_id_temp
              IMPORTING
                ev_failed           = lv_failed
                et_index_failed     = lt_index_failed
                et_node_data        = lt_prop_tree
            ).
            IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
              CONTINUE.
            ENDIF.

            LOOP AT lt_prop_tree ASSIGNING <ls_prop_tree>.
              CLEAR: lv_failed,
                     lt_index_failed,
                     lt_prop_tree_id,
                     lt_prop_node.
              MOVE-CORRESPONDING <ls_prop_tree> TO ls_prop_tree_id.
              APPEND ls_prop_tree_id TO lt_prop_tree_id.

              lo_connector_spc->retrieve(
                EXPORTING
                  iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree_list
                  iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree
                  iv_lock             = abap_false
                  it_node_id          = lt_prop_tree_id
                IMPORTING
                  ev_failed           = lv_failed
                  et_index_failed     = lt_index_failed
                  et_node_data        = lt_prop_node
              ).
              IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                CONTINUE.
              ENDIF.

              LOOP AT lt_prop_node ASSIGNING <ls_prop_node>
                WHERE leaf = abap_true AND estcat = iv_technical_estcat.
                CLEAR: lv_failed,
                       lt_index_failed,
                       lt_prop_node_id,
                       <lt_val_rows>.
                MOVE-CORRESPONDING <ls_prop_node> TO ls_prop_node_id.
                APPEND ls_prop_node_id TO lt_prop_node_id.

                lo_connector_spc->retrieve(
                  EXPORTING
                    iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree
                    iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation
                    it_node_id          = lt_prop_node_id
                  IMPORTING
                    ev_failed           = lv_failed
                    et_index_failed     = lt_index_failed
                    et_node_data        = <lt_val_rows>
                ).
                IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                  CONTINUE.
                ENDIF.

                LOOP AT <lt_val_rows> ASSIGNING <ls_val_row>.
                  CLEAR ls_val_id.
                  ls_val_id-recn       = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECN' ).
                  ls_val_id-actn       = me->get_component_string( is_data = <ls_val_row> iv_component = 'ACTN' ).
                  ls_val_id-recnroot   = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECNROOT' ).
                  ls_val_id-recnparent = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECNPARENT' ).
                  ls_val_id-estcat     = me->get_component_string( is_data = <ls_val_row> iv_component = 'ESTCAT' ).
                  ls_val_id-recn_vp    = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECN_VP' ).
                  ls_val_id-actn_vp    = me->get_component_string( is_data = <ls_val_row> iv_component = 'ACTN_VP' ).
                  IF ls_val_id-recn IS NOT INITIAL AND ls_val_id-estcat = iv_technical_estcat.
                    APPEND ls_val_id TO lt_val_ids.
                  ENDIF.
                ENDLOOP.
              ENDLOOP.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ENDIF.

      SORT lt_val_ids BY recn actn recnroot recnparent estcat recn_vp actn_vp.
      DELETE ADJACENT DUPLICATES FROM lt_val_ids COMPARING recn actn recnroot recnparent estcat recn_vp actn_vp.
    ENDIF.

    CLEAR ls_param.
    ls_param-estcat = iv_technical_estcat.
    lo_connector_rsp->action(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_config
        iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group
        is_param       = ls_param
      IMPORTING
        ev_failed      = lv_failed
        et_node_data   = lt_cfg
    ).
    IF lv_failed = abap_true.
      RETURN.
    ENDIF.

    READ TABLE lt_cfg INTO ls_cfg INDEX 1.
    IF sy-subrc = 0.
      ls_param-subcat_group = ls_cfg-subcat_grp.
    ENDIF.

    lo_connector_rsp->action(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_config
        iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qua_spc_group_list
        is_param       = ls_param
      IMPORTING
        ev_failed      = lv_failed
        et_node_data   = <lt_group_cfg>
    ).
    IF lv_failed = abap_true.
      RETURN.
    ENDIF.

    IF lt_val_ids IS INITIAL AND lo_connector_spc IS BOUND AND lo_metadata_spc IS BOUND.
      CLEAR lt_spc_id.

      LOOP AT <lt_group_cfg> ASSIGNING <ls_group_cfg>.
        UNASSIGN <lt_spc_group>.
        ASSIGN COMPONENT 'SPC_GROUP' OF STRUCTURE <ls_group_cfg> TO <lt_spc_group>.
        IF sy-subrc <> 0 OR <lt_spc_group> IS NOT ASSIGNED OR <lt_spc_group> IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_spc_group> ASSIGNING <ls_spc_group>.
          lv_group_recn = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECN' ).
          IF lv_group_recn IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR ls_spc_id.
          MOVE-CORRESPONDING <ls_spc_group> TO ls_spc_id.
          ls_spc_id-recn = lv_group_recn.
          IF ls_spc_id-actn IS INITIAL.
            ls_spc_id-actn = me->get_component_string( is_data = <ls_spc_group> iv_component = 'ACTN' ).
          ENDIF.
          APPEND ls_spc_id TO lt_spc_id.
        ENDLOOP.
      ENDLOOP.

      SORT lt_spc_id BY recn actn.
      DELETE ADJACENT DUPLICATES FROM lt_spc_id COMPARING recn actn.

      IF lt_spc_id IS NOT INITIAL.
        ls_param_estcat-estcat = iv_technical_estcat.
        ls_param_estcat-is_property = abap_true.
        lo_connector_spc->action(
          EXPORTING
            iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation
            iv_action_name = /plmb/if_spc_attr=>gc_actions_val-change_structure_def
            is_param       = ls_param_estcat
          IMPORTING
            ev_failed      = lv_failed
        ).

        IF lv_failed <> abap_true.
          IF lo_val_table_type IS NOT BOUND.
            lo_metadata_spc->get_node_details(
              EXPORTING
                iv_node_name            = /plmb/if_spc_attr=>gc_node_valuation
              IMPORTING
                eo_node_data_table_rtti = lo_val_table_type
            ).
          ENDIF.

          IF lo_val_table_type IS BOUND AND <lt_val_rows> IS NOT ASSIGNED.
            CREATE DATA lr_val_rows TYPE HANDLE lo_val_table_type.
            ASSIGN lr_val_rows->* TO <lt_val_rows>.
          ENDIF.

          IF <lt_val_rows> IS ASSIGNED.
            LOOP AT lt_spc_id INTO ls_spc_id.
              CLEAR: lv_failed,
                     lt_index_failed,
                     lt_spc_id_temp,
                     lt_spc_data,
                     lt_prop_tree.
              APPEND ls_spc_id TO lt_spc_id_temp.

              lo_connector_spc->retrieve(
                EXPORTING
                  iv_node_name     = /plmb/if_spc_attr=>gc_node_basic_header
                  it_node_id       = lt_spc_id_temp
                IMPORTING
                  ev_failed        = lv_failed
                  et_index_failed  = lt_index_failed
                  et_node_data     = lt_spc_data
              ).
              IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                CONTINUE.
              ENDIF.

              CLEAR: lv_failed,
                     lt_index_failed.
              lo_connector_spc->retrieve(
                EXPORTING
                  iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header
                  iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree_list
                  it_node_id          = lt_spc_id_temp
                IMPORTING
                  ev_failed           = lv_failed
                  et_index_failed     = lt_index_failed
                  et_node_data        = lt_prop_tree
              ).
              IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                CONTINUE.
              ENDIF.

              LOOP AT lt_prop_tree ASSIGNING <ls_prop_tree>.
                CLEAR: lv_failed,
                       lt_index_failed,
                       lt_prop_tree_id,
                       lt_prop_node.
                MOVE-CORRESPONDING <ls_prop_tree> TO ls_prop_tree_id.
                APPEND ls_prop_tree_id TO lt_prop_tree_id.

                lo_connector_spc->retrieve(
                  EXPORTING
                    iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree_list
                    iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree
                    iv_lock             = abap_false
                    it_node_id          = lt_prop_tree_id
                  IMPORTING
                    ev_failed           = lv_failed
                    et_index_failed     = lt_index_failed
                    et_node_data        = lt_prop_node
                ).
                IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                  CONTINUE.
                ENDIF.

                LOOP AT lt_prop_node ASSIGNING <ls_prop_node>
                  WHERE leaf = abap_true AND estcat = iv_technical_estcat.
                  CLEAR: lv_failed,
                         lt_index_failed,
                         lt_prop_node_id,
                         <lt_val_rows>.
                  MOVE-CORRESPONDING <ls_prop_node> TO ls_prop_node_id.
                  APPEND ls_prop_node_id TO lt_prop_node_id.

                  lo_connector_spc->retrieve(
                    EXPORTING
                      iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree
                      iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation
                      it_node_id          = lt_prop_node_id
                    IMPORTING
                      ev_failed           = lv_failed
                      et_index_failed     = lt_index_failed
                      et_node_data        = <lt_val_rows>
                  ).
                  IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
                    CONTINUE.
                  ENDIF.

                  LOOP AT <lt_val_rows> ASSIGNING <ls_val_row>.
                    CLEAR ls_val_id.
                    ls_val_id-recn       = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECN' ).
                    ls_val_id-actn       = me->get_component_string( is_data = <ls_val_row> iv_component = 'ACTN' ).
                    ls_val_id-recnroot   = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECNROOT' ).
                    ls_val_id-recnparent = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECNPARENT' ).
                    ls_val_id-estcat     = me->get_component_string( is_data = <ls_val_row> iv_component = 'ESTCAT' ).
                    ls_val_id-recn_vp    = me->get_component_string( is_data = <ls_val_row> iv_component = 'RECN_VP' ).
                    ls_val_id-actn_vp    = me->get_component_string( is_data = <ls_val_row> iv_component = 'ACTN_VP' ).
                    IF ls_val_id-recn IS NOT INITIAL AND ls_val_id-estcat = iv_technical_estcat.
                      APPEND ls_val_id TO lt_val_ids.
                    ENDIF.
                  ENDLOOP.
                ENDLOOP.
              ENDLOOP.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

      SORT lt_val_ids BY recn actn recnroot recnparent estcat recn_vp actn_vp.
      DELETE ADJACENT DUPLICATES FROM lt_val_ids COMPARING recn actn recnroot recnparent estcat recn_vp actn_vp.
    ENDIF.

    APPEND /plmb/if_spc_attr=>gc_actions_qua-qua_show_all TO lt_recn_group.
    APPEND /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained TO lt_recn_group.
    IF iv_recn_group IS NOT INITIAL.
      INSERT iv_recn_group INTO lt_recn_group INDEX 1.
    ENDIF.

    LOOP AT lt_recn_group INTO lv_recn_group.
      CLEAR <lt_qual_rows>.
      CLEAR ls_param.
      ls_param-estcat = iv_technical_estcat.
      ls_param-subcat_group = ls_cfg-subcat_grp.
      ls_param-recn_group = lv_recn_group.
      lo_connector_rsp->action(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_qual_li
          iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qual_list
          is_param       = ls_param
        IMPORTING
          ev_failed      = lv_failed
      ).
      IF lv_failed = abap_true.
        CONTINUE.
      ENDIF.

      lo_connector_rsp->action(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_qual_li
          iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qual_grp
        IMPORTING
          ev_failed      = lv_failed
      ).
      IF lv_failed = abap_true.
        CONTINUE.
      ENDIF.

      LOOP AT lt_val_ids INTO ls_val_id.
        CLEAR: lt_val_id_temp,
               <lt_qual_rows_tmp>.
        APPEND ls_val_id TO lt_val_id_temp.

        lo_connector_rsp->retrieve(
          EXPORTING
            iv_node_name        = /plmb/if_spc_attr=>gc_node_rsp_lead_object
            iv_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_qual_li
            it_node_id          = lt_val_id_temp
          IMPORTING
            ev_failed           = lv_failed
            et_node_data        = <lt_qual_rows_tmp>
        ).
        IF lv_failed = abap_true.
          CONTINUE.
        ENDIF.

        APPEND LINES OF <lt_qual_rows_tmp> TO <lt_qual_rows>.
      ENDLOOP.

      IF <lt_qual_rows> IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF iv_recn_group IS NOT INITIAL.
      CLEAR <lt_qual_rows>.
    ENDIF.

    CLEAR ls_row.
    ls_row-engine_key_col = 1.
    ls_row-engine_key_row = 1.
    ls_row-estcat       = iv_technical_estcat.
    ls_row-estcat_desc  = iv_description.
    ls_row-esttype      = iv_esttype.
    ls_row-node_name    = 'ZSUPPLIER_GROUP'.
    ls_row-node_desc    = 'Supplier Group'.
    ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-metadata.
    ls_row-line_no      = 1.
    ls_row-specid       = 'META_SPEC_ID'.
    ls_row-instance     = 'META_INSTANCE'.
    ls_row-sort_seq     = 'META_SORT'.
    ls_row-usage        = 'META_USAGE'.
    ls_row-ref_qty      = 'ADDITIONAL_FIELD_REF_QTY_UI'.
    ls_row-recn         = 'RECN'.
    ls_row-actn         = 'ACTN'.
    ls_row-recnroot     = 'RECNROOT'.
    ls_row-recnparent   = 'RECNPARENT'.
    ls_row-estcat_value = 'ESTCAT'.
    ls_row-recn_vp      = 'RECN_VP'.
    ls_row-actn_vp      = 'ACTN_VP'.
    ls_row-subid        = 'SUBID'.
    ls_row-grp_subid    = 'GRP_SUBID'.
    ls_row-ident1       = 'IDENT1'.
    ls_row-ident1_desc  = 'IDENT1_DESC'.
    APPEND ls_row TO ct_rows.

    CLEAR ls_row.
    ls_row-engine_key_col = 1.
    ls_row-engine_key_row = 2.
    ls_row-estcat       = iv_technical_estcat.
    ls_row-estcat_desc  = iv_description.
    ls_row-esttype      = iv_esttype.
    ls_row-node_name    = 'ZSUPPLIER_GROUP'.
    ls_row-node_desc    = 'Supplier Group'.
    ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-metadata.
    ls_row-line_no      = 2.
    ls_row-specid       = 'Specification'.
    ls_row-instance     = 'Instance'.
    ls_row-sort_seq     = 'Sort Sequence (Instance)'.
    ls_row-usage        = 'Usage'.
    ls_row-ref_qty      = 'Reference Quantity'.
    ls_row-subid        = 'Specification'.
    ls_row-grp_subid    = 'Group'.
    ls_row-ident1       = 'Identifier'.
    ls_row-ident1_desc  = 'Identifier Description'.
    APPEND ls_row TO ct_rows.

    CLEAR ls_row.
    ls_row-engine_key_col = 1.
    ls_row-engine_key_row = 3.
    ls_row-estcat       = iv_technical_estcat.
    ls_row-estcat_desc  = iv_description.
    ls_row-esttype      = iv_esttype.
    ls_row-node_name    = 'ZSUPPLIER_GROUP'.
    ls_row-node_desc    = 'Supplier Group'.
    ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-metadata.
    ls_row-line_no      = 3.
    ls_row-specid       = 'BF'.
    ls_row-instance     = 'TF'.
    ls_row-sort_seq     = 'TF'.
    ls_row-usage        = 'BF'.
    ls_row-ref_qty      = 'BF'.
    ls_row-subid        = 'BF'.
    ls_row-grp_subid    = 'BF'.
    ls_row-ident1       = 'BF'.
    ls_row-ident1_desc  = 'BF'.
    APPEND ls_row TO ct_rows.

    CLEAR ls_row.
    ls_row-engine_key_col = 1.
    ls_row-engine_key_row = 4.
    ls_row-estcat       = iv_technical_estcat.
    ls_row-estcat_desc  = iv_description.
    ls_row-esttype      = iv_esttype.
    ls_row-node_name    = 'ZSUPPLIER_GROUP'.
    ls_row-node_desc    = 'Supplier Group'.
    ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-metadata.
    ls_row-line_no      = 4.
    ls_row-specid       = 'S'.
    ls_row-instance     = 'I'.
    ls_row-sort_seq     = 'I'.
    ls_row-usage        = 'S'.
    ls_row-ref_qty      = 'S'.
    ls_row-subid        = 'S'.
    ls_row-grp_subid    = 'S'.
    ls_row-ident1       = 'S'.
    ls_row-ident1_desc  = 'S'.
    APPEND ls_row TO ct_rows.

    IF <lt_qual_rows> IS INITIAL AND
       <lt_group_cfg> IS NOT INITIAL AND
       iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all.
      LOOP AT <lt_group_cfg> ASSIGNING <ls_group_cfg>.
        UNASSIGN <lt_spc_group>.
        ASSIGN COMPONENT 'SPC_GROUP' OF STRUCTURE <ls_group_cfg> TO <lt_spc_group>.
        IF sy-subrc <> 0 OR <lt_spc_group> IS NOT ASSIGNED OR <lt_spc_group> IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_spc_group> ASSIGNING <ls_spc_group>.
          CLEAR: lv_group_recn,
                 lv_group_subid,
                 lv_group_ident,
                 ls_param,
                 lt_val_id_temp,
                 <lt_qual_rows_tmp>.

          lv_group_recn  = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECN' ).
          lv_group_subid = me->get_component_string( is_data = <ls_spc_group> iv_component = 'SUBID' ).
          lv_group_ident = me->get_component_string( is_data = <ls_spc_group> iv_component = 'IDENT' ).

          IF lv_group_recn IS INITIAL.
            CONTINUE.
          ENDIF.

          IF iv_recn_group IS NOT INITIAL AND
             iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all AND
             iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained AND
             lv_group_recn <> iv_recn_group AND
             lv_group_subid <> iv_recn_group AND
             lv_group_ident <> iv_recn_group.
            CONTINUE.
          ENDIF.

          ls_param-estcat = iv_technical_estcat.
          ls_param-subcat_group = ls_cfg-subcat_grp.
          ls_param-recn_group = iv_recn_group.
          IF ls_param-recn_group IS INITIAL.
            ls_param-recn_group = lv_group_recn.
          ENDIF.
          IF ls_param-recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all OR
             ls_param-recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained.
            ls_param-recn_group = lv_group_recn.
          ENDIF.

          lo_connector_rsp->action(
            EXPORTING
              iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_qual_li
              iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qual_list
              is_param       = ls_param
            IMPORTING
              ev_failed      = lv_failed
          ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          lo_connector_rsp->action(
            EXPORTING
              iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_qual_li
              iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qual_grp
            IMPORTING
              ev_failed      = lv_failed
          ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          CLEAR ls_val_id.
          ls_val_id-recn       = lv_group_recn.
          ls_val_id-actn       = me->get_component_string( is_data = <ls_spc_group> iv_component = 'ACTN' ).
          ls_val_id-recnroot   = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECNROOT' ).
          IF ls_val_id-recnroot IS INITIAL.
            ls_val_id-recnroot = lv_group_recn.
          ENDIF.
          ls_val_id-recnparent = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECNPARENT' ).
          ls_val_id-estcat     = iv_technical_estcat.
          ls_val_id-recn_vp    = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECN_VP' ).
          ls_val_id-actn_vp    = me->get_component_string( is_data = <ls_spc_group> iv_component = 'ACTN_VP' ).
          APPEND ls_val_id TO lt_val_id_temp.

          lo_connector_rsp->retrieve(
            EXPORTING
              iv_node_name        = /plmb/if_spc_attr=>gc_node_rsp_lead_object
              iv_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_qual_li
              it_node_id          = lt_val_id_temp
            IMPORTING
              ev_failed           = lv_failed
              et_node_data        = <lt_qual_rows_tmp>
          ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          APPEND LINES OF <lt_qual_rows_tmp> TO <lt_qual_rows>.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF <lt_qual_rows> IS INITIAL AND <lt_group_cfg> IS NOT INITIAL.
      LOOP AT <lt_group_cfg> ASSIGNING <ls_group_cfg>.
        UNASSIGN <lt_spc_group>.
        ASSIGN COMPONENT 'SPC_GROUP' OF STRUCTURE <ls_group_cfg> TO <lt_spc_group>.
        IF sy-subrc <> 0 OR <lt_spc_group> IS NOT ASSIGNED OR <lt_spc_group> IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_spc_group> ASSIGNING <ls_spc_group>.
          CLEAR: lv_group_recn,
                 lv_group_recn_db,
                 lv_group_subid,
                 lv_group_subid_db,
                 lv_child_subcat_db,
                 lv_group_ident,
                 lt_group_members.

          lv_group_recn    = me->get_component_string( is_data = <ls_spc_group> iv_component = 'RECN' ).
          lv_group_subid   = me->get_component_string( is_data = <ls_spc_group> iv_component = 'SUBID' ).
          lv_group_ident   = me->get_component_string( is_data = <ls_spc_group> iv_component = 'IDENT' ).
          lv_group_recn_db = lv_group_recn.
          lv_group_subid_db = lv_group_subid.

          IF lv_group_recn_db IS INITIAL AND lv_group_subid_db IS INITIAL.
            CONTINUE.
          ENDIF.

          IF iv_recn_group IS NOT INITIAL AND
             iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all AND
             iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained AND
             lv_group_recn <> iv_recn_group AND
             lv_group_subid <> iv_recn_group AND
             lv_group_ident <> iv_recn_group.
            CONTINUE.
          ENDIF.

          CASE ls_cfg-subcat_grp.
            WHEN 'ALLERG_GRP'.
              lv_child_subcat_db = 'ALLERGEN'.
            WHEN 'DIET_GROUP' OR 'DIET'.
              lv_child_subcat_db = 'DIET'.
            WHEN 'RELIG_GRP' OR 'RELIGIOUS' OR 'B'.
              lv_child_subcat_db = 'RELIGIOUS'.
            WHEN 'GENMOD' OR 'GENMOD_GRP'.
              lv_child_subcat_db = 'GENMOD'.
          ENDCASE.

          IF lv_child_subcat_db IS INITIAL.
            CONTINUE.
          ENDIF.

          IF lv_group_recn_db IS NOT INITIAL.
            SELECT grp~subid AS group_subid
                   grp~subcat AS group_type
                   vp~ord AS ord
                   child~recn AS child_recn
                   child~subid AS child_subid
                   child~subcat AS child_type
              INTO TABLE lt_group_members
              FROM estrh AS grp
              INNER JOIN estva AS va
                ON va~recnroot = grp~recnroot
              INNER JOIN estvp AS vp
                ON vp~recnroot = va~recnroot
               AND vp~recntva  = va~recn
              INNER JOIN estrh AS child
                ON child~recn = vp~recncmp
              WHERE grp~recn = lv_group_recn_db
                AND child~subcat = lv_child_subcat_db.
          ENDIF.

          IF lt_group_members IS INITIAL AND lv_group_subid_db IS NOT INITIAL.
            SELECT grp~subid AS group_subid
                   grp~subcat AS group_type
                   vp~ord AS ord
                   child~recn AS child_recn
                   child~subid AS child_subid
                   child~subcat AS child_type
              INTO TABLE lt_group_members
              FROM estrh AS grp
              INNER JOIN estva AS va
                ON va~recnroot = grp~recnroot
              INNER JOIN estvp AS vp
                ON vp~recnroot = va~recnroot
               AND vp~recntva  = va~recn
              INNER JOIN estrh AS child
                ON child~recn = vp~recncmp
              WHERE grp~subid = lv_group_subid_db
                AND child~subcat = lv_child_subcat_db.
          ENDIF.

          SORT lt_group_members BY group_subid ord child_subid.
          DELETE ADJACENT DUPLICATES FROM lt_group_members COMPARING group_subid ord child_subid.

          LOOP AT lt_group_members INTO ls_group_member.
            lv_line_no = lv_line_no + 1.

            CLEAR ls_row.
            ls_row-engine_key_col = 1.
            ls_row-engine_key_row = lv_line_no + 4.
            ls_row-estcat       = iv_technical_estcat.
            ls_row-estcat_desc  = iv_description.
            ls_row-esttype      = iv_esttype.
            ls_row-node_name    = 'ZSUPPLIER_GROUP'.
            ls_row-node_desc    = 'Supplier Group'.
            ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-tabledata.
            ls_row-line_no      = lv_line_no.
            ls_row-specid       = ls_group_member-child_subid.
            ls_row-instance     = '1'.
            ls_row-sort_seq     = ls_group_member-ord.
            ls_row-recn         = ls_group_member-child_recn.
            ls_row-estcat_value = iv_technical_estcat.
            ls_row-subid        = ls_group_member-child_subid.
            ls_row-grp_subid    = ls_group_member-group_subid.
            ls_row-ident1       = ls_group_member-child_subid.
            ls_row-ident1_desc  = ls_group_member-child_subid.
            APPEND ls_row TO ct_rows.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

      IF lv_line_no > 0.
        RETURN.
      ENDIF.
    ENDIF.

    IF <lt_qual_rows> IS INITIAL.
      lv_line_no = lv_line_no + 1.
      lv_cfg_count = lines( lt_cfg ).
      lv_group_cfg_count = lines( <lt_group_cfg> ).
      lv_val_id_count = lines( lt_val_ids ).
      CONCATENATE 'CFG=' lv_cfg_count
                  ';GROUP_CFG=' lv_group_cfg_count
                  ';VAL_IDS=' lv_val_id_count
        INTO lv_diag.

      CLEAR ls_row.
      ls_row-engine_key_col = 1.
      ls_row-engine_key_row = lv_line_no + 4.
      ls_row-estcat       = iv_technical_estcat.
      ls_row-estcat_desc  = iv_description.
      ls_row-esttype      = iv_esttype.
      ls_row-node_name    = 'ZSUPPLIER_GROUP'.
      ls_row-node_desc    = 'Supplier Group'.
      ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-tabledata.
      ls_row-line_no      = lv_line_no.
      ls_row-specid       = gc_debug_marker.
      ls_row-instance     = '1'.
      ls_row-sort_seq     = lv_line_no.
      ls_row-estcat_value = iv_technical_estcat.
      ls_row-subid        = 'NO_QUAL_ROWS'.
      ls_row-grp_subid    = ls_cfg-subcat_grp.
      ls_row-ident1       = iv_recn_group.
      ls_row-ident1_desc  = lv_diag.
      APPEND ls_row TO ct_rows.
      RETURN.
    ENDIF.

    LOOP AT <lt_qual_rows> ASSIGNING <ls_qual_row>.
      lv_line_no = lv_line_no + 1.

      CLEAR ls_row.
      ls_row-engine_key_col = 1.
      ls_row-engine_key_row = lv_line_no + 4.
      ls_row-estcat       = iv_technical_estcat.
      ls_row-estcat_desc  = iv_description.
      ls_row-esttype      = iv_esttype.
      ls_row-node_name    = 'ZSUPPLIER_GROUP'.
      ls_row-node_desc    = 'Supplier Group'.
      ls_row-datatype     = /plmb/if_exp_c=>gc_data_type-tabledata.
      ls_row-line_no      = lv_line_no.
      ls_row-specid       = iv_specid.
      ls_row-instance     = '1'.
      ls_row-sort_seq     = lv_line_no.
      ls_row-recn         = me->get_component_string( is_data = <ls_qual_row> iv_component = 'RECN' ).
      ls_row-actn         = me->get_component_string( is_data = <ls_qual_row> iv_component = 'ACTN' ).
      ls_row-recnroot     = me->get_component_string( is_data = <ls_qual_row> iv_component = 'RECNROOT' ).
      ls_row-recnparent   = me->get_component_string( is_data = <ls_qual_row> iv_component = 'RECNPARENT' ).
      ls_row-estcat_value = iv_technical_estcat.
      ls_row-recn_vp      = me->get_component_string( is_data = <ls_qual_row> iv_component = 'RECN_VP' ).
      ls_row-actn_vp      = me->get_component_string( is_data = <ls_qual_row> iv_component = 'ACTN_VP' ).
      ls_row-subid        = me->get_component_string( is_data = <ls_qual_row> iv_component = 'SUBID' ).
      IF ls_row-subid IS INITIAL.
        ls_row-subid = me->get_component_string( is_data = <ls_qual_row> iv_component = 'IDENT1' ).
      ENDIF.
      ls_row-grp_subid   = me->get_component_string( is_data = <ls_qual_row> iv_component = 'GRP_SUBID' ).
      ls_row-ident1      = me->get_component_string( is_data = <ls_qual_row> iv_component = 'IDENT1' ).
      ls_row-ident1_desc = me->get_component_string( is_data = <ls_qual_row> iv_component = 'IDENT1_DESC' ).
      IF ls_row-ident1_desc IS INITIAL.
        ls_row-ident1_desc = me->get_component_string( is_data = <ls_qual_row> iv_component = 'COMPEXCVALNAM' ).
      ENDIF.
      APPEND ls_row TO ct_rows.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_component_string.

    FIELD-SYMBOLS <lv_value> TYPE any.

    ASSIGN COMPONENT iv_component OF STRUCTURE is_data TO <lv_value>.
    IF sy-subrc = 0.
      rv_value = <lv_value>.
    ENDIF.

  ENDMETHOD.


  METHOD get_add_info_value.

    DATA ls_add_info TYPE /plmb/s_exp_additional_info.

    FIELD-SYMBOLS <lv_value> TYPE any.

    READ TABLE it_add_info INTO ls_add_info WITH KEY fname = iv_fname.
    IF sy-subrc <> 0 OR ls_add_info-value IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN ls_add_info-value->* TO <lv_value>.
    IF sy-subrc = 0.
      rv_value = <lv_value>.
    ENDIF.

  ENDMETHOD.


  METHOD has_first_sheet_hidden_vat.

    DATA:
      lo_struct     TYPE REF TO cl_abap_structdescr,
      lo_value_type TYPE REF TO cl_abap_typedescr,
      lt_components TYPE abap_component_tab,
      ls_component  TYPE abap_componentdescr,
      lv_value      TYPE string.

    FIELD-SYMBOLS <lv_value> TYPE any.

    lo_struct ?= cl_abap_typedescr=>describe_by_data( is_data ).
    lt_components = lo_struct->get_components( ).

    LOOP AT lt_components INTO ls_component.
      UNASSIGN <lv_value>.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE is_data TO <lv_value>.
      IF sy-subrc <> 0 OR <lv_value> IS INITIAL.
        CONTINUE.
      ENDIF.

      lo_value_type = cl_abap_typedescr=>describe_by_data( <lv_value> ).
      IF lo_value_type->kind <> cl_abap_typedescr=>kind_elem.
        CONTINUE.
      ENDIF.

      lv_value = <lv_value>.
      CASE lv_value.
        WHEN 'SAP_RMS_1012_005'
          OR 'SAP_RMS_1012_010'
          OR 'SAP_RMS_1012_021'
          OR 'SAP_RMS_1012_022'
          OR 'SAP_RMS_1012_025'
          OR 'SAP_EHS_1012_003'.
          rv_value = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD deserialize_selection_xml.

    DATA: lt_vat TYPE SORTED TABLE OF eseestcat WITH UNIQUE KEY table_line.

    FIELD-SYMBOLS: <ls_selection> TYPE /plmb/s_spc_exp_ptree_select,
                   <ls_vat>       TYPE /plmb/s_spc_exp_estcat_select.

    CLEAR et_selection.

    IF iv_selection IS NOT INITIAL.
      "CALL TRANSFORMATION can raise exception, we catch it here and raise ASSERT
      TRY.
          CALL TRANSFORMATION id
            SOURCE XML iv_selection
            RESULT     root = et_selection.
        CATCH cx_transformation_error.
          ASSERT 1 = 0.
      ENDTRY.
    ENDIF.

*--------------------------------------------------------------------*
* Delete duplicate entries and delete lines where no
* value assignment type needs to be queried
*--------------------------------------------------------------------*
    IF et_selection IS NOT INITIAL.
      SORT et_selection BY property_tree ASCENDING.
      DELETE ADJACENT DUPLICATES FROM et_selection COMPARING property_tree.
*--------------------------------------------------------------------*
*   Allow only one Value Assignment Type per selection
*   If the same VAT is in more property tree, it will be selected only once
*--------------------------------------------------------------------*
      LOOP AT et_selection ASSIGNING <ls_selection>.
        SORT <ls_selection>-value_assignment_types BY estcat ASCENDING.
        DELETE ADJACENT DUPLICATES FROM <ls_selection>-value_assignment_types COMPARING estcat.
        LOOP AT <ls_selection>-value_assignment_types ASSIGNING <ls_vat>.
          READ TABLE lt_vat TRANSPORTING NO FIELDS BINARY SEARCH WITH KEY table_line = <ls_vat>-estcat.
          IF sy-subrc = 0.
            DELETE <ls_selection>-value_assignment_types.
          ELSE.
            CLEAR <ls_vat>-parent_estcat.
            INSERT <ls_vat>-estcat INTO TABLE lt_vat.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      DELETE et_selection WHERE value_assignment_types IS INITIAL.
    ENDIF.

  ENDMETHOD.

  METHOD process_table_data.

    TYPES:
      BEGIN OF ty_s_allowed_value,
        atnam TYPE cabn-atnam,
        sort_seq TYPE estpj-ord,
        allowed_value TYPE estpp-phrtext,
      END OF ty_s_allowed_value,
      BEGIN OF ty_s_atnam,
        atnam TYPE cabn-atnam,
      END OF ty_s_atnam.

    DATA:
      ls_vatcust              TYPE /plmb/s_spc_val_action_vatcust,
      ls_atnam                TYPE ty_s_atnam,
      ls_allowed_value        TYPE ty_s_allowed_value,
      lt_vat_atnam            TYPE STANDARD TABLE OF ty_s_atnam,
      lt_allowed_values       TYPE STANDARD TABLE OF ty_s_allowed_value,
      lv_failed               TYPE /plmb/spi_failed_ind,
      lv_fieldname            TYPE abap_compname,
      lv_additional_info      TYPE string,
      lv_additional_info_part TYPE string,
      lv_allowed_values       TYPE string,
      lr_metadata_line        TYPE REF TO data,
      lo_spi_connector_spc    TYPE REF TO /plmb/if_spi_appl_access,
      lv_insert_index         TYPE sy-tabix.

    FIELD-SYMBOLS:
      <ls_table_meta_data> TYPE ty_s_table_meta_data,
      <ls_table_data>      TYPE /plmb/s_exp_table_data_export,
      <lt_table_data>      TYPE STANDARD TABLE,
      <ls_table_line>      TYPE any,
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

    LOOP AT <lt_table_data> ASSIGNING <ls_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_table_line> TO <lv_data>.
        IF sy-subrc = 0 AND <lv_data> = 5.
          ASSIGN <ls_table_line> TO <ls_metadata_line>.
          CLEAR lv_insert_index.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CALL METHOD /plmb/cl_spi_connector=>create_instance
      EXPORTING
        iv_abbid     = /plmb/if_abbid_c=>gc_spc
      IMPORTING
        eo_connector = lo_spi_connector_spc.
    IF lo_spi_connector_spc IS NOT BOUND.
      RETURN.
    ENDIF.

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

    IF <ls_metadata_line> IS NOT ASSIGNED.
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
    ENDIF.
    IF <ls_metadata_line> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT ls_vatcust-vat_customizing ASSIGNING <ls_vatcust>
      WHERE estcat = iv_technical_estcat
        AND atnam IS NOT INITIAL.
      ls_atnam-atnam = <ls_vatcust>-atnam.
      APPEND ls_atnam TO lt_vat_atnam.
    ENDLOOP.

    SORT lt_vat_atnam BY atnam.
    DELETE ADJACENT DUPLICATES FROM lt_vat_atnam COMPARING atnam.

    IF lt_vat_atnam IS NOT INITIAL.
      SELECT cabn~atnam
             cawn~atzhl
             cawn~atwrt
        INTO TABLE lt_allowed_values
        FROM cabn
        INNER JOIN cawn
          ON cawn~atinn = cabn~atinn
        FOR ALL ENTRIES IN lt_vat_atnam
        WHERE cabn~atnam = lt_vat_atnam-atnam.

      SELECT tcg66~atnam
             estpj~ord
             estpp~phrtext
        APPENDING TABLE lt_allowed_values
        FROM tcg66
        INNER JOIN estpj
          ON estpj~recntps = tcg66~recntps
        INNER JOIN estph
          ON estph~recn = estpj~recntph
        INNER JOIN estpp
          ON estpp~recnroot = estph~recnroot
        FOR ALL ENTRIES IN lt_vat_atnam
        WHERE tcg66~estcat = iv_technical_estcat
          AND tcg66~atnam = lt_vat_atnam-atnam
          AND tcg66~recntps <> '00000000000000000000'
          AND estpj~delflg <> 'X'
          AND estpj~parkflg <> 'X'
          AND estpj~valfr <= sy-datum
          AND estpj~valto >= sy-datum
          AND estph~delflg <> 'X'
          AND estph~parkflg <> 'X'
          AND estph~valfr <= sy-datum
          AND estph~valto >= sy-datum
          AND estpp~langu = sy-langu
          AND estpp~delflg <> 'X'
          AND estpp~parkflg <> 'X'
          AND estpp~valfr <= sy-datum
          AND estpp~valto >= sy-datum.

      DELETE lt_allowed_values WHERE allowed_value IS INITIAL.
      SORT lt_allowed_values BY atnam allowed_value sort_seq.
      DELETE ADJACENT DUPLICATES FROM lt_allowed_values COMPARING atnam allowed_value.
      SORT lt_allowed_values BY atnam sort_seq allowed_value.
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
             lv_additional_info_part,
             lv_allowed_values.

      IF <ls_vatcust>-flg_is_no_single_value = abap_true.
        lv_additional_info = 'Multiple values allowed'.
      ELSE.
        lv_additional_info = 'Single value'.
      ENDIF.

      IF <ls_vatcust>-flg_is_no_single_value = 'D'.
        CONCATENATE lv_additional_info 'Predefined list (dropdown)' INTO lv_additional_info SEPARATED BY '; '.
      ENDIF.

      IF <ls_vatcust>-flg_input_required = abap_true.
        CONCATENATE lv_additional_info 'Entry required' INTO lv_additional_info SEPARATED BY '; '.
      ENDIF.

      IF <ls_vatcust>-anzst IS NOT INITIAL.
        lv_additional_info_part = <ls_vatcust>-anzst.
        SHIFT lv_additional_info_part LEFT DELETING LEADING space.
        CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
        CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
      ENDIF.

      CASE <ls_vatcust>-atfor.
        WHEN 'NUM' OR 'CURR'.
          CONCATENATE lv_additional_info 'Numeric value' INTO lv_additional_info SEPARATED BY '; '.
          IF <ls_vatcust>-msehi IS NOT INITIAL.
            lv_additional_info_part = <ls_vatcust>-msehi.
            CONCATENATE 'Default UoM (' lv_additional_info_part ')' INTO lv_additional_info_part.
            CONCATENATE lv_additional_info lv_additional_info_part INTO lv_additional_info SEPARATED BY '; '.
          ENDIF.
        WHEN 'DATE'.
          CONCATENATE lv_additional_info 'Date format YYYYMMDD' INTO lv_additional_info SEPARATED BY '; '.
        WHEN 'CHAR'.
          CONCATENATE lv_additional_info 'Character value' INTO lv_additional_info SEPARATED BY '; '.
      ENDCASE.

      lv_fieldname = <ls_vatcust>-atnam.
      TRANSLATE lv_fieldname USING '-_'.

      LOOP AT lt_allowed_values INTO ls_allowed_value WHERE atnam = <ls_vatcust>-atnam.
        IF lv_allowed_values IS INITIAL.
          lv_allowed_values = ls_allowed_value-allowed_value.
        ELSE.
          CONCATENATE lv_allowed_values ls_allowed_value-allowed_value INTO lv_allowed_values
            SEPARATED BY '||ALLOWED_VALUE||'.
        ENDIF.
      ENDLOOP.

      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_metadata_line> TO <lv_data>.
      IF sy-subrc = 0.
        IF lv_allowed_values IS INITIAL.
          <lv_data> = lv_additional_info.
        ELSE.
          CONCATENATE lv_additional_info lv_allowed_values INTO <lv_data>
            SEPARATED BY '||ALLOWED_VALUES||'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lr_metadata_line IS BOUND.
      IF lv_insert_index IS INITIAL.
        APPEND <ls_metadata_line> TO <lt_table_data>.
      ELSE.
        INSERT <ls_metadata_line> INTO <lt_table_data> INDEX lv_insert_index.
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
