class /PLMU/CL_FRW_APPL_CNTRL_ASSIST definition
  public
  inheriting from /PLMU/CL_FRW_ASSIST
  final
  create public .

public section.
  interface IF_FPM_NAVIGATION load .

  class-data GV_IS_MASTER type BOOLE_D read-only .

  events AFTER_OVERRIDE_EVENT_OIF
    exporting
      value(IO_OIF) type ref to IF_FPM_OIF .
  events BEFORE_AFTER_PBO
    exporting
      value(IO_EVENT) type ref to CL_FPM_EVENT
      value(IR_UIBBS_TABLE) type ref to FPM_T_UIBB_COMPONENTS .
  events AFTER_AFTER_PBO .

  methods AFTER_AFTER_FAILED_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
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
  methods BEFORE_AFTER_FAILED_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods BEFORE_FLUSH
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods BEFORE_NEEDS_CONFIRMATION
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods BEFORE_PROCESS_BEFORE_OUTPUT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS .
  methods BEFORE_PROCESS_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IT_UIBBS type FPM_T_UIBB_COMPONENTS
    exporting
      !EV_RESULT type FPM_EVENT_RESULT .
  methods CHECK_BEFORE_SAVE
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
    exporting
      !EV_REJECTED type BOOLE_D .
  methods CONSTRUCTOR .
  methods FPM_INITIALIZE
    importing
      !IO_FPM type ref to IF_FPM .
  methods IS_DIRTY
    returning
      value(RV_IS_DIRTY) type BOOLE_D .
  methods OVERRIDE_EVENT_GAF
    importing
      !IO_GAF type ref to IF_FPM_GAF .
  methods OVERRIDE_EVENT_OIF
    importing
      !IO_OIF type ref to IF_FPM_OIF .
  methods OVERRIDE_EVENT_OVP
    importing
      !IO_OVP type ref to IF_FPM_OVP .
  methods SAVE
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
    exporting
      !EV_REJECTED type BOOLE_D .
  methods WDDOAFTERACTION .
  methods WDDOBEFOREACTION .
  methods WDDOBEFORENAVIGATION .
  methods WDDOEXIT .
  methods WDDOPOSTPROCESSING .

  methods WDDOINIT
    redefinition .
protected section.
private section.

  types GTY_FLUSH_STATUS type CHAR2 .

  constants:
    BEGIN OF gc_flush_status,
      pending   TYPE gty_flush_status VALUE 'PE',
      processed TYPE gty_flush_status VALUE 'PR',
      deferred  TYPE gty_flush_status VALUE 'DE',
      aborted   TYPE gty_flush_status VALUE 'AB',
    END   OF gc_flush_status .
  constants GC_SIDEPANEL_NODE_NAME type STRING value `SIDE_PANEL` ##NO_TEXT.
  data MO_CNR_CONTROLLER_GAF type ref to /PLMU/CL_FRW_CNR_CNTRL_GAF .
  data MO_CNR_CONTROLLER_OIF type ref to /PLMU/CL_FRW_CNR_CNTRL_OIF .
  data MO_CNR_CONTROLLER_OVP type ref to /PLMU/CL_FRW_CNR_CNTRL_OVP .
  data MO_CONFIRMATION_REQUEST type ref to CL_FPM_CONFIRMATION_REQUEST .
  data MO_CONTEXT_APPL_MODEL_POOL type ref to /PLMU/CL_FRW_C_APPL_MODEL_POOL .
  data MO_CONTEXT_POOL type ref to /PLMU/CL_FRW_CONTEXT_POOL .
  data MO_FPM type ref to IF_FPM .
  data MO_FUIBB_APPL_MODEL_POOL type ref to /PLMU/CL_FRW_F_APPL_MODEL_POOL .
  data MO_SIDEPANEL_CONTROLLER type ref to /PLMU/CL_FRW_SIDEPANEL_CNTRL .
  data MO_WD_COMPONENT type ref to IF_WD_COMPONENT .
  data MV_FLUSH_STATUS type GTY_FLUSH_STATUS .
  data MV_SKIP_PROCESS_EVENT type BOOLE_D .
  data MV_FPM_EVENT_TRIGGERED type BOOLE_D .
  data MV_NO_WD_ONLY_EVENT type BOOLE_D .

  methods CHECK_ENTRIES .
  methods FLUSH .
  methods GET_FPM_EDIT_MODE
    returning
      value(RV_FPM_EDIT_MODE) type FPM_EDIT_MODE .
  methods GET_START_MODE
    importing
      !IV_CHECK_CONSISTENCY type BOOLE_D default ABAP_TRUE
    returning
      value(RV_MODE) type /PLMB/SPI_MODE .
  methods HNDL_SPECIAL_WDA_EVENT
    for event SPECIAL_WDA_EVENT of CL_FPM_FLOORPLAN_ASSIST
    importing
      !WDA_EVENT
      !FPM .
  methods LEAVE_TRANSACTION
    importing
      !IO_OIF type ref to IF_FPM_OIF .
  methods OVERRIDE_EVENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IO_WIRE_MODEL type ref to IF_FPM_WIRE_MODEL
    exporting
      !EV_CANCEL_EVENT type BOOLE_D .
  methods REMOVE_ACA_UIBBS
    importing
      !IV_ACA_LOCATION type FPM_ACA_LOCATION
      !IO_ACA type ref to IF_FPM_ACA .
  methods RESTART_SESSION
    importing
      !IO_EVENT type ref to CL_FPM_EVENT .
  methods SWITCH_VIEW .
  methods HNDL_UNSAVED_DATA_EXISTS
    for event UNSAVED_DATA_EXISTS of /PLMB/CL_SPI_CONNECTOR
    importing
      !IV_UNSAVED_DATA_EXISTS .
ENDCLASS.



CLASS /PLMU/CL_FRW_APPL_CNTRL_ASSIST IMPLEMENTATION.


METHOD after_after_failed_event.

  go_callback_proxy_pool->after_after_failed_event(
    EXPORTING io_event = io_event
              it_uibbs = it_uibbs ).

ENDMETHOD.


METHOD after_flush.

  CLEAR mv_fpm_event_triggered.  "note 2579051

  go_callback_proxy_pool->after_flush(
    EXPORTING io_event = io_event
              it_uibbs = it_uibbs ).

ENDMETHOD.


METHOD after_needs_confirmation.

  IF   mo_confirmation_request  IS NOT INITIAL
   AND ct_confirmation_requests IS INITIAL.
    INSERT mo_confirmation_request INTO ct_confirmation_requests INDEX 1.
  ENDIF.

  go_callback_proxy_pool->after_needs_confirmation(
    EXPORTING io_event                 = io_event
              it_uibbs                 = it_uibbs
    changing  ct_confirmation_requests = ct_confirmation_requests ).

  IF ct_confirmation_requests IS NOT INITIAL.
    gv_confirmation_running = abap_true.
  ENDIF.

ENDMETHOD.


METHOD after_process_before_output.

  DATA:
    lr_uibbs_table           TYPE REF TO    fpm_t_uibb_components.

  GET REFERENCE OF it_uibbs INTO lr_uibbs_table.
  RAISE EVENT before_after_pbo
    EXPORTING
      io_event       = io_event
      ir_uibbs_table = lr_uibbs_table.

  go_callback_proxy_pool->after_process_before_output(
    EXPORTING io_event = io_event
              it_uibbs = it_uibbs ).

  CLEAR /plmu/cl_frw_appl_cntrl=>gv_fpm_eventid.

  RAISE EVENT after_after_pbo.

ENDMETHOD.


