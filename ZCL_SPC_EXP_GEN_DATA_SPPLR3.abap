CLASS zcl_spc_exp_gen_data_spplr2 DEFINITION
  PUBLIC
  INHERITING FROM /plmi/cl_spc_exp_gen_data_sngl FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /plmb/if_exp_generic_data~get_definition  REDEFINITION.
    METHODS /plmb/if_exp_generic_data~get_export_data REDEFINITION.

  PROTECTED SECTION.
    METHODS process_table_data REDEFINITION.

  PRIVATE SECTION.
    DATA mv_nutrient_key_date TYPE sy-datum.
    DATA mt_folder_nodes TYPE /plmb/t_spc_bas_node_sp.
    DATA mt_exported_folders TYPE SORTED TABLE OF /plmb/s_spc_bas_node_id_sp
      WITH UNIQUE KEY menid id.

    METHODS retrieve_folder_nodes
      IMPORTING it_objects TYPE /plmb/t_gos_internal_key
                it_selection TYPE /plmb/t_spc_exp_ptree_select.
    METHODS append_folder_rows
      CHANGING ct_rows TYPE STANDARD TABLE.

    TYPES:
      BEGIN OF ty_s_group_member_db,
        group_subid TYPE c LENGTH 30,
        group_type  TYPE c LENGTH 30,
        ord         TYPE n LENGTH 4,
        child_recn  TYPE n LENGTH 20,
        child_subid TYPE c LENGTH 30,
        child_type  TYPE c LENGTH 30,
        compexp     TYPE estvp-compexp,
      END OF ty_s_group_member_db,
      ty_t_group_member_db TYPE STANDARD TABLE OF ty_s_group_member_db WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_s_child_identifier,
             child_recn TYPE estrh-recn,
             langu      TYPE estri-langu,
             ident      TYPE estri-ident,
           END OF ty_s_child_identifier.
    TYPES ty_t_child_identifier TYPE STANDARD TABLE OF ty_s_child_identifier WITH DEFAULT KEY.

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
        compexp_stext  TYPE string,
      END OF ty_s_group_export_row,
      ty_t_group_export_row TYPE STANDARD TABLE OF ty_s_group_export_row WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_s_allowed_value,
             atnam              TYPE cabn-atnam,
             sort_seq           TYPE estpj-ord,
             allowed_value      TYPE estpp-phrtext,
             allowed_value_desc TYPE estpp-phrtext,
             is_default         TYPE cawn-atstd,
           END OF ty_s_allowed_value.
    TYPES: BEGIN OF ty_s_atnam,
             atnam       TYPE cabn-atnam,
             atfor       TYPE cabn-atfor,
             atprt       TYPE cabn-atprt,
             msehi       TYPE cabn-msehi,
             atbez       TYPE cabnt-atbez,
             value_field TYPE string,
             desc_field  TYPE string,
           END OF ty_s_atnam.
    TYPES: BEGIN OF ty_s_check_field,
             fieldname TYPE dd03l-fieldname,
             keyflag   TYPE dd03l-keyflag,
             position  TYPE dd03l-position,
             datatype  TYPE dd03l-datatype,
           END OF ty_s_check_field.
    TYPES: BEGIN OF ty_s_cawn_allowed_value,
             atnam TYPE cabn-atnam,
             atzhl TYPE cawn-atzhl,
             atwrt TYPE cawn-atwrt,
             atflv TYPE cawn-atflv,
             atcod TYPE cawn-atcod,
             atawe TYPE cawn-atawe,
             atwtb TYPE cawnt-atwtb,
             atstd TYPE cawn-atstd,
           END OF ty_s_cawn_allowed_value.
    TYPES: BEGIN OF ty_s_lookup_helper,
             check_table  TYPE dd03l-tabname,
             helper_table TYPE dd03l-tabname,
             value_field  TYPE dd03l-fieldname,
             desc_field   TYPE dd03l-fieldname,
           END OF ty_s_lookup_helper.
    TYPES: BEGIN OF ty_s_plant_value,
             werks TYPE werks_d,
             name1 TYPE ad_name1,
           END OF ty_s_plant_value.
    TYPES ty_t_atnam TYPE STANDARD TABLE OF ty_s_atnam WITH DEFAULT KEY.
    TYPES ty_t_allowed_value TYPE STANDARD TABLE OF ty_s_allowed_value WITH DEFAULT KEY.

    METHODS update_export_rows
      IMPORTING iv_instance_field TYPE string
                iv_property_tree_text TYPE string
      CHANGING ct_rows TYPE STANDARD TABLE.

    METHODS retrieve_group_member_data
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_group_recn TYPE char30
                iv_group_subid TYPE string
      EXPORTING et_group_members TYPE ty_t_group_member_db.

    METHODS retrieve_nutrient_listing
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_recn_group TYPE char30
      EXPORTING et_group_members TYPE ty_t_group_member_db.

    METHODS retrieve_child_identifiers
      IMPORTING it_group_members TYPE ty_t_group_member_db
      EXPORTING et_child_identifiers TYPE ty_t_child_identifier.

    METHODS resolve_member_unit
      IMPORTING iv_technical_estcat TYPE eseestcat
                is_group_member TYPE ty_s_group_member_db
      RETURNING VALUE(rv_unit_text) TYPE string.

    METHODS resolve_member_identifier
      IMPORTING is_group_member TYPE ty_s_group_member_db
                it_child_identifiers TYPE ty_t_child_identifier
      RETURNING VALUE(rv_identifier) TYPE string.

    METHODS format_numeric_allowed_value
      IMPORTING is_value TYPE ty_s_cawn_allowed_value
                is_characteristic TYPE ty_s_atnam
      EXPORTING ev_value TYPE estpp-phrtext.

    METHODS build_field_guidance
      IMPORTING is_configuration TYPE /plmb/s_spc_val_conf_sp
      EXPORTING ev_guidance TYPE string.

    METHODS serialize_allowed_values
      IMPORTING it_allowed_values TYPE ty_t_allowed_value
                iv_atnam TYPE cabn-atnam
      EXPORTING ev_values TYPE string.

    METHODS retrieve_plant_values
      IMPORTING it_characteristics TYPE ty_t_atnam
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS resolve_lookup_fields
      IMPORTING iv_lookup_table TYPE dd03l-tabname
      CHANGING cs_characteristic TYPE ty_s_atnam.

    METHODS retrieve_check_table_values
      IMPORTING it_characteristics TYPE ty_t_atnam
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS retrieve_characteristic_values
      IMPORTING it_characteristics TYPE ty_t_atnam
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS retrieve_phrase_values
      IMPORTING iv_technical_estcat TYPE eseestcat
                it_characteristics TYPE ty_t_atnam
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS normalize_allowed_values
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS collect_allowed_values
      IMPORTING iv_technical_estcat TYPE eseestcat
                it_characteristics TYPE ty_t_atnam
      CHANGING ct_allowed_values TYPE ty_t_allowed_value.

    METHODS retrieve_characteristics
      IMPORTING iv_technical_estcat TYPE eseestcat
                is_vatcust TYPE /plmb/s_spc_val_action_vatcust
      EXPORTING et_characteristics TYPE ty_t_atnam.

    METHODS find_metadata_target
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_target_node_name TYPE /plmb/spi_node_name
                it_table_meta_data TYPE ty_t_table_meta_data
                it_table_data TYPE /plmb/t_exp_table_data_export
      EXPORTING er_table_data TYPE REF TO data.

    METHODS retrieve_vat_customizing
      EXPORTING es_vatcust TYPE /plmb/s_spc_val_action_vatcust
                ev_failed TYPE /plmb/spi_failed_ind.

    METHODS prepare_additional_info_row
      EXPORTING er_metadata_line TYPE REF TO data
                ev_insert_index TYPE sy-tabix
                ev_is_new TYPE abap_bool
      CHANGING ct_data TYPE STANDARD TABLE.

    METHODS populate_additional_info
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_esttype TYPE eseesttype
                is_vatcust TYPE /plmb/s_spc_val_action_vatcust
                it_allowed_values TYPE ty_t_allowed_value
      CHANGING cs_metadata_line TYPE any.

    METHODS insert_metadata_row
      IMPORTING iv_is_new TYPE abap_bool
                iv_insert_index TYPE sy-tabix
                is_metadata_line TYPE any
      CHANGING ct_data TYPE STANDARD TABLE.

    METHODS ensure_show_all_groups
      CHANGING ct_add_info TYPE /plmb/t_exp_additional_info.

    METHODS append_supplier_group_defs
      CHANGING ct_table_definition TYPE /plmb/t_exp_table_definition.

    METHODS append_supplier_group_rows
      IMPORTING it_objects          TYPE /plmb/t_gos_internal_key
                it_table_data       TYPE /plmb/t_exp_table_data_export
                iv_technical_estcat TYPE eseestcat
                iv_esttype          TYPE eseesttype
                iv_specid           TYPE string
                iv_description      TYPE string
                iv_recn_group       TYPE char30
      CHANGING  ct_table_data       TYPE /plmb/t_exp_table_data_export.

    METHODS remove_first_sheet_group_rows
      CHANGING ct_table_data TYPE /plmb/t_exp_table_data_export.

    METHODS fetch_supplier_group_rows
      IMPORTING it_objects          TYPE /plmb/t_gos_internal_key
                it_table_data       TYPE /plmb/t_exp_table_data_export
                iv_technical_estcat TYPE eseestcat
                iv_esttype          TYPE eseesttype
                iv_specid           TYPE string
                iv_description      TYPE string
                iv_recn_group       TYPE char30
      CHANGING  ct_rows             TYPE ty_t_group_export_row.

    METHODS collect_export_valuation_ids
      IMPORTING it_table_data TYPE /plmb/t_exp_table_data_export
                iv_technical_estcat TYPE eseestcat
      CHANGING ct_val_ids TYPE /plmb/t_spc_val_id_sp.

    METHODS retrieve_valuation_ids
      IMPORTING it_objects TYPE /plmb/t_gos_internal_key
                iv_technical_estcat TYPE eseestcat
                io_connector_spc TYPE REF TO /plmb/if_spi_appl_access
                io_metadata_spc TYPE REF TO /plmb/if_spi_metadata_output
                it_group_cfg TYPE STANDARD TABLE
                iv_from_groups TYPE abap_bool
      CHANGING ct_val_ids TYPE /plmb/t_spc_val_id_sp
               co_val_table_type TYPE REF TO cl_abap_tabledescr.

    METHODS retrieve_group_configuration
      IMPORTING io_connector_rsp TYPE REF TO /plmb/if_spi_appl_access
                iv_technical_estcat TYPE eseestcat
      EXPORTING es_cfg TYPE /plmb/s_spc_qua_cfg_sp
                ev_failed TYPE /plmb/spi_failed_ind
      CHANGING ct_group_cfg TYPE STANDARD TABLE.

    METHODS retrieve_group_members
      IMPORTING io_connector_rsp TYPE REF TO /plmb/if_spi_appl_access
                iv_technical_estcat TYPE eseestcat
                iv_recn_group TYPE char30
                it_group_cfg TYPE STANDARD TABLE
                is_cfg TYPE /plmb/s_spc_qua_cfg_sp
                it_val_ids TYPE /plmb/t_spc_val_id_sp
                iv_group_node TYPE /plmb/spi_node_name
                iv_group_list_action TYPE /plmb/spi_action_name
                iv_group_action TYPE /plmb/spi_action_name
      CHANGING ct_qual_rows TYPE STANDARD TABLE
               ct_qual_rows_tmp TYPE STANDARD TABLE.

    METHODS append_member_export_rows
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_esttype TYPE eseesttype
                iv_description TYPE string
                iv_recn_group TYPE char30
                it_group_cfg TYPE STANDARD TABLE
                it_qual_rows TYPE STANDARD TABLE
      CHANGING ct_rows TYPE ty_t_group_export_row.

    METHODS append_qualification_rows
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_esttype TYPE eseesttype
                iv_description TYPE string
                iv_specid TYPE string
                it_qual_rows TYPE STANDARD TABLE
      CHANGING ct_rows TYPE ty_t_group_export_row.

    METHODS append_group_metadata
      IMPORTING iv_technical_estcat TYPE eseestcat
                iv_esttype          TYPE eseesttype
                iv_description      TYPE string
      CHANGING  ct_rows             TYPE ty_t_group_export_row.

    METHODS default_export_defaults
      CHANGING ct_rows TYPE ty_t_group_export_row.

    METHODS get_add_info_value
      IMPORTING it_add_info     TYPE /plmb/t_exp_additional_info
                iv_fname        TYPE fieldname
      RETURNING VALUE(rv_value) TYPE char30.

    METHODS get_component_string
      IMPORTING is_data         TYPE any
                iv_component    TYPE string
      RETURNING VALUE(rv_value) TYPE string.

    METHODS has_first_sheet_hidden_vat
      IMPORTING is_data         TYPE any
      RETURNING VALUE(rv_value) TYPE abap_bool.

    METHODS deserialize_selection_xml
      IMPORTING iv_selection TYPE string
      EXPORTING et_selection TYPE /plmb/t_spc_exp_ptree_select.
ENDCLASS.


