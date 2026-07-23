class /PLMB/CL_EXP_SP definition
  public
  final
  create private

  global friends /PLMB/CL_SPI_FACTORY .

public section.

  interfaces /PLMB/IF_SPI_APPL_ACCESS .
  interfaces /PLMB/IF_SPI_APPL_ACCESS_INIT .
protected section.
*"* protected components of class /PLMB/CL_EXP_SP
*"* do not include other source files here!!!
private section.

  data MO_COLLECTOR type ref to /PLMB/IF_SPI_COLLECTOR .

  methods SET_DIRTY_FLAG
    importing
      !IV_NEW_STATE type BOOLE_D .
  methods SET_FIELD_PROPERTIES
    importing
      !IT_NODE_DATA type INDEX TABLE
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_ACTION_NAME type /PLMB/SPI_ACTION_NAME optional
      !IO_NODE type ref to /PLMB/IF_EXP_NODE_ACCESS .
ENDCLASS.



CLASS /PLMB/CL_EXP_SP IMPLEMENTATION.


METHOD /plmb/if_spi_appl_access_init~initialize.

  mo_collector = is_options-collector.

ENDMETHOD.


METHOD /plmb/if_spi_appl_access~action.

  DATA: lo_node    TYPE REF TO /plmb/if_exp_node_access,
        lt_message TYPE        /plmb/t_spi_msg.

*--------------------------------------------------------------------*
* Clear Export parameter
*--------------------------------------------------------------------*
  CLEAR: ev_failed,
         et_index_failed,
         et_node_data.

*--------------------------------------------------------------------*
* Get Node
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_exp_node_factory=>get_node
    EXPORTING
      iv_node_name = iv_node_name
    IMPORTING
      eo_node      = lo_node.

*--------------------------------------------------------------------*
* Call Action
*--------------------------------------------------------------------*
  CALL METHOD lo_node->action
    EXPORTING
      iv_action_name = iv_action_name
      is_param       = is_param
      it_node_id     = it_node_id
    IMPORTING
      et_data        = et_node_data
      eg_param       = eg_param
      et_message     = lt_message.

*--------------------------------------------------------------------*
* Set Messages
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>evaluate_messages
    EXPORTING
      it_message      = lt_message
    IMPORTING
      ev_failed       = ev_failed
      et_index_failed = et_index_failed.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_message
      iv_node_name = iv_node_name
      it_node_ref  = it_node_id.

*--------------------------------------------------------------------*
* Set Field Properties
*--------------------------------------------------------------------*
  CALL METHOD set_field_properties
    EXPORTING
      it_node_data   = et_node_data
      iv_node_name   = iv_node_name
      iv_action_name = iv_action_name
      io_node        = lo_node.

*--------------------------------------------------------------------*
* Set dirty flag after special actions
*--------------------------------------------------------------------*
  IF ev_failed EQ abap_false
   AND ( ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_additional_info   AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_add_info-set_selected_data )
    OR   ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_app_specific_data AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_app_specific_data-set_selection )
    OR   ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_selection_tree    AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_selection_tree-select_all )
    OR   ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_selection_tree    AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_selection_tree-deselect_all )
    ).

    me->set_dirty_flag( iv_new_state = abap_true ).

  ELSEIF ev_failed EQ abap_false
     AND ( ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_selection_layout  AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_selection_layout-load_selection_layout )
      OR   ( iv_node_name EQ /plmb/cl_exp_mp=>gc_node_selection_layout  AND iv_action_name EQ /plmb/cl_exp_mp=>gc_action_selection_layout-save_selection_layout )
    ).

    me->set_dirty_flag( iv_new_state = abap_false ).

  ENDIF.

ENDMETHOD.


method /PLMB/IF_SPI_APPL_ACCESS~CHECK_BEFORE_SAVE. "#EC NEEDED
endmethod.


method /PLMB/IF_SPI_APPL_ACCESS~CLEAN_UP. "#EC NEEDED
endmethod.


