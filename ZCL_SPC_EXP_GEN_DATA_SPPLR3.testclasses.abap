" Paste into the Test Classes include of ZCL_SPC_EXP_GEN_DATA_SPPLR2.
" Install ZCL_SPC_EXP_GEN_DATA_SPPLR3.locals_def.abap in Local Definitions first.
" That include grants this local test class access to private helpers.
CLASS ltc_supplier_export DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_spc_exp_gen_data_spplr2.
    METHODS setup.
    METHODS normalizes_allowed_values FOR TESTING.
    METHODS lists_default_values_first FOR TESTING.
    METHODS serializes_matching_values FOR TESTING.
    METHODS clears_unmatched_values FOR TESTING.
    METHODS guidance_single_value FOR TESTING.
    METHODS guidance_multiple_required FOR TESTING.
    METHODS guidance_dropdown_date FOR TESTING.
    METHODS guidance_numeric_unit FOR TESTING.
    METHODS defaults_and_orders_rows FOR TESTING.
    METHODS preserves_connector_order FOR TESTING.
    METHODS empty_export_rows FOR TESTING.
    METHODS creates_group_defaults FOR TESTING.
    METHODS preserves_group_selection FOR TESTING.
    METHODS reads_missing_add_info FOR TESTING.
    METHODS reads_dynamic_component FOR TESTING.
    METHODS updates_only_data_rows FOR TESTING.
    METHODS resolves_member_names FOR TESTING.
    METHODS folder_ancestors_once FOR TESTING.
ENDCLASS.

