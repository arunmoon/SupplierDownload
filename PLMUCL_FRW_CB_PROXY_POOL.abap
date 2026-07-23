class /PLMU/CL_FRW_CB_PROXY_POOL definition
  public
  create private .

public section.

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /PLMU/CL_FRW_CB_PROXY_POOL .
  methods ADD_CALLBACK_PROXY
    importing
      !IO_CALLBACK_PROXY type ref to /PLMU/IF_FRW_CALLBACK_PROXY
      !IO_CALLBACK type ref to OBJECT .
  methods AFTER_AFTER_FAILED_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods AFTER_CLEANUP
    importing
      !IV_REASON type /PLMB/SPI_CLEAN_UP_REASON .
  methods AFTER_FAILED_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
      !IV_REVERT type BOOLE_D
    exporting
      !EV_SKIP_STANDARD type BOOLE_D .
  methods AFTER_FLUSH
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods AFTER_NEEDS_CONFIRMATION
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    changing
      !CT_CONFIRMATION_REQUESTS type FPM_T_CONFIRMATION_REQUESTS .
  methods AFTER_PROCESS_BEFORE_OUTPUT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods AFTER_PROCESS_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    changing
      !CV_RESULT type FPM_EVENT_RESULT .
  methods AFTER_SAVE
    importing
      !IV_REASON type /PLMU/FRW_AFTER_SAVE_REASON
    changing
      !CV_MODE type /PLMB/SPI_MODE .
  methods BEFORE_CLEANUP
    importing
      !IV_REASON type /PLMB/SPI_CLEAN_UP_REASON .
  methods FLUSH
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods GET_CALLBACK_PROXY
    importing
      !IV_RUNTIME_ID type STRING optional
      !IO_CALLBACK type ref to OBJECT
    returning
      value(RO_CALLBACK_PROXY) type ref to /PLMU/IF_FRW_CALLBACK_PROXY .
  methods GET_CALLBACK_RUNTIME_ID
    importing
      !IO_CALLBACK type ref to OBJECT
    exporting
      !EV_RUNTIME_ID type STRING .
  methods INITIALIZE .
  methods NEEDS_CONFIRMATION
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    exporting
      !EO_CONFIRMATION_REQUEST type ref to CL_FPM_CONFIRMATION_REQUEST
      !EV_SKIP_STANDARD type BOOLE_D .
  methods OVERRIDE_CONFIG_TABBED
    importing
      !IO_TABBED type ref to IF_FPM_TABBED .
  methods OVERRIDE_EVENT_GAF
    importing
      !IO_GAF type ref to IF_FPM_GAF .
  methods OVERRIDE_EVENT_OIF
    importing
      !IO_OIF type ref to IF_FPM_OIF .
  methods OVERRIDE_EVENT_OVP
    importing
      !IO_OVP type ref to IF_FPM_OVP .
  methods PROCESS_BEFORE_OUTPUT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    exporting
      !EV_SKIP_STANDARD type BOOLE_D .
  methods PROCESS_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    exporting
      !EV_SKIP_STANDARD type BOOLE_D
      !EV_RESULT type FPM_EVENT_RESULT .
protected section.
*"* protected components of class /PLMU/CL_FRW_CB_PROXY_POOL
*"* do not include other source files here!!!
private section.

  types:
    BEGIN OF gty_s_callback_proxy_pool,
      callback               TYPE REF TO    object,
      callback_proxy         TYPE REF TO    /plmu/if_frw_callback_proxy,
    END   OF gty_s_callback_proxy_pool .
  types:
    gty_t_callback_proxy_pool TYPE SORTED TABLE OF gty_s_callback_proxy_pool
                              WITH UNIQUE KEY callback
                              WITH UNIQUE SORTED KEY callback_proxy
                                COMPONENTS callback_proxy .

  class-data GO_INSTANCE type ref to /PLMU/CL_FRW_CB_PROXY_POOL .
  data MO_GAF_APPCC type ref to /PLMU/EX_FRW_APPCC_GAF .
  data MO_OIF_APPCC type ref to /PLMU/EX_FRW_CONSUMER_APPCC .
  data MO_OVP_APPCC type ref to /PLMU/EX_FRW_APPCC_OVP .
  data MO_WIRE_SERVICES type ref to /PLMU/CL_FRW_W_SERVICES .
  data MT_CALLBACK_PROXY_POOL type GTY_T_CALLBACK_PROXY_POOL .
  data MV_FLOORPLAN_TYPE type FPM_FLOORPLAN .

  methods HNDL_PROXY_BEFORE_DESTRUCTION
    for event BEFORE_DESTRUCTION of /PLMU/IF_FRW_CALLBACK_PROXY
    importing
      !IO_CALLBACK_PROXY .
ENDCLASS.



CLASS /PLMU/CL_FRW_CB_PROXY_POOL IMPLEMENTATION.


