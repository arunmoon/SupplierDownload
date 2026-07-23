class /PLMU/CL_EXP_FRW_EVENT_EXT definition
  public
  final
  create public .

public section.

  interfaces /PLMU/IF_EX_FRW_CONSUMER_APPCC .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.

  data MV_FPM_IDR_TICKET_GUID type I .
  data MR_ACTION_UTIL type ref to /PLMU/IF_FRW_ACTION_UTIL .
  data MR_APPL_MODEL type ref to /PLMU/IF_FRW_BASIC_APPL_MODEL .
  data MT_GOS_OBJECT type /PLMB/T_GOS_OTYPE_INTKEY .
  data MV_GOS_OBJECT_TYPE type /PLMB/GOS_OBJECT_TYPE .
  data MR_FPM type ref to IF_FPM .
  data MR_FPM_IDR type ref to IF_FPM_IDR .

  methods CHECK_NAVIGATION_PARAM_EXIST
    returning
      value(RV_RESULT) type FPM_EVENT_RESULT .
  methods CHECK_SEL_LAYOUT_EXIST
    returning
      value(RV_RESULT) type FPM_EVENT_RESULT .
  methods SET_IDR_REGION .
  methods CONVERT_HEADER_DATA
    importing
      !IT_HEADER_DATA_XS type /PLMB/T_EXP_HEADER_INFO_XS
    exporting
      !ET_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO .
  methods OPEN_SEL_LAYOUT_MANAGER_POPUP
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
    exporting
      !EV_RESULT type FPM_EVENT_RESULT .
  methods SELECTION_LAYOUT_DEL
    importing
      !IO_FPM_EVENT type ref to CL_FPM_EVENT
    returning
      value(RV_FPM_RESULT) type FPM_EVENT_RESULT .
  methods SELECTION_LAYOUT_LOAD
    importing
      !IO_FPM_EVENT type ref to CL_FPM_EVENT
    returning
      value(RV_FPM_RESULT) type FPM_EVENT_RESULT .
  methods SELECTION_LAYOUT_SAVE
    returning
      value(RV_FPM_RESULT) type FPM_EVENT_RESULT .
  methods EXPORT_DATA
    exporting
      !EV_FAILED type FLAG .
  methods GET_NAVIGATION_PARAMETERS
    exporting
      !EV_GOS_OBJECT_TYPE type /PLMB/GOS_OBJECT_TYPE
      !ET_GOS_OBJECT type /PLMB/T_GOS_OTYPE_INTKEY .
  methods GET_OUT_TABLES
    returning
      value(RT_OUT_TABLES) type /PLMB/T_EXP_TABLES .
  methods CONVERT_TABLE_DATA
    exporting
      !ET_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !ET_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION
    changing
      !CS_NODE_DATA type /PLMB/S_EXPORTING_SP .
ENDCLASS.



CLASS /PLMU/CL_EXP_FRW_EVENT_EXT IMPLEMENTATION.


METHOD /plmu/if_ex_frw_consumer_appcc~after_after_failed_event. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_cleanup. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_failed_event. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_flush.  "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_needs_confirmation. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_process_before_output.  "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_process_event.

  DATA:
        ls_node_id                  TYPE          /plmb/s_exp_downld_param_sp_id,
        lt_node_id                  TYPE TABLE OF /plmb/s_exp_downld_param_sp_id,
        ls_node_data                TYPE          /plmb/s_exp_downld_param_sp,
        ls_node_in                  TYPE          /plmb/s_gos_otype_intkey,
        lt_node_in                  TYPE          /plmb/t_gos_otype_intkey,
        lv_current_dialog_box_id    TYPE          string,
        lv_add_object_dialog_box_id TYPE          string,
        lv_dialog_box_button        TYPE          string
        .

  CASE io_event->mv_event_id.

