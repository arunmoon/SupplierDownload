class /PLMU/CL_EXP_EXPORT_TO_EXCEL definition
  public
  final
  create public .

public section.

  interfaces /PLMU/IF_EXP_EXPORT_DATA .

  methods EXPORT_COMPARISON_TABLE
    importing
      !IT_DATA type ANY TABLE
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE optional
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID optional
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO optional
      !IV_NEW_EXCEL type BOOLE_D optional
      !IV_END_EXCEL type BOOLE_D optional
      !IV_HEADER_ROW_KEY type STRING optional
      !IV_FILENAME type STRING optional
      !IV_TABLE_PARENT_NUMBER type I optional
      !IV_TABLE_NUMBER type I optional
      !IV_DISPLAY_EMPTY_TABLE type BOOLE_D default ABAP_FALSE
      !IV_ROW_KEY_EMPHASIZED type BOOLE_D default ABAP_FALSE .
  methods EXPORT_HEADER_GROUP_TABLE
    importing
      !IT_DATA type ANY TABLE
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IT_HEADER_GROUP type /PLMB/T_EXP_TABLE_HEADER_GRP
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE optional
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID optional
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO optional
      !IV_NEW_EXCEL type BOOLE_D optional
      !IV_END_EXCEL type BOOLE_D optional
      !IV_FILENAME type STRING optional
      !IV_TABLE_PARENT_NUMBER type I optional
      !IV_TABLE_NUMBER type I optional .
  methods EXPORT_SINGLE_TABLE
    importing
      !IT_DATA type ANY TABLE
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE optional
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID optional
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO optional
      !IV_NEW_EXCEL type BOOLE_D optional
      !IV_END_EXCEL type BOOLE_D optional
      !IV_FILENAME type STRING optional
      !IV_TABLE_PARENT_NUMBER type I optional
      !IV_TABLE_NUMBER type I optional .
protected section.
*"* protected components of class /PLMU/CL_EXP_EXPORT_TO_EXCEL
*"* do not include other source files here!!!
private section.

  types:
    BEGIN OF ts_style_cell,
            decimals     TYPE i,
            lv_tag_begin TYPE char255,
            lv_tag_end   TYPE char255,
          END OF ts_style_cell .
  types:
    tt_style_cell TYPE STANDARD TABLE OF ts_style_cell .
  types:
    BEGIN OF ts_columns,
          engine_col_key TYPE i,
          header_text    TYPE char255,
         END OF ts_columns .
  types:
    BEGIN OF ts_rows,
          engine_row_key TYPE i,
          engine_col_key TYPE i,
          data           TYPE REF TO data,
         END OF ts_rows .
  types:
    tt_rows TYPE TABLE OF ts_rows .
  types:
    BEGIN OF ts_table_fields,
          fieldname TYPE  fieldname,
          index     TYPE  i,
          col       TYPE  boole_d,
         END OF ts_table_fields .
  types:
    tt_table_fields TYPE TABLE OF ts_table_fields .

  type-pools ABAP .
  constants GC_ENCODING type ABAP_ENCOD value 'UTF-8'. "#EC NOTEXT
  constants GC_FILENAME type CHAR255 value 'Table.xml'. "#EC NOTEXT
  constants GC_MIMETYPE type STRING value 'application/msexcel'. "#EC NOTEXT
  data MT_STYLE_CELLS type TT_STYLE_CELL .
  constants:
    BEGIN OF gc_tag,
                worksheet_begin                      TYPE char255 VALUE '<Worksheet ss:Name="',
                worksheet_end                        TYPE char255 VALUE '</Worksheet>',
                row_begin                            TYPE char255 VALUE '<Row>',
                row_begin_with_hyphen                TYPE char255 VALUE '<Row ss:StyleID="cut">',
                row_end                              TYPE char255 VALUE '</Row>',
                data_cell_header                     TYPE char255 VALUE '<Cell ss:StyleID="H"><Data ss:Type="String">',
                data_cell_table_header               TYPE char255 VALUE '<Cell ss:StyleID="TH"><Data ss:Type="String">',
                data_cell                            TYPE char255 VALUE '<Cell><Data ss:Type="String">',
                data_cell_row_key                    TYPE char255 VALUE '<Cell ss:StyleID="H"><Data ss:Type="String">',
                data_cell_number                     TYPE char255 VALUE '<Cell><Data ss:Type="Number">',
                data_cell_merge_down                 TYPE char255 VALUE '<Cell><Data ss:Type="String" ss:MergeDown="',
                data_cell_number_merge_down          TYPE char255 VALUE '<Cell><Data ss:Type="Number" ss:MergeDown="',
                data_cell_row_key_number             TYPE char255 VALUE '<Cell ss:StyleID="H"><Data ss:Type="Number">',
                data_cell_row_key_merge_down         TYPE char255 VALUE '<Cell ss:StyleID="H"><Data ss:Type="String" ss:MergeDown="',
                data_cell_rk_number_merge_down       TYPE char255 VALUE '<Cell ss:StyleID="H"><Data ss:Type="Number" ss:MergeDown="',
                data_cell_end                        TYPE char255 VALUE '</Data></Cell>',
                table_begin                          TYPE char255 VALUE '<Table>',
                table_end                            TYPE char255 VALUE '</Table>',
                data_cell_merge_header_part1         TYPE char255 VALUE '<Cell ss:MergeAcross="',
                data_cell_merge_header_part2         TYPE char255 VALUE '" ss:StyleID="H"><Data ss:Type="String">',
                data_cell_header_info                TYPE char255 VALUE '<Cell ss:StyleID="HI"><Data ss:Type="String">',
              END OF gc_tag .
  data MT_XML type STRING_TABLE .
  data MV_TABLE_INDEX type I .
  data MV_INSERT_INDEX type I .
  data MV_ROW_KEY type BOOLE_D .

  methods UPDATE_DEFINITION
    importing
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IT_OUT_TABLES type /PLMB/T_EXP_TABLES
    exporting
      !ET_DEF_UPD type /PLMB/T_EXP_TABLE_DEFINITION .
  methods ADD_ADDITIONAL_EMPTY_ROWS
    importing
      !IV_NUMBER_ROWS type I .
  methods SET_MERGED_FIELDS
    importing
      !IT_ROWS type TT_ROWS
      !IV_MERGE type I
      !IT_TABLE_FIELDS type TT_TABLE_FIELDS
      !IV_ROW_COLUMNS type I
      !IV_COLUMNS type I
    changing
      !CT_XML type STRING_TABLE .
  methods EXPORT_COMPARE_OBJECT_TYPE
    importing
      !IT_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO
      !IV_HEADER_ROW_KEY type STRING
      !IV_FILENAME type STRING .
  methods EXPORT_SINGLE_OBJECT_TYPE
    importing
      !IT_DATA type /PLMB/T_EXP_TABLE_DATA_EXPORT
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO
      !IV_HEADER_ROW_KEY type STRING
      !IV_FILENAME type STRING .
  methods END_EXCEL
    importing
      !IT_DATA type ANY TABLE
      !IT_DEF type /PLMB/T_EXP_TABLE_DEFINITION
      !IV_GOS_TYPE type /PLMB/GOS_OBJECT_TYPE
      !IV_VARIANT_ID type /PLMB/EXP_VARIANT_ID
      !IV_FILENAME type STRING .
  methods END_TABLE_AND_WORKSHEET .
  methods REPLACE_XML_CONTROL_CHARACTERS
    changing
      !CV_STRING type STRING .
  methods GENERATE_XML_LINE_FOR_CELL
    importing
      !IV_DATA type ANY optional
      !IV_MERGE_DOWN type I optional
      !IV_INDEX type I optional
      !IV_ROW_KEY type BOOLE_D default ABAP_FALSE
      !IV_INSERT_AT_TAG type STRING optional
    changing
      !CT_XML type STRING_TABLE .
  methods GENERATE_XML_LINE_FOR_EPT_CELL
    importing
      !IV_MERGE_DOWN type I optional
      !IV_INDEX type I optional
      !IV_ROW_KEY type BOOLE_D default ABAP_FALSE
    changing
      !CT_XML type STRING_TABLE .
  methods CREATE_XML_HEADER
    changing
      !CT_XML type STRING_TABLE .
  methods GENERATE_STYLES
    importing
      !IS_DATA type ANY
    changing
      !CT_XML type STRING_TABLE .
  methods GENERATE_DECIMAL_STYLES
    importing
      !IO_STRUCT type ref to CL_ABAP_STRUCTDESCR optional
    exporting
      !ET_XML type STRING_TABLE .
  methods SET_HEADER_INFORMATION
    importing
      !IT_EXPORT_HEADER_DATA type /PLMB/T_EXP_HEADER_INFO
    changing
      !CT_XML type STRING_TABLE .
ENDCLASS.



CLASS /PLMU/CL_EXP_EXPORT_TO_EXCEL IMPLEMENTATION.


METHOD /plmu/if_exp_export_data~export_data.

  DATA: lt_def TYPE /plmb/t_exp_table_definition.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_data IS INITIAL OR it_def IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Update Definition Table
*--------------------------------------------------------------------*
  IF it_out_tables IS SUPPLIED.
    CALL METHOD update_definition
      EXPORTING
        it_def        = it_def
        it_out_tables = it_out_tables
      IMPORTING
        et_def_upd    = lt_def.
  ELSE.
    lt_def = it_def.
  ENDIF.

*--------------------------------------------------------------------*
* Put Data to File According to Type
*--------------------------------------------------------------------*
  CASE iv_export_object_type.
    WHEN /plmb/if_exp_c=>gc_exp_object_type-single.
      CALL METHOD export_single_object_type
        EXPORTING
          it_data               = it_data
          it_def                = lt_def
          iv_gos_type           = iv_gos_type
          iv_variant_id         = iv_variant_id
          it_export_header_data = it_export_header_data
          iv_header_row_key     = iv_header_row_key
          iv_filename           = iv_filename.
    WHEN /plmb/if_exp_c=>gc_exp_object_type-compare.
      CALL METHOD export_compare_object_type
        EXPORTING
          it_data               = it_data
          it_def                = lt_def
          iv_gos_type           = iv_gos_type
          iv_variant_id         = iv_variant_id
          it_export_header_data = it_export_header_data
          iv_header_row_key     = iv_header_row_key
          iv_filename           = iv_filename.
  ENDCASE.

ENDMETHOD.


METHOD add_additional_empty_rows.

  DO iv_number_rows TIMES.
    APPEND gc_tag-row_begin TO mt_xml.
    APPEND gc_tag-row_end TO mt_xml.
  ENDDO.

ENDMETHOD.


METHOD CREATE_XML_HEADER.

  APPEND '<?xml version="1.0"?>' TO ct_xml.                 "#EC NOTEXT
  APPEND '<?mso-application progid="Excel.Sheet"?>' TO ct_xml. "#EC NOTEXT
  APPEND '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' TO ct_xml. "#EC NOTEXT
  APPEND ' xmlns:o="urn:schemas-microsoft-com:office:office"' TO ct_xml. "#EC NOTEXT
  APPEND ' xmlns:x="urn:schemas-microsoft-com:office:excel"' TO ct_xml. "#EC NOTEXT
  APPEND ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' TO ct_xml. "#EC NOTEXT
  APPEND ' xmlns:html="http://www.w3.org/TR/REC-html40">' TO ct_xml. "#EC NOTEXT
  APPEND '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' TO ct_xml. "#EC NOTEXT
  APPEND '<ProtectWindows>False</ProtectWindows>' TO ct_xml. "#EC NOTEXT
  APPEND '</ExcelWorkbook>' TO ct_xml.

ENDMETHOD.


METHOD end_excel.

  DATA: lv_xml      TYPE string,
        lv_xml_out  TYPE string,
        lo_conv_out TYPE REF TO cl_abap_conv_out_ce,
        lv_content  TYPE xstring,
        lv_filename TYPE string,

        lv_index    TYPE i,

        lo_badi TYPE REF TO /plmu/exp_file.

*--------------------------------------------------------------------*
* End Table and Worksheet
*--------------------------------------------------------------------*
  CALL METHOD end_table_and_worksheet.

  " Workbook was opened in table Header
  APPEND '</Workbook>' TO mt_xml.                           "#EC NOTEXT

*--------------------------------------------------------------------*
* Concatenate Table to one String and convert
*--------------------------------------------------------------------*
  LOOP AT mt_xml INTO lv_xml.
    CONCATENATE lv_xml_out lv_xml cl_abap_char_utilities=>cr_lf INTO lv_xml_out.
  ENDLOOP.

  lo_conv_out = cl_abap_conv_out_ce=>create( encoding = gc_encoding ).

  CALL METHOD lo_conv_out->convert
    EXPORTING
      data   = lv_xml_out
    IMPORTING
      buffer = lv_content.

