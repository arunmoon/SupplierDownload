class /PLMI/CL_SPC_EXP_GEN_DATA_ABS definition
  public
  abstract
  create public .

public section.

  interfaces /PLMB/IF_EXP_GENERIC_DATA .
  interfaces IF_BADI_INTERFACE .

  class-methods CLASS_CONSTRUCTOR .
protected section.

  types:
    BEGIN OF ty_s_component_descriptor,
      name                 TYPE abap_compname,
      typename             TYPE string,
      text                 TYPE string,
      type                 TYPE string,
      is_technical         TYPE boole_d,
      is_date_type         TYPE boole_d,
      is_time_type         TYPE boole_d,
      is_uom_type          TYPE boole_d,
      is_icon_type         TYPE boole_d,
      is_language_key_type TYPE boole_d,
      is_multiple          TYPE boole_d,
    END OF ty_s_component_descriptor .
  types:
    ty_t_component_descriptor TYPE STANDARD TABLE OF ty_s_component_descriptor WITH KEY name .
  types:
    BEGIN OF TY_S_TABLE_META_DATA,
      table_no TYPE numc04,
      engine_value_assignment_type TYPE ESEESTCAT,
      target_node_name TYPE /PLMB/SPI_NODE_NAME,
      ENGINE_KEY_ROW_MAX TYPE INT4,
      STRUCT_REF TYPE REF TO data,
    END OF TY_S_TABLE_META_DATA .
  types:
    TY_T_TABLE_META_DATA TYPE STANDARD TABLE OF TY_S_TABLE_META_DATA WITH KEY table_no engine_value_assignment_type .

  methods CONVERT_AND_APPEND_DATA
  abstract
    importing
      !IV_TABLE_NO type INT4
      !IR_OUT_DATA type ref to DATA
    changing
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  methods PROCESS_COMPONENT_DESCRIPTOR
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TECHNICAL_ESTCAT type ESEESTCAT
      !IV_ESTTYPE type ESEESTTYPE
    changing
      !CT_COMPONENT_DESCRIPTOR type TY_T_COMPONENT_DESCRIPTOR .
  methods PROCESS_TABLE_DATA
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TECHNICAL_ESTCAT type ESEESTCAT
      !IV_ESTTYPE type ESEESTTYPE
    changing
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !CT_TABLE_META_DATA type TY_T_TABLE_META_DATA .
  methods CHECK_NUMBER_OF_OBJECTS
  abstract
    importing
      !IT_OBJECTS type /PLMB/T_GOS_INTERNAL_KEY
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID
    exporting
      !EV_FAILED type BOOLE_D
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG
      !CV_SEVERITY type /PLMB/SPI_MSG_SEVERITY .
private section.

  types:
    BEGIN OF ty_s_node_property,
        node_name    TYPE /PLMB/SPI_NODE_NAME,
        PROPERTIES   TYPE /PLMB/T_SPI_PROPERTIES,
    END OF ty_s_node_property .
  types:
    ty_t_node_property TYPE STANDARD TABLE OF ty_s_node_property WITH KEY node_name .
  types:
    BEGIN OF TY_S_COMPOSITION_INFO,
        SUBCAT_GROUP type ESESUBCAT,
        TAB_TYPE     type STRING,
        TAB_LABEL    type STRING,
    END OF TY_S_COMPOSITION_INFO .
  types:
    BEGIN OF TY_S_FIELD_DESCRIPTION,
      estcat      TYPE ESEESTCAT,
      node_name   TYPE /plmb/spi_node_name,
      field_name  TYPE abap_compname,
      description TYPE string,
    END OF TY_S_FIELD_DESCRIPTION .
  types:
    ty_t_field_description TYPE STANDARD TABLE OF ty_s_field_description WITH KEY estcat node_name field_name .
  types:
    BEGIN OF TY_S_INSTANCE_NUMBER_REL,
      row_number      TYPE int4,
      instance_number TYPE int4,
    END OF TY_S_INSTANCE_NUMBER_REL .
  types:
    TY_T_INSTANCE_NUMBER_REL TYPE STANDARD TABLE OF TY_S_INSTANCE_NUMBER_REL WITH KEY row_number instance_number .
  types:
    BEGIN OF TY_S_ADDITIONAL_FIELDS,
      instance_number TYPE int4,
      sort_sequence   TYPE string,
      usage           TYPE string,
    END OF TY_S_ADDITIONAL_FIELDS .
  types:
    TY_T_ADDITIONAL_FIELDS TYPE STANDARD TABLE OF TY_S_ADDITIONAL_FIELDS WITH KEY instance_number .

  data MT_TABLE_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION .
  data MV_SELECTION type STRING .
  data MT_OBJECTS type /PLMB/T_GOS_INTERNAL_KEY .
  data MT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  data MV_TABLE_DEFINITION_FILLED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_SELECTION_FILLED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_OBJECTS_FILLED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_TABLE_DATA_FILLED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_NUTR_GROUP type CHAR30 .
  data MV_DIET_GROUP type CHAR30 .
  data MV_ALLERG_GRP type CHAR30 .
  data MV_RELIG_GRP type CHAR30 .
  data MV_GENMOD_GRP type CHAR30 .
  data MV_GROUPS_FILLED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_BUFFER_UPD_DATS type SYDATUM .
  constants GC_TEXT_SEPARATOR type STRING value '/' ##NO_TEXT.
  constants GC_METADATA_TECHNICAL_FIELD type STRING value 'TF' ##NO_TEXT.
  constants GC_METADATA_BUSINESS_FIELD type STRING value 'BF' ##NO_TEXT.
  constants GC_ADDITIONAL_FIELD_COMPREL_UI type STRING value 'ADDITIONAL_FIELD_COMPREL_UI' ##NO_TEXT.
  constants GC_ADDITIONAL_FIELD_REF_QTY_UI type STRING value 'ADDITIONAL_FIELD_REF_QTY_UI' ##NO_TEXT.
  constants GC_META_SPEC_ID type STRING value 'META_SPEC_ID' ##NO_TEXT.
  constants GC_META_INSTANCE type STRING value 'META_INSTANCE' ##NO_TEXT.
  constants GC_META_SORT type STRING value 'META_SORT' ##NO_TEXT.
  constants GC_META_USAGE type STRING value 'META_USAGE' ##NO_TEXT.
  constants GC_TECH_NODE_NAME_INSTANCES type /PLMB/SPI_NODE_NAME value 'INSTANCES' ##NO_TEXT.
  constants GC_COMPONENT_NAME_RELATION type ABAP_COMPNAME value '__STDVAI_RELATION' ##NO_TEXT.
  constants GC_COMPONENT_NAME_SORTSEQ type ABAP_COMPNAME value '__STDVAI_SORT' ##NO_TEXT.
  constants GC_COMPONENT_NAME_USAGE type ABAP_COMPNAME value '__USAGE' ##NO_TEXT.
  constants GC_MULTIVALUE_SEPARATOR type STRING value ';' ##NO_TEXT.
  constants GC_TAB_NAME_LIST type STRING value 'LIST' ##NO_TEXT.
  constants GC_TAB_NAME_COMP type STRING value 'COMP' ##NO_TEXT.
  class-data MO_SPI_CONNECTOR_SPC type ref to /PLMB/IF_SPI_APPL_ACCESS .
  class-data MO_SPI_COLLECTOR_SPC type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT .
  class-data MO_SPI_METADATA_SPC type ref to /PLMB/IF_SPI_METADATA_OUTPUT .
  class-data MO_SPI_CONNECTOR_RSP_SP type ref to /PLMB/IF_SPI_APPL_ACCESS .
  class-data MO_SPI_COLLECTOR_RSP_SP type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT .
  class-data MO_SPI_METADATA_RSP_SP type ref to /PLMB/IF_SPI_METADATA_OUTPUT .
  class-data MO_SPI_CONNECTOR_EXP type ref to /PLMB/IF_SPI_APPL_ACCESS .
  class-data MO_SPI_COLLECTOR_EXP type ref to /PLMB/IF_SPI_COLLECTOR_OUTPUT .
  class-data MO_SPI_METADATA_EXP type ref to /PLMB/IF_SPI_METADATA_OUTPUT .
  data MV_KEY_DATE type RMSAE_GPDATE .

  methods DESERIALIZE_SELECTION_XML
    importing
      !IV_SELECTION type STRING
    exporting
      !ET_SELECTION type /PLMB/T_SPC_EXP_PTREE_SELECT .
  methods GET_DATA_AND_DEFINITION
    importing
      !IT_SPC_ID type /PLMB/T_SPC_ID_SP
      !IT_SELECTION type /PLMB/T_SPC_EXP_PTREE_SELECT
      !IV_NUTR_GROUP type CHAR30
      !IV_DIET_GROUP type CHAR30
      !IV_ALLERG_GRP type CHAR30
      !IV_RELIG_GRP type CHAR30
      !IV_GENMOD_GRP type CHAR30
    exporting
      !ET_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !ET_TABLE_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
  methods GET_TABLE_DEFINITION_SECTION
    importing
      !IV_TABLE_NO type INT4
    returning
      value(RT_TABLE_DEFINITION) type /PLMB/T_EXP_TABLE_DEFINITION .
  methods ADD_TABLE_DEFINITION_DEFAULTS
    importing
      !IV_TABLE_NO type INT4
      !IV_TABLE_TEXT type STRING
      !IV_ADD_COMPREL type BOOLE_D
      !IV_ADD_REF_QTY type BOOLE_D
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
    changing
      !CT_TABLE_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION .
  methods GET_VALUATION_DATA
    importing
      !IV_TABLE_TEXT_PREFIX type STRING
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_SPC_SUBID type /PLMB/SPC_SUBID
      !IV_SPC_RECNROOT type ESERECN
      !IV_TECHNICAL_ESTCAT type ESEESTCAT
      !IV_TECHNICAL_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_DESCRIPTION_ESTCAT type SEU_TEXT
      !IV_DESCRIPTION_NODE_NAME type STRING
      !IV_ESTTYPE type ESEESTTYPE
      !IT_NODE_ID type INDEX TABLE
      !IT_ADDITIONAL_FIELDS type TY_T_ADDITIONAL_FIELDS optional
      !IV_FILL_TABLE_DEFINITION type ABAP_BOOL
      !IV_NUTR_GROUP type CHAR30
      !IV_DIET_GROUP type CHAR30
      !IV_ALLERG_GRP type CHAR30
      !IV_RELIG_GRP type CHAR30
      !IV_GENMOD_GRP type CHAR30
    exporting
      !ET_VAL_ID type /PLMB/T_SPC_VAL_ID_SP
      !ET_ADDITIONAL_FIELDS type TY_T_ADDITIONAL_FIELDS
    changing
      !CV_TABLE_NO type INT4
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !CT_TABLE_DEFINITION type /PLMB/T_EXP_TABLE_DEFINITION
      !CT_MESSAGE type /PLMB/T_SPI_MSG
      !CT_TABLE_META_DATA type TY_T_TABLE_META_DATA .
  methods GET_NODE_ID_DATA_RTTI
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_TECHNICAL_ESTCAT type ESEESTCAT optional
      !IV_SPC_RECNROOT type ESERECN
    exporting
      !EO_NODE_ID_TABLE_RTTI type ref to CL_ABAP_TABLEDESCR
      !EO_NODE_DATA_TABLE_RTTI type ref to CL_ABAP_TABLEDESCR
      !EO_NODE_ID_STRUCT_RTTI type ref to CL_ABAP_STRUCTDESCR
      !EO_NODE_DATA_STRUCT_RTTI type ref to CL_ABAP_STRUCTDESCR
      !ES_COMPOSITION_INFO type TY_S_COMPOSITION_INFO
      !ET_COMPONENT_DESCRIPTOR type TY_T_COMPONENT_DESCRIPTOR
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
  methods GET_FRIENDLY_NODE_NAME
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
    returning
      value(RV_FRIENDLY_NODE_NAME) type STRING .
  methods CLEAR_BUFFERS .
  methods UPDATE_DEFINITION_BUFFER
    importing
      !IT_TABLE_DEFINTION type /PLMB/T_EXP_TABLE_DEFINITION .
  methods UPDATE_DATA_BUFFER
    importing
      !IT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  methods UPDATE_GROUPS_BUFFER
    importing
      !IV_NUTR_GROUP type CHAR30
      !IV_DIET_GROUP type CHAR30
      !IV_ALLERG_GRP type CHAR30
      !IV_RELIG_GRP type CHAR30
      !IV_GENMOD_GRP type CHAR30
      !IV_KEY_DATE type RMSAE_GPDATE optional .
  methods ACTION_CHANGE_STRUCTURE_DEF
    importing
      !IV_TECHNICAL_ESTCAT type ESEESTCAT
    exporting
      !EV_FAILED type BOOLE_D
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
  methods ACTION_GET_VAT_CUSTOMIZING
    exporting
      !EV_FAILED type BOOLE_D
      !ES_VATCUST type /PLMB/S_SPC_VAL_ACTION_VATCUST
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
  methods GET_ADDITIONAL_INFO_FIELDS
    exporting
      !ET_ADDITIONAL_INFO_FIELDS type /PLMB/T_EXP_ADDITIONAL_INFO_F .
  methods PROCESS_ADDITIONAL_INFO_FIELDS
    importing
      !IT_ADD_INFO type /PLMB/T_EXP_ADDITIONAL_INFO
    exporting
      !EV_NUTR_GROUP type CHAR30
      !EV_DIET_GROUP type CHAR30
      !EV_ALLERG_GRP type CHAR30
      !EV_RELIG_GRP type CHAR30
      !EV_GENMOD_GRP type CHAR30
      !EV_KEY_DATE type RMSAE_GPDATE .
  methods GET_ESTTYPE_BY_ESTCAT
    importing
      !IV_ESTCAT type ESEESTCAT
    returning
      value(RV_ESTTYPE) type ESEESTTYPE .
  methods GET_TAB_TYPE_BY_ESTCAT
    importing
      !IV_ESTCAT type ESEESTCAT
      !IV_SPC_RECNROOT type ESERECN
    exporting
      !EV_TAB_TYPE type STRING
      !EV_TAB_LABEL type STRING .
  methods GET_LAST_UPD_DATS
    importing
      !IT_SPC_ID type /PLMB/T_SPC_ID_SP
    exporting
      !EV_LAST_UPD_DATS type SYDATUM
      !EV_FAILED type BOOLE_D
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
  methods SPLIT_STRING
    importing
      !IV_STRING type ANY
    returning
      value(RV_STRING) type STRING .
  methods GET_FIELD_BUSINESS_OR_TECHN
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_FIELD_NAME type ABAP_COMPNAME
    returning
      value(RV_FIELD_TYPE) type STRING .
  methods GET_FRIENDLY_FIELD_NAME
    importing
      !IV_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IV_FIELD_NAME type ABAP_COMPNAME
    returning
      value(RV_FRIENDLY_FIELD_NAME) type STRING .
  methods CONVERT_TABLE
    changing
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  methods GET_CURRENT_TABLE_REFERENCE
    importing
      !IV_ENGINE_VALUE_ASSIGNMENT_TYP type ESEESTCAT
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IO_OUT_STRUCT type ref to CL_ABAP_STRUCTDESCR
      !IO_OUT_TABLE_TYPE type ref to CL_ABAP_TABLEDESCR
    exporting
      !EV_ENGINE_KEY_ROW_MAX type INT4
      !EV_TABLE_ALREADY_EXISTS type BOOLE_D
      !ER_STRUCT_REF type ref to DATA
      !ER_TABLE_REF type ref to DATA
    changing
      !CT_TABLE_META_DATA type TY_T_TABLE_META_DATA
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  methods UPDATE_MAX_ROW_NUMBER
    importing
      !IV_ENGINE_VALUE_ASSIGNMENT_TYP type ESEESTCAT
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
    changing
      !CT_TABLE_META_DATA type TY_T_TABLE_META_DATA
      !CT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT .
  methods TABLE_REFERENCE_EXISTS
    importing
      !IV_ENGINE_VALUE_ASSIGNMENT_TYP type ESEESTCAT
      !IV_TARGET_NODE_NAME type /PLMB/SPI_NODE_NAME
      !IT_TABLE_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !IT_TABLE_META_DATA type TY_T_TABLE_META_DATA
    returning
      value(RV_TABLE_ALREADY_EXISTS) type BOOLE_D .
  methods SET_KEY_DATE
    importing
      !IT_SPC_ID type /PLMB/T_SPC_ID_SP
      !IV_KEY_DATE type RMSAE_GPDATE
    exporting
      !EV_FAILED type BOOLE_D
    changing
      !CT_MESSAGE type /PLMB/T_SPI_MSG .
ENDCLASS.



CLASS /PLMI/CL_SPC_EXP_GEN_DATA_ABS IMPLEMENTATION.


METHOD /plmb/if_exp_generic_data~get_definition.

  DATA:
*--------------------------------------------------------------------*
*       SelectionFilter for checkbox selection
*--------------------------------------------------------------------*
        lt_selection        TYPE /plmb/t_spc_exp_ptree_select,


*--------------------------------------------------------------------*
*       Temporary storage for data and definition
*--------------------------------------------------------------------*
        lt_table_data       TYPE /plmb/t_exp_table_data_export,
        lt_table_definition TYPE /plmb/t_exp_table_definition,


*--------------------------------------------------------------------*
*       Input object handling
*--------------------------------------------------------------------*
        lv_object           TYPE /plmb/gos_internal_key,
        lt_spc_id           TYPE /plmb/t_spc_id_sp,
        ls_spc_id           TYPE /plmb/s_spc_id_sp,


*--------------------------------------------------------------------*
*       Message handling
*--------------------------------------------------------------------*
        lt_message          TYPE /plmb/t_spi_msg,
        lv_severity         TYPE /plmb/spi_msg_severity,
        lv_failed           TYPE boole_d,


*--------------------------------------------------------------------*
*       Last update date handling
*--------------------------------------------------------------------*
        lv_last_upd_dats    TYPE sydatum,


*--------------------------------------------------------------------*
*       Additional Info Fields
*--------------------------------------------------------------------*
        lv_key_date         TYPE rmsae_gpdate,
        lv_nutr_group       TYPE char30,
        lv_diet_group       TYPE char30,
        lv_allerg_grp       TYPE char30,
        lv_relig_grp        TYPE char30,
        lv_genmod_grp       TYPE char30.


  CLEAR et_table_definition.
  CLEAR et_table_definition_ui.


*--------------------------------------------------------------------*
* Check number of objects
*--------------------------------------------------------------------*
  me->check_number_of_objects(
    EXPORTING
      it_objects    = it_objects
      iv_variant_id = iv_variant_id
    IMPORTING
      ev_failed     = lv_failed
    CHANGING
      ct_message    = ct_message
      cv_severity   = cv_severity
  ).
  IF lv_failed = abap_true.
    RETURN.
  ENDIF.


*--------------------------------------------------------------------*
* Process input table - it is sure that IT_OBJECTS is filled
*--------------------------------------------------------------------*
  IF it_objects IS NOT INITIAL.
    LOOP AT it_objects INTO lv_object.
      /plmb/cl_gos_cnv_tools=>split_intern_to_key(
        EXPORTING
          iv_internal_key = lv_object    " Internal key
        IMPORTING
          es_key          = ls_spc_id    " Key structure
      ).
      APPEND ls_spc_id TO lt_spc_id.
    ENDLOOP.
  ELSE.
*--------------------------------------------------------------------*
* Return if there is no input object list
*--------------------------------------------------------------------*
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Process Additional Info
*--------------------------------------------------------------------*
  me->process_additional_info_fields(
    EXPORTING
      it_add_info   = it_add_info    " Additional Information for Download
    IMPORTING
      ev_nutr_group = lv_nutr_group
      ev_diet_group = lv_diet_group
      ev_allerg_grp = lv_allerg_grp
      ev_relig_grp  = lv_relig_grp
      ev_genmod_grp = lv_genmod_grp
      ev_key_date   = lv_key_date
  ).

*--------------------------------------------------------------------*
* Set key date in EH&S BO                                     "2179985
*--------------------------------------------------------------------*
  me->set_key_date(
    EXPORTING
      it_spc_id   = lt_spc_id
      iv_key_date = lv_key_date
    IMPORTING
      ev_failed   = lv_failed
    CHANGING
      ct_message  = ct_message
  ).

  IF lv_failed = abap_true.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Last update date handling
*--------------------------------------------------------------------*
  me->get_last_upd_dats(
    EXPORTING
      it_spc_id        = lt_spc_id
    IMPORTING
      ev_last_upd_dats = lv_last_upd_dats    " Current Date of Application Server
      ev_failed        = lv_failed
    CHANGING
      ct_message       = ct_message    " Message
  ).
  IF lv_failed = abap_true.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Check buffered selection
*--------------------------------------------------------------------*
  IF me->mv_selection_filled        = abap_true     AND " if there is selection buffer and
     me->mv_selection               = iv_selection  AND " it is the same as the input and
     me->mv_objects_filled          = abap_true     AND " if there is objects buffer and
     me->mt_objects[]               = it_objects[]  AND " it is the same as the input and
     me->mv_groups_filled           = abap_true     AND " groups buffer is filled and
     me->mv_allerg_grp              = lv_allerg_grp AND " it is the same as the input and
     me->mv_diet_group              = lv_diet_group AND
     me->mv_genmod_grp              = lv_genmod_grp AND
     me->mv_nutr_group              = lv_nutr_group AND
     me->mv_relig_grp               = lv_relig_grp  AND
     me->mv_key_date                = lv_key_date   AND
     me->mv_table_definition_filled = abap_true     AND " table defintion is filled and
     me->mv_buffer_upd_dats        >= lv_last_upd_dats. " the buffer is newer than the last update date
    " return from buffer
    et_table_definition = me->mt_table_definition.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* in any other case:
*  1. clear definition buffer
*  2. fill definition buffer
*  3. return definition buffer
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Deserialize selection XML
*--------------------------------------------------------------------*
  me->deserialize_selection_xml(
    EXPORTING
      iv_selection = iv_selection
    IMPORTING
      et_selection = lt_selection
  ).


*--------------------------------------------------------------------*
* If there is no property to be selected - return
*--------------------------------------------------------------------*
  IF lt_selection IS INITIAL.
    RETURN.
  ENDIF.


*--------------------------------------------------------------------*
* Buffer selection XML and objects
*--------------------------------------------------------------------*
  me->mv_selection        = iv_selection.
  me->mv_selection_filled = abap_true.
  me->mt_objects[]        = it_objects[].
  me->mv_objects_filled   = abap_true.
  me->update_groups_buffer(
    EXPORTING
      iv_nutr_group = lv_nutr_group    " Selected Nutrient Group
      iv_diet_group = lv_diet_group    " Selected Diet Group
      iv_allerg_grp = lv_allerg_grp    " Selected Allergen Group
      iv_relig_grp  = lv_relig_grp     " Selected Religious Certificate Compliance Group
      iv_genmod_grp = lv_genmod_grp    " Selected Genetically Modified Ingredients Group
      iv_key_date   = lv_key_date
  ).


*--------------------------------------------------------------------*
* Clear definition buffer
*--------------------------------------------------------------------*
  me->clear_buffers( ).

*--------------------------------------------------------------------*
* Fill definition buffer
*--------------------------------------------------------------------*
  me->get_data_and_definition(
    EXPORTING
      it_spc_id           = lt_spc_id
      it_selection        = lt_selection
      iv_nutr_group       = me->mv_nutr_group
      iv_diet_group       = me->mv_diet_group
      iv_allerg_grp       = me->mv_allerg_grp
      iv_relig_grp        = me->mv_relig_grp
      iv_genmod_grp       = me->mv_genmod_grp
    IMPORTING
      et_table_data       = lt_table_data
      et_table_definition = lt_table_definition    " Table Definition
    CHANGING
      ct_message          = lt_message    " Message
  ).