*--------------------------------------------------------------------*
* Download Data button is pressed
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-download_data.

      " Quick access requires some prefill methods
      " 1) In case of quick download a selection layout should be selected
      " 2) If selection layout was loaded, a retreive has to be called on the
      "    selection tree -> model BADI is called here in the SP
      " Check it before call export data.
      " It should be displyed only in "quick" mode
      IF /plmu/cl_frw_appl_cntrl=>gv_wdy_appl_name EQ '/PLMU/WDA_EXP_QUICK_OIF'.
        cv_result = me->check_sel_layout_exist( ).
        IF cv_result EQ if_fpm_constants=>gc_event_result-failed.
          RETURN.
        ENDIF.

        me->mr_appl_model->action(
          EXPORTING
            iv_node_name   = /plmb/cl_exp_mp=>gc_node_download_parameters
            iv_action_name = /plmb/cl_exp_mp=>gc_action_download_parameters-get_param_value
          IMPORTING
            eg_param       = ls_node_data
            ).
        MOVE-CORRESPONDING ls_node_data TO ls_node_id.
        APPEND ls_node_id TO lt_node_id.

        me->mr_appl_model->retrieve(
          EXPORTING
            iv_node_name        =  /plmb/cl_exp_mp=>gc_node_download_parameters
            iv_target_node_name = /plmb/cl_exp_mp=>gc_node_selection_tree
            it_node_id          = lt_node_id
        ).

      ENDIF.

      " Call data export
      me->export_data( ).

*--------------------------------------------------------------------*
* Selection clear
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-clear_selection.

      me->mr_appl_model->action(
        EXPORTING
          iv_node_name    = /plmb/cl_exp_mp=>gc_node_download_data
          iv_action_name  = /plmb/cl_exp_mp=>gc_action_data_download-clear_dirty_flag
      ).

*--------------------------------------------------------------------*
* Dialog box is closed
*--------------------------------------------------------------------*
    WHEN cl_fpm_event=>gc_event_close_dialog_box.

      " Get current dialog box ID
      io_event->mo_event_data->get_value(
        EXPORTING
          iv_key   = if_fpm_constants=>gc_dialog_box-id
        IMPORTING
          ev_value = lv_current_dialog_box_id
        ).

      " Generate ID of add object dialog box
      CONCATENATE /plmu/if_exp_c=>gc_fpm_dialog_box_id-add_object mv_gos_object_type INTO lv_add_object_dialog_box_id SEPARATED BY '_'.

      CASE lv_current_dialog_box_id.

        WHEN lv_add_object_dialog_box_id.

          io_event->mo_event_data->get_value(
            EXPORTING
              iv_key   = if_fpm_constants=>gc_dialog_box-dialog_buton_key
            IMPORTING
              ev_value = lv_dialog_box_button
            ).

          " OK button is pressed
          IF lv_dialog_box_button EQ if_fpm_constants=>gc_dialog_action_id-ok.

            io_event->mo_event_data->get_value(
              EXPORTING
                iv_key   = /plmu/if_exp_c=>gc_event_param_id-internal_key
              IMPORTING
                ev_value = ls_node_in
              ).

            IF ls_node_in IS NOT INITIAL.

              APPEND ls_node_in TO lt_node_in.

              me->mr_appl_model->insert(
                EXPORTING
                  iv_node_name        = /plmb/cl_exp_mp=>gc_node_objects
                  it_node_data        = lt_node_in
              ).

            ENDIF.

          ENDIF.

        WHEN OTHERS.
          " there are no more dialog boxes to be handled here

      ENDCASE.

  ENDCASE.

ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~after_save. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~flush.  "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~initialization.

* Get application model
  me->mr_appl_model = /plmu/cl_frw_factory=>get_basic_application_model(
      iv_abbid            = /plmb/if_exp_c=>gc_abbid ).

* Get action utility
  me->mr_action_util = /plmu/cl_frw_factory=>get_action_utilities(
      io_callback         = me
      iv_abbid            = /plmb/if_exp_c=>gc_abbid
      iv_mapping_mode     = /plmb/if_frw_map=>gc_s_mapping_mode-map_all
  ).

* Get FPM instance
  me->mr_fpm = cl_fpm_factory=>get_instance( ).
  me->mr_fpm_idr ?= me->mr_fpm->get_service( cl_fpm_service_manager=>gc_key_idr ).