METHOD add_callback_proxy.

  DATA:
    ls_callback_proxy_pool   TYPE           gty_s_callback_proxy_pool.

  ls_callback_proxy_pool-callback       = io_callback.
  ls_callback_proxy_pool-callback_proxy = io_callback_proxy.
  INSERT ls_callback_proxy_pool INTO TABLE mt_callback_proxy_pool.

  SET HANDLER hndl_proxy_before_destruction FOR io_callback_proxy.

ENDMETHOD.


METHOD after_after_failed_event.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_after_failed_event
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_after_failed_event
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_after_failed_event
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
  ENDCASE.

ENDMETHOD.


METHOD after_cleanup.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_cleanup
        EXPORTING
          iv_reason = iv_reason.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_cleanup
        EXPORTING
          iv_reason = iv_reason.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_cleanup
        EXPORTING
          iv_reason = iv_reason.
  ENDCASE.

  LOOP AT mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>.
    <ls_callback_proxy_pool>-callback_proxy->after_cleanup(
      EXPORTING iv_reason = iv_reason ).
  ENDLOOP.

ENDMETHOD.


METHOD after_failed_event.

  CLEAR: ev_skip_standard.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_failed_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          iv_revert        = iv_revert
        CHANGING
          cv_skip_standard = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_failed_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          iv_revert        = iv_revert
        CHANGING
          cv_skip_standard = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_failed_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          iv_revert        = iv_revert
        CHANGING
          cv_skip_standard = ev_skip_standard.
  ENDCASE.

ENDMETHOD.


METHOD after_flush.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
  ENDCASE.

ENDMETHOD.


METHOD after_needs_confirmation.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_needs_confirmation
        EXPORTING
          io_event                 = io_event
          it_uibbs                 = it_uibbs
        CHANGING
          ct_confirmation_requests = ct_confirmation_requests.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_needs_confirmation
        EXPORTING
          io_event                 = io_event
          it_uibbs                 = it_uibbs
        CHANGING
          ct_confirmation_requests = ct_confirmation_requests.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_needs_confirmation
        EXPORTING
          io_event                 = io_event
          it_uibbs                 = it_uibbs
        CHANGING
          ct_confirmation_requests = ct_confirmation_requests.
  ENDCASE.

ENDMETHOD.


METHOD after_process_before_output.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          io_wire_services = mo_wire_services.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          io_wire_services = mo_wire_services.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
          io_wire_services = mo_wire_services.
  ENDCASE.

ENDMETHOD.


METHOD after_process_event.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_process_event
        EXPORTING
          io_event  = io_event
          it_uibbs  = it_uibbs
        CHANGING
          cv_result = cv_result.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_process_event
        EXPORTING
          io_event  = io_event
          it_uibbs  = it_uibbs
        CHANGING
          cv_result = cv_result.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_process_event
        EXPORTING
          io_event  = io_event
          it_uibbs  = it_uibbs
        CHANGING
          cv_result = cv_result.
  ENDCASE.

ENDMETHOD.


METHOD after_save.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->after_save
        EXPORTING
          iv_reason = iv_reason
        CHANGING
          cv_mode   = cv_mode.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->after_save
        EXPORTING
          iv_reason = iv_reason
        CHANGING
          cv_mode   = cv_mode.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->after_save
        EXPORTING
          iv_reason = iv_reason
        CHANGING
          cv_mode   = cv_mode.
  ENDCASE.

  LOOP AT mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>.
    <ls_callback_proxy_pool>-callback_proxy->after_save(
      EXPORTING iv_reason = iv_reason
      CHANGING  cv_mode   = cv_mode ).
  ENDLOOP.

ENDMETHOD.


METHOD before_cleanup.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  LOOP AT mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>.
    <ls_callback_proxy_pool>-callback_proxy->before_cleanup(
      EXPORTING iv_reason = iv_reason ).
  ENDLOOP.

ENDMETHOD.


METHOD flush.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->flush
        EXPORTING
          io_event = io_event
          it_uibbs = it_uibbs.
  ENDCASE.

ENDMETHOD.


METHOD get_callback_proxy.

  FIELD-SYMBOLS:
    <ls_proxy_pool>          TYPE           gty_s_callback_proxy_pool.

  READ TABLE mt_callback_proxy_pool ASSIGNING <ls_proxy_pool>
    WITH TABLE KEY callback = io_callback.
  IF sy-subrc IS INITIAL.
    ro_callback_proxy = <ls_proxy_pool>-callback_proxy.
  ENDIF.

ENDMETHOD.


METHOD get_callback_runtime_id.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  CLEAR: ev_runtime_id.

  READ TABLE mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>
    WITH TABLE KEY callback = io_callback.

  IF sy-subrc IS INITIAL.
    ev_runtime_id = <ls_callback_proxy_pool>-callback_proxy->get_runtime_id( ).
  ENDIF.

ENDMETHOD.


METHOD get_instance.

  IF go_instance IS INITIAL.
    CREATE OBJECT go_instance.
  ENDIF.

  ro_instance = go_instance.

ENDMETHOD.