METHOD /PLMB/IF_SPI_APPL_ACCESS~DELETE.

  DATA:
        lv_node_name              TYPE         /plmb/spi_node_name,
        lo_node                   TYPE REF TO  /plmb/if_exp_node_access,
        lt_messages               TYPE         /plmb/t_spi_msg.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: ev_failed,
         et_index_failed.

*--------------------------------------------------------------------*
* Get Node
*--------------------------------------------------------------------*
  lv_node_name = iv_node_name.

  CALL METHOD /plmb/cl_exp_node_factory=>get_node
    EXPORTING
      iv_node_name = lv_node_name
    IMPORTING
      eo_node      = lo_node.

*--------------------------------------------------------------------*
* Call Delete
*--------------------------------------------------------------------*
  CALL METHOD lo_node->delete
    EXPORTING
      it_node_id  = it_node_id
    IMPORTING
      et_message  = lt_messages
*     ev_severity =      " Severity
    .

*--------------------------------------------------------------------*
* Set Messages
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>evaluate_messages
    EXPORTING
      it_message      = lt_messages
    IMPORTING
      ev_failed       = ev_failed
      et_index_failed = et_index_failed.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_messages
      iv_node_name = iv_node_name
      it_node_ref  = it_node_id.

*--------------------------------------------------------------------*
* In case of success delete update dirty flag
*--------------------------------------------------------------------*
  IF ev_failed EQ abap_false.
    me->set_dirty_flag( iv_new_state = abap_true ).
  ENDIF.

ENDMETHOD.


METHOD /PLMB/IF_SPI_APPL_ACCESS~INSERT.

  DATA:
        lv_node_name              TYPE         /plmb/spi_node_name,
        lo_node                   TYPE REF TO  /plmb/if_exp_node_access,
        lt_messages               TYPE         /plmb/t_spi_msg.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: ev_failed,
         et_index_failed,
         et_node_data,
         et_node_id_rel.

*--------------------------------------------------------------------*
* Get Node
*--------------------------------------------------------------------*
  IF iv_target_node_name IS INITIAL.
    lv_node_name = iv_node_name.
  ELSE.
    lv_node_name = iv_target_node_name.
  ENDIF.

  CALL METHOD /plmb/cl_exp_node_factory=>get_node
    EXPORTING
      iv_node_name = lv_node_name
    IMPORTING
      eo_node      = lo_node.

*--------------------------------------------------------------------*
* call Insert
*--------------------------------------------------------------------*
  CALL METHOD lo_node->insert
    EXPORTING
      it_data        = it_node_data
      is_param       = is_param
    IMPORTING
      et_data        = et_node_data
      et_message     = lt_messages
*     ev_severity    =
      et_node_id_rel = et_node_id_rel.

*--------------------------------------------------------------------*
* Set Messages
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>evaluate_messages
    EXPORTING
      it_message      = lt_messages
    IMPORTING
      ev_failed       = ev_failed
      et_index_failed = et_index_failed.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_messages
      iv_node_name = lv_node_name
      it_node_ref  = it_node_data.

*--------------------------------------------------------------------*
* In case of success insert update dirty flag
*--------------------------------------------------------------------*
  IF ev_failed EQ abap_false
    AND iv_node_name NE /plmb/cl_exp_mp=>gc_node_objects
    AND iv_node_name NE /plmb/cl_exp_mp=>gc_node_selection_layout.
    me->set_dirty_flag( iv_new_state = abap_true ).
  ENDIF.

ENDMETHOD.


method /PLMB/IF_SPI_APPL_ACCESS~QUERY.  "#EC NEEDED
endmethod.


METHOD /PLMB/IF_SPI_APPL_ACCESS~RETRIEVE.

  DATA: lv_node_name              TYPE         /plmb/spi_node_name,
        lo_node                   TYPE REF TO  /plmb/if_exp_node_access,

        lt_messages               TYPE         /plmb/t_spi_msg,
        lt_lock_messages          TYPE         /plmb/t_spi_msg,
        lt_msg_combined           TYPE         /plmb/t_spi_msg.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: ev_failed,
         et_index_failed,
         et_node_data,
         et_node_id_rel.