CLASS ltc_supplier_export IMPLEMENTATION.
  METHOD folder_ancestors_once.
    DATA components TYPE cl_abap_structdescr=>component_table.
    DATA data_ref TYPE REF TO data.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <value> TYPE any.
    DATA names TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    names = VALUE #(
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_key_col ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_key_row ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_v_a_type ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_v_a_category ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_node_name ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_node_name_desc ) )
      ( CONV string( /plmb/if_exp_c=>gc_component_key-engine_datatype ) )
      ( `CHARACTERISTIC_VALUE` ) ).
    LOOP AT names INTO DATA(name).
      APPEND VALUE #( name = name type = cl_abap_elemdescr=>get_string( ) ) TO components.
    ENDLOOP.
    DATA(row_type) = cl_abap_structdescr=>create( components ).
    DATA(table_type) = cl_abap_tabledescr=>create( row_type ).
    CREATE DATA data_ref TYPE HANDLE table_type.
    ASSIGN data_ref->* TO <rows>.
    DO 2 TIMES.
      APPEND INITIAL LINE TO <rows> ASSIGNING <row>.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <row> TO <value>.
      <value> = 'VAT1'.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <row> TO <value>.
      <value> = 'INSTANCES'.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <row> TO <value>.
      <value> = 'TABLEDATA'.
      ASSIGN COMPONENT 'CHARACTERISTIC_VALUE' OF STRUCTURE <row> TO <value>.
      <value> = 'Keep me'.
    ENDDO.
    " Deliberately unordered nodes: hierarchy must come from PARENT, not table order.
    cut->mt_folder_nodes = VALUE #(
        ( menid = 'TREE1' id = '3' parent = '2' leaf = abap_true type = 'LEAF' estcat = 'VAT1' )
        ( menid = 'TREE1' id = '2' parent = '1' type = 'INTR' text = 'Inner' )
        ( menid = 'TREE1' id = '1' parent = '4' type = 'INTR' text = 'Outer' )
        ( menid = 'TREE1' id = '4' type = 'ROOT' text = 'Root' ) ).
    cut->append_folder_rows( CHANGING ct_rows = <rows> ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = lines( <rows> ) ).
    READ TABLE <rows> ASSIGNING <row> INDEX 3.
    cl_abap_unit_assert=>assert_equals( exp = 'Outer' act = cut->get_component_string(
      is_data = <row> iv_component = CONV string( /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc ) ) ).
    READ TABLE <rows> ASSIGNING <row> INDEX 4.
    cl_abap_unit_assert=>assert_equals( exp = 'Inner' act = cut->get_component_string(
      is_data = <row> iv_component = CONV string( /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc ) ) ).
    cl_abap_unit_assert=>assert_initial( act = cut->get_component_string(
      is_data = <row> iv_component = 'CHARACTERISTIC_VALUE' ) ).
    READ TABLE <rows> ASSIGNING <row> INDEX 1.
    cl_abap_unit_assert=>assert_equals( exp = 'Keep me' act = cut->get_component_string(
      is_data = <row> iv_component = 'CHARACTERISTIC_VALUE' ) ).
    " A new download with buffered rows must not duplicate the headings.
    CLEAR cut->mt_exported_folders.
    cut->append_folder_rows( CHANGING ct_rows = <rows> ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = lines( <rows> ) ).
  ENDMETHOD.

  METHOD setup.
    CREATE OBJECT cut.
  ENDMETHOD.

  METHOD normalizes_allowed_values.
    DATA actual TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_allowed_value.
    DATA expected LIKE actual.
    actual = VALUE #(
      ( atnam = 'B' allowed_value = '2' )
      ( atnam = 'A' allowed_value = '' )
      ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'One' sort_seq = 9 )
      ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'One' sort_seq = 2 )
      ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'Other' sort_seq = 3 ) ).
    expected = VALUE #(
      ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'One' sort_seq = 2 )
      ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'Other' sort_seq = 3 )
      ( atnam = 'B' allowed_value = '2' ) ).
    cut->normalize_allowed_values( CHANGING ct_allowed_values = actual ).
    cl_abap_unit_assert=>assert_equals( exp = expected act = actual ).
  ENDMETHOD.

  METHOD lists_default_values_first.
    DATA values TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_allowed_value.
    DATA actual TYPE string.
    values = VALUE #(
      ( atnam = 'A' allowed_value = 'Alpha' )
      ( atnam = 'A' allowed_value = 'Zulu' sort_seq = 1 )
      ( atnam = 'A' allowed_value = 'Zulu' sort_seq = 9 is_default = abap_true )
      ( atnam = 'A' allowed_value = 'Beta' is_default = abap_true )
      ( atnam = 'A' allowed_value = 'Gamma' )
      ( atnam = 'B' allowed_value = 'Other' is_default = abap_true ) ).
    cut->normalize_allowed_values( CHANGING ct_allowed_values = values ).
    cut->serialize_allowed_values( EXPORTING it_allowed_values = values iv_atnam = 'A'
                                   IMPORTING ev_values = actual ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Beta||ALLOWED_VALUE||Zulu||ALLOWED_VALUE||Alpha||ALLOWED_VALUE||Gamma'
      act = actual ).
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lines( values ) ).
  ENDMETHOD.

  METHOD serializes_matching_values.
    DATA values TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_allowed_value.
    DATA actual TYPE string.
    values = VALUE #( ( atnam = 'A' allowed_value = '1' allowed_value_desc = 'One' )
                      ( atnam = 'B' allowed_value = 'ignored' )
                      ( atnam = 'A' allowed_value = '2' ) ).
    cut->serialize_allowed_values( EXPORTING it_allowed_values = values iv_atnam = 'A'
                                   IMPORTING ev_values = actual ).
    cl_abap_unit_assert=>assert_equals( exp = '||ALLOWED_VALUE||1|One||ALLOWED_VALUE||2' act = actual ).
  ENDMETHOD.

  METHOD clears_unmatched_values.
    DATA values TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_allowed_value.
    DATA actual TYPE string VALUE 'stale output'.
    values = VALUE #( ( atnam = 'B' allowed_value = '2' ) ).
    cut->serialize_allowed_values( EXPORTING it_allowed_values = values iv_atnam = 'A'
                                   IMPORTING ev_values = actual ).
    cl_abap_unit_assert=>assert_initial( act = actual ).
  ENDMETHOD.

  METHOD guidance_single_value.
    DATA config TYPE /plmb/s_spc_val_conf_sp.
    DATA actual TYPE string VALUE 'stale output'.
    cut->build_field_guidance( EXPORTING is_configuration = config
                              IMPORTING ev_guidance = actual ).
    cl_abap_unit_assert=>assert_equals( exp = 'Single value' act = actual ).
  ENDMETHOD.

  METHOD guidance_multiple_required.
    DATA config TYPE /plmb/s_spc_val_conf_sp.
    DATA actual TYPE string.
    config-flg_is_no_single_value = abap_true.
    config-flg_input_required = abap_true.
    config-atfor = 'CHAR'.
    cut->build_field_guidance( EXPORTING is_configuration = config
                              IMPORTING ev_guidance = actual ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Multiple values allowed; Entry required; Character value' act = actual ).
  ENDMETHOD.

  METHOD guidance_dropdown_date.
    DATA config TYPE /plmb/s_spc_val_conf_sp.
    DATA actual TYPE string.
    config-flg_is_no_single_value = 'D'.
    config-atfor = 'DATE'.
    cut->build_field_guidance( EXPORTING is_configuration = config
                              IMPORTING ev_guidance = actual ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Single value; Predefined list (dropdown); Date format YYYYMMDD' act = actual ).
  ENDMETHOD.

  METHOD guidance_numeric_unit.
    DATA config TYPE /plmb/s_spc_val_conf_sp.
    DATA actual TYPE string.
    config-atfor = 'NUM'.
    config-msehi = 'KG'.
    cut->build_field_guidance( EXPORTING is_configuration = config
                              IMPORTING ev_guidance = actual ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Single value; Numeric value; Default UoM (KG)' act = actual ).
    config-atfor = 'CURR'.
    CLEAR config-msehi.
    cut->build_field_guidance( EXPORTING is_configuration = config
                              IMPORTING ev_guidance = actual ).
    cl_abap_unit_assert=>assert_equals( exp = 'Single value; Numeric value' act = actual ).
  ENDMETHOD.

  METHOD defaults_and_orders_rows.
    DATA actual TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_group_export_row.
    DATA expected LIKE actual.
    actual = VALUE #(
      ( datatype = /plmb/if_exp_c=>gc_data_type-tabledata
        estcat_desc = 'Group' subid = 'B' sort_seq = '10' instance = '3' ref_qty = '4' )
      ( datatype = /plmb/if_exp_c=>gc_data_type-metadata engine_key_row = 5 )
      ( datatype = /plmb/if_exp_c=>gc_data_type-tabledata
        estcat_desc = 'Group' subid = 'A' sort_seq = '2' )
      ( datatype = /plmb/if_exp_c=>gc_data_type-tabledata
        estcat_desc = 'Group' subid = 'A' sort_seq = '9' ) ).
    expected = VALUE #(
      ( datatype = /plmb/if_exp_c=>gc_data_type-metadata engine_key_row = 5 )
      ( datatype = /plmb/if_exp_c=>gc_data_type-tabledata
        estcat_desc = 'Group' subid = 'A' sort_seq = '2' instance = '1' ref_qty = '1'
        engine_key_row = 2 line_no = '1' )
      ( datatype = /plmb/if_exp_c=>gc_data_type-tabledata
        estcat_desc = 'Group' subid = 'B' sort_seq = '10' instance = '3' ref_qty = '4'
        engine_key_row = 3 line_no = '2' ) ).
    cut->default_export_defaults( CHANGING ct_rows = actual ).
    cl_abap_unit_assert=>assert_equals( exp = expected act = actual ).
  ENDMETHOD.

  METHOD preserves_connector_order.
    TYPES: BEGIN OF ty_source,
             subid TYPE string,
             ord TYPE n LENGTH 4,
           END OF ty_source.
    DATA source_rows TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.
    DATA actual TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_group_export_row.
    source_rows = VALUE #( ( subid = 'NUTR_027' ord = '0007' )
                           ( subid = 'NUTR_026' ord = '0006' )
                           ( subid = 'NUTR_021' ord = '0001' )
                           ( subid = 'NUTR_028' ord = '0008' ) ).
    cut->append_qualification_rows(
      EXPORTING iv_technical_estcat = 'SAP_RMS_1012_005'
                iv_esttype = 'RMS_D'
                iv_description = 'Nutrient Composition'
                iv_specid = ''
                it_qual_rows = source_rows
      CHANGING ct_rows = actual ).
    cut->default_export_defaults( CHANGING ct_rows = actual ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = lines( actual ) ).
    cl_abap_unit_assert=>assert_equals( exp = 'NUTR_027' act = actual[ 1 ]-specid ).
    cl_abap_unit_assert=>assert_equals( exp = 'NUTR_026' act = actual[ 2 ]-specid ).
    cl_abap_unit_assert=>assert_equals( exp = 'NUTR_021' act = actual[ 3 ]-specid ).
    cl_abap_unit_assert=>assert_equals( exp = 'NUTR_028' act = actual[ 4 ]-specid ).
  ENDMETHOD.

  METHOD empty_export_rows.
    DATA actual TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_group_export_row.
    cut->default_export_defaults( CHANGING ct_rows = actual ).
    cl_abap_unit_assert=>assert_initial( act = actual ).
  ENDMETHOD.

  METHOD creates_group_defaults.
    DATA info TYPE /plmb/t_exp_additional_info.
    DATA fields TYPE STANDARD TABLE OF fieldname WITH DEFAULT KEY.
    fields = VALUE #( ( /plmi/if_spc_exp_c=>gc_additional_info-nutrient )
                       ( /plmi/if_spc_exp_c=>gc_additional_info-diet )
                       ( /plmi/if_spc_exp_c=>gc_additional_info-allergen )
                       ( /plmi/if_spc_exp_c=>gc_additional_info-religious )
                       ( /plmi/if_spc_exp_c=>gc_additional_info-gen_mod ) ).
    cut->ensure_show_all_groups( CHANGING ct_add_info = info ).
    cut->ensure_show_all_groups( CHANGING ct_add_info = info ).
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lines( info ) ).
    LOOP AT fields INTO DATA(field).
      cl_abap_unit_assert=>assert_equals(
        exp = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all
        act = cut->get_add_info_value( it_add_info = info iv_fname = field ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD preserves_group_selection.
    DATA info TYPE /plmb/t_exp_additional_info.
    DATA selected TYPE REF TO char30.
    DATA blank TYPE REF TO char30.
    CREATE DATA selected.
    CREATE DATA blank.
    selected->* = 'MY_GROUP'.
    info = VALUE #( ( fname = /plmi/if_spc_exp_c=>gc_additional_info-nutrient value = selected )
                    ( fname = /plmi/if_spc_exp_c=>gc_additional_info-diet value = blank )
                    ( fname = /plmi/if_spc_exp_c=>gc_additional_info-allergen ) ).
    cut->ensure_show_all_groups( CHANGING ct_add_info = info ).
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lines( info ) ).
    cl_abap_unit_assert=>assert_equals( exp = 'MY_GROUP'
      act = cut->get_add_info_value( it_add_info = info
        iv_fname = /plmi/if_spc_exp_c=>gc_additional_info-nutrient ) ).
    cl_abap_unit_assert=>assert_equals( exp = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all
      act = cut->get_add_info_value( it_add_info = info
        iv_fname = /plmi/if_spc_exp_c=>gc_additional_info-diet ) ).
    cl_abap_unit_assert=>assert_equals( exp = /plmb/if_spc_attr=>gc_actions_qua-qua_show_all
      act = cut->get_add_info_value( it_add_info = info
        iv_fname = /plmi/if_spc_exp_c=>gc_additional_info-allergen ) ).
  ENDMETHOD.

  METHOD reads_missing_add_info.
    DATA info TYPE /plmb/t_exp_additional_info.
    cl_abap_unit_assert=>assert_initial(
      act = cut->get_add_info_value( it_add_info = info iv_fname = 'ABSENT' ) ).
    APPEND VALUE #( fname = 'UNBOUND' ) TO info.
    cl_abap_unit_assert=>assert_initial(
      act = cut->get_add_info_value( it_add_info = info iv_fname = 'UNBOUND' ) ).
  ENDMETHOD.

  METHOD updates_only_data_rows.
    DATA components TYPE cl_abap_structdescr=>component_table.
    DATA rows_ref TYPE REF TO data.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    " This helper consumes engine rows, whose component names come from SAP constants.
    components = VALUE #(
      ( name = /plmb/if_exp_c=>gc_component_key-engine_datatype
        type = cl_abap_elemdescr=>get_string( ) )
      ( name = 'INSTANCE' type = cl_abap_elemdescr=>get_string( ) )
      ( name = /plmb/if_exp_c=>gc_component_key-engine_node_name_desc
        type = cl_abap_elemdescr=>get_string( ) ) ).
    DATA(row_type) = cl_abap_structdescr=>create( components ).
    DATA(table_type) = cl_abap_tabledescr=>create( row_type ).
    CREATE DATA rows_ref TYPE HANDLE table_type.
    ASSIGN rows_ref->* TO <rows>.

    APPEND INITIAL LINE TO <rows> ASSIGNING <row>.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype
      OF STRUCTURE <row> TO <value>.
    cl_abap_unit_assert=>assert_subrc( ).
    <value> = /plmb/if_exp_c=>gc_data_type-metadata.
    ASSIGN COMPONENT 'INSTANCE' OF STRUCTURE <row> TO <value>.
    <value> = 'META_INSTANCE'.
    APPEND INITIAL LINE TO <rows> ASSIGNING <row>.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype
      OF STRUCTURE <row> TO <value>.
    <value> = /plmb/if_exp_c=>gc_data_type-tabledata.
    APPEND <row> TO <rows>.
    READ TABLE <rows> ASSIGNING <row> INDEX 3.
    ASSIGN COMPONENT 'INSTANCE' OF STRUCTURE <row> TO <value>.
    <value> = '7'.

    cut->update_export_rows( EXPORTING iv_instance_field = 'INSTANCE'
                                      iv_property_tree_text = 'Property tree'
                            CHANGING ct_rows = <rows> ).
    READ TABLE <rows> ASSIGNING <row> INDEX 1.
    cl_abap_unit_assert=>assert_equals( exp = 'META_INSTANCE'
      act = cut->get_component_string( is_data = <row> iv_component = 'INSTANCE' ) ).
    cl_abap_unit_assert=>assert_initial( act = cut->get_component_string(
      is_data = <row>
      iv_component = CONV string( /plmb/if_exp_c=>gc_component_key-engine_node_name_desc ) ) ).
    READ TABLE <rows> ASSIGNING <row> INDEX 3.
    cl_abap_unit_assert=>assert_equals( exp = '7'
      act = cut->get_component_string( is_data = <row> iv_component = 'INSTANCE' ) ).
    READ TABLE <rows> ASSIGNING <row> INDEX 2.
    cl_abap_unit_assert=>assert_equals( exp = '1'
      act = cut->get_component_string( is_data = <row> iv_component = 'INSTANCE' ) ).
    cl_abap_unit_assert=>assert_equals( exp = 'Property tree' act = cut->get_component_string(
      is_data = <row>
      iv_component = CONV string( /plmb/if_exp_c=>gc_component_key-engine_node_name_desc ) ) ).

    cut->update_export_rows( EXPORTING iv_instance_field = 'INSTANCE'
                                      iv_property_tree_text = ''
                            CHANGING ct_rows = <rows> ).
    READ TABLE <rows> ASSIGNING <row> INDEX 2.
    cl_abap_unit_assert=>assert_equals( exp = 'Property tree' act = cut->get_component_string(
      is_data = <row>
      iv_component = CONV string( /plmb/if_exp_c=>gc_component_key-engine_node_name_desc ) ) ).
  ENDMETHOD.

  METHOD resolves_member_names.
    DATA member TYPE zcl_spc_exp_gen_data_spplr2=>ty_s_group_member_db.
    DATA identifiers TYPE zcl_spc_exp_gen_data_spplr2=>ty_t_child_identifier.
    member-child_recn = '1'.
    member-child_subid = 'SPEC1'.
    cl_abap_unit_assert=>assert_equals( exp = 'SPEC1'
      act = cut->resolve_member_identifier( is_group_member = member
                                           it_child_identifiers = identifiers ) ).
    APPEND VALUE #( child_recn = member-child_recn langu = space ident = 'Neutral' ) TO identifiers.
    cl_abap_unit_assert=>assert_equals( exp = 'Neutral'
      act = cut->resolve_member_identifier( is_group_member = member
                                           it_child_identifiers = identifiers ) ).
    APPEND VALUE #( child_recn = member-child_recn langu = sy-langu ident = 'Local' ) TO identifiers.
    APPEND VALUE #( child_recn = member-child_recn langu = sy-langu ident = 'Local' ) TO identifiers.
    APPEND VALUE #( child_recn = '2' langu = sy-langu ident = 'Other member' ) TO identifiers.
    cl_abap_unit_assert=>assert_equals( exp = 'Local'
      act = cut->resolve_member_identifier( is_group_member = member
                                           it_child_identifiers = identifiers ) ).
    APPEND VALUE #( child_recn = member-child_recn langu = sy-langu ident = 'Ambiguous' ) TO identifiers.
    cl_abap_unit_assert=>assert_equals( exp = 'SPEC1'
      act = cut->resolve_member_identifier( is_group_member = member
                                           it_child_identifiers = identifiers ) ).
  ENDMETHOD.

  METHOD reads_dynamic_component.
    DATA row TYPE zcl_spc_exp_gen_data_spplr2=>ty_s_group_export_row.
    row-subid = 'SPEC123'.
    cl_abap_unit_assert=>assert_equals( exp = 'SPEC123'
      act = cut->get_component_string( is_data = row iv_component = 'SUBID' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = cut->get_component_string( is_data = row iv_component = 'ABSENT' ) ).
  ENDMETHOD.
ENDCLASS.