METHOD after_process_event.

  DATA:
    lv_mode                  TYPE           /plmb/spi_mode,
    lo_frw_exc               TYPE REF TO    /plmb/cx_frw.

  go_callback_proxy_pool->after_process_event(
    EXPORTING io_event  = io_event
              it_uibbs  = it_uibbs
    CHANGING  cv_result = cv_result ).

  IF cv_result = if_fpm_constants=>gc_event_result-failed
    OR mv_skip_process_event = abap_true.
    RETURN.
  ENDIF.

  "Process framework logic for common events
  "(Can be skipped either via cancelling the whole event
  " or by setting EV_SKIP_STANDARD of APPCC method PROCESS_EVENT).
  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_check.
      check_entries( ).

    WHEN cl_fpm_event=>gc_event_start.
      IF gv_floorplan_state = if_fpm_constants=>gc_floorplan_state-main_area.
        "Activate sidepanel for applications without initial screen.
        mo_sidepanel_controller->trigger_activation( ).
      ENDIF.

    WHEN cl_fpm_event=>gc_event_leave_initial_screen.
      gv_leaving_initial_screen = abap_true.
      gv_floorplan_state        = if_fpm_constants=>gc_floorplan_state-main_area.
      "Activate sidepanel for applications with initial screen.
      mo_sidepanel_controller->trigger_activation( ).

    WHEN cl_fpm_event=>gc_event_edit.
      /plmu/cl_frw_appl_cntrl=>set_mode( /plmu/if_frw_constants=>gc_mode-change ).
      go_appl_model_pool->clean_up(
        EXPORTING iv_reason = /plmu/if_frw_constants=>gc_cleanup_reason-buffer_refresh ).

    WHEN cl_fpm_event=>gc_event_read_only
      OR cl_fpm_event=>gc_event_cancel.
      "Set the UI to read only mode,...
      /plmu/cl_frw_appl_cntrl=>set_mode( /plmu/if_frw_constants=>gc_mode-display ).
      "...clear obsolete messages,
      go_appl_model_pool->clear_messages( ).
      go_message_manager->clear_messages( iv_current_roundtrip = abap_true ).
      "...set all contextes to read only
      mo_context_pool->read_only( ).
      "...and clean up all application models.
      go_appl_model_pool->clean_up(
        EXPORTING iv_reason = /plmu/if_frw_constants=>gc_cleanup_reason-rollback ).

    WHEN cl_fpm_event=>gc_event_refresh.
      "Refresh UI:...
      IF /plmu/cl_frw_appl_cntrl=>gv_mode <> /plmu/if_frw_constants=>gc_mode-display.
        "...in edit/create mode we must clear potential obsolete messages
        go_appl_model_pool->clear_messages( ).
        go_message_manager->clear_messages( iv_current_roundtrip = abap_true ).
      ENDIF.
      "...and clean up all application models.
      go_appl_model_pool->clean_up(
        EXPORTING iv_reason = /plmu/if_frw_constants=>gc_cleanup_reason-rollback ).

    WHEN cl_fpm_event=>gc_event_close.
      gv_close_in_progress = abap_true.

    WHEN cl_fpm_event=>gc_event_delete_current_object.
      RAISE EVENT root_about_to_be_deleted
        EXPORTING
          iv_root_delete = abap_true.

    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_change
      OR /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_create
      OR /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_display.
      restart_session( io_event ).

    WHEN cl_fpm_event=>gc_event_start_over.
      "We need to raise an additional event to ensure that the UI is
      "consistent (e.g. to the mode) since after the start-over-event is
      "completely processed the FPM will reinitialize the UI completely.
      mo_fpm->raise_event_by_id(
        EXPORTING iv_event_id = /plmu/if_frw_constants=>gc_fpm_event_id-after_start_over ).

    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-after_start_over.
      "Reset the UI mode.
      lv_mode = get_start_mode( iv_check_consistency = abap_false ).
      IF /plmu/cl_frw_appl_cntrl=>gv_mode <> lv_mode.
        /plmu/cl_frw_appl_cntrl=>set_mode( lv_mode ).
      ENDIF.
      "Reset of all CNR button properties mandatory because
      "start-over-event initializes all properties.
      IF mo_fpm->mv_edit_mode_supported <> abap_true.
        /plmu/cl_frw_cnr_cntrl=>control_standard_buttons( ).
      ENDIF.

    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-activate_sidepanel.
      mo_sidepanel_controller->add_link_to_ui( ).

    WHEN cl_fpm_event=>gc_event_open_side_panel.
      mo_sidepanel_controller->refresh( iv_manual_refresh = abap_false ).

    WHEN OTHERS.
      "If event is service relevant, then process that service
      TRY.
          /plmu/cl_frw_action_util_int=>process_service_frw( io_event->mv_event_id(10) ).
        CATCH /plmb/cx_frw_no_data INTO lo_frw_exc.
          lo_frw_exc->get_message( ).
          /plmu/cl_frw_action_util=>collect_messages( ).
      ENDTRY.
  ENDCASE.

ENDMETHOD.


METHOD before_after_failed_event.

  "A potential confirmation that occurred before is done at this point.
  CLEAR gv_confirmation_running.

  go_callback_proxy_pool->after_failed_event(
    EXPORTING io_event  = io_event
              it_uibbs  = it_uibbs
              iv_revert = abap_true ).

ENDMETHOD.


METHOD before_flush.

  mv_fpm_event_triggered = abap_true.

  go_callback_proxy_pool->flush(
    EXPORTING io_event = io_event
              it_uibbs = it_uibbs ).

ENDMETHOD.


METHOD before_needs_confirmation.

  DATA:
    lv_text                  TYPE           string,
    lt_text                  TYPE           string_table,
    lv_title                 TYPE           string,
    lv_approve               TYPE           string,
    lv_reject                TYPE           string,
    lv_skip_standard         TYPE           boole_d.

  CLEAR mo_confirmation_request.

  go_callback_proxy_pool->needs_confirmation(
    EXPORTING io_event                = io_event
              it_uibbs                = it_uibbs
    IMPORTING eo_confirmation_request = mo_confirmation_request
              ev_skip_standard        = lv_skip_standard ).

  IF mo_confirmation_request IS INITIAL
    AND lv_skip_standard <> abap_true.
    "Check if a confirmation request is needed.
    CASE io_event->mv_event_id.
      WHEN cl_fpm_event=>gc_event_refresh
        OR cl_fpm_event=>gc_event_read_only
        OR cl_fpm_event=>gc_event_cancel
        OR /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_change
        OR /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_create
        OR /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_display.

        IF is_dirty( ) <> abap_true.
          "No confirmation required
          RETURN.
        ENDIF.

        APPEND text-001 TO lt_text.
        lv_title   = text-002.
        lv_approve = text-014.
        lv_reject  = text-013.

        CREATE OBJECT mo_confirmation_request
          EXPORTING
            it_confirmation_text   = lt_text
            iv_window_title        = lv_title
            iv_button_text_approve = lv_approve
            iv_button_text_reject  = lv_reject.

      WHEN cl_fpm_event=>gc_event_delete_current_object.
        APPEND text-005 TO lt_text.
        lv_title   = text-002.
        lv_approve = text-012.
        lv_reject  = text-013.

        CREATE OBJECT mo_confirmation_request
          EXPORTING
            it_confirmation_text   = lt_text
            iv_window_title        = lv_title
            iv_button_text_approve = lv_approve
            iv_button_text_reject  = lv_reject.

      WHEN cl_fpm_event=>gc_event_save.

        IF go_appl_model_pool->has_unsaved_data( ) = abap_false.
          RETURN.
        ENDIF.

        CASE go_message_manager->get_severity_of_published_msgs( ).
          WHEN /plmu/if_frw_constants=>gc_severity-error.
            lv_text = text-006.
          WHEN /plmu/if_frw_constants=>gc_severity-warning.
            lv_text = text-007.
          WHEN OTHERS.
            "No confirmation needed.
            RETURN.
        ENDCASE.
        "Open before save confirmation popup
        APPEND lv_text TO lt_text.
        lv_title   = text-009.
        lv_approve = text-014.
        lv_reject  = text-013.
        CREATE OBJECT mo_confirmation_request
          EXPORTING
            it_confirmation_text   = lt_text
            iv_window_title        = lv_title
            iv_button_text_approve = lv_approve
            iv_button_text_reject  = lv_reject.
    ENDCASE.
  ENDIF.