*--------------------------------------------------------------------*
* Get severity and update CT_MESSAGE
*--------------------------------------------------------------------*
  CLEAR lv_severity.
  /plmi/cl_spc_message=>get_severity(
    EXPORTING
      it_message  = lt_message    " Message table
    CHANGING
      cv_severity = lv_severity    " Message severity
  ).
  /plmi/cl_spc_message=>add_messages(
    EXPORTING
      it_message = lt_message    " Messages that should be added to CT_MESSAGE
    CHANGING
      ct_message = ct_message    " Existing messages
  ).

*--------------------------------------------------------------------*
* On success - update buffers. Otherwise the buffers will not be changed
*--------------------------------------------------------------------*
  IF NOT ( lv_severity CA /plmi/cl_spc_message=>gc_sv_aex ).
    me->update_data_buffer( lt_table_data ).
    me->update_definition_buffer( lt_table_definition ).
  ENDIF.

*--------------------------------------------------------------------*
* Fill CV_SEVERITY
*--------------------------------------------------------------------*
  /plmi/cl_spc_message=>get_severity(
    EXPORTING
      it_message  = ct_message    " Message table
    CHANGING
      cv_severity = cv_severity    " Message severity
  ).


*--------------------------------------------------------------------*
* Error handling
*--------------------------------------------------------------------*
  IF cv_severity CA /plmi/cl_spc_message=>gc_sv_aex. "if there was an error, abort, or exception, clear buffer
    me->clear_buffers( ).
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Return definition buffer
*--------------------------------------------------------------------*
  et_table_definition = me->mt_table_definition.

ENDMETHOD.                    "/plmb/if_exp_generic_data~get_definition


METHOD /plmb/if_exp_generic_data~get_export_data.

  DATA:
*--------------------------------------------------------------------*
*         SelectionFilter for checkbox selection
*--------------------------------------------------------------------*
          lt_selection        TYPE /plmb/t_spc_exp_ptree_select,

*--------------------------------------------------------------------*
*         Temporary storage for data and definition
*--------------------------------------------------------------------*
          lt_table_data       TYPE /plmb/t_exp_table_data_export,
          lt_table_definition TYPE /plmb/t_exp_table_definition,

*--------------------------------------------------------------------*
*         Last update date handling
*--------------------------------------------------------------------*
          lv_last_upd_dats    TYPE sydatum,

*--------------------------------------------------------------------*
*         Input and SPI handling
*--------------------------------------------------------------------*
          lv_object           TYPE /plmb/gos_internal_key,
          ls_spc_id           TYPE /plmb/s_spc_id_sp,
          lt_spc_id           TYPE /plmb/t_spc_id_sp,

*--------------------------------------------------------------------*
*         Message handling
*--------------------------------------------------------------------*
          lt_message          TYPE /plmb/t_spi_msg,
          lv_severity         TYPE /plmb/spi_msg_severity,
          lv_failed           TYPE boole_d,

*--------------------------------------------------------------------*
*         Additional Info Fields
*--------------------------------------------------------------------*
          lv_key_date        TYPE rmsae_gpdate,
          lv_nutr_group      TYPE char30,
          lv_diet_group      TYPE char30,
          lv_allerg_grp      TYPE char30,
          lv_relig_grp       TYPE char30,
          lv_genmod_grp      TYPE char30.


  CLEAR et_table_data.


*--------------------------------------------------------------------*
* Check number of objects
*--------------------------------------------------------------------*
  me->check_number_of_objects(
    EXPORTING
      it_objects    = it_objects
      iv_variant_id = iv_variant_id
    IMPORTING
      ev_failed     = lv_failed
    CHANGING
      ct_message    = ct_message
      cv_severity   = cv_severity
  ).
  IF lv_failed = abap_true.
    RETURN.
  ENDIF.


*--------------------------------------------------------------------*
* Process input table
*--------------------------------------------------------------------*
  IF it_objects IS NOT INITIAL.
    LOOP AT it_objects INTO lv_object.
      /plmb/cl_gos_cnv_tools=>split_intern_to_key(
        EXPORTING
          iv_internal_key = lv_object    " Internal key
        IMPORTING
          es_key          = ls_spc_id    " Key structure
      ).
      APPEND ls_spc_id TO lt_spc_id.
    ENDLOOP.
  ELSE.
*--------------------------------------------------------------------*
*   If there is no input, return
*--------------------------------------------------------------------*
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Deserialize selection XML
*--------------------------------------------------------------------*
  me->deserialize_selection_xml(
    EXPORTING
      iv_selection = iv_selection    " Selection (serialized)
    IMPORTING
      et_selection = lt_selection    " Property Tree Selection (Data Download)
  ).

*--------------------------------------------------------------------*
* If there is no property to select - return
*--------------------------------------------------------------------*
  IF lt_selection IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Process Additional Info
*--------------------------------------------------------------------*
  me->process_additional_info_fields(
    EXPORTING
      it_add_info   = it_add_info    " Additional Information for Download
    IMPORTING
      ev_nutr_group = lv_nutr_group
      ev_diet_group = lv_diet_group
      ev_allerg_grp = lv_allerg_grp
      ev_relig_grp  = lv_relig_grp
      ev_genmod_grp = lv_genmod_grp
      ev_key_date   = lv_key_date
  ).

*--------------------------------------------------------------------*
* Set key date in EH&S BO                                     "2179985
*--------------------------------------------------------------------*
  me->set_key_date(
    EXPORTING
      it_spc_id   = lt_spc_id
      iv_key_date = lv_key_date
    IMPORTING
      ev_failed   = lv_failed
    CHANGING
      ct_message  = ct_message
  ).

  IF lv_failed = abap_true.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Last update date handling
*--------------------------------------------------------------------*
  me->get_last_upd_dats(
    EXPORTING
      it_spc_id        = lt_spc_id
    IMPORTING
      ev_last_upd_dats = lv_last_upd_dats    " Current Date of Application Server
      ev_failed        = lv_failed
    CHANGING
      ct_message       = ct_message    " Message
  ).
  IF lv_failed = abap_true.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Check buffered selection
*--------------------------------------------------------------------*
  IF me->mv_selection_filled = abap_true     AND
     me->mv_selection        = iv_selection  AND
     me->mv_objects_filled   = abap_true     AND
     me->mt_objects[]        = it_objects[]  AND
     me->mv_groups_filled    = abap_true     AND
     me->mv_allerg_grp       = lv_allerg_grp AND
     me->mv_diet_group       = lv_diet_group AND
     me->mv_genmod_grp       = lv_genmod_grp AND
     me->mv_nutr_group       = lv_nutr_group AND
     me->mv_key_date         = lv_key_date   AND
     me->mv_relig_grp        = lv_relig_grp.

*--------------------------------------------------------------------*
*   If there is buffered data -> return from buffer
*--------------------------------------------------------------------*
    IF me->mv_table_data_filled = abap_true AND
       me->mv_buffer_upd_dats >= lv_last_upd_dats. " if the buffer is newer than the last update date
      et_table_data = me->mt_table_data.
    ELSE.

      IF me->mv_table_definition_filled = abap_false. " if there is no defintion buffer - get definition and data

*--------------------------------------------------------------------*
*       Get definition and export data
*--------------------------------------------------------------------*
        me->get_data_and_definition(
          EXPORTING
            it_spc_id           = lt_spc_id    " Table Type for ID Structure of SpecUI
            it_selection        = lt_selection
            iv_nutr_group       = me->mv_nutr_group
            iv_diet_group       = me->mv_diet_group
            iv_allerg_grp       = me->mv_allerg_grp
            iv_relig_grp        = me->mv_relig_grp
            iv_genmod_grp       = me->mv_genmod_grp
          IMPORTING
            et_table_data       = lt_table_data    " Table Data for Exporting
            et_table_definition = lt_table_definition    " Table Definition
          CHANGING
            ct_message          = lt_message    " Message
        ).

*--------------------------------------------------------------------*
*       Get severity and update CT_MESSAGE
*--------------------------------------------------------------------*
        CLEAR lv_severity.
        /plmi/cl_spc_message=>get_severity(
          EXPORTING
            it_message  = lt_message    " Message table
          CHANGING
            cv_severity = lv_severity    " Message severity
        ).
        /plmi/cl_spc_message=>add_messages(
          EXPORTING
            it_message = lt_message    " Messages that should be added to CT_MESSAGE
          CHANGING
            ct_message = ct_message    " Existing messages
        ).

*--------------------------------------------------------------------*
*       On success - update buffers. Otherwise the buffers will not be changed
*--------------------------------------------------------------------*
        IF NOT ( lv_severity CA /plmi/cl_spc_message=>gc_sv_aex ).
          me->update_data_buffer( lt_table_data ).
          me->update_definition_buffer( lt_table_definition ).
        ENDIF.

      ELSE. "if there is definition buffer - only get table data

*--------------------------------------------------------------------*
*       Get export data only
*--------------------------------------------------------------------*
        me->get_data_and_definition(
          EXPORTING
            it_spc_id     = lt_spc_id    " Table Type for ID Structure of SpecUI
            it_selection  = lt_selection
            iv_nutr_group = me->mv_nutr_group
            iv_diet_group = me->mv_diet_group
            iv_allerg_grp = me->mv_allerg_grp
            iv_relig_grp  = me->mv_relig_grp
            iv_genmod_grp = me->mv_genmod_grp
          IMPORTING
            et_table_data = lt_table_data    " Table Data for Exporting
          CHANGING
            ct_message    = lt_message    " Message
        ).

*--------------------------------------------------------------------*
*       Get severity and update CT_MESSAGE
*--------------------------------------------------------------------*
        CLEAR lv_severity.
        /plmi/cl_spc_message=>get_severity(
          EXPORTING
            it_message  = lt_message    " Message table
          CHANGING
            cv_severity = lv_severity    " Message severity
        ).
        /plmi/cl_spc_message=>add_messages(
          EXPORTING
            it_message = lt_message    " Messages that should be added to CT_MESSAGE
          CHANGING
            ct_message = ct_message    " Existing messages
        ).

*--------------------------------------------------------------------*
*       On success - update data buffer. Otherwise the data buffer will not be changed
*--------------------------------------------------------------------*
        IF NOT ( lv_severity CA /plmi/cl_spc_message=>gc_sv_aex ).
          me->update_data_buffer( lt_table_data ).
        ENDIF.

      ENDIF.

      "return output
      et_table_data = me->mt_table_data.

    ENDIF.

*--------------------------------------------------------------------*
*   Fill CV_SEVERITY (ct_message already contains the new messages)
*--------------------------------------------------------------------*
    /plmi/cl_spc_message=>get_severity(
      EXPORTING
        it_message  = ct_message    " Message table
      CHANGING
        cv_severity = cv_severity    " Message severity
    ).

    "return
    RETURN.

  ENDIF.

*--------------------------------------------------------------------*
* in any other case:
*  1. clear definition buffer and data buffer
*  2. get export data
*  3. return export data
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Clear definition buffer and data buffer
*--------------------------------------------------------------------*
  me->clear_buffers( ).

*--------------------------------------------------------------------*
* Store selection, objects and groups
*--------------------------------------------------------------------*
  me->mv_selection        = iv_selection.
  me->mv_selection_filled = abap_true.
  me->mt_objects[]        = it_objects[].
  me->mv_objects_filled   = abap_true.
  me->update_groups_buffer(
    EXPORTING
      iv_nutr_group = lv_nutr_group    " Selected Nutrient Group
      iv_diet_group = lv_diet_group    " Selected Diet Group
      iv_allerg_grp = lv_allerg_grp    " Selected Allergen Group
      iv_relig_grp  = lv_relig_grp    " Selected Religious Certificate Compliance Group
      iv_genmod_grp = lv_genmod_grp    " Selected Genetically Modified Ingredients Group
      iv_key_date   = lv_key_date
  ).


*--------------------------------------------------------------------*
* Get definition and export data
*--------------------------------------------------------------------*
  me->get_data_and_definition(
    EXPORTING
      it_spc_id           = lt_spc_id    " Table Type for ID Structure of SpecUI
      it_selection        = lt_selection
      iv_nutr_group       = me->mv_nutr_group
      iv_diet_group       = me->mv_diet_group
      iv_allerg_grp       = me->mv_allerg_grp
      iv_relig_grp        = me->mv_relig_grp
      iv_genmod_grp       = me->mv_genmod_grp
    IMPORTING
      et_table_data       = lt_table_data    " Table Data for Exporting
      et_table_definition = lt_table_definition    " Table Definition
    CHANGING
      ct_message          = lt_message    " Message
  ).

*--------------------------------------------------------------------*
* Get severity and update CT_MESSAGE
*--------------------------------------------------------------------*
  CLEAR lv_severity.
  /plmi/cl_spc_message=>get_severity(
    EXPORTING
      it_message  = lt_message    " Message table
    CHANGING
      cv_severity = lv_severity    " Message severity
  ).
  /plmi/cl_spc_message=>add_messages(
    EXPORTING
      it_message = lt_message    " Messages that should be added to CT_MESSAGE
    CHANGING
      ct_message = ct_message    " Existing messages
  ).

*--------------------------------------------------------------------*
* On success - update buffers. Otherwise the buffers will not be changed
*--------------------------------------------------------------------*
  IF NOT ( lv_severity CA /plmi/cl_spc_message=>gc_sv_aex ).
    me->update_data_buffer( lt_table_data ).
    me->update_definition_buffer( lt_table_definition ).
  ENDIF.


  "return data
  et_table_data = me->mt_table_data.

*--------------------------------------------------------------------*
* Fill CV_SEVERITY
*--------------------------------------------------------------------*
  /plmi/cl_spc_message=>get_severity(
    EXPORTING
      it_message  = ct_message    " Message table
    CHANGING
      cv_severity = cv_severity    " Message severity
  ).

ENDMETHOD.                    "/plmb/if_exp_generic_data~get_export_data


METHOD /plmb/if_exp_generic_data~get_selection.

  "return selection
  ev_selection = me->mv_selection.

ENDMETHOD.                    "/plmb/if_exp_generic_data~get_selection


METHOD /plmb/if_exp_generic_data~set_selection.

  "if selection buffer is not the same as the input
  IF ( me->mv_selection_filled =  abap_true AND
       me->mv_selection        <> iv_selection ) OR
       me->mv_selection_filled =  abap_false.

    "set selection
    me->mv_selection = iv_selection.
    me->mv_selection_filled = abap_true.

    "clear buffers
    CLEAR me->mt_objects.
    me->mv_objects_filled = abap_false.
    me->clear_buffers( ).

  ENDIF.

ENDMETHOD.                    "/plmb/if_exp_generic_data~set_selection


METHOD action_change_structure_def.

  DATA:
*--------------------------------------------------------------------*
*       Dynamic handling of structure definition
*--------------------------------------------------------------------*
        ls_param_estcat TYPE /plmb/s_spc_val_action_estcat,


*--------------------------------------------------------------------*
*       Error handling
*--------------------------------------------------------------------*
        lv_failed       TYPE /plmb/spi_failed_ind,
        lt_messages     TYPE /plmb/t_spi_coll_message_node,
        ls_message      TYPE /plmb/s_spi_coll_message_node,
        ls_spi_message  TYPE /plmb/s_spi_msg.


  CLEAR ev_failed.

*--------------------------------------------------------------------*
* Call Action to Change structure definition if needed
* Because of dynamic metadata the structure definition of the
* valuation instance should be changed before calling retrieve.
*--------------------------------------------------------------------*
  ls_param_estcat-estcat = iv_technical_estcat.
  ls_param_estcat-is_property = abap_true.

  mo_spi_connector_spc->action(
    EXPORTING
      iv_node_name    = /plmb/if_spc_attr=>gc_node_valuation    " Node name
      iv_action_name  = /plmb/if_spc_attr=>gc_actions_val-change_structure_def    " Action name
      is_param        = ls_param_estcat    " Parameter for action (e. g. profile)
*     it_node_id      =     " Node ID to which action refers
    IMPORTING
      ev_failed       = lv_failed    " Failed indicator
*     et_index_failed = lt_index_failed_action    " Index of node ID for which no data is available
*     et_node_data    =     " Node ID and node data
*     eg_param        =     " Exporting parameters for action
  ).


*--------------------------------------------------------------------*
* Error handling
* Abort the process, return
*--------------------------------------------------------------------*
  IF lv_failed = abap_true.
*--------------------------------------------------------------------*
*   Get messages
*--------------------------------------------------------------------*
    mo_spi_collector_spc->get_messages(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation    " Node Name
*       iv_init_buffer =     " Remove exported messages from buffer
      IMPORTING
        et_messages    = lt_messages    " Message table
*       ev_severity    =     " Message Severity
    ).

    LOOP AT lt_messages INTO ls_message.
      MOVE-CORRESPONDING ls_message TO ls_spi_message.
      APPEND ls_spi_message TO ct_message.
    ENDLOOP.
    ev_failed = abap_true.
  ENDIF.

ENDMETHOD.


METHOD action_get_vat_customizing.

  DATA:
*--------------------------------------------------------------------*
*       Error handling
*--------------------------------------------------------------------*
          lv_failed               TYPE /plmb/spi_failed_ind,
          lt_messages             TYPE /plmb/t_spi_coll_message_node,
          ls_message              TYPE /plmb/s_spi_coll_message_node,
          ls_spi_message          TYPE /plmb/s_spi_msg,


*--------------------------------------------------------------------*
*       Output Table definition
*--------------------------------------------------------------------*
          ls_vatcust              TYPE /plmb/s_spc_val_action_vatcust.


  CLEAR: ev_failed,
         es_vatcust.


*--------------------------------------------------------------------*
* Get customizing for naming the fields
*--------------------------------------------------------------------*
  mo_spi_connector_spc->action(
    EXPORTING
      iv_node_name    = /plmb/if_spc_attr=>gc_node_valuation    " Node name
      iv_action_name  = /plmb/if_spc_attr=>gc_actions_val-get_vat_customizing    " Action name
*     is_param        =     " Parameter for action (e. g. profile)
*     it_node_id      =     " Node ID to which action refers
    IMPORTING
      ev_failed       = lv_failed    " Failed indicator
*     et_index_failed =     " Index of node ID for which no data is available
*     et_node_data    =     " Node ID and node data
      eg_param        = ls_vatcust    " Exporting parameters for action
  ).

*--------------------------------------------------------------------*
*   Error handling
*   Don't abort the process, but collect the messages and set the max severity
*--------------------------------------------------------------------*
  IF lv_failed = abap_true.
*--------------------------------------------------------------------*
*     Get messages
*     Severity will be filled later
*--------------------------------------------------------------------*
    mo_spi_collector_spc->get_messages(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_valuation    " Node Name
*       iv_init_buffer =     " Remove exported messages from buffer
      IMPORTING
        et_messages    = lt_messages    " Message table
*       ev_severity    =     " Message Severity
    ).

    LOOP AT lt_messages INTO ls_message.
      MOVE-CORRESPONDING ls_message TO ls_spi_message.
      APPEND ls_spi_message TO ct_message.
    ENDLOOP.
    ev_failed = abap_true.
  ELSE.
    es_vatcust = ls_vatcust.
  ENDIF.

ENDMETHOD.


METHOD add_table_definition_defaults.

  DATA: ls_definition TYPE /plmb/s_exp_table_definition.

  IF iv_table_no = 1.
    ls_definition-new_page       = abap_true.
    ls_definition-page_text      = text-002. "Property Tree
    ls_definition-table_no       = 0.
    ls_definition-nodedisplay    = abap_false.
    ls_definition-rowkey         = abap_false.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = space.
    ls_definition-fieldtext      = space.
    ls_definition-fieldtype_name = space.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.
    CLEAR ls_definition.
  ENDIF.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_false.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = space.
  ls_definition-fieldtext      = space.
  ls_definition-fieldtype_name = space.
  ls_definition-table_text     = iv_table_text.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_false.
  ls_definition-rowkey         = abap_false.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_key_col.
  ls_definition-fieldtext      = space.
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_key_col.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_false.
  ls_definition-rowkey         = abap_false.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_key_row.
  ls_definition-fieldtext      = space.
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_key_row.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_v_a_type.
  ls_definition-fieldtext      = text-004. "Value Assignment Type
  ls_definition-fieldtype_name = 'ESEESTCAT'.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc.
  ls_definition-fieldtext      = text-015. "Value Assignment Type Description
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_v_a_category.
  ls_definition-fieldtext      = text-017. "Value Assignment Category
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_node_name.
  ls_definition-fieldtext      = text-013. "Node Name
  ls_definition-fieldtype_name = '/PLMB/SPI_NODE_NAME'.     "#EC NOTEXT
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_node_name_desc.
  ls_definition-fieldtext      = text-016. "Node Description
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_datatype.
  ls_definition-fieldtext      = text-011. "Data Type
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_line_no.
  ls_definition-fieldtext      = text-012. "Line No.
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  ls_definition-new_page       = abap_false.
  ls_definition-page_text      = space.
  ls_definition-table_no       = iv_table_no.
  ls_definition-nodedisplay    = abap_true.
  ls_definition-rowkey         = abap_true.
  ls_definition-colkey         = abap_false.
  ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_obj_id.
  ls_definition-fieldtext      = text-003. "Specification
  ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
  ls_definition-table_text     = space.
  APPEND ls_definition TO ct_table_definition.

  IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation   OR
     iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
     iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
     iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
     iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
    ls_definition-new_page       = abap_false.
    ls_definition-page_text      = space.
    ls_definition-table_no       = iv_table_no.
    ls_definition-nodedisplay    = abap_true.
    ls_definition-rowkey         = abap_true.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_parent_line_no.
    ls_definition-fieldtext      = text-040. "Instance
    ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.

    ls_definition-new_page       = abap_false.
    ls_definition-page_text      = space.
    ls_definition-table_no       = iv_table_no.
    ls_definition-nodedisplay    = abap_true.
    ls_definition-rowkey         = abap_true.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq.
    ls_definition-fieldtext      = text-041. "Sort Sequence
    ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.

    ls_definition-new_page       = abap_false.
    ls_definition-page_text      = space.
    ls_definition-table_no       = iv_table_no.
    ls_definition-nodedisplay    = abap_true.
    ls_definition-rowkey         = abap_true.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = /plmb/if_exp_c=>gc_component_key-engine_meta_usage.
    ls_definition-fieldtext      = text-042. "Usage
    ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.
  ENDIF.

  IF iv_add_comprel = abap_true.
    ls_definition-new_page       = abap_false.
    ls_definition-page_text      = space.
    ls_definition-table_no       = iv_table_no.
    ls_definition-nodedisplay    = abap_true.
    ls_definition-rowkey         = abap_true.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = gc_additional_field_comprel_ui.
    ls_definition-fieldtext      = text-020. "Reference Value
    ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.
  ENDIF.

  IF iv_add_ref_qty = abap_true.
    ls_definition-new_page       = abap_false.
    ls_definition-page_text      = space.
    ls_definition-table_no       = iv_table_no.
    ls_definition-nodedisplay    = abap_true.
    ls_definition-rowkey         = abap_true.
    ls_definition-colkey         = abap_false.
    ls_definition-fieldname      = gc_additional_field_ref_qty_ui.
    ls_definition-fieldtext      = text-021. "Reference Value
    ls_definition-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
    ls_definition-table_text     = space.
    APPEND ls_definition TO ct_table_definition.
  ENDIF.

ENDMETHOD.                    "add_table_definition_defaults