* Get navigation parameters
  me->get_navigation_parameters(
    IMPORTING
      ev_gos_object_type = me->mv_gos_object_type
      et_gos_object      = me->mt_gos_object
  ).

ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~needs_confirmation.

  DATA:
        lt_conf_popup_text  TYPE TABLE OF string,
        lv_conf_popup_text  TYPE string,
        ls_boolean          TYPE /plmb/s_exp_boolean_sp.

  " Quick access doesn't need confirmation popup
  IF /plmu/cl_frw_appl_cntrl=>gv_wdy_appl_name EQ '/PLMU/WDA_EXP_QUICK_OIF'.
    RETURN.
  ENDIF.

  " For specified events dirty flag should be checked and
  " confirmation popup should be raised
  CASE io_event->mv_event_id.
    WHEN /plmu/if_exp_c=>gc_events-clear_selection
      OR /plmu/if_exp_c=>gc_events-load_sel_layout
      OR cl_fpm_event=>gc_event_close.

      me->mr_appl_model->action(
        EXPORTING
          iv_node_name    = /plmb/cl_exp_mp=>gc_node_download_data
          iv_action_name  = /plmb/cl_exp_mp=>gc_action_data_download-get_dirty_flag
        IMPORTING
          eg_param        = ls_boolean
      ).

      IF ls_boolean-boolean EQ abap_true.
        " Confirmation popup should be created
        lv_conf_popup_text = cl_wd_utilities=>get_otr_text_by_alias( alias = '/PLMU/UI_EXP/CONFIRM_DIRTY_TEXT' ).
        APPEND lv_conf_popup_text TO lt_conf_popup_text.

        lv_conf_popup_text = cl_wd_utilities=>get_otr_text_by_alias( alias = '/PLMU/UI_EXP/CONFIRM_DIRTY_WINDOW_TITLE' ).
        CREATE OBJECT co_confirmation_request
          EXPORTING
            it_confirmation_text = lt_conf_popup_text
            iv_window_title	     = lv_conf_popup_text.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~override_config_tabbed. "#EC NEEDED
ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~override_event_oif.

  DATA:
        lt_variant    TYPE if_fpm_oif=>ty_t_variant,
        lv_variant_id TYPE if_fpm_oif=>ty_s_variant-id
        .
  FIELD-SYMBOLS:
        <fs_variant>  TYPE if_fpm_oif=>ty_s_variant.

  CASE io_oif->mo_event->mv_event_id.

    WHEN cl_fpm_event=>gc_event_start.

      " Get OIF configuration variants
      io_oif->get_variants( IMPORTING et_variant = lt_variant ).

      " Search for object specific variant
      READ TABLE lt_variant ASSIGNING <fs_variant>
        WITH KEY id = me->mv_gos_object_type.
      IF sy-subrc NE 0.
        " No object specific variant is defined -> select default variant
        lv_variant_id = /plmu/if_exp_c=>gc_default_variant_id.
      ELSE.
        lv_variant_id = <fs_variant>-id.
      ENDIF.

      " Try to load this variant
      TRY .
          io_oif->set_variant( lv_variant_id ).
        CATCH cx_fpm_floorplan.
          " Technical error -> Report
          RETURN.
      ENDTRY.

  ENDCASE.

ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~process_before_output.

  CASE io_event->mv_event_id.
    WHEN cl_fpm_event=>gc_event_start
      OR /plmu/if_exp_c=>gc_events-load_sel_layout
      OR /plmu/if_exp_c=>gc_events-save_sel_layout
      OR /plmu/if_exp_c=>gc_events-del_sel_layout
      OR /plmu/if_exp_c=>gc_events-clear_selection            "2145634
      OR cl_fpm_event=>gc_event_close_dialog_box.
        me->set_idr_region( ).
    WHEN OTHERS.
  ENDCASE.


ENDMETHOD.


METHOD /plmu/if_ex_frw_consumer_appcc~process_event.

  DATA:
        ls_node_id        TYPE          /plmb/s_exp_downld_param_sp_id,
        lt_node_id        TYPE TABLE OF /plmb/s_exp_downld_param_sp_id,
        ls_node_data      TYPE          /plmb/s_exp_downld_param_sp,
        lv_failed         TYPE          /plmb/spi_failed_ind,
        lv_dialog_box_id  TYPE          string
        .

*--------------------------------------------------------------------*
* Handle FPM event
*--------------------------------------------------------------------*
  CASE io_event->mv_event_id.

*--------------------------------------------------------------------*
* Start application
*--------------------------------------------------------------------*
    WHEN cl_fpm_event=>gc_event_start.

      cv_result = me->check_navigation_param_exist( ).
      IF cv_result = if_fpm_constants=>gc_event_result-failed.
        RETURN.
      ENDIF.

      " Store objects in SPI
      me->mr_appl_model->insert(
        EXPORTING
          iv_node_name        = /plmb/cl_exp_mp=>gc_node_objects
          it_node_data        = me->mt_gos_object
        IMPORTING
          ev_failed           = lv_failed
        ).
      IF lv_failed EQ abap_true.
        cv_result = if_fpm_constants=>gc_event_result-failed.
      ENDIF.

      ASSERT me->mt_gos_object IS NOT INITIAL.