*--------------------------------------------------------------------*
* Call BAdI to update the file
*--------------------------------------------------------------------*

  TRY.
      IF iv_gos_type IS NOT INITIAL AND iv_variant_id IS NOT INITIAL.
        GET BADI lo_badi
          FILTERS
            gos_type = iv_gos_type
            variant  = iv_variant_id.
      ENDIF.

    CATCH cx_badi_not_implemented.
* No implementation is OK, as it is optional -> no error msg is necessary
    CATCH cx_badi_filter_error
          cx_badi_multiply_implemented.
      ASSERT 1 = 0.
* Multiple implementation or filter error will dump -> is forbidden
  ENDTRY.

  TRY.
      IF lo_badi IS BOUND.
        CALL BADI lo_badi->update_file
          EXPORTING
            iv_export_type = /plmb/if_exp_c=>gc_exp_type-excel
            it_data        = it_data
            it_def         = it_def
          CHANGING
            cv_file        = lv_content.
      ENDIF.

    CATCH cx_root.
* No implementation is OK, as it is optional -> no error msg is necessary
  ENDTRY.

*--------------------------------------------------------------------*
* attach the file to response
*--------------------------------------------------------------------*
  IF iv_filename IS NOT INITIAL.
    CONCATENATE iv_filename '.xml' INTO lv_filename.
  ELSE.
    lv_filename = gc_filename.
  ENDIF.

  CALL METHOD cl_wd_runtime_services=>attach_file_to_response
    EXPORTING
      i_filename      = lv_filename
      i_content       = lv_content
      i_mime_type     = gc_mimetype
      i_in_new_window = abap_false
      i_inplace       = abap_false.

ENDMETHOD.


METHOD END_TABLE_AND_WORKSHEET.

  DATA: lv_xml      TYPE string,
        lv_index    TYPE i.

*--------------------------------------------------------------------*
* Remove tailing empty rows                                  " 1882712
*--------------------------------------------------------------------*
  DATA lv_index_minus TYPE i.                                " 1882712
  DO.
    lv_index       = lines( mt_xml ).
    lv_index_minus = lv_index - 1.
    IF lv_index < 2. EXIT. ENDIF.
    READ TABLE mt_xml INTO lv_xml INDEX lv_index_minus.
    IF lv_xml = gc_tag-row_begin.
      READ TABLE mt_xml INTO lv_xml INDEX lv_index.
      IF lv_xml = gc_tag-row_end.
        DELETE mt_xml INDEX lv_index.
        DELETE mt_xml INDEX lv_index_minus.
      ELSE.
        EXIT.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.                                                     " 1882712

*--------------------------------------------------------------------*
* End Table and Worksheet
*--------------------------------------------------------------------*
  lv_index = lines( mt_xml ) - 1.
  READ TABLE mt_xml INTO lv_xml INDEX lv_index.
  IF lv_xml <> gc_tag-table_end.
    lv_index = lines( mt_xml ).
    READ TABLE mt_xml INTO lv_xml INDEX lv_index.
    IF lv_xml <> gc_tag-table_end.
      APPEND gc_tag-table_end TO mt_xml.
    ENDIF.
  ENDIF.

  lv_index = lines( mt_xml ).
  READ TABLE mt_xml INTO lv_xml INDEX lv_index.
  IF lv_xml <> gc_tag-worksheet_end.
    APPEND gc_tag-worksheet_end TO mt_xml.
  ENDIF.

ENDMETHOD.


METHOD export_compare_object_type.

  DATA: lt_def       TYPE /plmb/t_exp_table_definition,
        ls_def       TYPE /plmb/s_exp_table_definition,
        ls_def_new   TYPE /plmb/s_exp_table_definition,
        lt_def_int   TYPE /plmb/t_exp_table_definition,
        ls_data      TYPE /plmb/s_exp_table_data_export,

        lv_index_from  TYPE i,          "Note 2370173
        lv_index_to    TYPE i,          "Note 2370173

        lv_new_table TYPE boole_d,
        lv_new_excel TYPE boole_d,
        lv_end_excel TYPE boole_d.

  FIELD-SYMBOLS:
        <ls_def>   TYPE /plmb/s_exp_table_definition,
        <lt_data>  TYPE ANY TABLE.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_data IS INITIAL OR it_def IS INITIAL.
    RETURN.
  ENDIF.

**--------------------------------------------------------------------*
** Clear First Page
**--------------------------------------------------------------------*
  lt_def = it_def.

*--------------------------------------------------------------------*
* Put Data to File
*--------------------------------------------------------------------*
  lv_new_excel = abap_true.
  CLEAR mv_table_index.
  LOOP AT lt_def INTO ls_def
    WHERE new_page = abap_false.

    CLEAR: lv_new_table.

    AT NEW table_no.                                    "#EC AT_LOOP_WH
*        lv_new_table = abap_true.                                   "2370173
        lv_index_from = sy-tabix.                                    "2370173
    ENDAT.

*-->Note 2370173 Performance:
*   APPENDing only the relevant records instead of table copy and deletion!
      AT END OF table_no.
        lv_new_table = abap_true. "trigger processing >AFTER< each block!
        lv_index_to = sy-tabix.
        CLEAR lt_def_int.
        APPEND LINES OF lt_def FROM lv_index_from TO lv_index_to TO lt_def_int.
      ENDAT.
*<--Note 2370173 Performance

    IF lv_new_table = abap_true.
      LOOP AT lt_def TRANSPORTING NO FIELDS
        WHERE table_no > ls_def-table_no.
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0.
        lv_end_excel = abap_true.
      ENDIF.
*      lt_def_int = lt_def.                                            "2370173
*      DELETE lt_def_int WHERE table_no <> ls_def-table_no.            "2370173
      READ TABLE it_data INTO ls_data
        WITH TABLE KEY table_no = ls_def-table_no.
      IF sy-subrc = 0.
        READ TABLE lt_def INTO ls_def_new
          WITH KEY table_no = ls_def-table_no.
        IF sy-subrc = 0.
          READ TABLE lt_def INTO ls_def INDEX sy-tabix - 1.
          IF ls_def-new_page = abap_true.
            INSERT ls_def INTO lt_def_int INDEX 1.
            CLEAR mv_table_index.
          ENDIF.
        ENDIF.
        ASSIGN ls_data-table_data->* TO <lt_data>.
        LOOP AT lt_def_int TRANSPORTING NO FIELDS
          WHERE rowkey = abap_true
             OR colkey = abap_true.
          EXIT.
        ENDLOOP.
        ADD 1 TO mv_table_index.
        IF sy-subrc = 0.
          CALL METHOD export_comparison_table
            EXPORTING
              it_data                = <lt_data>
              it_def                 = lt_def_int
              iv_gos_type            = iv_gos_type
              iv_variant_id          = iv_variant_id
              it_export_header_data  = it_export_header_data
              iv_new_excel           = lv_new_excel
              iv_end_excel           = lv_end_excel
              iv_header_row_key      = iv_header_row_key
              iv_filename            = iv_filename
              iv_table_number        = mv_table_index
              iv_display_empty_table = abap_true
              iv_row_key_emphasized  = abap_true.
        ELSE.
          CALL METHOD export_single_table
            EXPORTING
              it_data               = <lt_data>
              it_def                = lt_def_int
              iv_gos_type           = iv_gos_type
              iv_variant_id         = iv_variant_id
              it_export_header_data = it_export_header_data
              iv_new_excel          = lv_new_excel
              iv_end_excel          = lv_end_excel
              iv_table_number       = mv_table_index
              iv_filename           = iv_filename.
        ENDIF.

        lv_new_excel = abap_false.
      ELSE.
        IF lv_end_excel = abap_true.
          CALL METHOD end_excel
            EXPORTING
              it_data       = it_data
              it_def        = it_def
              iv_gos_type   = iv_gos_type
              iv_variant_id = iv_variant_id
              iv_filename   = iv_filename.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


METHOD export_comparison_table.

  DATA: lt_xml          TYPE        string_table,
        lv_xml          TYPE        string,
        lv_columns      TYPE        i,
        lv_columns_char TYPE        char255,
        ls_def          TYPE        /plmb/s_exp_table_definition,
        lo_struct       TYPE REF TO cl_abap_structdescr.

  DATA: lt_grp_columns  TYPE STANDARD TABLE OF ts_columns,
        ls_grp_columns  TYPE                   ts_columns,
        lv_number1      TYPE                   char1,
        lv_number2      TYPE                   char2,
        lv_number3      TYPE                   char3,
        lv_number4      TYPE                   char4,
        lv_pnumber1     TYPE                   char1,
        lv_pnumber2     TYPE                   char2,
        lv_pnumber3     TYPE                   char3,
        lv_pnumber4     TYPE                   char4,
        lv_header       TYPE                   string,
        lv_row_columns  TYPE                   i,
        lv_grp_columns  TYPE                   i.

  DATA: lt_rows         TYPE STANDARD TABLE OF ts_rows,
        lt_rows_int     TYPE STANDARD TABLE OF ts_rows,
        ls_rows         TYPE                   ts_rows,
        lv_rows         TYPE                   i,
        lv_row_key      TYPE                   boole_d,
        lv_row_fields   TYPE                   boole_d,
        lv_index        TYPE                   i,
        lv_insert_index TYPE                   i.

  DATA: lt_table_fields  TYPE        tt_table_fields,
        ls_table_field   TYPE        ts_table_fields,
        lv_table_index   TYPE        i,
        lo_datadescr     TYPE REF TO cl_abap_datadescr,
        lv_merge         TYPE        i.

  "Note: 2438594 - Display Recipe Description in MFE table header/export to excel
  DATA: lt_note_column   TYPE STANDARD TABLE OF ts_columns,
        ls_note_column   TYPE                   ts_columns,
        lv_rowkey_col_ch TYPE                   char255,
        lv_colkey_col_ch TYPE                   char255.

  FIELD-SYMBOLS:
        <lt_table>      TYPE ANY TABLE,
        <ls_data_ref>   TYPE any,
        <ls_data>       TYPE any,
        <lv_data>       TYPE any,
        <lv_col_key>    TYPE i,
        <lv_row_key>    TYPE i.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_def IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Clear Row Key
*--------------------------------------------------------------------*
  CLEAR mv_row_key.

*--------------------------------------------------------------------*
* Check for New Excel
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    CLEAR mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Create XML Header
*--------------------------------------------------------------------*
  IF mt_xml IS INITIAL.
    CALL METHOD create_xml_header
      CHANGING
        ct_xml = mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Generate Style and Structure
*--------------------------------------------------------------------*
  IF it_data IS NOT INITIAL.
    LOOP AT it_data ASSIGNING <ls_data>.
      EXIT.
    ENDLOOP.

    CALL METHOD generate_styles
      EXPORTING
        is_data = <ls_data>
      CHANGING
        ct_xml  = mt_xml.

    lo_struct ?= cl_abap_structdescr=>describe_by_data( <ls_data> ).
  ENDIF.

*--------------------------------------------------------------------*
* Open Worksheet and Table or create Empty Line
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    READ TABLE it_def INTO ls_def INDEX 1.
    IF ls_def-page_text IS NOT INITIAL.
      CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
    ELSE.
      lv_xml = ls_def-table_no.
      SHIFT lv_xml LEFT DELETING LEADING '0'.
      CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
      CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
    ENDIF.
    APPEND lv_xml TO mt_xml.
    APPEND gc_tag-table_begin TO mt_xml.
    CALL METHOD set_header_information
      EXPORTING
        it_export_header_data = it_export_header_data
      CHANGING
        ct_xml                = mt_xml.
  ELSE.
    APPEND gc_tag-row_begin TO lt_xml.
    APPEND gc_tag-row_end TO lt_xml.
    READ TABLE it_def INTO ls_def
      WITH KEY new_page = abap_true.
    IF sy-subrc = 0.
      CALL METHOD end_table_and_worksheet.
      IF ls_def-page_text IS NOT INITIAL.
        CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
      ELSE.
        CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
        CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
      ENDIF.
      READ TABLE mt_xml TRANSPORTING NO FIELDS
              WITH KEY table_line = lv_xml.
      IF sy-subrc = 0.
        lv_insert_index = sy-tabix.
        LOOP AT mt_xml TRANSPORTING NO FIELDS
          WHERE table_line = gc_tag-table_end.
          IF sy-tabix > lv_insert_index.
            lv_insert_index = sy-tabix.
            EXIT.
          ENDIF.
        ENDLOOP.
        CLEAR mv_insert_index.
      ELSE.
        CLEAR lt_xml.
        APPEND lv_xml TO lt_xml.
        APPEND gc_tag-table_begin TO lt_xml.
      ENDIF.
    ENDIF.
  ENDIF.

  IF it_data IS NOT INITIAL OR iv_display_empty_table = abap_true.

