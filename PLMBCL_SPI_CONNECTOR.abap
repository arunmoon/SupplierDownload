class /PLMB/CL_SPI_CONNECTOR definition
  public
  final
  create public

  global friends /PLMB/CL_SPI_COLLECTOR
                 /PLMB/CL_SPI_COLLECTOR_OUTPUT
                 /PLMB/CL_SPI_FACTORY
                 /PLMB/CL_SPI_METADATA
                 /PLMB/CL_SPI_RFC_CONNECTOR .

public section.

  interfaces /PLMB/IF_RFC_CONNECTOR .
  interfaces /PLMB/IF_SPI_APPL_ACCESS .

  aliases ACTION
    for /PLMB/IF_SPI_APPL_ACCESS~ACTION .
  aliases CHECK_BEFORE_SAVE
    for /PLMB/IF_SPI_APPL_ACCESS~CHECK_BEFORE_SAVE .
  aliases CLEAN_UP
    for /PLMB/IF_SPI_APPL_ACCESS~CLEAN_UP .
  aliases DELETE
    for /PLMB/IF_SPI_APPL_ACCESS~DELETE .
  aliases INSERT
    for /PLMB/IF_SPI_APPL_ACCESS~INSERT .
  aliases QUERY
    for /PLMB/IF_SPI_APPL_ACCESS~QUERY .
  aliases RETRIEVE
    for /PLMB/IF_SPI_APPL_ACCESS~RETRIEVE .
  aliases SAVE
    for /PLMB/IF_SPI_APPL_ACCESS~SAVE .
  aliases UPDATE
    for /PLMB/IF_SPI_APPL_ACCESS~UPDATE .

  class-data GV_DATA_FLOW_LOG_IS_ACTIVE type BOOLE_D read-only .
  class-data GV_WITHOUT_COMMIT type BOOLE_D read-only .

  class-events UNSAVED_DATA_EXISTS
    exporting
      value(IV_UNSAVED_DATA_EXISTS) type BOOLE_D .

  class-methods CLASS_CONSTRUCTOR .
  class-methods CREATE_INSTANCE
    importing
      !IV_ABBID type /PLMB/SPI_ABBID
      !IS_OPTIONS type /PLMB/S_SPI_CONNECTOR_OPTIONS optional
      !IO_MASTER_COLLECTOR type ref to /PLMB/IF_SPI_COLLECTOR optional
    exporting
      !EO_CONNECTOR type ref to /PLMB/IF_SPI_APPL_ACCESS
      !EO_COLLECTOR type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT
      !EO_METADATA type ref to /PLMB/IF_SPI_METADATA_OUTPUT .
  class-methods INVALIDATE_INSTANCE
    importing
      !IO_CONNECTOR type ref to /PLMB/IF_SPI_APPL_ACCESS .
  class-methods WITHOUT_COMMIT .
  class-methods HAS_UNSAVED_DATA
    importing
      !IO_CONNECTOR type ref to /PLMB/IF_SPI_APPL_ACCESS optional
    exporting
      !EV_UNSAVED_DATA_EXISTS type BOOLE_D .
  methods CONSTRUCTOR
    importing
      !IV_ABBID type /PLMB/SPI_ABBID
      !IS_OPTIONS type /PLMB/S_SPI_CONNECTOR_OPTIONS optional
      !IO_MASTER_COLLECTOR type ref to /PLMB/IF_SPI_COLLECTOR optional .
protected section.

  class-methods GET_ACTIVE_CONNECTOR
    returning
      value(RO_CONNECTOR) type ref to /PLMB/CL_SPI_CONNECTOR .
private section.

  types:
    BEGIN OF ys_collector,
      collector TYPE REF TO /plmb/if_spi_collector,
    END   OF ys_collector .
  types:
    yt_collector TYPE STANDARD TABLE OF ys_collector
                               WITH NON-UNIQUE DEFAULT KEY .
  types:
    BEGIN OF ys_instance,
      abbid                 TYPE /plmb/spi_abbid,
      sp_rtid               TYPE /plmb/spi_sp_rtid,
      connector             TYPE REF TO /plmb/cl_spi_connector,
   END   OF ys_instance .
  types:
    yt_instance TYPE STANDARD TABLE OF ys_instance
              WITH UNIQUE SORTED KEY sp_rtid COMPONENTS sp_rtid
              WITH NON-UNIQUE SORTED KEY abbid COMPONENTS abbid .
  types:
    yt_data_flow_check TYPE SORTED TABLE OF /plmb/spi_check
                               WITH UNIQUE KEY target_abbid target_user .

  constants GC_CLASS_NAME type SEOCLSNAME value '/PLMB/CL_SPI_CONNECTOR'. "#EC NOTEXT
  constants:
    BEGIN OF gs_c_target_method,
      invalidate_instance            TYPE numc2 VALUE '01', "Release Instance
      get_properties                 TYPE numc2 VALUE '02', "Get Properties
      get_operation_properties       TYPE numc2 VALUE '03', "Get Operation Properties
    END OF gs_c_target_method .
  class-data GT_CALLSTACK type /PLMB/T_SPI_CALLSTACK .
  class-data GT_DATA_FLOW_CHECK type YT_DATA_FLOW_CHECK .
  class-data GT_INSTANCE type YT_INSTANCE .
  class-data GV_CHECK_BEFORE_SAVE type BOOLE_D .
  class-data GV_UNSAVED_DATA type BOOLE_D .
  data MO_APPL_ACCESS_CHECK type ref to /PLMB/CL_SPI_APPL_ACCESS_CHECK .
  data MO_COLLECTOR_IN type ref to /PLMB/CL_SPI_COLLECTOR_INPUT .
  data MO_COLLECTOR_OUT type ref to /PLMB/CL_SPI_COLLECTOR_OUTPUT .
  data MO_MP type ref to /PLMB/CL_SPI_METADATA .
  data MO_PROPERTIES_ACCESS type ref to /PLMB/IF_SPI_PROPERTIES_ACCESS .
  data MO_SP type ref to /PLMB/IF_SPI_APPL_ACCESS .
  data MS_ABBID_DETAILS type /PLMB/S_SPI_METADATA_ABBID .
  data MS_CONTROL_OPTIONS type /PLMB/S_SPI_OPTIONS_INT .
  data MV_ABBID type /PLMB/SPI_ABBID .
  data MV_BYPASS_SERVICE_PROVIDER type /PLMB/SPI_SKIP_STANDARD .
  data MV_CALLED_BY_RFC type BOOLE_D .
  data MV_DMZ_HOST_NAME type SYHOST .
  data MV_DMZ_IPV4ADDR type NI_IPV4ADDR .
  data MV_SP_RTID type /PLMB/SPI_SP_RTID .
  data MV_UNSAVED_DATA type BOOLE_D .

  class-methods DECREASE_CALLSTACK .
  class-methods DELETE_INSTANCE_FROM_BUFFER
    importing
      !IV_SP_RTID type /PLMB/SPI_SP_RTID
    returning
      value(RV_DELETE_SUCCESSFUL) type BOOLE_D .
  class-methods EVALUATE_COLLECTOR_DATA
    importing
      !IV_SP_CALL_SUCCESSFUL type BOOLE_D .
  class-methods EVALUATE_COLLECTOR_OPTIONS .
  class-methods GET_CONNECTOR_BY_RTID
    importing
      !IV_SP_RTID type /PLMB/SPI_SP_RTID
    exporting
      !EO_CONNECTOR type ref to /PLMB/CL_SPI_CONNECTOR .
  class-methods GET_INSTANCE
    importing
      !IV_SP_RTID type /PLMB/SPI_SP_RTID
      !IV_ABBID type /PLMB/SPI_ABBID
      !IS_OPTIONS_CON type /PLMB/S_SPI_OPTIONS_INT
    exporting
      !EO_APPL_ACCESS type ref to /PLMB/IF_SPI_APPL_ACCESS
      !EO_COLLECTOR_OUTPUT type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT
      !EO_METADATA type ref to /PLMB/IF_SPI_METADATA_OUTPUT .
  class-methods GET_SUCCEEDED_RECORDS
    importing
      !IT_NODE_ID type INDEX TABLE optional
      !IT_NODE_DATA type INDEX TABLE optional
      !IT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED optional
      !IT_INDEX_FAILED_RTR type /PLMB/T_SPI_RTR_INDEX_FAILED optional
    exporting
      !ET_SUCCEEDED_NODE_ID type INDEX TABLE .
  class-methods INCREASE_CALLSTACK
    importing
      !IV_ACCESS_METHOD type /PLMB/SPI_ACCESS_METHOD
      !IO_CONNECTOR type ref to /PLMB/CL_SPI_CONNECTOR .
  class-methods IS_SUPPLIED
    importing
      !IG_PARAM type DATA
    returning
      value(RV_IS_SUPPLIED) type BOOLE_D .
  methods CHECK_INDEX_FAILED
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_DATA type INDEX TABLE
    changing
      !CT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED .
  methods CHECK_RTR_INDEX_FAILED
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_DATA type INDEX TABLE
    changing
      !CT_INDEX_FAILED type /PLMB/T_SPI_RTR_INDEX_FAILED .
  methods DETERMINE_DATA_FLOW_CHECK .
  methods GET_AUTO_PULL_FOCUS
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_OPERATION_TYPE type /PLMB/SPI_OPERATION_TYPE
      !IV_OPERATION_NAME type /PLMB/SPI_OPERATION_NAME optional
    exporting
      !ES_REQUESTED_PROPERTIES type /PLMB/S_SPI_SUPPORTED_PROPERTY
      !ET_REQUESTED_FIELDS type /PLMB/T_SPI_REQUESTED_FIELD .
  methods GET_FAILED_NODE_DATA
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_NODE_DATA type INDEX TABLE
      !IT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED
    exporting
      !ET_FAILED_NODE_DATA type INDEX TABLE .
  methods GET_OPERATION_PROPERTIES
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME optional
      !IV_REFERENCE_TYPE type /PLMB/SPI_OPR_PRPTY_REF_TYPE
      !IG_REFERENCE_DATA type ANY optional
      !IV_EVALUATE_COLLECTOR_DATA type BOOLE_D optional
    exporting
      !ET_OPERATION_PROPERTIES type /PLMB/T_SPI_OPERATION_PRPTY
      !ET_OPR_PRPTY_SINGLE_IDX type /PLMB/T_SPI_INDEXED_OPR_PRPTY
      !ET_OPR_PRPTY_MULTI_IDX type /PLMB/T_SPI_NDX_OPR_PRPTY_MULT .
  methods GET_PROPERTIES
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME optional
      !IV_REFERENCE_TYPE type /PLMB/SPI_PRPTY_REF_TYPE
      !IG_REFERENCE_DATA type ANY optional
      !IV_EVALUATE_COLLECTOR_DATA type BOOLE_D optional
      !IT_REQUESTED_FIELD type /PLMB/T_SPI_REQUESTED_FIELD optional
    exporting
      !ET_PROPERTIES_SINGLE_IDX type /PLMB/T_SPI_INDEXED_PROPERTY
      !ET_PROPERTIES_MULTI_IDX type /PLMB/T_SPI_INDEXED_PRP_MULTI
      !ET_PROPERTIES type /PLMB/T_SPI_PROPERTIES .
  methods INVALIDATE_NODE_ID_IMPLICIT
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_NODE_ID type INDEX TABLE optional
      !IV_REASON type /PLMB/SPI_INVALIDATION_REASON .
  methods PULL_PROPERTIES
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME optional
      !IT_NODE_ID type INDEX TABLE optional
      !IS_NODE_ID type ANY optional
      !IT_NODE_DATA_IN type INDEX TABLE optional
      !IT_NODE_DATA_OUT type INDEX TABLE optional
      !IT_INDEX_FAILED_RTR type /PLMB/T_SPI_RTR_INDEX_FAILED optional
      !IT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED optional
      !IV_OPERATION_TYPE type /PLMB/SPI_OPERATION_TYPE
      !IV_OPERATION_NAME type /PLMB/SPI_OPERATION_NAME optional .
ENDCLASS.



CLASS /PLMB/CL_SPI_CONNECTOR IMPLEMENTATION.


METHOD /plmb/if_rfc_connector~rfc_call_receive.

  DATA:
    lv_abbid                       TYPE /plmb/spi_abbid,    "#EC NEEDED
    lv_sp_rtid                     TYPE /plmb/spi_sp_rtid,
    lv_node_name                   TYPE /plmb/spi_node_name,
    lv_target_node_name            TYPE /plmb/spi_node_name,
    ls_data_negue                  TYPE /plmb/spi_xstring,
    lv_reference_type              TYPE /plmb/spi_reference_type,
    lv_reference_data              TYPE /plmb/spi_xstring,
    lo_metadata_node               TYPE REF TO /plmb/if_spi_metadata_node,
    lr_structure                   TYPE REF TO data,
    lr_table                       TYPE REF TO data,
    lv_kind                        TYPE abap_typecategory,
    lv_target_method               TYPE numc2,
    lt_properties_single_idx       TYPE /plmb/t_spi_indexed_property,
    lt_properties_multi_idx        TYPE /plmb/t_spi_indexed_prp_multi,
    lt_properties                  TYPE /plmb/t_spi_properties,
    lt_operation_properties        TYPE /plmb/t_spi_operation_prpty,
    lt_opr_prpty_single_idx        TYPE /plmb/t_spi_indexed_opr_prpty,
    lt_opr_prpty_multi_idx         TYPE /plmb/t_spi_ndx_opr_prpty_mult,
    lt_messages                    TYPE	/plmb/t_spi_coll_int_message.

  FIELD-SYMBOLS:
    <ls_instance>                  TYPE ys_instance,
    <lg_reference_data>            TYPE any .

  CLEAR: es_data.

  IMPORT iv_abbid             = lv_abbid
         iv_sp_rtid           = lv_sp_rtid
         is_data              = ls_data_negue
         iv_target_method     = lv_target_method
   FROM DATA BUFFER  is_data.

  READ TABLE gt_instance ASSIGNING <ls_instance>
    WITH TABLE KEY sp_rtid
    COMPONENTS sp_rtid = lv_sp_rtid.

  IF  lv_target_method = /plmb/cl_spi_connector=>gs_c_target_method-get_properties
   OR lv_target_method = /plmb/cl_spi_connector=>gs_c_target_method-get_operation_properties.
    IMPORT iv_reference_data   = lv_reference_data
           iv_node_name        = lv_node_name
           iv_target_node_name = lv_target_node_name
           iv_reference_type   = lv_reference_type
           iv_kind             = lv_kind
     FROM DATA BUFFER ls_data_negue.
  ENDIF.

  IF lv_reference_data IS NOT INITIAL.