*--------------------------------------------------------------------*
* Open list of objects dialog box
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-open_object_list_popup.
*     Begin IF note 2650799
      IF /plmb/cl_plmwui_parameter=>get_parameter_value( /plmb/if_exp_c=>gc_param_name-add_multi_objects ) = abap_true.
        me->mr_fpm->open_dialog_box(
          EXPORTING
            iv_dialog_box_id         = /plmu/if_exp_c=>gc_fpm_dialog_box_id-object_list2
            ).
*     End IF note 2650799
      ELSE.
        me->mr_fpm->open_dialog_box(
          EXPORTING
            iv_dialog_box_id         = /plmu/if_exp_c=>gc_fpm_dialog_box_id-object_list
          ).
      ENDIF.

*--------------------------------------------------------------------*
* Open add object dialog box
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-open_add_object_popup.

      CONCATENATE /plmu/if_exp_c=>gc_fpm_dialog_box_id-add_object mv_gos_object_type INTO lv_dialog_box_id SEPARATED BY '_'.

      me->mr_fpm->open_dialog_box(
        EXPORTING
          iv_dialog_box_id = lv_dialog_box_id
        ).

*--------------------------------------------------------------------*
* Open selection variant management dialog box
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-open_load_sel_layout_popup
      OR /plmu/if_exp_c=>gc_events-open_save_sel_layout_popup
      OR /plmu/if_exp_c=>gc_events-open_del_sel_layout_popup.

      me->open_sel_layout_manager_popup(
        EXPORTING
          io_event  = io_event
        IMPORTING
          ev_result = cv_result
      ).

*--------------------------------------------------------------------*
* Selection Layout
*--------------------------------------------------------------------*
    WHEN /plmu/if_exp_c=>gc_events-load_sel_layout.
      " Call load selection layout action
      cv_result = me->selection_layout_load( io_event ).

    WHEN /plmu/if_exp_c=>gc_events-save_sel_layout.
      " Call save selection layout action
      cv_result = me->selection_layout_save( ).

      IF cv_result NE if_fpm_constants=>gc_event_result-failed.
        me->mr_fpm->raise_event_by_id(
          EXPORTING
            iv_event_id = cl_fpm_event=>gc_event_save
        ).
      ENDIF.

    WHEN /plmu/if_exp_c=>gc_events-del_sel_layout.
      " Call delete selection layout action
      cv_result = me->selection_layout_del( io_event ).

      IF cv_result NE if_fpm_constants=>gc_event_result-failed.
        me->mr_fpm->raise_event_by_id(
          EXPORTING
            iv_event_id = cl_fpm_event=>gc_event_save
        ).
      ENDIF.

  ENDCASE.

ENDMETHOD.


METHOD CHECK_NAVIGATION_PARAM_EXIST.

  DATA:
        lv_msg_text         TYPE string.


  IF me->mt_gos_object IS INITIAL.

    lv_msg_text = cl_wd_utilities=>get_otr_text_by_alias( '/PLMU/UI_EXP/NAVIGATION_DATA_MISSING' ).

    me->mr_fpm->mo_message_manager->report_message(
      EXPORTING
        iv_message_text              = lv_msg_text
        io_component                 = me
    ).

    rv_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

ENDMETHOD.


METHOD check_sel_layout_exist.

  DATA:
        ls_sel_layout_sp_id TYPE /plmb/s_exp_sel_layout_sp_id,
        lv_msg_text         TYPE string.

  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_selection_layout-get_loaded_sel_layout_id
    IMPORTING
      eg_param        = ls_sel_layout_sp_id
  ).

  IF ls_sel_layout_sp_id-sel_layout_id IS INITIAL.

    lv_msg_text = cl_wd_utilities=>get_otr_text_by_alias( '/PLMU/UI_EXP/SELECTION_LAYOUT_NO_SELECTION' ).

    me->mr_fpm->mo_message_manager->report_message(
      EXPORTING
        iv_message_text              = lv_msg_text
        io_component                 = me
    ).

    rv_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

ENDMETHOD.


