class /PLMU/CL_FRW_BASIC_APPL_MODEL definition
  public
  create public .

public section.
  class CL_WD_DYNAMIC_TOOL definition load .

  interfaces /PLMU/IF_FRW_APPL_MODEL_INT .
  interfaces /PLMU/IF_FRW_BASIC_APPL_MODEL .

  class-methods CLASS_CONSTRUCTOR .
  interface /PLMU/IF_FRW_APPL_MODEL_INT load .
  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !IV_ABBID type /PLMB/SPI_ABBID
      !IV_RUNTIME_ID type STRING optional
      !IS_COLL_DATA_PROCESSING_MODE type /PLMU/IF_FRW_APPL_MODEL_INT=>GTY_S_COLL_DATA_PROC_MODE default /PLMU/IF_FRW_APPL_MODEL_INT=>GC_COLL_DATA_PROC_MODE_DEFAULT
      !IV_CREATE_TOOL type BOOLE_D default ABAP_TRUE .
protected section.

  types:
    BEGIN OF gty_s_collector_data_cache,
      field_properties     TYPE /plmb/t_spi_coll_prpty_enh,
      operation_properties TYPE /plmb/t_spi_coll_opr_prp_enh,
      messages             TYPE /plmb/t_spi_coll_message_enh,
    END   OF gty_s_collector_data_cache .

  data MO_COLLECTOR_OUTPUT type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT .
  data MO_RETRIEVE_FILTER type ref to /PLMU/CL_FRW_RETR_FILTER .
  data MS_COLLECTOR_DATA_CACHE type GTY_S_COLLECTOR_DATA_CACHE .
  interface /PLMU/IF_FRW_APPL_MODEL_INT load .
  data MS_COLL_DATA_PROCESSING_MODE type /PLMU/IF_FRW_APPL_MODEL_INT=>GTY_S_COLL_DATA_PROC_MODE .
  data MV_IS_ALIVE type BOOLE_D .

  methods APPLY_FIELD_PROPERTIES
    importing
      !IT_PROPERTIES type /PLMB/T_SPI_COLL_PRPTY_ENH .
  methods APPLY_NODE_INVALIDATION
    importing
      !IT_INVALID_NODE type /PLMB/T_SPI_COLL_INVALID_NODE .
  methods APPLY_OPERATION_PROPERTIES
    importing
      !IT_PROPERTIES type /PLMB/T_SPI_COLL_OPR_PRP_ENH .
  methods PROCESS_AFTER_ACTION
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_IN_ACTION_NAME type /PLMB/SPI_ACTION_NAME
      !IT_IN_NODE_ID type INDEX TABLE
      !IS_IN_PARAM type ANY
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED
      !IT_OUT_NODE_DATA type INDEX TABLE
      !IG_OUT_PARAM type ANY
    exporting
      !EV_ALL_RECORDS_FAILED type BOOLE_D .
  methods PROCESS_AFTER_DELETE
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_IN_NODE_ID type INDEX TABLE
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED
    exporting
      !EV_ALL_RECORDS_FAILED type BOOLE_D
      !ET_SUCCEEDED_NODE_ID type INDEX TABLE .
  methods PROCESS_AFTER_INSERT
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_IN_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_IN_NODE_DATA type INDEX TABLE
      !IS_IN_NODE_ID type ANY
      !IS_IN_PARAM type ANY
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED
      !IT_OUT_NODE_DATA type INDEX TABLE
    exporting
      !ET_SUCCEEDED_NODE_DATA type INDEX TABLE
      !EV_ALL_RECORDS_FAILED type BOOLE_D
    changing
      !CT_OUT_NODE_ID_REL type /PLMB/T_SPI_NODE_REL .
  methods PROCESS_AFTER_QUERY
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_IN_QUERY_NAME type /PLMB/SPI_QUERY_NAME
      !IT_IN_SEL_PARAM type /PLMB/T_SPI_SELECTION_PARAM
      !IS_IN_OPTIONS type /PLMB/S_SPI_QUERY_OPTIONS
      !IV_IN_KEYS_ONLY type /PLMB/SPI_KEYS_ONLY_IND
      !IT_IN_FILTER_NODE_ID type INDEX TABLE
      !IT_IN_REQUESTED_FIELD type /PLMB/T_SPI_REQUESTED_FIELD
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_NODE_ID type INDEX TABLE
      !IT_OUT_NODE_DATA type INDEX TABLE
    changing
      !CT_OUT_NODE_ID_REL type /PLMB/T_SPI_NODE_REL .
  methods PROCESS_AFTER_RETRIEVE
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_IN_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_IN_NODE_ID type INDEX TABLE
      !IV_IN_LOCK type /PLMB/SPI_LOCK_IND
      !IT_IN_REQUESTED_FIELD type /PLMB/T_SPI_REQUESTED_FIELD
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_NODE_DATA type INDEX TABLE
      !IT_FILTERED_NODE_ID type INDEX TABLE
      !IV_INDEX_FAILED_REQUESTED type BOOLE_D
      !IV_NODE_ID_REL_REQUESTED type BOOLE_D
    exporting
      !EV_ALL_RECORDS_FAILED type BOOLE_D
    changing
      !CT_OUT_INDEX_FAILED type /PLMB/T_SPI_RTR_INDEX_FAILED
      !CT_OUT_NODE_ID_REL type /PLMB/T_SPI_NODE_REL .
  methods PROCESS_AFTER_UPDATE
    importing
      !IV_IN_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_IN_NODE_DATA type INDEX TABLE
      !IT_IN_CHANGED_FIELD type /PLMB/T_SPI_CHANGED_FIELD
      !IV_OUT_FAILED type /PLMB/SPI_FAILED_IND
      !IT_OUT_INDEX_FAILED type /PLMB/T_SPI_INDEX_FAILED
      !IT_OUT_NODE_DATA type INDEX TABLE
    exporting
      !EV_ALL_RECORDS_FAILED type BOOLE_D
      !ET_SUCCEEDED_NODE_DATA type INDEX TABLE
    changing
      !CT_OUT_NODE_ID_REL type /PLMB/T_SPI_NODE_REL .
  methods PROCESS_BEFORE_ACTION
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_ACTION_NAME type /PLMB/SPI_ACTION_NAME
      !IT_NODE_ID type INDEX TABLE
      !IS_PARAM type ANY
    exporting
      !EV_SUPPLY_OUT_NODE_DATA type BOOLE_D .
  methods PROCESS_BEFORE_DELETE
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
    changing
      !CT_NODE_ID type INDEX TABLE .
  methods PROCESS_BEFORE_INSERT
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_NODE_DATA type INDEX TABLE
      !IS_NODE_ID type ANY
      !IS_PARAM type ANY
    exporting
      !EV_SUPPLY_OUT_NODE_DATA type BOOLE_D .
  methods PROCESS_BEFORE_QUERY
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_QUERY_NAME type /PLMB/SPI_QUERY_NAME
      !IT_SEL_PARAM type /PLMB/T_SPI_SELECTION_PARAM
      !IS_OPTIONS type /PLMB/S_SPI_QUERY_OPTIONS
      !IV_KEYS_ONLY type /PLMB/SPI_KEYS_ONLY_IND
      !IT_FILTER_NODE_ID type INDEX TABLE
      !IT_REQUESTED_FIELD type /PLMB/T_SPI_REQUESTED_FIELD
    exporting
      !EV_SUPPLY_OUT_NODE_DATA type BOOLE_D
      !EV_SKIP_QUERY type BOOLE_D .
  methods PROCESS_BEFORE_RETRIEVE
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_NODE_ID type INDEX TABLE
      !IV_LOCK type /PLMB/SPI_LOCK_IND
      !IT_REQUESTED_FIELD type /PLMB/T_SPI_REQUESTED_FIELD
    exporting
      !ET_FILTERED_NODE_ID type INDEX TABLE
      !EV_SKIP_RETRIEVE type BOOLE_D
      !EV_SUPPLY_OUT_NODE_DATA type BOOLE_D .
  methods PROCESS_BEFORE_UPDATE
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_NODE_DATA type INDEX TABLE
      !IT_CHANGED_FIELD type /PLMB/T_SPI_CHANGED_FIELD
    exporting
      !EV_SUPPLY_OUT_NODE_DATA type BOOLE_D .