* Get instance of node ------------------------------------
    lo_metadata_node = <ls_instance>-connector->mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
    TRY .
        IF lv_kind = cl_abap_typedescr=>kind_struct.
          CALL METHOD lo_metadata_node->get_reference_data_container
            EXPORTING
              iv_reference_type = lv_reference_type
            IMPORTING
              er_structure      = lr_structure.
          ASSIGN lr_structure->* TO <lg_reference_data>.
        ELSEIF lv_kind = cl_abap_typedescr=>kind_table.
          CALL METHOD lo_metadata_node->get_reference_data_container
            EXPORTING
              iv_reference_type = lv_reference_type
            IMPORTING
              er_table          = lr_table.
          ASSIGN lr_table->* TO <lg_reference_data>.
        ELSE.
          RAISE EXCEPTION TYPE /plmb/cx_spi_error.
        ENDIF.
      CATCH /plmb/cx_spi_metadata.    " SPI Metadata Exception (static)
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            node_name = lv_node_name
            abbid     = lv_abbid.
    ENDTRY.
    IMPORT ig_reference_data = <lg_reference_data>
      FROM DATA BUFFER lv_reference_data.
  ENDIF.

  CASE lv_target_method.
    WHEN /plmb/cl_spi_connector=>gs_c_target_method-invalidate_instance.
      " Release Instance
      CALL METHOD invalidate_instance( <ls_instance>-connector ).

    WHEN /plmb/cl_spi_connector=>gs_c_target_method-get_properties.
      " Get Field Properties
      IF <lg_reference_data> IS ASSIGNED.
        CALL METHOD <ls_instance>-connector->get_properties
          EXPORTING
            iv_node_name             = lv_node_name
            iv_target_node_name      = lv_target_node_name
            ig_reference_data        = <lg_reference_data>
            iv_reference_type        = lv_reference_type
          IMPORTING
            et_properties_single_idx = lt_properties_single_idx
            et_properties_multi_idx  = lt_properties_multi_idx
            et_properties            = lt_properties.
      ELSE.
        CALL METHOD <ls_instance>-connector->get_properties
          EXPORTING
            iv_node_name             = lv_node_name
            iv_target_node_name      = lv_target_node_name
            iv_reference_type        = lv_reference_type
          IMPORTING
            et_properties_single_idx = lt_properties_single_idx
            et_properties_multi_idx  = lt_properties_multi_idx
            et_properties            = lt_properties.
      ENDIF.
      "Messages
      /plmb/cl_spi_collector_output=>/plmb/if_spi_collector_out_gen~get_messages(
        IMPORTING et_messages = lt_messages ).
      EXPORT et_properties_single_idx = lt_properties_single_idx
             et_properties_multi_idx  = lt_properties_multi_idx
             et_properties            = lt_properties
             et_messages              = lt_messages
       TO DATA BUFFER  es_data
           COMPRESSION ON.

    WHEN /plmb/cl_spi_connector=>gs_c_target_method-get_operation_properties.
      " Get Operation Properties
      IF <lg_reference_data> IS ASSIGNED.
        CALL METHOD <ls_instance>-connector->get_operation_properties
          EXPORTING
            iv_node_name            = lv_node_name
            iv_target_node_name     = lv_target_node_name
            ig_reference_data       = <lg_reference_data>
            iv_reference_type       = lv_reference_type
          IMPORTING
            et_operation_properties = lt_operation_properties
            et_opr_prpty_single_idx = lt_opr_prpty_single_idx
            et_opr_prpty_multi_idx  = lt_opr_prpty_multi_idx.
      ELSE.
        CALL METHOD <ls_instance>-connector->get_operation_properties
          EXPORTING
            iv_node_name            = lv_node_name
            iv_target_node_name     = lv_target_node_name
            iv_reference_type       = lv_reference_type
          IMPORTING
            et_operation_properties = lt_operation_properties
            et_opr_prpty_single_idx = lt_opr_prpty_single_idx
            et_opr_prpty_multi_idx  = lt_opr_prpty_multi_idx.
      ENDIF.
      "Messages
      /plmb/cl_spi_collector_output=>/plmb/if_spi_collector_out_gen~get_messages(
        IMPORTING et_messages = lt_messages ).
      EXPORT et_operation_properties = lt_operation_properties
             et_opr_prpty_single_idx = lt_opr_prpty_single_idx
             et_opr_prpty_multi_idx  = lt_opr_prpty_multi_idx
             et_messages             = lt_messages
       TO DATA BUFFER  es_data
           COMPRESSION ON.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~action.

  DATA:
    lr_node_data_table       TYPE REF TO data,  "Container for the data table
    lr_action_struc_export   TYPE REF TO data,  "Container for exporting parameters
    lr_node_id_table         TYPE REF TO data,  "Container for the IDs table
    lr_succeeded_node_id     TYPE REF TO data,  "Container for the IDs table
    lr_action_struc_import   TYPE REF TO data,  "Container for importing parameters
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lt_generic_type          TYPE /plmb/t_spi_generic_type_def,
    ls_generic_type          TYPE /plmb/s_spi_generic_type_def,
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lv_not_save_relevant     TYPE /plmb/spi_not_save_relevant,
    lv_save_relevant         TYPE boole_d,
    lv_version               TYPE /plmb/spi_metadata_version,
    lv_sideeffect            TYPE /plmb/spi_sideeffect,
    lv_sp_call_successful    TYPE boole_d.

  FIELD-SYMBOLS:
    <lt_node_data>           TYPE INDEX TABLE,
    <lt_node_id>             TYPE INDEX TABLE,
    <lt_succeeded_node_id>   TYPE INDEX TABLE,
    <ls_param>               TYPE any,
    <lg_param>               TYPE any.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_node_data,
    et_index_failed,
    eg_param.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-action.

  "Check import parameter.
  IF iv_node_name IS INITIAL.
    "Node name mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_node_name
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.
  IF iv_action_name IS INITIAL.
    "Action name mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_action_name
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF is_supplied( is_param ) = abap_true.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_action_struc_import(
           iv_action_name = iv_action_name
           is_data        = is_param ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_param
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
    IF is_supplied( it_node_id ) = abap_true.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = it_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
    IF et_node_data IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = et_node_data ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
    IF eg_param IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_action_struc_export(
           iv_action_name = iv_action_name
           ig_data        = eg_param ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-eg_param
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).
  IF lv_version > /plmb/if_mdp_c=>gs_c_version-version_702.
    "Check if operation is supported according to metadata.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
      IMPORTING
        ev_action = ls_operation_category-action.
    IF ls_operation_category-action IS INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid             = /plmb/cx_spi_error=>operation_not_supported
          abbid              = mv_abbid
          node_name          = iv_node_name
          operation_category = /plmb/if_spi_c=>gs_c_operation_category-action.
    ENDIF.
  ENDIF.

  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_transient( ) = abap_false.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_action_details
      EXPORTING
        iv_action_name       = iv_action_name
      IMPORTING
        ev_not_save_relevant = lv_not_save_relevant.
    IF lv_not_save_relevant = abap_false.
      "CHECK_BEFORE_SAVE needs to be called again before calling SAVE.
      CLEAR: gv_check_before_save.
      IF ms_control_options-transient = abap_true.
        "Upon instantiation the SP instance was marked as transient,
        "so save relevant operations are forbidden
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid = /plmb/cx_spi_error=>save_rel_operation_prohibited
            abbid  = mv_abbid.
      ENDIF.
      lv_save_relevant = abap_true.
    ENDIF.
  ENDIF.

  "Get structure container:
  CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_action_details
    EXPORTING
      iv_action_name            = iv_action_name
    IMPORTING
      er_import_struc_container = lr_action_struc_import
      er_export_struc_container = lr_action_struc_export.
  IF lr_action_struc_import IS BOUND.
    ASSIGN lr_action_struc_import->* TO <ls_param>.
    IF is_param IS NOT INITIAL.
      <ls_param> = is_param.
    ENDIF.
  ELSEIF is_param IS NOT INITIAL.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_param
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-action
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ELSE.
    ASSIGN ls_generic_type TO <ls_param>.
  ENDIF.
  IF eg_param IS SUPPLIED.
    ASSIGN eg_param TO <lg_param>.
  ELSEIF lr_action_struc_export IS BOUND.
    ASSIGN lr_action_struc_export->* TO <lg_param>.
  ELSE.
    ASSIGN ls_generic_type TO <lg_param>.
  ENDIF.

  TRY.
      "Get a container for IT_NODE_ID
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
        IMPORTING
          er_id_table = lr_node_id_table.
      ASSIGN lr_node_id_table->* TO <lt_node_id>.
      IF it_node_id IS NOT INITIAL.
        <lt_node_id> = it_node_id.
      ENDIF.
    CATCH /plmb/cx_spi_metadata.
      IF it_node_id IS NOT INITIAL.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = iv_node_name.
      ENDIF.
      ASSIGN lt_generic_type TO <lt_node_id>.
  ENDTRY.

  IF et_node_data IS SUPPLIED.
    ASSIGN et_node_data TO <lt_node_data>.
  ELSE.
    "Get a container for ET_NODE_DATA
    "Note: this is required to avoid type conflicts if consumer does not
    "      request the parameters but the service provider fills them
    TRY.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
          IMPORTING
            er_data_table = lr_node_data_table.
      CATCH /plmb/cx_spi_metadata.
        CLEAR: lr_node_data_table.
    ENDTRY.
    IF lr_node_data_table IS BOUND.
      ASSIGN lr_node_data_table->* TO <lt_node_data>.
    ELSE.
      ASSIGN lt_generic_type TO <lt_node_data>.
    ENDIF.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = iv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before Action ----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_action
      EXPORTING
        iv_abbid       = mv_abbid
        iv_node_name   = iv_node_name
        iv_action_name = iv_action_name
        io_collector   = mo_collector_in
        io_metadata    = mo_mp
      CHANGING
        cs_param       = <ls_param>
        ct_node_id     = <lt_node_id>.

    CALL BADI lb_appl_access->before_action
      EXPORTING
        iv_abbid         = mv_abbid
        iv_node_name     = iv_node_name
        iv_action_name   = iv_action_name
        is_param         = <ls_param>
        it_node_id       = <lt_node_id>
        io_collector     = mo_collector_in
        io_metadata      = mo_mp
      CHANGING
        cv_skip_standard = mv_bypass_service_provider
        cv_failed        = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      "collect also possible messages to be displayed later note 2630149
      CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
      RETURN.
    ENDIF.
  ENDIF.

*--- Call Action ------------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    mo_sp->action(
      EXPORTING iv_node_name    = iv_node_name
                iv_action_name  = iv_action_name
                it_node_id      = <lt_node_id>
                is_param        = <ls_param>
      IMPORTING ev_failed       = ev_failed
                et_index_failed = et_index_failed
                et_node_data    = <lt_node_data>
                eg_param        = <lg_param> ).

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->action
        EXPORTING
          iv_node_name    = iv_node_name
          iv_action_name  = iv_action_name
          is_param        = <ls_param>
          it_node_id      = <lt_node_id>
          iv_failed       = ev_failed
          it_index_failed = et_index_failed
          it_node_data    = <lt_node_data>
          ig_param        = <lg_param>.
    ENDIF.
  ENDIF.

*--- After Action -----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->after_action
      EXPORTING
        iv_abbid        = mv_abbid
        iv_node_name    = iv_node_name
        iv_action_name  = iv_action_name
        is_param        = <ls_param>
        it_node_id      = <lt_node_id>
        io_collector    = mo_collector_in
        io_metadata     = mo_mp
      CHANGING
        cv_failed       = ev_failed
        ct_index_failed = et_index_failed
        ct_node_data    = <lt_node_data>
        cg_param        = <lg_param>.

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->action
        EXPORTING
          iv_node_name    = iv_node_name
          iv_action_name  = iv_action_name
          is_param        = <ls_param>
          it_node_id      = <lt_node_id>
          iv_failed       = ev_failed
          it_index_failed = et_index_failed
          it_node_data    = <lt_node_data>
          ig_param        = <lg_param>.
    ENDIF.
  ENDIF.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name      = iv_node_name
        it_node_id        = <lt_node_id>
        it_node_data_out  = <lt_node_data>
        it_index_failed   = et_index_failed
        iv_operation_type = /plmb/if_mdp_c=>gs_c_operation_type-action
        iv_operation_name = iv_action_name.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  IF ev_failed = abap_false.
    IF et_index_failed IS INITIAL.
      "Everything is fine.
      lv_sp_call_successful = abap_true.
    ELSE.
      "Check if all recods failed.
      IF lines( <lt_node_id> ) > lines( et_index_failed ).
        lv_sp_call_successful = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

*--- Node Invalidation based on side-effects --------------------------*
  IF lv_sp_call_successful = abap_true.
    IF lv_save_relevant = abap_true.
      IF gv_unsaved_data = abap_false.
        RAISE EVENT unsaved_data_exists
          EXPORTING
            iv_unsaved_data_exists = abap_true.
      ENDIF.
      gv_unsaved_data = mv_unsaved_data = abap_true.
    ENDIF.

    "Get side-effect.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_action_details
      EXPORTING
        iv_action_name = iv_action_name
      IMPORTING
        ev_sideeffect  = lv_sideeffect.
    "Invalidate nodes.
    CALL METHOD mo_collector_in->invalidate_nodes_by_sideeffect
      EXPORTING
        iv_node_name  = iv_node_name
        iv_sideeffect = lv_sideeffect.

    IF et_node_data IS NOT INITIAL.
      "Create container for invalid node ID.
      CREATE DATA lr_succeeded_node_id LIKE <lt_node_id>.
      ASSIGN lr_succeeded_node_id->* TO <lt_succeeded_node_id>.
      CALL METHOD get_succeeded_records
        EXPORTING
          it_node_data         = et_node_data
        IMPORTING
          et_succeeded_node_id = <lt_succeeded_node_id>.

      CALL METHOD invalidate_node_id_implicit
        EXPORTING
          iv_node_name = iv_node_name
          it_node_id   = <lt_succeeded_node_id>
          iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-update.
    ENDIF.
  ENDIF.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          iv_action_name
                                          <lt_node_id>
                                          <ls_param>
                                          ev_failed
                                          et_index_failed
                                          et_node_data
                                          eg_param
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            iv_action_name
                                            <lt_node_id>
                                            <ls_param>
                                            sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~check_before_save.

  DATA:
    ls_instance              TYPE ys_instance,
    lt_instance              TYPE SORTED TABLE OF ys_instance
                                  WITH UNIQUE KEY abbid.

  DATA:
    lb_transaction           TYPE REF TO /plmb/ex_spi_transaction.

  CLEAR: ev_failed.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Call service provider 'check_before_save'.
  LOOP AT gt_instance INTO ls_instance.
    IF ls_instance-connector->ms_control_options-transient = abap_true.
      "the instance is transient
      CONTINUE.
    ENDIF.

    READ TABLE lt_instance WITH TABLE KEY abbid = ls_instance-abbid
                           TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      "ABBID was already processed
      CONTINUE.
    ENDIF.
    INSERT ls_instance INTO TABLE lt_instance.

    CALL METHOD increase_callstack
      EXPORTING
        io_connector     = ls_instance-connector
        iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-check_before_save.

    ls_instance-connector->mo_sp->check_before_save(
      IMPORTING ev_failed = ev_failed ).

    IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
      TRY.
          GET BADI lb_transaction
            FILTERS
              application_building_block = ls_instance-abbid.
        CATCH cx_badi.                                  "#EC NO_HANDLER
      ENDTRY.
    ELSE.
      "Two system scenario
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      EXIT.
    ENDIF.

    IF ( lb_transaction IS BOUND ).
      "After Perform checks before save
      CALL BADI lb_transaction->after_check_before_save
        EXPORTING
          iv_abbid     = ls_instance-abbid
          io_collector = ls_instance-connector->mo_collector_in
        CHANGING
          cv_failed    = ev_failed.
    ENDIF.

    CALL METHOD decrease_callstack.
    "Collect field properties
    /plmb/cl_spi_collector=>set_field_properties( ).
    "Collect operation properties
    /plmb/cl_spi_collector=>set_operation_properties( ).

    "Expert mode
    LOG-POINT ID /plmb/spi_data_flow FIELDS ls_instance-abbid
                                            ev_failed
                                            sy-uname.

    IF ev_failed IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF ev_failed IS NOT INITIAL.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_false ).
  ELSE.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_true ).
    gv_check_before_save = abap_true.
  ENDIF.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~clean_up.

  DATA:
    lt_invalid_node          TYPE /plmb/t_spi_coll_invalid_node,
    ls_invalid_node          TYPE /plmb/s_spi_coll_invalid_node,
    ls_instance              TYPE ys_instance,
    lt_instance              TYPE SORTED TABLE OF ys_instance
                                  WITH UNIQUE KEY abbid.

  DATA:
    lb_transaction           TYPE REF TO /plmb/ex_spi_transaction.

  CLEAR: lt_instance.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Call service provider 'Cleanup'
  LOOP AT gt_instance INTO ls_instance.

    CLEAR: ls_instance-connector->mv_unsaved_data.

    READ TABLE lt_instance WITH TABLE KEY abbid = ls_instance-abbid
                           TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      "ABBID was already processed
      CONTINUE.
    ENDIF.
    INSERT ls_instance INTO TABLE lt_instance.

    CALL METHOD increase_callstack
      EXPORTING
        io_connector     = ls_instance-connector
        iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-cleanup.

    ls_instance-connector->mo_sp->clean_up(
      EXPORTING iv_reason = iv_reason ).

    IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
      TRY.
          GET BADI lb_transaction
            FILTERS
              application_building_block = ls_instance-abbid.
        CATCH cx_badi.                                  "#EC NO_HANDLER
      ENDTRY.
    ELSE.
      "Two system scenario
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      EXIT.
    ENDIF.

    IF ( lb_transaction IS BOUND ).
      "After Perform clean up (e. g. release all locks)
      CALL BADI lb_transaction->after_clean_up
        EXPORTING
          iv_abbid     = ls_instance-abbid
          iv_reason    = iv_reason
          io_collector = ls_instance-connector->mo_collector_in.
    ENDIF.

    CALL METHOD decrease_callstack.
    "Collect field properties
    /plmb/cl_spi_collector=>set_field_properties( ).
    "Collect operation properties
    /plmb/cl_spi_collector=>set_operation_properties( ).

    "Expert mode
    LOG-POINT ID /plmb/spi_data_flow FIELDS ls_instance-abbid
                                            iv_reason
                                            sy-uname.

    ls_invalid_node-abbid = ls_instance-abbid.
    INSERT ls_invalid_node INTO TABLE lt_invalid_node.
  ENDLOOP.

  CALL METHOD ls_instance-connector->mo_collector_in->spread_invalid_node
    EXPORTING
      it_invalid_node   = lt_invalid_node
      iv_exclude_myself = abap_false.

  CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_true ).

  IF gv_unsaved_data = abap_true.
    RAISE EVENT unsaved_data_exists
      EXPORTING
        iv_unsaved_data_exists = abap_false.
    CLEAR: gv_unsaved_data.
  ENDIF.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS iv_reason sy-uname.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_false.
    RETURN.
  ENDIF.

  IF iv_reason = /plmb/if_spi_c=>gs_c_cleanup_reason-rollback.
    "Rollback work always in back-end system
    ROLLBACK WORK.
  ENDIF.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~delete.

  DATA:
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lr_node_id_table         TYPE REF TO data,  "Container for the IDs
    lr_succeeded_node_id     TYPE REF TO data,  "Container for the IDs table
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lv_save_relevant         TYPE boole_d,
    lv_version               TYPE /plmb/spi_metadata_version,
    lv_sideeffect            TYPE /plmb/spi_sideeffect,
    lv_sp_call_successful    TYPE boole_d.

  FIELD-SYMBOLS:
    <lt_node_id>             TYPE INDEX TABLE,
    <lt_succeeded_node_id>   TYPE INDEX TABLE.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_index_failed.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-delete.

  "Check import parameter.
  IF iv_node_name IS INITIAL.
    "Node name mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_node_name
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-delete
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.
  IF it_node_id IS INITIAL.
    "Node data mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_id
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-delete
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = it_node_id ) = abap_false.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
          parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_id
          method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-delete
          abbid          = mv_abbid
          node_name      = iv_node_name.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).
  IF lv_version > /plmb/if_mdp_c=>gs_c_version-version_702.
    "Check if operation is supported according to metadata.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
      IMPORTING
        ev_delete = ls_operation_category-delete.
    IF ls_operation_category-delete IS INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid             = /plmb/cx_spi_error=>operation_not_supported
          abbid              = mv_abbid
          node_name          = iv_node_name
          operation_category = /plmb/if_spi_c=>gs_c_operation_category-delete.
    ENDIF.
  ENDIF.

  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_transient( ) = abap_false.
    "CHECK_BEFORE_SAVE needs to be called again before calling SAVE.
    CLEAR: gv_check_before_save.
    IF ms_control_options-transient = abap_true.
      "Upon instantiation the SP instance was marked as transient,
      "so save relevant operations are forbidden
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>save_rel_operation_prohibited
          abbid  = mv_abbid.
    ENDIF.
    lv_save_relevant = abap_true.
  ENDIF.

  TRY .
      "Get a container for IT_NODE_ID
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
        IMPORTING
          er_id_table = lr_node_id_table.
      ASSIGN lr_node_id_table->* TO <lt_node_id>.
      <lt_node_id> = it_node_id.
    CATCH /plmb/cx_spi_metadata.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid    = /plmb/cx_spi_error=>node_typization_insufficient
          abbid     = mv_abbid
          node_name = iv_node_name.
  ENDTRY.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = iv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before Delete ----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_delete
      EXPORTING
        iv_abbid     = mv_abbid
        iv_node_name = iv_node_name
        io_collector = mo_collector_in
        io_metadata  = mo_mp
      CHANGING
        ct_node_id   = <lt_node_id>.

    CALL BADI lb_appl_access->before_delete
      EXPORTING
        iv_abbid         = mv_abbid
        iv_node_name     = iv_node_name
        it_node_id       = <lt_node_id>
        io_collector     = mo_collector_in
        io_metadata      = mo_mp
      CHANGING
        cv_skip_standard = mv_bypass_service_provider
        cv_failed        = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      RETURN.
    ENDIF.
  ENDIF.