ENDMETHOD.


METHOD before_process_before_output.

  DATA:
    lv_skip_standard         TYPE           boole_d ##needed.

  "Match FRW_MODE to FPM_EDIT_MODE.
  CASE get_fpm_edit_mode( ).
    WHEN if_fpm_constants=>gc_edit_mode-edit.
      IF /plmu/cl_frw_appl_cntrl=>gv_mode = /plmu/if_frw_constants=>gc_mode-display.
        /plmu/cl_frw_appl_cntrl=>set_mode( /plmu/if_frw_constants=>gc_mode-change ).
      ENDIF.
    WHEN if_fpm_constants=>gc_edit_mode-read_only.
      IF   /plmu/cl_frw_appl_cntrl=>gv_mode = /plmu/if_frw_constants=>gc_mode-change
        OR /plmu/cl_frw_appl_cntrl=>gv_mode = /plmu/if_frw_constants=>gc_mode-create.
        /plmu/cl_frw_appl_cntrl=>set_mode( /plmu/if_frw_constants=>gc_mode-display ).
      ENDIF.
    WHEN OTHERS.
      "FPM_EDIT_MODE has not been set.
  ENDCASE.

  go_callback_proxy_pool->process_before_output(
    EXPORTING io_event           = io_event
              it_uibbs           = it_uibbs
    IMPORTING ev_skip_standard   = lv_skip_standard ).

ENDMETHOD.


METHOD before_process_event.

  "A potential confirmation that occurred before is done at this point.
  CLEAR: gv_confirmation_running,
         ev_result,
         mv_skip_process_event.

  go_callback_proxy_pool->process_event(
    EXPORTING io_event         = io_event
              it_uibbs         = it_uibbs
    IMPORTING ev_result        = ev_result
              ev_skip_standard = mv_skip_process_event ).

ENDMETHOD.


METHOD check_before_save.

  CLEAR ev_rejected.

  go_appl_model_pool->check_before_save(
    IMPORTING ev_failed = ev_rejected ).

  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_delete_current_object.
      IF ev_rejected = abap_true.
        RAISE EVENT root_about_to_be_deleted
          EXPORTING
            iv_root_delete = abap_false.
      ENDIF.
  ENDCASE.

ENDMETHOD.


METHOD check_entries.

  DATA:
    lv_message_dummy         TYPE           string ##needed.

  IF go_message_manager->get_severity_of_published_msgs( ) CA /plmu/if_frw_constants=>gc_severity_category-error_or_worse.
    RETURN.
  ENDIF.

  MESSAGE s002(/plmu/ui_frw) INTO lv_message_dummy.
  go_message_manager->/plmu/if_frw_message_manager~publish_system_message( ).

ENDMETHOD.


METHOD constructor.

  super->constructor( ).


  "Activate event handler.
  SET HANDLER: hndl_unsaved_data_exists . "Note 2020417 set the work proection

  mo_context_pool            = /plmu/cl_frw_context_pool=>get_instance( ).
  mo_context_appl_model_pool = /plmu/cl_frw_c_appl_model_pool=>get_instance( ).
  mo_fuibb_appl_model_pool   = /plmu/cl_frw_f_appl_model_pool=>get_instance( ).

ENDMETHOD.


METHOD flush.

  IF mv_flush_status <> gc_flush_status-pending.
    "Flush was already triggered this roundtrip.
    RETURN.
  ENDIF.

  go_message_manager->clear_messages( iv_last_roundtrip = abap_true ).

  IF go_message_manager->/plmu/if_frw_message_manager~has_validation_errors( ) = abap_true.
    "When an error during the WebDynpro validation occurred we defer the flush.
    mv_flush_status     = gc_flush_status-deferred.
    gv_validation_error = abap_true.
    RETURN.
  ELSE.
    CLEAR gv_validation_error.
  ENDIF.

  IF   gv_floorplan_state = if_fpm_constants=>gc_floorplan_state-init_screen
    OR gv_floorplan_state = if_fpm_constants=>gc_floorplan_state-conf_screen
    OR gv_floorplan_state = if_fpm_constants=>gc_floorplan_state-error_screen
    OR gv_close_in_progress = abap_true
    OR /plmu/cl_frw_appl_cntrl=>gv_root_delete = abap_true.
    "We avoid the automatic flush in some floorplan states,
    "when the UI is getting closed or the root object is being deleted.
    mv_flush_status = gc_flush_status-aborted.
    RETURN.
  ENDIF.

  "Clean up models that are superfluous.
  go_appl_model_pool->garbage_collector( ).

  "Flush data of freestyle UIBBs.
  mo_fuibb_appl_model_pool->flush( ).

  "Set flush status accordingly.
  mv_flush_status = gc_flush_status-processed.

ENDMETHOD.


METHOD fpm_initialize.

  DATA:
    ls_runtime_info          TYPE           fpm_s_runtime_info,
    lv_auto_wire             TYPE           boole_d.

  mo_fpm = io_fpm.

  /plmu/cl_frw_appl_cntrl=>go_fpm = io_fpm.

  /plmu/cl_frw_component_manager=>get_instance( )->initialize(
    io_fpm          = io_fpm
    io_wd_component = mo_wd_component ).

  "Get application parameter from FPM (application name, config ID, floorplan type)
  ls_runtime_info = io_fpm->get_runtime_info( ).
  /plmu/cl_frw_appl_cntrl=>gv_application_config_id = ls_runtime_info-config_id.
  /plmu/cl_frw_appl_cntrl=>gv_wdy_appl_name         = ls_runtime_info-application.

  "Setup sidepanel controller.
  mo_sidepanel_controller->set_floorplan_type( ls_runtime_info-floorplan ).

  IF ls_runtime_info-floorplan = if_fpm_constants=>gc_floorplan-oif.
    io_fpm->mo_app_parameter->get_value(
      EXPORTING iv_key   = /plmu/if_frw_constants=>gc_application_parameter-auto_wire
      IMPORTING ev_value = lv_auto_wire ).
    IF lv_auto_wire = abap_true.
      TRY.
          /plmu/cl_frw_w_creator=>get_instance( )->activate( ).
        CATCH /plmu/cx_frw_wire.
          RAISE EXCEPTION TYPE /plmu/cx_frw_services_error
            EXPORTING
              textid = /plmu/cx_frw_services_error=>auto_wire_impossible.
      ENDTRY.
    ENDIF.
  ENDIF.

  SET HANDLER hndl_special_wda_event FOR ALL INSTANCES.

ENDMETHOD.


METHOD get_fpm_edit_mode.

  DATA:
    lv_blank_window          TYPE           fpm_window_name ##needed,
    ls_blank_uibb_key        TYPE           fpm_s_uibb_instance_key ##needed.

  rv_fpm_edit_mode = mo_fpm->get_uibb_edit_mode(
                       is_uibb_instance_key = ls_blank_uibb_key
                       iv_window_name       = lv_blank_window ).