CLASS zcl_spc_exp_gen_data_spplr2 IMPLEMENTATION.
  METHOD /plmb/if_exp_generic_data~get_definition.
    DATA lt_add_info TYPE /plmb/t_exp_additional_info.

    lt_add_info = it_add_info.
    ensure_show_all_groups( CHANGING ct_add_info = lt_add_info ).

    super->/plmb/if_exp_generic_data~get_definition( EXPORTING it_objects             = it_objects
                                                               iv_variant_id          = iv_variant_id
                                                               iv_selection           = iv_selection
                                                               it_add_info            = lt_add_info
                                                     IMPORTING et_table_definition    = et_table_definition
                                                               et_table_definition_ui = et_table_definition_ui
                                                     CHANGING  ct_message             = ct_message
                                                               cv_severity            = cv_severity ).

    " ZSPPLR_DEBUG_20260814_001: keep base definition metadata; the XSL hides group rows from the Data sheet.

    append_supplier_group_defs( CHANGING ct_table_definition = et_table_definition ).
  ENDMETHOD.

  METHOD /plmb/if_exp_generic_data~get_export_data.
    DATA lt_add_info           TYPE /plmb/t_exp_additional_info.
    DATA lt_base_data          TYPE /plmb/t_exp_table_data_export.
    DATA lt_table_definition   TYPE /plmb/t_exp_table_definition.
    DATA lt_definition         TYPE /plmb/t_exp_table_definition.
    DATA lt_selection          TYPE /plmb/t_spc_exp_ptree_select.
    DATA lt_def_message        TYPE /plmb/t_spi_msg.
    DATA lv_nutrient_grp       TYPE char30.
    DATA lv_allerg_grp         TYPE char30.
    DATA lv_diet_group         TYPE char30.
    DATA lv_relig_group        TYPE char30.
    DATA lv_genmod_grp         TYPE char30.
    DATA lv_def_severity       TYPE /plmb/spi_msg_severity.
    DATA lv_property_tree_text TYPE string.
    DATA lv_instance_field     TYPE string.
    DATA lo_table_type         TYPE REF TO cl_abap_tabledescr.
    DATA lr_table_data         TYPE REF TO data.
    DATA lr_base_rows          TYPE REF TO data.

    FIELD-SYMBOLS <ls_definition> TYPE /plmb/s_exp_table_definition.
    FIELD-SYMBOLS <ls_table_data> TYPE /plmb/s_exp_table_data_export.
    FIELD-SYMBOLS <lt_table_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_base_rows>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_xstring>    TYPE /plmb/t_exp_xstring.
    FIELD-SYMBOLS <ls_xstring>    TYPE /plmb/s_exp_xstring.
    FIELD-SYMBOLS <ls_selection>  TYPE /plmb/s_spc_exp_ptree_select.

    lt_add_info = it_add_info.
    ensure_show_all_groups( CHANGING ct_add_info = lt_add_info ).
    mv_nutrient_key_date = get_add_info_value(
      it_add_info = lt_add_info
      iv_fname = /plmi/if_spc_exp_c=>gc_additional_info-key_date ).
    IF mv_nutrient_key_date IS INITIAL.
      mv_nutrient_key_date = sy-datum.
    ENDIF.
    lv_nutrient_grp = get_add_info_value( it_add_info = lt_add_info
                                          iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-nutrient ).
    lv_allerg_grp = get_add_info_value( it_add_info = lt_add_info
                                        iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-allergen ).
    lv_diet_group = get_add_info_value( it_add_info = lt_add_info
                                        iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-diet ).
    lv_relig_group = get_add_info_value( it_add_info = lt_add_info
                                         iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-religious ).
    lv_genmod_grp = get_add_info_value( it_add_info = lt_add_info
                                        iv_fname    = /plmi/if_spc_exp_c=>gc_additional_info-gen_mod ).

    me->/plmb/if_exp_generic_data~get_definition( EXPORTING it_objects          = it_objects
                                                            iv_variant_id       = iv_variant_id
                                                            iv_selection        = iv_selection
                                                            it_add_info         = lt_add_info
                                                  IMPORTING et_table_definition = lt_table_definition
                                                  CHANGING  ct_message          = lt_def_message
                                                            cv_severity         = lv_def_severity ).

    super->/plmb/if_exp_generic_data~get_export_data( EXPORTING it_objects    = it_objects
                                                                iv_variant_id = iv_variant_id
                                                                iv_selection  = iv_selection
                                                                it_add_info   = lt_add_info
                                                      IMPORTING et_table_data = et_table_data
                                                      CHANGING  ct_message    = ct_message
                                                                cv_severity   = cv_severity ).

    deserialize_selection_xml( EXPORTING iv_selection = iv_selection
                               IMPORTING et_selection = lt_selection ).
    ASSIGN lt_selection[ 1 ] TO <ls_selection>.
    IF sy-subrc = 0.
      lv_property_tree_text = <ls_selection>-property_tree.
    ENDIF.

    retrieve_folder_nodes( it_objects = it_objects it_selection = lt_selection ).

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
           WHERE     table_no    = <ls_table_data>-table_no
                 AND new_page    = abap_false
                 AND table_text IS INITIAL.
        IF <ls_definition>-fieldname = /plmb/if_exp_c=>gc_component_key-engine_parent_line_no.
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
             WHERE     table_no    = <ls_table_data>-table_no
                   AND new_page    = abap_false
                   AND table_text IS INITIAL.
          APPEND <ls_definition> TO lt_definition.
        ENDLOOP.
        IF lt_definition IS INITIAL.
          CONTINUE.
        ENDIF.

        CLEAR lo_table_type.
        /plmb/cl_exp_tools=>create_struct_and_table_type( EXPORTING it_definition = lt_definition
                                                          IMPORTING eo_table_type = lo_table_type ).
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

          update_export_rows(
            EXPORTING iv_instance_field = lv_instance_field
                      iv_property_tree_text = lv_property_tree_text
            CHANGING ct_rows = <lt_table_data> ).

          EXPORT xstring = <lt_table_data>
                 TO DATA BUFFER <ls_xstring>-xstring
                 COMPRESSION OFF.
        ENDLOOP.
        CONTINUE.
      ENDIF.

      update_export_rows(
        EXPORTING iv_instance_field = lv_instance_field
                  iv_property_tree_text = lv_property_tree_text
        CHANGING ct_rows = <lt_table_data> ).
    ENDLOOP.

    lt_base_data = et_table_data.
    " Keep independent, decoded rows for supplier-group valuation ID lookup.
    LOOP AT lt_base_data ASSIGNING <ls_table_data>.
      IF <ls_table_data>-table_data IS NOT BOUND.
        CONTINUE.
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
          EXPORTING it_definition = lt_definition
          IMPORTING eo_table_type = lo_table_type ).
        IF lo_table_type IS NOT BOUND.
          CONTINUE.
        ENDIF.
        CREATE DATA lr_base_rows TYPE HANDLE lo_table_type.
        ASSIGN lr_base_rows->* TO <lt_base_rows>.
        CREATE DATA lr_table_data TYPE HANDLE lo_table_type.
        ASSIGN lr_table_data->* TO <lt_table_data>.
        LOOP AT <lt_xstring> ASSIGNING <ls_xstring>.
          CLEAR <lt_table_data>.
          IMPORT xstring = <lt_table_data>
                 FROM DATA BUFFER <ls_xstring>-xstring.
          APPEND LINES OF <lt_table_data> TO <lt_base_rows>.
        ENDLOOP.
      ELSE.
        ASSIGN <ls_table_data>-table_data->* TO <lt_table_data>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        CREATE DATA lr_base_rows LIKE <lt_table_data>.
        ASSIGN lr_base_rows->* TO <lt_base_rows>.
        <lt_base_rows> = <lt_table_data>.
      ENDIF.
      <ls_table_data>-table_data = lr_base_rows.
    ENDLOOP.
    remove_first_sheet_group_rows( CHANGING ct_table_data = et_table_data ).

    append_supplier_group_rows( EXPORTING it_objects          = it_objects
                                          it_table_data       = lt_base_data
                                          iv_technical_estcat = 'SAP_RMS_1012_005'
                                          iv_esttype          = 'RMS_D'
                                          iv_specid           = ''
                                          iv_description      = 'Nutrient Composition'
                                          iv_recn_group       = lv_nutrient_grp
                                CHANGING  ct_table_data       = et_table_data ).
    append_supplier_group_rows( EXPORTING it_objects          = it_objects
                                          it_table_data       = lt_base_data
                                          iv_technical_estcat = 'SAP_RMS_1012_021'
                                          iv_esttype          = 'RMS_D'
                                          iv_specid           = ''
                                          iv_description      = 'Allergens'
                                          iv_recn_group       = lv_allerg_grp
                                CHANGING  ct_table_data       = et_table_data ).
    append_supplier_group_rows( EXPORTING it_objects          = it_objects
                                          it_table_data       = lt_base_data
                                          iv_technical_estcat = 'SAP_RMS_1012_010'
                                          iv_esttype          = 'RMS_D'
                                          iv_specid           = ''
                                          iv_description      = 'Diet Suitability'
                                          iv_recn_group       = lv_diet_group
                                CHANGING  ct_table_data       = et_table_data ).
    append_supplier_group_rows( EXPORTING it_objects          = it_objects
                                          it_table_data       = lt_base_data
                                          iv_technical_estcat = 'SAP_RMS_1012_022'
                                          iv_esttype          = 'B'
                                          iv_specid           = ''
                                          iv_description      = 'Religious Certificate Compliance'
                                          iv_recn_group       = lv_relig_group
                                CHANGING  ct_table_data       = et_table_data ).
    append_supplier_group_rows( EXPORTING it_objects          = it_objects
                                          it_table_data       = lt_base_data
                                          iv_technical_estcat = 'SAP_RMS_1012_025'
                                          iv_esttype          = 'RMS_D'
                                          iv_specid           = ''
                                          iv_description      = 'Genetically Modified Ingredients'
                                          iv_recn_group       = lv_genmod_grp
                                CHANGING  ct_table_data       = et_table_data ).
  ENDMETHOD.

  METHOD ensure_show_all_groups.
    DATA lt_fields   TYPE STANDARD TABLE OF fieldname.
    DATA lv_field    TYPE fieldname.
    DATA lr_show_all TYPE REF TO data.
    DATA lv_show_all TYPE char30.
    DATA ls_add_info TYPE /plmb/s_exp_additional_info.

    FIELD-SYMBOLS <ls_add_info> TYPE /plmb/s_exp_additional_info.
    FIELD-SYMBOLS <lv_value>    TYPE any.

    APPEND /plmi/if_spc_exp_c=>gc_additional_info-nutrient  TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-diet      TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-allergen  TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-religious TO lt_fields.
    APPEND /plmi/if_spc_exp_c=>gc_additional_info-gen_mod   TO lt_fields.

    LOOP AT lt_fields INTO lv_field.
      UNASSIGN: <ls_add_info>,
                <lv_value>.
      ASSIGN ct_add_info[ fname = lv_field ] TO <ls_add_info>.

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
    DATA ls_table_data TYPE /plmb/s_exp_table_data_export.
    DATA lv_index      TYPE sy-tabix.

    FIELD-SYMBOLS <lt_export_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_export_row>  TYPE any.

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
        ASSIGN <lt_export_rows>[ lv_index ] TO <ls_export_row>.
        IF sy-subrc <> 0.
          lv_index -= 1.
          CONTINUE.
        ENDIF.

        IF me->has_first_sheet_hidden_vat( is_data = <ls_export_row> ) = abap_true.
          DELETE <lt_export_rows> INDEX lv_index.
        ENDIF.

        lv_index -= 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD append_supplier_group_defs.
    DATA lv_table_no TYPE int4.
    DATA ls_def      TYPE /plmb/s_exp_table_definition.
    DATA lt_fields   TYPE /plmb/t_exp_table_definition.

    FIELD-SYMBOLS <ls_existing_def> TYPE /plmb/s_exp_table_definition.

    " Keep the field order aligned with the intermediate export layout.
    lt_fields = VALUE #(
      ( fieldname = 'ESTCAT'         fieldtext = 'Value Assignment Type' fieldtype_name = 'ESEESTCAT' )
      ( fieldname = 'ESTCAT_DESC'    fieldtext = 'Value Assignment Type Description' )
      ( fieldname = 'ESTTYPE'        fieldtext = 'Value Assignment Category' fieldtype_name = 'ESEESTTYPE' )
      ( fieldname = 'NODE_NAME'      fieldtext = 'Node Name' fieldtype_name = '/PLMB/SPI_NODE_NAME' )
      ( fieldname = 'NODE_DESC'      fieldtext = 'Node Description' )
      ( fieldname = 'DATATYPE'       fieldtext = 'Data Type' )
      ( fieldname = 'LINE_NO'        fieldtext = 'Line No.' )
      ( fieldname = 'SPECID'         fieldtext = 'Specification' )
      ( fieldname = 'INSTANCE'       fieldtext = 'Instance' )
      ( fieldname = 'SORT_SEQ'       fieldtext = 'Sort Sequence' )
      ( fieldname = 'USAGE'          fieldtext = 'Usage' )
      ( fieldname = 'REF_QTY'        fieldtext = 'Reference Quantity' )
      ( fieldname = 'RECN'           fieldtext = 'Record Number' )
      ( fieldname = 'ACTN'           fieldtext = 'Change Number' )
      ( fieldname = 'RECNROOT'       fieldtext = 'Root Record' )
      ( fieldname = 'RECNPARENT'     fieldtext = 'Parent Record' )
      ( fieldname = 'ESTCAT_VALUE'   fieldtext = 'Value Assignment Type' fieldtype_name = 'ESEESTCAT' )
      ( fieldname = 'RECN_VP'        fieldtext = 'Value Record' )
      ( fieldname = 'ACTN_VP'        fieldtext = 'Value Change Number' )
      ( fieldname = 'SUBID'          fieldtext = 'Specification' )
      ( fieldname = 'GRP_SUBID'      fieldtext = 'Group' )
      ( fieldname = 'IDENT1'         fieldtext = 'Identifier' )
      ( fieldname = 'IDENT1_DESC'    fieldtext = 'Identifier Description' )
      ( fieldname = 'COMPEXP_STEXT'  fieldtext = 'UoM' )
    ).

    LOOP AT ct_table_definition ASSIGNING <ls_existing_def>.
      IF <ls_existing_def>-table_no > lv_table_no.
        lv_table_no = <ls_existing_def>-table_no.
      ENDIF.
    ENDLOOP.

    DO 5 TIMES.
      lv_table_no += 1.

      CLEAR ls_def.
      ls_def-table_no    = lv_table_no.
      ls_def-nodedisplay = abap_true.
      ls_def-table_text  = 'Supplier Group'.
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

      LOOP AT lt_fields INTO ls_def.
        IF ls_def-fieldtype_name IS INITIAL.
          ls_def-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
        ENDIF.
        ls_def-table_no    = lv_table_no.
        ls_def-nodedisplay = abap_true.
        ls_def-rowkey      = abap_true.
        APPEND ls_def TO ct_table_definition.
      ENDLOOP.
    ENDDO.
  ENDMETHOD.

  METHOD append_supplier_group_rows.
    DATA lt_rows     TYPE ty_t_group_export_row.
    DATA lr_rows     TYPE REF TO data.
    DATA lv_table_no TYPE int4.

    FIELD-SYMBOLS <lt_rows> TYPE ty_t_group_export_row.

    fetch_supplier_group_rows( EXPORTING it_objects          = it_objects
                                         it_table_data       = it_table_data
                                         iv_technical_estcat = iv_technical_estcat
                                         iv_esttype          = iv_esttype
                                         iv_specid           = iv_specid
                                         iv_description      = iv_description
                                         iv_recn_group       = iv_recn_group
                               CHANGING  ct_rows             = lt_rows ).

    IF lt_rows IS INITIAL.
      append_group_metadata( EXPORTING iv_technical_estcat = iv_technical_estcat
                                     iv_esttype          = iv_esttype
                                     iv_description      = iv_description
                           CHANGING  ct_rows             = lt_rows ).
    ENDIF.

    default_export_defaults( CHANGING ct_rows = lt_rows ).

    CREATE DATA lr_rows LIKE lt_rows.
    ASSIGN lr_rows->* TO <lt_rows>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    <lt_rows> = lt_rows.
    lv_table_no = lines( ct_table_data ) + 1.

    convert_and_append_data( EXPORTING iv_table_no   = lv_table_no
                                       ir_out_data   = lr_rows
                             CHANGING  ct_table_data = ct_table_data ).
  ENDMETHOD.

  METHOD append_group_metadata.
    DATA lt_metadata TYPE ty_t_group_export_row.

    lt_metadata = VALUE #(
      engine_key_col = 1
      estcat         = iv_technical_estcat
      estcat_desc    = iv_description
      esttype        = iv_esttype
      node_name      = 'ZSUPPLIER_GROUP'
      node_desc      = 'Supplier Group'
      datatype       = /plmb/if_exp_c=>gc_data_type-metadata
      ( engine_key_row = 1
        line_no        = 1
        specid         = 'META_SPEC_ID'
        instance       = 'META_INSTANCE'
        sort_seq       = 'META_SORT'
        usage          = 'META_USAGE'
        ref_qty        = 'ADDITIONAL_FIELD_REF_QTY_UI'
        recn           = 'RECN'
        actn           = 'ACTN'
        recnroot       = 'RECNROOT'
        recnparent     = 'RECNPARENT'
        estcat_value   = 'ESTCAT'
        recn_vp        = 'RECN_VP'
        actn_vp        = 'ACTN_VP'
        subid          = 'SUBID'
        grp_subid      = 'GRP_SUBID'
        ident1         = 'IDENT1'
        ident1_desc    = 'IDENT1_DESC'
        compexp_stext  = 'COMPEXP_STEXT' )
      ( engine_key_row = 2
        line_no        = 2
        specid         = 'Specification'
        instance       = 'Instance'
        sort_seq       = 'Sort Sequence (Instance)'
        usage          = 'Usage'
        ref_qty        = 'Reference Quantity'
        subid          = 'Specification'
        grp_subid      = 'Group'
        ident1         = 'Identifier'
        ident1_desc    = 'Identifier Description'
        compexp_stext  = 'UoM' )
      ( engine_key_row = 3
        line_no        = 3
        specid         = 'BF'
        instance       = 'TF'
        sort_seq       = 'TF'
        usage          = 'BF'
        ref_qty        = 'BF'
        subid          = 'BF'
        grp_subid      = 'BF'
        ident1         = 'BF'
        ident1_desc    = 'BF'
        compexp_stext  = 'BF' )
      ( engine_key_row = 4
        line_no        = 4
        specid         = 'S'
        instance       = 'I'
        sort_seq       = 'I'
        usage          = 'S'
        ref_qty        = 'S'
        subid          = 'S'
        grp_subid      = 'S'
        ident1         = 'S'
        ident1_desc    = 'S'
        compexp_stext  = 'S' )
    ).
    APPEND LINES OF lt_metadata TO ct_rows.
  ENDMETHOD.

  METHOD default_export_defaults.
    DATA lt_metadata TYPE ty_t_group_export_row.
    TYPES: BEGIN OF ty_s_sorted_row,
             sort_order TYPE i,
             row        TYPE ty_s_group_export_row,
           END OF ty_s_sorted_row.
    DATA lt_data TYPE STANDARD TABLE OF ty_s_sorted_row.
    DATA ls_data TYPE ty_s_sorted_row.
    DATA lt_seen     TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA lv_index    TYPE sy-tabix.
    DATA lv_line_no  TYPE i.
    DATA lv_key      TYPE string.
    DATA ls_row      TYPE ty_s_group_export_row.

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
      ASSIGN ct_rows[ lv_index ] TO <ls_row>.
      IF sy-subrc <> 0.
        lv_index += 1.
        CONTINUE.
      ENDIF.

      IF <ls_row>-datatype <> /plmb/if_exp_c=>gc_data_type-tabledata.
        lv_index += 1.
        CONTINUE.
      ENDIF.

      " Nutrients are deduplicated in their SAP listing/valuation context.
      IF <ls_row>-estcat = 'SAP_RMS_1012_005'.
        lv_index += 1.
        CONTINUE.
      ENDIF.

      lv_key = |{ <ls_row>-estcat_value }\|| &&
               |{ <ls_row>-subid }\|| &&
               <ls_row>-ident1.

      IF line_exists( lt_seen[ table_line = lv_key ] ).
        DELETE ct_rows INDEX lv_index.
        CONTINUE.
      ENDIF.

      INSERT lv_key INTO TABLE lt_seen.
      lv_index += 1.
    ENDWHILE.

    LOOP AT ct_rows INTO ls_row.
      IF ls_row-datatype <> /plmb/if_exp_c=>gc_data_type-tabledata.
        APPEND ls_row TO lt_metadata.
      ELSE.
        CLEAR ls_data.
        ls_data-row = ls_row.
        IF ls_row-node_name = 'ZSUPPLIER_GROUP'.
          " Connector rows already arrive in display order; retain their ORD as metadata.
          ls_data-sort_order = lines( lt_data ) + 1.
        ELSE.
          ls_data-sort_order = ls_row-sort_seq.
        ENDIF.
        APPEND ls_data TO lt_data.
      ENDIF.
    ENDLOOP.

    SORT lt_data STABLE BY row-estcat_desc sort_order.

    CLEAR ct_rows.
    APPEND LINES OF lt_metadata TO ct_rows.

    CLEAR lv_line_no.
    LOOP AT lt_data INTO ls_data.
      ls_row = ls_data-row.
      lv_index = lines( ct_rows ) + 1.
      lv_line_no += 1.
      ls_row-engine_key_row = lv_index.
      ls_row-line_no        = |{ lv_line_no NUMBER = RAW }|.
      APPEND ls_row TO ct_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD fetch_supplier_group_rows.
    DATA lo_connector_rsp TYPE REF TO /plmb/if_spi_appl_access.
    DATA lo_connector_spc TYPE REF TO /plmb/if_spi_appl_access.
    DATA lo_metadata_rsp TYPE REF TO /plmb/if_spi_metadata_output.
    DATA lo_metadata_spc TYPE REF TO /plmb/if_spi_metadata_output.
    DATA lo_table_type TYPE REF TO cl_abap_tabledescr.
    DATA lo_cfg_table_type TYPE REF TO cl_abap_tabledescr.
    DATA lo_id_table_type TYPE REF TO cl_abap_tabledescr.
    DATA lo_val_table_type TYPE REF TO cl_abap_tabledescr.
    DATA lr_qual_rows TYPE REF TO data.
    DATA lr_qual_rows_tmp TYPE REF TO data.
    DATA lr_qual_ids TYPE REF TO data.
    DATA lr_group_cfg TYPE REF TO data.
    DATA ls_cfg TYPE /plmb/s_spc_qua_cfg_sp.
    DATA lt_val_ids TYPE /plmb/t_spc_val_id_sp.
    DATA lv_failed TYPE /plmb/spi_failed_ind.
    DATA lv_group_node TYPE /plmb/spi_node_name.
    DATA lv_group_list_action TYPE /plmb/spi_action_name.
    DATA lv_group_action TYPE /plmb/spi_action_name.
    FIELD-SYMBOLS <lt_qual_ids> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_qual_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_qual_rows_tmp> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_group_cfg> TYPE STANDARD TABLE.

    " Nutrients use the quantitative node, including its unit fields.
    IF iv_technical_estcat = 'SAP_RMS_1012_005'.
      lv_group_node        = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
      lv_group_list_action = /plmb/if_spc_attr=>gc_actions_qua-quant_list.
      lv_group_action      = /plmb/if_spc_attr=>gc_actions_qua-quant_grp.
    ELSE.
      lv_group_node        = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
      lv_group_list_action = /plmb/if_spc_attr=>gc_actions_qua-qual_list.
      lv_group_action      = /plmb/if_spc_attr=>gc_actions_qua-qual_grp.
    ENDIF.

    /plmb/cl_spi_connector=>create_instance( EXPORTING iv_abbid     = /plmb/if_spc_attr=>gc_abbid_rsp_spc
                                             IMPORTING eo_connector = lo_connector_rsp
                                                       eo_metadata  = lo_metadata_rsp ).

    /plmb/cl_spi_connector=>create_instance( EXPORTING iv_abbid     = /plmb/if_abbid_c=>gc_spc
                                             IMPORTING eo_connector = lo_connector_spc
                                                       eo_metadata  = lo_metadata_spc ).

    IF lo_connector_rsp IS NOT BOUND OR lo_metadata_rsp IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_metadata_rsp->get_node_details( EXPORTING iv_node_name            = lv_group_node
                                       IMPORTING eo_node_id_table_rtti   = lo_id_table_type
                                                 eo_node_data_table_rtti = lo_table_type ).

    lo_metadata_rsp->get_node_details( EXPORTING iv_node_name            = /plmb/if_spc_attr=>gc_node_rsp_config
                                       IMPORTING eo_node_data_table_rtti = lo_cfg_table_type ).

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
    IF    <lt_qual_ids>      IS NOT ASSIGNED OR <lt_qual_rows> IS NOT ASSIGNED
       OR <lt_qual_rows_tmp> IS NOT ASSIGNED OR <lt_group_cfg> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    collect_export_valuation_ids(
      EXPORTING it_table_data = it_table_data
                iv_technical_estcat = iv_technical_estcat
      CHANGING ct_val_ids = lt_val_ids ).

    retrieve_valuation_ids(
      EXPORTING it_objects = it_objects
                iv_technical_estcat = iv_technical_estcat
                io_connector_spc = lo_connector_spc
                io_metadata_spc = lo_metadata_spc
                it_group_cfg = <lt_group_cfg>
                iv_from_groups = abap_false
      CHANGING ct_val_ids = lt_val_ids
               co_val_table_type = lo_val_table_type ).

    retrieve_group_configuration(
      EXPORTING io_connector_rsp = lo_connector_rsp
                iv_technical_estcat = iv_technical_estcat
      IMPORTING es_cfg = ls_cfg
                ev_failed = lv_failed
      CHANGING ct_group_cfg = <lt_group_cfg> ).

    IF lv_failed = abap_true.
      RETURN.
    ENDIF.

    retrieve_valuation_ids(
      EXPORTING it_objects = it_objects
                iv_technical_estcat = iv_technical_estcat
                io_connector_spc = lo_connector_spc
                io_metadata_spc = lo_metadata_spc
                it_group_cfg = <lt_group_cfg>
                iv_from_groups = abap_true
      CHANGING ct_val_ids = lt_val_ids
               co_val_table_type = lo_val_table_type ).

    retrieve_group_members(
      EXPORTING io_connector_rsp = lo_connector_rsp
                iv_technical_estcat = iv_technical_estcat
                iv_recn_group = iv_recn_group
                it_group_cfg = <lt_group_cfg>
                is_cfg = ls_cfg
                it_val_ids = lt_val_ids
                iv_group_node = lv_group_node
                iv_group_list_action = lv_group_list_action
                iv_group_action = lv_group_action
      CHANGING ct_qual_rows = <lt_qual_rows>
               ct_qual_rows_tmp = <lt_qual_rows_tmp> ).

    append_group_metadata( EXPORTING iv_technical_estcat = iv_technical_estcat
                                     iv_esttype          = iv_esttype
                                     iv_description      = iv_description
                           CHANGING  ct_rows             = ct_rows ).

    append_member_export_rows(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                iv_esttype = iv_esttype
                iv_description = iv_description
                iv_recn_group = iv_recn_group
                it_group_cfg = <lt_group_cfg>
                it_qual_rows = <lt_qual_rows>
      CHANGING ct_rows = ct_rows ).

    append_qualification_rows(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                iv_esttype = iv_esttype
                iv_description = iv_description
                iv_specid = iv_specid
                it_qual_rows = <lt_qual_rows>
      CHANGING ct_rows = ct_rows ).
  ENDMETHOD.

  METHOD collect_export_valuation_ids.
    DATA ls_val_id TYPE /plmb/s_spc_val_id_sp.
    DATA ls_table_data TYPE /plmb/s_exp_table_data_export.
    DATA lv_row_vat TYPE string.
    DATA lv_row_node TYPE string.
    FIELD-SYMBOLS <lt_export_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_export_row> TYPE any.

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

        lv_row_vat = get_component_string( is_data      = <ls_export_row>
                                           iv_component = /plmb/if_exp_c=>gc_component_key-engine_v_a_type ).
        IF me->get_component_string( is_data      = <ls_export_row>
                                     iv_component = /plmb/if_exp_c=>gc_component_key-engine_datatype )
           = /plmb/if_exp_c=>gc_data_type-metadata.
          CONTINUE.
        ENDIF.
        IF lv_row_vat <> iv_technical_estcat.
          CONTINUE.
        ENDIF.
        lv_row_node = get_component_string( is_data      = <ls_export_row>
                                            iv_component = /plmb/if_exp_c=>gc_component_key-engine_node_name ).
        IF lv_row_node IS NOT INITIAL AND lv_row_node <> 'INSTANCES'.
          CONTINUE.
        ENDIF.

        CLEAR ls_val_id.
        ls_val_id-recn       = get_component_string( is_data      = <ls_export_row>
                                                     iv_component = 'RECN' ).
        ls_val_id-actn       = get_component_string( is_data      = <ls_export_row>
                                                     iv_component = 'ACTN' ).
        ls_val_id-recnroot   = get_component_string( is_data      = <ls_export_row>
                                                     iv_component = 'RECNROOT' ).
        ls_val_id-recnparent = get_component_string( is_data      = <ls_export_row>
                                                     iv_component = 'RECNPARENT' ).
        ls_val_id-estcat     = get_component_string( is_data      = <ls_export_row>
                                                     iv_component = 'ESTCAT' ).
        IF ls_val_id-estcat IS INITIAL.
          ls_val_id-estcat = iv_technical_estcat.
        ENDIF.
        ls_val_id-recn_vp = get_component_string( is_data      = <ls_export_row>
                                                  iv_component = 'RECN_VP' ).
        ls_val_id-actn_vp = get_component_string( is_data      = <ls_export_row>
                                                  iv_component = 'ACTN_VP' ).

        IF ls_val_id-recn IS NOT INITIAL AND ls_val_id-estcat = iv_technical_estcat.
          APPEND ls_val_id TO ct_val_ids.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT ct_val_ids BY recn
                       actn
                       recnroot
                       recnparent
                       estcat
                       recn_vp
                       actn_vp.
    DELETE ADJACENT DUPLICATES FROM ct_val_ids COMPARING recn actn recnroot recnparent estcat recn_vp actn_vp.
  ENDMETHOD.

  METHOD retrieve_valuation_ids.
    DATA lr_val_rows TYPE REF TO data.
    DATA ls_param_estcat TYPE /plmb/s_spc_val_action_estcat.
    DATA ls_val_id TYPE /plmb/s_spc_val_id_sp.
    DATA lv_object TYPE /plmb/gos_internal_key.
    DATA lt_spc_id TYPE /plmb/t_spc_id_sp.
    DATA lt_spc_id_temp TYPE /plmb/t_spc_id_sp.
    DATA ls_spc_id TYPE /plmb/s_spc_id_sp.
    DATA lt_spc_data TYPE /plmb/t_spc_bas_header_sp.
    DATA lt_prop_tree TYPE /plmb/t_spc_bas_tree_sp.
    DATA lt_prop_tree_id TYPE /plmb/t_spc_bas_tree_id_sp.
    DATA ls_prop_tree_id TYPE /plmb/s_spc_bas_tree_id_sp.
    DATA lt_prop_node TYPE /plmb/t_spc_bas_node_sp.
    DATA lt_prop_node_id TYPE /plmb/t_spc_bas_node_id_sp.
    DATA ls_prop_node_id TYPE /plmb/s_spc_bas_node_id_sp.
    DATA lt_index_failed TYPE /plmb/t_spi_rtr_index_failed.
    DATA lv_group_recn TYPE char30.
    DATA lv_failed TYPE /plmb/spi_failed_ind.
    FIELD-SYMBOLS <lt_val_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_spc_group> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_prop_tree> TYPE /plmb/s_spc_bas_tree_sp.
    FIELD-SYMBOLS <ls_prop_node> TYPE /plmb/s_spc_bas_node_sp.
    FIELD-SYMBOLS <ls_group_cfg> TYPE any.
    FIELD-SYMBOLS <ls_spc_group> TYPE any.
    FIELD-SYMBOLS <ls_val_row> TYPE any.

    IF ct_val_ids IS NOT INITIAL OR io_connector_spc IS NOT BOUND
       OR io_metadata_spc IS NOT BOUND.
      RETURN.
    ENDIF.

    IF iv_from_groups = abap_true.
      LOOP AT it_group_cfg ASSIGNING <ls_group_cfg>.
        UNASSIGN <lt_spc_group>.
        ASSIGN COMPONENT 'SPC_GROUP' OF STRUCTURE <ls_group_cfg> TO <lt_spc_group>.
        IF sy-subrc <> 0 OR <lt_spc_group> IS NOT ASSIGNED OR <lt_spc_group> IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_spc_group> ASSIGNING <ls_spc_group>.
          lv_group_recn = get_component_string( is_data      = <ls_spc_group>
                                                iv_component = 'RECN' ).
          IF lv_group_recn IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR ls_spc_id.
          MOVE-CORRESPONDING <ls_spc_group> TO ls_spc_id.
          ls_spc_id-recn = lv_group_recn.
          IF ls_spc_id-actn IS INITIAL.
            ls_spc_id-actn = get_component_string( is_data      = <ls_spc_group>
                                                   iv_component = 'ACTN' ).
          ENDIF.
          APPEND ls_spc_id TO lt_spc_id.
        ENDLOOP.
      ENDLOOP.

      SORT lt_spc_id BY recn
                        actn.
      DELETE ADJACENT DUPLICATES FROM lt_spc_id COMPARING recn actn.

      IF lt_spc_id IS INITIAL.
        RETURN.
      ENDIF.
    ELSE.
      LOOP AT it_objects INTO lv_object.
        CLEAR ls_spc_id.
        /plmb/cl_gos_cnv_tools=>split_intern_to_key( EXPORTING iv_internal_key = lv_object
                                                     IMPORTING es_key          = ls_spc_id ).
        APPEND ls_spc_id TO lt_spc_id.
      ENDLOOP.

    ENDIF.

    ls_param_estcat-estcat      = iv_technical_estcat.
    ls_param_estcat-is_property = abap_true.
    io_connector_spc->action( EXPORTING iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation
                                        iv_action_name = /plmb/if_spc_attr=>gc_actions_val-change_structure_def
                                        is_param       = ls_param_estcat
                              IMPORTING ev_failed      = lv_failed ).

    IF lv_failed = abap_true.
      RETURN.
    ENDIF.

    " Object lookup refreshes RTTI; group fallback can reuse it.
    IF iv_from_groups <> abap_true OR co_val_table_type IS NOT BOUND.
      io_metadata_spc->get_node_details(
        EXPORTING iv_node_name = /plmb/if_spc_attr=>gc_node_valuation
        IMPORTING eo_node_data_table_rtti = co_val_table_type ).
    ENDIF.
    IF co_val_table_type IS NOT BOUND.
      RETURN.
    ENDIF.
    CREATE DATA lr_val_rows TYPE HANDLE co_val_table_type.
    ASSIGN lr_val_rows->* TO <lt_val_rows>.
    IF <lt_val_rows> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT lt_spc_id INTO ls_spc_id.
      CLEAR: lv_failed,
             lt_index_failed,
             lt_spc_id_temp,
             lt_spc_data,
             lt_prop_tree.
      APPEND ls_spc_id TO lt_spc_id_temp.

      io_connector_spc->retrieve( EXPORTING iv_node_name    = /plmb/if_spc_attr=>gc_node_basic_header
                                            it_node_id      = lt_spc_id_temp
                                  IMPORTING ev_failed       = lv_failed
                                            et_index_failed = lt_index_failed
                                            et_node_data    = lt_spc_data ).
      IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR: lv_failed,
             lt_index_failed.
      io_connector_spc->retrieve( EXPORTING iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header
                                            iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree_list
                                            it_node_id          = lt_spc_id_temp
                                  IMPORTING ev_failed           = lv_failed
                                            et_index_failed     = lt_index_failed
                                            et_node_data        = lt_prop_tree ).
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

        io_connector_spc->retrieve( EXPORTING iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree_list
                                              iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree
                                              iv_lock             = abap_false
                                              it_node_id          = lt_prop_tree_id
                                    IMPORTING ev_failed           = lv_failed
                                              et_index_failed     = lt_index_failed
                                              et_node_data        = lt_prop_node ).
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

          io_connector_spc->retrieve( EXPORTING iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree
                                                iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation
                                                it_node_id          = lt_prop_node_id
                                      IMPORTING ev_failed           = lv_failed
                                                et_index_failed     = lt_index_failed
                                                et_node_data        = <lt_val_rows> ).
          IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
            CONTINUE.
          ENDIF.

          LOOP AT <lt_val_rows> ASSIGNING <ls_val_row>.
            CLEAR ls_val_id.
            ls_val_id-recn       = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'RECN' ).
            ls_val_id-actn       = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'ACTN' ).
            ls_val_id-recnroot   = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'RECNROOT' ).
            ls_val_id-recnparent = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'RECNPARENT' ).
            ls_val_id-estcat     = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'ESTCAT' ).
            ls_val_id-recn_vp    = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'RECN_VP' ).
            ls_val_id-actn_vp    = get_component_string( is_data      = <ls_val_row>
                                                         iv_component = 'ACTN_VP' ).
            IF ls_val_id-recn IS NOT INITIAL AND ls_val_id-estcat = iv_technical_estcat.
              APPEND ls_val_id TO ct_val_ids.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    SORT ct_val_ids BY recn
                       actn
                       recnroot
                       recnparent
                       estcat
                       recn_vp
                       actn_vp.
    DELETE ADJACENT DUPLICATES FROM ct_val_ids COMPARING recn actn recnroot recnparent estcat recn_vp actn_vp.
  ENDMETHOD.

  METHOD retrieve_group_configuration.
    DATA ls_param TYPE /plmb/s_rsp_spc_actions.
    DATA lt_cfg TYPE STANDARD TABLE OF /plmb/s_spc_qua_cfg_sp.

    CLEAR ls_param.
    ls_param-estcat = iv_technical_estcat.
    io_connector_rsp->action( EXPORTING iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_config
                                        iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group
                                        is_param       = ls_param
                              IMPORTING ev_failed      = ev_failed
                                        et_node_data   = lt_cfg ).
    IF ev_failed = abap_true.
      RETURN.
    ENDIF.

    READ TABLE lt_cfg INTO es_cfg INDEX 1.
    IF sy-subrc = 0.
      ls_param-subcat_group = es_cfg-subcat_grp.
    ENDIF.

    io_connector_rsp->action( EXPORTING iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_config
                                        iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qua_spc_group_list
                                        is_param       = ls_param
                              IMPORTING ev_failed      = ev_failed
                                        et_node_data   = ct_group_cfg ).
    IF ev_failed = abap_true.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD retrieve_group_members.
    DATA ls_param TYPE /plmb/s_rsp_spc_actions.
    DATA lt_val_id_temp TYPE /plmb/t_spc_val_id_sp.
    DATA ls_val_id TYPE /plmb/s_spc_val_id_sp.
    DATA lt_recn_group TYPE STANDARD TABLE OF char30.
    DATA lv_recn_group TYPE char30.
    DATA lv_group_recn TYPE char30.
    DATA lv_failed TYPE /plmb/spi_failed_ind.
    FIELD-SYMBOLS <lt_spc_group> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_group_cfg> TYPE any.
    FIELD-SYMBOLS <ls_spc_group> TYPE any.

    IF iv_recn_group IS NOT INITIAL.
      APPEND iv_recn_group TO lt_recn_group.
    ELSE.
      APPEND /plmb/if_spc_attr=>gc_actions_qua-qua_show_all TO lt_recn_group.
    ENDIF.

    LOOP AT lt_recn_group INTO lv_recn_group.
      CLEAR ct_qual_rows.
      CLEAR ls_param.
      ls_param-estcat       = iv_technical_estcat.
      ls_param-subcat_group = is_cfg-subcat_grp.
      ls_param-recn_group   = lv_recn_group.
      io_connector_rsp->action( EXPORTING iv_node_name   = iv_group_node
                                          iv_action_name = iv_group_list_action
                                          is_param       = ls_param
                                IMPORTING ev_failed      = lv_failed ).
      IF lv_failed = abap_true.
        CONTINUE.
      ENDIF.

      io_connector_rsp->action( EXPORTING iv_node_name   = iv_group_node
                                          iv_action_name = iv_group_action
                                IMPORTING ev_failed      = lv_failed ).
      IF lv_failed = abap_true.
        CONTINUE.
      ENDIF.

      LOOP AT it_val_ids INTO ls_val_id.
        CLEAR: lt_val_id_temp,
               ct_qual_rows_tmp.
        APPEND ls_val_id TO lt_val_id_temp.

        io_connector_rsp->retrieve( EXPORTING iv_node_name        = /plmb/if_spc_attr=>gc_node_rsp_lead_object
                                              iv_target_node_name = iv_group_node
                                              it_node_id          = lt_val_id_temp
                                    IMPORTING ev_failed           = lv_failed
                                              et_node_data        = ct_qual_rows_tmp ).
        IF lv_failed = abap_true.
          CONTINUE.
        ENDIF.

        APPEND LINES OF ct_qual_rows_tmp TO ct_qual_rows.
      ENDLOOP.

      IF ct_qual_rows IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    " Keep successful results in the selected SAP view's returned order.

    IF     ct_qual_rows IS INITIAL
       AND it_group_cfg IS NOT INITIAL
       AND iv_recn_group  <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all.
      LOOP AT it_group_cfg ASSIGNING <ls_group_cfg>.
        UNASSIGN <lt_spc_group>.
        ASSIGN COMPONENT 'SPC_GROUP' OF STRUCTURE <ls_group_cfg> TO <lt_spc_group>.
        IF sy-subrc <> 0 OR <lt_spc_group> IS NOT ASSIGNED OR <lt_spc_group> IS INITIAL.
          CONTINUE.
        ENDIF.

        LOOP AT <lt_spc_group> ASSIGNING <ls_spc_group>.
          CLEAR: lv_group_recn,
                 ls_param,
                 lt_val_id_temp,
                 ct_qual_rows_tmp.

          lv_group_recn  = get_component_string( is_data      = <ls_spc_group>
                                                 iv_component = 'RECN' ).

          IF lv_group_recn IS INITIAL.
            CONTINUE.
          ENDIF.

          " Selection contains RECN or a show-mode constant, never SUBID/IDENT.
          IF     iv_recn_group  IS NOT INITIAL
             AND iv_recn_group  <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all
             AND iv_recn_group  <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained
             AND lv_group_recn  <> iv_recn_group.
            CONTINUE.
          ENDIF.

          ls_param-estcat       = iv_technical_estcat.
          ls_param-subcat_group = is_cfg-subcat_grp.
          ls_param-recn_group   = lv_group_recn.

          io_connector_rsp->action( EXPORTING iv_node_name   = iv_group_node
                                              iv_action_name = iv_group_list_action
                                              is_param       = ls_param
                                    IMPORTING ev_failed      = lv_failed ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          io_connector_rsp->action( EXPORTING iv_node_name   = iv_group_node
                                              iv_action_name = iv_group_action
                                    IMPORTING ev_failed      = lv_failed ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          CLEAR ls_val_id.
          ls_val_id-recn     = lv_group_recn.
          ls_val_id-actn     = get_component_string( is_data      = <ls_spc_group>
                                                     iv_component = 'ACTN' ).
          ls_val_id-recnroot = get_component_string( is_data      = <ls_spc_group>
                                                     iv_component = 'RECNROOT' ).
          IF ls_val_id-recnroot IS INITIAL.
            ls_val_id-recnroot = lv_group_recn.
          ENDIF.
          ls_val_id-recnparent = get_component_string( is_data      = <ls_spc_group>
                                                       iv_component = 'RECNPARENT' ).
          ls_val_id-estcat     = iv_technical_estcat.
          ls_val_id-recn_vp    = get_component_string( is_data      = <ls_spc_group>
                                                       iv_component = 'RECN_VP' ).
          ls_val_id-actn_vp    = get_component_string( is_data      = <ls_spc_group>
                                                       iv_component = 'ACTN_VP' ).
          APPEND ls_val_id TO lt_val_id_temp.

          io_connector_rsp->retrieve( EXPORTING iv_node_name        = /plmb/if_spc_attr=>gc_node_rsp_lead_object
                                                iv_target_node_name = iv_group_node
                                                it_node_id          = lt_val_id_temp
                                      IMPORTING ev_failed           = lv_failed
                                                et_node_data        = ct_qual_rows_tmp ).
          IF lv_failed = abap_true.
            CONTINUE.
          ENDIF.

          APPEND LINES OF ct_qual_rows_tmp TO ct_qual_rows.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD append_member_export_rows.
    DATA ls_row TYPE ty_s_group_export_row.
    DATA lv_group_recn TYPE char30.
    DATA lv_group_recn_db TYPE n LENGTH 20.
    DATA lv_group_subid TYPE string.
    DATA lv_group_subid_db TYPE c LENGTH 30.
    DATA lt_group_members TYPE ty_t_group_member_db.
    DATA ls_group_member TYPE ty_s_group_member_db.
    DATA lt_child_identifiers TYPE ty_t_child_identifier.
    DATA lv_line_no TYPE i.
    FIELD-SYMBOLS <lt_spc_group> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_group_cfg> TYPE any.
    FIELD-SYMBOLS <ls_spc_group> TYPE any.

    IF iv_technical_estcat = 'SAP_RMS_1012_005'
       AND iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained
       AND iv_recn_group <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_not_maintained.
      IF it_qual_rows IS NOT INITIAL.
        RETURN.
      ENDIF.
      retrieve_nutrient_listing(
        EXPORTING iv_technical_estcat = iv_technical_estcat
                  iv_recn_group = iv_recn_group
        IMPORTING et_group_members = lt_group_members ).
      retrieve_child_identifiers(
        EXPORTING it_group_members = lt_group_members
        IMPORTING et_child_identifiers = lt_child_identifiers ).
      LOOP AT lt_group_members INTO ls_group_member.
        lv_line_no += 1.

        CLEAR ls_row.
        ls_row-engine_key_col = 1.
        ls_row-engine_key_row = lv_line_no + 4.
        ls_row-estcat         = iv_technical_estcat.
        ls_row-estcat_desc    = iv_description.
        ls_row-esttype        = iv_esttype.
        ls_row-node_name      = 'ZSUPPLIER_GROUP'.
        ls_row-node_desc      = |LISTING; DISPLAY_ORD={ ls_group_member-ord }|.
        ls_row-datatype       = /plmb/if_exp_c=>gc_data_type-tabledata.
        ls_row-line_no        = lv_line_no.
        ls_row-specid         = ls_group_member-child_subid.
        ls_row-instance       = '1'.
        ls_row-sort_seq       = ls_group_member-ord.
        ls_row-recn           = ls_group_member-child_recn.
        ls_row-estcat_value   = iv_technical_estcat.
        ls_row-subid          = ls_group_member-child_subid.
        ls_row-grp_subid      = ls_group_member-group_subid.
        ls_row-compexp_stext = resolve_member_unit(
          iv_technical_estcat = iv_technical_estcat
          is_group_member = ls_group_member ).
        ls_row-ident1 = resolve_member_identifier(
          is_group_member = ls_group_member
          it_child_identifiers = lt_child_identifiers ).
        ls_row-ident1_desc = ls_row-ident1.
        APPEND ls_row TO ct_rows.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF it_qual_rows IS INITIAL AND it_group_cfg IS NOT INITIAL.
      LOOP AT it_group_cfg ASSIGNING <ls_group_cfg>.
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
                 lt_group_members.

          lv_group_recn    = get_component_string( is_data      = <ls_spc_group>
                                                   iv_component = 'RECN' ).
          lv_group_subid   = get_component_string( is_data      = <ls_spc_group>
                                                   iv_component = 'SUBID' ).
          lv_group_recn_db = lv_group_recn.
          lv_group_subid_db = lv_group_subid.

          IF lv_group_recn_db IS INITIAL AND lv_group_subid_db IS INITIAL.
            CONTINUE.
          ENDIF.

          " Selection contains RECN or a show-mode constant, never SUBID/IDENT.
          IF     iv_recn_group  IS NOT INITIAL
             AND iv_recn_group  <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_all
             AND iv_recn_group  <> /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained
             AND lv_group_recn  <> iv_recn_group.
            CONTINUE.
          ENDIF.

          retrieve_group_member_data(
            EXPORTING iv_technical_estcat = iv_technical_estcat
                      iv_group_recn = lv_group_recn
                      iv_group_subid = lv_group_subid
            IMPORTING et_group_members = lt_group_members ).

          retrieve_child_identifiers(
            EXPORTING it_group_members = lt_group_members
            IMPORTING et_child_identifiers = lt_child_identifiers ).

          LOOP AT lt_group_members INTO ls_group_member.
            lv_line_no += 1.

            CLEAR ls_row.
            ls_row-engine_key_col = 1.
            ls_row-engine_key_row = lv_line_no + 4.
            ls_row-estcat         = iv_technical_estcat.
            ls_row-estcat_desc    = iv_description.
            ls_row-esttype        = iv_esttype.
            ls_row-node_name      = 'ZSUPPLIER_GROUP'.
            ls_row-node_desc      = |DB; ORD={ ls_group_member-ord }|.
            ls_row-datatype       = /plmb/if_exp_c=>gc_data_type-tabledata.
            ls_row-line_no        = lv_line_no.
            ls_row-specid         = ls_group_member-child_subid.
            ls_row-instance       = '1'.
            ls_row-sort_seq       = ls_group_member-ord.
            ls_row-recn           = ls_group_member-child_recn.
            ls_row-estcat_value   = iv_technical_estcat.
            ls_row-subid          = ls_group_member-child_subid.
            ls_row-grp_subid      = ls_group_member-group_subid.
            ls_row-compexp_stext = resolve_member_unit(
              iv_technical_estcat = iv_technical_estcat
              is_group_member = ls_group_member ).
            ls_row-ident1 = resolve_member_identifier(
              is_group_member = ls_group_member
              it_child_identifiers = lt_child_identifiers ).
            ls_row-ident1_desc = ls_row-ident1.
            APPEND ls_row TO ct_rows.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

      IF lv_line_no > 0.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD append_qualification_rows.
    DATA ls_row TYPE ty_s_group_export_row.
    DATA lv_line_no TYPE i.
    FIELD-SYMBOLS <ls_qual_row> TYPE any.

    IF it_qual_rows IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_qual_rows ASSIGNING <ls_qual_row>.
      lv_line_no += 1.

      CLEAR ls_row.
      ls_row-engine_key_col = 1.
      ls_row-engine_key_row = lv_line_no + 4.
      ls_row-estcat         = iv_technical_estcat.
      ls_row-estcat_desc    = iv_description.
      ls_row-esttype        = iv_esttype.
      ls_row-node_name      = 'ZSUPPLIER_GROUP'.
      ls_row-node_desc      = |SPI; ORD={ get_component_string( is_data = <ls_qual_row> iv_component = 'ORD' ) }|.
      ls_row-datatype       = /plmb/if_exp_c=>gc_data_type-tabledata.
      ls_row-line_no        = |{ lv_line_no NUMBER = RAW }|.
      ls_row-specid         = iv_specid.
      ls_row-instance       = '1'.
      IF iv_technical_estcat = 'SAP_RMS_1012_005'.
        " The quantitative SPI node has already finalized the display ORD.
        ls_row-sort_seq = get_component_string( is_data = <ls_qual_row>
                                                iv_component = 'ORD' ).
      ELSE.
        " Preserve the connector's display sequence for other properties.
        ls_row-sort_seq = lv_line_no.
      ENDIF.
      ls_row-recn           = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'RECN' ).
      ls_row-actn           = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'ACTN' ).
      ls_row-recnroot       = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'RECNROOT' ).
      ls_row-recnparent     = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'RECNPARENT' ).
      ls_row-estcat_value   = iv_technical_estcat.
      ls_row-recn_vp        = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'RECN_VP' ).
      ls_row-actn_vp        = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'ACTN_VP' ).
      ls_row-subid          = get_component_string( is_data      = <ls_qual_row>
                                                    iv_component = 'SUBID' ).
      IF ls_row-subid IS INITIAL.
        ls_row-subid = get_component_string( is_data      = <ls_qual_row>
                                             iv_component = 'IDENT1' ).
      ENDIF.
      IF ls_row-specid IS INITIAL.
        ls_row-specid = ls_row-subid.
      ENDIF.
      ls_row-compexp_stext = get_component_string( is_data = <ls_qual_row>
                                                       iv_component = 'COMPEXP_STEXT' ).
      IF ls_row-compexp_stext IS INITIAL.
        ls_row-compexp_stext = get_component_string( is_data = <ls_qual_row>
                                                     iv_component = 'COMPEXP' ).
      ENDIF.
      ls_row-grp_subid   = get_component_string( is_data      = <ls_qual_row>
                                                 iv_component = 'GRP_SUBID' ).
      ls_row-ident1      = get_component_string( is_data      = <ls_qual_row>
                                                 iv_component = 'IDENT1' ).
      ls_row-ident1_desc = get_component_string( is_data      = <ls_qual_row>
                                                 iv_component = 'IDENT1_DESC' ).
      IF ls_row-ident1_desc IS INITIAL.
        ls_row-ident1_desc = get_component_string( is_data      = <ls_qual_row>
                                                   iv_component = 'COMPEXCVALNAM' ).
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
    DATA lo_struct     TYPE REF TO cl_abap_structdescr.
    DATA lo_value_type TYPE REF TO cl_abap_typedescr.
    DATA lt_components TYPE abap_component_tab.
    DATA ls_component  TYPE abap_componentdescr.
    DATA lv_value      TYPE string.

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
    DATA lt_vat TYPE SORTED TABLE OF eseestcat WITH UNIQUE KEY table_line.

    FIELD-SYMBOLS <ls_selection> TYPE /plmb/s_spc_exp_ptree_select.
    FIELD-SYMBOLS <ls_vat>       TYPE /plmb/s_spc_exp_estcat_select.

    CLEAR et_selection.

    IF iv_selection IS NOT INITIAL.
      " CALL TRANSFORMATION can raise exception, we catch it here and raise ASSERT
      TRY.
          CALL TRANSFORMATION id
               SOURCE XML iv_selection
               RESULT     root = et_selection.
        CATCH cx_transformation_error.
          ASSERT 1 = 0.
      ENDTRY.
    ENDIF.

    " ---------------------------------------------------------------------
    " Delete duplicate entries and delete lines where no
    " value assignment type needs to be queried
    " ---------------------------------------------------------------------
    IF et_selection IS NOT INITIAL.
      SORT et_selection BY property_tree ASCENDING.
      DELETE ADJACENT DUPLICATES FROM et_selection COMPARING property_tree.
      " ---------------------------------------------------------------------
      " Allow only one Value Assignment Type per selection
      " If the same VAT is in more property tree, it will be selected only once
      " ---------------------------------------------------------------------
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
    DATA lr_target_table TYPE REF TO data.
    DATA lr_info_row TYPE REF TO data.
    DATA lv_is_new TYPE abap_bool.
    DATA ls_vatcust TYPE /plmb/s_spc_val_action_vatcust.
    DATA lt_vat_atnam TYPE STANDARD TABLE OF ty_s_atnam.
    DATA lt_allowed_values TYPE STANDARD TABLE OF ty_s_allowed_value.
    DATA lv_failed TYPE /plmb/spi_failed_ind.
    DATA lv_insert_index TYPE sy-tabix.
    FIELD-SYMBOLS <lt_table_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_metadata_line> TYPE any.

    super->process_table_data( EXPORTING iv_node_name        = iv_node_name
                                         iv_target_node_name = iv_target_node_name
                                         iv_technical_estcat = iv_technical_estcat
                                         iv_esttype          = iv_esttype
                               CHANGING  ct_table_data       = ct_table_data
                                         ct_table_meta_data  = ct_table_meta_data ).

    IF iv_target_node_name <> /plmb/if_spc_attr=>gc_node_valuation.
      RETURN.
    ENDIF.

    find_metadata_target(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                iv_target_node_name = iv_target_node_name
                it_table_meta_data = ct_table_meta_data
                it_table_data = ct_table_data
      IMPORTING er_table_data = lr_target_table ).
    IF lr_target_table IS NOT BOUND.
      RETURN.
    ENDIF.
    ASSIGN lr_target_table->* TO <lt_table_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    retrieve_vat_customizing(
      IMPORTING es_vatcust = ls_vatcust
                ev_failed = lv_failed ).
    IF lv_failed = abap_true OR ls_vatcust-vat_customizing IS INITIAL.
      RETURN.
    ENDIF.

    prepare_additional_info_row(
      IMPORTING er_metadata_line = lr_info_row
                ev_insert_index = lv_insert_index
                ev_is_new = lv_is_new
      CHANGING ct_data = <lt_table_data> ).
    IF lr_info_row IS NOT BOUND.
      RETURN.
    ENDIF.
    ASSIGN lr_info_row->* TO <ls_metadata_line>.

    retrieve_characteristics(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                is_vatcust = ls_vatcust
      IMPORTING et_characteristics = lt_vat_atnam ).

    collect_allowed_values(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                it_characteristics = lt_vat_atnam
      CHANGING ct_allowed_values = lt_allowed_values ).

    populate_additional_info(
      EXPORTING iv_technical_estcat = iv_technical_estcat
                iv_esttype = iv_esttype
                is_vatcust = ls_vatcust
                it_allowed_values = lt_allowed_values
      CHANGING cs_metadata_line = <ls_metadata_line> ).

    insert_metadata_row(
      EXPORTING iv_is_new = lv_is_new
                iv_insert_index = lv_insert_index
                is_metadata_line = <ls_metadata_line>
      CHANGING ct_data = <lt_table_data> ).
  ENDMETHOD.

  METHOD format_numeric_allowed_value.
    DATA lv_numeric_value TYPE string.
    DATA lv_value_prefix TYPE string.
    DATA lv_unit TYPE msehi.

    CLEAR: lv_numeric_value,
           lv_value_prefix,
           lv_unit.
    lv_numeric_value = is_value-atflv.
    lv_numeric_value = condense( lv_numeric_value ).

    CASE is_value-atcod.
      WHEN '6'.
        lv_value_prefix = '<'.
      WHEN '7'.
        lv_value_prefix = '<='.
      WHEN '8'.
        lv_value_prefix = '>'.
      WHEN '9'.
        lv_value_prefix = '>='.
      WHEN OTHERS.
        CLEAR lv_value_prefix.
    ENDCASE.
    IF lv_value_prefix IS NOT INITIAL.
      CONCATENATE lv_value_prefix lv_numeric_value
                  INTO lv_numeric_value
                  SEPARATED BY space.
    ENDIF.

    lv_unit = is_value-atawe.
    IF lv_unit IS INITIAL AND is_characteristic-msehi IS NOT INITIAL.
      lv_unit = is_characteristic-msehi.
    ENDIF.
    IF lv_unit IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING  input    = lv_unit
                   language = sy-langu
        IMPORTING  output   = lv_unit
        EXCEPTIONS OTHERS   = 1.
      CONCATENATE lv_numeric_value lv_unit
                  INTO lv_numeric_value
                  SEPARATED BY space.
    ENDIF.
    ev_value = lv_numeric_value.
  ENDMETHOD.

  METHOD build_field_guidance.
    DATA lv_additional_info_part TYPE string.

    IF is_configuration-flg_is_no_single_value = abap_true.
      ev_guidance = 'Multiple values allowed'.
    ELSE.
      ev_guidance = 'Single value'.
    ENDIF.

    IF is_configuration-flg_is_no_single_value = 'D'.
      CONCATENATE ev_guidance 'Predefined list (dropdown)' INTO ev_guidance SEPARATED BY '; '.
    ENDIF.

    IF is_configuration-flg_input_required = abap_true.
      CONCATENATE ev_guidance 'Entry required' INTO ev_guidance SEPARATED BY '; '.
    ENDIF.

    IF is_configuration-anzst IS NOT INITIAL.
      lv_additional_info_part = is_configuration-anzst.
      SHIFT lv_additional_info_part LEFT DELETING LEADING space.
      CONCATENATE 'Length' lv_additional_info_part INTO lv_additional_info_part SEPARATED BY ' '.
      CONCATENATE ev_guidance lv_additional_info_part INTO ev_guidance SEPARATED BY '; '.
    ENDIF.

    CASE is_configuration-atfor.
      WHEN 'NUM' OR 'CURR'.
        CONCATENATE ev_guidance 'Numeric value' INTO ev_guidance SEPARATED BY '; '.
        IF is_configuration-msehi IS NOT INITIAL.
          lv_additional_info_part = is_configuration-msehi.
          CONCATENATE 'Default UoM (' lv_additional_info_part ')' INTO lv_additional_info_part.
          CONCATENATE ev_guidance lv_additional_info_part INTO ev_guidance SEPARATED BY '; '.
        ENDIF.
      WHEN 'DATE'.
        CONCATENATE ev_guidance 'Date format YYYYMMDD' INTO ev_guidance SEPARATED BY '; '.
      WHEN 'CHAR'.
        CONCATENATE ev_guidance 'Character value' INTO ev_guidance SEPARATED BY '; '.
    ENDCASE.
  ENDMETHOD.

  METHOD serialize_allowed_values.
    DATA ls_allowed_value TYPE ty_s_allowed_value.
    DATA lv_allowed_value_token TYPE string.

    CLEAR ev_values.
    LOOP AT it_allowed_values INTO ls_allowed_value WHERE atnam = iv_atnam.
      IF ls_allowed_value-allowed_value_desc IS INITIAL.
        lv_allowed_value_token = ls_allowed_value-allowed_value.
      ELSE.
        CONCATENATE ls_allowed_value-allowed_value ls_allowed_value-allowed_value_desc
                    INTO lv_allowed_value_token
                    SEPARATED BY '|'.
      ENDIF.
      IF ev_values IS INITIAL.
        ev_values = lv_allowed_value_token.
      ELSE.
        CONCATENATE ev_values lv_allowed_value_token INTO ev_values
                    SEPARATED BY '||ALLOWED_VALUE||'.
      ENDIF.
    ENDLOOP.
    " Start the dropdown blank when no application default is configured.
    IF ev_values IS NOT INITIAL
       AND NOT line_exists( it_allowed_values[ atnam = iv_atnam is_default = abap_true ] ).
      ev_values = '||ALLOWED_VALUE||' && ev_values.
    ENDIF.
  ENDMETHOD.

  METHOD retrieve_plant_values.
    DATA ls_atnam TYPE ty_s_atnam.
    DATA ls_allowed_value TYPE ty_s_allowed_value.
    DATA lt_plant_values TYPE STANDARD TABLE OF ty_s_plant_value.
    DATA ls_plant_value TYPE ty_s_plant_value.
    DATA lv_atbez TYPE string.
    DATA lv_allowed_value_count TYPE i.

    LOOP AT it_characteristics INTO ls_atnam.
      lv_atbez = ls_atnam-atbez.
      lv_atbez = condense( lv_atbez ).
      IF     lv_atbez       <> 'Production Plant'
         AND ls_atnam-atnam <> 'WERKS'.
        CONTINUE.
      ENDIF.

      CLEAR lt_plant_values.
      SELECT werks,
             name1
        FROM shsm_mt001w
        INTO TABLE @lt_plant_values.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR lv_allowed_value_count.
      LOOP AT lt_plant_values INTO ls_plant_value.
        lv_allowed_value_count += 1.
        CLEAR ls_allowed_value.
        ls_allowed_value-atnam              = ls_atnam-atnam.
        ls_allowed_value-sort_seq           = lv_allowed_value_count.
        ls_allowed_value-allowed_value      = ls_plant_value-werks.
        ls_allowed_value-allowed_value_desc = ls_plant_value-name1.
        IF ls_allowed_value-allowed_value IS INITIAL.
          CONTINUE.
        ENDIF.
        APPEND ls_allowed_value TO ct_allowed_values.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD resolve_lookup_fields.
    DATA lt_check_fields TYPE STANDARD TABLE OF ty_s_check_field.
    DATA ls_check_field TYPE ty_s_check_field.

    CLEAR: lt_check_fields,
           ls_check_field.

    SELECT fieldname
           keyflag
           position
           datatype
      INTO TABLE lt_check_fields
      FROM dd03l
      WHERE tabname  = iv_lookup_table
        AND as4local = 'A'.
    IF sy-subrc <> 0.
      CLEAR cs_characteristic-value_field.
      RETURN.
    ENDIF.

    DELETE lt_check_fields WHERE    fieldname = 'MANDT'
                                 OR fieldname = '.INCLUDE'.
    SORT lt_check_fields BY position.

    IF cs_characteristic-value_field IS INITIAL.
      LOOP AT lt_check_fields INTO ls_check_field WHERE keyflag = abap_true.
        IF ls_check_field-fieldname = 'SPRAS'.
          CONTINUE.
        ENDIF.
        cs_characteristic-value_field = ls_check_field-fieldname.
        EXIT.
      ENDLOOP.
    ENDIF.
    IF cs_characteristic-value_field IS INITIAL.
      READ TABLE lt_check_fields INTO ls_check_field INDEX 1.
      IF sy-subrc = 0.
        cs_characteristic-value_field = ls_check_field-fieldname.
      ENDIF.
    ENDIF.
    IF cs_characteristic-value_field IS INITIAL.
      RETURN.
    ENDIF.

    IF cs_characteristic-desc_field IS INITIAL.
      LOOP AT lt_check_fields INTO ls_check_field.
        IF ls_check_field-fieldname = cs_characteristic-value_field.
          RETURN.
        ENDIF.
        IF    ls_check_field-fieldname  = 'NAME1'
           OR ls_check_field-fieldname  = 'KTEXT'
           OR ls_check_field-fieldname  = 'LTEXT'
           OR ls_check_field-fieldname  = 'BEZEI'
           OR ls_check_field-fieldname  = 'ATWTB'
           OR ls_check_field-fieldname CP '*TEXT*'
           OR ls_check_field-fieldname CP '*TXT*'
           OR ls_check_field-fieldname CP '*DESC*'.
          cs_characteristic-desc_field = ls_check_field-fieldname.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF cs_characteristic-desc_field IS INITIAL.
      LOOP AT lt_check_fields INTO ls_check_field
           WHERE     keyflag  <> abap_true
                 AND datatype  = 'CHAR'.
        IF ls_check_field-fieldname <> cs_characteristic-value_field.
          cs_characteristic-desc_field = ls_check_field-fieldname.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD retrieve_check_table_values.
    DATA ls_atnam TYPE ty_s_atnam.
    DATA ls_allowed_value TYPE ty_s_allowed_value.
    DATA lt_lookup_helpers TYPE STANDARD TABLE OF ty_s_lookup_helper.
    DATA ls_lookup_helper TYPE ty_s_lookup_helper.
    DATA ls_t005 TYPE t005.
    DATA ls_t005t TYPE t005t.
    DATA ls_t179 TYPE t179.
    DATA ls_t179t TYPE t179t.
    DATA lv_atbez TYPE string.
    DATA lv_lookup_table TYPE dd03l-tabname.
    DATA lv_allowed_value_count TYPE i.
    DATA lv_check_value TYPE string.
    DATA lv_check_desc TYPE string.
    DATA lv_check_language TYPE string.
    DATA lv_t179_sort_seq TYPE i.
    DATA lr_check_rows TYPE REF TO data.
    FIELD-SYMBOLS <lt_check_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_check_row> TYPE any.

    " Add helper sources here when a check table should follow the same value-help source as the UI.
    APPEND VALUE ty_s_lookup_helper( check_table  = 'T001W'
                                     helper_table = 'SHSM_MT001W'
                                     value_field  = 'WERKS'
                                     desc_field   = 'NAME1' ) TO lt_lookup_helpers.

    LOOP AT it_characteristics INTO ls_atnam WHERE atprt IS NOT INITIAL.
      lv_atbez = ls_atnam-atbez.
      lv_atbez = condense( lv_atbez ).
      IF    lv_atbez       = 'Production Plant'
         OR ls_atnam-atnam = 'WERKS'.
        CONTINUE.
      ENDIF.

      CLEAR: ls_lookup_helper,
             lv_lookup_table.
      READ TABLE lt_lookup_helpers INTO ls_lookup_helper WITH KEY check_table = ls_atnam-atprt.
      IF ls_lookup_helper-helper_table IS INITIAL.
        lv_lookup_table = ls_atnam-atprt.
      ELSE.
        lv_lookup_table = ls_lookup_helper-helper_table.
        ls_atnam-value_field = ls_lookup_helper-value_field.
        ls_atnam-desc_field  = ls_lookup_helper-desc_field.
      ENDIF.

      IF ls_atnam-atprt = 'T005'.
        CLEAR lv_allowed_value_count.
        SELECT * FROM t005
          INTO ls_t005.
          CLEAR ls_allowed_value.
          lv_allowed_value_count += 1.
          ls_allowed_value-atnam         = ls_atnam-atnam.
          ls_allowed_value-sort_seq      = lv_allowed_value_count.
          ls_allowed_value-allowed_value = ls_t005-land1.

          SELECT SINGLE * FROM t005t
            INTO ls_t005t
            WHERE spras = sy-langu
              AND land1 = ls_t005-land1.
          IF sy-subrc = 0.
            ls_allowed_value-allowed_value_desc = ls_t005t-landx50.
          ENDIF.

          APPEND ls_allowed_value TO ct_allowed_values.
        ENDSELECT.
        CONTINUE.
      ENDIF.

      IF ls_atnam-atprt = 'T179'.
        CLEAR lv_t179_sort_seq.
        SELECT * FROM t179
          INTO ls_t179.
          CLEAR ls_allowed_value.
          lv_t179_sort_seq += 1.
          ls_allowed_value-atnam         = ls_atnam-atnam.
          ls_allowed_value-sort_seq      = lv_t179_sort_seq.
          ls_allowed_value-allowed_value = ls_t179-prodh.

          SELECT SINGLE * FROM t179t
            INTO ls_t179t
            WHERE spras = sy-langu
              AND prodh = ls_t179-prodh.
          IF sy-subrc = 0.
            ls_allowed_value-allowed_value_desc = ls_t179t-vtext.
          ENDIF.

          APPEND ls_allowed_value TO ct_allowed_values.
        ENDSELECT.
        CONTINUE.
      ENDIF.

      resolve_lookup_fields(
        EXPORTING iv_lookup_table = lv_lookup_table
        CHANGING cs_characteristic = ls_atnam ).
      IF ls_atnam-value_field IS INITIAL.
        CONTINUE.
      ENDIF.
      TRY.
        UNASSIGN <lt_check_rows>.
        CREATE DATA lr_check_rows TYPE STANDARD TABLE OF (lv_lookup_table).
        ASSIGN lr_check_rows->* TO <lt_check_rows>.
      CATCH cx_sy_create_data_error.
        CONTINUE.
      ENDTRY.
      IF <lt_check_rows> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      SELECT *
        FROM (lv_lookup_table)
        INTO TABLE <lt_check_rows>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR lv_allowed_value_count.
      LOOP AT <lt_check_rows> ASSIGNING <ls_check_row>.
        lv_check_language = get_component_string( is_data      = <ls_check_row>
                                                  iv_component = 'SPRAS' ).
        IF lv_check_language IS NOT INITIAL AND lv_check_language <> sy-langu.
          CONTINUE.
        ENDIF.

        lv_check_value = get_component_string( is_data      = <ls_check_row>
                                               iv_component = ls_atnam-value_field ).
        IF lv_check_value IS INITIAL.
          CONTINUE.
        ENDIF.

        CLEAR lv_check_desc.
        IF ls_atnam-desc_field IS NOT INITIAL.
          lv_check_desc = get_component_string( is_data      = <ls_check_row>
                                                iv_component = ls_atnam-desc_field ).
        ENDIF.

        lv_allowed_value_count += 1.
        CLEAR ls_allowed_value.
        ls_allowed_value-atnam              = ls_atnam-atnam.
        ls_allowed_value-sort_seq           = lv_allowed_value_count.
        ls_allowed_value-allowed_value      = lv_check_value.
        ls_allowed_value-allowed_value_desc = lv_check_desc.
        APPEND ls_allowed_value TO ct_allowed_values.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD retrieve_characteristic_values.
    DATA ls_atnam TYPE ty_s_atnam.
    DATA ls_allowed_value TYPE ty_s_allowed_value.
    DATA lt_cawn_values TYPE STANDARD TABLE OF ty_s_cawn_allowed_value.
    DATA ls_cawn_value TYPE ty_s_cawn_allowed_value.

    SELECT cabn~atnam
           cawn~atzhl
           cawn~atwrt
           cawn~atflv
           cawn~atcod
           cawn~atawe
           cawnt~atwtb
           cawn~atstd
      INTO TABLE lt_cawn_values
      FROM cabn
             INNER JOIN
               cawn ON cawn~atinn = cabn~atinn
                 LEFT OUTER JOIN
                   cawnt ON  cawnt~atinn = cawn~atinn
                         AND cawnt~atzhl = cawn~atzhl
                         AND cawnt~spras = sy-langu
      FOR ALL ENTRIES IN it_characteristics
      WHERE cabn~atnam = it_characteristics-atnam.

    LOOP AT lt_cawn_values INTO ls_cawn_value.
      CLEAR ls_allowed_value.
      ls_allowed_value-atnam    = ls_cawn_value-atnam.
      ls_allowed_value-sort_seq = ls_cawn_value-atzhl.
      ls_allowed_value-is_default = ls_cawn_value-atstd.
      CLEAR ls_atnam.
      READ TABLE it_characteristics INTO ls_atnam WITH KEY atnam = ls_cawn_value-atnam.
      IF    ls_atnam-atfor       = 'NUM'
         OR ls_atnam-atfor       = 'CURR'
         OR ls_cawn_value-atwrt IS INITIAL.
        format_numeric_allowed_value(
          EXPORTING is_value = ls_cawn_value
                    is_characteristic = ls_atnam
          IMPORTING ev_value = ls_allowed_value-allowed_value ).
      ELSE.
        ls_allowed_value-allowed_value = ls_cawn_value-atwrt.
      ENDIF.
      ls_allowed_value-allowed_value_desc = ls_cawn_value-atwtb.
      APPEND ls_allowed_value TO ct_allowed_values.
    ENDLOOP.
  ENDMETHOD.

  METHOD retrieve_phrase_values.

    SELECT tcg66~atnam
           estpj~ord
           estph~phrid
           estpp~phrtext
      APPENDING TABLE ct_allowed_values
      FROM tcg66
             INNER JOIN
               estpj ON estpj~recntps = tcg66~recntps
                 INNER JOIN
                   estph ON estph~recn = estpj~recntph
                     INNER JOIN
                       estpp ON estpp~recnroot = estph~recnroot
      FOR ALL ENTRIES IN it_characteristics
      WHERE tcg66~estcat   = iv_technical_estcat
        AND tcg66~atnam    = it_characteristics-atnam
        AND tcg66~recntps <> '00000000000000000000'
        AND estpj~delflg  <> 'X'
        AND estpj~parkflg <> 'X'
        AND estpj~valfr   <= sy-datum
        AND estpj~valto   >= sy-datum
        AND estph~delflg  <> 'X'
        AND estph~parkflg <> 'X'
        AND estph~valfr   <= sy-datum
        AND estph~valto   >= sy-datum
        AND estpp~langu    = sy-langu
        AND estpp~delflg  <> 'X'
        AND estpp~parkflg <> 'X'
        AND estpp~valfr   <= sy-datum
        AND estpp~valto   >= sy-datum.
  ENDMETHOD.

  METHOD normalize_allowed_values.

    DELETE ct_allowed_values WHERE allowed_value IS INITIAL.
    SORT ct_allowed_values BY atnam
                              allowed_value
                              allowed_value_desc
                              is_default DESCENDING
                              sort_seq.
    DELETE ADJACENT DUPLICATES FROM ct_allowed_values COMPARING atnam allowed_value allowed_value_desc.
    " Put configured defaults first without changing the remaining value order.
    SORT ct_allowed_values STABLE BY atnam is_default DESCENDING.
  ENDMETHOD.

  METHOD collect_allowed_values.
    DATA lt_value_atnam TYPE STANDARD TABLE OF ty_s_atnam.

    retrieve_plant_values(
      EXPORTING it_characteristics = it_characteristics
      CHANGING ct_allowed_values = ct_allowed_values ).

    retrieve_check_table_values(
      EXPORTING it_characteristics = it_characteristics
      CHANGING ct_allowed_values = ct_allowed_values ).

    lt_value_atnam = it_characteristics.
    DELETE lt_value_atnam WHERE atprt IS NOT INITIAL.

    IF lt_value_atnam IS NOT INITIAL.
      retrieve_characteristic_values(
        EXPORTING it_characteristics = lt_value_atnam
        CHANGING ct_allowed_values = ct_allowed_values ).

      retrieve_phrase_values(
        EXPORTING iv_technical_estcat = iv_technical_estcat
                  it_characteristics = lt_value_atnam
        CHANGING ct_allowed_values = ct_allowed_values ).
    ENDIF.

    normalize_allowed_values(
      CHANGING ct_allowed_values = ct_allowed_values ).
  ENDMETHOD.

  METHOD retrieve_characteristics.
    FIELD-SYMBOLS <ls_vatcust> TYPE /plmb/s_spc_val_conf_sp.
    DATA ls_atnam TYPE ty_s_atnam.
    DATA lt_value_atnam TYPE STANDARD TABLE OF ty_s_atnam.

    CLEAR et_characteristics.
    LOOP AT is_vatcust-vat_customizing ASSIGNING <ls_vatcust>
         WHERE     estcat  = iv_technical_estcat
               AND atnam  IS NOT INITIAL.
      CLEAR ls_atnam.
      ls_atnam-atnam = <ls_vatcust>-atnam.
      APPEND ls_atnam TO et_characteristics.
    ENDLOOP.

    SORT et_characteristics BY atnam.
    DELETE ADJACENT DUPLICATES FROM et_characteristics COMPARING atnam.

    IF et_characteristics IS NOT INITIAL.
      lt_value_atnam = et_characteristics.
      SELECT cabn~atnam
             cabn~atfor
             cabn~atprt
             cabn~msehi
             cabnt~atbez
        INTO CORRESPONDING FIELDS OF TABLE et_characteristics
        FROM cabn
               LEFT OUTER JOIN
                 cabnt ON  cabnt~atinn = cabn~atinn
                       AND cabnt~spras = sy-langu
        FOR ALL ENTRIES IN lt_value_atnam
        WHERE cabn~atnam = lt_value_atnam-atnam.

      SORT et_characteristics BY atnam
                           atprt DESCENDING.
      DELETE ADJACENT DUPLICATES FROM et_characteristics COMPARING atnam.
    ENDIF.
  ENDMETHOD.

  METHOD find_metadata_target.
    FIELD-SYMBOLS <ls_table_meta_data> TYPE ty_s_table_meta_data.
    FIELD-SYMBOLS <ls_table_data> TYPE /plmb/s_exp_table_data_export.

    CLEAR er_table_data.
    ASSIGN it_table_meta_data[ engine_value_assignment_type = iv_technical_estcat
                               target_node_name             = iv_target_node_name ] TO <ls_table_meta_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ASSIGN it_table_data[ table_no = <ls_table_meta_data>-table_no ] TO <ls_table_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    er_table_data = <ls_table_data>-table_data.
  ENDMETHOD.

  METHOD retrieve_vat_customizing.
    DATA lo_spi_connector_spc TYPE REF TO /plmb/if_spi_appl_access.

    CLEAR es_vatcust.
    ev_failed = abap_true.
    /plmb/cl_spi_connector=>create_instance( EXPORTING iv_abbid     = /plmb/if_abbid_c=>gc_spc
                                             IMPORTING eo_connector = lo_spi_connector_spc ).
    IF lo_spi_connector_spc IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_spi_connector_spc->action( EXPORTING iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation
                                            iv_action_name = /plmb/if_spc_attr=>gc_actions_val-get_vat_customizing
                                  IMPORTING ev_failed      = ev_failed
                                            eg_param       = es_vatcust ).
    IF ev_failed = abap_true OR es_vatcust-vat_customizing IS INITIAL.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_additional_info_row.
    DATA lr_metadata_line TYPE REF TO data.
    FIELD-SYMBOLS <ls_table_line> TYPE any.
    FIELD-SYMBOLS <ls_metadata_line> TYPE any.
    FIELD-SYMBOLS <lv_data> TYPE any.

    CLEAR: er_metadata_line, ev_insert_index, ev_is_new.
    LOOP AT ct_data ASSIGNING <ls_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_table_line> TO <lv_data>.
        IF sy-subrc = 0 AND <lv_data> = 5.
          ASSIGN <ls_table_line> TO <ls_metadata_line>.
          GET REFERENCE OF <ls_metadata_line> INTO er_metadata_line.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF er_metadata_line IS BOUND.
      RETURN.
    ENDIF.
    LOOP AT ct_data ASSIGNING <ls_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_data>.
      IF sy-subrc = 0 AND <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_table_line> TO <lv_data>.
        IF sy-subrc = 0 AND <lv_data> = 4.
          CREATE DATA lr_metadata_line LIKE <ls_table_line>.
          ASSIGN lr_metadata_line->* TO <ls_metadata_line>.
          <ls_metadata_line> = <ls_table_line>.
          ev_insert_index = sy-tabix + 1.
          er_metadata_line = lr_metadata_line.
          ev_is_new = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD populate_additional_info.
    FIELD-SYMBOLS <ls_vatcust> TYPE /plmb/s_spc_val_conf_sp.
    DATA lv_fieldname TYPE abap_compname.
    DATA lv_additional_info TYPE string.
    DATA lv_allowed_values TYPE string.
    FIELD-SYMBOLS <lv_data> TYPE any.

    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = 1.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = 5.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = iv_technical_estcat.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = iv_esttype.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = /plmb/if_exp_c=>gc_data_type-metadata.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = 5.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      <lv_data> = 'Additional Information'.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      CLEAR <lv_data>.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      CLEAR <lv_data>.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE cs_metadata_line TO <lv_data>.
    IF sy-subrc = 0.
      CLEAR <lv_data>.
    ENDIF.

    LOOP AT is_vatcust-vat_customizing ASSIGNING <ls_vatcust>
         WHERE estcat = iv_technical_estcat.
      CLEAR: lv_additional_info,
             lv_allowed_values.

      build_field_guidance(
        EXPORTING is_configuration = <ls_vatcust>
        IMPORTING ev_guidance = lv_additional_info ).
      lv_fieldname = <ls_vatcust>-atnam.
      TRANSLATE lv_fieldname USING '-_'.
      serialize_allowed_values(
        EXPORTING it_allowed_values = it_allowed_values
                  iv_atnam = <ls_vatcust>-atnam
        IMPORTING ev_values = lv_allowed_values ).
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_metadata_line TO <lv_data>.
      IF sy-subrc = 0.
        IF lv_allowed_values IS INITIAL.
          <lv_data> = lv_additional_info.
        ELSE.
          CONCATENATE lv_additional_info lv_allowed_values INTO <lv_data>
                      SEPARATED BY '||ALLOWED_VALUES||'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD insert_metadata_row.

    IF iv_is_new = abap_true.
      IF iv_insert_index IS INITIAL.
        APPEND is_metadata_line TO ct_data.
      ELSE.
        INSERT is_metadata_line INTO ct_data INDEX iv_insert_index.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD retrieve_folder_nodes.
    DATA lo_connector TYPE REF TO /plmb/if_spi_appl_access.
    DATA lv_object TYPE /plmb/gos_internal_key.
    DATA lt_spc_id TYPE /plmb/t_spc_id_sp.
    DATA ls_spc_id TYPE /plmb/s_spc_id_sp.
    DATA lt_trees TYPE /plmb/t_spc_bas_tree_sp.
    DATA lt_tree_id TYPE /plmb/t_spc_bas_tree_id_sp.
    DATA ls_tree_id TYPE /plmb/s_spc_bas_tree_id_sp.
    DATA lt_nodes TYPE /plmb/t_spc_bas_node_sp.
    DATA lv_failed TYPE /plmb/spi_failed_ind.
    DATA lt_failed TYPE /plmb/t_spi_rtr_index_failed.
    FIELD-SYMBOLS <ls_selection> TYPE /plmb/s_spc_exp_ptree_select.

    CLEAR: mt_folder_nodes, mt_exported_folders.
    " The single-specification exporter accepts exactly one object.
    IF lines( it_objects ) <> 1.
      RETURN.
    ENDIF.
    READ TABLE it_objects INTO lv_object INDEX 1.
    /plmb/cl_gos_cnv_tools=>split_intern_to_key(
      EXPORTING iv_internal_key = lv_object
      IMPORTING es_key = ls_spc_id ).
    APPEND ls_spc_id TO lt_spc_id.
    /plmb/cl_spi_connector=>create_instance(
      EXPORTING iv_abbid = /plmb/if_abbid_c=>gc_spc
      IMPORTING eo_connector = lo_connector ).
    IF lo_connector IS NOT BOUND.
      RETURN.
    ENDIF.
    lo_connector->retrieve(
      EXPORTING iv_node_name = /plmb/if_spc_attr=>gc_node_basic_header
                iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree_list
                it_node_id = lt_spc_id
      IMPORTING et_node_data = lt_trees
                ev_failed = lv_failed et_index_failed = lt_failed ).
    IF lv_failed = abap_true OR lt_failed IS NOT INITIAL.
      RETURN.
    ENDIF.
    LOOP AT lt_trees INTO DATA(ls_tree).
      UNASSIGN <ls_selection>.
      IF it_selection IS NOT INITIAL.
        READ TABLE it_selection ASSIGNING <ls_selection>
          WITH KEY property_tree = ls_tree-menid.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.
      CLEAR: lt_tree_id, ls_tree_id, lt_nodes, lv_failed, lt_failed.
      MOVE-CORRESPONDING ls_tree TO ls_tree_id.
      APPEND ls_tree_id TO lt_tree_id.
      lo_connector->retrieve(
        EXPORTING iv_node_name = /plmb/if_spc_attr=>gc_node_ptree_list
                  iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree
                  iv_lock = abap_false it_node_id = lt_tree_id
        IMPORTING et_node_data = lt_nodes
                  ev_failed = lv_failed et_index_failed = lt_failed ).
      IF lv_failed = abap_false AND lt_failed IS INITIAL.
        LOOP AT lt_nodes INTO DATA(ls_node).
          IF ls_node-leaf = abap_true AND <ls_selection> IS ASSIGNED.
            IF <ls_selection>-value_assignment_types IS NOT INITIAL.
              READ TABLE <ls_selection>-value_assignment_types TRANSPORTING NO FIELDS
                WITH KEY estcat = ls_node-estcat.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.
            ENDIF.
          ENDIF.
          APPEND ls_node TO mt_folder_nodes.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD append_folder_rows.
    DATA lt_ancestors TYPE /plmb/t_spc_bas_node_sp.
    DATA ls_node TYPE /plmb/s_spc_bas_node_sp.
    DATA ls_folder_id TYPE /plmb/s_spc_bas_node_id_sp.
    DATA lv_estcat TYPE eseestcat.
    DATA lv_row_key TYPE i.
    DATA lv_key TYPE i.
    DATA lv_parent TYPE seu_id.
    DATA lv_menid TYPE esemenid.
    DATA lv_index TYPE sy-tabix.
    DATA lv_source_rows TYPE i.
    TYPES: BEGIN OF ty_field,
             name TYPE string,
             value TYPE string,
           END OF ty_field.
    DATA lt_fields TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <ls_folder> TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.

    " Base export buffers can still contain rows added by a previous download.
    lv_index = lines( ct_rows ).
    WHILE lv_index > 0.
      ASSIGN ct_rows[ lv_index ] TO <ls_row>.
      IF get_component_string( is_data = <ls_row>
           iv_component = /plmb/if_exp_c=>gc_component_key-engine_node_name ) = 'ZPT_FOLDER'.
        DELETE ct_rows INDEX lv_index.
      ELSE.
        lv_key = get_component_string( is_data = <ls_row>
          iv_component = /plmb/if_exp_c=>gc_component_key-engine_key_row ).
        lv_row_key = nmax( val1 = lv_row_key val2 = lv_key ).
      ENDIF.
      lv_index -= 1.
    ENDWHILE.
    IF mt_folder_nodes IS INITIAL OR ct_rows IS INITIAL.
      RETURN.
    ENDIF.
    " Only visit original rows; new folder rows are appended to this table.
    lv_source_rows = lines( ct_rows ).
    LOOP AT ct_rows ASSIGNING <ls_row> TO lv_source_rows.
      IF get_component_string( is_data = <ls_row>
           iv_component = /plmb/if_exp_c=>gc_component_key-engine_node_name ) <> 'INSTANCES'
         OR get_component_string( is_data = <ls_row>
           iv_component = /plmb/if_exp_c=>gc_component_key-engine_datatype )
              <> /plmb/if_exp_c=>gc_data_type-tabledata
         OR has_first_sheet_hidden_vat( <ls_row> ) = abap_true.
        CONTINUE.
      ENDIF.
      lv_estcat = get_component_string( is_data = <ls_row>
        iv_component = /plmb/if_exp_c=>gc_component_key-engine_v_a_type ).
      READ TABLE mt_folder_nodes INTO ls_node WITH KEY estcat = lv_estcat leaf = abap_true.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR lt_ancestors.
      " Walk actual parent IDs, then emit outermost folder first.
      DO lines( mt_folder_nodes ) TIMES.
        IF ls_node-parent IS INITIAL.
          EXIT.
        ENDIF.
        lv_parent = ls_node-parent.
        lv_menid = ls_node-menid.
        READ TABLE mt_folder_nodes INTO ls_node WITH KEY menid = lv_menid id = lv_parent.
        IF sy-subrc <> 0.
          CLEAR lt_ancestors.
          EXIT.
        ENDIF.
        IF ls_node-type = 'INTR'.
          INSERT ls_node INTO lt_ancestors INDEX 1.
        ENDIF.
      ENDDO.
      IF ls_node-parent IS NOT INITIAL.
        CONTINUE. " Broken or cyclic hierarchy: do not invent a folder path.
      ENDIF.
      LOOP AT lt_ancestors INTO ls_node.
        READ TABLE mt_exported_folders TRANSPORTING NO FIELDS
          WITH TABLE KEY menid = ls_node-menid id = ls_node-id.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
        lv_row_key += 1.
        lt_fields = VALUE #(
          ( name = /plmb/if_exp_c=>gc_component_key-engine_key_col
            value = get_component_string( is_data = <ls_row>
              iv_component = /plmb/if_exp_c=>gc_component_key-engine_key_col ) )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_key_row value = |{ lv_row_key }| )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_v_a_type value = CONV string( lv_estcat ) )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc value = CONV string( ls_node-text ) )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_v_a_category value = 'E' )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_node_name value = 'ZPT_FOLDER' )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_node_name_desc value = CONV string( ls_node-menid ) )
          ( name = /plmb/if_exp_c=>gc_component_key-engine_datatype value = 'TABLEDATA' ) ).
        APPEND INITIAL LINE TO ct_rows ASSIGNING <ls_folder>.
        LOOP AT lt_fields INTO DATA(ls_field).
          ASSIGN COMPONENT ls_field-name OF STRUCTURE <ls_folder> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_field-value.
          ENDIF.
        ENDLOOP.
        MOVE-CORRESPONDING ls_node TO ls_folder_id.
        INSERT ls_folder_id INTO TABLE mt_exported_folders.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_export_rows.
    FIELD-SYMBOLS <ls_table_line> TYPE any.
    FIELD-SYMBOLS <lv_component> TYPE any.

    LOOP AT ct_rows ASSIGNING <ls_table_line>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_line> TO <lv_component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <lv_component> <> /plmb/if_exp_c=>gc_data_type-tabledata.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT iv_instance_field OF STRUCTURE <ls_table_line> TO <lv_component>.
      IF sy-subrc = 0 AND <lv_component> IS INITIAL.
        <lv_component> = '1'.
      ENDIF.

      IF iv_property_tree_text IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_table_line> TO <lv_component>.
      IF sy-subrc = 0.
        <lv_component> = iv_property_tree_text.
      ENDIF.
    ENDLOOP.
    append_folder_rows( CHANGING ct_rows = ct_rows ).
  ENDMETHOD.

  METHOD retrieve_nutrient_listing.
    DATA lv_subcat_group TYPE esesubcat.
    DATA lv_estcat_list TYPE eseestcat.
    DATA lv_severity TYPE /plmb/spi_msg_severity.
    DATA lt_message TYPE /plmb/t_spi_msg.
    DATA lt_groups TYPE /plmb/t_rsp_spc_specifications.
    DATA ls_group TYPE /plmb/s_rsp_spc_specifications.
    DATA lt_listing TYPE /plmb/t_rsp_spc_spec_grp_memb.
    DATA ls_listing TYPE /plmb/s_rsp_spc_spec_grp_memb.
    DATA ls_member TYPE ty_s_group_member_db.
    TYPES: BEGIN OF ty_s_header,
             recn TYPE estrh-recn,
             subid TYPE estrh-subid,
           END OF ty_s_header.
    DATA lt_headers TYPE STANDARD TABLE OF ty_s_header.
    DATA ls_header TYPE ty_s_header.
    FIELD-SYMBOLS <ls_member> TYPE ty_s_group_member_db.

    CLEAR et_group_members.
    " These modes require maintained composition data from the SPI node.
    IF iv_recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained
       OR iv_recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_not_maintained.
      RETURN.
    ENDIF.

    /plmi/cl_rsp_spc_services=>get_settings_by_vat(
      EXPORTING iv_estcat = iv_technical_estcat
      IMPORTING ev_subcat_group = lv_subcat_group
                ev_estcat_list = lv_estcat_list
                et_message = lt_message
                ev_severity = lv_severity ).
    IF lv_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
      RETURN.
    ENDIF.
    /plmi/cl_rsp_spc_services=>get_qual_quan_groups(
      EXPORTING iv_subcat_group = lv_subcat_group
                iv_keydate = mv_nutrient_key_date
      IMPORTING et_groups = lt_groups ).
    IF lt_groups IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_recn_group IS INITIAL
       OR iv_recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all.
      " One combined listing across all groups, as in the quantitative UI.
      /plmi/cl_rsp_spc_services=>get_qual_quan_listing(
        EXPORTING iv_estcat = iv_technical_estcat
                  iv_estcat_list = lv_estcat_list
                  iv_keydate = mv_nutrient_key_date
                  it_groups = lt_groups
        IMPORTING et_listing = lt_listing
                  et_message = lt_message ).
    ELSE.
      READ TABLE lt_groups INTO ls_group WITH KEY recn = iv_recn_group.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      /plmi/cl_rsp_spc_services=>get_qual_quan_listing(
        EXPORTING iv_estcat = iv_technical_estcat
                  iv_estcat_list = lv_estcat_list
                  iv_keydate = mv_nutrient_key_date
                  is_group = ls_group
        IMPORTING et_listing = lt_listing
                  et_message = lt_message ).
    ENDIF.
    IF lt_listing IS INITIAL.
      RETURN.
    ENDIF.

    " RECNCMP identifies the nutrient; SUBID is only used for SAP deduplication.
    SELECT recn subid INTO TABLE lt_headers FROM estrh
      FOR ALL ENTRIES IN lt_listing
      WHERE recn = lt_listing-recncmp.
    LOOP AT lt_listing INTO ls_listing.
      READ TABLE lt_headers INTO ls_header WITH KEY recn = ls_listing-recncmp.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR ls_member.
      ls_member-group_subid = iv_recn_group.
      ls_member-group_type = lv_subcat_group.
      ls_member-child_recn = ls_listing-recncmp.
      ls_member-child_subid = ls_header-subid.
      ls_member-ord = ls_listing-ord.
      ls_member-compexp = ls_listing-compexp.
      APPEND ls_member TO et_group_members.
    ENDLOOP.

    " Align export sort order with SAP quantitative composition UI
    SORT et_group_members BY child_subid.
    DELETE ADJACENT DUPLICATES FROM et_group_members COMPARING child_subid.
    SORT et_group_members BY ord.
    LOOP AT et_group_members ASSIGNING <ls_member>.
      <ls_member>-ord = sy-tabix.
    ENDLOOP.
  ENDMETHOD.

  METHOD retrieve_group_member_data.
    DATA lv_group_recn_db TYPE n LENGTH 20.
    DATA lv_group_subid_db TYPE c LENGTH 30.
    DATA lv_child_subcat_db TYPE c LENGTH 30.

    CLEAR et_group_members.
    lv_group_recn_db = iv_group_recn.
    lv_group_subid_db = iv_group_subid.
    CASE iv_technical_estcat.
      WHEN 'SAP_RMS_1012_005'.
        lv_child_subcat_db = 'NUTRIENT'.
      WHEN 'SAP_RMS_1012_021'.
        lv_child_subcat_db = 'ALLERGEN'.
      WHEN 'SAP_RMS_1012_010'.
        lv_child_subcat_db = 'DIET'.
      WHEN 'SAP_RMS_1012_022'.
        lv_child_subcat_db = 'RELIGIOUS'.
      WHEN 'SAP_RMS_1012_025'.
        lv_child_subcat_db = 'GENMOD'.
    ENDCASE.

    IF lv_child_subcat_db IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_group_recn_db IS NOT INITIAL.
      SELECT grp~subid    AS group_subid
             grp~subcat   AS group_type
             vp~ord       AS ord
             child~recn   AS child_recn
             child~subid  AS child_subid
             child~subcat AS child_type
             vp~compexp   AS compexp
        INTO TABLE et_group_members
        FROM estrh AS grp
               INNER JOIN
                 estva AS va ON va~recnroot = grp~recnroot
                   INNER JOIN
                     estvp AS vp ON  vp~recnroot = va~recnroot
                                 AND vp~recntva  = va~recn
                       INNER JOIN
                         estrh AS child ON child~recn = vp~recncmp
        WHERE grp~recn     = lv_group_recn_db
          AND child~subcat = lv_child_subcat_db.
    ENDIF.

    IF et_group_members IS INITIAL AND lv_group_subid_db IS NOT INITIAL.
      SELECT grp~subid    AS group_subid
             grp~subcat   AS group_type
             vp~ord       AS ord
             child~recn   AS child_recn
             child~subid  AS child_subid
             child~subcat AS child_type
             vp~compexp   AS compexp
        INTO TABLE et_group_members
        FROM estrh AS grp
               INNER JOIN
                 estva AS va ON va~recnroot = grp~recnroot
                   INNER JOIN
                     estvp AS vp ON  vp~recnroot = va~recnroot
                                 AND vp~recntva  = va~recn
                       INNER JOIN
                         estrh AS child ON child~recn = vp~recncmp
        WHERE grp~subid    = lv_group_subid_db
          AND child~subcat = lv_child_subcat_db.
    ENDIF.

    SORT et_group_members BY group_subid
                             ord
                             child_subid.
    DELETE ADJACENT DUPLICATES FROM et_group_members COMPARING group_subid ord child_subid.
  ENDMETHOD.

  METHOD retrieve_child_identifiers.
    " Read product names once for all children of this group.
    CLEAR et_child_identifiers.
    IF it_group_members IS NOT INITIAL.
      SELECT child~recn id~langu id~ident
        INTO TABLE et_child_identifiers
        FROM estrh AS child
        INNER JOIN estri AS id ON id~recnroot = child~recnroot
        FOR ALL ENTRIES IN it_group_members
        WHERE child~recn = it_group_members-child_recn
          AND id~idtype = 'NAM'
          AND id~idcat = 'PROD'
          AND ( id~langu = sy-langu OR id~langu = space )
          AND id~delflg = space
          AND id~parkflg = space
          AND id~valfr <= sy-datum
          AND id~valto >= sy-datum.
    ENDIF.
  ENDMETHOD.

  METHOD resolve_member_unit.
    TYPES: BEGIN OF ty_s_nutrient_valuation,
             recn TYPE estva-recn,
             actn TYPE estva-actn,
             valfr TYPE estva-valfr,
           END OF ty_s_nutrient_valuation.
    DATA lt_nutrient_valuations TYPE STANDARD TABLE OF ty_s_nutrient_valuation.
    DATA ls_nutrient_valuation TYPE ty_s_nutrient_valuation.
    DATA lv_nutrient_object TYPE ausp-objek.
    DATA lv_nutrient_unit TYPE ausp-atwrt.
    DATA lv_unit TYPE estvp-compexp.

    lv_unit = is_group_member-compexp.
    " Unmaintained group items obtain their unit from the nutrient property.
    IF lv_unit IS INITIAL
       AND iv_technical_estcat = 'SAP_RMS_1012_005'.
      CLEAR: lt_nutrient_valuations, lv_nutrient_unit.
      SELECT va~recn va~actn va~valfr
        INTO TABLE lt_nutrient_valuations
        FROM estva AS va
        INNER JOIN estvh AS vh ON vh~recn = va~recntvh
                              AND vh~recnroot = va~recnroot
        WHERE va~recnroot = is_group_member-child_recn
          AND vh~estcat = 'SAP_RMS_1011_001'
          AND vh~delflg = space
          AND vh~parkflg = space
          AND vh~valfr <= sy-datum
          AND vh~valto >= sy-datum
          AND va~delflg = space
          AND va~parkflg = space
          AND va~valfr <= sy-datum
          AND va~valto >= sy-datum.
      SORT lt_nutrient_valuations BY valfr DESCENDING actn DESCENDING recn.
      LOOP AT lt_nutrient_valuations INTO ls_nutrient_valuation.
        CONCATENATE ls_nutrient_valuation-recn ls_nutrient_valuation-actn
          INTO lv_nutrient_object.
        CLEAR lv_nutrient_unit.
        SELECT SINGLE a~atwrt
          INTO lv_nutrient_unit
          FROM ausp AS a
          INNER JOIN cabn AS c ON c~atinn = a~atinn
          WHERE a~objek = lv_nutrient_object
            AND a~lkenz = space
            AND c~atnam = 'SAP_RMS_1011_001_VALUE'
            AND c~lkenz = space.
        IF sy-subrc = 0 AND lv_nutrient_unit IS NOT INITIAL.
          lv_unit = lv_nutrient_unit.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF lv_unit IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING input = lv_unit
                  language = sy-langu
        IMPORTING output = rv_unit_text
        EXCEPTIONS OTHERS = 1.
      IF sy-subrc <> 0.
        rv_unit_text = lv_unit.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD resolve_member_identifier.
    DATA ls_child_identifier TYPE ty_s_child_identifier.
    DATA lt_child_names TYPE SORTED TABLE OF estri-ident WITH UNIQUE KEY table_line.
    DATA lv_child_name TYPE estri-ident.

    rv_identifier = is_group_member-child_subid.
    CLEAR lt_child_names.
    LOOP AT it_child_identifiers INTO ls_child_identifier
         WHERE child_recn = is_group_member-child_recn AND langu = sy-langu.
      IF ls_child_identifier-ident IS NOT INITIAL.
        INSERT ls_child_identifier-ident INTO TABLE lt_child_names.
      ENDIF.
    ENDLOOP.
    IF lt_child_names IS INITIAL.
      LOOP AT it_child_identifiers INTO ls_child_identifier
           WHERE child_recn = is_group_member-child_recn AND langu = space.
        IF ls_child_identifier-ident IS NOT INITIAL.
          INSERT ls_child_identifier-ident INTO TABLE lt_child_names.
        ENDIF.
      ENDLOOP.
    ENDIF.
    " Keep the SpecID when the product name is missing or ambiguous.
    IF lines( lt_child_names ) = 1.
      READ TABLE lt_child_names INTO lv_child_name INDEX 1.
      rv_identifier = lv_child_name.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