method CONVERT_HEADER_DATA.

  DATA: ls_header_data_xs TYPE /plmb/s_exp_header_info_xs,
        ls_header_data    TYPE /plmb/s_exp_header_info.

  FIELD-SYMBOLS:
        <lv_data>         TYPE any.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR et_header_data.

*--------------------------------------------------------------------*
* Convert Data
*--------------------------------------------------------------------*
  LOOP AT it_header_data_xs INTO ls_header_data_xs.
    ls_header_data-fname_descr = ls_header_data_xs-fname_descr.
    ls_header_data-fname_type  = ls_header_data_xs-fname_type.
    ls_header_data-content_descr = ls_header_data_xs-content_descr.
    CREATE DATA ls_header_data-content TYPE (ls_header_data-fname_type).
    ASSIGN ls_header_data-content->* TO <lv_data>.
    IMPORT content = <lv_data>
      FROM DATA BUFFER ls_header_data_xs-content.
    APPEND ls_header_data TO et_header_data.
  ENDLOOP.

endmethod.


METHOD CONVERT_TABLE_DATA.


  DATA: ls_data       TYPE /plmb/s_exp_table_data_xstring,
        ls_table_data TYPE /plmb/s_exp_table_data_export,

        lt_definition TYPE /plmb/t_exp_table_definition,
        ls_definition TYPE /plmb/s_exp_table_definition,
        lo_table_type TYPE REF TO cl_abap_tabledescr,

        lo_data       TYPE REF TO data,
        ls_data_ref   TYPE /plmb/s_exp_ref_to_data.

  FIELD-SYMBOLS:
        <lt_data>     TYPE ANY TABLE,
        <lt_data2>    TYPE ANY TABLE,
        <lt_data_ref> TYPE /plmb/t_exp_ref_to_data,
        <ls_data>     TYPE /plmb/s_exp_xstring,
        <ls_definition> TYPE /plmb/s_exp_table_definition,
        <ls_definition_local> TYPE /plmb/s_exp_table_definition.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_table_data,
         et_definition.

*--------------------------------------------------------------------*
* Set Definition
*--------------------------------------------------------------------*
  et_definition = cs_node_data-table_definition.

  DELETE cs_node_data-table_definition
    WHERE new_page = abap_true OR
          table_text IS NOT INITIAL.
  SORT cs_node_data-table_definition STABLE BY table_no ASCENDING.

*--------------------------------------------------------------------*
* Convert XSTRING to DATA
*--------------------------------------------------------------------*
  LOOP AT cs_node_data-table_data INTO ls_data.

    CLEAR lt_definition.
    READ TABLE cs_node_data-table_definition INDEX 1 INTO ls_definition.
    LOOP AT cs_node_data-table_definition ASSIGNING <ls_definition> WHERE table_no = ls_definition-table_no.
      APPEND INITIAL LINE TO lt_definition ASSIGNING <ls_definition_local>.
      <ls_definition_local> = <ls_definition>.
      DELETE cs_node_data-table_definition.
    ENDLOOP.

    CALL METHOD /plmb/cl_exp_tools=>create_struct_and_table_type
      EXPORTING
        it_definition = lt_definition
      IMPORTING
        eo_table_type = lo_table_type.

    TRY .
        CREATE DATA lo_data TYPE /plmb/t_exp_xstring.
        ASSIGN lo_data->* TO <lt_data>.
        IMPORT table_data = <lt_data>
          FROM DATA BUFFER ls_data-table_data.

        ls_table_data-table_no = ls_data-table_no.
        CREATE DATA ls_table_data-table_data TYPE /plmb/t_exp_ref_to_data.
        ASSIGN ls_table_data-table_data->* TO <lt_data_ref>.

        LOOP AT <lt_data> ASSIGNING <ls_data>.
          CLEAR ls_data_ref.
          CREATE DATA ls_data_ref-data TYPE HANDLE lo_table_type.
          ASSIGN ls_data_ref-data->* TO <lt_data2>.
          IMPORT xstring = <lt_data2>
          FROM DATA BUFFER <ls_data>-xstring.
          INSERT ls_data_ref INTO TABLE <lt_data_ref>.
        ENDLOOP.

        APPEND ls_table_data TO et_table_data.
        CONTINUE.

      CATCH cx_root.

    ENDTRY.

    CREATE DATA lo_data TYPE HANDLE lo_table_type.
    ASSIGN lo_data->* TO <lt_data>.

    IMPORT table_data = <lt_data>
      FROM DATA BUFFER ls_data-table_data.

    ls_table_data-table_no = ls_data-table_no.
    ls_table_data-table_data = lo_data.
    APPEND ls_table_data TO et_table_data.


  ENDLOOP.