ENDMETHOD.


METHOD get_start_mode.

  mo_fpm->mo_app_parameter->get_value(
    EXPORTING iv_key   = /plmu/if_frw_constants=>gc_application_parameter-mode
    IMPORTING ev_value = rv_mode ).
  IF rv_mode IS INITIAL.
    CASE get_fpm_edit_mode( ).
      WHEN if_fpm_constants=>gc_edit_mode-edit.
        rv_mode = /plmu/if_frw_constants=>gc_mode-change.
      WHEN OTHERS.
        rv_mode = /plmu/if_frw_constants=>gc_mode-display.
    ENDCASE.
  ELSE.
    "Tolerate lower case FRW_MODE coming from application parameters.
    TRANSLATE rv_mode TO UPPER CASE.
    IF iv_check_consistency = abap_true.
      "Check if the application parameter FRW_MODE fits
      "to the FPM edit mode from the floorplan configuration.
      CASE get_fpm_edit_mode( ).
        WHEN if_fpm_constants=>gc_edit_mode-edit.
          IF rv_mode = /plmu/if_frw_constants=>gc_mode-display.
            "FRW_MODE doesn't fit to FPM edit mode!
            RAISE EXCEPTION TYPE /plmu/cx_frw_error
              EXPORTING
                textid = /plmu/cx_frw_error=>frw_fpm_mode_mismatch.
          ENDIF.
        WHEN if_fpm_constants=>gc_edit_mode-read_only.
          IF rv_mode <> /plmu/if_frw_constants=>gc_mode-display.
            "FRW_MODE doesn't fit to FPM edit mode!
            RAISE EXCEPTION TYPE /plmu/cx_frw_error
              EXPORTING
                textid = /plmu/cx_frw_error=>frw_fpm_mode_mismatch.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD hndl_special_wda_event.

  IF fpm <> mo_fpm.
    "The event was raised by another FPM instance.
    RETURN.
  ENDIF.

  CASE wda_event.
    WHEN 'WDDOBEFOREACTION'.
      wddobeforeaction( ).
    WHEN 'WDDOAFTERACTION'.
      wddoafteraction( ).
  ENDCASE.

ENDMETHOD.


method HNDL_UNSAVED_DATA_EXISTS.

  DATA:
    lo_portal_manager TYPE REF TO if_wd_portal_integration.

"Note 2020417 set the work proection
     IF iv_unsaved_data_exists = abap_true.
      "Hand over dirty flag to Web Dynpro,
      "which will lead to a data-loss popup in NWBC and Portal.
      lo_portal_manager = mo_wd_component->get_portal_manager( ).
      lo_portal_manager->set_work_protect_mode(
        EXPORTING mode = if_wd_portal_integration=>co_wp_mode_both ).
      lo_portal_manager->set_application_dirty_flag(
        EXPORTING dirty_flag = abap_true ).
    ENDIF.

endmethod.


METHOD is_dirty.

  IF /plmu/cl_frw_appl_cntrl=>gv_mode = /plmu/if_frw_constants=>gc_mode-display
    OR (     go_appl_model_pool->has_unsaved_data( )  <> abap_true
         AND /plmu/cl_frw_appl_model=>gv_update_error <> abap_true
         AND gv_validation_error                      <> abap_true ).
    RETURN.
  ENDIF.

  rv_is_dirty = abap_true.

ENDMETHOD.