private section.

  class-data GO_CONTEXT_POOL type ref to /PLMU/CL_FRW_CONTEXT_POOL .
  class-data GO_MESSAGE_MANAGER type ref to /PLMU/CL_FRW_MESSAGE_MANAGER .
  class-data GO_RETRIEVE_FILTER_POOL type ref to /PLMU/CL_FRW_RETR_FILTER_POOL .
  data MO_APPL_ACCESS type ref to /PLMB/IF_SPI_APPL_ACCESS .
  data MV_RUNTIME_ID type STRING .
  data MV_SP_WAS_CALLED type BOOLE_D .

  methods CACHE_MESSAGES .
  methods HNDL_NEW_COLLECTOR_DATA
    for event NEW_DATA_AVAILABLE of /PLMB/IF_SPI_COLLECTOR_OUTPUT
    importing
      !IS_AVAILABLE_DATA .
  methods HNDL_UNSAVED_DATA_EXISTS
    for event UNSAVED_DATA_EXISTS of /PLMB/CL_SPI_CONNECTOR
    importing
      !IV_UNSAVED_DATA_EXISTS .
ENDCLASS.



CLASS /PLMU/CL_FRW_BASIC_APPL_MODEL IMPLEMENTATION.


METHOD /plmu/if_frw_appl_model_int~cache_field_properties.

  DATA:
    lv_abbid                 TYPE           /plmb/spi_abbid,
    lr_fld_properties        TYPE REF TO    /plmb/t_spi_coll_prpty_enh,
    lt_fld_properties        TYPE           /plmb/t_spi_coll_prpty_enh.
  FIELD-SYMBOLS:
    <ls_fld_properties>      TYPE           /plmb/s_spi_coll_prpty_enh,
    <ls_fld_props_cache>     TYPE           /plmb/s_spi_coll_prpty_enh,
    <ls_prop>                TYPE           /plmb/s_spi_properties.

  IF ms_coll_data_processing_mode-field_properties = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    "Field properties
    RETURN.
  ENDIF.

  "Get new field properties from the collector.
  mo_collector_output->get_properties_enh(
    EXPORTING iv_node_name        = iv_node_name
              iv_target_node_name = iv_target_node_name
              iv_reference_type   = iv_reference_type
              ig_reference_data   = ig_reference_data
              iv_init_buffer      = abap_true
    IMPORTING et_properties       = lt_fld_properties ).

  "Cache field properties.
  IF ms_collector_data_cache-field_properties IS INITIAL.
    ms_collector_data_cache-field_properties = lt_fld_properties.
  ELSE.
    LOOP AT lt_fld_properties ASSIGNING <ls_fld_properties>.
      "Insert record into cache for later field property processing
      INSERT <ls_fld_properties> INTO TABLE ms_collector_data_cache-field_properties.
      IF sy-subrc IS NOT INITIAL.
        "Entry already exists => adjust field property cache
        READ TABLE ms_collector_data_cache-field_properties ASSIGNING <ls_fld_props_cache>
          WITH TABLE KEY node_name = <ls_fld_properties>-node_name
                         target_node_name = <ls_fld_properties>-target_node_name
                         reference_type   = <ls_fld_properties>-reference_type
                         reference_data   = <ls_fld_properties>-reference_data.
        LOOP AT <ls_fld_properties>-properties ASSIGNING <ls_prop>.
          "Replace / insert new property option
          DELETE TABLE <ls_fld_props_cache>-properties
            WITH TABLE KEY node_field = <ls_prop>-node_field.
          INSERT <ls_prop> INTO TABLE <ls_fld_props_cache>-properties.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

  "Publish new properties via event
  IF lt_fld_properties IS NOT INITIAL.
    lv_abbid = /plmu/if_frw_basic_appl_model~mo_metadata->get_abbid( ).
    GET REFERENCE OF lt_fld_properties INTO lr_fld_properties.
    RAISE EVENT /plmu/if_frw_appl_model_int~after_collect_properties
      EXPORTING iv_abbid          = lv_abbid
                ir_fld_properties = lr_fld_properties.
  ENDIF.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~cache_operation_properties.

  DATA:
    lv_abbid                 TYPE           /plmb/spi_abbid,
    lr_opr_properties        TYPE REF TO    /plmb/t_spi_coll_opr_prp_enh,
    lt_opr_properties        TYPE           /plmb/t_spi_coll_opr_prp_enh.
  FIELD-SYMBOLS:
    <ls_opr_properties>      TYPE           /plmb/s_spi_coll_opr_prp_enh,
    <ls_opr_props_cache>     TYPE           /plmb/s_spi_coll_opr_prp_enh,
    <ls_opr_prop>            TYPE           /plmb/s_spi_operation_prpty.

  IF ms_coll_data_processing_mode-operation_properties = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    RETURN.
  ENDIF.

  "Get new operation properties from the collector.
  mo_collector_output->get_operation_properties_enh(
    EXPORTING iv_node_name        = iv_node_name
              iv_target_node_name = iv_target_node_name
              iv_reference_type   = iv_reference_type
              ig_reference_data   = ig_reference_data
              iv_init_buffer      = abap_true
    IMPORTING et_opr_properties   = lt_opr_properties ).

  "Cache operation properties.
  IF ms_collector_data_cache-operation_properties IS INITIAL.
    ms_collector_data_cache-operation_properties = lt_opr_properties.
  ELSE.
    LOOP AT lt_opr_properties ASSIGNING <ls_opr_properties>.
      "Insert record into cache for later field property processing
      INSERT <ls_opr_properties> INTO TABLE ms_collector_data_cache-operation_properties.
      IF sy-subrc IS NOT INITIAL.
        "Entry already exists => adjust field property cache
        READ TABLE ms_collector_data_cache-operation_properties ASSIGNING <ls_opr_props_cache>
          WITH TABLE KEY node_name = <ls_opr_properties>-node_name
                         target_node_name = <ls_opr_properties>-target_node_name
                         reference_type   = <ls_opr_properties>-reference_type
                         reference_data   = <ls_opr_properties>-reference_data.
        LOOP AT <ls_opr_properties>-properties ASSIGNING <ls_opr_prop>.
          "Replace / insert new property option
          DELETE TABLE <ls_opr_props_cache>-properties
            WITH TABLE KEY operation_type = <ls_opr_prop>-operation_type
                           action_name    = <ls_opr_prop>-action_name.
          INSERT <ls_opr_prop> INTO TABLE <ls_opr_props_cache>-properties.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