METHOD class_constructor.

  " create SPI instance for PLM_SPC ABBID
  CALL METHOD /plmb/cl_spi_connector=>create_instance
    EXPORTING
      iv_abbid     = /plmb/if_abbid_c=>gc_spc
    IMPORTING
      eo_collector = mo_spi_collector_spc
      eo_connector = mo_spi_connector_spc
      eo_metadata  = mo_spi_metadata_spc.


  " create SPI instance for PLM_RSP_SP ABBID
  CALL METHOD /plmb/cl_spi_connector=>create_instance
    EXPORTING
      iv_abbid     = /plmb/if_spc_attr=>gc_abbid_rsp_spc
    IMPORTING
      eo_collector = mo_spi_collector_rsp_sp
      eo_connector = mo_spi_connector_rsp_sp
      eo_metadata  = mo_spi_metadata_rsp_sp.


  " create SPI instance for PLM_EXP ABBID
  CALL METHOD /plmb/cl_spi_connector=>create_instance
    EXPORTING
      iv_abbid     = /plmb/if_exp_c=>gc_abbid
    IMPORTING
      eo_collector = mo_spi_collector_exp
      eo_connector = mo_spi_connector_exp
      eo_metadata  = mo_spi_metadata_exp.

ENDMETHOD.


METHOD clear_buffers.

  CLEAR me->mt_table_data.
  CLEAR me->mt_table_definition.
  me->mv_table_data_filled = abap_false.
  me->mv_table_definition_filled = abap_false.
  CLEAR me->mv_buffer_upd_dats.

ENDMETHOD.                    "clear_buffers


METHOD convert_table.

  DATA: lt_table_data TYPE /plmb/t_exp_table_data_export,
        lv_table_no   TYPE int4.

  FIELD-SYMBOLS: <ls_table_data> TYPE /plmb/s_exp_table_data_export.

  LOOP AT ct_table_data ASSIGNING <ls_table_data>.
    lv_table_no = <ls_table_data>-table_no.
    me->convert_and_append_data(
      EXPORTING
        iv_table_no   = lv_table_no    " Natural Number
        ir_out_data   = <ls_table_data>-table_data    " Reference to Input Table to be Converted
      CHANGING
        ct_table_data = lt_table_data    " Table Data for Exporting
    ).
  ENDLOOP.

  CLEAR ct_table_data.
  ct_table_data = lt_table_data.

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

ENDMETHOD.                    "deserialize_selection_xml


METHOD get_additional_info_fields.

  DATA: lt_gos_type     TYPE /plmb/t_gos_otype_intkey,
        ls_gos_type     TYPE /plmb/s_gos_otype_intkey,
        lv_gos_type     TYPE /plmb/gos_object_type,
        lt_node_id      TYPE TABLE OF /plmb/s_exp_downld_param_sp_id,
        ls_node_id      TYPE /plmb/s_exp_downld_param_sp_id,
        lt_node_data_sp TYPE /plmb/t_exp_additional_info_f.

  CLEAR et_additional_info_fields.

  " Get the object keys to call the retrieve
  mo_spi_connector_exp->action(
    EXPORTING
      iv_node_name    = /plmb/cl_exp_mp=>gc_node_objects
      iv_action_name  = /plmb/cl_exp_mp=>gc_action_objects-get_current_gos_type
    IMPORTING
      et_node_data    = lt_gos_type ).

  IF lt_gos_type IS INITIAL.
    RETURN.
  ENDIF.

  READ TABLE lt_gos_type INTO ls_gos_type INDEX 1.
  ASSERT sy-subrc = 0.
  lv_gos_type = ls_gos_type-otype_name.

  ls_node_id-object_type = lv_gos_type.
  APPEND ls_node_id TO lt_node_id.

  " Call node: selection tree retrieve
  mo_spi_connector_exp->retrieve(
    EXPORTING
      iv_node_name        = /plmb/cl_exp_mp=>gc_node_download_parameters
      iv_target_node_name = /plmb/cl_exp_mp=>gc_node_additional_info
      it_node_id          = lt_node_id
    IMPORTING
      et_node_data        = lt_node_data_sp ).

  et_additional_info_fields = lt_node_data_sp.

ENDMETHOD.


METHOD get_current_table_reference.

  DATA: ls_table_meta_data TYPE ty_s_table_meta_data,
        ls_table_data      TYPE /plmb/s_exp_table_data_export.

  FIELD-SYMBOLS: <ls_table_meta_data> TYPE ty_s_table_meta_data,
                 <ls_table_data>      TYPE /plmb/s_exp_table_data_export.

  CLEAR: ev_engine_key_row_max,
         ev_table_already_exists,
         er_table_ref,
         er_struct_ref.

  READ TABLE ct_table_meta_data ASSIGNING <ls_table_meta_data>
    WITH KEY engine_value_assignment_type = iv_engine_value_assignment_typ
             target_node_name             = iv_target_node_name.
  IF sy-subrc = 0.

    READ TABLE ct_table_data ASSIGNING <ls_table_data>
      WITH KEY table_no = <ls_table_meta_data>-table_no.    "#EC WARNOK

    IF sy-subrc = 0.

      er_table_ref            = <ls_table_data>-table_data.
      er_struct_ref           = <ls_table_meta_data>-struct_ref.
      ev_engine_key_row_max   = <ls_table_meta_data>-engine_key_row_max.
      ev_table_already_exists = abap_true.

    ENDIF.

  ELSE.

    ASSERT io_out_table_type IS BOUND.
    CREATE DATA ls_table_data-table_data TYPE HANDLE io_out_table_type.
    ls_table_data-table_no = lines( ct_table_data ) + 1.

    ls_table_meta_data-engine_key_row_max           = 0.
    ls_table_meta_data-engine_value_assignment_type = iv_engine_value_assignment_typ.
    ls_table_meta_data-target_node_name             = iv_target_node_name.
    ls_table_meta_data-table_no                     = ls_table_data-table_no.
    ASSERT io_out_struct IS BOUND.
    CREATE DATA ls_table_meta_data-struct_ref TYPE HANDLE io_out_struct.

    APPEND ls_table_data TO ct_table_data.
    APPEND ls_table_meta_data TO ct_table_meta_data.

    er_table_ref            = ls_table_data-table_data.
    er_struct_ref           = ls_table_meta_data-struct_ref.
    ev_engine_key_row_max   = ls_table_meta_data-engine_key_row_max.
    ev_table_already_exists = abap_false.

  ENDIF.

ENDMETHOD.


METHOD get_data_and_definition.

  DATA:
*--------------------------------------------------------------------*
*       SelectionFilter for checkbox selection
*--------------------------------------------------------------------*
        lt_selection                TYPE /plmb/t_spc_exp_ptree_select,

*--------------------------------------------------------------------*
*       Input and SPI handling
*--------------------------------------------------------------------*
        lt_spc_id_temp              TYPE /plmb/t_spc_id_sp,
        ls_spc_id                   TYPE /plmb/s_spc_id_sp,

*--------------------------------------------------------------------*
*       Error and message handling
*--------------------------------------------------------------------*
        lv_failed                   TYPE /plmb/spi_failed_ind,
        lt_index_failed             TYPE /plmb/t_spi_rtr_index_failed,
        ls_spi_message              TYPE /plmb/s_spi_msg,
        lt_message                  TYPE /plmb/t_spi_coll_message_node,
        ls_message                  TYPE /plmb/s_spi_coll_message_node,
        lv_severity                 TYPE /plmb/spi_msg_severity,

*--------------------------------------------------------------------*
*       Property tree data
*--------------------------------------------------------------------*
        lt_spc_data_temp            TYPE /plmb/t_spc_bas_header_sp,
        ls_spc_data_temp            TYPE /plmb/s_spc_bas_header_sp,
        lt_prop_tree_data           TYPE /plmb/t_spc_bas_tree_sp,
        lt_prop_tree_id             TYPE /plmb/t_spc_bas_tree_id_sp,
        ls_prop_tree_id             TYPE /plmb/s_spc_bas_tree_id_sp,

*--------------------------------------------------------------------*
*       Property data (Value Assignment Type)
*--------------------------------------------------------------------*
        lt_prop_tree_node_data_temp TYPE /plmb/t_spc_bas_node_sp,

*--------------------------------------------------------------------*
*       Property instance values
*--------------------------------------------------------------------*
        lt_prop_tree_node_id        TYPE /plmb/t_spc_bas_node_id_sp,
        ls_prop_tree_node_id        TYPE /plmb/s_spc_bas_node_id_sp,

*--------------------------------------------------------------------*
*       Valuation Data
*--------------------------------------------------------------------*
        lt_val_id                   TYPE /plmb/t_spc_val_id_sp,
        lt_node_name                TYPE TABLE OF /plmb/spi_node_name,
        lv_node_name                TYPE /plmb/spi_node_name,
        lv_fill_table_definition    TYPE abap_bool VALUE abap_false,
        lv_esttype                  TYPE eseesttype,
        lt_processed_estcats        TYPE SORTED TABLE OF eseestcat WITH UNIQUE KEY table_line,
        lt_additional_fields        TYPE ty_t_additional_fields,
        lt_table_meta_data          TYPE ty_t_table_meta_data,

*--------------------------------------------------------------------*
*       Tabs for the Value Assignment Category
*--------------------------------------------------------------------*
        ls_spc_header_conf_id_sp   TYPE /plmb/s_spc_header_conf_id_sp,
        lt_spc_header_conf_id_sp   TYPE /plmb/t_spc_header_conf_id_sp,
        lt_spc_header_conf_sp      TYPE /plmb/t_spc_header_conf_sp,
        ls_spc_header_conf_sp_tabs TYPE /plmb/s_spc_header_conf_sp,

*--------------------------------------------------------------------*
*       Output Table definition
*       table numbering starts from 1 and the increment is 1
*--------------------------------------------------------------------*
        lv_table_no                 TYPE int4 VALUE 1
        .


  FIELD-SYMBOLS: <ls_selection>           TYPE /plmb/s_spc_exp_ptree_select,
                 <ls_prop_tree_data>      TYPE /plmb/s_spc_bas_tree_sp,
                 <ls_prop_tree_node_data> TYPE /plmb/s_spc_bas_node_sp.


  lt_selection = it_selection.

*--------------------------------------------------------------------*
* Clear exporting parameters
*--------------------------------------------------------------------*
  CLEAR et_table_data.
  CLEAR et_table_definition.


*--------------------------------------------------------------------*
* Check for inconsistent input data
*--------------------------------------------------------------------*
  ASSERT et_table_data IS REQUESTED.      "table data should be provided


*--------------------------------------------------------------------*
* Return if there is no input data
*--------------------------------------------------------------------*
  IF it_spc_id IS INITIAL.
    RETURN.
  ENDIF.


*--------------------------------------------------------------------*
* Initialize control flag
*--------------------------------------------------------------------*
  IF et_table_definition IS REQUESTED.
    lv_fill_table_definition = abap_true.
  ENDIF.

*--------------------------------------------------------------------*
* 1. Get List of Property Trees
*--------------------------------------------------------------------*
  LOOP AT it_spc_id INTO ls_spc_id.

    " clear already processed table
    CLEAR lt_processed_estcats.

    APPEND ls_spc_id TO lt_spc_id_temp.

*--------------------------------------------------------------------*
*   Get SubID
*--------------------------------------------------------------------*
    mo_spi_connector_spc->retrieve(
      EXPORTING
        iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header     " Node name
*       iv_target_node_name =     " Target node name
*       iv_lock             =     " Locking indicator
        it_node_id          = lt_spc_id_temp    " Node ID
      IMPORTING
        ev_failed           = lv_failed    " Failed indicator
        et_index_failed     = lt_index_failed   " Index of node ID for which no data is availab
        et_node_data        = lt_spc_data_temp    " Node ID and node data
*       et_node_id_rel      =     " Relationship between index of source and target node ID
    ).
    READ TABLE lt_spc_data_temp INTO ls_spc_data_temp INDEX 1.
    IF sy-subrc <> 0.
*--------------------------------------------------------------------*
*     Error handling
*     Abort the process
*--------------------------------------------------------------------*
      IF lv_failed = abap_true OR
         lt_index_failed IS NOT INITIAL.
*--------------------------------------------------------------------*
*       Get messages
*--------------------------------------------------------------------*
        mo_spi_collector_spc->get_messages(
          EXPORTING
            iv_node_name   = /plmb/if_spc_attr=>gc_node_basic_header    " Node Name
*           iv_init_buffer =     " Remove exported messages from buffer
          IMPORTING
            et_messages    = lt_message    " Message table
            ev_severity    = lv_severity    " Message Severity
        ).

        LOOP AT lt_message INTO ls_message.
          MOVE-CORRESPONDING ls_message TO ls_spi_message.
          APPEND ls_spi_message TO ct_message.
        ENDLOOP.
        IF lv_severity CA /plmi/cl_spc_message=>gc_sv_aex.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.


*--------------------------------------------------------------------*
*   Get List of Property Trees
*--------------------------------------------------------------------*
    mo_spi_connector_spc->retrieve(
      EXPORTING
        iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header     " Node name
        iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree_list     " Target node name
*       iv_lock             =     " Locking indicator
        it_node_id          = lt_spc_id_temp    " Node ID
      IMPORTING
        ev_failed           = lv_failed    " Failed indicator
        et_index_failed     = lt_index_failed   " Index of node ID for which no data is availab
        et_node_data        = lt_prop_tree_data    " Node ID and node data
*       et_node_id_rel      =     " Relationship between index of source and target node ID
    ).

*--------------------------------------------------------------------*
*   Error handling
*   Don't abort the process, but collect the messages
*--------------------------------------------------------------------*
    IF lv_failed = abap_true OR
       lt_index_failed IS NOT INITIAL.
*--------------------------------------------------------------------*
*     Get messages
*--------------------------------------------------------------------*
      mo_spi_collector_spc->get_messages(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_ptree_list    " Node Name
*         iv_init_buffer =     " Remove exported messages from buffer
        IMPORTING
          et_messages    = lt_message    " Message table
*         ev_severity    = lv_severity    " Message Severity
      ).

      LOOP AT lt_message INTO ls_message.
        MOVE-CORRESPONDING ls_message TO ls_spi_message.
        APPEND ls_spi_message TO ct_message.
      ENDLOOP.
    ENDIF.


*--------------------------------------------------------------------*
*   2. Get List of Properties within the Property Trees
*--------------------------------------------------------------------*
    LOOP AT lt_prop_tree_data ASSIGNING <ls_prop_tree_data>.

      "filter out unnecessary property trees
      IF lt_selection IS NOT INITIAL.
        READ TABLE lt_selection WITH KEY property_tree = <ls_prop_tree_data>-menid ASSIGNING <ls_selection> BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ELSE.
          "tolerate duplicate entries
          SORT <ls_selection>-value_assignment_types BY estcat ASCENDING.
          DELETE ADJACENT DUPLICATES FROM <ls_selection>-value_assignment_types COMPARING estcat.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING <ls_prop_tree_data> TO ls_prop_tree_id.
      APPEND ls_prop_tree_id TO lt_prop_tree_id.

      mo_spi_connector_spc->retrieve(
        EXPORTING
          iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree_list     " Node name
          iv_target_node_name = /plmb/if_spc_attr=>gc_node_ptree     " Target node name
          iv_lock             = abap_false    " Locking indicator
          it_node_id          = lt_prop_tree_id    " Node ID
        IMPORTING
          ev_failed           = lv_failed    " Failed indicator
          et_index_failed     = lt_index_failed    " Index of node ID for which no data is availab
          et_node_data        = lt_prop_tree_node_data_temp    " Node ID and node data
*         et_node_id_rel      =     " Relationship between index of source and target node ID
      ).


*--------------------------------------------------------------------*
*     3. Get Property data
*--------------------------------------------------------------------*
      " lt_prop_tree_node_data_temp may contain duplicates, but
      " we only consider distinct value assignment types

      LOOP AT lt_prop_tree_node_data_temp ASSIGNING <ls_prop_tree_node_data>
        WHERE leaf = abap_true. " only leaf nodes are considered

        " set up initial state of LT_NODE_NAME. document links is always there
        CLEAR lt_node_name.
        APPEND /plmb/if_spc_attr=>gc_node_doclink TO lt_node_name.

        " check if we already processed this estcat
        READ TABLE lt_processed_estcats TRANSPORTING NO FIELDS BINARY SEARCH WITH KEY table_line = <ls_prop_tree_node_data>-estcat.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        "filter out unnecessary property trees
        IF <ls_selection> IS NOT INITIAL AND
           <ls_selection>-value_assignment_types IS NOT INITIAL.
          READ TABLE <ls_selection>-value_assignment_types
            WITH KEY estcat = <ls_prop_tree_node_data>-estcat
            TRANSPORTING NO FIELDS
            BINARY SEARCH.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        " append the estcat to the processed table
        INSERT <ls_prop_tree_node_data>-estcat INTO TABLE lt_processed_estcats.


*--------------------------------------------------------------------*
*       Get Value Assignment Category for this Value Assignment Type
*--------------------------------------------------------------------*
        lv_esttype = me->get_esttype_by_estcat( iv_estcat = <ls_prop_tree_node_data>-estcat ).


*--------------------------------------------------------------------*
*       Get list of tabs for this value assignment category
*--------------------------------------------------------------------*
        CLEAR: lt_spc_header_conf_id_sp,
               lt_spc_header_conf_sp.

        " fill value assignment type as an input
        ls_spc_header_conf_id_sp-estcat = <ls_prop_tree_node_data>-estcat.
        ls_spc_header_conf_id_sp-recnroot = ls_spc_id-recn.
        APPEND ls_spc_header_conf_id_sp TO lt_spc_header_conf_id_sp.

        " Read the tabs to be shown from customizing
        mo_spi_connector_spc->action(
          EXPORTING
            iv_node_name   = /plmb/if_spc_attr=>gc_node_header_config
            iv_action_name = /plmb/if_spc_attr=>gc_actions_hdr_conf-get_spc_val_tabs
            it_node_id     = lt_spc_header_conf_id_sp
          IMPORTING
            et_node_data   = lt_spc_header_conf_sp ).

        " only one row is expected
        READ TABLE lt_spc_header_conf_sp INTO ls_spc_header_conf_sp_tabs INDEX 1.

        IF sy-subrc = 0.
          " read tabs, look for qualitative or quantitative
          LOOP AT ls_spc_header_conf_sp_tabs-val_tabs TRANSPORTING NO FIELDS
            WHERE tab = gc_tab_name_comp OR
                  tab = gc_tab_name_list OR
                  tab = /plmb/if_spc_attr=>gc_tab_names-quantitative OR
                  tab = /plmb/if_spc_attr=>gc_tab_names-qualitative.
            EXIT.
          ENDLOOP.
          " endloop sets sy-subrc to 0 if it was run at least once
          IF sy-subrc = 0.
            APPEND /plmb/if_spc_attr=>gc_node_composition TO lt_node_name.
          ENDIF.

          " check for sources
          READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
            WITH KEY estcat = <ls_prop_tree_node_data>-estcat
                        tab = 'SOURCE'                      "#EC WARNOK
            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND /plmb/if_spc_attr=>gc_node_source TO lt_node_name.
          ENDIF.

          " check for user defined texts
          READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
            WITH KEY estcat = <ls_prop_tree_node_data>-estcat
                        tab = 'TEXTS'                       "#EC WARNOK
            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND /plmb/if_spc_attr=>gc_node_longtext TO lt_node_name.
          ENDIF.
        ENDIF.


*--------------------------------------------------------------------*
*       Instances - we get back LT_VAL_ID
*--------------------------------------------------------------------*
        MOVE-CORRESPONDING <ls_prop_tree_node_data> TO ls_prop_tree_node_id.
        APPEND ls_prop_tree_node_id TO lt_prop_tree_node_id.

        CLEAR lt_val_id.

        me->get_valuation_data(
          EXPORTING
            iv_table_text_prefix     = <ls_prop_tree_node_data>-text && gc_text_separator
            iv_node_name             = /plmb/if_spc_attr=>gc_node_ptree    " Node Name
            iv_target_node_name      = /plmb/if_spc_attr=>gc_node_valuation    " Node Name
            iv_spc_subid             = ls_spc_data_temp-subid
            iv_spc_recnroot          = ls_spc_data_temp-recnroot
            iv_technical_estcat      = <ls_prop_tree_node_data>-estcat    " Value Assignment Type
            iv_technical_node_name   = gc_tech_node_name_instances
            iv_description_estcat    = <ls_prop_tree_node_data>-text
            iv_description_node_name = text-001 && ''
            iv_esttype               = lv_esttype
            it_node_id               = lt_prop_tree_node_id
            iv_fill_table_definition = lv_fill_table_definition
            iv_nutr_group            = iv_nutr_group
            iv_diet_group            = iv_diet_group
            iv_allerg_grp            = iv_allerg_grp
            iv_relig_grp             = iv_relig_grp
            iv_genmod_grp            = iv_genmod_grp
          IMPORTING
            et_val_id                = lt_val_id
            et_additional_fields     = lt_additional_fields
          CHANGING
            cv_table_no              = lv_table_no    " Natural Number
            ct_table_data            = et_table_data    " Table Data for Exporting
            ct_table_definition      = et_table_definition    " Table Definition
            ct_message               = ct_message    " Message
            ct_table_meta_data       = lt_table_meta_data
        ).

        CLEAR lt_prop_tree_node_id.

*--------------------------------------------------------------------*
*       Usage, Composition, Source - we used LT_VAL_ID as input
*--------------------------------------------------------------------*
        IF lt_val_id IS NOT INITIAL.                           "2426873
        LOOP AT lt_node_name INTO lv_node_name.

          "get data
          me->get_valuation_data(
            EXPORTING
              iv_table_text_prefix     = <ls_prop_tree_node_data>-text && gc_text_separator
              iv_node_name             = /plmb/if_spc_attr=>gc_node_valuation    " Node Name
              iv_target_node_name      = lv_node_name    " Node Name
              iv_spc_subid             = ls_spc_data_temp-subid
              iv_spc_recnroot          = ls_spc_data_temp-recnroot
              iv_technical_estcat      = <ls_prop_tree_node_data>-estcat    " Value Assignment Type
              iv_technical_node_name   = lv_node_name
              iv_description_estcat    = <ls_prop_tree_node_data>-text
              iv_description_node_name = me->get_friendly_node_name( lv_node_name )
              iv_esttype               = lv_esttype
              it_node_id               = lt_val_id    " Specification-UI: ID-Structure for Valuations
              it_additional_fields     = lt_additional_fields
              iv_fill_table_definition = lv_fill_table_definition
              iv_nutr_group            = iv_nutr_group
              iv_diet_group            = iv_diet_group
              iv_allerg_grp            = iv_allerg_grp
              iv_relig_grp             = iv_relig_grp
              iv_genmod_grp            = iv_genmod_grp
            CHANGING
              cv_table_no              = lv_table_no    " Natural Number
              ct_table_data            = et_table_data    " Table Data for Exporting
              ct_table_definition      = et_table_definition    " Table Definition
              ct_message               = ct_message    " Message
              ct_table_meta_data       = lt_table_meta_data
          ).

        ENDLOOP.
        ENDIF.                                                 "2426873

      ENDLOOP. "loop at properies

      CLEAR ls_prop_tree_id.
      CLEAR lt_prop_tree_id.
    ENDLOOP.

    CLEAR lt_spc_id_temp.
    CLEAR lt_prop_tree_data.
  ENDLOOP.


*--------------------------------------------------------------------*
* Convert data table to the final format (XSTRING if needed)
*--------------------------------------------------------------------*
  me->convert_table(
    CHANGING
      ct_table_data = et_table_data
  ).

ENDMETHOD.                    "get_data_and_definition


METHOD get_esttype_by_estcat.