METHOD leave_transaction.

  DATA:
    ls_state                 TYPE           if_fpm_oif=>ty_s_state,
    lt_variants              TYPE           if_fpm_oif=>ty_t_variant,
    lt_mainviews             TYPE           if_fpm_oif=>ty_t_mainview,
    lt_subviews              TYPE           if_fpm_oif=>ty_t_subview,
    lt_button                TYPE           if_fpm_cnr_oif=>t_button,
    lt_button_choice         TYPE           if_fpm_cnr_oif=>t_button_choice,
    lt_separator             TYPE           if_fpm_cnr_oif=>t_separator,
    lt_uibb                  TYPE           if_fpm_oif=>ty_t_uibb_ext,
    ls_uibb                  LIKE LINE OF   lt_uibb,
    lv_uibb                  TYPE           sytabix,
    ls_yca                   TYPE           if_fpm_cnr_oif=>s_menubar,
    lo_aca                   TYPE REF TO    if_fpm_aca,
    lo_cnr_oif               TYPE REF TO    if_fpm_cnr_oif,
    lo_idr                   TYPE REF TO    if_fpm_idr,
    lt_keys                  TYPE           if_fpm_idr=>t_item_group_keys.
  FIELD-SYMBOLS:
    <ls_variant>             TYPE           if_fpm_oif=>ty_s_variant,
    <ls_mainview>            TYPE           if_fpm_oif=>ty_s_mainview,
    <ls_subview>             LIKE LINE OF   lt_subviews,
    <ls_key>                 LIKE LINE OF   lt_keys,
    <ls_button>              LIKE LINE OF   lt_button,
    <ls_button_choice>       LIKE LINE OF   lt_button_choice,
    <ls_separator>           LIKE LINE OF   lt_separator.

  io_oif->get_current_state(
   IMPORTING es_current_state = ls_state ).

  TRY.
      "Set IDR to invisibles since context is empty
      lo_cnr_oif ?= mo_fpm->get_service(
        cl_fpm_service_manager=>gc_key_cnr_oif ).
      lo_idr ?= mo_fpm->get_service(
        cl_fpm_service_manager=>gc_key_idr ).
      lo_idr->set_header_visibility(
        EXPORTING iv_visible = abap_false ).
      lo_idr->set_ticket_visibility(
        EXPORTING iv_visible = abap_false ).
      lo_idr->set_items_visibility(
        EXPORTING iv_visible = abap_false ).

      lt_keys = lo_idr->get_item_group_keys(  ).
      LOOP AT lt_keys ASSIGNING <ls_key>.
        lo_idr->remove_item_group( EXPORTING iv_key = <ls_key> ).
      ENDLOOP.
    CATCH cx_fpm_idr ##no_handler.
  ENDTRY.

  "Remove all Mainviews
  io_oif->get_variants( IMPORTING et_variant = lt_variants ).
  LOOP AT lt_variants ASSIGNING <ls_variant>
    WHERE id = ls_state-variant.

    CLEAR:
     lt_mainviews,
     lt_button,
     lt_button_choice,
     lt_separator,
     ls_yca.

    TRY.
        io_oif->get_mainviews(
          EXPORTING iv_variant_id = <ls_variant>-id
          IMPORTING et_mainview   = lt_mainviews ).
      CATCH cx_fpm_floorplan ##no_handler.
    ENDTRY.
    LOOP AT lt_mainviews ASSIGNING <ls_mainview>.
      IF <ls_mainview>-id = ls_state-mainview.
        CLEAR lt_subviews.
        TRY.
            io_oif->get_subviews(
              EXPORTING iv_variant_id  = <ls_variant>-id
                        iv_mainview_id = <ls_mainview>-id
              IMPORTING et_subview     = lt_subviews  ).
          CATCH cx_fpm_floorplan ##no_handler.
        ENDTRY.

        LOOP AT lt_subviews ASSIGNING <ls_subview>.
          IF <ls_subview>-id = ls_state-subview.
            CLEAR:
              lt_uibb.
            TRY.
                io_oif->get_uibb_keys(
                  EXPORTING iv_variant_id	 = <ls_variant>-id
                            iv_mainview_id = <ls_mainview>-id
                            iv_subview_id  = <ls_subview>-id
                  IMPORTING et_uibb	       = lt_uibb ).
              CATCH cx_fpm_floorplan ##no_handler.
            ENDTRY.
            LOOP AT lt_uibb TRANSPORTING NO FIELDS
              WHERE variant = <ls_variant>-id.
              lv_uibb = sy-tabix.
              TRY.
                  io_oif->remove_uibb(
                    EXPORTING iv_variant_id  = <ls_variant>-id
                              iv_mainview_id = <ls_mainview>-id
                              iv_subview_id  = <ls_subview>-id
                              iv_index       = 1 ).
                  DELETE lt_uibb INDEX lv_uibb.
                CATCH cx_fpm_floorplan ##no_handler.
              ENDTRY.
            ENDLOOP.
            "Attach Update control component to all Main/Sub-views
            ls_uibb-component      = '/PLMU/WDC_FRW_TRANS_CNTRL'.
            ls_uibb-interface_view = 'W_MAIN'.
            READ TABLE lt_uibb TRANSPORTING NO FIELDS
              WITH KEY variant        = <ls_variant>-id
                       mainview       = <ls_mainview>-id
                       subview        = <ls_subview>-id
                       component      = ls_uibb-component
                       interface_view = ls_uibb-interface_view.
            IF sy-subrc IS NOT INITIAL.
              ls_uibb-variant  = <ls_variant>-id.
              ls_uibb-mainview = <ls_mainview>-id.
              ls_uibb-subview  = <ls_subview>-id.
              TRY.
                  io_oif->add_uibb( is_uibb_key = ls_uibb ).
                CATCH cx_fpm_floorplan ##no_handler.
              ENDTRY.
            ENDIF.

          ELSE.
            TRY.
                io_oif->remove_subview(
                  EXPORTING iv_variant_id  = <ls_variant>-id
                            iv_mainview_id = <ls_mainview>-id
                            iv_subview_id  = <ls_subview>-id ).
              CATCH cx_fpm_floorplan ##no_handler.
            ENDTRY.

          ENDIF.
        ENDLOOP.

      ELSE.
        TRY.
            io_oif->remove_mainview(
              EXPORTING iv_variant_id  = <ls_variant>-id
                        iv_mainview_id = <ls_mainview>-id ).
          CATCH cx_fpm_floorplan ##no_handler.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    "Remove duplicate toolbar
    lo_cnr_oif->set_duplicate_toolbar(
      EXPORTING iv_variant_id              = <ls_variant>-id
                iv_activate_bottom_toolbar = abap_false ).

    "Set all buttons to invisible
    lo_cnr_oif->get_buttons(
      EXPORTING iv_variant_id = <ls_variant>-id
      IMPORTING et_buttons    = lt_button ).
    LOOP AT lt_button ASSIGNING <ls_button>
      WHERE visibility = cl_wd_uielement=>e_visible-visible.
      lo_cnr_oif->define_button(
        EXPORTING iv_variant_id     = <ls_variant>-id
                  iv_function       = <ls_button>-function
                  iv_element_id     = <ls_button>-element_id
                  iv_sequence_id    = <ls_button>-other_function_index
                  iv_design         = <ls_button>-design
                  iv_enabled        = abap_false
                  iv_explanation    = <ls_button>-explanation
                  iv_on_action      = <ls_button>-on_action
                  iv_text           = <ls_button>-text
                  iv_tooltip        = <ls_button>-tooltip
                  iv_visibility     = cl_wd_uielement=>e_visible-none
                  iv_default_button = abap_false ).
    ENDLOOP.

    "Set all button choice to invisible
    lo_cnr_oif->get_button_choices(
       EXPORTING iv_variant_id     = <ls_variant>-id
       IMPORTING et_button_choices = lt_button_choice ).
    LOOP AT lt_button_choice ASSIGNING <ls_button_choice>
      WHERE visibility = cl_wd_uielement=>e_visible-visible.
      lo_cnr_oif->define_button_choice(
        EXPORTING iv_variant_id        = <ls_variant>-id
                  iv_function          = <ls_button_choice>-function
                  iv_element_id        = <ls_button_choice>-element_id
                  iv_sequence_id       = <ls_button_choice>-other_function_index
                  iv_enabled           = abap_false
                  iv_text              = <ls_button_choice>-text
                  iv_tooltip           = <ls_button_choice>-tooltip
                  iv_visibility        = cl_wd_uielement=>e_visible-none
                  it_menu_action_items = <ls_button_choice>-menu_action_items ).
    ENDLOOP.

    "Remove separators
    lo_cnr_oif->get_separators(
      EXPORTING iv_variant_id = <ls_variant>-id
      IMPORTING et_separators = lt_separator ).

    LOOP AT lt_separator ASSIGNING <ls_separator>.
      lo_cnr_oif->remove_separator(
        EXPORTING iv_variant_id = <ls_variant>-id
                  iv_sequence_id = <ls_separator>-sequence_id ).
    ENDLOOP.

    "Set YCA to invisible
    lo_cnr_oif->get_you_can_also(
      EXPORTING iv_variant_id   = <ls_variant>-id
      IMPORTING es_you_can_also = ls_yca ).

    IF ls_yca-visibility = cl_wd_uielement=>e_visible-visible.
      lo_cnr_oif->define_you_can_also(
        EXPORTING iv_variant_id = <ls_variant>-id
                  iv_role       = ls_yca-role
                  iv_instance   = ls_yca-instance
                  iv_label      = ls_yca-label
                  iv_visibility = cl_wd_uielement=>e_visible-none ).
    ENDIF.

    "Set Related Links to invisible
    CLEAR ls_yca.
    lo_cnr_oif->get_related_links(
      EXPORTING iv_variant_id    = <ls_variant>-id
      IMPORTING es_related_links = ls_yca ).

    IF ls_yca-visibility = cl_wd_uielement=>e_visible-visible.
      lo_cnr_oif->define_related_links(
        EXPORTING iv_variant_id = <ls_variant>-id
                  iv_role       = ls_yca-role
                  iv_instance   = ls_yca-instance
                  iv_label      = ls_yca-label
                  iv_visibility = cl_wd_uielement=>e_visible-none ).
    ENDIF.
  ENDLOOP.

  "Remove all ACA UIBBS
  lo_aca = io_oif->get_aca_api( ).

  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'ii1'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'ii2'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'oc1'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'oc2'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'ii3'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'oc3'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'oc4'
              io_aca          = lo_aca ).
  remove_aca_uibbs(
    EXPORTING iv_aca_location = 'oc5'
              io_aca          = lo_aca ).

ENDMETHOD.                    "leave_transaction