*--------------- Publish new properties via event ---------------------*
  IF lt_opr_properties IS NOT INITIAL.
    lv_abbid = /plmu/if_frw_basic_appl_model~mo_metadata->get_abbid( ).
    GET REFERENCE OF lt_opr_properties INTO lr_opr_properties.
    RAISE EVENT /plmu/if_frw_appl_model_int~after_collect_properties
      EXPORTING iv_abbid          = lv_abbid
                ir_opr_properties = lr_opr_properties.
  ENDIF.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~check_before_save.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-check_before_save.

  mo_appl_access->check_before_save(
    IMPORTING ev_failed = ev_failed ).

  mv_sp_was_called = abap_true.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-check_before_save ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-check_before_save
      iv_all_records_failed = ev_failed.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~clean_up.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  IF iv_ui_only = abap_true.
    RETURN.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-clean_up.

  mo_appl_access->clean_up(
    EXPORTING iv_reason = iv_reason ).

  mv_sp_was_called = abap_true.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-clean_up ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-clean_up
      iv_all_records_failed = abap_false.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~clear_messages.

  "Clear all messages that were cached before.
  "(The collector already was initialized when the cache was filled)
  CLEAR ms_collector_data_cache-messages.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~destruct.

  DATA:
    lv_unsaved_data          TYPE           boole_d,
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_destruction
    EXPORTING io_appl_model = me.

  "Destruct containing instances
  /plmb/cl_spi_connector=>invalidate_instance(
    EXPORTING io_connector = mo_appl_access ).
  mo_retrieve_filter->destruct( ).
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->destruct( ).

  IF iv_changes_reverted <> abap_true.
    /plmb/cl_spi_connector=>has_unsaved_data(
      EXPORTING io_connector           = mo_appl_access
      IMPORTING ev_unsaved_data_exists = lv_unsaved_data ).
    IF lv_unsaved_data = abap_true.
      RAISE EVENT /plmu/if_frw_appl_model_int~unsaved_data_locked.
    ENDIF.
  ENDIF.

  "Deactivate event handler.
  SET HANDLER: hndl_new_collector_data FOR mo_collector_output ACTIVATION abap_false,
               hndl_unsaved_data_exists ACTIVATION abap_false.

  "Clear member attributes.
  CLEAR: /plmu/if_frw_basic_appl_model~mo_metadata,
         /plmu/if_frw_basic_appl_model~mo_tools,
         /plmu/if_frw_basic_appl_model~mv_unsaved_data,
         mo_appl_access,
         mo_collector_output,
         mo_retrieve_filter,
         ms_collector_data_cache,
         ms_coll_data_processing_mode,
         mv_is_alive,
         mv_runtime_id.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~get_coll_data_processing_mode.

  es_coll_data_processing_mode = ms_coll_data_processing_mode.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~get_runtime_id.

  rv_runtime_id = mv_runtime_id.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~is_alive.

  IF mv_is_alive = abap_false.
    rv_is_alive = abap_false.
    RETURN.
  ENDIF.

  rv_is_alive = abap_true.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~process_field_properties.

  DATA:
    lt_field_properties      TYPE           /plmb/t_spi_coll_prpty_enh.

  IF ms_collector_data_cache-field_properties IS INITIAL.
    "Field property cache is empty.
    RETURN.
  ENDIF.

  "Copy properties and clear buffer before processing.
  lt_field_properties = ms_collector_data_cache-field_properties.
  CLEAR: ms_collector_data_cache-field_properties.

  "Apply field properties.
  apply_field_properties(
    EXPORTING it_properties = lt_field_properties ).

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~process_messages.

  DATA:
    lv_msg_index             TYPE           sytabix,
    ls_symsg                 TYPE           symsg,
    ls_msg_free_text         TYPE           /plmb/s_spi_msg_free_text,
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool,
    lt_message               TYPE           /plmb/t_spi_coll_message_enh.
  FIELD-SYMBOLS:
    <ls_message>             TYPE           /plmb/s_spi_coll_message_enh.

  IF ms_collector_data_cache-messages IS INITIAL.
    "Message cache is empty.
    RETURN.
  ENDIF.

  "Copy messages and clear buffer before processing.
  lt_message = ms_collector_data_cache-messages.
  CLEAR ms_collector_data_cache-messages.

  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->/plmu/if_frw_message_mapper~map_messages(
    EXPORTING io_metadata = /plmu/if_frw_basic_appl_model~mo_metadata
    CHANGING  ct_message  = lt_message ).

  IF lt_message IS INITIAL.
    "Messages were deleted by message mapper.
    RETURN.
  ENDIF.

  "Publish messages.
  LOOP AT lt_message ASSIGNING <ls_message>.
    lv_msg_index = lv_msg_index + 1.
    IF <ls_message>-msgid IS NOT INITIAL.
      MOVE-CORRESPONDING <ls_message> TO ls_symsg.
      go_message_manager->/plmu/if_frw_message_manager~publish_message(
        EXPORTING iv_message_index = lv_msg_index
                  is_message       = ls_symsg ).
    ELSEIF <ls_message>-msg_free_text IS NOT INITIAL.
      MOVE-CORRESPONDING <ls_message> TO ls_msg_free_text.
      go_message_manager->/plmu/if_frw_message_manager~publish_message_free_text(
        EXPORTING iv_message_index = lv_msg_index
                  is_message       = ls_msg_free_text ).
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~process_operation_properties.

  DATA:
    lt_operation_properties  TYPE           /plmb/t_spi_coll_opr_prp_enh.

  IF ms_collector_data_cache-operation_properties IS INITIAL.
    "Operation property cache is empty.
    RETURN.
  ENDIF.

  "Copy properties and clear buffer before processing.
  lt_operation_properties = ms_collector_data_cache-operation_properties.
  CLEAR: ms_collector_data_cache-operation_properties.

  "Apply operation properties.
  apply_operation_properties(
    EXPORTING it_properties = lt_operation_properties ).

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~save.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  CLEAR ev_failed.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-save.

  mo_appl_access->save(
    IMPORTING ev_failed = ev_failed ).

  mv_sp_was_called = abap_true.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-save ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-save
      iv_all_records_failed = ev_failed.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~set_coll_data_processing_mode.

  "Set processing modes for collector data.
  IF iv_messages IS SUPPLIED.
    ms_coll_data_processing_mode-messages = iv_messages.
  ENDIF.
  IF iv_field_properties IS SUPPLIED.
    ms_coll_data_processing_mode-field_properties = iv_field_properties.
  ENDIF.
  IF iv_invalid_nodes IS SUPPLIED.
    ms_coll_data_processing_mode-invalid_nodes = iv_invalid_nodes.
  ENDIF.
  IF iv_key_replacement IS SUPPLIED.
    ms_coll_data_processing_mode-key_replacement = iv_key_replacement.
  ENDIF.
  IF iv_operation_properties IS SUPPLIED.
    ms_coll_data_processing_mode-operation_properties = iv_operation_properties.
  ENDIF.

ENDMETHOD.