*--------------------------------------------------------------------*
* Create Table Header
*--------------------------------------------------------------------*
    IF iv_table_parent_number <> 0.
      WRITE iv_table_parent_number TO lv_pnumber4.
      SHIFT lv_pnumber4 LEFT DELETING LEADING '0'.
      CASE strlen( lv_pnumber4 ).
        WHEN 1.
          lv_pnumber1 = lv_pnumber4.
          lv_header = lv_pnumber1.
        WHEN 2.
          lv_pnumber2 = lv_pnumber4.
          lv_header = lv_pnumber2.
        WHEN 3.
          lv_pnumber3 = lv_pnumber4.
          lv_header = lv_pnumber3.
        WHEN OTHERS.
          lv_header = lv_pnumber4.
      ENDCASE.
    ENDIF.

    LOOP AT it_def INTO ls_def
      WHERE table_text IS NOT INITIAL.
      APPEND gc_tag-row_begin TO lt_xml.
      IF iv_table_number = 0.
        WRITE ls_def-table_no TO lv_number4.
      ELSE.
        WRITE iv_table_number TO lv_number4.
      ENDIF.
      SHIFT lv_number4 LEFT DELETING LEADING '0'.
      CASE strlen( lv_number4 ).
        WHEN 1.
          lv_number1 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number1 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number1 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.

        WHEN 2.
          lv_number2 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number2 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number2 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
        WHEN 3.
          lv_number3 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number3 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number3 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
        WHEN OTHERS.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number4 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number4 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
      ENDCASE.
      CONDENSE lv_header.
      CALL METHOD replace_xml_control_characters
        CHANGING
          cv_string = lv_header.
      CONCATENATE gc_tag-data_cell_table_header
                  lv_header
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.
      APPEND gc_tag-row_end TO lt_xml.
      EXIT.
    ENDLOOP.

*--------------------------------------------------------------------*
* Create Grouped Columns
*--------------------------------------------------------------------*
    READ TABLE it_def INTO ls_def
      WITH KEY nodedisplay = abap_true
               colkey       = abap_true.
    IF sy-subrc = 0.

      APPEND gc_tag-row_begin TO lt_xml.

* Create Row Key
*--------------------------
      LOOP AT it_def TRANSPORTING NO FIELDS
        WHERE rowkey      = abap_true
          AND nodedisplay = abap_true.
        ADD 1 TO lv_columns.
      ENDLOOP.

      ADD -1 TO lv_columns.

      WRITE lv_columns TO lv_columns_char LEFT-JUSTIFIED.
      lv_rowkey_col_ch = lv_columns_char. "Note: 2438594
      lv_header = iv_header_row_key.
      CALL METHOD replace_xml_control_characters
        CHANGING
          cv_string = lv_header.
      CONCATENATE gc_tag-data_cell_merge_header_part1
                  lv_columns_char
                  gc_tag-data_cell_merge_header_part2
                  lv_header
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.

* Get Columns under Column Key
*----------------------------
      CLEAR lv_columns.
      LOOP AT it_def TRANSPORTING NO FIELDS
        WHERE nodedisplay = abap_true
          AND colkey      = abap_false
          AND rowkey      = abap_false
          AND fieldname IS NOT INITIAL.
        ADD 1 TO lv_columns.
      ENDLOOP.

      ADD -1 TO lv_columns.
      WRITE lv_columns TO lv_columns_char LEFT-JUSTIFIED.
      lv_colkey_col_ch = lv_columns_char. "Note: 2438594

* Create Column Keys
*----------------------------
      LOOP AT it_data ASSIGNING <ls_data>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>.
        READ TABLE lt_grp_columns TRANSPORTING NO FIELDS
          WITH KEY engine_col_key = <lv_col_key>.
        IF sy-subrc <> 0 AND <lv_col_key> <> 0.
          CLEAR ls_grp_columns.
          ls_grp_columns-engine_col_key = <lv_col_key>.
          ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
          WRITE <lv_data> TO ls_grp_columns-header_text LEFT-JUSTIFIED.
          APPEND ls_grp_columns TO lt_grp_columns.
        ENDIF.
      ENDLOOP.

      SORT lt_grp_columns BY engine_col_key.
      LOOP AT lt_grp_columns INTO ls_grp_columns.
        ADD 1 TO lv_grp_columns.
        lv_header = ls_grp_columns-header_text.
        CALL METHOD replace_xml_control_characters
          CHANGING
            cv_string = lv_header.
        IF lv_columns > 0.
          CONCATENATE gc_tag-data_cell_merge_header_part1
                      lv_columns_char
                      gc_tag-data_cell_merge_header_part2
                      lv_header
                      gc_tag-data_cell_end
                 INTO lv_xml.
        ELSE.
          CONCATENATE gc_tag-data_cell_header
                      lv_header
                      gc_tag-data_cell_end
                 INTO lv_xml.
        ENDIF.
        APPEND lv_xml TO lt_xml.
      ENDLOOP.

      APPEND gc_tag-row_end TO lt_xml.

      IF lt_grp_columns IS INITIAL.
        CLEAR lv_columns.
        DO 3 TIMES.
          DELETE lt_xml INDEX lines( lt_xml ).
        ENDDO.
      ELSE.
        ADD 1 TO lv_columns.
        IF iv_row_key_emphasized = abap_true.
          mv_row_key = abap_true.
        ENDIF.
      ENDIF.

    ENDIF.

* Create Notes for Column Keys
*-----------------------------
    "Note: 2438594 - Display Recipe Description in MFE table header/export to excel
    READ TABLE it_def INTO ls_def
      WITH KEY colkey_note = abap_true.

    IF sy-subrc = 0.
*     Read the notes for each key column
      LOOP AT it_data ASSIGNING <ls_data>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>.
        READ TABLE lt_note_column TRANSPORTING NO FIELDS
          WITH KEY engine_col_key = <lv_col_key>.
        IF sy-subrc <> 0 AND <lv_col_key> <> 0.
          CLEAR ls_note_column.
          ls_note_column-engine_col_key = <lv_col_key>.
          ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
          WRITE <lv_data> TO ls_note_column-header_text LEFT-JUSTIFIED.
          APPEND ls_note_column TO lt_note_column.
        ENDIF.
      ENDLOOP.

*     Build up the XML
      APPEND gc_tag-row_begin TO lt_xml.

      CONCATENATE gc_tag-data_cell_merge_header_part1
                  lv_rowkey_col_ch
                  gc_tag-data_cell_merge_header_part2
                  "no text below the row key
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.

      SORT lt_note_column BY engine_col_key.
      LOOP AT lt_note_column INTO ls_note_column.
        lv_header = ls_note_column-header_text.
        CALL METHOD replace_xml_control_characters
          CHANGING
            cv_string = lv_header.

        CONCATENATE gc_tag-data_cell_merge_header_part1
                    lv_colkey_col_ch
                    gc_tag-data_cell_merge_header_part2
                    lv_header
                    gc_tag-data_cell_end
               INTO lv_xml.
        APPEND lv_xml TO lt_xml.
      ENDLOOP.

      APPEND gc_tag-row_end TO lt_xml.
    ENDIF.

*--------------------------------------------------------------------*
* Create Cells for Row Key and Column Key Fields
*--------------------------------------------------------------------*
    APPEND gc_tag-row_begin TO lt_xml.

    LOOP AT it_def INTO ls_def
      WHERE nodedisplay = abap_true
        AND rowkey      = abap_true.
      ADD 1 TO lv_table_index.
      CONCATENATE gc_tag-data_cell_header
                  ls_def-fieldtext
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.
      IF ls_def-fieldtype_name IS NOT INITIAL.
        lo_datadescr ?= cl_abap_datadescr=>describe_by_name( ls_def-fieldtype_name ).
        IF lo_datadescr->type_kind = cl_abap_datadescr=>typekind_table.
          ls_table_field-fieldname = ls_def-fieldname.
          ls_table_field-index     = lv_table_index.
          APPEND ls_table_field TO lt_table_fields.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lv_row_columns = lv_table_index.

    DO lv_grp_columns TIMES.
      LOOP AT it_def INTO ls_def
        WHERE nodedisplay = abap_true
          AND rowkey      = abap_false
          AND colkey      = abap_false
          AND fieldname IS NOT INITIAL.
        ADD 1 TO lv_table_index.
        lv_header = ls_def-fieldtext.
        CALL METHOD replace_xml_control_characters
          CHANGING
            cv_string = lv_header.
        CONCATENATE gc_tag-data_cell_header
                    lv_header
                    gc_tag-data_cell_end
               INTO lv_xml.
        APPEND lv_xml TO lt_xml.
        IF ls_def-fieldtype_name IS NOT INITIAL.
          lo_datadescr ?= cl_abap_datadescr=>describe_by_name( ls_def-fieldtype_name ).
          IF lo_datadescr->type_kind = cl_abap_datadescr=>typekind_table.
            ls_table_field-fieldname = ls_def-fieldname.
            ls_table_field-index     = lv_table_index.
            ls_table_field-col       = abap_true.
            READ TABLE lt_table_fields TRANSPORTING NO FIELDS
              WITH KEY fieldname = ls_table_field-fieldname.
            IF sy-subrc <> 0.
              APPEND ls_table_field TO lt_table_fields.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDDO.

    APPEND gc_tag-row_end TO lt_xml.

*--------------------------------------------------------------------*
* Sort Data Per Row
*--------------------------------------------------------------------*
    IF it_data IS NOT INITIAL.

      LOOP AT it_data ASSIGNING <ls_data>.
        CLEAR: ls_rows.
        CREATE DATA ls_rows-data TYPE HANDLE lo_struct.
        ASSIGN ls_rows-data->* TO <ls_data_ref>.
        <ls_data_ref> = <ls_data>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_row OF STRUCTURE <ls_data> TO <lv_row_key>.
        ls_rows-engine_row_key = <lv_row_key>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>.
        ls_rows-engine_col_key = <lv_col_key>.
        APPEND ls_rows TO lt_rows.
      ENDLOOP.

      SORT lt_rows BY engine_row_key engine_col_key.

*--------------------------------------------------------------------*
* Check for Duplicates *SAP Note 2909064
*--------------------------------------------------------------------*
      DELETE ADJACENT DUPLICATES FROM lt_rows COMPARING engine_col_key engine_row_key.
*--------------------------------------------------------------------*
* Create Rows
*--------------------------------------------------------------------*
      LOOP AT lt_rows INTO ls_rows.
        CLEAR lv_row_fields.

        ASSIGN ls_rows-data->* TO <ls_data>.
        ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>.

* Check for New Row
*------------------------
        IF lv_rows <> ls_rows-engine_row_key.

          IF lt_rows_int IS NOT INITIAL.
            CALL METHOD set_merged_fields
              EXPORTING
                it_rows         = lt_rows_int
                iv_merge        = lv_merge
                it_table_fields = lt_table_fields
                iv_row_columns  = lv_row_columns
                iv_columns      = lv_columns
              CHANGING
                ct_xml          = lt_xml.
          ENDIF.

          CLEAR lt_rows_int.
          IF lv_rows <> 0.
            APPEND gc_tag-row_end TO lt_xml.
          ENDIF.
          APPEND gc_tag-row_begin TO lt_xml.
          CLEAR lv_index.

* Check for Merging Cells
*------------------------
          CLEAR lv_merge.
          IF lt_table_fields IS NOT INITIAL.
            LOOP AT lt_table_fields INTO ls_table_field.
              ASSIGN COMPONENT ls_table_field-fieldname OF STRUCTURE <ls_data> TO <lt_table>.
              IF lines( <lt_table> ) > 1 AND ( lines( <lt_table> ) - 1 ) > lv_merge.
                lv_merge = lines( <lt_table> ) - 1.
              ENDIF.
            ENDLOOP.
          ENDIF.