METHOD override_event.

  DATA:
    lo_frw_exc               TYPE REF TO    /plmb/cx_frw.

  CLEAR ev_cancel_event.
  MV_NO_WD_ONLY_EVENT = abap_true. "note 3049172

  /plmu/cl_frw_appl_cntrl=>gv_fpm_eventid = io_event->mv_event_id.

  "Check if FPM event needs to be cancelled because of errors.
  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_close
      OR cl_fpm_event=>gc_event_read_only
      OR cl_fpm_event=>gc_event_refresh
      OR cl_fpm_event=>gc_event_cancel
      OR CL_FPM_EVENT=>GC_EVENT_OPEN_SIDE_PANEL     "note 2226624 side panel should be opened
      OR cl_fpm_event=>gc_event_goto_error_display.
      "Some events will never get cancelled by us,
      "since all those events will either close the UI or
      "trigger a complete clean up of all data.
    WHEN OTHERS.
      IF gv_validation_error = abap_true.
        "There is an error that occurred during the WebDynpro validation.
        ev_cancel_event = abap_true.
        RETURN.
      ELSEIF /plmu/cl_frw_appl_model=>gv_update_error = abap_true.
        "There is an error that occurred during the data flush.
        CASE io_event->mv_event_id.
          WHEN /plmu/if_frw_constants=>gc_fpm_event_id-delete
            OR if_fpm_guibb_list=>gc_fpm_event_on_lead_sel
            OR /plmu/if_frw_constants=>gc_fpm_event_id-selection_changed
            OR /plmu/if_frw_constants=>gc_fpm_event_id-lead_selection_changed.
            go_validation->validate_fpm_event(
              EXPORTING io_event                     = io_event
                        iv_validate_dependent_childs = abap_true
              IMPORTING ev_error                     = ev_cancel_event ).
            IF ev_cancel_event = abap_true.
              RETURN.
            ENDIF.
          WHEN OTHERS.
            ev_cancel_event = abap_true.
            RETURN.
        ENDCASE.
      ENDIF.
  ENDCASE.

  "Handle certain events
  "(Standard event processing is done in AFTER_PROCESS_EVENT)
  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_start.
      "En-/Disable CNR control for standard buttons.
      IF mo_fpm->mv_edit_mode_supported <> abap_true.
        "We will control the standard buttons of the CNR.
        /plmu/cl_frw_cnr_cntrl=>set_up(
          EXPORTING iv_refresh_cntrl_on_new_layout = abap_true ).
      ENDIF.
      "Set initial UI mode.
      /plmu/cl_frw_appl_cntrl=>set_mode( get_start_mode( ) ).
      "Register wire model at validation.
      go_validation->register_wire_model( io_wire_model ).
      "Initialize Callback Proxy (also consumer APPCC).
      go_callback_proxy_pool->initialize( ).

    WHEN cl_fpm_event=>gc_event_navigate.
      "Enrich navigation event with parameters.
      TRY.
          /plmu/cl_frw_action_util_int=>attach_parameters_to_event( io_event ).
        CATCH /plmb/cx_frw_no_data INTO lo_frw_exc.
          lo_frw_exc->get_message( ).
          /plmu/cl_frw_action_util=>collect_messages( ).
        CATCH /plmu/cx_frw_no_wd_component ##no_handler.
        CATCH /plmb/cx_frw ##no_handler.
      ENDTRY.
  ENDCASE.

ENDMETHOD.


METHOD override_event_gaf.

  DATA:
    ls_fpm_state             TYPE           if_fpm_gaf=>ty_s_state,
    lt_variant               TYPE           if_fpm_gaf=>ty_t_variant,
    lv_cancel_event          TYPE           boole_d.

  "Set floorplan state.
  io_gaf->get_current_state(
    IMPORTING es_current_state = ls_fpm_state ).
  gv_floorplan_state = ls_fpm_state-floorplan_state.

  "Setup CNR controller
  IF mo_cnr_controller_gaf IS INITIAL.
    mo_cnr_controller_gaf = /plmu/cl_frw_cnr_cntrl_gaf=>get_instance( ).
  ENDIF.
  io_gaf->get_variants(
    IMPORTING et_variant = lt_variant ).
  mo_cnr_controller_gaf->set_variants(
    EXPORTING it_variant = lt_variant ).

  "Call floorplan type independent override event logic.
  override_event(
    EXPORTING io_event        = io_gaf->mo_event
              io_wire_model   = io_gaf
    IMPORTING ev_cancel_event = lv_cancel_event ).
  IF lv_cancel_event = abap_true.
    io_gaf->cancel_event( ).
    RETURN.
  ENDIF.

  "Call override event of application.
  go_callback_proxy_pool->override_event_gaf(
    EXPORTING io_gaf = io_gaf ).

ENDMETHOD.


METHOD override_event_oif.

  DATA:
    ls_fpm_state             TYPE           if_fpm_oif=>ty_s_state,
    lt_variant               TYPE           if_fpm_oif=>ty_t_variant,
    lv_cancel_event          TYPE           boole_d.

  "Set floorplan state.
  io_oif->get_current_state(
    IMPORTING es_current_state = ls_fpm_state ).
  gv_floorplan_state = ls_fpm_state-floorplan_state.

  CASE io_oif->mo_event->mv_event_id.
    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-leave_transaction.
      leave_transaction(
        EXPORTING io_oif = io_oif ).
      RETURN.
  ENDCASE.

  "Setup CNR controller
  IF mo_cnr_controller_oif IS INITIAL.
    mo_cnr_controller_oif = /plmu/cl_frw_cnr_cntrl_oif=>get_instance( ).
  ENDIF.
  io_oif->get_variants(
    IMPORTING et_variant = lt_variant ).
  mo_cnr_controller_oif->set_variants(
    EXPORTING it_variant = lt_variant ).

  "Call floorplan type independent override event logic.
  override_event(
    EXPORTING io_event        = io_oif->mo_event
              io_wire_model   = io_oif
    IMPORTING ev_cancel_event = lv_cancel_event ).
  IF lv_cancel_event = abap_true.
    io_oif->cancel_event( ).
    RETURN.
  ENDIF.

  CASE io_oif->mo_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_leave_initial_screen.
      switch_view( ).
  ENDCASE.

  "Call override event of application.
  go_callback_proxy_pool->override_event_oif(
    EXPORTING io_oif = io_oif ).

  "After override event.
  RAISE EVENT after_override_event_oif
    EXPORTING io_oif = io_oif.

ENDMETHOD.


METHOD override_event_ovp.

  DATA:
    lv_cancel_event          TYPE           boole_d,
    ls_content_area          TYPE           if_fpm_ovp=>ty_s_content_area,
    lt_content_area          TYPE           if_fpm_ovp=>ty_t_content_area.

  "Get floorplan state.
  ls_content_area    = io_ovp->get_current_content_area( ).
  gv_floorplan_state = ls_content_area-type.

  "Setup CNR controller
  IF mo_cnr_controller_ovp IS INITIAL.
    mo_cnr_controller_ovp = /plmu/cl_frw_cnr_cntrl_ovp=>get_instance( ).
  ENDIF.
  io_ovp->get_content_areas(
    IMPORTING et_content_area = lt_content_area ).
  mo_cnr_controller_ovp->set_content_areas(
    EXPORTING it_content_area = lt_content_area ).

  "Call floorplan type independent override event logic.
  override_event(
    EXPORTING io_event        = io_ovp->get_event( )
              io_wire_model   = io_ovp
    IMPORTING ev_cancel_event = lv_cancel_event ).
  IF lv_cancel_event = abap_true.
    TRY.
        io_ovp->cancel_event( ).
      CATCH cx_fpm_floorplan ##no_handler.
    ENDTRY.
    RETURN.
  ENDIF.

  "Call override event of application.
  go_callback_proxy_pool->override_event_ovp(
    EXPORTING io_ovp = io_ovp ).

ENDMETHOD.


METHOD remove_aca_uibbs.

  DATA:
    lt_aca_uibb              TYPE           fpm_t_uibb_key.

  io_aca->get_uibb_keys(
    EXPORTING iv_aca_location = iv_aca_location
    IMPORTING et_uibb         = lt_aca_uibb ).

  DO lines( lt_aca_uibb ) TIMES.
    io_aca->remove_uibb(
      iv_aca_location = iv_aca_location
      iv_index        = 1 ).
  ENDDO.

ENDMETHOD.