METHOD /plmu/if_frw_appl_model_int~was_sp_called.

  rv_result = mv_sp_was_called.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~action.

  DATA:
    lv_supply_node_data      TYPE           boole_d,
    lv_all_records_failed    TYPE           boole_d,
    lr_node_data             TYPE REF TO    data,
    lo_node_metadata         TYPE REF TO    /plmb/if_spi_metadata_node.
  FIELD-SYMBOLS:
    <lt_node_data>           TYPE           INDEX TABLE.

  CLEAR: et_node_data,
         ev_failed,
         et_index_failed.

  process_before_action(
    EXPORTING iv_node_name            = iv_node_name
              iv_action_name          = iv_action_name
              it_node_id              = it_node_id
              is_param                = is_param
    IMPORTING ev_supply_out_node_data = lv_supply_node_data ).

  IF et_node_data IS SUPPLIED.
    "Node data requested from method caller.
    lv_supply_node_data = abap_true.
  ENDIF.

  IF lv_supply_node_data = abap_true.
    "Get data container for node data.
    lo_node_metadata = /plmu/if_frw_basic_appl_model~mo_metadata->get_node_metadata( iv_node_name ).
    TRY.
        lo_node_metadata->get_data_container(
          IMPORTING er_data_table = lr_node_data ).
        ASSIGN lr_node_data->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        "Node data typization is not specified in the metadata provider,
        "therefore we cannot import the node data from SPI.
        lv_supply_node_data = abap_false.
        "Assign dummy.
        ASSIGN et_node_data TO <lt_node_data>.
    ENDTRY.
  ELSE.
    "Assign dummy.
    ASSIGN et_node_data TO <lt_node_data>.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-action.

  "Call SPI action...
  IF lv_supply_node_data = abap_true.
    "...with node data and param exporting.
    IF eg_param IS SUPPLIED.
      mo_appl_access->action(
        EXPORTING iv_node_name    = iv_node_name
                  iv_action_name  = iv_action_name
                  it_node_id      = it_node_id
                  is_param        = is_param
        IMPORTING ev_failed       = ev_failed
                  et_index_failed = et_index_failed
                  et_node_data    = <lt_node_data>
                  eg_param        = eg_param ).
    ELSE.
      "...with node data but without param exporting.
      mo_appl_access->action(
        EXPORTING iv_node_name    = iv_node_name
                  iv_action_name  = iv_action_name
                  it_node_id      = it_node_id
                  is_param        = is_param
        IMPORTING ev_failed       = ev_failed
                  et_index_failed = et_index_failed
                  et_node_data    = <lt_node_data> ).
    ENDIF.
  ELSE.
    IF eg_param IS SUPPLIED.
      "...without node data but with param exporting.
      mo_appl_access->action(
        EXPORTING iv_node_name    = iv_node_name
                  iv_action_name  = iv_action_name
                  it_node_id      = it_node_id
                  is_param        = is_param
        IMPORTING ev_failed       = ev_failed
                  et_index_failed = et_index_failed
                  eg_param        = eg_param ).
    ELSE.
      "...without node data and param exporting.
      mo_appl_access->action(
        EXPORTING iv_node_name    = iv_node_name
                  iv_action_name  = iv_action_name
                  it_node_id      = it_node_id
                  is_param        = is_param
        IMPORTING ev_failed       = ev_failed
                  et_index_failed = et_index_failed ).
    ENDIF.
  ENDIF.

  mv_sp_was_called = abap_true.

  IF et_node_data IS SUPPLIED.
    "Fill export parameter.
    et_node_data = <lt_node_data>.
  ENDIF.

  process_after_action(
    EXPORTING iv_in_node_name       = iv_node_name
              iv_in_action_name     = iv_action_name
              it_in_node_id         = it_node_id
              is_in_param           = is_param
              iv_out_failed         = ev_failed
              it_out_index_failed   = et_index_failed
              it_out_node_data      = <lt_node_data>
              ig_out_param          = eg_param
    IMPORTING ev_all_records_failed = lv_all_records_failed ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-action
      iv_all_records_failed = lv_all_records_failed.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~delete.

  DATA:
    lv_all_records_failed    TYPE           boole_d,
    lr_node_id               TYPE REF TO    data.
  FIELD-SYMBOLS:
    <lt_node_id>             TYPE           INDEX TABLE.

  CLEAR: ev_failed,
         et_index_failed.

  "Create a copy of the node ID table.
  CREATE DATA lr_node_id LIKE it_node_id.
  ASSIGN lr_node_id->* TO <lt_node_id>.
  <lt_node_id> = it_node_id.

  process_before_delete(
    EXPORTING iv_node_name = iv_node_name
    CHANGING  ct_node_id   = <lt_node_id> ).

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-delete.

  IF <lt_node_id> IS NOT INITIAL.
    "Call SPI delete.
    mo_appl_access->delete(
      EXPORTING iv_node_name    = iv_node_name
                it_node_id      = <lt_node_id>
      IMPORTING ev_failed       = ev_failed
                et_index_failed = et_index_failed ).

    mv_sp_was_called = abap_true.
  ENDIF.

  process_after_delete(
    EXPORTING iv_in_node_name       = iv_node_name
              it_in_node_id         = <lt_node_id>
              iv_out_failed         = ev_failed
              it_out_index_failed   = et_index_failed
    IMPORTING ev_all_records_failed = lv_all_records_failed ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-delete
      iv_all_records_failed = lv_all_records_failed.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~insert.

  DATA:
    lv_node_name             TYPE           /plmb/spi_node_name,
    lv_supply_node_data      TYPE           boole_d,
    lv_all_records_failed    TYPE           boole_d,
    lr_node_data             TYPE REF TO    data,
    lo_node_metadata         TYPE REF TO    /plmb/if_spi_metadata_node.
  FIELD-SYMBOLS:
    <lt_node_data>           TYPE           INDEX TABLE.

  CLEAR: ev_failed,
         et_index_failed,
         et_node_data,
         et_node_id_rel.

  process_before_insert(
    EXPORTING iv_node_name            = iv_node_name
              iv_target_node_name     = iv_target_node_name
              it_node_data            = it_node_data
              is_node_id              = is_node_id
              is_param                = is_param
    IMPORTING ev_supply_out_node_data = lv_supply_node_data ).

  IF et_node_data IS SUPPLIED.
    "Node data requested from method caller.
    lv_supply_node_data = abap_true.
  ENDIF.

  IF lv_supply_node_data = abap_true.
    "Identify requested node.
    IF iv_target_node_name IS INITIAL.
      lv_node_name = iv_node_name.
    ELSE.
      lv_node_name = iv_target_node_name.
    ENDIF.
    "Get data container for node data.
    lo_node_metadata = /plmu/if_frw_basic_appl_model~mo_metadata->get_node_metadata( lv_node_name ).
    TRY.
        lo_node_metadata->get_data_container(
          IMPORTING er_data_table = lr_node_data ).
        ASSIGN lr_node_data->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        "Node data typization is not specified in the metadata provider,
        "therefore we cannot import the node data from SPI.
        lv_supply_node_data = abap_false.
        "Assign dummy.
        ASSIGN et_node_data TO <lt_node_data>.
    ENDTRY.
  ELSE.
    "Assign dummy.
    ASSIGN et_node_data TO <lt_node_data>.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-insert.

  "Call SPI insert...
  IF lv_supply_node_data = abap_true.
    "...with node data exporting.
    mo_appl_access->insert(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                it_node_data        = it_node_data
                is_node_id          = is_node_id
                is_param            = is_param
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed
                et_node_data        = <lt_node_data>
                et_node_id_rel      = et_node_id_rel ).
  ELSE.
    "...without node data exporting.
    mo_appl_access->insert(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                it_node_data        = it_node_data
                is_node_id          = is_node_id
                is_param            = is_param
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed ).
  ENDIF.

  mv_sp_was_called = abap_true.

  IF et_node_data IS SUPPLIED.
    "Fill export parameter.
    et_node_data = <lt_node_data>.
  ENDIF.

  process_after_insert(
    EXPORTING iv_in_node_name        = iv_node_name
              iv_in_target_node_name = iv_target_node_name
              it_in_node_data        = it_node_data
              is_in_node_id          = is_node_id
              is_in_param            = is_param
              iv_out_failed          = ev_failed
              it_out_index_failed    = et_index_failed
              it_out_node_data       = <lt_node_data>
    IMPORTING ev_all_records_failed  = lv_all_records_failed
    CHANGING  ct_out_node_id_rel     = et_node_id_rel ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-insert
      iv_all_records_failed = lv_all_records_failed.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~query.

  DATA:
    lv_skip_query            TYPE           boole_d,
    lv_supply_node_data      TYPE           boole_d,
    lr_node_data             TYPE REF TO    data,
    lo_node_metadata         TYPE REF TO    /plmb/if_spi_metadata_node.
  FIELD-SYMBOLS:
    <lt_node_data>           TYPE           INDEX TABLE.

  CLEAR: ev_failed,
         et_node_id,
         et_node_data,
         et_node_id_rel.

  process_before_query(
    EXPORTING iv_node_name            = iv_node_name
              iv_query_name           = iv_query_name
              it_sel_param            = it_sel_param
              is_options              = is_options
              iv_keys_only            = iv_keys_only
              it_filter_node_id       = it_filter_node_id
              it_requested_field      = it_requested_field
    IMPORTING ev_supply_out_node_data = lv_supply_node_data
              ev_skip_query           = lv_skip_query ).

  IF lv_skip_query = abap_true.
    "Query skipped.
    RETURN.
  ENDIF.

  IF iv_keys_only = abap_true.
    "Only the node IDs are requested.
    CLEAR lv_supply_node_data.
  ELSEIF et_node_data IS SUPPLIED.
    "Node data requested from method caller.
    lv_supply_node_data = abap_true.
  ENDIF.

  IF lv_supply_node_data = abap_true.
    "Get data container for node data.
    lo_node_metadata = /plmu/if_frw_basic_appl_model~mo_metadata->get_node_metadata( iv_node_name ).
    TRY.
        IF iv_query_name IS NOT INITIAL.
          lo_node_metadata->get_query_details(
            EXPORTING iv_query_name             = iv_query_name
            IMPORTING er_result_table_container = lr_node_data ).
        ELSE.
          lo_node_metadata->get_data_container(
            IMPORTING er_data_table = lr_node_data ).
        ENDIF.
        ASSIGN lr_node_data->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        "Node data or query result typization is not specified in the metadata provider,
        "therefore we cannot import the node data from SPI.
        lv_supply_node_data = abap_false.
        "Assign dummy.
        ASSIGN et_node_data TO <lt_node_data>.
    ENDTRY.
  ELSE.
    "Assign dummy.
    ASSIGN et_node_data TO <lt_node_data>.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-query.

  "Call SPI query...
  IF lv_supply_node_data = abap_true.
    IF et_node_id IS SUPPLIED.
      "...with node data and node ID exporting.
      mo_appl_access->query(
        EXPORTING iv_node_name       = iv_node_name
                  iv_query_name      = iv_query_name
                  it_sel_param       = it_sel_param
                  is_options         = is_options
                  iv_keys_only       = iv_keys_only
                  it_filter_node_id  = it_filter_node_id
                  it_requested_field = it_requested_field
        IMPORTING ev_failed          = ev_failed
                  et_node_id         = et_node_id
                  et_node_data       = <lt_node_data>
                  et_node_id_rel     = et_node_id_rel ).
    ELSE.
      "...with node data but without node ID exporting.
      mo_appl_access->query(
        EXPORTING iv_node_name       = iv_node_name
                  iv_query_name      = iv_query_name
                  it_sel_param       = it_sel_param
                  is_options         = is_options
                  iv_keys_only       = iv_keys_only
                  it_filter_node_id  = it_filter_node_id
                  it_requested_field = it_requested_field
        IMPORTING ev_failed          = ev_failed
                  et_node_data       = <lt_node_data>
                  et_node_id_rel     = et_node_id_rel ).
    ENDIF.
  ELSE.
    IF et_node_id IS SUPPLIED.
      "...without node data but with node ID exporting.
      mo_appl_access->query(
        EXPORTING iv_node_name       = iv_node_name
                  iv_query_name      = iv_query_name
                  it_sel_param       = it_sel_param
                  is_options         = is_options
                  iv_keys_only       = iv_keys_only
                  it_filter_node_id  = it_filter_node_id
                  it_requested_field = it_requested_field
        IMPORTING ev_failed          = ev_failed
                  et_node_id         = et_node_id
                  et_node_id_rel     = et_node_id_rel ).
    ELSE.
      "...without node data and node ID exporting.
      mo_appl_access->query(
        EXPORTING iv_node_name       = iv_node_name
                  iv_query_name      = iv_query_name
                  it_sel_param       = it_sel_param
                  is_options         = is_options
                  iv_keys_only       = iv_keys_only
                  it_filter_node_id  = it_filter_node_id
                  it_requested_field = it_requested_field
        IMPORTING ev_failed          = ev_failed
                  et_node_id_rel     = et_node_id_rel ).
    ENDIF.
  ENDIF.

  mv_sp_was_called = abap_true.

  IF et_node_data IS SUPPLIED.
    "Fill export parameter.
    et_node_data = <lt_node_data>.
  ENDIF.

  process_after_query(
    EXPORTING iv_in_node_name       = iv_node_name
              iv_in_query_name      = iv_query_name
              it_in_sel_param       = it_sel_param
              is_in_options         = is_options
              iv_in_keys_only       = iv_keys_only
              it_in_filter_node_id  = it_filter_node_id
              it_in_requested_field = it_requested_field
              iv_out_failed         = ev_failed
              it_out_node_id        = et_node_id
              it_out_node_data      = <lt_node_data>
    CHANGING  ct_out_node_id_rel    = et_node_id_rel ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-query
      iv_all_records_failed = ev_failed.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~retrieve.

  DATA:
    lv_node_name             TYPE           /plmb/spi_node_name,
    lv_supply_node_data      TYPE           boole_d,
    lv_skip_retrieve         TYPE           boole_d,
    lv_all_records_failed    TYPE           boole_d,
    lv_idx_failed_requested  TYPE           boole_d,
    lv_node_id_rel_requested TYPE           boole_d,
    lr_node_data             TYPE REF TO    data,
    lo_node_metadata         TYPE REF TO    /plmb/if_spi_metadata_node.
  FIELD-SYMBOLS:
    <lt_filtered_node_id>    TYPE           INDEX TABLE,
    <lt_node_data>           TYPE           INDEX TABLE.

  CLEAR: ev_failed,
         et_index_failed,
         et_node_data,
         et_node_id_rel.

  "Get a container to store filtered node IDs.
  CREATE DATA lr_node_data LIKE it_node_id.
  ASSIGN lr_node_data->* TO <lt_filtered_node_id>.

  process_before_retrieve(
    EXPORTING iv_node_name            = iv_node_name
              iv_target_node_name     = iv_target_node_name
              it_node_id              = it_node_id
              iv_lock                 = iv_lock
              it_requested_field      = it_requested_field
    IMPORTING et_filtered_node_id     = <lt_filtered_node_id>
              ev_skip_retrieve        = lv_skip_retrieve
              ev_supply_out_node_data = lv_supply_node_data ).

  IF lv_skip_retrieve = abap_true.
    "Retrieve skipped.
    RETURN.
  ENDIF.

  IF <lt_filtered_node_id> IS INITIAL.
    "No retrieve via SPI required.
    "Hint: Check side-effects/node invalidation if different behaviour is expected.
    RETURN.
  ENDIF.

  IF et_node_data IS SUPPLIED.
    "Node data requested from method caller.
    lv_supply_node_data = abap_true.
  ENDIF.

  IF lv_supply_node_data = abap_true.
    "Identify requested node.
    IF iv_target_node_name IS INITIAL.
      lv_node_name = iv_node_name.
    ELSE.
      lv_node_name = iv_target_node_name.
    ENDIF.
    "Get data container for node data.
    lo_node_metadata = /plmu/if_frw_basic_appl_model~mo_metadata->get_node_metadata( lv_node_name ).
    TRY.
        lo_node_metadata->get_data_container(
          IMPORTING er_data_table = lr_node_data ).
        ASSIGN lr_node_data->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        "Node data typization is not specified in the metadata provider,
        "therefore we cannot import the node data from SPI.
        lv_supply_node_data = abap_false.
        "Assign dummy.
        ASSIGN et_node_data TO <lt_node_data>.
    ENDTRY.
  ELSE.
    "Assign dummy.
    ASSIGN et_node_data TO <lt_node_data>.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-retrieve.

  "Call SPI retrieve...
  IF lv_supply_node_data = abap_true.
    "...with node data exporting.
    mo_appl_access->retrieve(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                it_node_id          = <lt_filtered_node_id>
                iv_lock             = iv_lock
                it_requested_field  = it_requested_field
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed
                et_node_data        = <lt_node_data>
                et_node_id_rel      = et_node_id_rel ).
  ELSE.
    "...without node data exporting.
    mo_appl_access->retrieve(
      EXPORTING iv_node_name        = iv_node_name
                iv_target_node_name = iv_target_node_name
                it_node_id          = <lt_filtered_node_id>
                iv_lock             = iv_lock
                it_requested_field  = it_requested_field
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed ).
  ENDIF.

  mv_sp_was_called = abap_true.

  IF et_node_data IS SUPPLIED.
    "Fill export parameter.
    et_node_data = <lt_node_data>.
  ENDIF.
  IF et_node_id_rel IS SUPPLIED.
    lv_node_id_rel_requested = abap_true.
  ENDIF.
  IF et_index_failed IS SUPPLIED.
    lv_idx_failed_requested = abap_true.
  ENDIF.

  process_after_retrieve(
    EXPORTING iv_in_node_name           = iv_node_name
              iv_in_target_node_name    = iv_target_node_name
              it_in_node_id             = it_node_id
              iv_in_lock                = iv_lock
              it_in_requested_field     = it_requested_field
              iv_out_failed             = ev_failed
              it_out_node_data          = <lt_node_data>
              it_filtered_node_id       = <lt_filtered_node_id>
              iv_index_failed_requested = lv_idx_failed_requested
              iv_node_id_rel_requested  = lv_node_id_rel_requested
    IMPORTING ev_all_records_failed     = lv_all_records_failed
    CHANGING  ct_out_index_failed       = et_index_failed
              ct_out_node_id_rel        = et_node_id_rel ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-retrieve
      iv_all_records_failed = lv_all_records_failed.

ENDMETHOD.


METHOD /plmu/if_frw_basic_appl_model~update.

  DATA:
    lv_supply_node_data      TYPE           boole_d,
    lv_all_records_failed    TYPE           boole_d,
    lr_node_data             TYPE REF TO    data,
    lo_node_metadata         TYPE REF TO    /plmb/if_spi_metadata_node.
  FIELD-SYMBOLS:
    <lt_node_data>           TYPE           INDEX TABLE.

  CLEAR: ev_failed,
         et_index_failed,
         et_node_data,
         et_node_id_rel.

  process_before_update(
    EXPORTING iv_node_name            = iv_node_name
              it_node_data            = it_node_data
              it_changed_field        = it_changed_field
    IMPORTING ev_supply_out_node_data = lv_supply_node_data ).

  IF et_node_data IS SUPPLIED.
    "Node data requested from method caller.
    lv_supply_node_data = abap_true.
  ENDIF.

  IF lv_supply_node_data = abap_true.
    "Get data container for node data.
    lo_node_metadata = /plmu/if_frw_basic_appl_model~mo_metadata->get_node_metadata( iv_node_name ).
    TRY.
        lo_node_metadata->get_data_container(
          IMPORTING er_data_table = lr_node_data ).
        ASSIGN lr_node_data->* TO <lt_node_data>.
      CATCH /plmb/cx_spi_metadata.
        "Node data typization is not specified in the metadata provider,
        "therefore we cannot import the node data from SPI.
        lv_supply_node_data = abap_false.
        "Assign dummy.
        ASSIGN et_node_data TO <lt_node_data>.
    ENDTRY.
  ELSE.
    "Assign dummy.
    ASSIGN et_node_data TO <lt_node_data>.
  ENDIF.

  RAISE EVENT /plmu/if_frw_appl_model_int~before_sp_call
    EXPORTING
      iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-update.

  "Call SPI update...
  IF lv_supply_node_data = abap_true.
    "...with node data exporting.
    mo_appl_access->update(
      EXPORTING iv_node_name        = iv_node_name
                it_node_data        = it_node_data
                it_changed_field    = it_changed_field
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed
                et_node_data        = <lt_node_data>
                et_node_id_rel      = et_node_id_rel ).
  ELSE.
    "...without node data exporting.
    mo_appl_access->update(
      EXPORTING iv_node_name        = iv_node_name
                it_node_data        = it_node_data
                it_changed_field    = it_changed_field
      IMPORTING ev_failed           = ev_failed
                et_index_failed     = et_index_failed ).
  ENDIF.

  mv_sp_was_called = abap_true.

  IF et_node_data IS SUPPLIED.
    "Fill export parameter.
    et_node_data = <lt_node_data>.
  ENDIF.

  process_after_update(
    EXPORTING iv_in_node_name       = iv_node_name
              it_in_node_data       = it_node_data
              it_in_changed_field   = it_changed_field
              iv_out_failed         = ev_failed
              it_out_index_failed   = et_index_failed
              it_out_node_data      = <lt_node_data>
    IMPORTING ev_all_records_failed = lv_all_records_failed
    CHANGING  ct_out_node_id_rel    = et_node_id_rel ).

  RAISE EVENT /plmu/if_frw_appl_model_int~after_sp_call
    EXPORTING
      iv_operation_type     = /plmu/if_frw_constants=>gc_operation_type-update
      iv_all_records_failed = lv_all_records_failed.

ENDMETHOD.


METHOD apply_field_properties.

  "This model type cannot apply the field properties directly!
  RETURN.

ENDMETHOD.


METHOD apply_node_invalidation.

  mo_retrieve_filter->invalidate_nodes(
    EXPORTING it_invalid_node = it_invalid_node ).

ENDMETHOD.


METHOD apply_operation_properties.

  "This model type cannot apply the operation properties directly!
  RETURN.

ENDMETHOD.


METHOD cache_messages.

  DATA:
    lt_message               TYPE           /plmb/t_spi_coll_message_enh.
  FIELD-SYMBOLS:
    <ls_message>             TYPE           /plmb/s_spi_coll_message_enh.

  IF ms_coll_data_processing_mode-messages = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    "Messag processing is disabled.
    mo_collector_output->init_buffer( iv_target = /plmu/if_frw_constants=>gc_target-message ).
    RETURN.
  ENDIF.

  "Read new messages from the collector.
  mo_collector_output->get_messages_enh(
    EXPORTING iv_init_buffer = abap_true
    IMPORTING et_messages    = lt_message ).
  "Fill new messages into the cache.
  IF ms_collector_data_cache-messages IS INITIAL.
    ms_collector_data_cache-messages = lt_message.
  ELSE.
    LOOP AT lt_message ASSIGNING <ls_message>.
      READ TABLE ms_collector_data_cache-messages TRANSPORTING NO FIELDS
        WITH KEY all_components
        COMPONENTS table_line = <ls_message>.
      IF sy-subrc IS INITIAL.
        CONTINUE.
      ENDIF.
      APPEND <ls_message> TO ms_collector_data_cache-messages.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD class_constructor.

  go_message_manager      = /plmu/cl_frw_message_manager=>get_instance( ).
  go_context_pool         = /plmu/cl_frw_context_pool=>get_instance( ).
  go_retrieve_filter_pool = /plmu/cl_frw_retr_filter_pool=>get_instance( ).

ENDMETHOD.


METHOD constructor.

  DATA:
    ls_options               TYPE           /plmb/s_spi_connector_options.

  mv_is_alive = abap_true.

  "Set runtime ID.
  IF iv_runtime_id IS NOT INITIAL.
    mv_runtime_id = iv_runtime_id.
  ELSE.
    mv_runtime_id = /plmu/cl_frw_internal_utils=>get_runtime_id( ).
  ENDIF.

  "Set connector options based on processing mode.
  ms_coll_data_processing_mode = is_coll_data_processing_mode.
  IF is_coll_data_processing_mode-messages = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    ls_options-control-messages = /plmu/if_frw_constants=>gc_message_processing-ignore.
  ENDIF.
  IF is_coll_data_processing_mode-invalid_nodes = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    ls_options-control-node_invalidation = /plmu/if_frw_constants=>gc_invalid_node_processing-ignore.
  ENDIF.
  IF is_coll_data_processing_mode-field_properties = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
    IF is_coll_data_processing_mode-operation_properties = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
      ls_options-control-properties = /plmu/if_frw_constants=>gc_property_processing-ignore.
    ELSE.
      ls_options-control-properties = /plmu/if_frw_constants=>gc_property_processing-process_operation_only.
    ENDIF.
  ELSE.
    IF is_coll_data_processing_mode-operation_properties = /plmu/if_frw_appl_model_int=>gc_data_processing_mode-disabled.
      ls_options-control-properties = /plmu/if_frw_constants=>gc_property_processing-process_field_only.
    ELSE.
      ls_options-control-properties = /plmu/if_frw_constants=>gc_property_processing-process.
    ENDIF.
  ENDIF.

  "Create SP access instance.
  /plmb/cl_spi_connector=>create_instance(
    EXPORTING
      iv_abbid     = iv_abbid
      is_options   = ls_options
    IMPORTING
      eo_connector = mo_appl_access
      eo_collector = mo_collector_output
      eo_metadata  = /plmu/if_frw_basic_appl_model~mo_metadata ).

  "Create retrieve filter.
  mo_retrieve_filter = go_retrieve_filter_pool->get_retrieve_filter(
                         io_metadata = /plmu/if_frw_basic_appl_model~mo_metadata ).

  IF iv_create_tool = abap_true.
    "Create model tools.
    CREATE OBJECT /plmu/if_frw_basic_appl_model~mo_tools
      TYPE /plmu/cl_frw_basic_tool
      EXPORTING
        io_collector_output =  MO_COLLECTOR_OUTPUT        "note 2153829
        io_application_model = me
        io_retrieve_filter   = mo_retrieve_filter.
  ENDIF.

  "Set event handler.
  SET HANDLER: hndl_new_collector_data FOR mo_collector_output,
               hndl_unsaved_data_exists.

ENDMETHOD.


METHOD hndl_new_collector_data.

  DATA:
    lt_invalid_node          TYPE           /plmb/t_spi_coll_invalid_node,
    lt_node_id_map           TYPE           /plmb/t_spi_coll_id_map_node.

  IF is_available_data-messages = abap_true.
    "Cache messages.
    cache_messages( ).
  ENDIF.

  IF is_available_data-new_node_id = abap_true.
    "Direclty process new node IDs
    mo_collector_output->get_link_to_new_node_id(
      EXPORTING iv_init_buffer  = abap_true
      IMPORTING et_node_id_mapp = lt_node_id_map ).
    go_context_pool->process_new_node_ids(
      EXPORTING io_metadata    = /plmu/if_frw_basic_appl_model~mo_metadata
                it_node_id_map = lt_node_id_map ).
  ENDIF.

  IF is_available_data-node_invalidation = abap_true.
    "Direclty process node invalidation.
    mo_collector_output->get_invalid_nodes(
      EXPORTING iv_init_buffer   = abap_true
      IMPORTING et_invalid_nodes = lt_invalid_node ).
    apply_node_invalidation(
      EXPORTING it_invalid_node = lt_invalid_node ).
  ENDIF.

  IF is_available_data-operation_properties = abap_true.
    "Cache operation properties.
    /plmu/if_frw_appl_model_int~cache_operation_properties( ).
  ENDIF.

  IF is_available_data-properties = abap_true.
    "Cache field properties.
    /plmu/if_frw_appl_model_int~cache_field_properties( ).
  ENDIF.

ENDMETHOD.


METHOD hndl_unsaved_data_exists.

  /plmu/if_frw_basic_appl_model~mv_unsaved_data = iv_unsaved_data_exists.

ENDMETHOD.


METHOD process_after_action.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  CLEAR: ev_all_records_failed.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = iv_in_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-action
              iv_operation_name = iv_in_action_name ).

  "Check if at least one record was successfully.
  IF iv_out_failed = abap_true
    OR (     it_in_node_id IS NOT INITIAL
         AND lines( it_in_node_id ) <= lines( it_out_index_failed ) ).
    "Everything failed!
    ev_all_records_failed = abap_true.
  ENDIF.

ENDMETHOD.


METHOD process_after_delete.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.
  FIELD-SYMBOLS:
    <ls_node_id>             TYPE           any.

  CLEAR: ev_all_records_failed,
         et_succeeded_node_id.

  IF it_in_node_id IS INITIAL.
    "Nothing deleted.
    RETURN.
  ENDIF.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = iv_in_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-delete ).

  "Check if at least one record was deleted successfully.
  IF iv_out_failed = abap_true
    OR lines( it_in_node_id ) <= lines( it_out_index_failed ).
    "Everything failed!
    ev_all_records_failed = abap_true.
    RETURN.
  ENDIF.

  IF et_succeeded_node_id IS SUPPLIED.
    "Collect node IDs of successfully deleted records.
    IF it_out_index_failed IS INITIAL.
      et_succeeded_node_id = it_in_node_id.
    ELSE.
      LOOP AT it_in_node_id ASSIGNING <ls_node_id>.
        READ TABLE it_out_index_failed TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          "Delete failed.
          CONTINUE.
        ENDIF.
        INSERT <ls_node_id> INTO TABLE et_succeeded_node_id.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD process_after_insert.

  DATA:
    lv_node_name             TYPE           /plmb/spi_node_name,
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.
  FIELD-SYMBOLS:
    <ls_node_data>           TYPE           any.

  CLEAR: ev_all_records_failed,
         et_succeeded_node_data.

  "Identify requested node.
  IF iv_in_target_node_name IS INITIAL.
    lv_node_name = iv_in_node_name.
  ELSE.
    lv_node_name = iv_in_target_node_name.
  ENDIF.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = lv_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-insert ).

  "Trim source/target relation table.
  SORT ct_out_node_id_rel BY trg_node_id.
  DELETE ADJACENT DUPLICATES FROM ct_out_node_id_rel COMPARING trg_node_id.
  SORT ct_out_node_id_rel BY src_node_id trg_node_id.

  "Check if at least one record was inserted successfully.
  IF iv_out_failed = abap_true
    OR lines( it_in_node_data ) <= lines( it_out_index_failed ).
    "Everything failed!
    ev_all_records_failed = abap_true.
    RETURN.
  ENDIF.

  IF et_succeeded_node_data IS SUPPLIED.
    "Collect node data of successfully inserted records.
    IF it_out_index_failed IS INITIAL.
      et_succeeded_node_data = it_in_node_data.
    ELSE.
      LOOP AT it_in_node_data ASSIGNING <ls_node_data>.
        READ TABLE it_out_index_failed TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          "Insert failed!
          CONTINUE.
        ENDIF.
        "Insert succeeded.
        INSERT <ls_node_data> INTO TABLE et_succeeded_node_data.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD process_after_query.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool,
    lo_retrieve_filter_node  TYPE REF TO    /plmu/cl_frw_retr_filter_node.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = iv_in_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-query
              iv_operation_name = iv_in_query_name ).

  "If filter is activated, we skip duplicate query calls.
  lo_retrieve_filter_node = mo_retrieve_filter->get_retrieve_filter_node( iv_in_node_name ).
  lo_retrieve_filter_node->add_criteria(
    EXPORTING iv_query_name      = iv_in_query_name
              it_sel_param       = it_in_sel_param
              is_options         = is_in_options
              iv_keys_only       = iv_in_keys_only
              it_filter_node_id  = it_in_filter_node_id
              it_requested_field = it_in_requested_field
              iv_failed          = iv_out_failed ).

ENDMETHOD.


METHOD process_after_retrieve.

  DATA:
    lv_node_name             TYPE           /plmb/spi_node_name,
    lo_retrieve_filter_node  TYPE REF TO    /plmu/cl_frw_retr_filter_node,
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.

  CLEAR: ev_all_records_failed.

  "Identify requested node.
  IF iv_in_target_node_name IS INITIAL.
    lv_node_name = iv_in_node_name.
  ELSE.
    lv_node_name = iv_in_target_node_name.
  ENDIF.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = lv_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-retrieve ).

  "Update retrieve filter.
  lo_retrieve_filter_node = mo_retrieve_filter->get_retrieve_filter_node( lv_node_name ).
  lo_retrieve_filter_node->add_ids(
    EXPORTING iv_node_name          = iv_in_node_name
              iv_target_node_name   = iv_in_target_node_name
              it_node_id            = it_in_node_id
              iv_lock               = iv_in_lock
              it_requested_field    = it_in_requested_field
              iv_failed             = iv_out_failed
              it_index_failed       = ct_out_index_failed
    IMPORTING ev_all_records_failed = ev_all_records_failed ).

  "When some node IDs were filtered it is necessary to adjust the
  "index tables that the SP has filled to fit to the node ID table
  "that was provided by the caller of the RETRIEVE.
  IF iv_index_failed_requested = abap_true
    AND ct_out_index_failed IS NOT INITIAL.
    lo_retrieve_filter_node->adjust_index_failed_table(
      CHANGING ct_index_failed = ct_out_index_failed ).
  ENDIF.
  IF iv_node_id_rel_requested = abap_true
    AND ct_out_node_id_rel IS NOT INITIAL.
    lo_retrieve_filter_node->adjust_node_id_rel_table(
      CHANGING ct_node_id_rel = ct_out_node_id_rel ).
  ENDIF.