* Translate the Value Assignment Type to the Value Assignment Category
  SELECT SINGLE esttype FROM tcg11
    INTO rv_esttype
    WHERE estcat = iv_estcat.
  IF sy-subrc <> 0.
    CLEAR rv_esttype.
  ENDIF.

ENDMETHOD.


METHOD get_field_business_or_techn.

  CASE iv_node_name.
    WHEN /plmb/if_spc_attr=>gc_node_composition.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'COMPREL' OR                                   "#EC NOTEXT
             'RECNTVA' OR                                   "#EC NOTEXT
             'VALFR' OR                                     "#EC NOTEXT
             'VALTO' OR                                     "#EC NOTEXT
             'RATING' OR                                    "#EC NOTEXT
             'VALIDITY_AREA' OR                             "#EC NOTEXT
             'USAGE_STR' OR                                 "#EC NOTEXT
             'DIMID'.                                       "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_rsp_quant_li.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'GRP_SUBID' OR                                 "#EC NOTEXT
             'DIMID' OR                                     "#EC NOTEXT
             'SUBCAT' OR                                    "#EC NOTEXT
             'RATING' OR                                    "#EC NOTEXT
             'VALIDITY_AREA' OR                             "#EC NOTEXT
             'INSTANCE_NO' OR                               "#EC NOTEXT
             'USAGE_STR' OR                                 "#EC NOTEXT
             'COMPEXCVAL_TEMPL' OR                          "#EC NOTEXT
             'COMPAVGTXT_TEMPL' OR                          "#EC NOTEXT
             'COMPEXP_TEMPL' OR                             "#EC NOTEXT
             'COMPEXCVALNAM_TEMPL'.                         "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_rsp_qual_li.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'GRP_SUBID' OR                                 "#EC NOTEXT
             'DIET_LIMIT_QTY' OR                            "#EC NOTEXT
             'DIET_LIMIT_UNIT' OR                           "#EC NOTEXT
             'DIET_LIMIT_UNIT_STEXT' OR                     "#EC NOTEXT
             'SUBCAT' OR                                    "#EC NOTEXT
             'RATING' OR                                    "#EC NOTEXT
             'VALIDITY_AREA' OR                             "#EC NOTEXT
             'INSTANCE_NO' OR                               "#EC NOTEXT
             'USAGE_STR' OR                                 "#EC NOTEXT
             'ADDITIONAL_FIELD_REF_QTY_UI' OR               "#EC NOTEXT
             'COMPEXCVAL_TEMPL' OR                          "#EC NOTEXT
             'COMPAVGTXT_TEMPL' OR                          "#EC NOTEXT
             'COMPEXP_TEMPL' OR                             "#EC NOTEXT
             'COMPEXCVALNAM_TEMPL'.                         "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_specification_listing.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'RECNTVA' OR                                   "#EC NOTEXT
             'VALFR' OR                                     "#EC NOTEXT
             'VALTO' OR                                     "#EC NOTEXT
             'RATING' OR                                    "#EC NOTEXT
             'VALIDITY_AREA' OR                             "#EC NOTEXT
             'USAGE_STR'.                                   "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_doclink.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'LTXTFLG' OR                                   "#EC NOTEXT
             'LONG_TEXT' OR                                 "#EC NOTEXT
             'NAMEMST' OR                                   "#EC NOTEXT
             'RECNMST' OR                                   "#EC NOTEXT
             'OBJTYPE' OR                                   "#EC NOTEXT
             'USAGE_STR' OR                                 "#EC NOTEXT
             'DOKNR' OR                                     "#EC NOTEXT
             'DOKVR' OR                                     "#EC NOTEXT
             'DOKTL' OR                                     "#EC NOTEXT
             'DOKAR'.                                       "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_longtext.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'NAMEMST' OR                                   "#EC NOTEXT
             'RECNMST' OR                                   "#EC NOTEXT
             'OBJTYPE' OR                                   "#EC NOTEXT
             'DOKNR' OR                                     "#EC NOTEXT
             'DOKVR' OR                                     "#EC NOTEXT
             'DOKTL' OR                                     "#EC NOTEXT
             'DOKAR' OR                                     "#EC NOTEXT
             'USAGE_STR' OR                                 "#EC NOTEXT
             'LONG_TEXT'.                                   "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_new_val_usg.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'USG_TYPE' OR                                  "#EC NOTEXT
             'NAMEMST' OR                                   "#EC NOTEXT
             'RECNMST' OR                                   "#EC NOTEXT
             'PARENT' OR                                    "#EC NOTEXT
             'EXPANDED' OR                                  "#EC NOTEXT
             'LEAF' OR                                      "#EC NOTEXT
             'CHILD_LOADED' OR                              "#EC NOTEXT
             'IMG_SOURCE' OR                                "#EC NOTEXT
             'MASTER_COLUMN' OR                             "#EC NOTEXT
             'RVA_ID' OR                                    "#EC NOTEXT
             'RVA_TEXT' OR                                  "#EC NOTEXT
             'TREEROW_ID' OR                                "#EC NOTEXT
             'RVLTYPE_ID' OR                                "#EC NOTEXT
             'RVLTYPENAM_TEXT'.                             "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_source.
      CASE iv_field_name.
        WHEN 'RECN' OR                                      "#EC NOTEXT
             'ACTN' OR                                      "#EC NOTEXT
             'RECNROOT' OR                                  "#EC NOTEXT
             'RECNPARENT' OR                                "#EC NOTEXT
             'ESTCAT' OR                                    "#EC NOTEXT
             'RECN_VP' OR                                   "#EC NOTEXT
             'ACTN_VP' OR                                   "#EC NOTEXT
             'OBJTYPE'.                                     "#EC NOTEXT
          rv_field_type = gc_metadata_technical_field.
        WHEN OTHERS.
          rv_field_type = gc_metadata_business_field.
      ENDCASE.
    WHEN OTHERS.
      CLEAR rv_field_type.
  ENDCASE.

ENDMETHOD.


METHOD get_friendly_field_name.

  CLEAR rv_friendly_field_name.

  CASE iv_node_name.
    WHEN /plmb/if_spc_attr=>gc_node_composition.
      CASE iv_field_name.
        WHEN 'TOTALVALUE'.                                  "#EC NOTEXT
          rv_friendly_field_name = text-023. " Total Value
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_rsp_quant_li.
      CASE iv_field_name.
        WHEN 'MAINTAINED'.                                  "#EC NOTEXT
          rv_friendly_field_name = text-024. " Maintained
        WHEN 'UPDDAT'.                                      "#EC NOTEXT
          rv_friendly_field_name = text-025. " Last Changed On
        WHEN 'COMPEXCVAL_TEMPL'.                            "#EC NOTEXT
          rv_friendly_field_name = text-026. " Template Exception Value
        WHEN 'COMPAVGTXT_TEMPL'.                            "#EC NOTEXT
          rv_friendly_field_name = text-027. " Template Value
        WHEN 'COMPEXP_TEMPL'.                               "#EC NOTEXT
          rv_friendly_field_name = text-028. " Template Unit of Measure
        WHEN 'COMPEXCVALNAM_TEMPL'.                         "#EC NOTEXT
          rv_friendly_field_name = text-029. " Template Exception Value Name
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_rsp_qual_li.
      CASE iv_field_name.
        WHEN 'MAINTAINED'.                                  "#EC NOTEXT
          rv_friendly_field_name = text-024. " Maintained
        WHEN 'COMPEXCVALNAM'.                               "#EC NOTEXT
          rv_friendly_field_name = text-030. " Exception Value Desc.
        WHEN 'UPDDAT'.                                      "#EC NOTEXT
          rv_friendly_field_name = text-025. " Last Changed On
        WHEN 'COMPEXCVALNAM_TEMPL'.                         "#EC NOTEXT
          rv_friendly_field_name = text-026. " Template Exception Value
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_doclink.
      CASE iv_field_name.
        WHEN 'TEXTCAT'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-031. " Text Type
        WHEN 'HEADER'.                                      "#EC NOTEXT
          rv_friendly_field_name = text-032. " Document
        WHEN 'TEXTNAM'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-033. " Text Name
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_longtext.
      CASE iv_field_name.
        WHEN 'TEXTCAT'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-031. " Text Type
        WHEN 'LANGU'.                                       "#EC NOTEXT
          rv_friendly_field_name = text-034. " Language Key
        WHEN 'HEADER'.                                      "#EC NOTEXT
          rv_friendly_field_name = text-035. " Text
        WHEN 'LTXTFLG'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-036. " Long Text Exists
        WHEN 'TEXTNAM'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-033. " Text Name
      ENDCASE.
    WHEN /plmb/if_spc_attr=>gc_node_new_val_usg.
      CASE iv_field_name.
        WHEN 'RVLTYPE'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-037. " Category
        WHEN 'RVLTYPENAM'.                                  "#EC NOTEXT
          rv_friendly_field_name = text-038. " Category Description
        WHEN 'ACTVFLG'.                                     "#EC NOTEXT
          rv_friendly_field_name = text-039. " Active
      ENDCASE.
  ENDCASE.

ENDMETHOD.


METHOD get_friendly_node_name.

  CASE iv_node_name.
    WHEN /plmb/if_spc_attr=>gc_node_new_val_usg.
      rv_friendly_node_name = text-005. "Usage
    WHEN /plmb/if_spc_attr=>gc_node_composition.
      rv_friendly_node_name = text-006. "Composition
    WHEN /plmb/if_spc_attr=>gc_node_specification_listing.
      rv_friendly_node_name = text-019. "Specification Listing
    WHEN /plmb/if_spc_attr=>gc_node_source.
      rv_friendly_node_name = text-007. "Sources
    WHEN /plmb/if_spc_attr=>gc_node_longtext.
      rv_friendly_node_name = text-008. "User Defined Texts
    WHEN /plmb/if_spc_attr=>gc_node_doclink.
      rv_friendly_node_name = text-009. "Document Links
    WHEN /plmb/if_spc_attr=>gc_node_longtext_popup.
      rv_friendly_node_name = text-010. "User Defined Texts Long Texts
    WHEN /plmb/if_spc_attr=>gc_node_doclink_popup.
      rv_friendly_node_name = text-018. "Document Links Long Texts
  ENDCASE.

ENDMETHOD.                    "get_friendly_node_name


METHOD get_last_upd_dats.

  DATA:
*--------------------------------------------------------------------*
*       Retrieve Specification Header
*--------------------------------------------------------------------*
        lt_spc_id_temp   TYPE /plmb/t_spc_id_sp,
        lt_spc_data_temp TYPE /plmb/t_spc_bas_header_sp,
        ls_spc_data_temp TYPE /plmb/s_spc_bas_header_sp,
        lt_spc_bas_init  TYPE /plmb/t_spc_bas_init_id_sp,
        ls_spc_bas_init  TYPE /plmb/s_spc_bas_init_id_sp,

*--------------------------------------------------------------------*
*       Error and message handling
*--------------------------------------------------------------------*
        lv_failed        TYPE /plmb/spi_failed_ind,
        lt_index_failed  TYPE /plmb/t_spi_rtr_index_failed,
        ls_spi_message   TYPE /plmb/s_spi_msg,
        lt_message       TYPE /plmb/t_spi_coll_message_node,
        ls_message       TYPE /plmb/s_spi_coll_message_node,
        lv_severity      TYPE /plmb/spi_msg_severity.


  CLEAR: ev_failed,
         ev_last_upd_dats.

  APPEND LINES OF it_spc_id TO lt_spc_id_temp.

*--------------------------------------------------------------------*
*   Get SubID
*--------------------------------------------------------------------*
  mo_spi_connector_spc->retrieve(
    EXPORTING
      iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header     " Node name
*     iv_target_node_name =     " Target node name
*     iv_lock             =     " Locking indicator
      it_node_id          = lt_spc_id_temp    " Node ID
    IMPORTING
      ev_failed           = lv_failed    " Failed indicator
      et_index_failed     = lt_index_failed   " Index of node ID for which no data is availab
      et_node_data        = lt_spc_data_temp    " Node ID and node data
*     et_node_id_rel      =     " Relationship between index of source and target node ID
  ).
  IF lines( lt_spc_data_temp ) NE lines( lt_spc_id_temp ).
*--------------------------------------------------------------------*
*   Error handling
*   Abort the process
*--------------------------------------------------------------------*
    IF lv_failed = abap_true OR
       lt_index_failed IS NOT INITIAL.
*--------------------------------------------------------------------*
*     Get messages
*--------------------------------------------------------------------*
      mo_spi_collector_spc->get_messages(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_basic_header    " Node Name
*         iv_init_buffer =     " Remove exported messages from buffer
        IMPORTING
          et_messages    = lt_message    " Message table
          ev_severity    = lv_severity    " Message Severity
      ).

      LOOP AT lt_message INTO ls_message.
        MOVE-CORRESPONDING ls_message TO ls_spi_message.
        APPEND ls_spi_message TO ct_message.
      ENDLOOP.
      IF lv_severity CA /plmi/cl_spc_message=>gc_sv_aex.
        ev_failed = abap_true.
        RETURN.
      ENDIF.
    ENDIF.
  ELSE.
    " get latest last update date
    SORT lt_spc_data_temp BY upddat DESCENDING.
    READ TABLE lt_spc_data_temp INDEX 1 INTO ls_spc_data_temp.
    ev_last_upd_dats = ls_spc_data_temp-upddat.
  ENDIF.

ENDMETHOD.


METHOD get_node_id_data_rtti.

  DATA:
*--------------------------------------------------------------------*
*       Dynamic metadata reading
*--------------------------------------------------------------------*
        ls_component            TYPE abap_compdescr,
        ls_component_descriptor TYPE ty_s_component_descriptor,


*--------------------------------------------------------------------*
*       Decide which composition group is it
*--------------------------------------------------------------------*
        ls_actions              TYPE /plmb/s_rsp_spc_actions,
        lt_spc_qua_cfg_sp       TYPE TABLE OF /plmb/s_spc_qua_cfg_sp,
        ls_spc_qua_cfg_sp       TYPE /plmb/s_spc_qua_cfg_sp,


*--------------------------------------------------------------------*
*       Component Descriptor Table
*--------------------------------------------------------------------*
        lt_component_descr      TYPE /plmb/cl_exp_tools=>ty_t_component_descriptor,
        ls_component_descr      TYPE /plmb/cl_exp_tools=>ty_s_component_descriptor,


*--------------------------------------------------------------------*
*       Qualitative or Quantitative Composition
*       Action call for deciding this
*--------------------------------------------------------------------*
        ls_composition_info     TYPE ty_s_composition_info,


*--------------------------------------------------------------------*
*       Error handling
*--------------------------------------------------------------------*
        lv_failed               TYPE /plmb/spi_failed_ind,


*--------------------------------------------------------------------*
*      VAT Customizing
*--------------------------------------------------------------------*
        ls_vatcust              TYPE /plmb/s_spc_val_action_vatcust.


  FIELD-SYMBOLS:
*--------------------------------------------------------------------*
*      VAT Customizing
*--------------------------------------------------------------------*
        <ls_vat_customizing>    TYPE /plmb/s_spc_val_conf_sp.


  CLEAR: et_component_descriptor,
         eo_node_data_table_rtti,
         eo_node_id_table_rtti,
         es_composition_info.


*--------------------------------------------------------------------*
* Special handling of two cases:
*
*   In case of Valuation: Change Structure Definition
*
*
*   In case of Composition:
*
*     1. Decide whether it is a
*       - quantitative, or
*       - qualitative
*       composition
*
*     2. Decide, which kind of group is it
*       (there are 5 types:
*         - nutrient
*         - diet
*         - allergen
*         - religious certificate
*         - genetically modified ingredients)
*
*--------------------------------------------------------------------*
  CASE iv_node_name.

*   in case of valuation, change structure definition
    WHEN /plmb/if_spc_attr=>gc_node_valuation.

      ASSERT iv_technical_estcat IS SUPPLIED.
      me->action_change_structure_def(
        EXPORTING
          iv_technical_estcat = iv_technical_estcat    " Value Assignment Type
        IMPORTING
          ev_failed           = lv_failed
        CHANGING
          ct_message          = ct_message    " Message
      ).
      IF lv_failed = abap_true.
        CLEAR: eo_node_id_table_rtti,
               eo_node_data_table_rtti,
               eo_node_id_struct_rtti,
               eo_node_data_struct_rtti,
               et_component_descriptor.
        RETURN.
      ENDIF.


*   in case of valuation, fill variable ls_composition_info
    WHEN /plmb/if_spc_attr=>gc_node_composition.


      "-----
      " 1. decision ( nutrient / diet / allergen / religious certificate /
      "    genetically modified ingredients )
      " fill value assignment type as an input for this action
      ls_actions-estcat = iv_technical_estcat.

      " Read SUBCAT_GROUP for this Value Assignment Type
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name   = /plmb/if_spc_attr=>gc_node_rsp_config
          iv_action_name = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group
          is_param       = ls_actions
        IMPORTING
          et_node_data   = lt_spc_qua_cfg_sp
      ).

      " only one row is expected
      READ TABLE lt_spc_qua_cfg_sp INTO ls_spc_qua_cfg_sp INDEX 1.

      " fill output
      ls_composition_info-subcat_group = ls_spc_qua_cfg_sp-subcat_grp.

      "----
      " 2. decision ( qualitative / quantitative )
      " (this is only needed if 1. decision was not empty)
      "get Tab Type and Tab Label
      me->get_tab_type_by_estcat(
        EXPORTING
          iv_estcat       = iv_technical_estcat     " Value Assignment Type
          iv_spc_recnroot = iv_spc_recnroot
        IMPORTING
          ev_tab_type     = ls_composition_info-tab_type    " Tab Type (Qualitative / Quantitative / none)
          ev_tab_label    = ls_composition_info-tab_label   " Label for Calculation by Composition
      ).

  ENDCASE.


*--------------------------------------------------------------------*
* Get node details. In case of dynamic metadata we use SPI of PLM_SPC.
* In case of qualitative or quantitative composition we use SPI of PLM_RSP_SP.
* LS_COMPOSITION_INFO can be initial even in case of composition
*--------------------------------------------------------------------*
* we are not in qualitative nor in quantitative mode
  IF ls_composition_info IS INITIAL OR
     ls_composition_info-tab_type = gc_tab_name_comp.

    mo_spi_metadata_spc->get_node_details(
      EXPORTING
        iv_node_name            = iv_node_name
      IMPORTING
        eo_node_id_table_rtti   = eo_node_id_table_rtti
        eo_node_data_table_rtti = eo_node_data_table_rtti
    ).

  ELSE. "LS_COMPOSITION_INFO was filled

    CASE ls_composition_info-tab_type.

*     in quantitative composition use QUAL_LI node for retrieving the data
      WHEN /plmb/if_spc_attr=>gc_tab_names-quantitative.
        mo_spi_metadata_rsp_sp->get_node_details(
          EXPORTING
            iv_node_name            = /plmb/if_spc_attr=>gc_node_rsp_quant_li    " Node name
          IMPORTING
            eo_node_data_table_rtti = eo_node_data_table_rtti    " RTTI of table for node data
            eo_node_id_table_rtti   = eo_node_id_table_rtti    " RTTI of table for node ID
        ).

*     in quantitative composition use QUANT_LI node for retrieving the data
      WHEN /plmb/if_spc_attr=>gc_tab_names-qualitative.
        mo_spi_metadata_rsp_sp->get_node_details(
          EXPORTING
            iv_node_name            = /plmb/if_spc_attr=>gc_node_rsp_qual_li    " Node name
          IMPORTING
            eo_node_data_table_rtti = eo_node_data_table_rtti    " RTTI of table for node data
            eo_node_id_table_rtti   = eo_node_id_table_rtti    " RTTI of table for node ID
        ).

*     Specification Listing (LIST) case
      WHEN gc_tab_name_list.                                "#EC NOTEXT
        mo_spi_metadata_spc->get_node_details(
          EXPORTING
            iv_node_name            = /plmb/if_spc_attr=>gc_node_specification_listing
          IMPORTING
            eo_node_id_table_rtti   = eo_node_id_table_rtti
            eo_node_data_table_rtti = eo_node_data_table_rtti
        ).

    ENDCASE.

  ENDIF.


*--------------------------------------------------------------------*
* fill es_composition_info
*--------------------------------------------------------------------*
  es_composition_info = ls_composition_info.


*--------------------------------------------------------------------*
* Fill ID structure RTTI
*--------------------------------------------------------------------*
  IF eo_node_id_struct_rtti IS REQUESTED.
    eo_node_id_struct_rtti ?= eo_node_id_table_rtti->get_table_line_type( ).
  ENDIF.


*--------------------------------------------------------------------*
* Fill DATA structure RTTI
* to be able to fill et_component_descriptor we also need eo_node_data_struct_rtti
*--------------------------------------------------------------------*
  IF eo_node_data_struct_rtti IS REQUESTED OR
     et_component_descriptor  IS REQUESTED.
    eo_node_data_struct_rtti ?= eo_node_data_table_rtti->get_table_line_type( ).
  ENDIF.


*--------------------------------------------------------------------*
* Fill output component descriptor table
*
* This algorithm
*   - cannot handle nested DDIC structures (DDIC structure which
*     contain another DDIC structure (or table) as a component)
*   - can handle DDIC structures with includes
*   - can handle DDIC structures with components of type
*       - DDIC data type
*       - Predefined ABAP data type (e.g. CHAR, NUMC, DATS, ...)
*   - can handle dynamic metadata (- field descriptions are read from
*     customizing)
*   - for the fields which have no customizing, the DDIC descriptions
*     are used, or in the worst case the technical field name is the
*     description
*
* This algorithm fills IS_TECHNICAL field of ET_COMPONENT_DESCRIPTOR
* table based on customizing data.
*--------------------------------------------------------------------*
  IF et_component_descriptor IS REQUESTED.
    "these parameters need to be supplied in this case
    ASSERT iv_technical_estcat IS SUPPLIED.

    " Value assignment customizing - it is only needed if we are requesting the valuation node
    IF iv_node_name = /plmb/if_spc_attr=>gc_node_valuation.
      me->action_get_vat_customizing(
        IMPORTING
          ev_failed        = lv_failed
          es_vatcust       = ls_vatcust    " Structure for Valuation Instance Action - VAT Customizing
        CHANGING
          ct_message       = ct_message    " Message
      ).
      IF lv_failed = abap_true.
        CLEAR: eo_node_id_table_rtti,
               eo_node_data_table_rtti,
               eo_node_id_struct_rtti,
               eo_node_data_struct_rtti,
               et_component_descriptor.
        RETURN.
      ENDIF.
    ENDIF.