METHOD restart_session.

  DATA:
     lv_frw_mode             TYPE           /plmb/spi_mode,
     lv_abb_desc             TYPE           /plmb/spi_abbid_desc,
     lv_header_text          TYPE           apb_lpd_link_text,
     lv_abbid                TYPE           /plmb/spi_abbid,
     lo_portal_manager       TYPE REF TO    if_wd_portal_integration,
     lo_application          TYPE REF TO    if_wd_application,
     ls_parameter            TYPE           apb_lpd_s_params,
     lt_keys                 TYPE           if_fpm_parameter=>t_keys,
     lt_parameter            TYPE           apb_lpd_t_params.
  FIELD-SYMBOLS:
     <ls_keys>               TYPE LINE OF   if_fpm_parameter=>t_keys,
     <ls_parameter>          TYPE           apb_lpd_s_params.

  "Get updcoming UI mode.
  CASE io_event->mv_event_id.
    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_create.
      lv_frw_mode = /plmu/if_frw_constants=>gc_mode-create.
    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_change.
      lv_frw_mode = /plmu/if_frw_constants=>gc_mode-change.
    WHEN /plmu/if_frw_constants=>gc_fpm_event_id-session_restart_display.
      lv_frw_mode = /plmu/if_frw_constants=>gc_mode-display.
  ENDCASE.

  "Reset dirty flag of portal environment if necessary.
  lo_application    = mo_wd_component->get_application( ).
  lo_portal_manager = mo_wd_component->get_portal_manager( ).
  IF lo_application->get_client_environment( ) = if_wd_application=>co_client_environment-portal.
    IF lo_portal_manager->m_dirty_flag = abap_true.
      lo_portal_manager->set_application_dirty_flag( abap_false ).
    ENDIF.
  ENDIF.

  "Add UI mode to parameter table
  ls_parameter-key  = /plmb/if_frw_action_c=>gc_param_frw_mode.
  ls_parameter-value = lv_frw_mode.
  APPEND ls_parameter TO lt_parameter.
  "Get all parameter out of the current event.
  lt_keys = io_event->mo_event_data->get_keys( ).
  LOOP AT lt_keys ASSIGNING <ls_keys>.
    ls_parameter-key  = <ls_keys>.
    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = <ls_keys>
      IMPORTING
        ev_value = ls_parameter-value ).
    APPEND ls_parameter TO lt_parameter.
  ENDLOOP.

  "Get window label...
  READ TABLE lt_parameter ASSIGNING <ls_parameter>
    WITH KEY key = /plmu/if_frw_action_c=>gc_param_frw_window_label.
  IF sy-subrc = 0.
    "...from parameters.
    lv_header_text = <ls_parameter>-value.
    DELETE lt_parameter WHERE key = /plmu/if_frw_action_c=>gc_param_frw_window_label.
  ELSE.
    "...from ABBID description.
    TRY.
        /plmu/cl_frw_action_util=>get_header_data(
          IMPORTING
            ev_abbid = lv_abbid ).
        IF lv_abbid IS NOT INITIAL.
          /plmb/cl_spi_abb=>get_abb(
            EXPORTING
              iv_abbid      = lv_abbid
            IMPORTING
              ev_abbid_desc = lv_abb_desc ).
          lv_header_text = lv_abb_desc.
        ENDIF.
      CATCH /plmb/cx_frw ##no_handler.
        "No header available.
    ENDTRY.
  ENDIF.

  "Reset change log.
  mo_context_appl_model_pool->clear_change_log( ).

  "Restart.
  mo_fpm->get_navigate_to( )->restart(
      id_header_text = lv_header_text
      it_parameters  = lt_parameter ).

ENDMETHOD.


METHOD save.

  DATA:
    lv_message_dummy         TYPE           string ##needed,
    lv_reason                TYPE           /plmu/frw_after_save_reason,
    lv_new_mode              TYPE           /plmb/spi_mode,
    lv_cleanup_reason        TYPE           /plmb/spi_clean_up_reason,
    lo_event                 TYPE REF TO    cl_fpm_event,
    ls_error_message         TYPE           symsg.

  CLEAR ev_rejected.

  IF go_appl_model_pool->has_unsaved_data( ) = abap_true.
*-- SAVE --------------------------------------------------------------*
    go_appl_model_pool->save(
      EXPORTING iv_reason = lv_reason
      IMPORTING ev_failed = ev_rejected ).

    IF ev_rejected = abap_true.
      lv_new_mode = /plmu/if_frw_constants=>gc_mode-display.
    ELSE.
      "Determine new mode after successful search.
      IF mo_fpm->mv_edit_mode_supported = abap_true.
        lv_new_mode = /plmu/if_frw_constants=>gc_mode-display.
      ELSE.
        lv_new_mode = /plmu/if_frw_constants=>gc_mode-change.
      ENDIF.
      /plmu/cl_frw_appl_cntrl=>set_mode( lv_new_mode ).
      "Determine reason of save for AFTER_SAVE callback.
      CASE io_event->mv_event_id.
        WHEN cl_fpm_event=>gc_event_save.
          IF /plmu/cl_frw_appl_cntrl=>gv_mode = /plmu/if_frw_constants=>gc_mode-create.
            lv_reason = /plmu/if_frw_constants=>gc_after_save_reason-create.
          ELSE.
            lv_reason = /plmu/if_frw_constants=>gc_after_save_reason-change.
          ENDIF.
        WHEN cl_fpm_event=>gc_event_delete_current_object.
          lv_reason = /plmu/if_frw_constants=>gc_after_save_reason-delete.
      ENDCASE.
      "AFTER_SAVE callback is only processed if save was successful.
      "Success message must come from the application.
      go_callback_proxy_pool->after_save(
        EXPORTING iv_reason = lv_reason
        CHANGING  cv_mode   = lv_new_mode ).
      IF mo_fpm->mv_edit_mode_supported = abap_true
        AND lv_new_mode <> /plmu/if_frw_constants=>gc_mode-display.
        "Mode cannot be changed in AFTER_SAVE, since it is controlled by the FPM!
        RAISE EXCEPTION TYPE /plmu/cx_frw_error
          EXPORTING
            textid = /plmu/cx_frw_error=>no_mode_change_in_after_save.
      ENDIF.
    ENDIF.
    /plmu/cl_frw_appl_cntrl=>set_mode( lv_new_mode ).

*-- CLEAN_UP ----------------------------------------------------------*
    IF ev_rejected = abap_true.
      lv_cleanup_reason = /plmu/if_frw_constants=>gc_cleanup_reason-rollback.
    ELSE.
      lv_cleanup_reason = /plmu/if_frw_constants=>gc_cleanup_reason-commit.
    ENDIF.
    go_appl_model_pool->clean_up(
      EXPORTING iv_reason = lv_cleanup_reason ).

    IF ev_rejected = abap_true.
      CASE io_event->mv_event_id.
        WHEN cl_fpm_event=>gc_event_delete_current_object.
          RAISE EVENT root_about_to_be_deleted
            EXPORTING
              iv_root_delete = abap_true.
      ENDCASE.
      "Display error page.
      MESSAGE e100(/plmu/ui_frw) INTO lv_message_dummy.
      MOVE-CORRESPONDING sy TO ls_error_message.
      /plmu/cl_frw_appl_cntrl=>display_error_page(
        EXPORTING is_error_message = ls_error_message ).
      RETURN.
    ENDIF.
  ELSE.
    CASE io_event->mv_event_id.
      WHEN cl_fpm_event=>gc_event_save.
        "Data has not been changed since last saved
        MESSAGE i017(/plmu/ui_frw) INTO lv_message_dummy.
        go_message_manager->/plmu/if_frw_message_manager~publish_system_message( ).