ENDMETHOD.


METHOD process_after_update.

  DATA:
    lo_tools                 TYPE REF TO    /plmu/cl_frw_basic_tool.
  FIELD-SYMBOLS:
    <ls_node_data>           TYPE           any.

  CLEAR: ev_all_records_failed,
         et_succeeded_node_data.

  "Write SP call Log.
  lo_tools ?= /plmu/if_frw_basic_appl_model~mo_tools.
  lo_tools->add_sp_call_log_entry(
    EXPORTING iv_node_name      = iv_in_node_name
              iv_operation_type = /plmu/if_frw_constants=>gc_operation_type-update ).

  "Trim source/target relation table.
  SORT ct_out_node_id_rel BY trg_node_id.
  DELETE ADJACENT DUPLICATES FROM ct_out_node_id_rel COMPARING trg_node_id.
  SORT ct_out_node_id_rel BY src_node_id trg_node_id.

  "Check if at least one record was updated successfully.
  IF iv_out_failed = abap_true
    OR lines( it_in_node_data ) <= lines( it_out_index_failed ).
    "Everything failed!
    ev_all_records_failed = abap_true.
    "-->
    RETURN.
  ENDIF.

  IF et_succeeded_node_data IS SUPPLIED.
    "Collect node data of successfully updated records.
    IF it_out_index_failed IS INITIAL.
      et_succeeded_node_data = it_in_node_data.
    ELSE.
      LOOP AT it_in_node_data ASSIGNING <ls_node_data>.
        READ TABLE it_out_index_failed TRANSPORTING NO FIELDS
          WITH KEY index = sy-tabix
          BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          "Update failed!
          CONTINUE.
        ENDIF.
        "Update succeeded.
        INSERT <ls_node_data> INTO TABLE et_succeeded_node_data.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD process_before_action.

  CLEAR ev_supply_out_node_data.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

  "We need the node data to refresh the retrieve filter accordingly.
  ev_supply_out_node_data = abap_true.