* Create Row Key Cells
*------------------------
          lv_rows = ls_rows-engine_row_key.
          LOOP AT it_def INTO ls_def
            WHERE nodedisplay = abap_true
              AND rowkey = abap_true
              AND fieldname IS NOT INITIAL.
            READ TABLE lt_table_fields TRANSPORTING NO FIELDS
              WITH KEY fieldname = ls_def-fieldname.
            IF sy-subrc <> 0.
              ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
              CALL METHOD generate_xml_line_for_cell
                EXPORTING
                  iv_data       = <lv_data>
                  iv_merge_down = lv_merge
                  iv_row_key    = abap_true
                CHANGING
                  ct_xml        = lt_xml.
            ELSE.
              ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lt_table>.
              LOOP AT <lt_table> ASSIGNING <lv_data>.
                EXIT.
              ENDLOOP.
              IF sy-subrc <> 0 AND <lv_data> IS ASSIGNED.
                CALL METHOD generate_xml_line_for_cell
                  EXPORTING
                    iv_row_key = abap_true
                  CHANGING
                    ct_xml     = lt_xml.
              ELSE.
                CALL METHOD generate_xml_line_for_cell
                  EXPORTING
                    iv_data    = <lv_data>
                    iv_row_key = abap_true
                  CHANGING
                    ct_xml     = lt_xml.
              ENDIF.

            ENDIF.
          ENDLOOP.
        ENDIF.

        ADD 1 TO lv_index.
        READ TABLE lt_grp_columns INTO ls_grp_columns INDEX lv_index.
        IF sy-subrc = 0.


* Create Column Cells
*-------------------------
          WHILE <lv_col_key> <> ls_grp_columns-engine_col_key.
            LOOP AT it_def INTO ls_def
              WHERE nodedisplay = abap_true
                AND rowkey     = abap_false
                AND colkey     = abap_false
                AND fieldname IS NOT INITIAL.
              CALL METHOD generate_xml_line_for_ept_cell
                CHANGING
                  ct_xml = lt_xml.
            ENDLOOP.
            ADD 1 TO lv_index.
            READ TABLE lt_grp_columns INTO ls_grp_columns INDEX lv_index.
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.
          ENDWHILE.

          IF <lv_col_key> = ls_grp_columns-engine_col_key.
            LOOP AT it_def INTO ls_def
              WHERE nodedisplay = abap_true
                AND rowkey     = abap_false
                AND colkey     = abap_false
                AND fieldname IS NOT INITIAL.
              READ TABLE lt_table_fields TRANSPORTING NO FIELDS
                WITH KEY fieldname = ls_def-fieldname.
              IF sy-subrc <> 0.
                ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
                IF <lv_data> IS ASSIGNED.
                  CALL METHOD generate_xml_line_for_cell
                    EXPORTING
                      iv_data       = <lv_data>
                      iv_merge_down = lv_merge
                    CHANGING
                      ct_xml        = lt_xml.
                ELSE.
                  CALL METHOD generate_xml_line_for_cell
                    EXPORTING
                      iv_merge_down = lv_merge
                    CHANGING
                      ct_xml        = lt_xml.
                ENDIF.

              ELSE.
                ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lt_table>.
                LOOP AT <lt_table> ASSIGNING <lv_data>.
                  EXIT.
                ENDLOOP.
                CALL METHOD generate_xml_line_for_cell
                  EXPORTING
                    iv_data = <lv_data>
                  CHANGING
                    ct_xml  = lt_xml.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDIF.

        IF lv_merge > 0.
          APPEND ls_rows TO lt_rows_int.
        ENDIF.

      ENDLOOP.

      IF lt_rows_int IS NOT INITIAL.
        CALL METHOD set_merged_fields
          EXPORTING
            it_rows         = lt_rows_int
            iv_merge        = lv_merge
            it_table_fields = lt_table_fields
            iv_row_columns  = lv_row_columns
            iv_columns      = lv_columns
          CHANGING
            ct_xml          = lt_xml.
      ENDIF.

      APPEND gc_tag-row_end TO lt_xml.

    ENDIF.

  ENDIF.

*--------------------------------------------------------------------*
* Add XML Lines
*--------------------------------------------------------------------*
  IF mv_insert_index = 0.
    IF lv_insert_index = 0.
      APPEND LINES OF lt_xml TO mt_xml.
    ELSE.
      INSERT gc_tag-row_begin INTO lt_xml INDEX 1.
      INSERT gc_tag-row_end INTO lt_xml INDEX 2.
      INSERT gc_tag-row_begin_with_hyphen INTO lt_xml INDEX 3.
      INSERT gc_tag-row_end INTO lt_xml INDEX 4.
      INSERT LINES OF lt_xml INTO mt_xml INDEX lv_insert_index.
      LOOP AT mt_xml TRANSPORTING NO FIELDS
        WHERE table_line = gc_tag-table_end.
        IF sy-tabix > lv_insert_index.
          mv_insert_index = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    INSERT LINES OF lt_xml INTO mt_xml INDEX mv_insert_index.
    LOOP AT mt_xml TRANSPORTING NO FIELDS
            WHERE table_line = gc_tag-table_end.
      IF sy-tabix > mv_insert_index.
        mv_insert_index = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

*--------------------------------------------------------------------*
* End Table and Worksheet
*--------------------------------------------------------------------*
  IF iv_end_excel = abap_true.
    CALL METHOD end_excel
      EXPORTING
        it_data       = it_data
        it_def        = it_def
        iv_gos_type   = iv_gos_type
        iv_variant_id = iv_variant_id
        iv_filename   = iv_filename.
  ENDIF.

ENDMETHOD.


METHOD EXPORT_HEADER_GROUP_TABLE.


  DATA: lt_xml          TYPE        string_table,
        lv_xml          TYPE        string,
        lv_columns      TYPE        i,
        lv_columns_char TYPE        char255,
        ls_def          TYPE        /plmb/s_exp_table_definition,
        lo_struct       TYPE REF TO cl_abap_structdescr.

  DATA: lt_grp_columns  TYPE STANDARD TABLE OF ts_columns,
        ls_grp_columns  TYPE                   ts_columns,
        lv_number1      TYPE                   char1,
        lv_number2      TYPE                   char2,
        lv_number3      TYPE                   char3,
        lv_number4      TYPE                   char4,
        lv_pnumber1     TYPE                   char1,
        lv_pnumber2     TYPE                   char2,
        lv_pnumber3     TYPE                   char3,
        lv_pnumber4     TYPE                   char4,
        lv_header       TYPE                   string,
        lv_grp_columns  TYPE                   i.

  DATA: lt_rows         TYPE STANDARD TABLE OF ts_rows,
        ls_rows         TYPE                   ts_rows,
        lv_rows         TYPE                   i.

  DATA: lv_filename     TYPE        string,
        lv_xml_out      TYPE        string,
        lv_content      TYPE        xstring,
        lo_conv_out     TYPE REF TO cl_abap_conv_out_ce.

  DATA: lv_export       TYPE        boole_d,
        lv_index        LIKE        sy-index,
        lv_insert_index LIKE        sy-index.

  FIELD-SYMBOLS:
        <ls_data_ref>     TYPE any,
        <ls_data>         TYPE any,
        <lv_data>         TYPE any,
        <lv_col_key>      TYPE i,
        <lv_row_key>      TYPE i,
        <ls_header_group> TYPE /plmb/s_exp_table_header_grp.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_def IS INITIAL.
    RETURN.
  ENDIF.

*  IF it_data IS INITIAL OR it_def IS INITIAL.
*    RETURN.
*  ENDIF.

*--------------------------------------------------------------------*
* Check for New Excel
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    CLEAR mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Create XML Header
*--------------------------------------------------------------------*
  IF mt_xml IS INITIAL.
    CALL METHOD create_xml_header
      CHANGING
        ct_xml = mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Generate Style and Structure
*--------------------------------------------------------------------*
  IF it_data IS NOT INITIAL.
    LOOP AT it_data ASSIGNING <ls_data>.
      EXIT.
    ENDLOOP.

    CALL METHOD generate_styles
      EXPORTING
        is_data = <ls_data>
      CHANGING
        ct_xml  = mt_xml.

    lo_struct ?= cl_abap_structdescr=>describe_by_data( <ls_data> ).
  ENDIF.

*--------------------------------------------------------------------*
* Open Worksheet and Table or create Empty Line
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    READ TABLE it_def INTO ls_def INDEX 1.
    IF ls_def-page_text IS NOT INITIAL.
      CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
    ELSE.
      lv_xml = ls_def-table_no.
      SHIFT lv_xml LEFT DELETING LEADING '0'.
      CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
      CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
    ENDIF.
    APPEND lv_xml TO mt_xml.
    APPEND gc_tag-table_begin TO mt_xml.
    CALL METHOD set_header_information
      EXPORTING
        it_export_header_data = it_export_header_data
      CHANGING
        ct_xml                = mt_xml.
  ELSE.
    APPEND gc_tag-row_begin TO lt_xml.
    APPEND gc_tag-row_end TO lt_xml.
    READ TABLE it_def INTO ls_def
      WITH KEY new_page = abap_true.
    IF sy-subrc = 0.
      CALL METHOD end_table_and_worksheet.
      IF ls_def-page_text IS NOT INITIAL.
        CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
      ELSE.
        CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
        CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
      ENDIF.
      READ TABLE mt_xml TRANSPORTING NO FIELDS
        WITH KEY table_line = lv_xml.
      IF sy-subrc = 0.
        lv_insert_index = sy-tabix.
        LOOP AT mt_xml TRANSPORTING NO FIELDS
          WHERE table_line = gc_tag-table_end.
          IF sy-tabix > lv_insert_index.
            lv_insert_index = sy-tabix.
            EXIT.
          ENDIF.
        ENDLOOP.
        mv_insert_index = 0.
      ELSE.
        CLEAR lt_xml.
        APPEND lv_xml TO lt_xml.
        APPEND gc_tag-table_begin TO lt_xml.
      ENDIF.

    ENDIF.
  ENDIF.

  IF it_data IS NOT INITIAL.

*--------------------------------------------------------------------*
* Create Table Header
*--------------------------------------------------------------------*
    IF iv_table_parent_number <> 0.
      WRITE iv_table_parent_number TO lv_pnumber4.
      SHIFT lv_pnumber4 LEFT DELETING LEADING '0'.
      CASE strlen( lv_pnumber4 ).
        WHEN 1.
          lv_pnumber1 = lv_pnumber4.
          lv_header = lv_pnumber1.
        WHEN 2.
          lv_pnumber2 = lv_pnumber4.
          lv_header = lv_pnumber2.
        WHEN 3.
          lv_pnumber3 = lv_pnumber4.
          lv_header = lv_pnumber3.
        WHEN OTHERS.
          lv_header = lv_pnumber4.
      ENDCASE.
    ENDIF.
    LOOP AT it_def INTO ls_def
      WHERE table_text IS NOT INITIAL.
      APPEND gc_tag-row_begin TO lt_xml.
      IF iv_table_number = 0.
        WRITE ls_def-table_no TO lv_number4.
      ELSE.
        WRITE iv_table_number TO lv_number4.
      ENDIF.
      SHIFT lv_number4 LEFT DELETING LEADING '0'.
      CASE strlen( lv_number4 ).
        WHEN 1.
          lv_number1 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number1 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number1 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.

        WHEN 2.
          lv_number2 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number2 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number2 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
        WHEN 3.
          lv_number3 = lv_number4.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number3 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number3 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
        WHEN OTHERS.
          IF lv_header IS INITIAL.
            CONCATENATE lv_number4 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ELSE.
            CONCATENATE lv_header '.' lv_number4 '. ' ls_def-table_text INTO lv_header
             RESPECTING BLANKS.
          ENDIF.
      ENDCASE.
      CONDENSE lv_header.
      CALL METHOD replace_xml_control_characters
        CHANGING
          cv_string = lv_header.
      CONCATENATE gc_tag-data_cell_table_header
                  lv_header
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.
      APPEND gc_tag-row_end TO lt_xml.
      EXIT.
    ENDLOOP.

*--------------------------------------------------------------------*
* Create Table Header Groups
*--------------------------------------------------------------------*
*   start new row
    APPEND gc_tag-row_begin TO lt_xml.

    LOOP AT it_header_group ASSIGNING <ls_header_group>.

      lv_header = <ls_header_group>-header_group_name.
      lv_columns = <ls_header_group>-merged_cells_num - 1.
      WRITE lv_columns TO lv_columns_char LEFT-JUSTIFIED.

      CALL METHOD replace_xml_control_characters
        CHANGING
          cv_string = lv_header.

      CONCATENATE gc_tag-data_cell_merge_header_part1
                  lv_columns_char
                  gc_tag-data_cell_merge_header_part2
                  lv_header
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.
    ENDLOOP.
