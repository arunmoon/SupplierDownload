<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="general_meta">
  <group id="0100" name="General Data">
    <group id="0105" name="Header Status" node="CURRENT_STATUS" display="transpose" header_with_specs="yes">
        <field>STATUS_DESCR</field>
        <field>STATUS_ID</field>
    </group>
    <group id="0110" name="Basic Data" header_with_specs="yes">
      <group id="0111" name="Header Data" node="BASIC_DATA" display="transpose">
        <field>SUBID</field>
        <field>SUBCAT</field>
        <field>OBJTYPE</field>
        <field>SUBCHAR</field>
        <field>AUTHGRP</field>
        <field>REM</field>
      </group>
      <group id="0112" name="Validity" node="BASIC_DATA" display="transpose">
        <field>AENNR</field>
        <field>VALFR</field>
        <field>VALTO</field>
      </group>
      <group id="0113" name="Administration" node="BASIC_DATA" display="transpose">
        <field>CRDAT</field>
        <field>CRNAM</field>
        <field>UPDDATS</field>
        <field>UPDNAMS</field>
        <field>UPDDAT</field>
        <field>UPDNAM</field>
        <group id="0114" node="ACC_REL_OBJ_ID" display="transpose" display-header="no">
        <!-- This data must be displayed as a part of the previous group. -->
        <!-- The order and the number of the specs are the same as for    -->
        <!-- BASIC_DATA                                                   -->
          <field>ACC_ID_EXT</field>
          <field>ACC_ID_INT</field>
          <field>DESCR</field>
        </group>
      </group>
    </group>
    <group id="0120" name="Identifiers" node="IDENTIFIERS" display="normal">
      <field>IDCAT_NAME</field>
      <field>IDTYPE_NAME</field>
      <field>LANGU</field>
      <!--field>RECN</field-->
      <field>IDENT</field>
      <field>USAGES</field>
      <field>LOCKED</field>
      <field>INH_ICON</field>
      <field>LONG_TEXT</field>
      <field>RECN</field>
      <field>ACTN</field>
      <field>AENNR</field>
      <field>VALFR</field>
      <field>VALTO</field>
      <field>AENNR</field>
      <field>CRDAT</field>
      <field>CRNAM</field>
      <field>UPDDAT</field>
      <field>UPDNAM</field>
      <field>SRSID</field>
      <field>OWNID</field>
      <field>RECNROOT</field>
      <field>LOGLOCKMOD</field>
      <field>OBJNR</field>
    </group>
    <group id="0130" name="Status"  node="STATUS" display="transpose" header_with_specs="yes">
      <field>VACLID</field>
      <field>VACLNAM</field>
      <field>RVLTYPE</field>
      <field>RVLID</field>
      <field>RVLNAM</field>
      <field>SUBSTAT_ON_SCREEN</field>
      <field>STATUS_DESC</field>
      <field>VALFR</field>
      <field>VALTO</field>
      <field>AENNR</field>
      <field>OTYPE</field>
      <field>REALO</field>
      <!--field>CLIENT</field-->
      <field>RECN</field>
      <field>ACTN</field>
      <field>CRDAT</field>
      <field>CRNAM</field>
      <field>UPDDAT</field>
      <field>UPDNAM</field>
      <field>SRSID</field>
      <field>OWNID</field>
      <field>RECNROOT</field>
      <field>LOGLOCKMOD</field>
      <field>OBJNR</field>
    </group>
    <group id="0140" name="Material Assignments" node="MATERIAL_ASSIGNMENT" display="transpose" header_with_specs="yes">
      <field>MATNR</field>
      <field>MAT_DESC</field>
      <field>WERKS</field>
      <field>PLANT_NAME</field>
      <!--field>CLIENT</field-->
      <field>RECN</field>
      <field>ACTN</field>
      <field>VALFR</field>
      <field>VALTO</field>
      <field>AENNR</field>
      <field>CRDAT</field>
      <field>CRNAM</field>
      <field>UPDDAT</field>
      <field>UPDNAM</field>
      <field>SRSID</field>
      <field>OWNID</field>
      <field>RECNROOT</field>
      <field>LOGLOCKMOD</field>
      <field>OBJNR</field>
    </group>
    <group id="0150" name="Relationships">
      <group id="0151" node="REL_FR" name="Inherits From" display="transpose" header_with_specs="yes" >
        <field>SUBID</field>
        <field>IDENT_1_VALUE</field>
        <field>IDENT_2_VALUE</field>
        <field>CONS_STAT</field>
        <field>APPRV_STAT</field>
        <field>ACTIVE_INH</field>
        <field>FLG_REQUEST</field>
        <field>ESNTFLG</field>
        <field>TEMPLATE</field>
        <field>TEMPLDESCR</field>
        <!--field>CLIENT</field-->
        <field>RECN</field>
        <field>ACTN</field>
        <field>VALFR</field>
        <field>VALTO</field>
        <field>AENNR</field>
        <field>CRDAT</field>
        <field>CRNAM</field>
        <field>UPDDAT</field>
        <field>UPDNAM</field>
        <field>SRSID</field>
        <field>OWNID</field>
        <field>RECNROOT</field>
        <field>LOGLOCKMOD</field>
        <field>OBJNR</field>
      </group>
      <group id="0152" node="REL_TO" name="Passes On To" display="transpose" header_with_specs="yes">
        <field>SUBID</field>  <!--<field>CLIENT</field>-->
        <field>IDENT_1_VALUE</field>
        <field>IDENT_2_VALUE</field>
        <field>CONS_STAT</field>
        <field>APPRV_STAT</field>
        <field>ACTIVE_INH</field>
        <field>FLG_REQUEST</field>
        <field>ESNTFLG</field>
        <field>TEMPLATE</field>
        <field>TEMPLDESCR</field>
        <!--field>CLIENT</field-->
        <field>RECN</field>
        <field>ACTN</field>
        <field>VALFR</field>
        <field>VALTO</field>
        <field>AENNR</field>
        <field>CRDAT</field>
        <field>CRNAM</field>
        <field>UPDDAT</field>
        <field>UPDNAM</field>
        <field>SRSID</field>
        <field>OWNID</field>
        <field>RECNROOT</field>
        <field>LOGLOCKMOD</field>
        <field>OBJNR</field>
      </group>
    </group>
    <group id="0160" name="WWI Reports" node="REPORTS" display="normal">
      <field>SBGVID</field>
      <field>SBGVNAM</field>
      <field>RVLNAM</field>
      <field>LANGUTEXT</field>
      <field>VERSION</field>
      <field>REPSTATUS</field>
      <field>RELEASE_DATE</field>
      <field>PARENT</field>
    </group>
  </group>
</xsl:variable>

<xsl:variable name="property_meta">
  <node id="INSTANCES" display="normal" display-input-fields="yes" display-property-tree="flat">
    <field>ENGINE_VALUE_ASSIGNMENT_TYPE_D</field>
    <field>ENGINE_NODE_NAME_DESC</field>
    <field>META_USAGE</field>
    <field>META_SPEC_ID</field>
    <field>META_INSTANCE</field>
    <field>META_SORT</field>
    <field display="no">__STDVAI_SORT</field>
    <field display="no">__USAGE</field>
  </node>
</xsl:variable>

</xsl:stylesheet>
<!-- Template [End] -->