ENDMETHOD.


METHOD process_before_delete.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

ENDMETHOD.


METHOD process_before_insert.

  CLEAR ev_supply_out_node_data.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

ENDMETHOD.


METHOD process_before_query.

  DATA:
    lo_retrieve_filter_node  TYPE REF TO    /plmu/cl_frw_retr_filter_node.

  CLEAR: ev_supply_out_node_data,
         ev_skip_query.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

  "If filter is activated, we skip duplicate query calls.
  lo_retrieve_filter_node = mo_retrieve_filter->get_retrieve_filter_node( iv_node_name ).
  lo_retrieve_filter_node->filter_criteria(
    EXPORTING iv_query_name      = iv_query_name
              it_sel_param       = it_sel_param
              is_options         = is_options
              iv_keys_only       = iv_keys_only
              it_filter_node_id  = it_filter_node_id
              it_requested_field = it_requested_field
    IMPORTING ev_skip_query      = ev_skip_query ).

ENDMETHOD.


METHOD process_before_retrieve.

  DATA:
    lv_node_name             TYPE           /plmb/spi_node_name,
    lo_retrieve_filter_node  TYPE REF TO    /plmu/cl_frw_retr_filter_node.

  CLEAR: et_filtered_node_id,
         ev_skip_retrieve,
         ev_supply_out_node_data.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

  IF it_node_id IS INITIAL.
    ev_skip_retrieve = abap_true.
    RETURN.
  ENDIF.

  "Identify requested node.
  IF iv_target_node_name IS INITIAL.
    lv_node_name = iv_node_name.
  ELSE.
    lv_node_name = iv_target_node_name.
  ENDIF.

  "Filter node IDs that have already been retrieved
  "and were not invalidated since then.
  lo_retrieve_filter_node = mo_retrieve_filter->get_retrieve_filter_node( lv_node_name ).
  lo_retrieve_filter_node->filter_ids(
    EXPORTING iv_node_name        = iv_node_name
              iv_target_node_name = iv_target_node_name
              it_node_id          = it_node_id
              iv_lock             = iv_lock
              it_requested_field  = it_requested_field
    IMPORTING et_filtered_node_id = et_filtered_node_id ).

ENDMETHOD.


METHOD process_before_update.

  CLEAR ev_supply_out_node_data.

  "Check if the application model has already been invalidated.
  IF mv_is_alive <> abap_true.
    RAISE EXCEPTION TYPE /plmu/cx_frw_error
      EXPORTING
        textid = /plmu/cx_frw_error=>appl_model_is_not_alive.
  ENDIF.

ENDMETHOD.
ENDCLASS.