*--------------------------------------------------------------------*
*   Get Component Descriptor with the helper class
*--------------------------------------------------------------------*
    /plmb/cl_exp_tools=>get_component_descriptor(
      EXPORTING
        io_tabledescr           = eo_node_data_table_rtti    " Runtime Type Services
      IMPORTING
        et_component_descriptor = lt_component_descr
    ).
    LOOP AT lt_component_descr INTO ls_component_descr.
      ls_component_descriptor-name = ls_component_descr-name.
      ls_component_descriptor-typename = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      IF ls_component_descr-datatype IS NOT INITIAL.
        CASE ls_component_descr-datatype.
          WHEN /plmb/if_exp_c=>gc_component_type-dats.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-date.
            " set date type indicator
            ls_component_descriptor-is_date_type = abap_true.
          WHEN /plmb/if_exp_c=>gc_component_type-tims.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-time.
            " set time type indicator
            ls_component_descriptor-is_time_type = abap_true.
          WHEN /plmb/if_exp_c=>gc_component_type-unit.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-string.
            " set uom type indicator
            ls_component_descriptor-is_uom_type = abap_true.
          WHEN /plmb/if_exp_c=>gc_component_type-lang.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-string.
            " set language key type indicator
            ls_component_descriptor-is_language_key_type = abap_true.
          WHEN /plmb/if_exp_c=>gc_component_type-curr OR
               /plmb/if_exp_c=>gc_component_type-d16d OR
               /plmb/if_exp_c=>gc_component_type-d16r OR
               /plmb/if_exp_c=>gc_component_type-d16s OR
               /plmb/if_exp_c=>gc_component_type-d34d OR
               /plmb/if_exp_c=>gc_component_type-d34r OR
               /plmb/if_exp_c=>gc_component_type-d34s OR
               /plmb/if_exp_c=>gc_component_type-dec  OR
               /plmb/if_exp_c=>gc_component_type-fltp OR
               /plmb/if_exp_c=>gc_component_type-quan.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-number.
          WHEN /plmb/if_exp_c=>gc_component_type-int1 OR
               /plmb/if_exp_c=>gc_component_type-int2 OR
               /plmb/if_exp_c=>gc_component_type-int4 OR
               /plmb/if_exp_c=>gc_component_type-int8 OR
               /plmb/if_exp_c=>gc_component_type-numc.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-integer.
          WHEN OTHERS.
            " set type
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-string.
        ENDCASE.
      ELSE.
        " if it's not found in the DDIC table
        " set type to string
        ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-string.
      ENDIF.

      " set icon type for relation
      IF ls_component-name = gc_component_name_relation AND
         iv_node_name = /plmb/if_spc_attr=>gc_node_valuation.
        ls_component_descriptor-is_icon_type = abap_true.
      ENDIF.

      " fill component text based on VAT customizing or component type info
      READ TABLE ls_vatcust-vat_customizing ASSIGNING <ls_vat_customizing>
        WITH KEY estcat = iv_technical_estcat
                 atnam  = ls_component_descr-name.
      IF sy-subrc = 0.
        ls_component_descriptor-text = <ls_vat_customizing>-atbez.
        IF <ls_vat_customizing>-flg_is_no_single_value = abap_true.
          ls_component_descriptor-is_multiple = abap_true.
        ENDIF.
        ls_component_descriptor-is_technical = abap_false.
        CASE <ls_vat_customizing>-atfor.
          WHEN 'DATE'.
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-date.
            ls_component_descriptor-is_date_type = abap_true.
          WHEN 'TIME'.
            ls_component_descriptor-type = /plmb/if_exp_c=>gc_component_descr_type-time.
            ls_component_descriptor-is_time_type = abap_true.
        ENDCASE.
      ELSE.
        ls_component_descriptor-text = ls_component_descr-text.
        IF ls_component_descriptor-text IS INITIAL.
          ls_component_descriptor-text = ls_component_descr-name.
        ENDIF.
        ls_component_descriptor-is_technical = abap_true.
      ENDIF.

      APPEND ls_component_descriptor TO et_component_descriptor.
      CLEAR ls_component_descriptor.
    ENDLOOP.

  ENDIF.

ENDMETHOD.                    "get_node_id_data_rtti


METHOD get_table_definition_section.

  FIELD-SYMBOLS: <ls_table_definition> TYPE /plmb/s_exp_table_definition.

*--------------------------------------------------------------------*
* Buffer should be filled
*--------------------------------------------------------------------*
  ASSERT me->mv_table_definition_filled = abap_true.

  LOOP AT me->mt_table_definition ASSIGNING <ls_table_definition> WHERE table_no = iv_table_no.
    APPEND <ls_table_definition> TO rt_table_definition.
  ENDLOOP.

ENDMETHOD.                    "get_table_definition_section


METHOD get_tab_type_by_estcat.

  DATA: ls_spc_header_conf_id_sp   TYPE /plmb/s_spc_header_conf_id_sp,
        lt_spc_header_conf_id_sp   TYPE /plmb/t_spc_header_conf_id_sp,
        lt_spc_header_conf_sp      TYPE /plmb/t_spc_header_conf_sp,
        ls_spc_header_conf_sp_tabs TYPE /plmb/s_spc_header_conf_sp.


  " fill value assignment type as an input
  ls_spc_header_conf_id_sp-estcat = iv_estcat.
  ls_spc_header_conf_id_sp-recnroot = iv_spc_recnroot.
  APPEND ls_spc_header_conf_id_sp TO lt_spc_header_conf_id_sp.

* Read the tabs to be shown from customizing
  mo_spi_connector_spc->action(
    EXPORTING
      iv_node_name   = /plmb/if_spc_attr=>gc_node_header_config
      iv_action_name = /plmb/if_spc_attr=>gc_actions_hdr_conf-get_spc_val_tabs
      it_node_id     = lt_spc_header_conf_id_sp
    IMPORTING
      et_node_data   = lt_spc_header_conf_sp
  ).

  " only one row is expected
  READ TABLE lt_spc_header_conf_sp INTO ls_spc_header_conf_sp_tabs INDEX 1.

  " read tab IDs, look for qualitative or quantitative
  READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
    WITH KEY estcat = iv_estcat
                tab = /plmb/if_spc_attr=>gc_tab_names-quantitative "#EC WARNOK
    TRANSPORTING NO FIELDS.

  " we are in quantitative case
  IF sy-subrc = 0.
    ev_tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative.
    " we are not in quantitative case - check if we are in qualitative?
  ELSE.
    READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
      WITH KEY estcat = iv_estcat
                  tab = /plmb/if_spc_attr=>gc_tab_names-qualitative "#EC WARNOK
      TRANSPORTING NO FIELDS.
    "we are in qualitative case
    IF sy-subrc = 0.
      ev_tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative.
    ELSE. "otherwise check if it contains LIST
      READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
        WITH KEY estcat = iv_estcat
                    tab = gc_tab_name_list                  "#EC WARNOK
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        ev_tab_type = gc_tab_name_list.                     "#EC NOTEXT
      ELSE.
        READ TABLE ls_spc_header_conf_sp_tabs-val_tabs
          WITH KEY estcat = iv_estcat
                      tab = gc_tab_name_comp                "#EC WARNOK
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          ev_tab_type = gc_tab_name_comp.                   "#EC NOTEXT
        ELSE.
          CLEAR ev_tab_type.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  " get label for qualitative and quantitative
  IF ev_tab_label IS REQUESTED AND
   ( ev_tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
     ev_tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ).
    mo_spi_connector_spc->action(
    EXPORTING
      iv_node_name   = /plmb/if_spc_attr=>gc_node_header_config
      iv_action_name = /plmb/if_spc_attr=>gc_actions_hdr_conf-get_spc_val_labels
      is_param       = ls_spc_header_conf_id_sp
    IMPORTING
      et_node_data   = lt_spc_header_conf_sp ).
    READ TABLE lt_spc_header_conf_sp INTO ls_spc_header_conf_sp_tabs INDEX 1.
    ev_tab_label = ls_spc_header_conf_sp_tabs-val_tab_labels-com_label.
  ENDIF.

ENDMETHOD.


METHOD get_valuation_data.

  DATA:
*--------------------------------------------------------------------*
*       Dynamic handling of structure definition
*--------------------------------------------------------------------*
        lo_metadata_structure          TYPE REF TO cl_abap_tabledescr,
        lo_metadata_structure_line     TYPE REF TO cl_abap_structdescr,
        lo_metadata_id_structure       TYPE REF TO cl_abap_tabledescr,
        lo_metadata_id_structure_line  TYPE REF TO cl_abap_structdescr,
        lo_metadata_id_out_str         TYPE REF TO cl_abap_tabledescr,
        lo_metadata_id_out_str_line    TYPE REF TO cl_abap_structdescr,
        lt_component_descriptor        TYPE ty_t_component_descriptor,
        ls_component_descriptor        TYPE ty_s_component_descriptor,
        lr_valuation_data_tab          TYPE REF TO data,
        lr_valuation_data_tab_temp     TYPE REF TO data,
        lr_valuation_data_line         TYPE REF TO data,
        lr_valuation_id_tab            TYPE REF TO data,
        lr_valuation_id_tab_temp       TYPE REF TO data,
        lr_valuation_id_line           TYPE REF TO data,
        lr_valuation_id_out_tab        TYPE REF TO data,
        lr_valuation_id_out_line       TYPE REF TO data,
        lr_out_data_struct             TYPE REF TO data,
        lr_out_data_tab                TYPE REF TO data,


*--------------------------------------------------------------------*
*       Handle composition
*--------------------------------------------------------------------*
        ls_composition_info            TYPE ty_s_composition_info,
        lv_description_node_name       TYPE string,
        lv_technical_node_name         TYPE /plmb/spi_node_name,


*--------------------------------------------------------------------*
*       Handle field control
*--------------------------------------------------------------------*
        lt_properties                  TYPE /plmb/t_spi_coll_prpty_node,
        lt_header_properties           TYPE /plmb/t_spi_coll_prpty_node,
        lt_row_properties              TYPE ty_t_node_property,
        ls_row_property                TYPE ty_s_node_property,
        ls_property_line               TYPE /plmb/s_spi_coll_prpty_node,
        ls_property_hdr                TYPE /plmb/s_spi_coll_prpty_node,
        ls_property_hdr_prop           TYPE /plmb/s_spi_properties,
        ls_row_property_list           TYPE /plmb/s_spi_properties,
        lv_row_xstring                 TYPE /plmb/spi_xstring,
        lv_tabix                       TYPE syindex,
        lo_spi_collector_for_fieldctrl TYPE REF TO /plmb/if_spi_collector_output,
        lv_target_node_name_fieldctrl  TYPE /plmb/spi_node_name,
        lv_option                      TYPE /plmb/spi_prpty_option,
        ls_property                    TYPE /plmb/s_spi_properties,


*--------------------------------------------------------------------*
*       Output Table definition
*--------------------------------------------------------------------*
        ls_definition_int              TYPE /plmb/s_exp_table_definition,
        lt_definition_int              TYPE /plmb/t_exp_table_definition,
        lo_out_struct                  TYPE REF TO cl_abap_structdescr,
        lo_out_table_type              TYPE REF TO cl_abap_tabledescr,
        lr_out_data                    TYPE REF TO data,


*--------------------------------------------------------------------*
*       For output valuation ID table
*--------------------------------------------------------------------*
        ls_val_id                      TYPE /plmb/s_spc_val_id_sp,


*--------------------------------------------------------------------*
*       Handle Valuation Composition
*--------------------------------------------------------------------*
        ls_param                       TYPE /plmb/s_rsp_spc_actions,
        lv_qua_target_node_name        TYPE /plmb/spi_node_name,
        lv_qua_node_name               TYPE /plmb/spi_node_name,
        lv_qua_action_name             TYPE /plmb/spi_action_name,
        lv_qua_action_name_2           TYPE /plmb/spi_action_name,
        lv_target_node_name            TYPE /plmb/spi_node_name,


*--------------------------------------------------------------------*
*       Date conversion
*--------------------------------------------------------------------*
        lv_in_date                     TYPE dats,
        lv_in_time                     TYPE tims,
        lv_in_data                     TYPE string,
        lv_out_data                    TYPE string,
        lv_new_string                  TYPE string,

*--------------------------------------------------------------------*
*       Reference Value (DIMID)
*--------------------------------------------------------------------*
        ls_comprel                     TYPE /plmb/s_spc_fes_comprel,
        lt_comprel                     TYPE TABLE OF /plmb/s_spc_fes_comprel,
        lv_add_comprel                 TYPE boole_d,


*--------------------------------------------------------------------*
*       Reference Quantity
*--------------------------------------------------------------------*
        lv_add_ref_qty                 TYPE boole_d,
        lv_ref_qty_was_retrieved       TYPE boole_d,
        ls_param_ref_qty_text          TYPE /plmb/s_rsp_spc_actions,
        lv_cpara_id                    TYPE /plmb/rca_cpara_id,
        lt_node_data_ref_qty_text      TYPE TABLE OF /plmb/s_spc_qua_cfg_sp,
        ls_node_data_ref_qty_text      TYPE /plmb/s_spc_qua_cfg_sp,


*--------------------------------------------------------------------*
*       Component Description
*--------------------------------------------------------------------*
        lv_component_description       TYPE string,


*--------------------------------------------------------------------*
*       Special handling of Document Links -> Long Text and
*                           User Defined Texts -> Long Text
*--------------------------------------------------------------------*
        ls_id_longtext                 TYPE /plmb/s_spc_ltx_popup_id_sp,
        lt_id_longtext                 TYPE TABLE OF /plmb/s_spc_ltx_popup_id_sp,
        ls_data_longtext               TYPE /plmb/s_spc_ltx_popup_sp,
        lt_data_longtext_tmp           TYPE TABLE OF /plmb/s_spc_ltx_popup_sp,
        lt_data_longtext               TYPE TABLE OF /plmb/s_spc_ltx_popup_sp,
        lv_longtext_node_name          TYPE /plmb/spi_node_name,
        lv_longtext_target_node_name   TYPE /plmb/spi_node_name,


*--------------------------------------------------------------------*
*       Instance Numbering
*--------------------------------------------------------------------*
        lv_instance_number             TYPE int4 VALUE 0,
        lv_row_number                  TYPE int4 VALUE 0,
        lt_instance_number_rel         TYPE ty_t_instance_number_rel,
        ls_instance_number_rel         TYPE ty_s_instance_number_rel,
        ls_additional_fields           TYPE ty_s_additional_fields,


*--------------------------------------------------------------------*
*       Handling meta data table
*--------------------------------------------------------------------*
        lv_engine_key_row_max          TYPE int4,
        lv_table_already_exists        TYPE boole_d VALUE abap_false,


*--------------------------------------------------------------------*
*       Error handling
*--------------------------------------------------------------------*
        lv_failed                      TYPE /plmb/spi_failed_ind,
        lt_index_failed                TYPE /plmb/t_spi_rtr_index_failed,
        lt_messages                    TYPE /plmb/t_spi_coll_message_node,
        ls_message                     TYPE /plmb/s_spi_coll_message_node,
        ls_spi_message                 TYPE /plmb/s_spi_msg
        .


  FIELD-SYMBOLS:
*--------------------------------------------------------------------*
*       Handle field control
*--------------------------------------------------------------------*
        <ls_property>                  TYPE /plmb/s_spi_coll_prpty_node,
        <ls_property_list>             TYPE /plmb/s_spi_properties,


*--------------------------------------------------------------------*
*       Output Table definition
*--------------------------------------------------------------------*
        <lt_out_data>                  TYPE ANY TABLE,
        <ls_out_data>                  TYPE any,
        <ls_out_data_str>              TYPE any,
        <lv_out_data>                  TYPE any,
        <lv_out_spc_data>              TYPE any,


*--------------------------------------------------------------------*
*       Dynamic handling of structure definition
*--------------------------------------------------------------------*
        <node_data_table_rtti_tab>     TYPE INDEX TABLE,
        <node_data_table_rtti_tab_tmp> TYPE INDEX TABLE,
        <node_data_struct_rtti>        TYPE any,
        <node_id_table_rtti_tab>       TYPE INDEX TABLE,
        <node_id_table_rtti_tab_temp>  TYPE INDEX TABLE,
        <node_id_struct_rtti>          TYPE any,
        <node_id_out_table_rtti>       TYPE any,
        <node_id_out_table_rtti_tab>   TYPE INDEX TABLE,
        <ls_component_descriptor>      TYPE ty_s_component_descriptor
        .


*--------------------------------------------------------------------*
* Clear output parameter
*--------------------------------------------------------------------*
  CLEAR et_val_id.
  CLEAR et_additional_fields.


*--------------------------------------------------------------------*
* Store node description (this needed because it is changed in some cases)
*--------------------------------------------------------------------*
  lv_description_node_name = iv_description_node_name.


*--------------------------------------------------------------------*
* Store Node Name
*--------------------------------------------------------------------*
  lv_technical_node_name = iv_technical_node_name.


*--------------------------------------------------------------------*
* Store Target Node Name
*--------------------------------------------------------------------*
  lv_target_node_name = iv_target_node_name.


*--------------------------------------------------------------------*
* Get components and RTTI of data structure (output)
*--------------------------------------------------------------------*
  me->get_node_id_data_rtti(
    EXPORTING
      iv_node_name             = lv_target_node_name    " Node Name
      iv_technical_estcat      = iv_technical_estcat
      iv_spc_recnroot          = iv_spc_recnroot
    IMPORTING
      eo_node_id_table_rtti    = lo_metadata_id_out_str
      eo_node_id_struct_rtti   = lo_metadata_id_out_str_line
      eo_node_data_table_rtti  = lo_metadata_structure     " Runtime Type Services
      eo_node_data_struct_rtti = lo_metadata_structure_line    " Runtime Type Services
      es_composition_info      = ls_composition_info
      et_component_descriptor  = lt_component_descriptor
    CHANGING
      ct_message               = ct_message
  ).
  ASSERT ( lo_metadata_id_out_str      IS BOUND AND
           lo_metadata_id_out_str_line IS BOUND AND
           lo_metadata_structure       IS BOUND AND
           lo_metadata_structure_line  IS BOUND AND
           lt_component_descriptor     IS NOT INITIAL ).


*--------------------------------------------------------------------*
* Create dynamic data
*--------------------------------------------------------------------*
  CREATE DATA lr_valuation_data_tab TYPE HANDLE lo_metadata_structure.
  ASSIGN lr_valuation_data_tab->* TO <node_data_table_rtti_tab>.

  CREATE DATA lr_valuation_data_tab_temp TYPE HANDLE lo_metadata_structure.
  ASSIGN lr_valuation_data_tab_temp->* TO <node_data_table_rtti_tab_tmp>.

  CREATE DATA lr_valuation_data_line TYPE HANDLE lo_metadata_structure_line.
  ASSIGN lr_valuation_data_line->* TO <node_data_struct_rtti>.

*--------------------------------------------------------------------*
* These references are needed for field control retrieval
*--------------------------------------------------------------------*
  CREATE DATA lr_valuation_id_out_tab TYPE HANDLE lo_metadata_id_out_str.
  ASSIGN lr_valuation_id_out_tab->* TO <node_id_out_table_rtti_tab>.

  CREATE DATA lr_valuation_id_out_line TYPE HANDLE lo_metadata_id_out_str_line.
  ASSIGN lr_valuation_id_out_line->* TO <node_id_out_table_rtti>.


*--------------------------------------------------------------------*
* Change component descriptor table to handle field types propertly
* The implementation of this method is optional, it makes possible
* changing the type eg. from character to number, in case the SP DDIC
* structure contains character type instead of a number type.
*--------------------------------------------------------------------*
  me->process_component_descriptor(
    EXPORTING
      iv_node_name            = iv_node_name
      iv_target_node_name     = iv_target_node_name
      iv_technical_estcat     = iv_technical_estcat
      iv_esttype              = iv_esttype
    CHANGING
      ct_component_descriptor = lt_component_descriptor
  ).


*--------------------------------------------------------------------*
* Get RTTI of id structure (input)
* We consume input variable iv_technical_estcat in GET_NODE_ID_DATA_RTTI only
* in case iv_node_name = /plmb/if_spc_attr=>gc_node_valuation or
* in case et_component_descriptor is requested.
*--------------------------------------------------------------------*
  me->get_node_id_data_rtti(
    EXPORTING
      iv_node_name           = iv_node_name    " Node Name
      iv_technical_estcat    = iv_technical_estcat " this paramter is not always consumed in GET_NODE_ID_DATA_RTTI
      iv_spc_recnroot        = iv_spc_recnroot
    IMPORTING
      eo_node_id_table_rtti  = lo_metadata_id_structure     " Runtime Type Services
      eo_node_id_struct_rtti = lo_metadata_id_structure_line    " Runtime Type Services
    CHANGING
      ct_message             = ct_message
  ).
  ASSERT ( lo_metadata_structure      IS BOUND AND
           lo_metadata_structure_line IS BOUND ).


*--------------------------------------------------------------------*
* Create dynamic data
*--------------------------------------------------------------------*
  CREATE DATA lr_valuation_id_tab TYPE HANDLE lo_metadata_id_structure.
  ASSIGN lr_valuation_id_tab->* TO <node_id_table_rtti_tab>.

  CREATE DATA lr_valuation_id_tab_temp TYPE HANDLE lo_metadata_id_structure.
  ASSIGN lr_valuation_id_tab_temp->* TO <node_id_table_rtti_tab_temp>.

  CREATE DATA lr_valuation_id_line TYPE HANDLE lo_metadata_id_structure_line.
  ASSIGN lr_valuation_id_line->* TO <node_id_struct_rtti>.


*--------------------------------------------------------------------*
* Retrieve always only one line
*--------------------------------------------------------------------*
  <node_id_table_rtti_tab> = it_node_id.
  LOOP AT <node_id_table_rtti_tab> INTO <node_id_struct_rtti>.
    " store instance number
    lv_instance_number = sy-tabix.

    " table <node_id_table_rtti_tab_temp> will always contain only 1 row
    APPEND <node_id_struct_rtti> TO <node_id_table_rtti_tab_temp>.


*--------------------------------------------------------------------*
*   Clear COMPREL
*--------------------------------------------------------------------*
    CLEAR ls_comprel.

*--------------------------------------------------------------------*
*   We are in valuation composition and we have additional info about
*   the composition
*--------------------------------------------------------------------*
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND   " if we are requesting VALUATION
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition AND " COMPOSITION, and
         ls_composition_info IS NOT INITIAL AND                           " we have additional info about composition
       ( ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
         ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ) ).


*--------------------------------------------------------------------*
*     If it is a quantitative or a qualitative composition, change node description
*--------------------------------------------------------------------*
      IF ls_composition_info-tab_label IS NOT INITIAL.
        lv_description_node_name = ls_composition_info-tab_label.
      ENDIF.