*--- Call Delete ------------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    mo_sp->delete(
      EXPORTING iv_node_name    = iv_node_name
                it_node_id      = <lt_node_id>
      IMPORTING ev_failed       = ev_failed
                et_index_failed = et_index_failed ).

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->delete
        EXPORTING
          iv_node_name    = iv_node_name
          it_node_id      = <lt_node_id>
          iv_failed       = ev_failed
          it_index_failed = et_index_failed.
    ENDIF.
  ENDIF.

*--- After Delete -----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->after_delete
      EXPORTING
        iv_abbid        = mv_abbid
        iv_node_name    = iv_node_name
        it_node_id      = <lt_node_id>
        io_collector    = mo_collector_in
        io_metadata     = mo_mp
      CHANGING
        cv_failed       = ev_failed
        ct_index_failed = et_index_failed.

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->delete
        EXPORTING
          iv_node_name    = iv_node_name
          it_node_id      = <lt_node_id>
          iv_failed       = ev_failed
          it_index_failed = et_index_failed.
    ENDIF.
  ENDIF.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name      = iv_node_name
        it_node_id        = <lt_node_id>
        it_index_failed   = et_index_failed
        iv_operation_type = /plmb/if_mdp_c=>gs_c_operation_type-delete.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  IF ev_failed = abap_false.
    IF et_index_failed IS INITIAL.
      "Everything is fine.
      lv_sp_call_successful = abap_true.
    ELSE.
      "Check if all recods failed.
      IF lines( <lt_node_id> ) > lines( et_index_failed ).
        lv_sp_call_successful = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

*--- Node Invalidation based on side-effects --------------------------*
  IF lv_sp_call_successful = abap_true.
    IF lv_save_relevant = abap_true.
      IF gv_unsaved_data = abap_false.
        RAISE EVENT unsaved_data_exists
          EXPORTING
            iv_unsaved_data_exists = abap_true.
      ENDIF.
      gv_unsaved_data = mv_unsaved_data = abap_true.
    ENDIF.

    "Get side-effect.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_delete_details
      IMPORTING
        ev_sideeffect = lv_sideeffect.
    "Invalidate nodes.
    CALL METHOD mo_collector_in->invalidate_nodes_by_sideeffect
      EXPORTING
        iv_node_name  = iv_node_name
        iv_sideeffect = lv_sideeffect.

    "Create container for invalid node ID.
    CREATE DATA lr_succeeded_node_id LIKE <lt_node_id>.
    ASSIGN lr_succeeded_node_id->* TO <lt_succeeded_node_id>.
    CALL METHOD get_succeeded_records
      EXPORTING
        it_node_id           = <lt_node_id>
        it_index_failed      = et_index_failed
      IMPORTING
        et_succeeded_node_id = <lt_succeeded_node_id>.

    CALL METHOD invalidate_node_id_implicit
      EXPORTING
        iv_node_name = iv_node_name
        it_node_id   = <lt_succeeded_node_id>
        iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-delete.
  ENDIF.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          <lt_node_id>
                                          ev_failed
                                          et_index_failed
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            <lt_node_id>
                                            sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~insert.

  DATA:
    lr_node_data_table       TYPE REF TO data,
    lr_node_data_in_table    TYPE REF TO data,
    lr_node_id_structure     TYPE REF TO data,
    lr_import_struc_container TYPE REF TO data,
    lr_succeeded_node_id     TYPE REF TO data,  "Container for the IDs table
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lo_metadata_node_parent  TYPE REF TO /plmb/cl_spi_metadata_node,
    lv_node_name             TYPE /plmb/spi_node_name,
    lt_generic_type          TYPE /plmb/t_spi_generic_type_def,
    ls_generic_type          TYPE /plmb/s_spi_generic_type_def,
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lv_save_relevant         TYPE boole_d,
    lv_version               TYPE /plmb/spi_metadata_version,
    lv_sideeffect            TYPE /plmb/spi_sideeffect,
    lv_sp_call_successful    TYPE boole_d.

  FIELD-SYMBOLS:
    <lt_node_data>           TYPE INDEX TABLE,
    <lt_node_data_in>        TYPE INDEX TABLE,
    <lt_succeeded_node_id>   TYPE INDEX TABLE,
    <ls_node_id>             TYPE any,
    <ls_param>               TYPE any.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_index_failed,
    et_node_data,
    et_node_id_rel.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-insert.

  "Determine target node name.
  lv_node_name = mo_mp->/plmb/if_spi_metadata_output~determine_target_node(
    iv_node_name         = iv_node_name
    iv_target_node_name  = iv_target_node_name
    iv_check_consistency = abap_true ).

  "Check import parameter.
  IF it_node_data IS INITIAL.
    "Node data mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_data
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
        abbid          = mv_abbid
        node_name      = lv_node_name.
  ENDIF.
  IF iv_target_node_name IS INITIAL
    AND is_node_id IS NOT INITIAL.
    "Node ID is only meaningful for an INSERT BY ASSOCIATION!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_node_id
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
        abbid          = mv_abbid
        node_name      = lv_node_name.
  ENDIF.

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
  IF iv_target_node_name IS NOT INITIAL.
    TRY.
        lo_metadata_node_parent ?= lo_metadata_node->/plmb/if_spi_metadata_node~get_parent( ).
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_target_node_name
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
            abbid          = mv_abbid
            node_name      = lv_node_name.
    ENDTRY.
  ENDIF.

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF    iv_target_node_name IS NOT INITIAL
      AND is_supplied( is_node_id ) = abap_true.
      IF lo_metadata_node_parent->/plmb/if_spi_node_check~applies_to_id_struc( is_data = is_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
            abbid          = mv_abbid
            node_name      = lv_node_name.
      ENDIF.
    ENDIF.
    IF is_supplied( is_param ) = abap_true.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_insert_struc( is_data = is_param ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_param
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
            abbid          = mv_abbid
            node_name      = lv_node_name.
      ENDIF.
    ENDIF.
    IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = it_node_data ) = abap_false.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
          parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_data
          method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
          abbid          = mv_abbid
          node_name      = lv_node_name.
    ENDIF.
    IF et_node_data IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = et_node_data ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
            abbid          = mv_abbid
            node_name      = lv_node_name.
      ENDIF.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).
  IF lv_version > /plmb/if_mdp_c=>gs_c_version-version_702.
    "Check if operation is supported according to metadata.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
      IMPORTING
        ev_insert = ls_operation_category-insert.
    IF ls_operation_category-insert IS INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid             = /plmb/cx_spi_error=>operation_not_supported
          abbid              = mv_abbid
          node_name          = iv_node_name
          operation_category = /plmb/if_spi_c=>gs_c_operation_category-insert.
    ENDIF.
  ENDIF.

  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_transient( ) = abap_false.
    "CHECK_BEFORE_SAVE needs to be called again before calling SAVE.
    CLEAR: gv_check_before_save.
    IF ms_control_options-transient = abap_true.
      "Upon instantiation the SP instance was marked as transient,
      "so save relevant operations are forbidden
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>save_rel_operation_prohibited
          abbid  = mv_abbid.
    ENDIF.
    lv_save_relevant = abap_true.
  ENDIF.

  TRY.
      "Get a container for IT_NODE_DATA
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
        IMPORTING
          er_data_table = lr_node_data_in_table.
      ASSIGN lr_node_data_in_table->* TO <lt_node_data_in>.
      <lt_node_data_in> = it_node_data.
    CATCH /plmb/cx_spi_metadata.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid    = /plmb/cx_spi_error=>node_typization_insufficient
          abbid     = mv_abbid
          node_name = lv_node_name.
  ENDTRY.

  IF iv_target_node_name IS NOT INITIAL.
    TRY.
        "Get a container for IS_NODE_ID
        CALL METHOD lo_metadata_node_parent->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_structure = lr_node_id_structure.
        ASSIGN lr_node_id_structure->* TO <ls_node_id>.
        IF is_node_id IS NOT INITIAL.
          <ls_node_id> = is_node_id.
        ENDIF.
      CATCH /plmb/cx_spi_metadata.
        IF is_node_id IS NOT INITIAL.
          RAISE EXCEPTION TYPE /plmb/cx_spi_error
            EXPORTING
              textid    = /plmb/cx_spi_error=>node_typization_insufficient
              abbid     = mv_abbid
              node_name = iv_node_name.
        ENDIF.
        ASSIGN ls_generic_type TO <ls_node_id>.
    ENDTRY.
  ELSE.
    ASSIGN ls_generic_type TO <ls_node_id>.
  ENDIF.

  "Get a container for IS_PARAM
  CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_insert_details
    IMPORTING
      er_import_struc_container = lr_import_struc_container.
  IF lr_import_struc_container IS BOUND.
    ASSIGN lr_import_struc_container->* TO <ls_param>.
    IF is_param IS NOT INITIAL.
      <ls_param> = is_param.
    ENDIF.
  ELSEIF is_param IS NOT INITIAL.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-is_param
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-insert
        abbid          = mv_abbid
        node_name      = lv_node_name.
  ELSE.
    ASSIGN ls_generic_type TO <ls_param>.
  ENDIF.

  IF et_node_data IS SUPPLIED.
    ASSIGN et_node_data TO <lt_node_data>.
  ELSE.
    "Get a container for ET_NODE_DATA
    "Note: this is required to avoid type conflicts if consumer does not
    "      request the parameters but the service provider fills them
    TRY.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
          IMPORTING
            er_data_table = lr_node_data_table.
        ASSIGN lr_node_data_table->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        ASSIGN lt_generic_type TO <lt_node_data>.
    ENDTRY.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = lv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before Insert ----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_insert
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cs_node_id          = <ls_node_id>
        cs_param            = <ls_param>
        ct_node_data        = <lt_node_data_in>.

    CALL BADI lb_appl_access->before_insert
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        is_node_id          = <ls_node_id>
        is_param            = <ls_param>
        it_node_data        = <lt_node_data_in>
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cv_skip_standard    = mv_bypass_service_provider
        cv_failed           = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      RETURN.
    ENDIF.
  ENDIF.

*--- Call Insert ------------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    mo_sp->insert(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                is_node_id          = <ls_node_id>
                is_param            = <ls_param>
                it_node_data        = <lt_node_data_in>
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed
                et_node_data        = <lt_node_data>
                et_node_id_rel      = et_node_id_rel ).

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_data_in>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->insert
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          is_node_id          = <ls_node_id>
          is_param            = <ls_param>
          it_node_data        = <lt_node_data_in>
          iv_failed           = ev_failed
          it_index_failed     = et_index_failed
          it_node_data_e      = <lt_node_data>
          it_node_id_rel      = et_node_id_rel.
    ENDIF.
  ENDIF.

*--- After Insert -----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->after_insert
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        is_node_id          = <ls_node_id>
        is_param            = <ls_param>
        it_node_data        = <lt_node_data_in>
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cv_failed           = ev_failed
        ct_index_failed     = et_index_failed
        ct_node_data        = <lt_node_data>
        ct_node_id_rel      = et_node_id_rel.

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_data_in>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->insert
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          is_node_id          = <ls_node_id>
          is_param            = <ls_param>
          it_node_data        = <lt_node_data_in>
          iv_failed           = ev_failed
          it_index_failed     = et_index_failed
          it_node_data_e      = <lt_node_data>
          it_node_id_rel      = et_node_id_rel.
    ENDIF.
  ENDIF.

  "Trim source/target relation table.
  CALL METHOD mo_appl_access_check->trim_node_id_rel
    EXPORTING
      iv_node_name    = lv_node_name
      iv_method_name  = /plmb/if_spi_c_internal=>gs_c_method_name-insert
      iv_check_errors = ms_control_options-data_flow_check_errors
    CHANGING
      ct_node_id_rel  = et_node_id_rel.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        it_node_data_out    = <lt_node_data>
        it_node_data_in     = <lt_node_data_in>
        it_index_failed     = et_index_failed
        iv_operation_type   = /plmb/if_mdp_c=>gs_c_operation_type-insert.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  IF ev_failed = abap_false.
    IF et_index_failed IS INITIAL.
      "Everything is fine.
      lv_sp_call_successful = abap_true.
    ELSE.
      "Check if all recods failed.
      IF lines( <lt_node_data_in> ) > lines( et_index_failed ).
        lv_sp_call_successful = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

*--- Node Invalidation based on side-effects --------------------------*
  IF lv_sp_call_successful = abap_true.
    IF lv_save_relevant = abap_true.
      IF gv_unsaved_data = abap_false.
        RAISE EVENT unsaved_data_exists
          EXPORTING
            iv_unsaved_data_exists = abap_true.
      ENDIF.
      gv_unsaved_data = mv_unsaved_data = abap_true.
    ENDIF.

    "Get side-effect.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_insert_details
      IMPORTING
        ev_sideeffect = lv_sideeffect.
    "Invalidate nodes.
    CALL METHOD mo_collector_in->invalidate_nodes_by_sideeffect
      EXPORTING
        iv_node_name  = lv_node_name
        iv_sideeffect = lv_sideeffect.

    TRY.
        "Get a container for NODE_ID
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_table = lr_succeeded_node_id.
        ASSIGN lr_succeeded_node_id->* TO <lt_succeeded_node_id>.
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = lv_node_name.
    ENDTRY.

    CALL METHOD get_succeeded_records
      EXPORTING
        it_node_data         = <lt_node_data_in>
        it_index_failed      = et_index_failed
      IMPORTING
        et_succeeded_node_id = <lt_succeeded_node_id>.

    CALL METHOD invalidate_node_id_implicit
      EXPORTING
        iv_node_name = lv_node_name
        it_node_id   = <lt_succeeded_node_id>
        iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-insert.
  ENDIF.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          iv_target_node_name
                                          <ls_node_id>
                                          <ls_param>
                                          <lt_node_data_in>
                                          ev_failed
                                          et_index_failed
                                          et_node_data
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            iv_target_node_name
                                            <ls_node_id>
                                            <ls_param>
                                            <lt_node_data_in>
                                            sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~query.

  DATA:
    lr_node_data_table       TYPE REF TO data,  "Container for the data table
    lr_node_id_table         TYPE REF TO data,  "Container for the ID table
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lt_generic_type          TYPE /plmb/t_spi_generic_type_def,
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lo_query_adapter         TYPE REF TO /plmb/if_spi_query_adapter,
    lt_f4_param_map          TYPE /plmb/t_spi_f4_param_map,
    lt_es_attr_map           TYPE /plmb/t_spi_es_attr_map,
    lr_data_table            TYPE REF TO data,   ""Container for the data table of query
    lr_filter_node_id        TYPE REF TO data,   ""Container for the node id table
    ls_options               TYPE /plmb/s_spi_query_options,
    lt_sel_param             TYPE /plmb/t_spi_selection_param,
    lv_keys_only             TYPE /plmb/spi_keys_only_ind,
    ls_f4_definition         TYPE /plmb/s_spi_f4_definition,
    ls_es_definition         TYPE /plmb/s_spi_es_definition,
    ls_sp_definition         TYPE /plmb/s_spi_sp_query,
    lt_queries               TYPE /plmb/t_spi_query_name_type,
    ls_query                 TYPE /plmb/s_spi_query_name_type,
    lt_requested_field       TYPE /plmb/t_spi_requested_field,
    lv_version               TYPE /plmb/spi_metadata_version.

  FIELD-SYMBOLS:
    <lt_node_id>             TYPE INDEX TABLE,
    <lt_node_data>           TYPE INDEX TABLE,
    <lt_filter_node_id>      TYPE INDEX TABLE,
    <lt_mapping>             TYPE ANY TABLE,
    <ls_query_definition>    TYPE any.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_node_data,
    et_node_id,
    et_node_id_rel.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-query.

  "Check import parameter.
  IF iv_node_name IS INITIAL.
    "Node name mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>mandatory_parameter_initial
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_node_name
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF is_supplied( it_filter_node_id ) = abap_true.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = it_filter_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_filter_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
            abbid          = mv_abbid
            node_name      = iv_node_name.

      ENDIF.
    ENDIF.
    IF et_node_id IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = et_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).

  ls_options         = is_options.
  lt_sel_param       = it_sel_param.
  lv_keys_only       = iv_keys_only.
  lt_requested_field = it_requested_field.

  TRY.
      "Get a container for IT_FILTER_NODE_ID
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
        IMPORTING
          er_id_table = lr_filter_node_id.
      ASSIGN lr_filter_node_id->* TO <lt_filter_node_id>.
      IF it_filter_node_id IS NOT INITIAL.
        <lt_filter_node_id> = it_filter_node_id.
      ENDIF.
    CATCH /plmb/cx_spi_metadata.
      IF it_filter_node_id IS NOT INITIAL.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = iv_node_name.
      ENDIF.
      ASSIGN lt_generic_type TO <lt_filter_node_id>.
  ENDTRY.

  IF et_node_id IS SUPPLIED.
    ASSIGN et_node_id TO <lt_node_id>.
  ELSE.
    "Get a container for ET_NODE_ID
    "Note: this is required to avoid type conflicts if consumer does not
    "      request the parameters but the service provider fills them
    TRY.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_table = lr_node_id_table.
        ASSIGN lr_node_id_table->* TO <lt_node_id>.
      CATCH /plmb/cx_spi_metadata.
        ASSIGN lt_generic_type TO <lt_node_id>.
    ENDTRY.
  ENDIF.

  IF lv_version = /plmb/if_mdp_c=>gs_c_version-version_702.