*-- CLEAN_UP ----------------------------------------------------------*
        IF mo_fpm->mv_edit_mode_supported = abap_true.
          lv_cleanup_reason = /plmu/if_frw_constants=>gc_cleanup_reason-buffer_refresh.
          go_appl_model_pool->clean_up(
            EXPORTING iv_reason = lv_cleanup_reason ).
        ENDIF.
        RETURN.
    ENDCASE.
  ENDIF.

  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_delete_current_object.
      "Leave Transaction after successful delete of root object.
      CREATE OBJECT lo_event
        EXPORTING
          iv_event_id = /plmu/if_frw_constants=>gc_fpm_event_id-leave_transaction.
      mo_fpm->raise_event(
        EXPORTING io_event = lo_event ).
  ENDCASE.

ENDMETHOD.


METHOD switch_view.

  DATA:
    lv_mainview              TYPE           fpm_event_param,
    lv_subview               TYPE           fpm_event_param,
    lo_event                 TYPE REF TO    cl_fpm_event.

  "Get Main View ID
  lv_mainview = cl_wd_runtime_services=>get_url_parameter( /plmb/if_frw_action_c=>gc_param_oif_mainview ).
  IF lv_mainview IS NOT INITIAL.
    mo_fpm->mo_app_parameter->delete_value( /plmb/if_frw_action_c=>gc_param_oif_mainview ).
    lo_event = cl_fpm_event=>create_by_id( cl_fpm_event=>gc_event_view_switch ).
    "Set Main View ID
    lo_event->mo_event_data->set_value(
      EXPORTING
        iv_key   = cl_fpm_event=>gc_event_param_view_id
        iv_value = lv_mainview ).
    "Get Sub View ID
    lv_subview = cl_wd_runtime_services=>get_url_parameter( /plmb/if_frw_action_c=>gc_param_oif_subview ).
    IF lv_subview IS NOT INITIAL.
      mo_fpm->mo_app_parameter->delete_value( /plmb/if_frw_action_c=>gc_param_oif_subview ).
      "Set Sub View ID
      lo_event->mo_event_data->set_value(
        EXPORTING
          iv_key   = cl_fpm_event=>gc_event_param_subview_id
          iv_value = lv_subview ).
    ENDIF.
    "Raise 'View Switch' Event
    mo_fpm->raise_event( lo_event ).
  ENDIF.

ENDMETHOD.


METHOD wddoafteraction.

  DATA:
    lo_portal_manager TYPE REF TO if_wd_portal_integration.

"Note 2020417 set the work proection
     IF /plmu/cl_frw_appl_model=>gv_unsaved_data = abap_true.
      "Hand over dirty flag to Web Dynpro,
      "which will lead to a data-loss popup in NWBC and Portal.
      lo_portal_manager = mo_wd_component->get_portal_manager( ).
      lo_portal_manager->set_work_protect_mode(
        EXPORTING mode = if_wd_portal_integration=>co_wp_mode_both ).
      lo_portal_manager->set_application_dirty_flag(
        EXPORTING dirty_flag = abap_true ).
    ELSE. " note 3049172  . If no event was processed before raise a dummy event if we are in display mode to remove pessimistic FPM workprotection
      IF /PLMU/CL_FRW_APPL_CNTRL=>GV_MODE = /plmb/if_spi_c=>gs_c_mode-display and MV_NO_WD_ONLY_EVENT = abap_false.
      IF mo_fpm is BOUND.
       mo_fpm->raise_event_by_id(
         EXPORTING
           iv_event_id   =  'DUMMY'          " This defines the ID of the FPM Event
*           io_event_data =                  " Property Bag
       ).
       ENDIF.
      ENDIF.
    ENDIF.

  clear MV_NO_WD_ONLY_EVENT.

  RETURN.

ENDMETHOD.


METHOD WDDOBEFOREACTION.

  flush( ).

ENDMETHOD.


METHOD wddobeforenavigation.

    DATA:
    lo_portal_manager TYPE REF TO if_wd_portal_integration.


  "Flush in wddobeforenavigation is needed for F4 Roundtrip,
  "since there no Web Dynpro action is processed but
  "wddobeforenavigation and wddomodifyview are getting called.
  "(In some (old) applications the data is retrieved in wddomodifyview)
  flush( ).

  IF mv_fpm_event_triggered <> abap_true.
    "If an error occurred during the validation or the flush we cancel the navigation
    "in case no FPM event is used by the application (only relevant for freestyle UIBBs).
    "(Exception: closing the UI and confirmation popups shall not be cancelled)
    IF (   /plmu/cl_frw_appl_model=>gv_update_error = abap_true
        OR gv_validation_error                      = abap_true )
      AND gv_close_in_progress    <> abap_true
      AND gv_confirmation_running <> abap_true.
      mo_fuibb_appl_model_pool->cancel_navigation( ).
    ENDIF.

    IF /plmu/cl_frw_appl_model=>gv_unsaved_data = abap_true. ""Note 2020417 set the work proection
      "Hand over dirty flag to Web Dynpro,
      "which will lead to a data-loss popup in NWBC and Portal.
      lo_portal_manager = mo_wd_component->get_portal_manager( ).
      lo_portal_manager->set_work_protect_mode(
        EXPORTING mode = if_wd_portal_integration=>co_wp_mode_both ).
      lo_portal_manager->set_application_dirty_flag(
        EXPORTING dirty_flag = abap_true ).
    ENDIF.
  ENDIF.

*  CLEAR mv_fpm_event_triggered.  "note 2579051
* publish the messages (to FPM mess man )
  /PLMU/CL_FRW_APPL_CNTRL=>process_messages( ). "note 2214722

ENDMETHOD.


METHOD wddoexit.

  go_appl_model_pool->clean_up(
    EXPORTING iv_reason          = /plmu/if_frw_constants=>gc_cleanup_reason-rollback
              iv_bypass_callback = abap_true ).

ENDMETHOD.


METHOD wddoinit.

  IF iv_is_master = abap_true.
    gv_is_master = abap_true.
  ENDIF.

  super->wddoinit(
    EXPORTING io_wd_component    = io_wd_component
              io_wd_context_root = io_wd_context_root ).

  mo_wd_component = io_wd_component.

  IF iv_is_master <> abap_true.
    RETURN.
  ENDIF.

  "Initialize the sidepanel controller.
  mo_sidepanel_controller = /plmu/cl_frw_sidepanel_cntrl=>get_instance( ).
  mo_sidepanel_controller->init(
    EXPORTING io_wd_context_node = io_wd_context_root->get_child_node( gc_sidepanel_node_name )
              io_wd_component    = io_wd_component ).

  /plmu/cl_frw_action_util_int=>set_wd_component( io_wd_component ).

ENDMETHOD.


METHOD wddopostprocessing.

  DATA:
    lv_reset_change_log      TYPE           boole_d.

  IF gv_confirmation_running = abap_true.
    RETURN.
  ENDIF.

  "When the flush was delayed we do not reset the change log to be
  "able to flush next roundtip based on its entries.
  IF mv_flush_status <> gc_flush_status-deferred.
    lv_reset_change_log = abap_true.
  ENDIF.
  "Initialize flush status.
  mv_flush_status = gc_flush_status-pending.

  "Process field properties and messages.
  /plmu/cl_frw_appl_cntrl=>post_processing(
    EXPORTING iv_process_messages       = abap_true
              iv_reset_model_change_log = lv_reset_change_log ).

  "Clean up contexts which are not alive anymore.
  mo_context_pool->garbage_collector( ).

  "Synchronize the selection buffer of all administered contexts.
  mo_context_appl_model_pool->synchronize_selection_buffer( ).

  go_message_manager->set_end_of_roundtrip( ).

ENDMETHOD.
ENDCLASS.