*   finish row
    APPEND gc_tag-row_end TO lt_xml.


*--------------------------------------------------------------------*
* Create cells for columns
*--------------------------------------------------------------------*
    APPEND gc_tag-row_begin TO lt_xml.

    LOOP AT it_def INTO ls_def.

      CONCATENATE gc_tag-data_cell_header
                  ls_def-fieldtext
                  gc_tag-data_cell_end
             INTO lv_xml.
      APPEND lv_xml TO lt_xml.
    ENDLOOP.

    APPEND gc_tag-row_end TO lt_xml.

*--------------------------------------------------------------------*
* Create data lines
*--------------------------------------------------------------------*
    LOOP AT it_data ASSIGNING <ls_data>.
*     start new row
      APPEND gc_tag-row_begin TO lt_xml.

      LOOP AT it_def INTO ls_def WHERE nodedisplay = abap_true
                                 AND   fieldname IS NOT INITIAL.

        ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
        CALL METHOD generate_xml_line_for_cell
          EXPORTING
            iv_data = <lv_data>
          CHANGING
            ct_xml  = lt_xml.
      ENDLOOP.

      APPEND gc_tag-row_end TO lt_xml.
    ENDLOOP.

  ENDIF.

*--------------------------------------------------------------------*
* Add XML Lines
*--------------------------------------------------------------------*
  IF mv_insert_index = 0.
    IF lv_insert_index = 0.
      APPEND LINES OF lt_xml TO mt_xml.
    ELSE.
      INSERT gc_tag-row_begin INTO lt_xml INDEX 1.
      INSERT gc_tag-row_end INTO lt_xml INDEX 2.
      INSERT gc_tag-row_begin_with_hyphen INTO lt_xml INDEX 3.
      INSERT gc_tag-row_end INTO lt_xml INDEX 4.
      INSERT LINES OF lt_xml INTO mt_xml INDEX lv_insert_index.
      LOOP AT mt_xml TRANSPORTING NO FIELDS
        WHERE table_line = gc_tag-table_end.
        IF sy-tabix > lv_insert_index.
          mv_insert_index = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    INSERT LINES OF lt_xml INTO mt_xml INDEX mv_insert_index.
    LOOP AT mt_xml TRANSPORTING NO FIELDS
            WHERE table_line = gc_tag-table_end.
      IF sy-tabix > mv_insert_index.
        mv_insert_index = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.


*--------------------------------------------------------------------*
* End Table and Worksheet
*--------------------------------------------------------------------*
  IF iv_end_excel = abap_true.
    CALL METHOD end_excel
      EXPORTING
        it_data       = it_data
        it_def        = it_def
        iv_gos_type   = iv_gos_type
        iv_variant_id = iv_variant_id
        iv_filename   = iv_filename.
  ENDIF.

ENDMETHOD.


METHOD export_single_object_type.

  DATA: lt_def       TYPE /plmb/t_exp_table_definition,
        ls_def       TYPE /plmb/s_exp_table_definition,
        ls_def_new   TYPE /plmb/s_exp_table_definition,
        lt_def_int   TYPE /plmb/t_exp_table_definition,
        lt_data      TYPE /plmb/t_exp_table_data_export,
        ls_data      TYPE /plmb/s_exp_table_data_export,
        ls_data_ref  TYPE /plmb/s_exp_ref_to_data,
        lt_data_new  TYPE /plmb/t_exp_table_data_export,
        ls_data_new  TYPE /plmb/s_exp_table_data_export,

        lv_new_table TYPE boole_d,
        lv_new_excel TYPE boole_d,
        lv_end_excel TYPE boole_d,

        lv_index_from TYPE i,          "Note 2370173
        lv_index_to   TYPE i,          "Note 2370173

        lo_data_des   TYPE REF TO cl_abap_datadescr,
        ls_ddic_hdr  TYPE x030l,
        lo_table     TYPE REF TO cl_abap_tabledescr,
        lv_export    TYPE boole_d,
        lv_index     LIKE sy-index.

  FIELD-SYMBOLS:
        <ls_def>   TYPE /plmb/s_exp_table_definition,
        <lt_data>  TYPE ANY TABLE,
        <ls_data>  TYPE any.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_data IS INITIAL OR it_def IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Clear First Page
*--------------------------------------------------------------------*
  lt_def = it_def.

*--------------------------------------------------------------------*
* Put Data to File
*--------------------------------------------------------------------*
  lv_export = abap_true.
  WHILE lv_export = abap_true.
    lv_index = sy-index.
    CLEAR: lv_export,
           lt_data_new.

    LOOP AT it_data INTO ls_data.
      ASSIGN ls_data-table_data->* TO <lt_data>.
      IF lv_index < lines( <lt_data> ).
        lv_export = abap_true.
      ENDIF.
      IF <ls_data> IS ASSIGNED.
        UNASSIGN <ls_data>.
      ENDIF.
      LOOP AT <lt_data> ASSIGNING <ls_data>.
        IF sy-tabix = lv_index.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF <ls_data> IS ASSIGNED.

        lo_data_des ?= cl_abap_datadescr=>describe_by_data( <ls_data> ).
        CLEAR ls_ddic_hdr.
        CALL METHOD lo_data_des->get_ddic_header
          RECEIVING
            p_header     = ls_ddic_hdr
          EXCEPTIONS
            not_found    = 1
            no_ddic_type = 2
            OTHERS       = 3.
        IF ls_ddic_hdr-tabname = '/PLMB/S_EXP_REF_TO_DATA'.
          ls_data_ref = <ls_data>.
          ASSIGN ls_data_ref-data->* TO <ls_data>.
          lo_data_des ?= cl_abap_datadescr=>describe_by_data( <ls_data> ).
        ENDIF.

        IF lo_data_des->type_kind <> cl_abap_datadescr=>typekind_table.
          ls_data_new-table_no = ls_data-table_no.
          lo_table ?= cl_abap_tabledescr=>describe_by_data( <lt_data> ).
          CREATE DATA ls_data_new-table_data TYPE HANDLE lo_table.
          ASSIGN ls_data_new-table_data->* TO <lt_data>.
          INSERT <ls_data> INTO TABLE <lt_data>.
        ELSE.
          ls_data_new-table_no = ls_data-table_no.
          lo_table ?= lo_data_des.
          CREATE DATA ls_data_new-table_data TYPE HANDLE lo_table.
          ASSIGN ls_data_new-table_data->* TO <lt_data>.
          <lt_data> = <ls_data>.
        ENDIF.
        APPEND ls_data_new TO lt_data_new.
      ENDIF.
    ENDLOOP.

    IF lv_index = 1.
      lv_new_excel = abap_true.
      CLEAR mv_table_index.
    ELSE.
      CALL METHOD add_additional_empty_rows
        EXPORTING
          iv_number_rows = 2.
    ENDIF.

    LOOP AT lt_def INTO ls_def
      WHERE new_page = abap_false.

      CLEAR: lv_new_table.

      AT NEW table_no.                                  "#EC AT_LOOP_WH
*        lv_new_table = abap_true.                                   "2370173
        lv_index_from = sy-tabix.                                    "2370173
      ENDAT.

*-->Note 2370173 Performance:
*   APPENDing only the relevant records instead of table copy and deletion!
      AT END OF table_no.
        lv_new_table = abap_true. "trigger processing >AFTER< each block!
        lv_index_to = sy-tabix.
        CLEAR lt_def_int.
        APPEND LINES OF lt_def FROM lv_index_from TO lv_index_to TO lt_def_int.
      ENDAT.
*<--Note 2370173 Performance

      IF lv_new_table = abap_true.
*        lt_def_int = lt_def.                                        "2370173
*        DELETE lt_def_int WHERE table_no <> ls_def-table_no.        "2370173
        READ TABLE lt_data_new INTO ls_data
          WITH TABLE KEY table_no = ls_def-table_no.
        IF sy-subrc = 0.
          READ TABLE lt_def INTO ls_def_new
            WITH KEY table_no = ls_def-table_no.
          IF sy-subrc = 0.
            READ TABLE lt_def INTO ls_def INDEX sy-tabix - 1.
            IF ls_def-new_page = abap_true.
              INSERT ls_def INTO lt_def_int INDEX 1.
              CLEAR mv_table_index.
            ENDIF.
          ENDIF.
          ASSIGN ls_data-table_data->* TO <lt_data>.
          LOOP AT lt_def_int TRANSPORTING NO FIELDS
            WHERE rowkey = abap_true
               OR colkey = abap_true.
            EXIT.
          ENDLOOP.
          ADD 1 TO mv_table_index.
          IF sy-subrc = 0.
            CALL METHOD export_comparison_table
              EXPORTING
                it_data                = <lt_data>
                it_def                 = lt_def_int
                iv_gos_type            = iv_gos_type
                iv_variant_id          = iv_variant_id
                it_export_header_data  = it_export_header_data
                iv_new_excel           = lv_new_excel
                iv_end_excel           = lv_end_excel
                iv_header_row_key      = iv_header_row_key
                iv_filename            = iv_filename
                iv_table_number        = mv_table_index
                iv_display_empty_table = abap_true
                iv_row_key_emphasized  = abap_true.
          ELSE.
            CALL METHOD export_single_table
              EXPORTING
                it_data               = <lt_data>
                it_def                = lt_def_int
                iv_gos_type           = iv_gos_type
                iv_variant_id         = iv_variant_id
                it_export_header_data = it_export_header_data
                iv_new_excel          = lv_new_excel
                iv_end_excel          = lv_end_excel
                iv_filename           = iv_filename
                iv_table_number       = mv_table_index.
          ENDIF.

          lv_new_excel = abap_false.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDWHILE.

  CALL METHOD end_excel
    EXPORTING
      it_data       = it_data
      it_def        = it_def
      iv_gos_type   = iv_gos_type
      iv_variant_id = iv_variant_id
      iv_filename   = iv_filename.


ENDMETHOD.


METHOD export_single_table.

  DATA: lt_xml          TYPE        string_table,
        lv_xml          TYPE        string,
        lv_columns      TYPE        i,
        lv_columns_char TYPE        char255,
        ls_def          TYPE        /plmb/s_exp_table_definition,
        lo_struct       TYPE REF TO cl_abap_structdescr.

  DATA: lt_grp_columns  TYPE STANDARD TABLE OF ts_columns,
        ls_grp_columns  TYPE                   ts_columns,
        lv_number1      TYPE                   char1,
        lv_number2      TYPE                   char2,
        lv_number3      TYPE                   char3,
        lv_number4      TYPE                   char4,
        lv_pnumber1     TYPE                   char1,
        lv_pnumber2     TYPE                   char2,
        lv_pnumber3     TYPE                   char3,
        lv_pnumber4     TYPE                   char4,
        lv_header       TYPE                   string,
        lv_grp_columns  TYPE                   i.

  DATA: lt_rows         TYPE STANDARD TABLE OF ts_rows,
        ls_rows         TYPE                   ts_rows,
        lv_rows         TYPE                   i.

  DATA: lv_filename     TYPE        string,
        lv_xml_out      TYPE        string,
        lv_content      TYPE        xstring,
        lo_conv_out     TYPE REF TO cl_abap_conv_out_ce.

  DATA: lv_export       TYPE        boole_d,
        lv_index        LIKE        sy-index,
        lv_insert_index LIKE        sy-index.

  FIELD-SYMBOLS:
        <ls_data_ref>   TYPE any,
        <ls_data>       TYPE any,
        <lv_data>       TYPE any,
        <lv_col_key>    TYPE i,
        <lv_row_key>    TYPE i.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_def IS INITIAL.
    RETURN.
  ENDIF.

*  IF it_data IS INITIAL OR it_def IS INITIAL.
*    RETURN.
*  ENDIF.

*--------------------------------------------------------------------*
* Check for New Excel
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    CLEAR mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Create XML Header
*--------------------------------------------------------------------*
  IF mt_xml IS INITIAL.
    CALL METHOD create_xml_header
      CHANGING
        ct_xml = mt_xml.
  ENDIF.

*--------------------------------------------------------------------*
* Generate Style and Structure
*--------------------------------------------------------------------*
  IF it_data IS NOT INITIAL.
    LOOP AT it_data ASSIGNING <ls_data>.
      EXIT.
    ENDLOOP.

    CALL METHOD generate_styles
      EXPORTING
        is_data = <ls_data>
      CHANGING
        ct_xml  = mt_xml.

    lo_struct ?= cl_abap_structdescr=>describe_by_data( <ls_data> ).
  ENDIF.