*--- Prepare 702 Query ------------------------------------------------*
    IF iv_query_name IS NOT INITIAL.
      "Query name mustn't be empty!
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>multiple_queries_not_supported
          abbid  = mv_abbid.
    ENDIF.

    "Get container for query result node data.
    IF et_node_data IS SUPPLIED.
      "Does the definition of dynamic parameter match to metadata
      IF   ms_control_options-data_flow_check_errors = abap_true
       AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
        IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = et_node_data ) = abap_false.
          RAISE EXCEPTION TYPE /plmb/cx_spi_error
            EXPORTING
              textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
              parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
              method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
              abbid          = mv_abbid
              node_name      = iv_node_name.
        ENDIF.
      ENDIF.
      ASSIGN et_node_data TO <lt_node_data>.
    ELSE.
      TRY .
          CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
            IMPORTING
              er_data_table = lr_node_data_table.
          ASSIGN lr_node_data_table->* TO <lt_node_data>.
        CATCH /plmb/cx_spi_metadata.
          ASSIGN lt_generic_type TO <lt_node_data>.
      ENDTRY.
    ENDIF.

  ELSE.
*--- Prepare 703 query ------------------------------------------------*
    IF iv_query_name IS INITIAL.
      "Query name mustn't be empty!
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
          parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_query_name
          method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
          abbid          = mv_abbid
          node_name      = iv_node_name.
    ENDIF.

    "Check if query is supported by SP.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
      IMPORTING
        ev_query = ls_operation_category-query.
    IF ls_operation_category-query IS INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid             = /plmb/cx_spi_error=>operation_not_supported
          abbid              = mv_abbid
          node_name          = iv_node_name
          operation_category = /plmb/if_spi_c=>gs_c_operation_category-query.
    ENDIF.

    "Get query type.
    CALL METHOD lo_metadata_node->get_query_with_type
      IMPORTING
        et_queries = lt_queries.
    READ TABLE lt_queries INTO ls_query
      WITH TABLE KEY query_name = iv_query_name.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid     = /plmb/cx_spi_error=>query_name_unknown
          abbid      = mv_abbid
          node_name  = iv_node_name
          query_name = iv_query_name.
    ENDIF.

    IF et_node_data IS SUPPLIED.
      "Does the definition of dynamic parameter match to metadata
      IF   ms_control_options-data_flow_check_errors = abap_true
       AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
        IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_query_result_ttype(
            iv_query_name = iv_query_name
            it_data       = et_node_data ) = abap_false.
          RAISE EXCEPTION TYPE /plmb/cx_spi_error
            EXPORTING
              textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
              parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
              method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-query
              abbid          = mv_abbid
              node_name      = iv_node_name.
        ENDIF.
      ENDIF.
      ASSIGN et_node_data TO <lt_node_data>.
    ELSE.
      "Get a container for ET_NODE_DATA
      "Note: this is required to avoid type conflicts if consumer does not
      "      request the parameters but the service provider fills them
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_query_details
        EXPORTING
          iv_query_name             = iv_query_name
        IMPORTING
          er_result_table_container = lr_data_table.
      IF lr_data_table IS BOUND.
        ASSIGN lr_data_table->* TO <lt_node_data>.
      ELSE.
        ASSIGN lt_generic_type TO <lt_node_data>.
      ENDIF.
    ENDIF.

    IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
      IF ls_query-query_type NE /plmb/cl_spi_metadata_output=>gs_c_query_type-sp.
        "Get query adapter.
        CALL METHOD /plmb/cl_spi_query_factory=>get_adapter
          EXPORTING
            iv_query_type    = ls_query-query_type
          RECEIVING
            ro_query_adapter = lo_query_adapter.

        CASE ls_query-query_type.
          WHEN /plmb/cl_spi_metadata_output=>gs_c_query_type-es.
            CALL METHOD lo_metadata_node->get_query_details_es
              EXPORTING
                iv_query_name    = iv_query_name
              IMPORTING
                et_es_attr_map   = lt_es_attr_map
                es_es_definition = ls_es_definition.

            ASSIGN ls_es_definition TO <ls_query_definition>.
            ASSIGN lt_es_attr_map   TO <lt_mapping>.

          WHEN /plmb/cl_spi_metadata_output=>gs_c_query_type-f4.
            CALL METHOD lo_metadata_node->get_query_details_f4
              EXPORTING
                iv_query_name    = iv_query_name
              IMPORTING
                et_f4_param_map  = lt_f4_param_map
                es_f4_definition = ls_f4_definition.

            ASSIGN ls_f4_definition TO <ls_query_definition>.
            ASSIGN lt_f4_param_map  TO <lt_mapping>.

        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = iv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before query -----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_query
      EXPORTING
        iv_abbid           = mv_abbid
        iv_node_name       = iv_node_name
        iv_query_name      = iv_query_name
        io_collector       = mo_collector_in
        io_metadata        = mo_mp
      CHANGING
        cs_options         = ls_options
        ct_sel_param       = lt_sel_param
        ct_filter_node_id  = <lt_filter_node_id>
        cv_keys_only       = lv_keys_only
        ct_requested_field = lt_requested_field.

    CALL BADI lb_appl_access->before_query
      EXPORTING
        iv_abbid           = mv_abbid
        iv_node_name       = iv_node_name
        iv_query_name      = iv_query_name
        is_options         = ls_options
        it_sel_param       = lt_sel_param
        it_filter_node_id  = <lt_filter_node_id>
        iv_keys_only       = lv_keys_only
        it_requested_field = lt_requested_field
        io_collector       = mo_collector_in
        io_metadata        = mo_mp
      CHANGING
        cv_skip_standard   = mv_bypass_service_provider
        cv_failed          = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      RETURN.
    ENDIF.
  ENDIF.

  IF   iv_query_name IS NOT INITIAL
   AND ls_query-query_type = /plmb/cl_spi_metadata_output=>gs_c_query_type-sp.
    "Check parameter consistency of SP query.
    CALL METHOD lo_metadata_node->get_query_details_sp
      EXPORTING
        iv_query_name    = iv_query_name
      IMPORTING
        es_sp_definition = ls_sp_definition.
    IF   NOT <lt_filter_node_id>       IS INITIAL AND ls_sp_definition-filter_node_id_supported = abap_false
      OR NOT ls_options-sortorder      IS INITIAL AND ls_sp_definition-sorting_supported        = abap_false
      OR NOT ls_options-number_of_rows IS INITIAL AND ls_sp_definition-paging_supported         = /plmb/if_spi_c=>gs_c_paging_supported-paging_not_supported
      OR NOT ls_options-start_row      IS INITIAL AND ls_sp_definition-paging_supported        <> /plmb/if_spi_c=>gs_c_paging_supported-paging_supported.
      "Query parameter not supported.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid     = /plmb/cx_spi_error=>query_parameter_not_supported
          abbid      = mv_abbid
          node_name  = iv_node_name
          query_name = iv_query_name.
    ENDIF.
  ENDIF.

*--- Call query -------------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    IF lo_query_adapter IS BOUND.
      "Call adapter
      CALL METHOD lo_query_adapter->query
        EXPORTING
          is_query_definition = <ls_query_definition>
          it_selection        = lt_sel_param
          is_options          = ls_options
          iv_keys_only        = lv_keys_only
          it_node_id_filter   = <lt_filter_node_id>
          it_mapping          = <lt_mapping>
          io_collector        = mo_collector_in
        IMPORTING
          ev_failed           = ev_failed
          et_node_id          = <lt_node_id>
          et_node_data        = <lt_node_data>
          et_node_id_rel      = et_node_id_rel.
    ELSE.
      "Call Service Provider
      CALL METHOD mo_sp->query(
        EXPORTING
          iv_node_name       = iv_node_name
          iv_query_name      = iv_query_name
          is_options         = ls_options
          it_sel_param       = lt_sel_param
          iv_keys_only       = lv_keys_only
          it_filter_node_id  = <lt_filter_node_id>
          it_requested_field = lt_requested_field
        IMPORTING
          ev_failed          = ev_failed
          et_node_id         = <lt_node_id>
          et_node_data       = <lt_node_data>
          et_node_id_rel     = et_node_id_rel ).
    ENDIF.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->query
        EXPORTING
          iv_node_name       = iv_node_name
          iv_query_name      = iv_query_name
          is_options         = ls_options
          it_sel_param       = lt_sel_param
          iv_keys_only       = lv_keys_only
          it_filter_node_id  = <lt_filter_node_id>
          it_requested_field = lt_requested_field
          iv_failed          = ev_failed
          it_node_id         = <lt_node_id>
          it_node_data       = <lt_node_data>
          it_node_id_rel     = et_node_id_rel.
    ENDIF.
  ENDIF.

*--- After query ------------------------------------------------------*
  IF lb_appl_access IS BOUND.

    CALL BADI lb_appl_access->after_query
      EXPORTING
        iv_abbid           = mv_abbid
        iv_node_name       = iv_node_name
        iv_query_name      = iv_query_name
        is_options         = ls_options
        it_sel_param       = lt_sel_param
        it_filter_node_id  = <lt_filter_node_id>
        iv_keys_only       = lv_keys_only
        it_requested_field = lt_requested_field
        io_collector       = mo_collector_in
        io_metadata        = mo_mp
      CHANGING
        cv_failed          = ev_failed
        ct_node_id         = <lt_node_id>
        ct_node_data       = <lt_node_data>
        ct_node_id_rel     = et_node_id_rel.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->query
        EXPORTING
          iv_node_name       = iv_node_name
          iv_query_name      = iv_query_name
          is_options         = ls_options
          it_sel_param       = lt_sel_param
          iv_keys_only       = lv_keys_only
          it_filter_node_id  = <lt_filter_node_id>
          it_requested_field = lt_requested_field
          iv_failed          = ev_failed
          it_node_id         = <lt_node_id>
          it_node_data       = <lt_node_data>
          it_node_id_rel     = et_node_id_rel.
    ENDIF.
  ENDIF.

  "Trim source/target relation table.
  CALL METHOD mo_appl_access_check->trim_node_id_rel
    EXPORTING
      iv_node_name    = iv_node_name
      iv_method_name  = /plmb/if_spi_c_internal=>gs_c_method_name-query
      iv_check_errors = ms_control_options-data_flow_check_errors
    CHANGING
      ct_node_id_rel  = et_node_id_rel.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name      = iv_node_name
        it_node_data_out  = <lt_node_data>
        iv_operation_type = /plmb/if_mdp_c=>gs_c_operation_type-query
        iv_operation_name = iv_query_name.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  IF ev_failed IS NOT INITIAL.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_false ).
  ELSE.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_true ).
  ENDIF.
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          ls_options
                                          lt_sel_param
                                          lv_keys_only
                                          ev_failed
                                          et_node_id
                                          et_node_data
                                          et_node_id_rel
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            ls_options
                                            lt_sel_param
                                            lv_keys_only
                                            sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~retrieve.

  DATA:
    lr_node_data_table       TYPE REF TO data,  "Container for the data table
    lr_node_id_table         TYPE REF TO data,  "Container for the IDs table
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lo_metadata_node_parent  TYPE REF TO /plmb/cl_spi_metadata_node,
    lr_succeeded_node_id     TYPE REF TO data,  "Container for the IDs table
    lv_node_name             TYPE /plmb/spi_node_name,
    lt_generic_type          TYPE /plmb/t_spi_generic_type_def,
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lv_version               TYPE /plmb/spi_metadata_version,
    lt_requested_field       TYPE /plmb/t_spi_requested_field,
    lv_lock                  TYPE /plmb/spi_lock_ind,
    lv_sp_call_successful    TYPE boole_d.

  FIELD-SYMBOLS:
    <lt_node_data>           TYPE INDEX TABLE,
    <lt_node_id>             TYPE INDEX TABLE,
    <lt_succeeded_node_id>   TYPE INDEX TABLE.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_node_data,
    et_node_id_rel,
    et_index_failed.

  IF it_node_id IS INITIAL.
    "Nothing to do.
    RETURN.
  ENDIF.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-retrieve.

  "Determine target node name.
  lv_node_name = mo_mp->/plmb/if_spi_metadata_output~determine_target_node(
    iv_node_name                   = iv_node_name
    iv_target_node_name            = iv_target_node_name
    iv_check_consistency           = abap_true
    iv_association_intern_consider = abap_true ).

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
  IF iv_target_node_name IS NOT INITIAL.
    TRY.
        lo_metadata_node_parent ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_target_node_name
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-retrieve
            abbid          = mv_abbid
            node_name      = iv_node_name.
    ENDTRY.
  ENDIF.

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF iv_target_node_name IS NOT INITIAL.
      IF lo_metadata_node_parent->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = it_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-retrieve
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ELSE.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_id_ttype( it_data = it_node_id ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_id
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-retrieve
            abbid          = mv_abbid
            node_name      = lv_node_name.
      ENDIF.
    ENDIF.
    IF et_node_data IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = et_node_data ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-retrieve
            abbid          = mv_abbid
            node_name      = lv_node_name.
      ENDIF.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).
  IF lv_version > /plmb/if_mdp_c=>gs_c_version-version_702.
    "Check if operation is supported according to metadata.
    IF iv_target_node_name IS INITIAL.
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
        IMPORTING
          ev_retrieve = ls_operation_category-retrieve.
      IF ls_operation_category-retrieve IS INITIAL.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid             = /plmb/cx_spi_error=>operation_not_supported
            abbid              = mv_abbid
            node_name          = iv_node_name
            operation_category = /plmb/if_spi_c=>gs_c_operation_category-retrieve.
      ENDIF.
    ELSE.
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
        IMPORTING
          ev_retrieve_by_association = ls_operation_category-retrieve_by_association.
      IF ls_operation_category-retrieve_by_association IS INITIAL.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid             = /plmb/cx_spi_error=>operation_not_supported
            abbid              = mv_abbid
            node_name          = iv_node_name
            operation_category = /plmb/if_spi_c=>gs_c_operation_category-retrieve_by_association.
      ENDIF.
    ENDIF.
  ENDIF.

  lt_requested_field = it_requested_field.
  lv_lock            = iv_lock.

  TRY.
      "Get a container for IT_NODE_ID
      IF iv_target_node_name IS NOT INITIAL.
        CALL METHOD lo_metadata_node_parent->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_table = lr_node_id_table.
      ELSE.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_table = lr_node_id_table.
      ENDIF.
      ASSIGN lr_node_id_table->* TO <lt_node_id>.
      <lt_node_id> = it_node_id.
    CATCH /plmb/cx_spi_metadata.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid    = /plmb/cx_spi_error=>node_typization_insufficient
          abbid     = mv_abbid
          node_name = lv_node_name.
  ENDTRY.

  IF et_node_data IS SUPPLIED.
    ASSIGN et_node_data TO <lt_node_data>.
  ELSE.
    "Get a container for ET_NODE_DATA
    "Note: this is required to avoid type conflicts if consumer does not
    "      request the parameters but the service provider fills them
    TRY.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
          IMPORTING
            er_data_table = lr_node_data_table.
        ASSIGN lr_node_data_table->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        ASSIGN lt_generic_type TO <lt_node_data>.
    ENDTRY.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = lv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before Retrieve --------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_retrieve
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        iv_association_name = iv_association_name
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cv_lock             = lv_lock
        ct_node_id          = <lt_node_id>
        ct_requested_field  = lt_requested_field.

    CALL BADI lb_appl_access->before_retrieve
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        iv_association_name = iv_association_name
        iv_lock             = lv_lock
        it_node_id          = <lt_node_id>
        it_requested_field  = lt_requested_field
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cv_skip_standard    = mv_bypass_service_provider
        cv_failed           = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      RETURN.
    ENDIF.
  ENDIF.

