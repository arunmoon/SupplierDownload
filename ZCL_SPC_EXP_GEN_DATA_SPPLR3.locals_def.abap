" Paste into the Local Definitions (CCDEF) include of ZCL_SPC_EXP_GEN_DATA_SPPLR2.
" Keep these declarations outside the main global-class source.
CLASS ltc_supplier_export DEFINITION DEFERRED.
CLASS zcl_spc_exp_gen_data_spplr2 DEFINITION LOCAL FRIENDS ltc_supplier_export.