*--------------------------------------------------------------------*
* Process of retrieving the right compsition:
*  1. Action: CONFIG -> QUA_SUBCAT_GROUP (ABBID: PLM_RSP_SP) (empty input)
*  2. Action: CONFIG -> QUA_REF_QTY_TEXT (ABBID: PLM_RSP_SP) (empty input)
*  3. Retrieve By Assotiation: LEAD_OBJECT -> QUANT_LI / QUAL_LI (ABBID: PLM_RSP_SP)
*                (input provided, output not processed)
*  4. Action: CONFIG -> QUA_SUBCAT_GROUP (ABBID: PLM_RSP_SP) (input: ESTCAT
*                (Value Assignment Category))
*  5. Action: CONFIG -> QUA_SPC_GROUP_LIST (ABBID: PLM_RSP_SP) (input: ESTCAT
*                (Value Assignment Category); SUBCAT_GROUP)
*  6. Action: QUAL_LI / QUANT_LI -> QUAL_LIST / QUANT_LIST (ABBID: PLM_RSP_SP)
*                (input: RECN_GROUP)
*  7. Action: QUAL_LI / QUANT_LI -> QUAL_GRP / QUANT_GRP (ABBID: PLM_RSP_SP)
*                (empty input)
*  8. Action: CONFIG -> QUA_REF_QTY_TEXT (ABBID: PLM_RSP_SP) (input: Calculation ID)
*  9. Retrieve By Assotiation: LEAD_OBJECT -> QUANT_LI / QUAL_LI (ABBID: PLM_RSP_SP)
*                (input provided, output processed)
*--------------------------------------------------------------------*

      "set node name to LEAD_OBJECT
      lv_qua_node_name = /plmb/if_spc_attr=>gc_node_rsp_lead_object.

      " call actions and retrieve according to qualitative / quantitative case
      CASE ls_composition_info-tab_type.

        WHEN /plmb/if_spc_attr=>gc_tab_names-quantitative.
          lv_technical_node_name  = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
          lv_qua_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
          lv_qua_action_name      = /plmb/if_spc_attr=>gc_actions_qua-quant_list.
          lv_qua_action_name_2    = /plmb/if_spc_attr=>gc_actions_qua-quant_grp.

        WHEN /plmb/if_spc_attr=>gc_tab_names-qualitative.
          lv_technical_node_name  = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
          lv_qua_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
          lv_qua_action_name      = /plmb/if_spc_attr=>gc_actions_qua-qual_list.
          lv_qua_action_name_2    = /plmb/if_spc_attr=>gc_actions_qua-qual_grp.

      ENDCASE.


      "--- step 1.
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 2.
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_ref_qty_text     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 3. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->retrieve(
        EXPORTING
          iv_node_name        = lv_qua_node_name     " Node name
          iv_target_node_name = lv_qua_target_node_name     " Target node name
          it_node_id          = <node_id_table_rtti_tab_temp>    " Node ID - only contains 1 row
*         it_requested_field  =     " Requested Fields of Node Data
*         iv_lock             =     " Locking indicator
*       IMPORTING
*         ev_failed           = lv_failed    " Failed indicator
*         et_index_failed     = lt_index_failed    " Index of node ID for which no data is availab
*         et_node_data        = <node_data_table_rtti_tab_tmp>    " Node ID and node data
*         et_node_id_rel      =     " Relationship between index of source and target node ID
      ).


      "--- step 4.
      ls_param-estcat = iv_technical_estcat.

      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 5.
      ls_param-estcat = iv_technical_estcat.
      ls_param-subcat_group = ls_composition_info-subcat_group.

      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_spc_group_list     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      " clear parameter
      CLEAR ls_param.

      " fill from the right input parameter based on subcat_group
      CASE ls_composition_info-subcat_group.
        WHEN 'NUTR_GROUP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_nutr_group.
        WHEN 'DIET_GROUP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_diet_group.
        WHEN 'ALLERG_GRP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_allerg_grp.
        WHEN 'RELIG_GRP'.                                   "#EC NOTEXT
          ls_param-recn_group = iv_relig_grp.
        WHEN 'GENMOD_GRP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_genmod_grp.
      ENDCASE.

      "if nothing is selected, show maintained should be called
      IF ls_param-recn_group IS INITIAL.
        ls_param-recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained.
      ENDIF.


      "--- step 6. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = lv_qua_target_node_name     " Node name
          iv_action_name  = lv_qua_action_name     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 7. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = lv_qua_target_node_name     " Node name
          iv_action_name  = lv_qua_action_name_2     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param_2    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 8. (get Reference Quantity field)
      IF lv_ref_qty_was_retrieved = abap_false.
*     Get parameter ID
        CALL METHOD /plmb/cl_rcp_customizing=>get_rsp_calc_id_by_vat
          EXPORTING
            iv_estcat   = iv_technical_estcat
          IMPORTING
            ev_cpara_id = lv_cpara_id.

        ls_param_ref_qty_text-cpara_id = lv_cpara_id.

        mo_spi_connector_rsp_sp->action(
          EXPORTING
            iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
            iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_ref_qty_text     " Action name
*           it_node_id      =     " Node ID to which action refers
            is_param        = ls_param_ref_qty_text    " Parameter for action (e. g. profile)
          IMPORTING
*           ev_failed       =     " Failed indicator
*           et_index_failed =     " Index of node ID for which no data is available
            et_node_data    = lt_node_data_ref_qty_text    " Node ID and node data
*           eg_param        =     " Exporting parameters for action
        ).
        READ TABLE lt_node_data_ref_qty_text INDEX 1 INTO ls_node_data_ref_qty_text.
        lv_ref_qty_was_retrieved = abap_true.
      ENDIF.

      "--- step 9. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->retrieve(
        EXPORTING
          iv_node_name        = lv_qua_node_name     " Node name
          iv_target_node_name = lv_qua_target_node_name     " Target node name
          it_node_id          = <node_id_table_rtti_tab_temp>    " Node ID - only contains 1 row
*         it_requested_field  =     " Requested Fields of Node Data
*         iv_lock             =     " Locking indicator
        IMPORTING
          ev_failed           = lv_failed    " Failed indicator
          et_index_failed     = lt_index_failed    " Index of node ID for which no data is availab
          et_node_data        = <node_data_table_rtti_tab_tmp>    " Node ID and node data
*         et_node_id_rel      =     " Relationship between index of source and target node ID
      ).

*--------------------------------------------------------------------*
* at this point, <node_data_table_rtti_tab_tmp> contains the right entries
*--------------------------------------------------------------------*

    ELSE.
*--------------------------------------------------------------------*
*     in this case we are not in composition or we are in composition
*     but neither in quantitative nor in qualitative composition
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*     Retrieve
*--------------------------------------------------------------------*
      IF ls_composition_info-tab_type = gc_tab_name_list.
        lv_technical_node_name = /plmb/if_spc_attr=>gc_node_specification_listing.
        lv_target_node_name = /plmb/if_spc_attr=>gc_node_specification_listing.
        lv_description_node_name = me->get_friendly_node_name( iv_node_name = /plmb/if_spc_attr=>gc_node_specification_listing ).
      ENDIF.

      IF ls_composition_info-tab_type IS NOT INITIAL.
        IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
           lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.

          mo_spi_connector_spc->action(
            EXPORTING
              iv_node_name    = /plmb/if_spc_attr=>gc_node_header_config    " Node name
              iv_action_name  = /plmb/if_spc_attr=>gc_actions_hdr_conf-get_spc_val_ref_qty    " Action name
*             it_node_id      =     " Node ID to which action refers
              is_param        = <node_id_struct_rtti>    " Parameter for action (e. g. profile) - here we provide the structure
            IMPORTING
*             ev_failed       =     " Failed indicator
*             et_index_failed =     " Index of node ID for which no data is available
*             et_node_data    =     " Node ID and node data
              eg_param        = ls_comprel    " Exporting parameters for action
          ).

        ENDIF.
      ENDIF.

      IF ( ls_composition_info-tab_type IS NOT INITIAL )                   OR
         ( iv_node_name        <> /plmb/if_spc_attr=>gc_node_valuation   ) OR
         ( lv_target_node_name <> /plmb/if_spc_attr=>gc_node_composition ).

        mo_spi_connector_spc->retrieve(
          EXPORTING
            iv_node_name        = iv_node_name    " Node name
            iv_target_node_name = lv_target_node_name    " Target node name
*           iv_lock             =     " Locking indicator
            it_node_id          = <node_id_table_rtti_tab_temp>    " Node ID
          IMPORTING
            ev_failed           = lv_failed    " Failed indicator
            et_index_failed     = lt_index_failed    " Index of node ID for which no data is availab
            et_node_data        = <node_data_table_rtti_tab_tmp>    " Node ID and node data
*           et_node_id_rel      =     " Relationship between index of source and target node ID
        ).

        DO lines( <node_data_table_rtti_tab_tmp> ) TIMES.
          APPEND ls_comprel TO lt_comprel.
        ENDDO.
      ENDIF.

    ENDIF.


*--------------------------------------------------------------------*
*   Retieve Error handling
*   Don't abort the process, but collect the messages and continue with the next entry
*--------------------------------------------------------------------*
    IF lv_failed = abap_true OR
       lt_index_failed IS NOT INITIAL.
*--------------------------------------------------------------------*
*     Get messages
*--------------------------------------------------------------------*
      mo_spi_collector_spc->get_messages(
        EXPORTING
          iv_node_name   = iv_node_name    " Node Name
*         iv_init_buffer =     " Remove exported messages from buffer
        IMPORTING
          et_messages    = lt_messages    " Message table
*         ev_severity    = lv_severity    " Message Severity
      ).

      LOOP AT lt_messages INTO ls_message.
        MOVE-CORRESPONDING ls_message TO ls_spi_message.
        APPEND ls_spi_message TO ct_message.
      ENDLOOP.

      CLEAR <node_data_table_rtti_tab_tmp>.
      CLEAR <node_id_table_rtti_tab_temp>.
      CONTINUE.
    ENDIF.


*--------------------------------------------------------------------*
*   Fill ID table based on output
*--------------------------------------------------------------------*
    IF <node_data_table_rtti_tab_tmp> IS NOT INITIAL.
      LOOP AT <node_data_table_rtti_tab_tmp> INTO <node_data_struct_rtti>.
        MOVE-CORRESPONDING <node_data_struct_rtti> TO <node_id_out_table_rtti>.
        APPEND <node_id_out_table_rtti> TO <node_id_out_table_rtti_tab>.
      ENDLOOP.

      IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND   " if we are requesting VALUATION
           lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition AND " COMPOSITION, and
           ls_composition_info IS NOT INITIAL AND                           " we have additional info about composition
         ( ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
           ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ) ).

        lo_spi_collector_for_fieldctrl = mo_spi_collector_rsp_sp.

        " call actions and retrieve according to qualitative / quantitative case
        CASE ls_composition_info-tab_type.
          WHEN /plmb/if_spc_attr=>gc_tab_names-quantitative.
            lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
          WHEN /plmb/if_spc_attr=>gc_tab_names-qualitative.
            lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
        ENDCASE.

      ELSE.

        " requesting field control
        lo_spi_collector_for_fieldctrl = mo_spi_collector_spc.
        IF ls_composition_info-tab_type = gc_tab_name_list.
          lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_specification_listing.
        ELSE.
          lv_target_node_name_fieldctrl = lv_target_node_name.
        ENDIF.

      ENDIF.


*--------------------------------------------------------------------*
*     Does table reference exist?
*--------------------------------------------------------------------*
      lv_table_already_exists = me->table_reference_exists(
        iv_engine_value_assignment_typ = iv_technical_estcat
        iv_target_node_name            = iv_target_node_name
        it_table_data                  = ct_table_data
        it_table_meta_data             = ct_table_meta_data
      ).


*--------------------------------------------------------------------*
*     Get field control info for header
*     If a field is invisible, it's column will not appear in the output
*--------------------------------------------------------------------*
      IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree AND
           lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ) AND
           lv_table_already_exists = abap_false. " only in case this is a new table
        CLEAR lt_header_properties.
        lo_spi_collector_for_fieldctrl->get_properties(
          EXPORTING
            iv_node_name   = lv_target_node_name_fieldctrl    " Node Name
*           it_node_id     = <node_id_out_table_rtti_tab>    " Node IDs
*           iv_init_buffer = abap_true   " Remove exported properties from buffer
          IMPORTING
            et_properties  = lt_header_properties    " Field properties for node ID
        ).
      ENDIF.

      UNASSIGN <ls_property>.
      " use <ls_property> as default
      READ TABLE lt_header_properties ASSIGNING <ls_property> WITH KEY node_name = lv_target_node_name_fieldctrl.

*--------------------------------------------------------------------*
*     Handle properties line-by-line
*     This algorithm makes sure that the lines of lt_row_properties
*     are in the same order as the lines of <node_id_out_table_rtti_tab>
*     If a field is invisible, the content of it will not appear in the
*     output
*--------------------------------------------------------------------*
      IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree AND    " for PTREE -> VALUATION
           lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ) AND
           lv_table_already_exists = abap_false. " only in case this is a new table
        CLEAR lt_properties.
        lo_spi_collector_for_fieldctrl->get_properties(
          EXPORTING
            iv_node_name   = lv_target_node_name_fieldctrl    " Node Name
            it_node_id     = <node_id_out_table_rtti_tab>    " Node IDs
*           iv_init_buffer = abap_true   " Remove exported properties from buffer
          IMPORTING
            et_properties  = lt_properties    " Field properties for node ID
        ).
        IF lt_properties IS NOT INITIAL.
          LOOP AT <node_id_out_table_rtti_tab> INTO <node_id_out_table_rtti>.
            " in lt_properties-properties table the rows are identified by
            " the XSTRING-converted representation of the current row in the
            " <node_id_out_table_rtti> table
            /plmb/cl_spi_appl_access_utils=>convert_data_to_xstring(
              EXPORTING
                ig_data           = <node_id_out_table_rtti>    " Data
*               iv_compression_on =     " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
              IMPORTING
                ev_xstring        = lv_row_xstring    " Generic Parameter as XSTRING
            ).
            CLEAR ls_row_property.
            READ TABLE lt_properties INTO ls_property_line
              WITH KEY node_name = lv_target_node_name_fieldctrl
                       node_id   = lv_row_xstring.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING ls_property_line TO ls_row_property.
            ELSE.
              ls_row_property-node_name = lv_target_node_name_fieldctrl.
              " put <ls_property> - this is a default property
              IF <ls_property> IS ASSIGNED.
                ls_row_property-properties = <ls_property>-properties.
                " otherwise append empty properties table - this way we ensure that
                " the same number of rows will be in both tables
              ENDIF.
            ENDIF.
            APPEND ls_row_property TO lt_row_properties.
          ENDLOOP.
        ELSE.
          lo_spi_collector_for_fieldctrl->get_properties(
            EXPORTING
              iv_node_name   = lv_target_node_name_fieldctrl    " Node Name
*             it_node_id     = <node_id_out_table_rtti_tab>    " Node IDs
*             iv_init_buffer = abap_true   " Remove exported properties from buffer
            IMPORTING
              et_properties  = lt_properties    " Field properties for node ID
          ).
          READ TABLE lt_properties INDEX 1 INTO ls_property_line.
          IF sy-subrc = 0.
            LOOP AT <node_id_out_table_rtti_tab> INTO <node_id_out_table_rtti>.
              MOVE-CORRESPONDING ls_property_line TO ls_row_property.
              APPEND ls_row_property TO lt_row_properties.
            ENDLOOP.
          ENDIF.
        ENDIF.

*--------------------------------------------------------------------*
*       Merge row-level and node-level properties
*--------------------------------------------------------------------*
        " set lv_option to the "theoretical" maximum
        IF <ls_property> IS ASSIGNED.
          LOOP AT <ls_property>-properties ASSIGNING <ls_property_list>.
            lv_option = 9.
            LOOP AT lt_row_properties INTO ls_row_property.
              LOOP AT ls_row_property-properties INTO ls_row_property_list
                WHERE node_field = <ls_property_list>-node_field.
                " if the default field control is stricter than the row-level
                " then the row-level dominates
                IF lv_option > ls_row_property_list-option.
                  lv_option = ls_row_property_list-option.
                ENDIF.
              ENDLOOP.
            ENDLOOP.
            IF lv_option <> 9.
              <ls_property_list>-option = lv_option.
            ENDIF.
          ENDLOOP.
        ELSE.
          ls_property_hdr-node_name = lv_target_node_name_fieldctrl.
          LOOP AT lt_component_descriptor ASSIGNING <ls_component_descriptor>.
            lv_option = 9.
            LOOP AT lt_row_properties INTO ls_row_property.
              LOOP AT ls_row_property-properties INTO ls_row_property_list
                WHERE node_field = <ls_component_descriptor>-name.
                IF ls_property_hdr_prop-node_field IS INITIAL.
                  ls_property_hdr_prop-node_field = <ls_component_descriptor>-name.
                ENDIF.
                IF lv_option > ls_row_property_list-option.
                  lv_option = ls_row_property_list-option.
                ENDIF.
              ENDLOOP.
            ENDLOOP.
            IF lv_option <> 9 AND
              ls_property_hdr_prop-node_field IS NOT INITIAL.
              ls_property_hdr_prop-option = lv_option.
              INSERT ls_property_hdr_prop INTO TABLE ls_property_hdr-properties.
              CLEAR ls_property_hdr_prop.
            ENDIF.
          ENDLOOP.
        ENDIF.


        READ TABLE lt_header_properties ASSIGNING <ls_property> WITH KEY node_name = lv_target_node_name_fieldctrl.
        IF sy-subrc = 0.
          ls_property_hdr = <ls_property>.
        ENDIF.
        IF ls_property_hdr-properties IS NOT INITIAL.

*--------------------------------------------------------------------*
*         Field control handling - set invisible components to technical,
*         CHANGE lt_component_descriptor - set technical field indicator
*--------------------------------------------------------------------*
          LOOP AT lt_component_descriptor ASSIGNING <ls_component_descriptor>.
            READ TABLE ls_property_hdr-properties INTO ls_property
              WITH KEY node_field = <ls_component_descriptor>-name.
            IF sy-subrc = 0.
              " if it is invisible, set it to technical - it should not be shown in the final excel
              IF ls_property-option = /plmb/if_spi_c=>gs_c_property-invisible.
                <ls_component_descriptor>-is_technical = abap_true.
              ELSE. " if it's not invisible, leave it as it is, but set it to non-technical
                <ls_component_descriptor>-is_technical = abap_false.
              ENDIF.
            ELSE. " if it's not found in the field control info, we consider it as a technical field
              " set technical field indicator
              <ls_component_descriptor>-is_technical = abap_true.
            ENDIF.
          ENDLOOP.

        ENDIF.
      ENDIF. " for PTREE -> VALUATION

      CLEAR <node_id_out_table_rtti_tab>.

    ENDIF.



*--------------------------------------------------------------------*
*   Process result
*--------------------------------------------------------------------*
    " instance numbering
    LOOP AT <node_data_table_rtti_tab_tmp> INTO <node_data_struct_rtti>.
      ADD 1 TO lv_row_number.
      ls_instance_number_rel-row_number = lv_row_number.
      ls_instance_number_rel-instance_number = lv_instance_number.
      APPEND ls_instance_number_rel TO lt_instance_number_rel.
      CLEAR ls_instance_number_rel.
    ENDLOOP.

    " append result to cumulated result table
    APPEND LINES OF <node_data_table_rtti_tab_tmp> TO <node_data_table_rtti_tab>.
    CLEAR <node_data_table_rtti_tab_tmp>.


    CLEAR <node_id_table_rtti_tab_temp>.
  ENDLOOP.


*--------------------------------------------------------------------*
* Special handling of initial case
*--------------------------------------------------------------------*
  IF <node_id_table_rtti_tab> IS INITIAL.

    CLEAR <node_id_table_rtti_tab_temp>.


*--------------------------------------------------------------------*
*   We are in valuation composition and we have additional info about
*   the composition
*--------------------------------------------------------------------*
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND   " if we are requesting VALUATION
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition AND " COMPOSITION, and
         ls_composition_info IS NOT INITIAL AND                           " we have additional info about composition
       ( ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
         ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ) ).


*--------------------------------------------------------------------*
*     If it is a quantitative or a qualitative composition, change node description
*--------------------------------------------------------------------*
      IF ls_composition_info-tab_label IS NOT INITIAL.
        lv_description_node_name = ls_composition_info-tab_label.
      ENDIF.


*--------------------------------------------------------------------*
* Process of retrieving the right compsition:
*  1. Action: CONFIG -> QUA_SUBCAT_GROUP (ABBID: PLM_RSP_SP) (empty input)
*  2. Action: CONFIG -> QUA_REF_QTY_TEXT (ABBID: PLM_RSP_SP) (empty input)
*  3. Retrieve By Assotiation: LEAD_OBJECT -> QUANT_LI / QUAL_LI (ABBID: PLM_RSP_SP)
*                (input provided, output not processed)
*  4. Action: CONFIG -> QUA_SUBCAT_GROUP (ABBID: PLM_RSP_SP) (input: ESTCAT
*                (Value Assignment Category))
*  5. Action: CONFIG -> QUA_SPC_GROUP_LIST (ABBID: PLM_RSP_SP) (input: ESTCAT
*                (Value Assignment Category); SUBCAT_GROUP)
*  6. Action: QUAL_LI / QUANT_LI -> QUAL_LIST / QUANT_LIST (ABBID: PLM_RSP_SP)
*                (input: RECN_GROUP)
*  7. Action: QUAL_LI / QUANT_LI -> QUAL_GRP / QUANT_GRP (ABBID: PLM_RSP_SP)
*                (empty input)
*  8. Action: CONFIG -> QUA_REF_QTY_TEXT (ABBID: PLM_RSP_SP) (input: Calculation ID)
*--------------------------------------------------------------------*

      "set node name to LEAD_OBJECT
      lv_qua_node_name = /plmb/if_spc_attr=>gc_node_rsp_lead_object.

      " call actions and retrieve according to qualitative / quantitative case
      CASE ls_composition_info-tab_type.

        WHEN /plmb/if_spc_attr=>gc_tab_names-quantitative.
          lv_technical_node_name  = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
          lv_qua_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
          lv_qua_action_name      = /plmb/if_spc_attr=>gc_actions_qua-quant_list.
          lv_qua_action_name_2    = /plmb/if_spc_attr=>gc_actions_qua-quant_grp.

        WHEN /plmb/if_spc_attr=>gc_tab_names-qualitative.
          lv_technical_node_name  = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
          lv_qua_target_node_name = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
          lv_qua_action_name      = /plmb/if_spc_attr=>gc_actions_qua-qual_list.
          lv_qua_action_name_2    = /plmb/if_spc_attr=>gc_actions_qua-qual_grp.

      ENDCASE.


      "--- step 1.
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 2.
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_ref_qty_text     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 3. (quantitative / qualitative case separated)
      " <node_id_table_rtti_tab_temp> is empty
      mo_spi_connector_rsp_sp->retrieve(
        EXPORTING
          iv_node_name        = lv_qua_node_name     " Node name
          iv_target_node_name = lv_qua_target_node_name     " Target node name
          it_node_id          = <node_id_table_rtti_tab_temp>    " Node ID - only contains 1 row
*         it_requested_field  =     " Requested Fields of Node Data
*         iv_lock             =     " Locking indicator
*       IMPORTING
*         ev_failed           = lv_failed    " Failed indicator
*         et_index_failed     = lt_index_failed    " Index of node ID for which no data is availab
*         et_node_data        = <node_data_table_rtti_tab_tmp>    " Node ID and node data
*         et_node_id_rel      =     " Relationship between index of source and target node ID
      ).


      "--- step 4.
      ls_param-estcat = iv_technical_estcat.

      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_subcat_group     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 5.
      ls_param-estcat = iv_technical_estcat.
      ls_param-subcat_group = ls_composition_info-subcat_group.

      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
          iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_spc_group_list     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      " clear parameter
      CLEAR ls_param.

      " fill from the right input parameter based on subcat_group
      CASE ls_composition_info-subcat_group.
        WHEN 'NUTR_GROUP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_nutr_group.
        WHEN 'DIET_GROUP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_diet_group.
        WHEN 'ALLERG_GRP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_allerg_grp.
        WHEN 'RELIG_GRP'.                                   "#EC NOTEXT
          ls_param-recn_group = iv_relig_grp.
        WHEN 'GENMOD_GRP'.                                  "#EC NOTEXT
          ls_param-recn_group = iv_genmod_grp.
      ENDCASE.

      "if nothing is selected, show maintained should be called
      IF ls_param-recn_group IS INITIAL.
        ls_param-recn_group = /plmb/if_spc_attr=>gc_actions_qua-qua_show_maintained.
      ENDIF.


      "--- step 6. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = lv_qua_target_node_name     " Node name
          iv_action_name  = lv_qua_action_name     " Action name
*         it_node_id      =     " Node ID to which action refers
          is_param        = ls_param    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 7. (quantitative / qualitative case separated)
      mo_spi_connector_rsp_sp->action(
        EXPORTING
          iv_node_name    = lv_qua_target_node_name     " Node name
          iv_action_name  = lv_qua_action_name_2     " Action name
*         it_node_id      =     " Node ID to which action refers
*         is_param        = ls_param_2    " Parameter for action (e. g. profile)
*       IMPORTING
*         ev_failed       =     " Failed indicator
*         et_index_failed =     " Index of node ID for which no data is available
*         et_node_data    =     " Node ID and node data
*         eg_param        =     " Exporting parameters for action
      ).


      "--- step 8. (get Reference Quantity field)
      IF lv_ref_qty_was_retrieved = abap_false.