*--- Call Retrieve ----------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    mo_sp->retrieve(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                iv_association_name = iv_association_name
                iv_lock             = lv_lock
                it_node_id          = <lt_node_id>
                it_requested_field  = lt_requested_field
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed
                et_node_data        = <lt_node_data>
                et_node_id_rel      = et_node_id_rel ).

    CALL METHOD check_rtr_index_failed
      EXPORTING
        iv_node_name    = lv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->retrieve
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          iv_association_name = iv_association_name
          iv_lock             = lv_lock
          it_node_id          = <lt_node_id>
          it_requested_field  = lt_requested_field
          iv_failed           = ev_failed
          it_index_failed     = et_index_failed
          it_node_data        = <lt_node_data>
          it_node_id_rel      = et_node_id_rel.
    ENDIF.
  ENDIF.

*--- After Retrieve ---------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->after_retrieve
      EXPORTING
        iv_abbid            = mv_abbid
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        iv_association_name = iv_association_name
        iv_lock             = lv_lock
        it_node_id          = <lt_node_id>
        it_requested_field  = lt_requested_field
        io_collector        = mo_collector_in
        io_metadata         = mo_mp
      CHANGING
        cv_failed           = ev_failed
        ct_index_failed     = et_index_failed
        ct_node_data        = <lt_node_data>
        ct_node_id_rel      = et_node_id_rel.

    CALL METHOD check_rtr_index_failed
      EXPORTING
        iv_node_name    = lv_node_name
        it_data         = <lt_node_id>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->retrieve
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          iv_association_name = iv_association_name
          iv_lock             = lv_lock
          it_node_id          = <lt_node_id>
          it_requested_field  = lt_requested_field
          iv_failed           = ev_failed
          it_index_failed     = et_index_failed
          it_node_data        = <lt_node_data>
          it_node_id_rel      = et_node_id_rel.
    ENDIF.
  ENDIF.

  "Trim source/target relation table.
  CALL METHOD mo_appl_access_check->trim_node_id_rel
    EXPORTING
      iv_node_name    = lv_node_name
      iv_method_name  = /plmb/if_spi_c_internal=>gs_c_method_name-retrieve
      iv_check_errors = ms_control_options-data_flow_check_errors
    CHANGING
      ct_node_id_rel  = et_node_id_rel.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name        = iv_node_name
        iv_target_node_name = iv_target_node_name
        it_node_id          = <lt_node_id>
        it_node_data_out    = <lt_node_data>
        it_index_failed_rtr = et_index_failed
        iv_operation_type   = /plmb/if_mdp_c=>gs_c_operation_type-retrieve.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  IF ev_failed = abap_false.
    IF et_index_failed IS INITIAL.
      "Everything is fine.
      lv_sp_call_successful = abap_true.
    ELSE.
      "Check if all recods failed.
      IF lines( <lt_node_id> ) > lines( et_index_failed ).
        lv_sp_call_successful = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

  "Node Invalidation
  IF   lv_sp_call_successful = abap_true
   AND lv_lock IS NOT INITIAL.
    "Create container for invalid node ID.
    CREATE DATA lr_succeeded_node_id LIKE <lt_node_id>.
    ASSIGN lr_succeeded_node_id->* TO <lt_succeeded_node_id>.
    CALL METHOD get_succeeded_records
      EXPORTING
        it_node_id           = <lt_node_id>
        it_index_failed_rtr  = et_index_failed
      IMPORTING
        et_succeeded_node_id = <lt_succeeded_node_id>.

    CALL METHOD invalidate_node_id_implicit
      EXPORTING
        iv_node_name = iv_node_name
        it_node_id   = <lt_succeeded_node_id>
        iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-lock.

    IF iv_target_node_name IS NOT INITIAL.
      CALL METHOD invalidate_node_id_implicit
        EXPORTING
          iv_node_name = iv_target_node_name
          iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-lock.
    ENDIF.
  ENDIF.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          iv_target_node_name
                                          lv_lock
                                          <lt_node_id>
                                          ev_failed
                                          et_index_failed
                                          et_node_data
                                          et_node_id_rel
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            iv_target_node_name
                                            lv_lock
                                            <lt_node_id>
                                            sy-uname.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~save.

  DATA:
    ls_instance              TYPE ys_instance,
    lb_transaction           TYPE REF TO /plmb/ex_spi_transaction,
    lt_instance              TYPE SORTED TABLE OF ys_instance
                                  WITH UNIQUE KEY abbid.

  CLEAR: ev_failed, lt_instance.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  IF gv_check_before_save = abap_false.
    "Check before save was not yet executed
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid = /plmb/cx_spi_error=>check_before_save_not_called.
  ENDIF.

  SET UPDATE TASK LOCAL.

  "Call service provider 'save'
  LOOP AT gt_instance INTO ls_instance.
    IF ls_instance-connector->ms_control_options-transient = abap_true.
      "the instance is transient
      CONTINUE.
    ENDIF.

    READ TABLE lt_instance WITH TABLE KEY abbid = ls_instance-abbid
                           TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      "ABBID was already processed
      CLEAR: ls_instance-connector->mv_unsaved_data.
      CONTINUE.
    ENDIF.
    INSERT ls_instance INTO TABLE lt_instance.

    CALL METHOD increase_callstack
      EXPORTING
        io_connector     = ls_instance-connector
        iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-save.

    ls_instance-connector->mo_sp->save(
      IMPORTING ev_failed = ev_failed ).

    IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
      TRY.
          GET BADI lb_transaction
            FILTERS
              application_building_block = ls_instance-abbid.
        CATCH cx_badi.                                  "#EC NO_HANDLER
      ENDTRY.
    ELSE.
      "Two system scenario
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      EXIT.
    ENDIF.

    IF ( lb_transaction IS BOUND ).
      "After Save changed data to database
      CALL BADI lb_transaction->after_save
        EXPORTING
          iv_abbid     = ls_instance-abbid
          io_collector = ls_instance-connector->mo_collector_in
        CHANGING
          cv_failed    = ev_failed.
    ENDIF.

    CALL METHOD decrease_callstack.
    "Collect field properties
    /plmb/cl_spi_collector=>set_field_properties( ).
    "Collect operation properties
    /plmb/cl_spi_collector=>set_operation_properties( ).

    "Expert mode
    LOG-POINT ID /plmb/spi_data_flow FIELDS ls_instance-abbid
                                            ev_failed
                                            sy-uname.

    IF ev_failed = abap_true.
      EXIT.
    ENDIF.

    CLEAR: ls_instance-connector->mv_unsaved_data.
  ENDLOOP.

  IF ev_failed IS NOT INITIAL.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_false ).
  ELSE.
    CALL METHOD evaluate_collector_data( iv_sp_call_successful = abap_true ).
  ENDIF.

  IF   ev_failed       = abap_false
   AND gv_unsaved_data = abap_true.
    RAISE EVENT unsaved_data_exists
      EXPORTING
        iv_unsaved_data_exists = abap_false.
    CLEAR: gv_unsaved_data.
  ENDIF.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS ev_failed sy-uname.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_false
    OR gv_without_commit = abap_true.
    RETURN.
  ENDIF.

  IF ev_failed IS NOT INITIAL.
    "Rollback work always in back-end system
    ROLLBACK WORK.

  ELSE.
    "Commit work always in back-end system
    COMMIT WORK AND WAIT.

  ENDIF.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~update.

  DATA:
    lr_node_data_table       TYPE REF TO data,  "Container for the data table
    lr_node_data_in_table    TYPE REF TO data,
    lr_succeeded_node_id     TYPE REF TO data,  "Container for the IDs table
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lt_generic_type          TYPE /plmb/t_spi_generic_type_def,
    lb_appl_access           TYPE REF TO /plmb/ex_spi_appl_access,
    ls_operation_category    TYPE /plmb/s_spi_opr_category_node,
    lv_save_relevant         TYPE boole_d,
    lv_version               TYPE /plmb/spi_metadata_version,
    lv_sideeffect            TYPE /plmb/spi_sideeffect,
    lt_changed_field         TYPE /plmb/t_spi_changed_field,
    lv_sp_call_successful    TYPE boole_d.

  FIELD-SYMBOLS:
    <lt_node_data>           TYPE INDEX TABLE,
    <lt_node_data_in>        TYPE INDEX TABLE,
    <lt_succeeded_node_id>   TYPE INDEX TABLE.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.

  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.

  "Initialize exporting parameters
  CLEAR:
    ev_failed,
    et_index_failed,
    et_node_data,
    et_node_id_rel.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-update.

  "Check import parameter.
  IF iv_node_name IS INITIAL.
    "Node name mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-iv_node_name
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-update
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.
  IF it_node_data IS INITIAL.
    "Node data mustn't be empty!
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid         = /plmb/cx_spi_error=>import_parameter_value_invalid
        parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_data
        method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-update
        abbid          = mv_abbid
        node_name      = iv_node_name.
  ENDIF.

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).

  "Does the definition of dynamic parameter match to metadata
  IF   ms_control_options-data_flow_check_errors = abap_true
   AND /plmb/cl_rfc_connector=>is_called_by_dmz( ) = abap_false.
    IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = it_node_data ) = abap_false.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid         = /plmb/cx_spi_error=>import_parameter_type_mismatch
          parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-it_node_data
          method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-update
          abbid          = mv_abbid
          node_name      = iv_node_name.
    ENDIF.
    IF et_node_data IS SUPPLIED.
      IF lo_metadata_node->/plmb/if_spi_node_check~applies_to_data_ttype( it_data = et_node_data ) = abap_false.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>export_parameter_type_mismatch
            parameter_name = /plmb/if_spi_c_internal=>gs_c_parameter_name-et_node_data
            method_name    = /plmb/if_spi_c_internal=>gs_c_method_name-update
            abbid          = mv_abbid
            node_name      = iv_node_name.
      ENDIF.
    ENDIF.
  ENDIF.

  "Get metadata version.
  lv_version = mo_mp->/plmb/if_spi_metadata_output~get_version( ).
  IF lv_version > /plmb/if_mdp_c=>gs_c_version-version_702.
    "Check if operation is supported according to metadata.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_supported_operations
      IMPORTING
        ev_update = ls_operation_category-update.
    IF ls_operation_category-update IS INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid             = /plmb/cx_spi_error=>operation_not_supported
          abbid              = mv_abbid
          node_name          = iv_node_name
          operation_category = /plmb/if_spi_c=>gs_c_operation_category-update.
    ENDIF.
  ENDIF.

  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_transient( ) = abap_false.
    "CHECK_BEFORE_SAVE needs to be called again before calling SAVE.
    CLEAR: gv_check_before_save.
    IF ms_control_options-transient = abap_true.
      "Upon instantiation the SP instance was marked as transient,
      "so save relevant operations are forbidden
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>save_rel_operation_prohibited
          abbid  = mv_abbid.
    ENDIF.
    lv_save_relevant = abap_true.
  ENDIF.

  lt_changed_field = it_changed_field.

  TRY .
      "Get a container for IT_NODE_DATA
      CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
        IMPORTING
          er_data_table = lr_node_data_in_table.
      ASSIGN lr_node_data_in_table->* TO <lt_node_data_in>.
      <lt_node_data_in> = it_node_data.
    CATCH /plmb/cx_spi_metadata.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid    = /plmb/cx_spi_error=>node_typization_insufficient
          abbid     = mv_abbid
          node_name = iv_node_name.
  ENDTRY.

  IF et_node_data IS SUPPLIED.
    ASSIGN et_node_data TO <lt_node_data>.
  ELSE.
    "Get a container for ET_NODE_DATA
    "Note: this is required to avoid type conflicts if consumer does not
    "      request the parameters but the service provider fills them
    TRY.
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_data_container
          IMPORTING
            er_data_table = lr_node_data_table.
        ASSIGN lr_node_data_table->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        ASSIGN lt_generic_type TO <lt_node_data>.
    ENDTRY.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    TRY.
        GET BADI lb_appl_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = iv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

*--- Before Update ----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->modify_before_update
      EXPORTING
        iv_abbid         = mv_abbid
        iv_node_name     = iv_node_name
        io_collector     = mo_collector_in
        io_metadata      = mo_mp
      CHANGING
        ct_node_data     = <lt_node_data_in>
        ct_changed_field = lt_changed_field.

    CALL BADI lb_appl_access->before_update
      EXPORTING
        iv_abbid         = mv_abbid
        iv_node_name     = iv_node_name
        it_node_data     = <lt_node_data_in>
        it_changed_field = lt_changed_field
        io_collector     = mo_collector_in
        io_metadata      = mo_mp
      CHANGING
        cv_skip_standard = mv_bypass_service_provider
        cv_failed        = ev_failed.

    IF NOT ev_failed IS INITIAL.
      CALL METHOD decrease_callstack.
      "Collect field properties
      /plmb/cl_spi_collector=>set_field_properties( ).
      "Collect operation properties
      /plmb/cl_spi_collector=>set_operation_properties( ).
      RETURN.
    ENDIF.
  ENDIF.

*--- Call Update ------------------------------------------------------*
  IF mv_bypass_service_provider IS INITIAL AND lo_metadata_node->is_sp_node( ) = abap_true.
    mo_sp->update(
      EXPORTING
        iv_node_name     = iv_node_name
        it_node_data     = <lt_node_data_in>
        it_changed_field = lt_changed_field
      IMPORTING
        ev_failed        = ev_failed
        et_index_failed  = et_index_failed
        et_node_data     = <lt_node_data>
        et_node_id_rel   = et_node_id_rel ).

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_data_in>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->update
        EXPORTING
          iv_node_name     = iv_node_name
          it_node_data     = <lt_node_data_in>
          it_changed_field = lt_changed_field
          iv_failed        = ev_failed
          it_index_failed  = et_index_failed
          it_node_data_e   = <lt_node_data>
          it_node_id_rel   = et_node_id_rel.
    ENDIF.
  ENDIF.

*--- After Update -----------------------------------------------------*
  IF lb_appl_access IS BOUND.
    CALL BADI lb_appl_access->after_update
      EXPORTING
        iv_abbid         = mv_abbid
        iv_node_name     = iv_node_name
        it_node_data     = <lt_node_data_in>
        it_changed_field = lt_changed_field
        io_collector     = mo_collector_in
        io_metadata      = mo_mp
      CHANGING
        cv_failed        = ev_failed
        ct_index_failed  = et_index_failed
        ct_node_data     = <lt_node_data>
        ct_node_id_rel   = et_node_id_rel.

    CALL METHOD check_index_failed
      EXPORTING
        iv_node_name    = iv_node_name
        it_data         = <lt_node_data_in>
      CHANGING
        ct_index_failed = et_index_failed.

    "Check consistency of parameter
    IF ms_control_options-data_flow_check_errors = abap_true.
      CALL METHOD mo_appl_access_check->update
        EXPORTING
          iv_node_name     = iv_node_name
          it_node_data     = <lt_node_data_in>
          it_changed_field = lt_changed_field
          iv_failed        = ev_failed
          it_index_failed  = et_index_failed
          it_node_data_e   = <lt_node_data>
          it_node_id_rel   = et_node_id_rel.
    ENDIF.
  ENDIF.

  "Trim source/target relation table.
  CALL METHOD mo_appl_access_check->trim_node_id_rel
    EXPORTING
      iv_node_name    = iv_node_name
      iv_method_name  = /plmb/if_spi_c_internal=>gs_c_method_name-update
      iv_check_errors = ms_control_options-data_flow_check_errors
    CHANGING
      ct_node_id_rel  = et_node_id_rel.

*--- Pull properties --------------------------------------------------*
  IF ev_failed IS INITIAL.
    "Collect operation and field properties.
    CALL METHOD pull_properties
      EXPORTING
        iv_node_name      = iv_node_name
        it_node_data_out  = <lt_node_data>
        iv_operation_type = /plmb/if_mdp_c=>gs_c_operation_type-update.
  ENDIF.

  CLEAR: mv_bypass_service_provider.

  IF ev_failed = abap_false.
    IF et_index_failed IS INITIAL.
      "Everything is fine.
      lv_sp_call_successful = abap_true.
    ELSE.
      "Check if all records failed.
      IF lines( <lt_node_data_in> ) > lines( et_index_failed ).
        lv_sp_call_successful = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

*--- Node Invalidation based on side-effects --------------------------*
  IF lv_sp_call_successful = abap_true.
    IF lv_save_relevant = abap_true.
      IF gv_unsaved_data = abap_false.
        RAISE EVENT unsaved_data_exists
          EXPORTING
            iv_unsaved_data_exists = abap_true.
      ENDIF.
      gv_unsaved_data = mv_unsaved_data = abap_true.
    ENDIF.

    "Get side-effect.
    CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_update_details
      IMPORTING
        ev_sideeffect = lv_sideeffect.
    "Invalidate nodes.
    CALL METHOD mo_collector_in->invalidate_nodes_by_sideeffect
      EXPORTING
        iv_node_name  = iv_node_name
        iv_sideeffect = lv_sideeffect.

    TRY .
        "Get a container for NODE_ID
        CALL METHOD lo_metadata_node->/plmb/if_spi_metadata_node~get_id_container
          IMPORTING
            er_id_table = lr_succeeded_node_id.
        ASSIGN lr_succeeded_node_id->* TO <lt_succeeded_node_id>.
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = iv_node_name.
    ENDTRY.

    CALL METHOD get_succeeded_records
      EXPORTING
        it_node_data         = <lt_node_data_in>
        it_index_failed      = et_index_failed
      IMPORTING
        et_succeeded_node_id = <lt_succeeded_node_id>.

    CALL METHOD invalidate_node_id_implicit
      EXPORTING
        iv_node_name = iv_node_name
        it_node_id   = <lt_succeeded_node_id>
        iv_reason    = /plmb/if_spi_c=>gs_c_invalidation_reason-update.
  ENDIF.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  CALL METHOD evaluate_collector_data( lv_sp_call_successful ).
  CALL METHOD decrease_callstack.

  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS mv_abbid
                                          iv_node_name
                                          <lt_node_data_in>
                                          ev_failed
                                          et_index_failed
                                          et_node_data
                                          sy-uname.

  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS mv_abbid
                                            iv_node_name
                                            iv_node_name
                                            sy-uname.