ENDMETHOD.


METHOD export_data.


  DATA:
        lt_exporting_data TYPE STANDARD TABLE OF /plmb/s_exporting_sp,
        ls_exporting_data TYPE /plmb/s_exporting_sp,
        ls_param_data     TYPE /plmb/s_exp_downld_param_sp,

        lt_table_data     TYPE /plmb/t_exp_table_data_export,
        lt_definition     TYPE /plmb/t_exp_table_definition,
        lt_header_info    TYPE /plmb/t_exp_header_info,
        lv_filename       TYPE string.

*--------------------------------------------------------------------*
* Clear Exporting parameters
*--------------------------------------------------------------------*
  CLEAR ev_failed.

*--------------------------------------------------------------------*
* Get view type from SP
*--------------------------------------------------------------------*
  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_download_parameters
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_download_parameters-get_param_value
    IMPORTING
      eg_param        = ls_param_data
  ).
  ASSERT ls_param_data-file_type IS NOT INITIAL.

*--------------------------------------------------------------------*
* Get data from application model
*--------------------------------------------------------------------*
  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_exporting
      iv_action_name  = /plmb/cl_exp_mp=>gc_act_get_download_data
    IMPORTING
      ev_failed       = ev_failed
      et_node_data    = lt_exporting_data
  ).

  IF ev_failed EQ abap_true AND lt_exporting_data IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Convert formats
*--------------------------------------------------------------------*
  READ TABLE lt_exporting_data INTO ls_exporting_data
    WITH KEY gos_type = ls_param_data-object_type.

  me->convert_table_data(
    IMPORTING
      et_table_data = lt_table_data
      et_definition = lt_definition
    CHANGING
      cs_node_data  = ls_exporting_data
  ).

  me->convert_header_data(
    EXPORTING
      it_header_data_xs = ls_exporting_data-header_info
    IMPORTING
      et_header_data    = lt_header_info ).

  CONCATENATE sy-datum sy-uzeit INTO lv_filename SEPARATED BY '_'.
  lv_filename = /plmu/cl_frw_services=>to_string( lv_filename ).

*--------------------------------------------------------------------*
* Get exporting class based on view type
*--------------------------------------------------------------------*

  /plmu/cl_exp_export_factory=>get_export_class(
    iv_export_type = ls_param_data-file_type )->export_data(
      iv_gos_type           = ls_param_data-object_type
      iv_variant_id         = ls_param_data-view_type
      iv_export_object_type = ls_exporting_data-export_type
      it_data               = lt_table_data
      it_def                = lt_definition
      it_export_header_data = lt_header_info
      iv_filename           = lv_filename
      it_out_tables         = me->get_out_tables( )
  ).

ENDMETHOD.


METHOD get_navigation_parameters.

  DATA:
        lt_parameter_set  TYPE /plmb/t_frw_parameter_set,
        ls_gos_object     TYPE /plmb/s_gos_otype_intkey,
        lt_gos_object     TYPE /plmb/t_gos_otype_intkey
        .

  FIELD-SYMBOLS:
         <lt_parameters>  TYPE /plmb/t_frw_parameters,
         <ls_parameters>  TYPE /plmb/s_frw_parameters.

*--------------------------------------------------------------------*
* Clear exporting parameters
*--------------------------------------------------------------------*
  CLEAR: ev_gos_object_type, et_gos_object.

*--------------------------------------------------------------------*
* Get external parameters from action util class
*--------------------------------------------------------------------*
  TRY.
      me->mr_action_util->get_external_params_mass_data(
      IMPORTING
        et_object_data        = lt_parameter_set
        ).
    CATCH /plmb/cx_frw_no_data .
      RETURN.
  ENDTRY.

  READ TABLE lt_parameter_set INDEX 1 ASSIGNING <lt_parameters>.
  READ TABLE <lt_parameters> WITH KEY name = 'FRW_OTYPE' ASSIGNING <ls_parameters>.
  ls_gos_object-otype_name = <ls_parameters>-value.

  LOOP AT lt_parameter_set ASSIGNING <lt_parameters>.
    LOOP AT <lt_parameters> ASSIGNING <ls_parameters>.

      CASE <ls_parameters>-name.
        WHEN 'FRW_OTYPE'.
          IF <ls_parameters>-value NE ls_gos_object-otype_name.
            " Technical error: Only one object type is supported
            ASSERT 1 = 0.
          ENDIF.

        WHEN 'FRW_OBJECT_ID'.
          ls_gos_object-internal_key = <ls_parameters>-value.
          INSERT ls_gos_object INTO TABLE lt_gos_object.

        WHEN OTHERS.
          " Not supported
          CONTINUE.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

  ev_gos_object_type  = ls_gos_object-otype_name.
  et_gos_object       = lt_gos_object.