*     Get parameter ID
        CALL METHOD /plmb/cl_rcp_customizing=>get_rsp_calc_id_by_vat
          EXPORTING
            iv_estcat   = iv_technical_estcat
          IMPORTING
            ev_cpara_id = lv_cpara_id.

        ls_param_ref_qty_text-cpara_id = lv_cpara_id.

        mo_spi_connector_rsp_sp->action(
          EXPORTING
            iv_node_name    = /plmb/if_spc_attr=>gc_node_rsp_config     " Node name
            iv_action_name  = /plmb/if_spc_attr=>gc_actions_qua-qua_ref_qty_text     " Action name
*           it_node_id      =     " Node ID to which action refers
            is_param        = ls_param_ref_qty_text    " Parameter for action (e. g. profile)
          IMPORTING
*           ev_failed       =     " Failed indicator
*           et_index_failed =     " Index of node ID for which no data is available
            et_node_data    = lt_node_data_ref_qty_text    " Node ID and node data
*           eg_param        =     " Exporting parameters for action
        ).
        READ TABLE lt_node_data_ref_qty_text INDEX 1 INTO ls_node_data_ref_qty_text.
        lv_ref_qty_was_retrieved = abap_true.
      ENDIF.

    ELSE.
*--------------------------------------------------------------------*
*     in this case we are not in composition or we are in composition
*     but neither in quantitative nor in qualitative composition
*--------------------------------------------------------------------*
      IF ls_composition_info-tab_type = gc_tab_name_list.
        lv_technical_node_name = /plmb/if_spc_attr=>gc_node_specification_listing.
        lv_target_node_name = /plmb/if_spc_attr=>gc_node_specification_listing.
        lv_description_node_name = me->get_friendly_node_name( iv_node_name = /plmb/if_spc_attr=>gc_node_specification_listing ).
      ENDIF.

    ENDIF.


*--------------------------------------------------------------------*
*   Fill ID table based on output
*--------------------------------------------------------------------*
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND   " if we are requesting VALUATION
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition AND " COMPOSITION, and
         ls_composition_info IS NOT INITIAL AND                           " we have additional info about composition
       ( ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
         ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ) ).

      lo_spi_collector_for_fieldctrl = mo_spi_collector_rsp_sp.

      " call actions and retrieve according to qualitative / quantitative case
      CASE ls_composition_info-tab_type.
        WHEN /plmb/if_spc_attr=>gc_tab_names-quantitative.
          lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_rsp_quant_li.
        WHEN /plmb/if_spc_attr=>gc_tab_names-qualitative.
          lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_rsp_qual_li.
      ENDCASE.

    ELSE.

      " requesting field control
      lo_spi_collector_for_fieldctrl = mo_spi_collector_spc.
      IF ls_composition_info-tab_type = gc_tab_name_list.
        lv_target_node_name_fieldctrl = /plmb/if_spc_attr=>gc_node_specification_listing.
      ELSE.
        lv_target_node_name_fieldctrl = lv_target_node_name.
      ENDIF.

    ENDIF.


*--------------------------------------------------------------------*
*     Does table reference exist?
*--------------------------------------------------------------------*
    lv_table_already_exists = me->table_reference_exists(
      iv_engine_value_assignment_typ = iv_technical_estcat
      iv_target_node_name            = iv_target_node_name
      it_table_data                  = ct_table_data
      it_table_meta_data             = ct_table_meta_data
    ).


*--------------------------------------------------------------------*
*   Get field control info for header
*   If a field is invisible, it's column will not appear in the output
*--------------------------------------------------------------------*
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree AND
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ) AND
         lv_table_already_exists = abap_false. " only in case this is a new table
      CLEAR lt_header_properties.
      lo_spi_collector_for_fieldctrl->get_properties(
        EXPORTING
          iv_node_name   = lv_target_node_name_fieldctrl    " Node Name
*         it_node_id     = <node_id_out_table_rtti_tab>    " Node IDs
*         iv_init_buffer = abap_true   " Remove exported properties from buffer
        IMPORTING
          et_properties  = lt_header_properties    " Field properties for node ID
      ).
    ENDIF.

    UNASSIGN <ls_property>.
    "use <ls_property> as default
    READ TABLE lt_header_properties ASSIGNING <ls_property> WITH KEY node_name = lv_target_node_name_fieldctrl.

*--------------------------------------------------------------------*
*   Handle properties line-by-line
*   This algorithm makes sure that the lines of lt_row_properties
*   are in the same order as the lines of <node_id_out_table_rtti_tab>
*   If a field is invisible, the content of it will not appear in the
*   output
*--------------------------------------------------------------------*
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree AND    " for PTREE -> VALUATION
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ) AND
         lv_table_already_exists = abap_false. " only in case this is a new table
      lo_spi_collector_for_fieldctrl->get_properties(
        EXPORTING
          iv_node_name   = lv_target_node_name_fieldctrl    " Node Name
*         it_node_id     = <node_id_out_table_rtti_tab>    " Node IDs
*         iv_init_buffer = abap_true   " Remove exported properties from buffer
        IMPORTING
          et_properties  = lt_properties    " Field properties for node ID
      ).
      READ TABLE lt_properties INDEX 1 INTO ls_property_line.
      IF sy-subrc = 0.
        LOOP AT <node_id_out_table_rtti_tab> INTO <node_id_out_table_rtti>.
          MOVE-CORRESPONDING ls_property_line TO ls_row_property.
          APPEND ls_row_property TO lt_row_properties.
        ENDLOOP.
      ENDIF.

*--------------------------------------------------------------------*
*     Merge row-level and node-level properties
*--------------------------------------------------------------------*
      " set lv_option to the "theoretical" maximum
      IF <ls_property> IS ASSIGNED.
        LOOP AT <ls_property>-properties ASSIGNING <ls_property_list>.
          lv_option = 9.
          LOOP AT lt_row_properties INTO ls_row_property.
            LOOP AT ls_row_property-properties INTO ls_row_property_list
              WHERE node_field = <ls_property_list>-node_field.
              " if the default field control is stricter than the row-level
              " then the row-level dominates
              IF lv_option > ls_row_property_list-option.
                lv_option = ls_row_property_list-option.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
          IF lv_option <> 9.
            <ls_property_list>-option = lv_option.
          ENDIF.
        ENDLOOP.
      ELSE.
        ls_property_hdr-node_name = lv_target_node_name_fieldctrl.
        LOOP AT lt_component_descriptor ASSIGNING <ls_component_descriptor>.
          lv_option = 9.
          LOOP AT lt_row_properties INTO ls_row_property.
            LOOP AT ls_row_property-properties INTO ls_row_property_list
              WHERE node_field = <ls_component_descriptor>-name.
              IF ls_property_hdr_prop-node_field IS INITIAL.
                ls_property_hdr_prop-node_field = <ls_component_descriptor>-name.
              ENDIF.
              IF lv_option > ls_row_property_list-option.
                lv_option = ls_row_property_list-option.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
          IF lv_option <> 9 AND
            ls_property_hdr_prop-node_field IS NOT INITIAL.
            ls_property_hdr_prop-option = lv_option.
            INSERT ls_property_hdr_prop INTO TABLE ls_property_hdr-properties.
            CLEAR ls_property_hdr_prop.
          ENDIF.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_header_properties ASSIGNING <ls_property> WITH KEY node_name = lv_target_node_name_fieldctrl.
      IF sy-subrc = 0.
        ls_property_hdr = <ls_property>.
      ENDIF.
      IF ls_property_hdr-properties IS NOT INITIAL.

*--------------------------------------------------------------------*
*         Field control handling - remove invisible components,
*         CHANGE lt_component_descriptor - set technical field indicator
*--------------------------------------------------------------------*
        LOOP AT lt_component_descriptor ASSIGNING <ls_component_descriptor>.
          READ TABLE ls_property_hdr-properties INTO ls_property
            WITH KEY node_field = <ls_component_descriptor>-name.
          IF sy-subrc = 0.
            " if it is invisible, delete it from LT_COMPONENT_DESCRIPTOR
            IF ls_property-option = /plmb/if_spi_c=>gs_c_property-invisible.
              DELETE lt_component_descriptor.
            ELSE. " if it's not invisible, leave it as it is, but set it to non-technical
              <ls_component_descriptor>-is_technical = abap_false.
            ENDIF.
          ELSE. " if it's not found in the field control info, we consider it as a technical field
            " set technical field indicator
            <ls_component_descriptor>-is_technical = abap_true.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF. " for PTREE -> VALUATION

    CLEAR <node_id_out_table_rtti_tab>.

    " <node_id_table_rtti_tab> is not initial
    " but <node_data_table_rtti_tab> is initial - put empty line.
    " In this case there will not be any instance for this specification,
    " but the output will contain an empty row
  ELSEIF <node_data_table_rtti_tab> IS INITIAL.
    APPEND INITIAL LINE TO <node_data_table_rtti_tab>.
* note 2751323
*--------------------------------------------------------------------*
*   Does table reference exist?
*--------------------------------------------------------------------*
    lv_table_already_exists = me->table_reference_exists(
      iv_engine_value_assignment_typ = iv_technical_estcat
      iv_target_node_name            = iv_target_node_name
      it_table_data                  = ct_table_data
      it_table_meta_data             = ct_table_meta_data
    ).
* note 2751323
  ENDIF.


*--------------------------------------------------------------------*
* Fill definition table if needed
*--------------------------------------------------------------------*
  IF iv_fill_table_definition = abap_true. " we need to fill the definition table
    CLEAR lt_definition_int.


*--------------------------------------------------------------------*
*     Add default fields to definition table
*--------------------------------------------------------------------*
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lt_comprel IS NOT INITIAL.
        lv_add_comprel = abap_true.
      ELSE.
        lv_add_comprel = abap_false.
      ENDIF.
    ELSE.
      lv_add_comprel = abap_false.
    ENDIF.
    IF ( ls_composition_info IS NOT INITIAL AND                           " we have additional info about composition
       ( ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-qualitative OR
         ls_composition_info-tab_type = /plmb/if_spc_attr=>gc_tab_names-quantitative ) ).
      IF ls_node_data_ref_qty_text-ref_qty IS NOT INITIAL.
        lv_add_ref_qty = abap_true.
      ELSE.
        lv_add_ref_qty = abap_false.
      ENDIF.
    ELSE.
      lv_add_ref_qty = abap_false.
    ENDIF.

    me->add_table_definition_defaults(
      EXPORTING
        iv_table_no         = cv_table_no   " Natural Number
        iv_table_text       = iv_table_text_prefix && lv_description_node_name " Value Assignment Type Text
        iv_add_comprel      = lv_add_comprel
        iv_add_ref_qty      = lv_add_ref_qty
        iv_target_node_name = iv_target_node_name
      CHANGING
        ct_table_definition = lt_definition_int " Table Definition
    ).

    LOOP AT lt_component_descriptor INTO ls_component_descriptor.

*--------------------------------------------------------------------*
*       Fill default values for the definition table
*--------------------------------------------------------------------*
      ls_definition_int-new_page       = abap_false.
      ls_definition_int-page_text      = space.
      ls_definition_int-table_no       = cv_table_no.
      ls_definition_int-nodedisplay    = abap_true.
      ls_definition_int-rowkey         = abap_true.
      ls_definition_int-colkey         = abap_false.
      ls_definition_int-table_text     = space.
*--------------------------------------------------------------------*
*       Fill field properties: NAME, TEXT, TYPE NAME
*--------------------------------------------------------------------*
      ls_definition_int-fieldname      = ls_component_descriptor-name.
      TRANSLATE ls_definition_int-fieldname USING '-_'.                "2033356
      ls_definition_int-fieldtext      = space.
      ls_definition_int-fieldtype_name = /plmb/if_exp_c=>gc_component_key_type-engine_string.
      APPEND ls_definition_int TO lt_definition_int.
      CLEAR ls_definition_int.

    ENDLOOP.

  ELSE. " we don't need to fill the definition table
    " fill LT_DEFINITION_INT by splitting the global defintion table
    lt_definition_int = me->get_table_definition_section( cv_table_no ).
  ENDIF. " if we need to fill the definition table


*--------------------------------------------------------------------*
*   Get dynamic structure and table type for filling data table
*--------------------------------------------------------------------*
  /plmb/cl_exp_tools=>create_struct_and_table_type(
    EXPORTING
      it_definition = lt_definition_int
    IMPORTING
      eo_structure  = lo_out_struct
      eo_table_type = lo_out_table_type
  ).
  ASSERT lo_out_struct     IS BOUND AND
         lo_out_table_type IS BOUND.


*--------------------------------------------------------------------*
*   Fill overall definition table and clear internal definition table
*--------------------------------------------------------------------*
* note 2733617
  IF iv_fill_table_definition = abap_true AND "we need to fill the definition table
     lv_table_already_exists = abap_false.
    APPEND LINES OF lt_definition_int TO ct_table_definition.
    CLEAR lt_definition_int.
  ELSE.
    CLEAR lt_definition_int.
    SUBTRACT 1 FROM cv_table_no.                               "2751323
  ENDIF.


*--------------------------------------------------------------------*
* Get Current table reference
* This will ensure that the entries will be put into the right table
*--------------------------------------------------------------------*
  me->get_current_table_reference(
    EXPORTING
      iv_engine_value_assignment_typ = iv_technical_estcat    " Value Assignment Type
      iv_target_node_name            = iv_target_node_name
      io_out_struct                  = lo_out_struct
      io_out_table_type              = lo_out_table_type    " Runtime Type Services
    IMPORTING
      ev_engine_key_row_max          = lv_engine_key_row_max    " Natural Number
      ev_table_already_exists        = lv_table_already_exists
      er_table_ref                   = lr_out_data_tab
      er_struct_ref                  = lr_out_data_struct
    CHANGING
      ct_table_meta_data             = ct_table_meta_data
      ct_table_data                  = ct_table_data    " Table Data for Download
  ).
  ASSERT lr_out_data_tab IS BOUND AND
         lr_out_data_struct IS BOUND.
  ASSIGN lr_out_data_tab->* TO <lt_out_data>.
  ASSIGN lr_out_data_struct->* TO <ls_out_data_str>.

  CREATE DATA lr_out_data TYPE HANDLE lo_out_struct.
  ASSIGN lr_out_data->* TO <ls_out_data>.


*--------------------------------------------------------------------*
*   Put metadata entry 1 - field names
*--------------------------------------------------------------------*
  IF lv_table_already_exists = abap_false. " only in case this table does not exist already
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-metadata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = gc_meta_spec_id.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation   OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_meta_instance.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_meta_sort.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_meta_usage.
    ENDIF.
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lv_add_comprel      = abap_true.
        ASSIGN COMPONENT gc_additional_field_comprel_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = gc_additional_field_comprel_ui.
      ENDIF.
      IF lv_add_ref_qty = abap_true.
        ASSIGN COMPONENT gc_additional_field_ref_qty_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = gc_additional_field_ref_qty_ui.
      ENDIF.
    ENDIF.
    LOOP AT lt_component_descriptor INTO ls_component_descriptor.
      TRANSLATE ls_component_descriptor-name USING '-_'.      "2033356
      ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      ASSERT sy-subrc = 0.
      <lv_out_data> = ls_component_descriptor-name.
    ENDLOOP.
    IF lt_component_descriptor IS NOT INITIAL.
      INSERT <ls_out_data> INTO TABLE <lt_out_data>.
      CLEAR <ls_out_data>.
    ENDIF.


*--------------------------------------------------------------------*
*   Put metadata entry 2 - field texts
*--------------------------------------------------------------------*
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 2.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-metadata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 2.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = text-003.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation   OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = text-040.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = text-041.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = text-042.
    ENDIF.
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lv_add_comprel = abap_true.
        ASSIGN COMPONENT gc_additional_field_comprel_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = text-020.
      ENDIF.
      IF lv_add_ref_qty = abap_true.
        ASSIGN COMPONENT gc_additional_field_ref_qty_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = text-021.
      ENDIF.
    ENDIF.
    DATA lv_descriptor_name TYPE abap_compname. "2033356
    LOOP AT lt_component_descriptor INTO ls_component_descriptor.
      lv_descriptor_name = ls_component_descriptor-name."2033356
      TRANSLATE lv_descriptor_name USING '-_'.   "2033356
      "ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <ls_out_data> TO <lv_out_data>."2033356
      ASSIGN COMPONENT lv_descriptor_name OF STRUCTURE <ls_out_data> TO <lv_out_data>."2033356
      ASSERT sy-subrc = 0.
      " get component description
      CLEAR lv_component_description.
      lv_component_description = me->get_friendly_field_name( iv_node_name  = lv_technical_node_name
                                                              iv_field_name = ls_component_descriptor-name ).
      IF lv_component_description IS NOT INITIAL.
        <lv_out_data> = lv_component_description.
      ELSE.
        <lv_out_data> = ls_component_descriptor-text.
      ENDIF.
    ENDLOOP.
    IF lt_component_descriptor IS NOT INITIAL.
      INSERT <ls_out_data> INTO TABLE <lt_out_data>.
      CLEAR <ls_out_data>.
    ENDIF.


*--------------------------------------------------------------------*
*   Put metadata entry 3 - technical field indicator
*--------------------------------------------------------------------*
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 3.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-metadata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 3.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation   OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_metadata_business_field.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_metadata_technical_field.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = gc_metadata_business_field.
    ENDIF.
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lv_add_comprel = abap_true.
        ASSIGN COMPONENT gc_additional_field_comprel_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = gc_metadata_business_field.
      ENDIF.
      IF lv_add_ref_qty = abap_true.
        ASSIGN COMPONENT gc_additional_field_ref_qty_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = gc_metadata_business_field.
      ENDIF.
    ENDIF.
    LOOP AT lt_component_descriptor INTO ls_component_descriptor.
      lv_descriptor_name = ls_component_descriptor-name."2033356
      TRANSLATE lv_descriptor_name USING '-_'.   "2033356
      "ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <ls_out_data> TO <lv_out_data>."2033356
      ASSIGN COMPONENT  lv_descriptor_name OF STRUCTURE <ls_out_data> TO <lv_out_data>."2033356
      ASSERT sy-subrc = 0.
      " first get technical or business info from coding
      <lv_out_data> = me->get_field_business_or_techn( iv_node_name  = lv_technical_node_name    " Node Name
                                                       iv_field_name = ls_component_descriptor-name ).
      " if it didn't return anything, decide based on component descriptor
      IF <lv_out_data> IS INITIAL.
        IF ls_component_descriptor-is_technical = abap_true.
          <lv_out_data> = gc_metadata_technical_field. " Technical Field
        ELSE.
          <lv_out_data> = gc_metadata_business_field. " Business Field
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lt_component_descriptor IS NOT INITIAL.
      INSERT <ls_out_data> INTO TABLE <lt_out_data>.
      CLEAR <ls_out_data>.
    ENDIF.


*--------------------------------------------------------------------*
*   Put metadata entry 4 - field types
*--------------------------------------------------------------------*
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 4.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-metadata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 4.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation   OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = /plmb/if_exp_c=>gc_component_descr_type-string.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = /plmb/if_exp_c=>gc_component_descr_type-integer.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = /plmb/if_exp_c=>gc_component_descr_type-string.
    ENDIF.
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lv_add_comprel = abap_true.
        ASSIGN COMPONENT gc_additional_field_comprel_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = /plmb/if_exp_c=>gc_component_descr_type-string.
      ENDIF.
      IF lv_add_ref_qty = abap_true.
        ASSIGN COMPONENT gc_additional_field_ref_qty_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = /plmb/if_exp_c=>gc_component_descr_type-string.
      ENDIF.
    ENDIF.
    LOOP AT lt_component_descriptor INTO ls_component_descriptor.
      lv_descriptor_name = ls_component_descriptor-name."2033356
      TRANSLATE lv_descriptor_name USING '-_'.   "2033356
      "ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      ASSIGN COMPONENT lv_descriptor_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      ASSERT sy-subrc = 0.
      <lv_out_data> = ls_component_descriptor-type.
    ENDLOOP.
    IF lt_component_descriptor IS NOT INITIAL.
      INSERT <ls_out_data> INTO TABLE <lt_out_data>.
      CLEAR <ls_out_data>.
    ENDIF.
  ENDIF.


*--------------------------------------------------------------------*
*   Special handling of long text
*   lt_data_longtext will contain the same number of lines as <node_data_table_rtti_tab>
*--------------------------------------------------------------------*
  IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
     ( lv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink OR
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext ) ).

    IF lv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink.
      lv_longtext_node_name = /plmb/if_spc_attr=>gc_node_doclink.
      lv_longtext_target_node_name = /plmb/if_spc_attr=>gc_node_doclink_popup.
    ELSEIF lv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      lv_longtext_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      lv_longtext_target_node_name = /plmb/if_spc_attr=>gc_node_longtext_popup.
    ENDIF.

    LOOP AT <node_data_table_rtti_tab> INTO <node_data_struct_rtti>.
      MOVE-CORRESPONDING <node_data_struct_rtti> TO ls_id_longtext.
      IF ls_id_longtext IS NOT INITIAL.                                   "1975584
      APPEND ls_id_longtext TO lt_id_longtext.
      mo_spi_connector_spc->retrieve(
        EXPORTING
          iv_node_name        = lv_longtext_target_node_name              "1975584
*         iv_node_name        = lv_longtext_node_name    " Node name      "1975584
*         iv_target_node_name = lv_longtext_target_node_name "Target node "1975584
          it_node_id          = lt_id_longtext    " Node ID
*         it_requested_field  =     " Requested Fields of Node Data
*         iv_lock             =     " Locking indicator
        IMPORTING
*         ev_failed           =     " Failed indicator
*         et_index_failed     =     " Index of node ID for which no data is availab
          et_node_data        = lt_data_longtext_tmp    " Node ID and node data
*         et_node_id_rel      =     " Relationship between index of source and target node ID
      ).
      CLEAR ls_data_longtext.
      READ TABLE lt_data_longtext_tmp INDEX 1 INTO ls_data_longtext.
      IF sy-subrc <> 0.
        CLEAR ls_data_longtext.
      ENDIF.
      APPEND ls_data_longtext TO lt_data_longtext. " append empty line of there is no longtext
      ENDIF.                                                                  "1975584
      CLEAR lt_id_longtext.
    ENDLOOP.
  ENDIF.


*--------------------------------------------------------------------*
*   Fill additional fields table (SORT SEQUENCE, USAGE)
*--------------------------------------------------------------------*
  IF et_additional_fields IS REQUESTED AND
     ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree AND
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ).
    LOOP AT <node_data_table_rtti_tab> INTO <node_data_struct_rtti>.
      ls_additional_fields-instance_number = sy-tabix.
      ASSIGN COMPONENT gc_component_name_sortseq OF STRUCTURE <node_data_struct_rtti> TO <lv_out_data>.
      IF sy-subrc = 0.
        ls_additional_fields-sort_sequence = <lv_out_data>.
      ENDIF.
      ASSIGN COMPONENT gc_component_name_usage OF STRUCTURE <node_data_struct_rtti> TO <lv_out_data>.
      IF sy-subrc = 0.
        ls_additional_fields-usage = <lv_out_data>.
      ENDIF.
      APPEND ls_additional_fields TO et_additional_fields.
      CLEAR ls_additional_fields.
    ENDLOOP.
  ENDIF.