ENDMETHOD.


METHOD check_index_failed.

  FIELD-SYMBOLS:
    <ls_index_failed>        TYPE /plmb/s_spi_index_failed.

  IF ct_index_failed IS INITIAL.
    RETURN.
  ENDIF.

  "Trim index failed table
  SORT ct_index_failed BY index.
  DELETE ADJACENT DUPLICATES FROM ct_index_failed COMPARING index.

  READ TABLE ct_index_failed ASSIGNING <ls_index_failed> INDEX 1.
  IF <ls_index_failed>-index < 1.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>index_failed_out_of_bounds
        abbid     = mv_abbid
        node_name = iv_node_name.
  ENDIF.

  IF sy-tfill = 1.
    RETURN.
  ENDIF.

  READ TABLE ct_index_failed ASSIGNING <ls_index_failed> INDEX sy-tfill.
  IF <ls_index_failed>-index > lines( it_data ).
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>index_failed_out_of_bounds
        abbid     = mv_abbid
        node_name = iv_node_name.
  ENDIF.

ENDMETHOD.


METHOD check_rtr_index_failed.

  FIELD-SYMBOLS:
    <ls_index_failed>        TYPE /plmb/s_spi_rtr_index_failed.

  IF ct_index_failed IS INITIAL.
    RETURN.
  ENDIF.

  "Trim index failed table
  SORT ct_index_failed BY index ASCENDING reason_code DESCENDING.
  DELETE ADJACENT DUPLICATES FROM ct_index_failed COMPARING index.

  READ TABLE ct_index_failed ASSIGNING <ls_index_failed> INDEX 1.
  IF <ls_index_failed>-index < 1.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>index_failed_out_of_bounds
        abbid     = mv_abbid
        node_name = iv_node_name.
  ENDIF.

  IF sy-tfill = 1.
    RETURN.
  ENDIF.

  READ TABLE ct_index_failed ASSIGNING <ls_index_failed> INDEX sy-tfill.
  IF <ls_index_failed>-index > lines( it_data ).
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>index_failed_out_of_bounds
        abbid     = mv_abbid
        node_name = iv_node_name.
  ENDIF.

ENDMETHOD.


METHOD class_constructor.

  "Is logging of data flow active
  gv_data_flow_log_is_active = cl_abap_aab_utilities=>is_active( id = '/PLMB/SPI_DATA_FLOW' mode_logpoint = abap_true ).

  SELECT * FROM /plmb/spi_check INTO TABLE gt_data_flow_check.

ENDMETHOD.


METHOD constructor.

  CONSTANTS:
    lc_properties_access     TYPE seoclsname VALUE '/PLMB/IF_SPI_PROPERTIES_ACCESS'.

  DATA:
    lx_uuid_error            TYPE REF TO cx_uuid_error,     "#EC NEEDED
    lo_master_collector      TYPE REF TO /plmb/cl_spi_collector,
    lo_master_connector      TYPE REF TO /plmb/cl_spi_connector,
    lo_collector             TYPE REF TO /plmb/cl_spi_collector.

  DATA:
    ls_instance          TYPE ys_instance,
    ls_abbid             TYPE /plmb/s_spi_abb.

  "Support mode
  BREAK-POINT ID /plmb/spi_data_in_out.
  "Expert mode
  BREAK-POINT ID /plmb/spi_data_flow.
  "Support mode
  LOG-POINT ID /plmb/spi_data_in_out FIELDS sy-uname iv_abbid.
  "Expert mode
  LOG-POINT ID /plmb/spi_data_flow FIELDS sy-uname iv_abbid.

  IF   /plmb/cl_rfc_connector=>is_backend_system( ) = abap_false
   AND io_master_collector IS NOT INITIAL.
    " Error when calling SPI: When creating a Connector instance,
    " IO_MASTER_COLLECTOR must only be filled during a SP call
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid = /plmb/cx_spi_error=>master_collector_outside_sp.
  ENDIF.

  CALL METHOD /plmb/cl_spi_abb=>get_abb(
    EXPORTING
      iv_abbid = iv_abbid
    IMPORTING
      es_abb   = ls_abbid ).

  CALL METHOD /plmb/cl_spi_rfc_connector=>get_sp_rtid
    IMPORTING
      ev_sp_rtid = mv_sp_rtid.

  IF mv_sp_rtid IS INITIAL.
    TRY.
        mv_sp_rtid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error INTO lx_uuid_error.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error. "Fatal system error!
    ENDTRY.
  ELSE.
    mv_called_by_rfc = abap_true.

    "Get Name of DMZ Application Server
    CALL METHOD /plmb/cl_spi_rfc_connector=>get_dmz_host_name
      IMPORTING
        ev_dmz_host_name = mv_dmz_host_name.

    "Get IPv4 Address of DMZ Application Server
    CALL METHOD /plmb/cl_spi_rfc_connector=>get_dmz_ipv4addr
      IMPORTING
        ev_dmz_ipv4addr = mv_dmz_ipv4addr.
  ENDIF.

  mv_abbid = iv_abbid.

  MOVE-CORRESPONDING is_options TO ms_control_options.
  ms_control_options-is_called_by_rfc = mv_called_by_rfc.

  IF io_master_collector IS BOUND.
    lo_master_collector ?= io_master_collector.
    ms_control_options-master_sp_rtid = lo_master_collector->mv_sp_rtid.

    IF ms_control_options-master_sp_rtid NE /plmb/cl_spi_connector=>get_active_connector( )->mv_sp_rtid.
      " Error in SP: When creating a Connector instance within the SP,
      " IO_MASTER_COLLECTOR must be filled with the Collector instance of the active SP
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>wrong_master_collector
          abbid  = /plmb/cl_spi_connector=>get_active_connector( )->mv_abbid.
    ENDIF.

    CALL METHOD get_connector_by_rtid
      EXPORTING
        iv_sp_rtid   = ms_control_options-master_sp_rtid
      IMPORTING
        eo_connector = lo_master_connector.

  ENDIF.

  determine_data_flow_check( ).

  "Create instance of metadata provider
  CALL METHOD /plmb/cl_spi_metadata=>get_instance_local
    EXPORTING
      iv_abbid   = iv_abbid
      iv_sp_rtid = mv_sp_rtid
      is_options = ms_control_options
    IMPORTING
      eo_mp      = mo_mp.

  "Create collector instances
  CREATE OBJECT mo_collector_in
    EXPORTING
      iv_sp_rtid   = mv_sp_rtid
      iv_abbid     = iv_abbid
      is_options   = is_options
      io_connector = me
      io_mp        = mo_mp.

  CREATE OBJECT mo_collector_out
    EXPORTING
      iv_sp_rtid          = mv_sp_rtid
      iv_abbid            = iv_abbid
      is_options          = is_options
      io_connector        = me
      io_master_connector = lo_master_connector
      io_mp               = mo_mp.

  CALL METHOD mo_collector_out->set_input_collector
    EXPORTING
      io_collector_input = mo_collector_in.

  "Get instance of service provider and instance of metadata provider
  CALL METHOD /plmb/cl_spi_factory=>get_providers
    EXPORTING
      iv_abbid              = iv_abbid
      iv_sp_rtid            = mv_sp_rtid
      iv_sp_name            = ls_abbid-sp_name
      iv_called_by_rfc      = mv_called_by_rfc
      iv_dmz_host_name      = mv_dmz_host_name
      iv_dmz_ipv4addr       = mv_dmz_ipv4addr
      is_options            = ms_control_options
      io_metadata           = mo_mp
      io_collector_in       = mo_collector_in
      io_collector_out      = mo_collector_out
    IMPORTING
      eo_application_access = mo_sp.

  "Set instance parameter of connector to buffer
  ls_instance-abbid     = iv_abbid.
  ls_instance-sp_rtid   = mv_sp_rtid.
  ls_instance-connector = me.
  APPEND ls_instance TO gt_instance.

  CALL METHOD mo_mp->/plmb/if_spi_metadata~get_abbid_details
    IMPORTING
      ev_pull_properties      = ms_abbid_details-pull_properties
      et_init_operations      = ms_abbid_details-init_operations
      ev_modification_allowed = ms_abbid_details-modification_allowed.

  IF ms_abbid_details-pull_properties IS NOT INITIAL.
    TRY.
        "Properties Access Interface
        mo_properties_access ?= mo_sp.
      CATCH cx_sy_move_cast_error.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid         = /plmb/cx_spi_error=>interface_not_implemented_sp
            interface_name = lc_properties_access
            sp_name        = ls_abbid-sp_name.
    ENDTRY.
  ENDIF.

  CALL METHOD evaluate_collector_options.

  CREATE OBJECT mo_appl_access_check
    EXPORTING
      io_mp    = mo_mp
      iv_abbid = iv_abbid.

  lo_collector = mo_collector_in.
  lo_collector->activate_check( ).

ENDMETHOD.


METHOD create_instance.

  DATA:
    lo_connector             TYPE REF TO /plmb/cl_spi_connector.

* initialize exporting parameters -------------------------
  CLEAR: eo_connector, eo_collector, eo_metadata.

* Create SP access instance -------------------------------
  CREATE OBJECT lo_connector
    EXPORTING
      iv_abbid            = iv_abbid
      is_options          = is_options
      io_master_collector = io_master_collector.

* Application Access --------------------------------------
  eo_connector = lo_connector.

* Collector output ----------------------------------------
  eo_collector = lo_connector->mo_collector_out.

* SP metadata ---------------------------------------------
  eo_metadata ?=  lo_connector->mo_mp->mo_metadata_output.

ENDMETHOD.


METHOD decrease_callstack.

  DATA:
    ls_callstack             TYPE /plmb/s_spi_callstack.

  "Decrease callstack.
  DELETE gt_callstack INDEX 1.

  "Set active collector functions.
  IF lines( gt_callstack ) > 0.
    READ TABLE gt_callstack INDEX 1 INTO ls_callstack.
  ENDIF.

  /plmb/cl_spi_collector=>set_active_collector_functions( ls_callstack-active_collector_functions ).

ENDMETHOD.


METHOD delete_instance_from_buffer.

* Connector -----------------------------------------------
  DELETE gt_instance USING KEY sp_rtid WHERE sp_rtid = iv_sp_rtid.
  IF sy-subrc IS INITIAL.
    rv_delete_successful = abap_true.
  ELSE.
    RETURN.
  ENDIF.

* Metadata ------------------------------------------------
  CALL METHOD /plmb/cl_spi_metadata=>delete_instance_from_buffer
    EXPORTING
      iv_sp_rtid = iv_sp_rtid.

* Collector -----------------------------------------------
  CALL METHOD /plmb/cl_spi_collector=>delete_instance_from_buffer
    EXPORTING
      iv_sp_rtid = iv_sp_rtid.

ENDMETHOD.


METHOD determine_data_flow_check.

  FIELD-SYMBOLS:
    <ls_data_flow_check>     TYPE /plmb/spi_check.



  READ TABLE gt_data_flow_check ASSIGNING <ls_data_flow_check>
             WITH TABLE KEY target_abbid = mv_abbid
                            target_user  = sy-uname.
  IF sy-subrc EQ 0.
    IF <ls_data_flow_check>-inactive IS INITIAL.
      ms_control_options-data_flow_check_errors = abap_true.
    ENDIF.
    IF <ls_data_flow_check>-basis_checks_inactive IS INITIAL.
      ms_control_options-basis_checks = abap_true.
    ENDIF.
    RETURN.
  ENDIF.


  READ TABLE gt_data_flow_check ASSIGNING <ls_data_flow_check>
             WITH TABLE KEY target_abbid = space
                            target_user  = sy-uname.
  IF sy-subrc EQ 0.
    IF <ls_data_flow_check>-inactive IS INITIAL.
      ms_control_options-data_flow_check_errors = abap_true.
    ENDIF.
    IF <ls_data_flow_check>-basis_checks_inactive IS INITIAL.
      ms_control_options-basis_checks = abap_true.
    ENDIF.
    RETURN.
  ENDIF.

  READ TABLE gt_data_flow_check  ASSIGNING <ls_data_flow_check>
                                WITH TABLE KEY target_abbid = mv_abbid
                                               target_user  = space.
  IF sy-subrc EQ 0.
    IF <ls_data_flow_check>-inactive IS INITIAL.
      ms_control_options-data_flow_check_errors = abap_true.
    ENDIF.
    IF <ls_data_flow_check>-basis_checks_inactive IS INITIAL.
      ms_control_options-basis_checks = abap_true.
    ENDIF.
    RETURN.
  ENDIF.



  READ TABLE gt_data_flow_check ASSIGNING <ls_data_flow_check>
             WITH TABLE KEY target_abbid = space
                            target_user  = space.
  IF sy-subrc EQ 0.
    IF <ls_data_flow_check>-inactive IS INITIAL.
      ms_control_options-data_flow_check_errors = abap_true.
    ENDIF.
    IF <ls_data_flow_check>-basis_checks_inactive IS INITIAL.
      ms_control_options-basis_checks = abap_true.
    ENDIF.
    RETURN.
  ENDIF.

*default  - no matching entry found - > all checks switched on
   ms_control_options-data_flow_check_errors = abap_false.
   ms_control_options-basis_checks = abap_true.

ENDMETHOD.


METHOD evaluate_collector_data.

  FIELD-SYMBOLS:
    <ls_instance>            TYPE           ys_instance.

  LOOP AT gt_instance ASSIGNING <ls_instance>.
    READ TABLE gt_callstack TRANSPORTING NO FIELDS
      WITH KEY sp_rtid = <ls_instance>-sp_rtid.
    IF sy-subrc IS INITIAL
      AND sy-tabix > 1.
      "When we are in a scenario with cascading SP calls
      "we do not want to evaluate the content of the superior collectors
      "as long as we are in the subordinate SP instances.
      CONTINUE.
    ENDIF.
    <ls_instance>-connector->mo_collector_out->evaluate_content( iv_sp_call_successful ).
  ENDLOOP.

ENDMETHOD.


METHOD evaluate_collector_options.

  DATA:
    lv_process_and_forward   TYPE boole_d.

  FIELD-SYMBOLS:
    <ls_instance_get>        TYPE ys_instance,
    <ls_instance_set>        TYPE ys_instance.

  LOOP AT gt_instance ASSIGNING <ls_instance_get>
                      USING KEY abbid.
    IF <ls_instance_get>-connector->mo_collector_in->/plmb/if_spi_collector~ms_collector_options-node_invalidation = /plmb/if_spi_c=>gs_c_invalid_node_processing-process_and_forward.
      lv_process_and_forward = abap_true.
    ENDIF.
    AT END OF abbid.
      LOOP AT gt_instance ASSIGNING <ls_instance_set>
        USING KEY abbid
        WHERE abbid = <ls_instance_get>-abbid.
        IF lv_process_and_forward = abap_true.
          "If one of the callers of the connector is interested
          "in all node invalidation info we need to set the external
          "control options accordingly, so that the SP knows that node
          "invalidation info is expected.
          CALL METHOD <ls_instance_set>-connector->mo_collector_in->set_invalidation_option( /plmb/if_spi_c=>gs_c_invalid_node_processing-process_and_forward ).
        ELSE.
          "Otherwise we just keep the settings of the caller.
          CALL METHOD <ls_instance_set>-connector->mo_collector_in->set_invalidation_option( <ls_instance_set>-connector->ms_control_options-control-node_invalidation ).
        ENDIF.
      ENDLOOP.
      CLEAR: lv_process_and_forward.
    ENDAT.
  ENDLOOP.

ENDMETHOD.