ENDMETHOD.


METHOD get_out_tables.

  CONSTANTS:
        lc_dummy      TYPE int4 value 9999.

  DATA:
        ls_out_tables TYPE /plmb/s_exp_table
        .
*--------------------------------------------------------------------*
* Get all avaiable out table
*--------------------------------------------------------------------*
  DO lc_dummy TIMES.

    ls_out_tables-table_no = sy-tabix.
    APPEND ls_out_tables TO rt_out_tables.

  ENDDO.

ENDMETHOD.


METHOD open_sel_layout_manager_popup.

  DATA:
        lv_fpm_dialog_window_id     TYPE fpm_dialog_window_id  .

*--------------------------------------------------------------------*
* Clear exporting parameters
*--------------------------------------------------------------------*
  CLEAR ev_result.

*--------------------------------------------------------------------*
* Open FPM dialog box based on FPM event ID
*--------------------------------------------------------------------*
  CASE io_event->mv_event_id.
      " Open load selection layout popup
    WHEN /plmu/if_exp_c=>gc_events-open_load_sel_layout_popup.
      lv_fpm_dialog_window_id = /plmu/if_exp_c=>gc_fpm_dialog_box_id-selection_layout_load.

      " Open save selection layout popup
    WHEN /plmu/if_exp_c=>gc_events-open_save_sel_layout_popup.
      lv_fpm_dialog_window_id = /plmu/if_exp_c=>gc_fpm_dialog_box_id-selection_layout_save.

    WHEN /plmu/if_exp_c=>gc_events-open_del_sel_layout_popup.
      lv_fpm_dialog_window_id = /plmu/if_exp_c=>gc_fpm_dialog_box_id-selection_layout_del.

    WHEN OTHERS.
      ev_result = if_fpm_constants=>gc_event_result-failed.
      RETURN.
  ENDCASE.

  " Open FPM dialog box
  me->mr_fpm->open_dialog_box(
    EXPORTING
      iv_dialog_box_id         = lv_fpm_dialog_window_id
    ).

ENDMETHOD.


METHOD SELECTION_LAYOUT_DEL.

  DATA:
        lo_fpm_parameter  TYPE REF TO data,
        lv_failed         TYPE /plmb/spi_failed_ind.

  FIELD-SYMBOLS:
        <ft_node_data_id> TYPE /plmb/t_exp_sel_layout_sp_id.

  " Get FPM parameters
  io_fpm_event->mo_event_data->get_value(
    EXPORTING
      iv_key   = /plmu/if_exp_c=>gc_event_param_id-sel_layout_selection
    IMPORTING
      er_value = lo_fpm_parameter
  ).
  ASSIGN lo_fpm_parameter->* TO <ft_node_data_id>.
  ASSERT <ft_node_data_id> IS ASSIGNED.

  me->mr_appl_model->delete(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
      it_node_id      = <ft_node_data_id>
    IMPORTING
      ev_failed       = lv_failed
  ).
  IF lv_failed EQ abap_true.
    rv_fpm_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

ENDMETHOD.


METHOD selection_layout_load.

  DATA:
        lo_fpm_parameter TYPE REF TO data,
        lv_failed TYPE /plmb/spi_failed_ind.

  FIELD-SYMBOLS:
        <ft_node_data_id> TYPE /plmb/t_exp_sel_layout_sp_id,
        <fs_node_data_id> TYPE /plmb/s_exp_sel_layout_sp_id.

  " Create local container
  io_fpm_event->mo_event_data->get_value(
    EXPORTING
      iv_key   = /plmu/if_exp_c=>gc_event_param_id-sel_layout_selection
    IMPORTING
      er_value = lo_fpm_parameter
  ).
  ASSIGN lo_fpm_parameter->* TO <ft_node_data_id>.
  ASSERT <ft_node_data_id> IS ASSIGNED AND lines( <ft_node_data_id> ) EQ 1.

  READ TABLE <ft_node_data_id> ASSIGNING <fs_node_data_id> INDEX 1.

  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_selection_layout-load_selection_layout
      is_param        = <fs_node_data_id>
    IMPORTING
      ev_failed       = lv_failed
  ).
  IF lv_failed EQ abap_true.
    rv_fpm_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