*--------------------------------------------------------------------*
* Open Worksheet and Table or create Empty Line
*--------------------------------------------------------------------*
  IF iv_new_excel = abap_true.
    READ TABLE it_def INTO ls_def INDEX 1.
    IF ls_def-page_text IS NOT INITIAL.
      CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
    ELSE.
      lv_xml = ls_def-table_no.
      SHIFT lv_xml LEFT DELETING LEADING '0'.
      CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
      CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
    ENDIF.
    APPEND lv_xml TO mt_xml.
    APPEND gc_tag-table_begin TO mt_xml.
    CALL METHOD set_header_information
      EXPORTING
        it_export_header_data = it_export_header_data
      CHANGING
        ct_xml                = mt_xml.
  ELSE.
    APPEND gc_tag-row_begin TO lt_xml.
    APPEND gc_tag-row_end TO lt_xml.
    READ TABLE it_def INTO ls_def
      WITH KEY new_page = abap_true.
    IF sy-subrc = 0.
      CALL METHOD end_table_and_worksheet.
      IF ls_def-page_text IS NOT INITIAL.
        CONCATENATE gc_tag-worksheet_begin ls_def-page_text '">' INTO lv_xml.
      ELSE.
        CONCATENATE text-001 lv_xml INTO lv_xml SEPARATED BY space.
        CONCATENATE gc_tag-worksheet_begin lv_xml '">' INTO lv_xml.
      ENDIF.
      READ TABLE mt_xml TRANSPORTING NO FIELDS
        WITH KEY table_line = lv_xml.
      IF sy-subrc = 0.
        lv_insert_index = sy-tabix.
        LOOP AT mt_xml TRANSPORTING NO FIELDS
          WHERE table_line = gc_tag-table_end.
          IF sy-tabix > lv_insert_index.
            lv_insert_index = sy-tabix.
            EXIT.
          ENDIF.
        ENDLOOP.
        mv_insert_index = 0.
      ELSE.
        CLEAR lt_xml.
        APPEND lv_xml TO lt_xml.
        APPEND gc_tag-table_begin TO lt_xml.
      ENDIF.

    ENDIF.
  ENDIF.

  IF it_data IS NOT INITIAL.


*--------------------------------------------------------------------*
* Export Data one after the other
*--------------------------------------------------------------------*
    lv_export = abap_true.
    WHILE lv_export = abap_true.
      lv_index = sy-index.
      IF lv_index > 1.
        APPEND gc_tag-row_begin TO lt_xml.
        APPEND gc_tag-row_end TO lt_xml.
      ENDIF.

*--------------------------------------------------------------------*
* Create Table Header
*--------------------------------------------------------------------*
      IF iv_table_parent_number <> 0.
        WRITE iv_table_parent_number TO lv_pnumber4.
        SHIFT lv_pnumber4 LEFT DELETING LEADING '0'.
        CASE strlen( lv_pnumber4 ).
          WHEN 1.
            lv_pnumber1 = lv_pnumber4.
            lv_header = lv_pnumber1.
          WHEN 2.
            lv_pnumber2 = lv_pnumber4.
            lv_header = lv_pnumber2.
          WHEN 3.
            lv_pnumber3 = lv_pnumber4.
            lv_header = lv_pnumber3.
          WHEN OTHERS.
            lv_header = lv_pnumber4.
        ENDCASE.
      ENDIF.
      LOOP AT it_def INTO ls_def
        WHERE table_text IS NOT INITIAL.
        APPEND gc_tag-row_begin TO lt_xml.
        IF iv_table_number = 0.
          WRITE ls_def-table_no TO lv_number4.
        ELSE.
          WRITE iv_table_number TO lv_number4.
        ENDIF.
        SHIFT lv_number4 LEFT DELETING LEADING '0'.
        CASE strlen( lv_number4 ).
          WHEN 1.
            lv_number1 = lv_number4.
            IF lv_header IS INITIAL.
              CONCATENATE lv_number1 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ELSE.
              CONCATENATE lv_header '.' lv_number1 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ENDIF.

          WHEN 2.
            lv_number2 = lv_number4.
            IF lv_header IS INITIAL.
              CONCATENATE lv_number2 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ELSE.
              CONCATENATE lv_header '.' lv_number2 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ENDIF.
          WHEN 3.
            lv_number3 = lv_number4.
            IF lv_header IS INITIAL.
              CONCATENATE lv_number3 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ELSE.
              CONCATENATE lv_header '.' lv_number3 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ENDIF.
          WHEN OTHERS.
            IF lv_header IS INITIAL.
              CONCATENATE lv_number4 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ELSE.
              CONCATENATE lv_header '.' lv_number4 '. ' ls_def-table_text INTO lv_header
               RESPECTING BLANKS.
            ENDIF.
        ENDCASE.
        CONDENSE lv_header.
        CALL METHOD replace_xml_control_characters
          CHANGING
            cv_string = lv_header.
        CONCATENATE gc_tag-data_cell_table_header
                    lv_header
                    gc_tag-data_cell_end
               INTO lv_xml.
        APPEND lv_xml TO lt_xml.
        APPEND gc_tag-row_end TO lt_xml.
        EXIT.
      ENDLOOP.

*--------------------------------------------------------------------*
* Create Lines
*--------------------------------------------------------------------*
      LOOP AT it_data ASSIGNING <ls_data>.
        IF sy-tabix = lv_index.
          EXIT.
        ENDIF.
      ENDLOOP.
      LOOP AT it_def INTO ls_def
        WHERE nodedisplay = abap_true
          AND fieldname IS NOT INITIAL.

        APPEND gc_tag-row_begin TO lt_xml.

* Create Label
*--------------------
        lv_header = ls_def-fieldtext.
        CONCATENATE gc_tag-data_cell_header
                    lv_header
                    gc_tag-data_cell_end
               INTO lv_xml.
        APPEND lv_xml TO lt_xml.

* Create Value
*---------------------
        ASSIGN COMPONENT ls_def-fieldname OF STRUCTURE <ls_data> TO <lv_data>.
        CALL METHOD generate_xml_line_for_cell
          EXPORTING
            iv_data = <lv_data>
          CHANGING
            ct_xml  = lt_xml.

        APPEND gc_tag-row_end TO lt_xml.

      ENDLOOP.

      IF lv_index >= lines( it_data ).
        lv_export = abap_false.
      ENDIF.

    ENDWHILE.

  ENDIF.

*--------------------------------------------------------------------*
* Add XML Lines
*--------------------------------------------------------------------*
  IF mv_insert_index = 0.
    IF lv_insert_index = 0.
      APPEND LINES OF lt_xml TO mt_xml.
    ELSE.
      INSERT gc_tag-row_begin INTO lt_xml INDEX 1.
      INSERT gc_tag-row_end INTO lt_xml INDEX 2.
      INSERT gc_tag-row_begin_with_hyphen INTO lt_xml INDEX 3.
      INSERT gc_tag-row_end INTO lt_xml INDEX 4.
      INSERT LINES OF lt_xml INTO mt_xml INDEX lv_insert_index.
      LOOP AT mt_xml TRANSPORTING NO FIELDS
        WHERE table_line = gc_tag-table_end.
        IF sy-tabix > lv_insert_index.
          mv_insert_index = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    INSERT LINES OF lt_xml INTO mt_xml INDEX mv_insert_index.
    LOOP AT mt_xml TRANSPORTING NO FIELDS
            WHERE table_line = gc_tag-table_end.
      IF sy-tabix > mv_insert_index.
        mv_insert_index = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.


*--------------------------------------------------------------------*
* End Table and Worksheet
*--------------------------------------------------------------------*
  IF iv_end_excel = abap_true.
    CALL METHOD end_excel
      EXPORTING
        it_data       = it_data
        it_def        = it_def
        iv_gos_type   = iv_gos_type
        iv_variant_id = iv_variant_id
        iv_filename   = iv_filename.
  ENDIF.

ENDMETHOD.


METHOD generate_decimal_styles.

  DATA: lo_struct          TYPE REF TO cl_abap_structdescr,
        lt_components      TYPE        cl_abap_structdescr=>component_table,
        lt_components_help TYPE        cl_abap_structdescr=>component_table,
        ls_component       TYPE        cl_abap_structdescr=>component,
        lo_elem_descr      TYPE REF TO cl_abap_elemdescr,

        lv_decimals        TYPE        string,
        lv_string          TYPE        string,
        ls_style_cell      TYPE        ts_style_cell,
        lv_xml             TYPE        string.

  CONSTANTS:
        gc_zero            TYPE        string VALUE '0'.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR et_xml.

**--------------------------------------------------------------------*
** Get Components
**--------------------------------------------------------------------*
*  CALL METHOD io_struct->get_components
*    RECEIVING
*      p_result = lt_components.
*
**--------------------------------------------------------------------*
** Resolve Includes
**--------------------------------------------------------------------*
*  LOOP AT lt_components INTO ls_component
*    WHERE as_include = abap_true.
*    TRY.
*        lo_struct ?= ls_component-type.
*      CATCH cx_root.
*        CONTINUE.
*    ENDTRY.
*    CALL METHOD lo_struct->get_components
*      RECEIVING
*        p_result = lt_components_help.
*    APPEND LINES OF lt_components_help TO lt_components.
*  ENDLOOP.
*
**--------------------------------------------------------------------*
** Check for Decimals
**--------------------------------------------------------------------*
*  LOOP AT lt_components INTO ls_component
*    WHERE as_include = abap_false.
*    lv_string = '0'.
*    TRY .
*        lo_elem_descr ?= ls_component-type.
*      CATCH cx_root.
*        CONTINUE.
*    ENDTRY.
*    IF lo_elem_descr->decimals <> 0.
*      READ TABLE mt_style_cells TRANSPORTING NO FIELDS
*        WITH KEY decimals = lo_elem_descr->decimals.
*      IF sy-subrc = 0.
*        CONTINUE.
*      ENDIF.
*      DO lo_elem_descr->decimals TIMES.
*        CONCATENATE lv_string gc_zero INTO lv_string.
*      ENDDO.
*      lv_decimals = lo_elem_descr->decimals.
*      CONDENSE lv_decimals NO-GAPS.
*      CONCATENATE '<Style ss:ID="' lv_decimals '"><NumberFormat ss:Format="' lv_string '"/></Style>' INTO lv_xml. "#EC NOTEXT
*      APPEND lv_xml TO et_xml.
*      CLEAR: ls_style_cell.
*      ls_style_cell-decimals = lo_elem_descr->decimals.
*      CONCATENATE '<Cell ss:StyleID="' lv_decimals '"><Data ss:Type="Number">' INTO ls_style_cell-lv_tag_begin. "#EC NOTEXT
*      INSERT ls_style_cell INTO TABLE mt_style_cells.
*    ENDIF.
*  ENDLOOP.

*--------------------------------------------------------------------*
* Add Number Style with no Decimals
*--------------------------------------------------------------------*
  APPEND '<Style ss:ID="N0"><NumberFormat ss:Format="#,##0"/></Style>' TO et_xml. "#EC NOTEXT
  CLEAR ls_style_cell.
  ls_style_cell-decimals = 0.
  ls_style_cell-lv_tag_begin = '<Cell ss:StyleID="N0"><Data ss:Type="Number">'. "#EC NOTEXT
  INSERT ls_style_cell INTO TABLE mt_style_cells.

*--------------------------------------------------------------------*
* Add Number Styles with up to 16 Decimal Places
*--------------------------------------------------------------------*
  DO 16 TIMES.
    lv_decimals = sy-index.
    CONCATENATE lv_string '0' INTO lv_string.
    CONCATENATE '<Style ss:ID="N' lv_decimals '"><NumberFormat ss:Format="#,##0.' lv_string '"/></Style>' INTO lv_xml. "#EC NOTEXT
    APPEND lv_xml TO et_xml.
    CLEAR ls_style_cell.
    ls_style_cell-decimals = lv_decimals.
    CONCATENATE '<Cell ss:StyleID="N' lv_decimals '"><Data ss:Type="Number">' INTO ls_style_cell-lv_tag_begin. "#EC NOTEXT
    INSERT ls_style_cell INTO TABLE mt_style_cells.
  ENDDO.


ENDMETHOD.


METHOD generate_styles.

  DATA: lo_struct TYPE REF TO cl_abap_structdescr,
        lt_xml    TYPE        string_table,
        lv_index  LIKE        sy-tabix.