METHOD get_active_connector.

  FIELD-SYMBOLS:
    <ls_instance>            TYPE ys_instance,
    <ls_callstack>           TYPE /plmb/s_spi_callstack.

  CLEAR: ro_connector.

  IF lines( gt_callstack ) > 0.
    READ TABLE gt_callstack INDEX 1 ASSIGNING <ls_callstack>.
    READ TABLE gt_instance ASSIGNING <ls_instance>
      WITH TABLE KEY sp_rtid
      COMPONENTS sp_rtid = <ls_callstack>-sp_rtid.
    IF <ls_instance> IS ASSIGNED.
      ro_connector = <ls_instance>-connector.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_auto_pull_focus.

  DATA:
    lt_node_options          TYPE /plmb/t_spi_prpty_pull_options.

  FIELD-SYMBOLS:
    <ls_node_options>        TYPE /plmb/s_spi_prpty_pull_options.

  CLEAR: es_requested_properties,
         et_requested_fields.

  IF ms_abbid_details-pull_properties IS INITIAL.
    "Application does not support pull.
    RETURN.
  ENDIF.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_false.
    "Properties are only pulled when we are in the backend system.
    RETURN.
  ENDIF.

  IF ms_control_options-control-properties = /plmb/if_spi_c=>gs_c_property_processing-ignore.
    "The caller of the SPI does not need the properties.
    "(This was set when instanciating the Connector)
    RETURN.
  ENDIF.

  "Get the list of nodes who are supposed to be automatically pulled.
  CALL METHOD mo_collector_out->/plmb/if_spi_collector_output~get_prpty_pull_options
    EXPORTING
      iv_node_name      = iv_node_name
      iv_operation_type = iv_operation_type
      iv_operation_name = iv_operation_name
    IMPORTING
      et_node_options   = lt_node_options.
  READ TABLE lt_node_options ASSIGNING <ls_node_options> INDEX 1.
  IF sy-subrc NE 0.
    "Node is not supposed to be pulled
    RETURN.
  ELSE.
    IF   ms_control_options-control-properties NE /plmb/if_spi_c=>gs_c_property_processing-process_operation_only
     AND ms_control_options-control-properties NE /plmb/if_spi_c=>gs_c_property_processing-process_operation_only_mr.
      es_requested_properties-fields = <ls_node_options>-requested_field_properties.
    ENDIF.
    IF   ms_control_options-control-properties NE /plmb/if_spi_c=>gs_c_property_processing-process_field_only
     AND ms_control_options-control-properties NE /plmb/if_spi_c=>gs_c_property_processing-process_field_only_mr.
      es_requested_properties-operations = <ls_node_options>-requested_operation_properties.
    ENDIF.
    IF et_requested_fields IS SUPPLIED.
      et_requested_fields = <ls_node_options>-requested_fields.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_connector_by_rtid.

  FIELD-SYMBOLS:
    <ls_instance>            TYPE ys_instance.

* initialize exporting parameters -------------------------
  CLEAR: eo_connector.

  READ TABLE gt_instance ASSIGNING <ls_instance>
                         WITH TABLE KEY sp_rtid
                         COMPONENTS sp_rtid = iv_sp_rtid.

  eo_connector = <ls_instance>-connector.

ENDMETHOD.


METHOD get_failed_node_data.

  DATA:
    lt_index_failed	         TYPE /plmb/t_spi_index_failed.

  FIELD-SYMBOLS:
    <ls_node_data>           TYPE any,
    <ls_index_failed>        TYPE /plmb/s_spi_index_failed.

  CLEAR et_failed_node_data.

  IF it_node_data IS INITIAL OR it_index_failed IS INITIAL.
    RETURN.
  ENDIF.

  lt_index_failed = it_index_failed.
  SORT lt_index_failed BY index.
  DELETE ADJACENT DUPLICATES FROM lt_index_failed COMPARING index.

  LOOP AT lt_index_failed ASSIGNING <ls_index_failed>.
    READ TABLE it_node_data ASSIGNING <ls_node_data> INDEX <ls_index_failed>-index.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid    = /plmb/cx_spi_error=>et_index_failed_out_of_bounds
          abbid     = mv_abbid
          node_name = iv_node_name
          index     = <ls_index_failed>-index.
    ENDIF.
    INSERT <ls_node_data> INTO TABLE et_failed_node_data.
  ENDLOOP.

ENDMETHOD.


METHOD get_instance.

  DATA:
    lo_connector             TYPE REF TO /plmb/cl_spi_connector,
    ls_options               TYPE /plmb/s_spi_connector_options,
    ls_instance              TYPE ys_instance.

  CLEAR: eo_appl_access, eo_collector_output, eo_metadata.

* Get/create instance --------------------------------------------------
  READ TABLE gt_instance INTO ls_instance
    WITH TABLE KEY sp_rtid
    COMPONENTS sp_rtid = iv_sp_rtid.
  IF sy-subrc EQ 0.
    eo_appl_access      = ls_instance-connector.
    eo_metadata         = ls_instance-connector->mo_mp->mo_metadata_output.
    eo_collector_output = ls_instance-connector->mo_collector_out.
* reset gv_sp_rtid
    /plmb/cl_spi_rfc_connector=>get_sp_rtid( ).
  ELSE.
* Create SP access instance -------------------------------
    MOVE-CORRESPONDING is_options_con TO ls_options.

    CREATE OBJECT lo_connector
      EXPORTING
        iv_abbid   = iv_abbid
        is_options = ls_options.

* Application Access --------------------------------------
    eo_appl_access = lo_connector.

* Collector output ----------------------------------------
    eo_collector_output = lo_connector->mo_collector_out.

* SP metadata ---------------------------------------------
    eo_metadata ?=  lo_connector->mo_mp->mo_metadata_output.
  ENDIF.

ENDMETHOD.


METHOD get_operation_properties.

  DATA:
    lb_properties_access     TYPE REF TO /plmb/ex_spi_properties_access,
    lv_call_property_access  TYPE boole_d,
    lv_call_property_badi    TYPE boole_d,
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lv_node_name             TYPE /plmb/spi_node_name,
    lt_operation_properties  TYPE /plmb/t_spi_operation_prpty,
    lt_opr_prpty_single_idx  TYPE /plmb/t_spi_indexed_opr_prpty,
    lt_opr_prpty_multi_idx   TYPE /plmb/t_spi_ndx_opr_prpty_mult.

  CLEAR: et_operation_properties,
         et_opr_prpty_single_idx,
         et_opr_prpty_multi_idx.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-get_operation_properties.

  lv_node_name = mo_mp->/plmb/if_spi_metadata_output~determine_target_node(
    iv_node_name         = iv_node_name
    iv_target_node_name  = iv_target_node_name
    iv_check_consistency = abap_true ).

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_opr_prpty_reftype_supported( iv_reference_type ) = abap_false.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>pull_not_supported_by_node
        abbid     = mv_abbid
        node_name = lv_node_name.
  ENDIF.

*--- Determine what to do ---------------------------------------------*
  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    IF mv_bypass_service_provider = abap_false.
      IF lo_metadata_node->is_sp_node( ) = abap_true.
        lv_call_property_access = abap_true.
      ENDIF.
    ENDIF.
    TRY.
        GET BADI lb_properties_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = lv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
    IF lb_properties_access IS BOUND.
      lv_call_property_badi = abap_true.
    ENDIF.
  ELSE.
    lv_call_property_access = abap_true.
  ENDIF.

*--- Property access via Service Provider -----------------------------*
  IF lv_call_property_access = abap_true.
    IF ig_reference_data IS SUPPLIED.
      CALL METHOD mo_properties_access->get_operation_properties
        EXPORTING
          iv_node_name            = iv_node_name
          iv_target_node_name     = iv_target_node_name
          iv_reference_type       = iv_reference_type
          ig_reference_data       = ig_reference_data
        IMPORTING
          et_operation_properties = et_operation_properties
          et_opr_prpty_single_idx = et_opr_prpty_single_idx
          et_opr_prpty_multi_idx  = et_opr_prpty_multi_idx.

      IF et_opr_prpty_multi_idx IS NOT INITIAL.
        "Merge multi and single properties.
        CALL METHOD mo_collector_in->merge_opr_prpty_indexed_multi
          EXPORTING
            it_opr_properties_multi_idx  = et_opr_prpty_multi_idx
          CHANGING
            ct_opr_properties_single_idx = et_opr_prpty_single_idx.
        CLEAR et_opr_prpty_multi_idx.
      ENDIF.
    ELSE.
      CALL METHOD mo_properties_access->get_operation_properties
        EXPORTING
          iv_node_name            = iv_node_name
          iv_target_node_name     = iv_target_node_name
          iv_reference_type       = iv_reference_type
        IMPORTING
          et_operation_properties = et_operation_properties
          et_opr_prpty_single_idx = et_opr_prpty_single_idx
          et_opr_prpty_multi_idx  = et_opr_prpty_multi_idx.
    ENDIF.
  ENDIF.

*--- Property access via BAdI -----------------------------------------*
  IF lv_call_property_badi = abap_true.
    CALL BADI lb_properties_access->get_operation_properties
      EXPORTING
        iv_node_name            = iv_node_name
        iv_target_node_name     = iv_target_node_name
        ig_reference_data       = ig_reference_data
        iv_reference_type       = iv_reference_type
        it_operation_properties = et_operation_properties
        it_opr_prpty_single_idx = et_opr_prpty_single_idx
      CHANGING
        ct_opr_prpty_single_idx = lt_opr_prpty_single_idx
        ct_opr_prpty_multi_idx  = lt_opr_prpty_multi_idx
        ct_operation_properties = lt_operation_properties.

    IF lt_opr_prpty_multi_idx IS NOT INITIAL.
      "Merge multi and single properties.
      CALL METHOD mo_collector_in->merge_opr_prpty_indexed_multi
        EXPORTING
          it_opr_properties_multi_idx  = lt_opr_prpty_multi_idx
        CHANGING
          ct_opr_properties_single_idx = lt_opr_prpty_single_idx.
    ENDIF.

    "Merge SP and BAdI properties.
    CALL METHOD mo_collector_in->merge_opr_prpty_indexed_single
      EXPORTING
        it_opr_properties_single_idx = lt_opr_prpty_single_idx
      CHANGING
        ct_opr_properties_single_idx = et_opr_prpty_single_idx.
    CALL METHOD mo_collector_in->merge_operation_prpty_profiles
      EXPORTING
        it_profile        = lt_operation_properties
      CHANGING
        ct_result_profile = et_operation_properties.
  ENDIF.

*--- Set properties to Collector --------------------------------------*
  CALL METHOD mo_collector_in->set_operation_properties
    EXPORTING
      iv_node_name            = iv_node_name
      iv_target_node_name     = iv_target_node_name
      iv_reference_type       = iv_reference_type
      ig_reference_data       = ig_reference_data
      it_opr_prpty_single_idx = et_opr_prpty_single_idx
      it_opr_prpty_multi_idx  = et_opr_prpty_multi_idx
      it_operation_properties = et_operation_properties.


  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  IF iv_evaluate_collector_data = abap_true.
    CALL METHOD evaluate_collector_data( abap_true ).
  ENDIF.
  CALL METHOD decrease_callstack.

ENDMETHOD.


METHOD get_properties.

  DATA:
    lb_properties_access     TYPE REF TO /plmb/ex_spi_properties_access,
    lv_call_property_access  TYPE boole_d,
    lv_call_property_badi    TYPE boole_d,
    lo_metadata_node         TYPE REF TO /plmb/cl_spi_metadata_node,
    lv_node_name             TYPE /plmb/spi_node_name,
    lt_properties_single_idx TYPE /plmb/t_spi_indexed_property,
    lt_properties_multi_idx  TYPE /plmb/t_spi_indexed_prp_multi,
    lt_properties            TYPE /plmb/t_spi_properties.

  CLEAR: et_properties_single_idx,
         et_properties_multi_idx,
         et_properties.

  CALL METHOD increase_callstack
    EXPORTING
      io_connector     = me
      iv_access_method = /plmb/if_spi_c=>gs_c_access_meth-get_properties.

  lv_node_name = mo_mp->/plmb/if_spi_metadata_output~determine_target_node(
    iv_node_name         = iv_node_name
    iv_target_node_name  = iv_target_node_name
    iv_check_consistency = abap_true ).

  lo_metadata_node ?= mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
  IF lo_metadata_node->/plmb/if_spi_metadata_node~is_prpty_reftype_supported( iv_reference_type ) = abap_false.
    RAISE EXCEPTION TYPE /plmb/cx_spi_error
      EXPORTING
        textid    = /plmb/cx_spi_error=>pull_not_supported_by_node
        abbid     = mv_abbid
        node_name = lv_node_name.
  ENDIF.

*--- Determine what to do ---------------------------------------------*
  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_true.
    IF mv_bypass_service_provider = abap_false.
      IF lo_metadata_node->is_sp_node( ) = abap_true.
        lv_call_property_access = abap_true.
      ENDIF.
    ENDIF.
    TRY.
        GET BADI lb_properties_access
          FILTERS
            application_building_block = mv_abbid
            node_name                  = lv_node_name.
      CATCH cx_badi.                                    "#EC NO_HANDLER
    ENDTRY.
    IF lb_properties_access IS BOUND.
      lv_call_property_badi = abap_true.
    ENDIF.
  ELSE.
    lv_call_property_access = abap_true.
  ENDIF.

*--- Property access via Service Provider -----------------------------*
  IF lv_call_property_access = abap_true.
    IF ig_reference_data IS SUPPLIED.
      CALL METHOD mo_properties_access->get_properties
        EXPORTING
          iv_node_name             = iv_node_name
          iv_target_node_name      = iv_target_node_name
          ig_reference_data        = ig_reference_data
          iv_reference_type        = iv_reference_type
          it_requested_field       = it_requested_field
        IMPORTING
          et_properties_single_idx = et_properties_single_idx
          et_properties_multi_idx  = et_properties_multi_idx
          et_properties            = et_properties.

      IF et_properties_multi_idx IS NOT INITIAL.
        "Merge multi and single properties.
        CALL METHOD mo_collector_in->merge_prpty_indexed_multi
          EXPORTING
            it_properties_multi_idx  = et_properties_multi_idx
          CHANGING
            ct_properties_single_idx = et_properties_single_idx.
        CLEAR et_properties_multi_idx.
      ENDIF.
    ELSE.
      CALL METHOD mo_properties_access->get_properties
        EXPORTING
          iv_node_name             = iv_node_name
          iv_target_node_name      = iv_target_node_name
          iv_reference_type        = iv_reference_type
          it_requested_field       = it_requested_field
        IMPORTING
          et_properties_single_idx = et_properties_single_idx
          et_properties_multi_idx  = et_properties_multi_idx
          et_properties            = et_properties.
    ENDIF.
  ENDIF.

*--- Property access via BAdI -----------------------------------------*
  IF lv_call_property_badi = abap_true.
    CALL BADI lb_properties_access->get_properties
      EXPORTING
        iv_node_name             = iv_node_name
        iv_target_node_name      = iv_target_node_name
        ig_reference_data        = ig_reference_data
        iv_reference_type        = iv_reference_type
        it_properties_single_idx = et_properties_single_idx
        it_properties            = et_properties
        it_requested_field       = it_requested_field
      CHANGING
        ct_properties_single_idx = lt_properties_single_idx
        ct_properties_multi_idx  = lt_properties_multi_idx
        ct_properties            = lt_properties.

    IF lt_properties_multi_idx IS NOT INITIAL.
      "Merge multi and single properties.
      CALL METHOD mo_collector_in->merge_prpty_indexed_multi
        EXPORTING
          it_properties_multi_idx  = lt_properties_multi_idx
        CHANGING
          ct_properties_single_idx = lt_properties_single_idx.
    ENDIF.

    "Merge SP and BAdI properties.
    CALL METHOD mo_collector_in->merge_prpty_indexed_single
      EXPORTING
        it_properties_single_idx = lt_properties_single_idx
      CHANGING
        ct_properties_single_idx = et_properties_single_idx.
    CALL METHOD mo_collector_in->merge_prpty_profiles
      EXPORTING
        it_profile        = lt_properties
      CHANGING
        ct_result_profile = et_properties.
  ENDIF.

*--- Set properties to Collector --------------------------------------*
  CALL METHOD mo_collector_in->set_properties
    EXPORTING
      iv_node_name             = iv_node_name
      iv_target_node_name      = iv_target_node_name
      iv_reference_type        = iv_reference_type
      ig_reference_data        = ig_reference_data
      it_properties_single_idx = et_properties_single_idx
      it_properties            = et_properties.

  "Collect field properties
  /plmb/cl_spi_collector=>set_field_properties( ).
  "Collect operation properties
  /plmb/cl_spi_collector=>set_operation_properties( ).

  IF iv_evaluate_collector_data = abap_true.
    CALL METHOD evaluate_collector_data( abap_true ).
  ENDIF.
  CALL METHOD decrease_callstack.

ENDMETHOD.


METHOD get_succeeded_records.

  DATA:
    lr_node_id               TYPE REF TO    data.
  FIELD-SYMBOLS:
    <ls_node_data>           TYPE           any,
    <ls_node_id>             TYPE           any.

  CLEAR: et_succeeded_node_id.

  IF it_node_id IS INITIAL.
    "Create container for node ID.
    CREATE DATA lr_node_id LIKE LINE OF et_succeeded_node_id.
    ASSIGN lr_node_id->* TO <ls_node_id>.
  ENDIF.

  IF   it_index_failed     IS INITIAL
   AND it_index_failed_rtr IS INITIAL.
    "All records succeeded.
    IF it_node_id IS NOT INITIAL.
      et_succeeded_node_id = it_node_id.
    ELSE.
      LOOP AT it_node_data ASSIGNING <ls_node_data>.
        MOVE-CORRESPONDING <ls_node_data> TO <ls_node_id>.
        INSERT <ls_node_id> INTO TABLE et_succeeded_node_id.
      ENDLOOP.
    ENDIF.
    RETURN.
  ENDIF.

  "Collect succeeded records.
  IF it_node_id IS NOT INITIAL.
    LOOP AT it_node_id ASSIGNING <ls_node_id>.
      IF it_index_failed IS NOT INITIAL.
        READ TABLE it_index_failed TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
      ELSE.
        READ TABLE it_index_failed_rtr TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
      ENDIF.
      IF sy-subrc IS INITIAL.
        "Record failed!
        CONTINUE.
      ENDIF.
      "Record succeeded.
      INSERT <ls_node_id> INTO TABLE et_succeeded_node_id.
    ENDLOOP.
  ELSE.
    LOOP AT it_node_data ASSIGNING <ls_node_data>.
      IF it_index_failed IS NOT INITIAL.
        READ TABLE it_index_failed TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
      ELSE.
        READ TABLE it_index_failed_rtr TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
      ENDIF.
      IF sy-subrc IS INITIAL.
        "Record failed!
        CONTINUE.
      ENDIF.
      "Record succeeded.
      MOVE-CORRESPONDING <ls_node_data> TO <ls_node_id>.
      INSERT <ls_node_id> INTO TABLE et_succeeded_node_id.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD has_unsaved_data.

  DATA:
    lo_connector             TYPE REF TO    /plmb/cl_spi_connector.

  IF io_connector IS NOT INITIAL.
    lo_connector ?= io_connector.
    ev_unsaved_data_exists = lo_connector->mv_unsaved_data.
  ELSE.
    ev_unsaved_data_exists = gv_unsaved_data.
  ENDIF.