ENDMETHOD.


METHOD selection_layout_save.

  DATA:
        lv_failed TYPE /plmb/spi_failed_ind.

  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_selection_layout-save_selection_layout    " Action Name
    IMPORTING
      ev_failed       = lv_failed
  ).
  IF lv_failed EQ abap_true.
    rv_fpm_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

ENDMETHOD.


METHOD set_idr_region.

  DATA:
        ls_sel_layout_sp_id TYPE /plmb/s_exp_sel_layout_sp_id,
        lt_gos_otype_key    TYPE /plmb/t_gos_otype_intkey,
        lv_no_of_objects    TYPE int4,
        lt_idr_items        TYPE if_fpm_idr=>t_items_val,
        ls_idr_items        TYPE if_fpm_idr=>s_items_val.

*--------------------------------------------------------------------*
* Get loaded selection layout
*--------------------------------------------------------------------*
  " It should be displyed only in "normal" mode
  IF /plmu/cl_frw_appl_cntrl=>gv_wdy_appl_name EQ '/PLMU/WDA_EXP_OIF'.

* note 2291285
    IF /plmu/cl_frw_appl_cntrl=>/plmu/if_frw_appl_cntrl~gv_fpm_eventid
       EQ /plmu/if_exp_c=>gc_events-clear_selection.
      me->mr_appl_model->action(
        EXPORTING
          iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
          iv_action_name  = /plmb/cl_exp_mp=>gc_action_selection_layout-clear_loaded_sel_layout_id
      ).
    ENDIF.
* note 2291285
* note 2145634
    IF /plmu/cl_frw_appl_cntrl=>/plmu/if_frw_appl_cntrl~gv_fpm_eventid
       NE /plmu/if_exp_c=>gc_events-clear_selection.
* note 2145634
    me->mr_appl_model->action(
      EXPORTING
        iv_node_name    = /plmb/cl_exp_mp=>gc_node_selection_layout
        iv_action_name  = /plmb/cl_exp_mp=>gc_action_selection_layout-get_loaded_sel_layout_id
      IMPORTING
        eg_param        = ls_sel_layout_sp_id
    ).
    ENDIF.                                                     "2145634
    ls_idr_items-label_name = cl_wd_utilities=>get_otr_text_by_alias( alias = '/PLMU/UI_EXP/SELECTION_LAYOUT_TBL_HEADER' ).
    ls_idr_items-value      = ls_sel_layout_sp_id-sel_layout_id.
    APPEND ls_idr_items TO lt_idr_items.
  ENDIF.

*--------------------------------------------------------------------*
* Get number of objects
*--------------------------------------------------------------------*
  me->mr_appl_model->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_objects
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_objects-get_current_keys
    IMPORTING
      et_node_data    = lt_gos_otype_key
  ).
  lv_no_of_objects = lines( lt_gos_otype_key ).

  ls_idr_items-label_name = cl_wd_utilities=>get_otr_text_by_alias( alias = '/PLMU/UI_EXP/OBJECTS_FOR_DOWNLOAD_IDR' ).
  ls_idr_items-value      = lv_no_of_objects.
  APPEND ls_idr_items TO lt_idr_items.

  IF me->mv_fpm_idr_ticket_guid IS INITIAL.
    me->mr_fpm_idr->add_item_group_by_val(
      EXPORTING
        it_items = lt_idr_items
      IMPORTING
        ev_key   = me->mv_fpm_idr_ticket_guid
    ).
  ELSE.
    TRY.
        me->mr_fpm_idr->change_item_group_by_val(
          EXPORTING
            iv_key   = me->mv_fpm_idr_ticket_guid
            it_items = lt_idr_items
        ).
      CATCH cx_fpm_idr.
        ASSERT 0 = 1. " Technical error
    ENDTRY.
  ENDIF.

ENDMETHOD.
ENDCLASS.