*--------------------------------------------------------------------*
*   Put table data entries
*   Process data coming from the retrive (<node_data_table_rtti_tab>)
*--------------------------------------------------------------------*
  LOOP AT <node_data_table_rtti_tab> INTO <node_data_struct_rtti>.
    " for field control retrieval
    lv_tabix = sy-tabix.

    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    IF lv_table_already_exists = abap_true.
      <lv_out_data> = lv_engine_key_row_max + lv_tabix + 1. " starting from the maximal line number
    ELSE.
      <lv_out_data> = lv_tabix + 5. " starting from 5 because the first 4 lines are the metadata
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_spc_subid.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_composition OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_source      OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink     OR
       iv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext.
      READ TABLE lt_instance_number_rel INTO ls_instance_number_rel WITH KEY row_number = lv_tabix.
      IF sy-subrc = 0.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = ls_instance_number_rel-instance_number.
        READ TABLE it_additional_fields INTO ls_additional_fields WITH KEY instance_number = ls_instance_number_rel-instance_number.
        IF sy-subrc = 0.
          ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
          <lv_out_data> = ls_additional_fields-sort_sequence.
          " execute Alpha conversion for sort sequence
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = <lv_out_data>
            IMPORTING
              output = <lv_out_data>.
          SHIFT <lv_out_data> RIGHT DELETING TRAILING space.
          SHIFT <lv_out_data> LEFT  DELETING LEADING  space.
          ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
          <lv_out_data> = ls_additional_fields-usage.
        ENDIF.
      ENDIF.
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-tabledata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_tabix.
    IF iv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      <lv_out_data> = lv_tabix.
      ASSIGN COMPONENT gc_component_name_sortseq OF STRUCTURE <node_data_struct_rtti> TO <lv_out_spc_data>.
      IF sy-subrc = 0.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_sort_seq OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = <lv_out_spc_data>.
        " execute Alpha conversion for sort sequence
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = <lv_out_data>
          IMPORTING
            output = <lv_out_data>.
        SHIFT <lv_out_data> RIGHT DELETING TRAILING space.
        SHIFT <lv_out_data> LEFT  DELETING LEADING  space.
      ENDIF.
      ASSIGN COMPONENT gc_component_name_usage OF STRUCTURE <node_data_struct_rtti> TO <lv_out_spc_data>.
      IF sy-subrc = 0.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_meta_usage OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = <lv_out_spc_data>.
      ENDIF.
    ENDIF.
    IF iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
       lv_target_node_name = /plmb/if_spc_attr=>gc_node_composition.
      IF lv_add_comprel = abap_true.
        READ TABLE lt_comprel INDEX lv_tabix INTO ls_comprel.
        IF sy-subrc = 0.
          ASSIGN COMPONENT gc_additional_field_comprel_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
          <lv_out_data> = ls_comprel-comprel.
        ENDIF.
      ENDIF.
      IF lv_add_ref_qty = abap_true.
        ASSIGN COMPONENT gc_additional_field_ref_qty_ui OF STRUCTURE <ls_out_data> TO <lv_out_data>.
        <lv_out_data> = ls_node_data_ref_qty_text-ref_qty.
      ENDIF.
    ENDIF.

    LOOP AT lt_component_descriptor INTO ls_component_descriptor.

      " field control handling on row level - it is only needed in valuation instances table
      IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree       AND " if we are requesting PTREE
           lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ).    " VALUATION
        " filter out invisible fields (field control handling on row level)
        READ TABLE lt_row_properties INTO ls_row_property INDEX lv_tabix.
        IF sy-subrc = 0.
          READ TABLE ls_property_line-properties INTO ls_property
            WITH KEY node_field = ls_component_descriptor-name.
          IF sy-subrc = 0 AND
             ls_property-option = /plmb/if_spi_c=>gs_c_property-invisible.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_descriptor_name = ls_component_descriptor-name.
      TRANSLATE lv_descriptor_name USING '-_'.
      " find the appropriate components of source and target data
      "ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      ASSIGN COMPONENT lv_descriptor_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT ls_component_descriptor-name OF STRUCTURE <node_data_struct_rtti> TO <lv_out_spc_data>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

*--------------------------------------------------------------------*
*       Special handling for dates - convert to external format
*--------------------------------------------------------------------*
      IF ls_component_descriptor-is_date_type = abap_true.
        lv_in_date = <lv_out_spc_data>.
        lv_out_data = /plmb/cl_exp_tools=>convert_date_time_to_external(
          iv_date = lv_in_date
        ).
        <lv_out_data> = lv_out_data.

*--------------------------------------------------------------------*
*       Special handling for times - convert to external format
*--------------------------------------------------------------------*
      ELSEIF ls_component_descriptor-is_time_type = abap_true.
        lv_new_string = <lv_out_spc_data>.
        REPLACE ALL OCCURRENCES OF PCRE '[^0-9]' IN lv_new_string WITH ''. "3259035
        lv_in_time = lv_new_string.
        lv_out_data = /plmb/cl_exp_tools=>convert_date_time_to_external(
          iv_time = lv_in_time
        ).
        <lv_out_data> = lv_out_data.

*--------------------------------------------------------------------*
*       Special handling for unit of measures - convert to display format
*--------------------------------------------------------------------*
      ELSEIF ls_component_descriptor-is_uom_type = abap_true.
        lv_in_data = <lv_out_spc_data>.
        IF lv_in_data IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = lv_in_data
*             LANGUAGE       = SY-LANGU
            IMPORTING
*             LONG_TEXT      =
              output         = lv_out_data
*             SHORT_TEXT     =
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            ls_spi_message-msgid = sy-msgid.
            ls_spi_message-msgno = sy-msgno.
            ls_spi_message-msgty = sy-msgty.
            ls_spi_message-msgv1 = sy-msgv1.
            ls_spi_message-msgv2 = sy-msgv2.
            ls_spi_message-msgv3 = sy-msgv3.
            ls_spi_message-msgv4 = sy-msgv4.
            APPEND ls_spi_message TO ct_message.
            <lv_out_data> = <lv_out_spc_data>.
          ELSE.
            <lv_out_data> = lv_out_data.
          ENDIF.
        ENDIF.

*--------------------------------------------------------------------*
*       Special handling of icon types
*--------------------------------------------------------------------*
      ELSEIF ls_component_descriptor-is_icon_type = abap_true.
        <lv_out_data> = /plmb/cl_exp_tools=>get_icon_text( <lv_out_spc_data> ).

*--------------------------------------------------------------------*
*       Special handling for language key - convert to display format
*--------------------------------------------------------------------*
      ELSEIF ls_component_descriptor-is_language_key_type = abap_true.
        lv_in_data = <lv_out_spc_data>.
        CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
          EXPORTING
            input  = lv_in_data
          IMPORTING
            output = lv_out_data.
        <lv_out_data> = lv_out_data.

*--------------------------------------------------------------------*
*       Normal filling of output field with the data without conversion
*--------------------------------------------------------------------*
      ELSE.

*--------------------------------------------------------------------*
*       Special handling of sort sequence
*--------------------------------------------------------------------*
        IF ( iv_node_name = /plmb/if_spc_attr=>gc_node_ptree AND
             lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ) AND
             ls_component_descriptor-name = gc_component_name_sortseq.
          " execute Alpha conversion for sort sequence
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = <lv_out_spc_data>
            IMPORTING
              output = <lv_out_data>.
          SHIFT <lv_out_data> RIGHT DELETING TRAILING space.
          SHIFT <lv_out_data> LEFT  DELETING LEADING  space.
        ENDIF.

*--------------------------------------------------------------------*
*         Special handling of longtexts
*--------------------------------------------------------------------*
        IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_valuation AND
           ( lv_target_node_name = /plmb/if_spc_attr=>gc_node_doclink OR
             lv_target_node_name = /plmb/if_spc_attr=>gc_node_longtext ) AND
             ls_component_descriptor-name = 'HEADER' ).     "#EC NOTEXT
          READ TABLE lt_data_longtext INDEX lv_tabix INTO ls_data_longtext.
          IF sy-subrc = 0.
            IF ls_data_longtext-longtext IS NOT INITIAL.
              <lv_out_data> = ls_data_longtext-longtext.
            ENDIF.
          ELSE.
            IF ls_component_descriptor-is_multiple = abap_true.
              <lv_out_data> = me->split_string( <lv_out_spc_data> ).
            ELSE.
              <lv_out_data> = <lv_out_spc_data>.
            ENDIF.
          ENDIF.
        ELSE.
          IF ls_component_descriptor-is_multiple = abap_true.
            <lv_out_data> = me->split_string( <lv_out_spc_data> ).
          ELSE.
            <lv_out_data> = <lv_out_spc_data>.
            if ls_component_descriptor-type = 'N'.                                     "2391922
              condense <lv_out_data>.                                                  "2391922
            endif.                                                                     "2391922
          ENDIF.
        ENDIF.

      ENDIF.
    ENDLOOP.

    " instance number shall be cleared if there is no valuation data
    IF <node_data_struct_rtti> IS INITIAL.
      ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_parent_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
      CLEAR <lv_out_data>.
    ENDIF.

    MOVE-CORRESPONDING <ls_out_data> TO <ls_out_data_str>.
    INSERT <ls_out_data_str> INTO TABLE <lt_out_data>.
    CLEAR <ls_out_data>.
    CLEAR <ls_out_data_str>.
  ENDLOOP.


*--------------------------------------------------------------------*
*   in case the data table is empty, put an initial line into the output
*--------------------------------------------------------------------*
  IF <node_data_table_rtti_tab> IS INITIAL AND
   ( ( ls_composition_info-tab_type IS NOT INITIAL )                   OR
     ( iv_node_name        <> /plmb/if_spc_attr=>gc_node_valuation   ) OR
     ( lv_target_node_name <> /plmb/if_spc_attr=>gc_node_composition ) ).
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    IF lv_table_already_exists = abap_true.
      <lv_out_data> = lv_engine_key_row_max + 1. " starting from the maximal line number
    ELSE.
      <lv_out_data> = 5. " starting from 5 because the first 4 lines are the metadata
    ENDIF.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_obj_id OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_spc_subid.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_technical_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_type_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_description_estcat.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_v_a_category OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = iv_esttype.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_technical_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_node_name_desc OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = lv_description_node_name.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = /plmb/if_exp_c=>gc_data_type-tabledata.
    ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_line_no OF STRUCTURE <ls_out_data> TO <lv_out_data>.
    <lv_out_data> = 1.

    MOVE-CORRESPONDING <ls_out_data> TO <ls_out_data_str>.
    INSERT <ls_out_data_str> INTO TABLE <lt_out_data>.
    CLEAR <ls_out_data>.
    CLEAR <ls_out_data_str>.
  ENDIF.


*--------------------------------------------------------------------*
* Update max row number in meta data table
*--------------------------------------------------------------------*
  me->update_max_row_number(
    EXPORTING
      iv_engine_value_assignment_typ = iv_technical_estcat    " Value Assignment Type
      iv_target_node_name            = iv_target_node_name    " Node Name
    CHANGING
      ct_table_data                  = ct_table_data    " Table Data for Download
      ct_table_meta_data             = ct_table_meta_data
  ).


*--------------------------------------------------------------------*
* Process Data Table - enhancement possibility to make changes
* (like field conversions) in the data table before providing it
* to the caller
*--------------------------------------------------------------------*
  me->process_table_data(
    EXPORTING
      iv_node_name        = iv_node_name
      iv_target_node_name = iv_target_node_name
      iv_technical_estcat = iv_technical_estcat
      iv_esttype          = iv_esttype
    CHANGING
      ct_table_data       = ct_table_data    " Table Data for Download
      ct_table_meta_data  = ct_table_meta_data
  ).


*--------------------------------------------------------------------*
*   Increase table number if data or definition was supplied (and there was data)
*--------------------------------------------------------------------*
  ADD 1 TO cv_table_no.


*--------------------------------------------------------------------*
*   Provide output data
*--------------------------------------------------------------------*
  IF et_val_id IS REQUESTED. " if et_val_id needs to be filled
    IF ( iv_node_name        = /plmb/if_spc_attr=>gc_node_ptree       AND " if we are requesting PTREE
         lv_target_node_name = /plmb/if_spc_attr=>gc_node_valuation ).    " VALUATION

      LOOP AT <node_data_table_rtti_tab> INTO <node_data_struct_rtti>.

        IF  <node_data_struct_rtti> IS NOT INITIAL.            "2426873
        " fill output table
        MOVE-CORRESPONDING <node_data_struct_rtti> TO ls_val_id.
        APPEND ls_val_id TO et_val_id.
        CLEAR ls_val_id.
        ENDIF.                                                 "2426873

      ENDLOOP.

    ENDIF.
  ENDIF.

ENDMETHOD.                    "get_valuation_data


METHOD process_additional_info_fields.

  DATA: lt_additional_info_fields TYPE /plmb/t_exp_additional_info_f,
        ls_additional_info_fields TYPE /plmb/s_exp_additional_info_f,
        ls_add_info               TYPE /plmb/s_exp_additional_info,
        lr_data                   TYPE REF TO data,
        lt_fields                 TYPE TABLE OF fieldname,
        lv_field                  TYPE fieldname.

  FIELD-SYMBOLS: <ls_data>          TYPE any,
                 <ls_add_info_data> TYPE any.

  CLEAR: ev_allerg_grp,
         ev_diet_group,
         ev_genmod_grp,
         ev_nutr_group,
         ev_relig_grp.

  IF it_add_info IS INITIAL.
    RETURN.
  ENDIF.

  me->get_additional_info_fields(
    IMPORTING
      et_additional_info_fields = lt_additional_info_fields
  ).
  IF lt_additional_info_fields IS INITIAL.
    RETURN.
  ENDIF.

  APPEND /plmi/if_spc_exp_c=>gc_additional_info-key_date TO lt_fields.   "2179985
  APPEND /plmi/if_spc_exp_c=>gc_additional_info-nutrient TO lt_fields.
  APPEND /plmi/if_spc_exp_c=>gc_additional_info-diet TO lt_fields.
  APPEND /plmi/if_spc_exp_c=>gc_additional_info-allergen TO lt_fields.
  APPEND /plmi/if_spc_exp_c=>gc_additional_info-religious TO lt_fields.
  APPEND /plmi/if_spc_exp_c=>gc_additional_info-gen_mod TO lt_fields.

  LOOP AT lt_fields INTO lv_field.
    READ TABLE it_add_info INTO ls_add_info WITH KEY fname = lv_field.
    IF sy-subrc = 0.
      READ TABLE lt_additional_info_fields INTO ls_additional_info_fields WITH KEY fname = ls_add_info-fname.
      IF sy-subrc = 0.
        ASSIGN ls_add_info-value->* TO <ls_add_info_data>.
        CREATE DATA lr_data TYPE (ls_additional_info_fields-typename).
        ASSIGN lr_data->* TO <ls_data>.
        IF <ls_add_info_data> IS ASSIGNED.
          <ls_data> = <ls_add_info_data>.
        ENDIF.
        CASE lv_field.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-key_date.          "2179985
            ev_key_date   = <ls_data>.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-nutrient.
            ev_nutr_group = <ls_data>.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-diet.
            ev_diet_group = <ls_data>.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-allergen.
            ev_allerg_grp = <ls_data>.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-religious.
            ev_relig_grp = <ls_data>.
          WHEN /plmi/if_spc_exp_c=>gc_additional_info-gen_mod.
            ev_genmod_grp = <ls_data>.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD process_component_descriptor.                        "#EC NEEDED

  " Default implementation is empty
  " Customer can change type of a field in a value assignment type

ENDMETHOD.


METHOD process_table_data.                                  "#EC NEEDED

  " this method makes it possible for the customer to process
  " data table before providing it to the output
  " it can be used for field conversions
  " the default implementation executes Alpha conversion
  " for the sort sequence field

  FIELD-SYMBOLS: <ls_table_meta_data>  TYPE ty_s_table_meta_data,
                 <ls_table_data>       TYPE /plmb/s_exp_table_data_export,
                 <ls_table_data_line>  TYPE any,
                 <ls_table_data_tab>   TYPE ANY TABLE,
                 <ls_table_data_field> TYPE any.

  IF iv_node_name = /plmb/if_spc_attr=>gc_node_valuation.
    READ TABLE ct_table_meta_data
      ASSIGNING <ls_table_meta_data>
      WITH KEY engine_value_assignment_type = iv_technical_estcat
               target_node_name             = iv_target_node_name.
    IF sy-subrc = 0.
      READ TABLE ct_table_data ASSIGNING <ls_table_data>
        WITH KEY table_no = <ls_table_meta_data>-table_no.
      IF sy-subrc = 0.
        ASSIGN <ls_table_data>-table_data->* TO <ls_table_data_tab>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
        LOOP AT <ls_table_data_tab> ASSIGNING <ls_table_data_line>.
          ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_datatype OF STRUCTURE <ls_table_data_line> TO <ls_table_data_field>.
          IF sy-subrc = 0.
            IF <ls_table_data_field> = /plmb/if_exp_c=>gc_data_type-tabledata.
              ASSIGN COMPONENT 'ORD' OF STRUCTURE <ls_table_data_line> TO <ls_table_data_field>.
              IF sy-subrc = 0.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                  EXPORTING
                    input  = <ls_table_data_field>
                  IMPORTING
                    output = <ls_table_data_field>.
                SHIFT <ls_table_data_field> RIGHT DELETING TRAILING space.
                SHIFT <ls_table_data_field> LEFT  DELETING LEADING  space.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD set_key_date.

* Set key date in EH&S BO                                    "2179985

  DATA:
*--------------------------------------------------------------------*
*       Retrieve Specification Header
*--------------------------------------------------------------------*
    lt_spc_id_temp   TYPE /plmb/t_spc_id_sp,
    ls_spc_id_temp   TYPE /plmb/s_spc_id_sp,
    lt_spc_data_temp TYPE /plmb/t_spc_bas_header_sp,
    ls_spc_data_temp TYPE /plmb/s_spc_bas_header_sp,
    lt_spc_bas_init  TYPE /plmb/t_spc_bas_init_id_sp,
    ls_spc_bas_init  TYPE /plmb/s_spc_bas_init_id_sp,

*--------------------------------------------------------------------*
*       Error and message handling
*--------------------------------------------------------------------*
    lv_failed        TYPE /plmb/spi_failed_ind,
    lt_index_failed  TYPE /plmb/t_spi_rtr_index_failed,
    ls_spi_message   TYPE /plmb/s_spi_msg,
    lt_message       TYPE /plmb/t_spi_coll_message_node,
    ls_message       TYPE /plmb/s_spi_coll_message_node,
    lv_severity      TYPE /plmb/spi_msg_severity.


  CLEAR ev_failed.

  " Key date may be initial => when it is initial then
  " sy-datum is set

  IF it_spc_id IS INITIAL.
    RETURN.
  ENDIF.

  " We just require 1 SUBID to change the key data
  " => get SUBID for RECN
  READ TABLE it_spc_id INTO ls_spc_id_temp INDEX 1.

  APPEND ls_spc_id_temp TO lt_spc_id_temp.
  mo_spi_connector_spc->retrieve(
    EXPORTING
      iv_node_name        = /plmb/if_spc_attr=>gc_node_basic_header
      it_node_id          = lt_spc_id_temp
    IMPORTING
      ev_failed           = lv_failed
      et_index_failed     = lt_index_failed
      et_node_data        = lt_spc_data_temp
  ).

  IF lv_failed = abap_true OR
     lt_index_failed IS NOT INITIAL.
    mo_spi_collector_spc->get_messages(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_basic_header    " Node Name
*         iv_init_buffer =     " Remove exported messages from buffer
      IMPORTING
        et_messages    = lt_message    " Message table
        ev_severity    = lv_severity    " Message Severity
    ).

    LOOP AT lt_message INTO ls_message.
      MOVE-CORRESPONDING ls_message TO ls_spi_message.
      APPEND ls_spi_message TO ct_message.
    ENDLOOP.
    IF lv_severity CA /plmi/cl_spc_message=>gc_sv_aex.
      ev_failed = abap_true.
      RETURN.
    ENDIF.
  ENDIF.

  READ TABLE lt_spc_data_temp INDEX 1 INTO ls_spc_data_temp.


  " INIT Node sets automatically sy-datum when key date is not set.
  ls_spc_bas_init-subid   =  ls_spc_data_temp-subid.
  ls_spc_bas_init-objtype =  ls_spc_data_temp-objtype.
  ls_spc_bas_init-keydate = iv_key_date.
  APPEND ls_spc_bas_init TO lt_spc_bas_init.

  " Here key date is set
  mo_spi_connector_spc->retrieve(
      EXPORTING
        iv_node_name        = /plmb/if_spc_attr=>gc_node_init_screen
        it_node_id          = lt_spc_bas_init
      IMPORTING
        ev_failed           = lv_failed
        et_index_failed     = lt_index_failed
  ).

  IF lv_failed = abap_true OR lt_index_failed IS NOT INITIAL.
    mo_spi_collector_spc->get_messages(
      EXPORTING
        iv_node_name   = /plmb/if_spc_attr=>gc_node_init_screen
      IMPORTING
        et_messages    = lt_message    " Message table
        ev_severity    = lv_severity    " Message Severity
    ).

    LOOP AT lt_message INTO ls_message.
      MOVE-CORRESPONDING ls_message TO ls_spi_message.
      APPEND ls_spi_message TO ct_message.
    ENDLOOP.
    IF lv_severity CA /plmi/cl_spc_message=>gc_sv_aex.
      ev_failed = abap_true.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD split_string.

  DATA: lv_string TYPE string.

  lv_string = iv_string.

  REPLACE ALL OCCURRENCES OF gc_multivalue_separator IN lv_string WITH cl_abap_char_utilities=>newline.

  rv_string = lv_string.

ENDMETHOD.


METHOD table_reference_exists.

  FIELD-SYMBOLS: <ls_table_meta_data> TYPE ty_s_table_meta_data.

  rv_table_already_exists = abap_false.

  READ TABLE it_table_meta_data ASSIGNING <ls_table_meta_data>
    WITH KEY engine_value_assignment_type = iv_engine_value_assignment_typ
             target_node_name             = iv_target_node_name.
  IF sy-subrc = 0.
    READ TABLE it_table_data TRANSPORTING NO FIELDS
      WITH KEY table_no = <ls_table_meta_data>-table_no.    "#EC WARNOK
    IF sy-subrc = 0.
      rv_table_already_exists = abap_true.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD update_data_buffer.

  me->mt_table_data        = it_table_data.
  me->mv_table_data_filled = abap_true.
  me->mv_buffer_upd_dats   = sy-datum.

ENDMETHOD.                    "update_data_buffer


METHOD update_definition_buffer.

  me->mt_table_definition        = it_table_defintion.
  me->mv_table_definition_filled = abap_true.
  me->mv_buffer_upd_dats         = sy-datum.

ENDMETHOD.                    "update_definition_buffer


METHOD update_groups_buffer.

  me->mv_nutr_group = iv_nutr_group.
  me->mv_diet_group = iv_diet_group.
  me->mv_allerg_grp = iv_allerg_grp.
  me->mv_relig_grp  = iv_relig_grp.
  me->mv_genmod_grp = iv_genmod_grp.
  me->mv_key_date   = iv_key_date.
  me->mv_groups_filled = abap_true.

ENDMETHOD.


METHOD update_max_row_number.

  FIELD-SYMBOLS: <ls_table_meta_data> TYPE ty_s_table_meta_data,
                 <ls_table_data>      TYPE /plmb/s_exp_table_data_export,
                 <lt_data>            TYPE ANY TABLE.

  READ TABLE ct_table_meta_data ASSIGNING <ls_table_meta_data>
    WITH KEY engine_value_assignment_type = iv_engine_value_assignment_typ
             target_node_name             = iv_target_node_name.
  IF sy-subrc = 0.
    READ TABLE ct_table_data ASSIGNING <ls_table_data>
      WITH KEY table_no = <ls_table_meta_data>-table_no. "#EC WARNOK
    IF sy-subrc = 0.
      ASSIGN <ls_table_data>-table_data->* TO <lt_data>.
      IF sy-subrc = 0.
        <ls_table_meta_data>-engine_key_row_max = lines( <lt_data> ).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