ENDMETHOD.


METHOD increase_callstack.

  DATA:
    ls_callstack             TYPE /plmb/s_spi_callstack,
    ls_active_collector_functions      TYPE /plmb/s_spi_coll_function.

  ls_callstack-sp_rtid = io_connector->mv_sp_rtid.
  ls_callstack-abbid   = io_connector->mv_abbid.

  CASE iv_access_method.
    WHEN /plmb/if_spi_c=>gs_c_access_meth-action
      OR /plmb/if_spi_c=>gs_c_access_meth-update
      OR /plmb/if_spi_c=>gs_c_access_meth-insert
      OR /plmb/if_spi_c=>gs_c_access_meth-delete.

      "No key replacement allowed.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-exception.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-message.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-invalidate_nodes.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-invalidate_changed_nodes.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-invalidate_locked_nodes.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-new_node_id.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-operation_properties.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-properties.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.

    WHEN /plmb/if_spi_c=>gs_c_access_meth-query
      OR /plmb/if_spi_c=>gs_c_access_meth-retrieve.

      "No node invalidation and key replacement allowed.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-exception.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-message.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-invalidate_locked_nodes.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-new_node_id.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-operation_properties.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-properties.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.

    WHEN /plmb/if_spi_c=>gs_c_access_meth-get_properties
      OR /plmb/if_spi_c=>gs_c_access_meth-get_operation_properties
      OR /plmb/if_spi_c=>gs_c_access_meth-check_before_save
      OR /plmb/if_spi_c=>gs_c_access_meth-cleanup.

      "Only messages allowed.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-exception.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-message.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.

    WHEN /plmb/if_spi_c=>gs_c_access_meth-save.

      "Messages and key replacement allowed.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-exception.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-message.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.
      ls_active_collector_functions-function = /plmb/cl_spi_collector=>gs_c_coll_function-new_node_id.
      INSERT ls_active_collector_functions INTO TABLE ls_callstack-active_collector_functions.

  ENDCASE.

  INSERT ls_callstack INTO gt_callstack
    INDEX 1.

  /plmb/cl_spi_collector=>set_active_collector_functions( ls_callstack-active_collector_functions ).

ENDMETHOD.


METHOD invalidate_instance.

  DATA:
    lv_delete_successful     TYPE boole_d,
    lo_connector             TYPE REF TO /plmb/cl_spi_connector,
    ls_data                  TYPE /plmb/spi_xstring,
    ls_idata                 TYPE /plmb/spi_xstring,
    ls_abbid                 TYPE /plmb/s_spi_abbid,
    ls_msg                   TYPE symsg.

  lo_connector ?= io_connector.

  CALL METHOD delete_instance_from_buffer
    EXPORTING
      iv_sp_rtid           = lo_connector->mv_sp_rtid
    RECEIVING
      rv_delete_successful = lv_delete_successful.

  IF /plmb/cl_rfc_connector=>is_backend_system( ) = abap_false
    AND lv_delete_successful = abap_true.
    EXPORT iv_abbid            = lo_connector->mv_abbid
           iv_sp_rtid          = lo_connector->mv_sp_rtid
           is_data             = ls_data
           iv_target_method    = /plmb/cl_spi_connector=>gs_c_target_method-invalidate_instance
     TO DATA BUFFER  ls_idata
         COMPRESSION ON.

    CALL METHOD /plmb/cl_rfc_connector=>rfc_call
      EXPORTING
        iv_class_name = gc_class_name
        is_data       = ls_idata
      IMPORTING
        es_message    = ls_msg.

    IF ls_msg IS NOT INITIAL.
      RAISE EXCEPTION TYPE /plmb/cx_spi_error
        EXPORTING
          textid = /plmb/cx_spi_error=>runtime_error
          msgv1  = ls_msg-msgv1
          msgv2  = ls_msg-msgv2.
    ENDIF.
  ENDIF.

  CALL METHOD evaluate_collector_options.

ENDMETHOD.


METHOD invalidate_node_id_implicit.

  DATA:
    ls_invalid_node          TYPE /plmb/s_spi_coll_invalid_node,
    lt_invalid_node          TYPE /plmb/t_spi_coll_invalid_node.

  FIELD-SYMBOLS:
    <ls_node_id>             TYPE any.

  "The scenario here is the following:
  "Via Connector instance 1 e.g. an update was triggered,
  "Connector instance 2 belongs to the same ABBID but doesn't
  "know about the existance of instance 1.
  "To ensure that also instance 2 can react on all data changes
  "we need to spread this invalidation info.

  ls_invalid_node-abbid     = mv_abbid.
  ls_invalid_node-node_name = iv_node_name.
  IF it_node_id IS NOT INITIAL.
    ls_invalid_node-scope     = /plmb/if_spi_c=>gs_c_invalidation_scope-id_only.
  ENDIF.
  ls_invalid_node-reason    = iv_reason.
  LOOP AT it_node_id ASSIGNING <ls_node_id>.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>convert_structure_to_xstring
      EXPORTING
        is_node_id         = <ls_node_id>
      IMPORTING
        ev_node_id_xstring = ls_invalid_node-node_id.
    INSERT ls_invalid_node INTO TABLE lt_invalid_node.
  ENDLOOP.

  IF it_node_id IS INITIAL.
    INSERT ls_invalid_node INTO TABLE lt_invalid_node.
  ENDIF.

  "Since the caller of the update (in the above example)
  "already gets the up-to-date data via the export parameters
  "we fill now only the dependent nodes into his collector.
  CALL METHOD mo_collector_in->invalidate_dependent_nodes
    EXPORTING
      iv_abbid     = mv_abbid
      iv_sp_rtid   = mv_sp_rtid
      io_mp        = mo_mp
      iv_node_name = iv_node_name.

  "The "foreign" collectors which belong to the same ABBID
  "will receive the complete invalidation info based on the result
  "of the method call.
  CALL METHOD mo_collector_in->spread_invalid_node
    EXPORTING
      it_invalid_node   = lt_invalid_node
      iv_exclude_myself = abap_true.

ENDMETHOD.


METHOD is_supplied.

  DATA:
    lo_datadescr  TYPE REF TO cl_abap_datadescr,
    lo_tabledescr TYPE REF TO cl_abap_tabledescr.

  IF ig_param IS INITIAL.
    TRY.
        lo_datadescr ?= cl_abap_datadescr=>describe_by_data( ig_param ).
        IF lo_datadescr->get_relative_name( ) IS INITIAL.
          IF lo_datadescr->kind = cl_abap_datadescr=>kind_table.
            lo_tabledescr ?= lo_datadescr.
            lo_datadescr  = lo_tabledescr->get_table_line_type( ).
          ENDIF.
          IF    lo_datadescr->kind      = cl_abap_datadescr=>kind_elem
            AND lo_datadescr->type_kind = cl_abap_datadescr=>typekind_char.
            RETURN.
          ENDIF.
        ENDIF.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.
  ENDIF.

  rv_is_supplied = abap_true.

ENDMETHOD.


METHOD pull_properties.

  DATA:
    lr_node_data_table_trans TYPE REF TO data,  "Container for the data table
    lr_node_id_struc         TYPE REF TO data,  "Container for the ID structure
    lr_node_id_table         TYPE REF TO data,  "Container for the ID table
    lo_metadata_node         TYPE REF TO /plmb/if_spi_metadata_node,
    lv_node_name             TYPE /plmb/spi_node_name,
    lt_index_failed_rtr      TYPE /plmb/t_spi_rtr_index_failed,
    lt_index_failed	         TYPE /plmb/t_spi_index_failed,
    ls_requested_properties  TYPE /plmb/s_spi_supported_property,
    lt_requested_fields      TYPE /plmb/t_spi_requested_field.

  FIELD-SYMBOLS:
    <lt_transient_node_data>  TYPE INDEX TABLE,
    <ls_node_data>            TYPE any,
    <lt_node_id>              TYPE INDEX TABLE,
    <ls_node_id>              TYPE any.

  "Determine target node name.
  lv_node_name = mo_mp->/plmb/if_spi_metadata_output~determine_target_node(
    iv_node_name         = iv_node_name
    iv_target_node_name  = iv_target_node_name ).

  "Check if node requires pull.
  CALL METHOD get_auto_pull_focus
    EXPORTING
      iv_node_name            = lv_node_name
      iv_operation_type       = iv_operation_type
      iv_operation_name       = iv_operation_name
    IMPORTING
      es_requested_properties = ls_requested_properties
      et_requested_fields     = lt_requested_fields.
  IF ls_requested_properties IS INITIAL.
    RETURN.
  ENDIF.

  "Check if nothing could be read at all.
  IF it_node_id IS NOT INITIAL.
    IF it_index_failed IS NOT INITIAL.
      lt_index_failed = it_index_failed.
      SORT lt_index_failed BY index.
      DELETE ADJACENT DUPLICATES FROM lt_index_failed COMPARING index.
      IF lines( it_node_id ) <= lines( lt_index_failed ).
        RETURN.
      ENDIF.
    ELSEIF it_index_failed_rtr IS NOT INITIAL.
      lt_index_failed_rtr = it_index_failed_rtr.
      DELETE lt_index_failed_rtr WHERE reason_code <> /plmb/if_spi_c=>gs_c_reason_code-key_not_found.
      SORT lt_index_failed_rtr BY index.
      DELETE ADJACENT DUPLICATES FROM lt_index_failed_rtr COMPARING index.
      IF lines( it_node_id ) <= lines( lt_index_failed_rtr ).
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

*--- Node properties --------------------------------------------------*
  IF ls_requested_properties-fields-node = abap_true.
    CALL METHOD get_properties
      EXPORTING
        iv_node_name       = lv_node_name
        iv_reference_type  = /plmb/if_spi_c=>gs_c_prpty_ref_type-node
        it_requested_field = lt_requested_fields.
  ENDIF.
  IF ls_requested_properties-operations-node = abap_true.
    CALL METHOD get_operation_properties
      EXPORTING
        iv_node_name      = lv_node_name
        iv_reference_type = /plmb/if_spi_c=>gs_c_opr_prpty_ref_type-node.
  ENDIF.

*--- Insert field properties ------------------------------------------*
  IF ls_requested_properties-fields-insert = abap_true.
    CALL METHOD get_properties
      EXPORTING
        iv_node_name       = lv_node_name
        iv_reference_type  = /plmb/if_spi_c=>gs_c_prpty_ref_type-insert
        it_requested_field = lt_requested_fields.
  ENDIF.

*--- Properties by association ----------------------------------------*
  IF   iv_target_node_name IS NOT INITIAL
   AND ( it_node_id        IS NOT INITIAL
    OR   is_node_id        IS NOT INITIAL ).

    "Collect node IDs that did not fail.
    "RETRIEVE
    IF it_node_id IS NOT INITIAL.
      IF it_index_failed_rtr IS INITIAL.
        ASSIGN it_node_id TO <lt_node_id>.
      ELSE.
        CREATE DATA lr_node_id_table LIKE it_node_id.
        ASSIGN lr_node_id_table->* TO <lt_node_id>.
        LOOP AT it_node_id ASSIGNING <ls_node_id>.
          READ TABLE lt_index_failed_rtr TRANSPORTING NO FIELDS
            WITH KEY index = sy-tabix
            BINARY SEARCH.
          IF sy-subrc NE 0.
            INSERT <ls_node_id> INTO TABLE <lt_node_id>.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSEIF is_node_id IS NOT INITIAL.
      "INSERT
      TRY.
          "Get metadata info for the parent node.
          lo_metadata_node = mo_mp->/plmb/if_spi_metadata~get_node_metadata( iv_node_name ).
          "Get a container for the node IDs.
          CALL METHOD lo_metadata_node->get_id_container
            IMPORTING
              er_id_table = lr_node_id_table.
          ASSIGN lr_node_id_table->*   TO <lt_node_id>.
          INSERT is_node_id INTO TABLE <lt_node_id>.
        CATCH /plmb/cx_spi_metadata.
          RAISE EXCEPTION TYPE /plmb/cx_spi_error
            EXPORTING
              textid    = /plmb/cx_spi_error=>node_typization_insufficient
              abbid     = mv_abbid
              node_name = lv_node_name.
      ENDTRY.
    ENDIF.

    "Insert by associaton field properties
    IF ls_requested_properties-fields-insert_by_association = abap_true.
      CALL METHOD get_properties
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          ig_reference_data   = <lt_node_id>
          iv_reference_type   = /plmb/if_spi_c=>gs_c_prpty_ref_type-insert_by_association
          it_requested_field  = lt_requested_fields.
    ENDIF.

    "Data record by association field properties
    IF ls_requested_properties-fields-data_records_by_association = abap_true.
      CALL METHOD get_properties
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          ig_reference_data   = <lt_node_id>
          iv_reference_type   = /plmb/if_spi_c=>gs_c_prpty_ref_type-data_records_by_association
          it_requested_field  = lt_requested_fields.
    ENDIF.

    "Data record by association operation properties
    IF ls_requested_properties-operations-data_records_by_association = abap_true.
      CALL METHOD get_operation_properties
        EXPORTING
          iv_node_name        = iv_node_name
          iv_target_node_name = iv_target_node_name
          ig_reference_data   = <lt_node_id>
          iv_reference_type   = /plmb/if_spi_c=>gs_c_opr_prpty_ref_type-data_records_by_association.
    ENDIF.
  ENDIF.

*--- Data record properties -------------------------------------------*
  IF it_node_data_out IS NOT INITIAL
    AND (    ls_requested_properties-fields-data_record     = abap_true
          OR ls_requested_properties-operations-data_record = abap_true ).

    TRY.
        "Get metadata info for the current node.
        lo_metadata_node = mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
        "Get a container for the node IDs.
        CALL METHOD lo_metadata_node->get_id_container
          IMPORTING
            er_id_structure = lr_node_id_struc
            er_id_table     = lr_node_id_table.
        ASSIGN lr_node_id_table->*   TO <lt_node_id>.
        ASSIGN lr_node_id_struc->*   TO <ls_node_id>.
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = lv_node_name.
    ENDTRY.

    "Extract node IDs from output node data.
    LOOP AT it_node_data_out ASSIGNING <ls_node_data>.
      MOVE-CORRESPONDING <ls_node_data> TO <ls_node_id>.
      INSERT <ls_node_id> INTO TABLE <lt_node_id>.
    ENDLOOP.

    "Data record field properties.
    IF ls_requested_properties-fields-data_record = abap_true.
      CALL METHOD get_properties
        EXPORTING
          iv_node_name       = lv_node_name
          ig_reference_data  = <lt_node_id>
          iv_reference_type  = /plmb/if_spi_c=>gs_c_prpty_ref_type-data_record
          it_requested_field = lt_requested_fields.
    ENDIF.

    "Data record operation properties.
    IF ls_requested_properties-operations-data_record = abap_true.
      CALL METHOD get_operation_properties
        EXPORTING
          iv_node_name      = lv_node_name
          ig_reference_data = <lt_node_id>
          iv_reference_type = /plmb/if_spi_c=>gs_c_opr_prpty_ref_type-data_record.
    ENDIF.
  ENDIF.

*--- Transient data record properties ---------------------------------*
  IF    it_index_failed IS NOT INITIAL
    AND it_node_data_in IS NOT INITIAL
    AND ls_requested_properties-fields-transient_data_record = abap_true.

    TRY.
        "Get a container for failed node data.
        IF lo_metadata_node IS INITIAL.
          lo_metadata_node = mo_mp->/plmb/if_spi_metadata~get_node_metadata( lv_node_name ).
        ENDIF.
        CALL METHOD lo_metadata_node->get_data_container
          IMPORTING
            er_data_table = lr_node_data_table_trans.
        ASSIGN lr_node_data_table_trans->* TO <lt_transient_node_data>.
      CATCH /plmb/cx_spi_metadata.
        RAISE EXCEPTION TYPE /plmb/cx_spi_error
          EXPORTING
            textid    = /plmb/cx_spi_error=>node_typization_insufficient
            abbid     = mv_abbid
            node_name = lv_node_name.
    ENDTRY.

    "Collect failed node data.
    CALL METHOD get_failed_node_data
      EXPORTING
        iv_node_name        = lv_node_name
        it_node_data        = it_node_data_in
        it_index_failed     = it_index_failed
      IMPORTING
        et_failed_node_data = <lt_transient_node_data>.

    "Transient data record field properties
    IF ls_requested_properties-fields-transient_data_record = abap_true.
      CALL METHOD get_properties
        EXPORTING
          iv_node_name       = lv_node_name
          ig_reference_data  = <lt_transient_node_data>
          iv_reference_type  = /plmb/if_spi_c=>gs_c_prpty_ref_type-transient_data_record
          it_requested_field = lt_requested_fields.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD without_commit.

* Sets Connector as irresponsible for commit / rollback
  gv_without_commit = abap_true.

ENDMETHOD.
ENDCLASS.