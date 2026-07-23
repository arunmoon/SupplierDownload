class /PLMB/CL_EXP_ND_EXPORTING definition
  public
  inheriting from /PLMB/CL_EXP_NODE
  final
  create public .

public section.

  methods /PLMB/IF_EXP_NODE_ACCESS~ACTION
    redefinition .
protected section.
*"* protected components of class /PLMB/CL_EXP_ND_EXPORTING
*"* do not include other source files here!!!
private section.

  methods ACTION_GET_ADD_INFO_FIELDS
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_DEFINITION
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_DEFINITION_UI
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_EXP_DATA
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_HEADER_INFORMATION
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_VARIANTS
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods CHECK_TABLE_DEFINITION
    importing
      !IT_TABLE_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_VARIANT type /PLMB/EXP_VARIANT_ID
    exporting
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
  methods ACTION_GET_DOWNLOAD_DATA
    importing
      !IS_PARAM type ANY
      !IT_NODE_ID type INDEX TABLE
    exporting
      !ET_DATA type INDEX TABLE
      !EG_PARAM type ANY
      !ET_MESSAGE type /PLMB/T_SPI_MSG
      !EV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
ENDCLASS.



CLASS /PLMB/CL_EXP_ND_EXPORTING IMPLEMENTATION.


METHOD /plmb/if_exp_node_access~action.

  DATA: lv_method TYPE string.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Call Action
*--------------------------------------------------------------------*
  TRY.
      CONCATENATE 'ACTION_' iv_action_name INTO lv_method.
      CALL METHOD (lv_method)
        EXPORTING
          is_param    = is_param
          it_node_id  = it_node_id
        IMPORTING
          et_data     = et_data
          eg_param    = eg_param
          et_message  = et_message
          ev_severity = ev_severity.
    CATCH cx_root.
      RETURN.
  ENDTRY.






ENDMETHOD.


METHOD action_get_add_info_fields.

  DATA: ls_param       TYPE        /plmb/s_exp_add_info_param,
        lo_exp         TYPE REF TO /plmb/exp_exporting,
        lt_add_info_f  TYPE        /plmb/t_exp_additional_info_f,
        lv_otype_descr TYPE        /plmb/gos_otype_desc,

        lv_msg         TYPE        char255.

*--------------------------------------------------------------------*
* Clear export parameters
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Parameter
*--------------------------------------------------------------------*
  ls_param = is_param.

*--------------------------------------------------------------------*
* Badi call
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_exp
        FILTERS
          gos_type = ls_param-gos_type. "is_param.

      CALL BADI lo_exp->get_additional_info_fields
        EXPORTING
          iv_variant_id      = ls_param-variant_id
          it_objects         = ls_param-gos_internal_key
        CHANGING
          ct_add_info_fields = lt_add_info_f.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_param-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
    CATCH cx_root.