*--------------------------------------------------------------------*
* Get Node
*--------------------------------------------------------------------*
  IF iv_target_node_name IS INITIAL.
    lv_node_name = iv_node_name.
  ELSE.
    lv_node_name = iv_target_node_name.
  ENDIF.

  CALL METHOD /plmb/cl_exp_node_factory=>get_node
    EXPORTING
      iv_node_name = lv_node_name
    IMPORTING
      eo_node      = lo_node.

*--------------------------------------------------------------------*
* call Retrieve
*--------------------------------------------------------------------*
  CALL METHOD lo_node->retrieve
    EXPORTING
      it_id           = it_node_id
      iv_lock         = iv_lock
    IMPORTING
      et_data         = et_node_data
      et_message      = lt_messages
      et_message_lock = lt_lock_messages
      et_relation     = et_node_id_rel.

*--------------------------------------------------------------------*
* Set Messages
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>evaluate_messages_retrieve
    EXPORTING
      it_message_lock     = lt_lock_messages
      it_message_retrieve = lt_messages
    IMPORTING
      et_message_combined = lt_msg_combined
      ev_failed           = ev_failed
      et_index_failed     = et_index_failed.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_msg_combined
      iv_node_name = iv_node_name
      it_node_ref  = it_node_id.

*--------------------------------------------------------------------*
* Set Field Properties
*--------------------------------------------------------------------*
  CALL METHOD set_field_properties
    EXPORTING
      it_node_data = et_node_data
      iv_node_name = lv_node_name
      io_node      = lo_node.

ENDMETHOD.


method /PLMB/IF_SPI_APPL_ACCESS~SAVE. "#EC NEEDED
endmethod.


METHOD /plmb/if_spi_appl_access~update.

  DATA: lo_node           TYPE REF TO /plmb/if_exp_node_access,
        lt_message        TYPE        /plmb/t_spi_msg.

*--------------------------------------------------------------------*
* Get Node
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_exp_node_factory=>get_node
    EXPORTING
      iv_node_name = iv_node_name
    IMPORTING
      eo_node      = lo_node.

*--------------------------------------------------------------------*
* Update Data
*--------------------------------------------------------------------*
  CALL METHOD lo_node->update
    EXPORTING
      it_data        = it_node_data
    IMPORTING
      et_data        = et_node_data
      et_message     = lt_message
      et_node_id_rel = et_node_id_rel.

*--------------------------------------------------------------------*
* Set Messages
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>evaluate_messages
    EXPORTING
      it_message      = lt_message
    IMPORTING
      ev_failed       = ev_failed
      et_index_failed = et_index_failed.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_message
      iv_node_name = iv_node_name
      it_node_ref  = it_node_data.

*--------------------------------------------------------------------*
* Set Field Properties
*--------------------------------------------------------------------*
  CALL METHOD set_field_properties
    EXPORTING
      it_node_data = et_node_data
      iv_node_name = iv_node_name
      io_node      = lo_node.

*--------------------------------------------------------------------*
* In case of success updata, update dirty flag
*--------------------------------------------------------------------*
  IF ev_failed EQ abap_false
    AND iv_node_name NE /plmb/cl_exp_mp=>gc_node_download_parameters " special case
    AND iv_node_name NE /plmb/cl_exp_mp=>gc_node_selection_tree      " special case
    AND iv_node_name NE /plmb/cl_exp_mp=>gc_node_selection_layout.   " special case
    me->set_dirty_flag( abap_true ).
  ENDIF.

ENDMETHOD.


METHOD set_dirty_flag.

  DATA:
        lr_node           TYPE REF TO /plmb/if_exp_node_access.

  /plmb/cl_exp_node_factory=>get_node(
    EXPORTING
      iv_node_name = /plmb/cl_exp_mp=>gc_node_download_data
    IMPORTING
      eo_node      = lr_node ).
  assert lr_node IS BOUND.

  IF iv_new_state EQ abap_true.
  lr_node->action(
    EXPORTING
      iv_action_name = /plmb/cl_exp_mp=>gc_action_data_download-set_dirty_flag
    ).
  else.
  lr_node->action(
    EXPORTING
      iv_action_name = /plmb/cl_exp_mp=>gc_action_data_download-clear_dirty_flag
    ).
  endif.