METHOD hndl_proxy_before_destruction.

  DELETE TABLE mt_callback_proxy_pool
    WITH TABLE KEY callback_proxy
    COMPONENTS callback_proxy = io_callback_proxy.

  SET HANDLER hndl_proxy_before_destruction
    FOR io_callback_proxy ACTIVATION abap_false.

ENDMETHOD.


METHOD initialize.

  DATA:
    lo_fpm                   TYPE REF TO    if_fpm,
    ls_fpm_runtime_info      TYPE           fpm_s_runtime_info.

  lo_fpm = /plmu/cl_frw_appl_cntrl=>get_fpm( ).

  IF lo_fpm IS INITIAL.
    "We are in FPM configuration mode.
    RETURN.
  ENDIF.

  ls_fpm_runtime_info = lo_fpm->get_runtime_info( ).
  mv_floorplan_type   = ls_fpm_runtime_info-floorplan.

  CREATE OBJECT mo_wire_services.

  "Get and initialize APPCC BadI.
  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      GET BADI mo_oif_appcc
        FILTERS
          wdapplicationconfigurationid = ls_fpm_runtime_info-config_id
          wd_application_name	         = ls_fpm_runtime_info-application.
      CALL BADI mo_oif_appcc->initialization
        EXPORTING
          io_wire_services = mo_wire_services.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      GET BADI mo_ovp_appcc
        FILTERS
          wdapplicationconfigurationid = ls_fpm_runtime_info-config_id
          wd_application_name	         = ls_fpm_runtime_info-application.
      CALL BADI mo_ovp_appcc->initialization
        EXPORTING
          io_wire_services = mo_wire_services.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      GET BADI mo_gaf_appcc
        FILTERS
          wdapplicationconfigurationid = ls_fpm_runtime_info-config_id
          wd_application_name	         = ls_fpm_runtime_info-application.
      CALL BADI mo_gaf_appcc->initialization
        EXPORTING
          io_wire_services = mo_wire_services.
  ENDCASE.

ENDMETHOD.


METHOD needs_confirmation.

  CLEAR: eo_confirmation_request,
         ev_skip_standard.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->needs_confirmation
        EXPORTING
          io_event                = io_event
          it_uibbs                = it_uibbs
        CHANGING
          co_confirmation_request = eo_confirmation_request
          cv_skip_standard        = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->needs_confirmation
        EXPORTING
          io_event                = io_event
          it_uibbs                = it_uibbs
        CHANGING
          co_confirmation_request = eo_confirmation_request
          cv_skip_standard        = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->needs_confirmation
        EXPORTING
          io_event                = io_event
          it_uibbs                = it_uibbs
        CHANGING
          co_confirmation_request = eo_confirmation_request
          cv_skip_standard        = ev_skip_standard.
  ENDCASE.

ENDMETHOD.


METHOD override_config_tabbed.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->override_config_tabbed
        EXPORTING
          io_tabbed = io_tabbed.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->override_config_tabbed
        EXPORTING
          io_tabbed = io_tabbed.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->override_config_tabbed
        EXPORTING
          io_tabbed = io_tabbed.
  ENDCASE.

  LOOP AT mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>.
    <ls_callback_proxy_pool>-callback_proxy->override_config_tabbed(
      EXPORTING io_tabbed = io_tabbed ).
  ENDLOOP.

ENDMETHOD.


METHOD override_event_gaf.

  CALL BADI mo_gaf_appcc->override_event_gaf
    EXPORTING
      io_gaf = io_gaf.

ENDMETHOD.


METHOD override_event_oif.

  FIELD-SYMBOLS:
    <ls_callback_proxy_pool> TYPE           gty_s_callback_proxy_pool.

  CALL BADI mo_oif_appcc->override_event_oif
    EXPORTING
      io_oif = io_oif.

  LOOP AT mt_callback_proxy_pool ASSIGNING <ls_callback_proxy_pool>.
    <ls_callback_proxy_pool>-callback_proxy->override_event( io_oif = io_oif ).
  ENDLOOP.

ENDMETHOD.


METHOD override_event_ovp.

  CALL BADI mo_ovp_appcc->override_event_ovp
    EXPORTING
      io_ovp = io_ovp.

ENDMETHOD.


METHOD process_before_output.

  CLEAR: ev_skip_standard.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->process_before_output
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard.
  ENDCASE.

ENDMETHOD.


METHOD process_event.

  CLEAR: ev_skip_standard,
         ev_result.

  CASE mv_floorplan_type.
    WHEN if_fpm_constants=>gc_floorplan-oif.
      CALL BADI mo_oif_appcc->process_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard
          cv_result        = ev_result.
    WHEN if_fpm_constants=>gc_floorplan-ovp.
      CALL BADI mo_ovp_appcc->process_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard
          cv_result        = ev_result.
    WHEN if_fpm_constants=>gc_floorplan-gaf.
      CALL BADI mo_gaf_appcc->process_event
        EXPORTING
          io_event         = io_event
          it_uibbs         = it_uibbs
        CHANGING
          cv_skip_standard = ev_skip_standard
          cv_result        = ev_result.
  ENDCASE.

ENDMETHOD.
ENDCLASS.