class /PLMU/CL_EXP_EXPORT_FACTORY definition
  public
  final
  create public .

public section.

  class-methods GET_FILE_TYPES
    exporting
      !ET_FILE_TYPES type DDFIXVALUES .
  class-methods GET_EXPORT_CLASS
    importing
      !IV_EXPORT_TYPE type /PLMB/EXP_TYPE
    returning
      value(RR_EXPORT_CLASS) type ref to /PLMU/IF_EXP_EXPORT_DATA .
  class-methods CLASS_CONSTRUCTOR .
protected section.
PRIVATE SECTION.

  TYPES:
    BEGIN OF lty_s_export_type_to_class,
    export_name   TYPE /plmb/exp_type,
    export_object TYPE REF TO /plmu/if_exp_export_data,
  END OF lty_s_export_type_to_class .
  TYPES:
    lty_t_export_type_to_class TYPE STANDARD TABLE OF lty_s_export_type_to_class WITH KEY export_name .

  TYPES:
    BEGIN OF lty_s_export_file_definition,
      export_name       TYPE /plmb/exp_type,
      export_class      TYPE seoclsname,
      export_form_name  TYPE val_text,
      END OF lty_s_export_file_definition.
  TYPES:
    lty_t_export_file_definition TYPE STANDARD TABLE OF lty_s_export_file_definition WITH KEY export_name.

  CLASS-DATA gt_file_definition TYPE lty_t_export_file_definition.
  CLASS-DATA gt_export_classes  TYPE lty_t_export_type_to_class .
ENDCLASS.



CLASS /PLMU/CL_EXP_EXPORT_FACTORY IMPLEMENTATION.


METHOD class_constructor.

  DATA:
        lt_fixed_values        TYPE ddfixvalues,
        lo_elemdescr           TYPE REF TO cl_abap_elemdescr.

  FIELD-SYMBOLS:
        <fs_fixed_value>       TYPE ddfixvalue,
        <fs_file_definition>   TYPE lty_s_export_file_definition.

*--------------------------------------------------------------------*
* Define exort type - export class assignments
*--------------------------------------------------------------------*
  " To describe a file format we are reusing a domain fixes value
  " structure
  lo_elemdescr ?= cl_abap_typedescr=>describe_by_name( p_name = '/PLMB/EXP_TYPE' ).
  ASSERT lo_elemdescr IS BOUND.

  lt_fixed_values = lo_elemdescr->get_ddic_fixed_values( ).

*--------------------------------------------------------------------*
* Define file format - object type assignment
*--------------------------------------------------------------------*
  LOOP AT lt_fixed_values ASSIGNING <fs_fixed_value>.
    APPEND INITIAL LINE TO gt_file_definition ASSIGNING <fs_file_definition>.
    <fs_file_definition>-export_name      = <fs_fixed_value>-low.
    <fs_file_definition>-export_form_name = <fs_fixed_value>-ddtext.

    CASE <fs_file_definition>-export_name.
      WHEN 'EXCEL'.
        <fs_file_definition>-export_class = /plmb/if_exp_c=>gc_exp_class-excel.
      WHEN 'HTML'.
        <fs_file_definition>-export_class = /plmb/if_exp_c=>gc_exp_class-html.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.


METHOD get_export_class.

  FIELD-SYMBOLS:
       <fs_exp_type_buf>    TYPE lty_s_export_type_to_class,
       <fs_file_definition> type lty_s_export_file_definition.

*--------------------------------------------------------------------*
* Check for instance in the buffer
*--------------------------------------------------------------------*
  READ TABLE gt_export_classes
   ASSIGNING <fs_exp_type_buf>
        WITH TABLE KEY export_name = iv_export_type.
  IF sy-subrc EQ 0.
    rr_export_class = <fs_exp_type_buf>-export_object.
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Not find in the buffer -> create new instance
*--------------------------------------------------------------------*
  READ TABLE gt_file_definition ASSIGNING <fs_file_definition>
    WITH KEY export_name = iv_export_type.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  APPEND INITIAL LINE TO gt_export_classes ASSIGNING <fs_exp_type_buf>.
  <fs_exp_type_buf>-export_name = iv_export_type.
  CREATE OBJECT <fs_exp_type_buf>-export_object TYPE (<fs_file_definition>-export_class).
  rr_export_class = <fs_exp_type_buf>-export_object.

ENDMETHOD.


method GET_FILE_TYPES.

  FIELD-SYMBOLS:
                 <fs_file_type>       type ddfixvalue,
                 <fs_file_definition> type lty_s_export_file_definition.

*--------------------------------------------------------------------*
* Clear exporting parameters
*--------------------------------------------------------------------*
  CLEAR et_file_types.

*--------------------------------------------------------------------*
* Get file definition in form of fixed values
*--------------------------------------------------------------------*
  " We are using fixed value description to define file types
  LOOP AT gt_file_definition ASSIGNING <fs_file_definition>.
    APPEND INITIAL LINE TO et_file_types ASSIGNING <fs_file_type>.
    <fs_file_type>-low    = <fs_file_definition>-export_name.
    <fs_file_type>-ddtext = <fs_file_definition>-export_form_name.
  ENDLOOP.

endmethod.
ENDCLASS.