*--------------------------------------------------------------------*
* Open Style Chapter
*--------------------------------------------------------------------*
  READ TABLE ct_xml TRANSPORTING NO FIELDS
    WITH KEY table_line = '</Styles>'.
  IF sy-subrc <> 0.
    APPEND '<Styles>' TO ct_xml.                            "#EC NOTEXT

*--------------------------------------------------------------------*
* Generate Style for TableHeader
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="TH">' TO ct_xml.                  "#EC NOTEXT
*    APPEND '<Borders>' TO ct_xml.                           "#EC NOTEXT
*    APPEND '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
*    APPEND '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
*    APPEND '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
*    APPEND '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
*    APPEND '</Borders>' TO ct_xml.                          "#EC NOTEXT
    APPEND '<Font ss:Bold="1"/>' TO ct_xml.                 "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.

*--------------------------------------------------------------------*
* Generate Style for Header
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="H">' TO ct_xml.                   "#EC NOTEXT
    APPEND '<Borders>' TO ct_xml.                           "#EC NOTEXT
    APPEND '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Borders>' TO ct_xml.                          "#EC NOTEXT
    APPEND '<Font ss:Bold="1"/>' TO ct_xml.                 "#EC NOTEXT
    APPEND '<Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.

*--------------------------------------------------------------------*
* Generate Style for Row Key
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="RK">' TO ct_xml.                  "#EC NOTEXT
    APPEND '<Borders>' TO ct_xml.                           "#EC NOTEXT
    APPEND '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Borders>' TO ct_xml.                          "#EC NOTEXT
    APPEND '<Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.

*--------------------------------------------------------------------*
* Generate Style for Header Information
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="HI">' TO ct_xml.                  "#EC NOTEXT
    APPEND '<Font ss:Bold="1"/>' TO ct_xml.                 "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.

*--------------------------------------------------------------------*
* Generate Style for Merged Cell
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="mc">' TO ct_xml.                  "#EC NOTEXT
    APPEND '<Alignment ss:Vertical="Top"/>' TO ct_xml.      "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.                            "#EC NOTEXT

*--------------------------------------------------------------------*
* Generate Style for Merged Cell with Row Key
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="mcRK">' TO ct_xml.                "#EC NOTEXT
    APPEND '<Borders>' TO ct_xml.                           "#EC NOTEXT
    APPEND '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Borders>' TO ct_xml.                          "#EC NOTEXT
    APPEND '<Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>' TO ct_xml. "#EC NOTEXT
    APPEND '<Alignment ss:Vertical="Top"/>' TO ct_xml.      "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.

*--------------------------------------------------------------------*
* Generate Style for hyphen between objects
*--------------------------------------------------------------------*
    APPEND '<Style ss:ID="cut">' TO ct_xml.                 "#EC NOTEXT
    APPEND '<Borders>' TO ct_xml.                           "#EC NOTEXT
    APPEND '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' TO ct_xml. "#EC NOTEXT
    APPEND '</Borders>' TO ct_xml.                          "#EC NOTEXT
    APPEND '</Style>' TO ct_xml.                            "#EC NOTEXT

*--------------------------------------------------------------------*
* Generate decimal Styles
*--------------------------------------------------------------------*
    CALL METHOD generate_decimal_styles
*    EXPORTING
*      io_struct = lo_struct
      IMPORTING
        et_xml    = lt_xml.


  ELSE.
    lv_index = sy-tabix.
  ENDIF.

**--------------------------------------------------------------------*
** Check if Decimal Dataelements are in Structure and create Style
**--------------------------------------------------------------------*
*  lo_struct ?= cl_abap_structdescr=>describe_by_data( is_data ).
*
*  CALL METHOD generate_decimal_styles
*    EXPORTING
*      io_struct = lo_struct
*    IMPORTING
*      et_xml    = lt_xml.

  IF lv_index IS INITIAL.
    APPEND LINES OF lt_xml TO ct_xml.
  ELSE.
    INSERT LINES OF lt_xml INTO ct_xml INDEX lv_index.
  ENDIF.

*--------------------------------------------------------------------*
* End Style Chapter
*--------------------------------------------------------------------*
  READ TABLE ct_xml TRANSPORTING NO FIELDS
    WITH KEY table_line = '</Styles>'.
  IF sy-subrc <> 0.
    APPEND '</Styles>' TO ct_xml.                           "#EC NOTEXT
  ENDIF.

ENDMETHOD.


METHOD generate_xml_line_for_cell.

  DATA: lo_type        TYPE REF TO cl_abap_typedescr,
        lo_elem_descr  TYPE REF TO cl_abap_elemdescr,
        ls_dfies       TYPE        dfies,

        lv_exit_name   TYPE        string,
        lv_string      TYPE        string,
        lt_string      TYPE        string_table,
        lv_decimal     TYPE        string,
        lv_dec_places  TYPE        i,
        lv_dec_cell    TYPE        i,                           "2331727
        lv_char        TYPE        char1,
        lv_index       TYPE        i,

        ls_style_cell  TYPE        ts_style_cell,
        lv_merge_down  TYPE        char10,
        lv_index_col   TYPE        char10,
        lv_row_key     TYPE        boole_d,
        lv_tag         TYPE        char255,
        lv_tag_int     TYPE        char255,
        lv_xml         TYPE        string,

        lv_zerovalflg  TYPE        flag,                   "Note 1955624
        lv_value       TYPE        string,                 "Note 2038105
        lv_number      TYPE        f.                      "Note 2038105

  CONSTANTS:
        gc_true        TYPE        flag VALUE 'X'.         "Note 1955624

*--------------------------------------------------------------------*
* Get Element Description
*--------------------------------------------------------------------*
  TRY.
      lo_type ?= cl_abap_datadescr=>describe_by_data( iv_data ).
      lo_elem_descr ?= lo_type.
    CATCH cx_root.
      CALL METHOD generate_xml_line_for_ept_cell
        EXPORTING
          iv_merge_down = iv_merge_down
          iv_index      = iv_index
          iv_row_key    = iv_row_key
        CHANGING
          ct_xml        = ct_xml.
      RETURN.
  ENDTRY.

*--------------------------------------------------------------------*
* Merge Down and Index
*--------------------------------------------------------------------*
  IF iv_merge_down > 0.
    lv_merge_down = iv_merge_down.
    CONDENSE lv_merge_down.
  ENDIF.

  IF iv_index > 0.
    lv_index_col = iv_index.
    CONDENSE lv_index_col.
  ENDIF.

*--------------------------------------------------------------------*
* Get Row KEy
*--------------------------------------------------------------------*
  IF iv_row_key = abap_true AND mv_row_key = abap_true.
    lv_row_key = abap_true.
  ENDIF.

*--------------------------------------------------------------------*
* Check for Conversion Exit
*--------------------------------------------------------------------*
  IF lo_elem_descr->is_ddic_type( ) = abap_true.
    CALL METHOD lo_elem_descr->get_ddic_field
      RECEIVING
        p_flddescr = ls_dfies.
    IF ls_dfies-convexit IS NOT INITIAL.
      CONCATENATE 'CONVERSION_EXIT_' ls_dfies-convexit '_OUTPUT' INTO lv_exit_name. "#EC NOTEXT

      CALL FUNCTION lv_exit_name
        EXPORTING
          input    = iv_data
          language = sy-langu
        IMPORTING
          output   = lv_string.
    ELSE.
      lv_string = iv_data.
    ENDIF.
  ELSE. " no ddic type
    lv_string = iv_data.
  ENDIF.

*--------------------------------------------------------------------*
* Determine Cell Type
*--------------------------------------------------------------------*
  CASE lo_elem_descr->type_kind.  "#EC CI_INT8_OK
    WHEN cl_abap_elemdescr=>typekind_int OR
         cl_abap_elemdescr=>typekind_float OR
         cl_abap_elemdescr=>typekind_packed OR
         cl_abap_elemdescr=>typekind_decfloat34.
      lv_string = iv_data.
      CONDENSE lv_string.
      IF lo_elem_descr->decimals <> 0.
        READ TABLE mt_style_cells INTO ls_style_cell
          WITH KEY decimals = lo_elem_descr->decimals.
      ELSE.
        SPLIT lv_string AT '.' INTO TABLE lt_string.
        IF sy-subrc = 0.
* Note 2038105 -> Start
          READ TABLE lt_string INTO lv_value INDEX 1.
          lv_number = lv_value.
          IF lv_number = 0.
            lv_zerovalflg = gc_true.
          ENDIF.
* Note 2038105 <- End

          READ TABLE lt_string INTO lv_decimal INDEX 2.
          lv_number = lv_decimal.                          "Note 2038105
          IF lv_number <> 0.                               "Note 2038105
            lv_dec_places = strlen( lv_decimal ).
            " note 2789092: excel export is able to manage max. 16 dec. places
            IF lv_dec_places > 16.
              lv_dec_places = 16.
            ENDIF.
            " end note 2789092
          ENDIF.                                           "Note 2038105

          IF lo_elem_descr->type_kind = cl_abap_elemdescr=>typekind_decfloat34.
            DO lv_dec_places TIMES.
              lv_index = sy-index - 1.
              lv_char = lv_decimal+lv_index(1).
              IF lv_char = '0'.
                IF lv_zerovalflg is initial.               "Note 1955624
* note 2331727 -> value 1.2001 or 0.20105
*                 lv_dec_places = sy-index - 1.
*                 EXIT.
                  IF lv_dec_cell = lv_dec_places.
                    lv_dec_cell   = sy-index - 1.
                  ENDIF.
* note 2331727
                ENDIF.
              ELSE.                                        "Note 1955624
                CLEAR lv_zerovalflg.                       "Note 1955624
                lv_dec_cell = lv_dec_places.                    "2331727
              ENDIF.
            ENDDO.
          ENDIF.
          READ TABLE mt_style_cells INTO ls_style_cell
*           WITH KEY decimals = lv_dec_places.                  "2331727
            WITH KEY decimals = lv_dec_cell.                    "2331727
        ELSE.
          READ TABLE mt_style_cells INTO ls_style_cell
            WITH KEY decimals = 0.
        ENDIF.
      ENDIF.
      "N2692379
      IF lo_elem_descr->type_kind = cl_abap_elemdescr=>typekind_packed.
        SEARCH lv_string FOR '-'.
        IF SY-SUBRC = 0 AND SY-FDPOS <> 0.
            REPLACE '-' IN lv_string WITH ''.
            CONDENSE lv_string.
            CONCATENATE '-' lv_string INTO lv_string.
        ENDIF.
      ENDIF.
      "N2692379
      lv_tag = ls_style_cell-lv_tag_begin.
      IF iv_merge_down > 0 OR iv_index > 0.
        IF iv_merge_down > 0.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mcRK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mc">' INTO lv_tag_int.
          ENDIF.
        ELSE.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:Index="' lv_index_col '" ss:StyleID="RK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:Index="' lv_index_col '">' INTO lv_tag_int.
          ENDIF.
        ENDIF.
        CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
        REPLACE '<Cell>' WITH space INTO lv_tag.
        CONDENSE lv_tag.
        CONCATENATE lv_tag_int lv_tag INTO lv_tag.
      ELSE.
        IF lv_row_key = abap_true.
          lv_tag_int = 'ss:StyleID="RK">'.
          CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
          REPLACE '<Cell' WITH space INTO lv_tag.
          CONDENSE lv_tag.
          CONCATENATE lv_tag_int lv_tag INTO lv_tag SEPARATED BY space.
        ENDIF.
      ENDIF.
      CONCATENATE lv_tag
                  lv_string
                  gc_tag-data_cell_end
             INTO lv_xml.
    WHEN cl_abap_elemdescr=>typekind_date.
      lv_tag = gc_tag-data_cell.
      IF iv_merge_down > 0 OR iv_index > 0.
        IF iv_merge_down > 0.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mcRK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mc">' INTO lv_tag_int.
          ENDIF.
        ELSE.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:Index="' lv_index_col '" ss:StyleID="RK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:Index="' lv_index_col '">' INTO lv_tag_int.
          ENDIF.
        ENDIF.
        CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
        REPLACE '<Cell>' WITH space INTO lv_tag.
        CONDENSE lv_tag.
        CONCATENATE lv_tag_int lv_tag INTO lv_tag.
      ELSE.
        IF lv_row_key = abap_true.
          lv_tag_int = 'ss:StyleID="RK">'.
          CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
          REPLACE '<Cell' WITH space INTO lv_tag.
          CONDENSE lv_tag.
          CONCATENATE lv_tag_int lv_tag INTO lv_tag SEPARATED BY space.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = iv_data
        IMPORTING
          date_external            = lv_string
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
        CONCATENATE lv_tag
                    lv_string
                    gc_tag-data_cell_end
               INTO lv_xml.
      ELSE.
        CONCATENATE lv_tag
                    iv_data
                    gc_tag-data_cell_end
               INTO lv_xml.
      ENDIF.
    WHEN OTHERS.
      lv_tag = gc_tag-data_cell.
      IF iv_merge_down > 0 OR iv_index > 0.
        IF iv_merge_down > 0.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mcRK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mc">' INTO lv_tag_int.
          ENDIF.
        ELSE.
          IF lv_row_key = abap_true.
            CONCATENATE 'ss:Index="' lv_index_col '" ss:StyleID="RK">' INTO lv_tag_int.
          ELSE.
            CONCATENATE 'ss:Index="' lv_index_col '">' INTO lv_tag_int.
          ENDIF.
        ENDIF.
        CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
        REPLACE '<Cell>' WITH space INTO lv_tag.
        CONDENSE lv_tag.
        CONCATENATE lv_tag_int lv_tag INTO lv_tag.
      ELSE.
        IF lv_row_key = abap_true.
          lv_tag_int = 'ss:StyleID="RK">'.
          CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
          REPLACE '<Cell' WITH space INTO lv_tag.
          CONDENSE lv_tag.
          CONCATENATE lv_tag_int lv_tag INTO lv_tag SEPARATED BY space.
        ENDIF.
      ENDIF.
      CALL METHOD replace_xml_control_characters
        CHANGING
          cv_string = lv_string.
      CONCATENATE lv_tag
                  lv_string
                  gc_tag-data_cell_end
             INTO lv_xml.
  ENDCASE.

  IF iv_insert_at_tag IS SUPPLIED.    "1884471
    " Insert the field at the tagged row
    READ TABLE ct_xml WITH KEY table_line = iv_insert_at_tag TRANSPORTING NO FIELDS.
    IF sy-subrc is INITIAL.
      INSERT lv_xml INTO ct_xml INDEX sy-tabix.
    ELSE.
      APPEND lv_xml TO ct_xml.
    ENDIF.
  ELSE. "1884471
    APPEND lv_xml TO ct_xml.
  ENDIF. "1884471