ENDMETHOD.


METHOD set_field_properties.

  DATA: lt_default_profile TYPE /plmb/t_spi_profile_node,
        lt_profile_id      TYPE /plmb/t_spi_profile_node,

        lt_message         TYPE /plmb/t_spi_msg,
        lv_severity        TYPE /plmb/spi_msg_severity.

  FIELD-SYMBOLS:
        <ls_profile>       TYPE /plmb/s_spi_profile_def,
        <ls_profile_node>  TYPE /plmb/s_spi_profile_node,
        <ls_data>          TYPE any,
        <ls_id>            TYPE any.

*--------------------------------------------------------------------*
* Get Default Profile
*--------------------------------------------------------------------*
  TRY .
      CALL METHOD io_node->get_profiles
        EXPORTING
          iv_action_name     = iv_action_name
          it_node_data       = it_node_data
        IMPORTING
          et_default_profile = lt_default_profile
          et_message         = lt_message
          ev_severity        = lv_severity.
    CATCH cx_root.                                       "#EC CATCH_ALL
      RETURN.
  ENDTRY.

* Note: errors in profile determination are always adjusted to message
*       index 0, since they have no actual relationship to the
*       triggerung request (e.g. UPDATE or RETRIEVE); also this will
*       lead to EV_FAILED = 'X' on SP level, which is wanted in this case
  CALL METHOD /plmb/cl_spi_appl_access_utils=>set_msg_index
    EXPORTING
      iv_index   = 0
    CHANGING
      ct_message = lt_message.

  CALL METHOD mo_collector->add_message_tab
    EXPORTING
      it_msg       = lt_message
      iv_node_name = iv_node_name.

  IF lv_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Set Default Profile
*--------------------------------------------------------------------*
  IF lt_default_profile IS NOT INITIAL.
    LOOP AT lt_default_profile ASSIGNING <ls_profile_node>.
      LOOP AT <ls_profile_node>-profiles ASSIGNING <ls_profile>.
        CALL METHOD mo_collector->set_properties
          EXPORTING
            iv_node_name = <ls_profile_node>-node_name
            it_profile   = <ls_profile>-properties.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

*--------------------------------------------------------------------*
* Typify Structures
*--------------------------------------------------------------------*
  ASSIGN io_node->mr_sp_data_str->* TO <ls_data>.
  ASSIGN io_node->mr_sp_id_str->* TO <ls_id>.

  LOOP AT it_node_data ASSIGNING <ls_data>.
    MOVE-CORRESPONDING <ls_data> TO <ls_id>.
*--------------------------------------------------------------------*
* Get Profile per ID line
*--------------------------------------------------------------------*
    CALL METHOD io_node->get_profiles
      EXPORTING
        is_id          = <ls_id>
        iv_action_name = iv_action_name
        it_node_data   = it_node_data
      IMPORTING
        et_profile     = lt_profile_id
        et_message     = lt_message
        ev_severity    = lv_severity.

    CALL METHOD /plmb/cl_spi_appl_access_utils=>set_msg_index
      EXPORTING
        iv_index   = 0
      CHANGING
        ct_message = lt_message.

    CALL METHOD mo_collector->add_message_tab
      EXPORTING
        it_msg       = lt_message
        iv_node_name = iv_node_name.

    IF lv_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
      RETURN.
    ENDIF.

*--------------------------------------------------------------------*
* set Profile per ID line
*--------------------------------------------------------------------*
    IF lt_profile_id IS NOT INITIAL.
      LOOP AT lt_profile_id ASSIGNING <ls_profile_node>.
        LOOP AT <ls_profile_node>-profiles ASSIGNING <ls_profile>.
          CALL METHOD mo_collector->set_properties
            EXPORTING
              iv_node_name = <ls_profile_node>-node_name
              is_node_id   = <ls_id>
              it_profile   = <ls_profile>-properties.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.