*   Technical error; contact your system administrator
      MESSAGE e001(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
  ENDTRY.

  IF lv_msg IS NOT INITIAL.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
      EXPORTING
        iv_index   = 0
      CHANGING
        ct_message = et_message.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
      EXPORTING
        it_message      = et_message
      IMPORTING
        ev_msg_severity = ev_severity.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Set Additional Fields
*--------------------------------------------------------------------*
  eg_param = lt_add_info_f.


ENDMETHOD.


METHOD action_get_definition.

  DATA: ls_param            TYPE /plmb/s_exp_add_info_param,

        lo_badi             TYPE REF TO /plmb/exp_exporting,

        lt_table_definition TYPE /plmb/t_exp_table_definition,

        lv_otype_descr      TYPE /plmb/gos_otype_desc,
        lt_message          TYPE /plmb/t_spi_msg,
        lv_msg              TYPE char255.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Parameter
*--------------------------------------------------------------------*
  ls_param = is_param.

*--------------------------------------------------------------------*
* Get BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_badi
        FILTERS
          gos_type = ls_param-gos_type.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_param-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Get Definition
*--------------------------------------------------------------------*
  TRY .
      CALL BADI lo_badi->get_definition
        EXPORTING
          iv_variant_id       = ls_param-variant_id
        CHANGING
          ct_table_definition = lt_table_definition
          ct_message          = lt_message.
    CATCH cx_root.
      MESSAGE e003(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Check Table Definition
*--------------------------------------------------------------------*
  CALL METHOD check_table_definition
    EXPORTING
      it_table_definition = lt_table_definition
      iv_variant          = ls_param-variant_id
    IMPORTING
      et_message          = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Return Definition
*--------------------------------------------------------------------*
  eg_param = lt_table_definition.

ENDMETHOD.


METHOD action_get_definition_ui.

  DATA: ls_param            TYPE /plmb/s_exp_add_info_param,

        lo_badi             TYPE REF TO /plmb/exp_exporting,

        lt_table_definition TYPE /plmb/t_exp_tbl_definition_ui,

        lv_otype_descr      TYPE /plmb/gos_otype_desc,
        lt_message          TYPE /plmb/t_spi_msg,
        lv_msg              TYPE char255.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Parameter
*--------------------------------------------------------------------*
  ls_param = is_param.

*--------------------------------------------------------------------*
* Get BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_badi
        FILTERS
          gos_type = ls_param-gos_type.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_param-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Get Definition
*--------------------------------------------------------------------*
  TRY .
      CALL BADI lo_badi->get_definition
        EXPORTING
          iv_variant_id          = ls_param-variant_id
        CHANGING
          ct_table_definition_ui = lt_table_definition
          ct_message             = lt_message.
    CATCH cx_root.
      MESSAGE e003(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Return Definition
*--------------------------------------------------------------------*
  eg_param = lt_table_definition.

ENDMETHOD.


METHOD action_get_download_data.

  DATA:
        ls_add_info_param TYPE /plmb/s_exp_add_info_param,
        lt_add_info       TYPE /plmb/t_exp_additional_info,

        lo_badi           TYPE REF TO /plmb/exp_exporting,
        lo_gen_badi       TYPE REF TO /plmb/exp_generic_data,
        lo_bo             TYPE REF TO /plmb/cl_exp_bo,

        lv_variant_id     TYPE /plmb/exp_variant_id,
        lt_sel_fields     TYPE /plmb/t_exp_sel_fields,
        lv_selection      TYPE string,
        lv_table_no(4)    TYPE n,

        lt_out_tables     TYPE /plmb/t_exp_tables,
        ls_out_table      TYPE /plmb/s_exp_table,

        lt_table_definition TYPE /plmb/t_exp_table_definition,

        ls_export         TYPE /plmb/s_exporting_sp,

        lt_table_data     TYPE /plmb/t_exp_table_data_export,
        ls_table_data     TYPE /plmb/s_exp_table_data_export,
        lt_gen_table_data     TYPE /plmb/t_exp_table_data_export,

        lt_data           TYPE /plmb/t_exp_table_data_xstring,
        ls_data           TYPE /plmb/s_exp_table_data_xstring,

        lv_otype_descr    TYPE /plmb/gos_otype_desc,
        lt_message        TYPE /plmb/t_spi_msg,
        lv_msg            TYPE char255.

  FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE,
                 <ls_table_def> TYPE /plmb/s_exp_table_definition,
                 <ls_gen_table_data> TYPE /plmb/s_exp_table_data_export.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Call BO to get all relevant selection data
*--------------------------------------------------------------------*

  lo_bo = /plmb/cl_exp_bo=>get_instance( ).

  lo_bo->get_selection(
    IMPORTING
      ev_gos_type   = ls_export-gos_type
      ev_variant_id = lv_variant_id
      et_objects    = ls_add_info_param-gos_internal_key
      et_sel_fields = lt_sel_fields
      et_add_info   = lt_add_info
      ev_selection  = lv_selection
    CHANGING
      ct_message    = et_message
      cv_severity   = ev_severity ).

*--------------------------------------------------------------------*
* Set Parameter for Header and Additional Information
*--------------------------------------------------------------------*

  IF ls_add_info_param-gos_internal_key IS INITIAL.
* Objects are missing, the user should add some
    MESSAGE e011(/plmb/ba_exp) INTO lv_msg.
    /plmb/cl_exp_tools=>add_message(
      CHANGING
        ct_message  = et_message
        cv_severity = ev_severity ).
    RETURN.
  ENDIF.

  ls_add_info_param-gos_type         = ls_export-gos_type.
  ls_add_info_param-variant_id       = lv_variant_id.

*--------------------------------------------------------------------*
* Get Header Information
*--------------------------------------------------------------------*
  CALL METHOD /plmb/if_exp_node_access~action
    EXPORTING
      iv_action_name = /plmb/cl_exp_mp=>gc_act_get_header_info
      is_param       = ls_add_info_param
    IMPORTING
      eg_param       = ls_export-header_info
      et_message     = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/if_spi_c=>gs_c_severity_category-error_or_worse.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Get Export BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_badi
        FILTERS
          gos_type = ls_export-gos_type.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_export-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
      /plmb/cl_exp_tools=>add_message(
        CHANGING
          ct_message  = et_message
          cv_severity = ev_severity ).
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Get Generic Data BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_gen_badi
        FILTERS
          gos_type = ls_export-gos_type
          variant  = lv_variant_id.
    CATCH cx_badi_filter_error
          cx_badi_multiply_implemented.
      ASSERT 1 = 0.
* Multiple implementation or filter error will dump -> is forbidden
    CATCH cx_badi_not_implemented.
* No implementation is OK, as it is optional -> no error msg is necessary
  ENDTRY.

*--------------------------------------------------------------------*
* Get Definition
*--------------------------------------------------------------------*
  TRY .
      CALL BADI lo_badi->get_definition
        EXPORTING
          iv_variant_id       = lv_variant_id
          it_sel_fields       = lt_sel_fields
        CHANGING
          ct_table_definition = ls_export-table_definition
          ct_message          = lt_message.
    CATCH cx_root.
      MESSAGE e003(/plmb/ba_exp) WITH lv_variant_id INTO lv_msg.
      /plmb/cl_exp_tools=>add_message(
        CHANGING
          ct_message  = et_message
          cv_severity = ev_severity ).
      RETURN.
  ENDTRY.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Get Generic Definition
*--------------------------------------------------------------------*
  IF lo_gen_badi IS BOUND.

    CALL BADI lo_gen_badi->get_definition
      EXPORTING
        it_objects          = ls_add_info_param-gos_internal_key
        it_add_info         = lt_add_info
        iv_variant_id       = lv_variant_id
        iv_selection        = lv_selection
      IMPORTING
        et_table_definition = lt_table_definition
      CHANGING
        ct_message          = et_message
        cv_severity         = ev_severity.

    IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
      RETURN.
    ENDIF.
  ENDIF.

* Find the highest Group number in the old BAdI
  LOOP AT ls_export-table_definition ASSIGNING <ls_table_def>.
    IF <ls_table_def>-table_no > lv_table_no.
      lv_table_no = <ls_table_def>-table_no.
    ENDIF.
  ENDLOOP.

* Offset the new Group numbers with this, so there are no overlaps
  LOOP AT lt_table_definition ASSIGNING <ls_table_def> WHERE new_page <> abap_true.
    ADD lv_table_no TO <ls_table_def>-table_no.
  ENDLOOP.

* Finally join them
  APPEND LINES OF lt_table_definition TO ls_export-table_definition.

*--------------------------------------------------------------------*
* Check if definition table is initial
*--------------------------------------------------------------------*
  IF ls_export-table_definition IS INITIAL.
    "No data found to download
    MESSAGE e012(/plmb/ba_exp) INTO lv_msg.
    /plmb/cl_exp_tools=>add_message(
      CHANGING
        ct_message  = et_message
        cv_severity = ev_severity ).
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Check Definition
*--------------------------------------------------------------------*
  CALL METHOD check_table_definition
    EXPORTING
      it_table_definition = ls_export-table_definition
      iv_variant          = lv_variant_id
    IMPORTING
      et_message          = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Get Export Data
*--------------------------------------------------------------------*
* Prepare parameters
  LOOP AT ls_export-table_definition ASSIGNING <ls_table_def> WHERE table_text IS NOT INITIAL.
    MOVE-CORRESPONDING <ls_table_def> TO ls_out_table.
    APPEND ls_out_table TO lt_out_tables.
  ENDLOOP.

  TRY .
      CALL BADI lo_badi->get_export_data
        EXPORTING
          it_objects    = ls_add_info_param-gos_internal_key
          iv_variant_id = lv_variant_id
          it_add_info   = lt_add_info
          it_out_tables = lt_out_tables
          it_sel_fields = lt_sel_fields
        CHANGING
          ct_table_data = lt_table_data
          ct_message    = lt_message.
    CATCH cx_root.
      MESSAGE e004(/plmb/ba_exp) WITH lv_variant_id INTO lv_msg.
      /plmb/cl_exp_tools=>add_message(
        CHANGING
          ct_message  = et_message
          cv_severity = ev_severity ).
      RETURN.
  ENDTRY.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

*--------------------------------------------------------------------*
* Get Generic Export Data
*--------------------------------------------------------------------*
  IF lo_gen_badi IS BOUND.
    TRY.
        CALL BADI lo_gen_badi->get_export_data
          EXPORTING
            it_objects    = ls_add_info_param-gos_internal_key
            it_add_info   = lt_add_info
            iv_variant_id = lv_variant_id
            iv_selection  = lv_selection
          IMPORTING
            et_table_data = lt_gen_table_data
          CHANGING
            ct_message    = et_message
            cv_severity   = ev_severity.
      CATCH cx_root.
        ASSERT 1 = 0.  "The method must be implemented
    ENDTRY.

*   Offset the new Group numbers with the max group number, so there are no overlaps
    LOOP AT lt_gen_table_data ASSIGNING <ls_gen_table_data>.
      ADD lv_table_no TO <ls_gen_table_data>-table_no.
    ENDLOOP.

    APPEND LINES OF lt_gen_table_data TO lt_table_data.
  ENDIF.

*--------------------------------------------------------------------*
* Export Data to XSTRING
*--------------------------------------------------------------------*
  LOOP AT lt_table_data INTO ls_table_data.
    ls_data-table_no = ls_table_data-table_no.
    ASSIGN ls_table_data-table_data->* TO <lt_data>.
    CLEAR ls_data-table_data.
    EXPORT table_data = <lt_data>
      TO DATA BUFFER ls_data-table_data
      COMPRESSION OFF.
    APPEND ls_data TO lt_data.
  ENDLOOP.

*--------------------------------------------------------------------*
* Get Export Type
*--------------------------------------------------------------------*
  CLEAR lv_msg.
  TRY .
      CALL BADI lo_badi->get_export_type
        EXPORTING
          iv_variant_id  = lv_variant_id
        CHANGING
          cv_export_type = ls_export-export_type.
    CATCH cx_root.
      lv_msg = abap_true.
  ENDTRY.

  IF lv_msg IS NOT INITIAL OR ls_export-export_type IS INITIAL.
    MESSAGE e005(/plmb/ba_exp) WITH lv_variant_id INTO lv_msg.
    /plmb/cl_exp_tools=>add_message(
      CHANGING
        ct_message  = et_message
        cv_severity = ev_severity ).
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Add Export Data
*--------------------------------------------------------------------*
  ls_export-table_data = lt_data.
  APPEND ls_export TO et_data.

ENDMETHOD.


METHOD action_get_exp_data.

  DATA: ls_param          TYPE /plmb/s_exp_export_data,

        ls_add_info_param TYPE /plmb/s_exp_add_info_param,
        ls_add_info_xs    TYPE /plmb/s_exp_additional_info_xs,
        lt_add_info       TYPE /plmb/t_exp_additional_info,
        ls_add_info       TYPE /plmb/s_exp_additional_info,
        lt_add_info_f     TYPE /plmb/t_exp_additional_info_f,
        ls_add_info_f     TYPE /plmb/s_exp_additional_info_f,

        lo_badi           TYPE REF TO /plmb/exp_exporting,

        ls_export         TYPE /plmb/s_exporting_sp,

        ls_id             TYPE /plmb/s_exporting_id_sp,
        lt_objects        TYPE /plmb/t_gos_internal_key,
        ls_objects        TYPE /plmb/s_gos_internal_key,

        lt_table_data     TYPE /plmb/t_exp_table_data_export,
        ls_table_data     TYPE /plmb/s_exp_table_data_export,

        lt_data           TYPE /plmb/t_exp_table_data_xstring,
        ls_data           TYPE /plmb/s_exp_table_data_xstring,

        lv_otype_descr    TYPE /plmb/gos_otype_desc,
        lt_message        TYPE /plmb/t_spi_msg,
        lv_msg            TYPE char255.

  FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE,
                 <lv_data> TYPE any.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Parameter
*--------------------------------------------------------------------*
  ls_param = is_param.
  ls_export-gos_type = ls_param-gos_type.

*--------------------------------------------------------------------*
* Set Parameter for Header and Additional Information
*--------------------------------------------------------------------*
  ls_add_info_param-gos_type         = ls_param-gos_type.
  ls_add_info_param-variant_id       = ls_param-variant_id.
  ls_add_info_param-gos_internal_key = ls_param-gos_internal_key.

*--------------------------------------------------------------------*
* Get Header Information
*--------------------------------------------------------------------*
  CALL METHOD /plmb/if_exp_node_access~action
    EXPORTING
      iv_action_name = /plmb/cl_exp_mp=>gc_act_get_header_info
      is_param       = ls_add_info_param
    IMPORTING
      eg_param       = ls_export-header_info
      et_message     = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/if_spi_c=>gs_c_severity_category-error_or_worse.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Get Additional Information
*--------------------------------------------------------------------*
  CALL METHOD /plmb/if_exp_node_access~action
    EXPORTING
      iv_action_name = /plmb/cl_exp_mp=>gc_act_get_add_info_f
      is_param       = ls_add_info_param
    IMPORTING
      eg_param       = lt_add_info_f
      et_message     = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/if_spi_c=>gs_c_severity_category-error_or_worse.
    RETURN.
  ENDIF.

  LOOP AT lt_add_info_f INTO ls_add_info_f.
    READ TABLE ls_param-add_info INTO ls_add_info_xs
      WITH KEY fname = ls_add_info_f-fname.
    IF sy-subrc = 0.
      CLEAR ls_add_info.
      ls_add_info-fname = ls_add_info_f-fname.
      CREATE DATA ls_add_info-value TYPE (ls_add_info_f-typename).
      ASSIGN ls_add_info-value->* TO <lv_data>.
      IMPORT value = <lv_data>
        FROM DATA BUFFER ls_add_info_xs-value.
      APPEND ls_add_info TO lt_add_info.
    ENDIF.
  ENDLOOP.

*--------------------------------------------------------------------*
* Get BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_badi
        FILTERS
          gos_type = ls_param-gos_type.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_param-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Get Definition
*--------------------------------------------------------------------*
  TRY .
      CALL BADI lo_badi->get_definition
        EXPORTING
          iv_variant_id       = ls_param-variant_id
        CHANGING
          ct_table_definition = ls_export-table_definition
          ct_message          = lt_message.
    CATCH cx_root.
      MESSAGE e003(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Check Definition
*--------------------------------------------------------------------*
  CALL METHOD check_table_definition
    EXPORTING
      it_table_definition = ls_export-table_definition
      iv_variant          = ls_param-variant_id
    IMPORTING
      et_message          = lt_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

  IF ev_severity CA /plmb/cl_rcp_message=>gc_sv_aex.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Get Export Data
*--------------------------------------------------------------------*
  lt_objects = ls_param-gos_internal_key.

  TRY .
      CALL BADI lo_badi->get_export_data
        EXPORTING
          it_objects    = lt_objects
          iv_variant_id = ls_param-variant_id
          it_add_info   = lt_add_info
          it_out_tables = ls_param-out_tables
        CHANGING
          ct_table_data = lt_table_data
          ct_message    = lt_message.
    CATCH cx_root.
      MESSAGE e004(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.


  CALL METHOD /plmb/cl_spi_appl_access_utils=>add_messages
    EXPORTING
      it_message = lt_message
    CHANGING
      ct_message = et_message.

  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

*--------------------------------------------------------------------*
* Export Data to XSTRING
*--------------------------------------------------------------------*
  LOOP AT lt_table_data INTO ls_table_data.
    ls_data-table_no = ls_table_data-table_no.
    ASSIGN ls_table_data-table_data->* TO <lt_data>.
    CLEAR ls_data-table_data.
    EXPORT table_data = <lt_data>
      TO DATA BUFFER ls_data-table_data
      COMPRESSION OFF.
    APPEND ls_data TO lt_data.
  ENDLOOP.

*--------------------------------------------------------------------*
* Get Export Type
*--------------------------------------------------------------------*
  CLEAR lv_msg.
  TRY .
      CALL BADI lo_badi->get_export_type
        EXPORTING
          iv_variant_id  = ls_param-variant_id
        CHANGING
          cv_export_type = ls_export-export_type.
    CATCH cx_root.
      lv_msg = abap_true.
  ENDTRY.

  IF lv_msg IS NOT INITIAL OR ls_export-export_type IS INITIAL.
    MESSAGE e005(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
      EXPORTING
        iv_index   = 0
      CHANGING
        ct_message = et_message.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
      EXPORTING
        it_message      = et_message
      IMPORTING
        ev_msg_severity = ev_severity.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Add Export Data
*--------------------------------------------------------------------*
  ls_export-table_data = lt_data.
  APPEND ls_export TO et_data.

ENDMETHOD.


METHOD action_get_header_information.

  DATA: ls_param          TYPE        /plmb/s_exp_add_info_param,
        lo_badi           TYPE REF TO /plmb/exp_exporting,
        lv_otype_descr    TYPE        /plmb/gos_otype_desc,

        lt_header_info    TYPE        /plmb/t_exp_header_info,
        ls_header_info    TYPE        /plmb/s_exp_header_info,

        lt_header_info_xs TYPE        /plmb/t_exp_header_info_xs,
        ls_header_info_xs TYPE        /plmb/s_exp_header_info_xs,

        lv_msg            TYPE        char255.

  FIELD-SYMBOLS:
        <lv_data>         TYPE        any.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Parameter
*--------------------------------------------------------------------*
  ls_param = is_param.

*--------------------------------------------------------------------*
* Get BadI
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_badi
        FILTERS
          gos_type = ls_param-gos_type.
    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      CALL METHOD /plmb/cl_gos_obj_type=>get_descr
        EXPORTING
          iv_otype_name = ls_param-gos_type
        IMPORTING
          ev_otype_desc = lv_otype_descr.
      MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Get Header Information
*--------------------------------------------------------------------*
  TRY .
      CALL BADI lo_badi->get_header_information
        EXPORTING
          iv_variant_id  = ls_param-variant_id
        CHANGING
          ct_header_info = lt_header_info.
    CATCH cx_root.
      MESSAGE w006(/plmb/ba_exp) WITH ls_param-variant_id INTO lv_msg.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
        EXPORTING
          it_message      = et_message
        IMPORTING
          ev_msg_severity = ev_severity.
  ENDTRY.


*--------------------------------------------------------------------*
* Map Header Information to XSTRING
*--------------------------------------------------------------------*
  LOOP AT lt_header_info INTO ls_header_info.
    CLEAR ls_header_info_xs.
    ls_header_info_xs-fname_descr = ls_header_info-fname_descr.
    ls_header_info_xs-fname_type  = ls_header_info-fname_type.
    ls_header_info_xs-content_descr = ls_header_info-content_descr.
    ASSIGN ls_header_info-content->* TO <lv_data>.
    CLEAR ls_header_info_xs-content.
    EXPORT content = <lv_data>
      TO DATA BUFFER ls_header_info_xs-content
      COMPRESSION OFF.
    APPEND ls_header_info_xs TO lt_header_info_xs.
  ENDLOOP.

*--------------------------------------------------------------------*
* Output Header Information
*--------------------------------------------------------------------*
  eg_param = lt_header_info_xs.

ENDMETHOD.


METHOD action_get_variants.

  DATA: lo_rcp_exp     TYPE REF TO /plmb/exp_exporting,
        lt_variants    TYPE        /plmb/t_exp_variants,
        lv_gos_type    TYPE        /plmb/gos_object_type,
        lv_otype_descr TYPE        /plmb/gos_otype_desc,

        lv_msg         TYPE        char255.

*--------------------------------------------------------------------*
* Clear export parameters
*--------------------------------------------------------------------*
  CLEAR: et_data,
         eg_param,
         et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Get Input
*--------------------------------------------------------------------*
  lv_gos_type = is_param.

*--------------------------------------------------------------------*
* Get Variants
*--------------------------------------------------------------------*
  TRY.
      GET BADI lo_rcp_exp
        FILTERS
          gos_type = lv_gos_type.

      CALL BADI lo_rcp_exp->get_export_variants
        CHANGING
          ct_variants = lt_variants.

    CATCH cx_badi_filter_error
          cx_badi_not_implemented.
      lv_msg = abap_true.
  ENDTRY.

  IF lv_msg IS NOT INITIAL OR lt_variants IS INITIAL.
    CALL METHOD /plmb/cl_gos_obj_type=>get_descr
      EXPORTING
        iv_otype_name = lv_gos_type
      IMPORTING
        ev_otype_desc = lv_otype_descr.
    MESSAGE e002(/plmb/ba_exp) WITH lv_otype_descr INTO lv_msg.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
      EXPORTING
        iv_index   = 0
      CHANGING
        ct_message = et_message.
    CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
      EXPORTING
        it_message      = et_message
      IMPORTING
        ev_msg_severity = ev_severity.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Export Variants
*--------------------------------------------------------------------*
  eg_param = lt_variants.


ENDMETHOD.


METHOD check_table_definition.

  DATA: ls_table_def TYPE /plmb/s_exp_table_definition,

        lo_element   TYPE REF TO cl_abap_typedescr,
        lv_is_ddic   TYPE abap_bool,

        lv_msg       TYPE char255.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR: et_message,
         ev_severity.

*--------------------------------------------------------------------*
* Check that displayed fields are DDIC Types
*--------------------------------------------------------------------*
  LOOP AT it_table_definition INTO ls_table_def
    WHERE nodedisplay = abap_true
      AND fieldname IS NOT INITIAL.

    CLEAR lv_msg.

    IF ls_table_def-fieldtype_name IS INITIAL.
      MESSAGE e007(/plmb/ba_exp) WITH iv_variant
                                      ls_table_def-fieldname
                                      ls_table_def-table_no
                                 INTO lv_msg.
    ELSE.
      CLEAR lv_is_ddic.
      TRY .
          lo_element ?= cl_abap_typedescr=>describe_by_name( ls_table_def-fieldtype_name ).
          lv_is_ddic =  lo_element->is_ddic_type( ).
        CATCH cx_root.
      ENDTRY.
      IF lv_is_ddic = abap_false.
        MESSAGE e007(/plmb/ba_exp) WITH iv_variant
                                        ls_table_def-fieldname
                                        ls_table_def-table_no
                                   INTO lv_msg.
      ENDIF.
    ENDIF.

    IF lv_msg IS NOT INITIAL.
      CALL METHOD /plmb/cl_spi_appl_access_utils=>set_message
        EXPORTING
          iv_index   = 0
        CHANGING
          ct_message = et_message.
    ENDIF.

  ENDLOOP.

*--------------------------------------------------------------------*
* Get Message Severity
*--------------------------------------------------------------------*
  CALL METHOD /plmb/cl_spi_appl_access_utils=>get_severity
    EXPORTING
      it_message      = et_message
    IMPORTING
      ev_msg_severity = ev_severity.

ENDMETHOD.
ENDCLASS.