ENDMETHOD.


METHOD generate_xml_line_for_ept_cell.

  DATA: lv_xml        TYPE char255,
        lv_row_key    TYPE boole_d,
        lv_tag        TYPE char255,
        lv_tag_int    TYPE char255,
        lv_merge_down TYPE char10,
        lv_index      TYPE char10.

  IF iv_row_key = abap_true AND mv_row_key = abap_true.
    lv_row_key = abap_true.
  ENDIF.

  IF iv_merge_down = 0 AND iv_index = 0.
    IF lv_row_key = abap_true.
      lv_tag = gc_tag-data_cell_row_key.
    ELSE.
      lv_tag = gc_tag-data_cell.
    ENDIF.
    CONCATENATE lv_tag
                gc_tag-data_cell_end
           INTO lv_xml.
  ELSE.
    IF iv_merge_down > 0 OR iv_index > 0.
      IF iv_merge_down > 0.
        lv_merge_down = iv_merge_down.
        CONDENSE lv_merge_down.
        IF lv_row_key = abap_true.
          CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mcRK">' INTO lv_tag_int.
        ELSE.
          CONCATENATE 'ss:MergeDown="' lv_merge_down '" ss:StyleID="mc">' INTO lv_tag_int.
        ENDIF.
      ELSE.
        lv_index = iv_index.
        CONDENSE lv_index.
        IF lv_row_key = abap_true.
          CONCATENATE 'ss:Index="' lv_index '" ss:StyleID="RK">' INTO lv_tag_int.
        ELSE.
          CONCATENATE 'ss:Index="' lv_index '">' INTO lv_tag_int.
        ENDIF.

      ENDIF.
    ENDIF.

    lv_tag = gc_tag-data_cell.
    CONCATENATE '<Cell' lv_tag_int INTO lv_tag_int SEPARATED BY space.
    REPLACE '<Cell>' WITH space INTO lv_tag.
    CONDENSE lv_tag.
    CONCATENATE lv_tag_int lv_tag INTO lv_tag.
    CONCATENATE lv_tag
                gc_tag-data_cell_end
           INTO lv_xml.

  ENDIF.

  APPEND lv_xml TO ct_xml.

ENDMETHOD.


METHOD REPLACE_XML_CONTROL_CHARACTERS.

  REPLACE ALL OCCURRENCES OF  '&' IN cv_string WITH '&amp;'.
  REPLACE ALL OCCURRENCES OF  '>' IN cv_string WITH '&gt;'.
  REPLACE ALL OCCURRENCES OF  '<' IN cv_string WITH '&lt;'.
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN cv_string WITH '&#10;'.

ENDMETHOD.


METHOD set_header_information.

  DATA: ls_export_header_data TYPE /plmb/s_exp_header_info,
        lv_xml                TYPE string.

  FIELD-SYMBOLS:
        <lv_data>             TYPE any,
        <lv_xml>              TYPE string.

  LOOP AT it_export_header_data INTO ls_export_header_data.
    APPEND gc_tag-row_begin TO ct_xml.
    CONCATENATE gc_tag-data_cell_header_info
                ls_export_header_data-fname_descr
                gc_tag-data_cell_end
           INTO lv_xml.
    APPEND lv_xml TO ct_xml.
    ASSIGN ls_export_header_data-content->* TO <lv_data>.
    CALL METHOD generate_xml_line_for_cell
      EXPORTING
        iv_data = <lv_data>
      CHANGING
        ct_xml  = ct_xml.
    IF ls_export_header_data-content_descr IS NOT INITIAL.
      READ TABLE ct_xml ASSIGNING <lv_xml> INDEX lines( ct_xml ).
      CONCATENATE ls_export_header_data-content_descr
                  gc_tag-data_cell_end INTO lv_xml.
      SHIFT lv_xml RIGHT BY 1 PLACES.
      REPLACE gc_tag-data_cell_end IN <lv_xml> WITH lv_xml.
    ENDIF.
    APPEND gc_tag-row_end TO ct_xml.
  ENDLOOP.
  IF sy-subrc = 0.
    DO 2 TIMES.
      APPEND gc_tag-row_begin TO ct_xml.
      APPEND gc_tag-row_end TO ct_xml.
    ENDDO.
  ENDIF.


ENDMETHOD.


METHOD set_merged_fields.

  "DATA: lv_html           TYPE        string."1884471

  DATA: ls_rows           TYPE        ts_rows,
        lv_row_key        TYPE        boole_d,
        lv_row_fields     TYPE        boole_d,
        lv_index          TYPE        i.

  DATA: lt_table_fields   TYPE        tt_table_fields,
        ls_table_field    TYPE        ts_table_fields,
        lv_table_index    TYPE        i.

  DATA lv_tag_line        TYPE string."1884471
  DATA lv_insert_at_tag   TYPE string."1884471
  DATA lt_used_tags       TYPE string_table."1884471

  FIELD-SYMBOLS:
        <lt_table>        TYPE        ANY TABLE,
        <ls_data>         TYPE        any,
        <lv_data>         TYPE        any,
        <lv_col_key>      type        any.

*--------------------------------------------------------------------*
* Check Input
*--------------------------------------------------------------------*
  IF it_rows IS INITIAL.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Set Merged Cells
*--------------------------------------------------------------------*
  LOOP AT it_rows INTO ls_rows.
    IF sy-tabix = 1.
      lv_row_fields = abap_true.
     ASSIGN ls_rows-data->* TO <ls_data>."1884471
     ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>."1884471
    ELSE.
      lv_row_fields = abap_false.
      ASSIGN ls_rows-data->* TO <ls_data>."1884471
      ADD 1 TO <lv_col_key>."1884471
    ENDIF.
    "ASSIGN ls_rows-data->* TO <ls_data>."1884471
    "ASSIGN COMPONENT /plmb/if_exp_c=>gc_component_key-engine_key_col OF STRUCTURE <ls_data> TO <lv_col_key>."1884471
    lv_index = 1.
    WHILE iv_merge >= lv_index.
      lv_index = sy-index + 1.
      lt_table_fields = it_table_fields.
      IF lv_row_fields = abap_false.
        DELETE lt_table_fields WHERE col = abap_false.
      ELSE.
        APPEND gc_tag-row_end TO ct_xml.
        APPEND gc_tag-row_begin TO ct_xml.
      ENDIF.
      LOOP AT lt_table_fields INTO ls_table_field.
        ASSIGN COMPONENT ls_table_field-fieldname OF STRUCTURE <ls_data> TO <lt_table>.
        LOOP AT <lt_table> ASSIGNING <lv_data>.
          IF sy-tabix = lv_index.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF sy-subrc <> 0 AND <lv_data> IS ASSIGNED.
          UNASSIGN <lv_data>.
        ENDIF.
        CLEAR lv_row_key.
        IF ls_table_field-index > iv_row_columns.
          lv_table_index = iv_row_columns.
          IF <lv_col_key> > 1.
            DO <lv_col_key> - 1 TIMES.
              ADD iv_columns TO lv_table_index.
            ENDDO.
            ls_table_field-index = ls_table_field-index - iv_row_columns.
            ADD ls_table_field-index TO lv_table_index.
          ELSE.
            lv_table_index = ls_table_field-index.
          ENDIF.
        ELSE.
          lv_row_key = abap_true.
          lv_table_index = ls_table_field-index.
        ENDIF.
        IF lv_row_fields = abap_true."1884471
          IF <lv_data> IS ASSIGNED.
            CALL METHOD generate_xml_line_for_cell
              EXPORTING
                iv_data    = <lv_data>
                iv_row_key = lv_row_key
                iv_index   = lv_table_index
              CHANGING
                ct_xml     = ct_xml.
          ELSE.
            CALL METHOD generate_xml_line_for_cell
              EXPORTING
                iv_row_key = lv_row_key
                iv_index   = lv_table_index
              CHANGING
                ct_xml     = ct_xml.
          ENDIF.
        ELSE.
          " Insert cell at tagged row  "1884471
          lv_insert_at_tag = '$TAG_LINE' && lv_index.
        IF <lv_data> IS ASSIGNED.
          CALL METHOD generate_xml_line_for_cell
            EXPORTING
              iv_data    = <lv_data>
              iv_row_key = lv_row_key
              iv_index   = lv_table_index
                iv_insert_at_tag = lv_insert_at_tag
              CHANGING
              ct_xml     = ct_xml.
        ELSE.
          CALL METHOD generate_xml_line_for_cell
            EXPORTING
              iv_row_key = lv_row_key
              iv_index   = lv_table_index
                iv_insert_at_tag = lv_insert_at_tag
              CHANGING
                ct_xml     = ct_xml.
          ENDIF.
        ENDIF.
        AT LAST."1884471
          " Tag row - it will be used to insert data of
          " other recipes into same row.
          IF lv_row_fields = abap_true.
            lv_tag_line = '$TAG_LINE' && lv_index.
            APPEND lv_tag_line TO ct_xml.
            APPEND lv_tag_line TO lt_used_tags.
          ENDIF.
        ENDAT.
      ENDLOOP.
    ENDWHILE.
  ENDLOOP.

  " Remove tags from the resulting XML  "1884471
  LOOP AT lt_used_tags INTO lv_tag_line.
    DELETE ct_xml WHERE table_line = lv_tag_line.
  ENDLOOP.

ENDMETHOD.


METHOD update_definition.

  DATA: lt_def TYPE /plmb/t_exp_table_definition,
        ls_def TYPE /plmb/s_exp_table_definition.

*--------------------------------------------------------------------*
* Clear Export Parameter
*--------------------------------------------------------------------*
  CLEAR et_def_upd.

*--------------------------------------------------------------------*
* Set whole Definition to Output
*--------------------------------------------------------------------*
  et_def_upd = it_def.

*--------------------------------------------------------------------*
* Get Table Numbers
*--------------------------------------------------------------------*
  lt_def = it_def.
  SORT lt_def BY table_no.
  DELETE ADJACENT DUPLICATES FROM lt_def COMPARING table_no.

*--------------------------------------------------------------------*
* Check Table Numbers
*--------------------------------------------------------------------*
  LOOP AT lt_def INTO ls_def.
    READ TABLE it_out_tables TRANSPORTING NO FIELDS
      WITH KEY table_no = ls_def-table_no.
    IF sy-subrc <> 0.
      DELETE et_def_upd WHERE table_no = ls_def-table_no
                          AND new_page = abap_false.
    ENDIF.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.