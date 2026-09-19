<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
      xmlns:input="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:sap="http://www.sap.com/sapxsl"
      xmlns:rcp="http://www.sap.com/recipe_development"
      xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:html="http://www.w3.org/TR/REC-html40"
      exclude-result-prefixes="rcp input"> <!-- white space separated list of namespace prefixes that should not be sent to the output -->
<!-- Includes -->
<xsl:include sap:name="ZTR_SPC_EXP_META_SU"/>       <!-- Meta information for displaying data -->
<xsl:include sap:name="/PLMU/TR_SPC_EXP_STYLES"/> <!-- Style definitions for excel -->
<xsl:include sap:name="/PLMU/TR_SPC_EXP_UTIL"/>       <!-- Utility methods -->


<xsl:param name="OUTPUT" sap:type="string">excel</xsl:param>
<xsl:param name="OUTPUT_METHOD" sap:type="string">xml</xsl:param>
<xsl:param name="ENABLE_DROPDOWN_VALIDATION" sap:type="string">X</xsl:param>

<xsl:output method="{$OUTPUT_METHOD}" indent="yes" encoding="UTF-8"/>

<!-- Functions [Start] -->
<sap:external-function name="rcp:pattern" class="/PLMU/CL_EXP_XSLT_UTIL" method="get_pattern" kind="class">
  <sap:argument param="IV_OUTPUT"/>
  <sap:argument param="IV_DATA_TYPE"/>
  <sap:argument param="IV_PATTERN_ID"/>
  <sap:result param="EV_PATTERN" type="string"/>
</sap:external-function>

<sap:external-function name="rcp:pattern_desc" class="/PLMU/CL_EXP_XSLT_UTIL" method="get_pattern" kind="class">
  <sap:argument param="IV_OUTPUT"/>
  <sap:argument param="IV_DATA_TYPE"/>
  <sap:argument param="IV_PATTERN_ID"/>
  <sap:result param="EV_PATTERN_DESC" type="string"/>
</sap:external-function>

<sap:external-function name="rcp:format" class="/PLMU/CL_EXP_XSLT_UTIL" method="format" kind="class">
  <sap:argument param="IV_OUTPUT"/>
  <sap:argument param="IV_DATA"/>
  <sap:argument param="IV_DATA_TYPE"/>
  <sap:argument param="IV_PATTERN_ID"/>
  <sap:result param="RV_FORMATTED_DATA" type="string"/>
</sap:external-function>
<!-- Functions [End] -->



<xsl:preserve-space elements="text"/>

<!-- Global Variables -->
<!-- General Data [start] -->
<xsl:variable name="g_sdm_chapter_idx" select="1"/>
<xsl:variable name="g_sdm_node_idx" select="2"/>
<xsl:variable name="g_sdm_node_desc_idx" select="3"/>
<xsl:variable name="g_sdm_mt_flag_idx" select="4"/>
<xsl:variable name="g_sdm_lnum_idx" select="5"/>
<xsl:variable name="g_sdm_specid_idx" select="6"/>
<!-- General Data [start] -->

<!-- Property Tree [start] -->
<xsl:variable name="g_prop_idx" select="1"/>
<xsl:variable name="g_prop_desc_idx" select="2"/>
<xsl:variable name="g_prop_vac_idx" select="3"/>
<xsl:variable name="g_prop_node_idx" select="4"/>
<xsl:variable name="g_prop_node_desc_idx" select="5"/>
<xsl:variable name="g_prop_mt_flag_idx" select="6"/>
<xsl:variable name="g_prop_lnum_idx" select="7"/>
<xsl:variable name="g_prop_specid_idx" select="8"/>
<!-- Property Tree [end] -->

<xsl:variable name="date_pattern_id" select="string(/input:Workbook/input:Worksheet[1]/input:Table/input:Row[5]/input:Cell[2]/input:Data)"/>
<xsl:variable name="time_pattern_id" select="string(/input:Workbook/input:Worksheet[1]/input:Table/input:Row[7]/input:Cell[2]/input:Data)"/>
<xsl:variable name="number_pattern_id" select="string(/input:Workbook/input:Worksheet[1]/input:Table/input:Row[9]/input:Cell[2]/input:Data)"/>

<xsl:key name="properties" match="input:Row/input:Cell[1]/input:Data/text()" use="." />

<!-- Root Template -->

<!-- Template [Start] -->
<xsl:template match="/">
  <xsl:call-template name="open_document"/>

  <!-- Get Header information -->
  <!-- header information is displayed only once in the input file in the first
       tab. In the different tamplates that processes the worksheets it is difficult
       to identify it. -->
  <xsl:variable name="header_rows" select="input:Workbook[1]/input:Worksheet[1]/input:Table[1]/input:Row[position() &lt; 9]"/>
  <!-- Display output info -->
<!--   <xsl:call-template name="display_output_info">
    <xsl:with-param name="rows" select="$header_rows"/>
  </xsl:call-template> -->

  <!-- Display Data-->
  <xsl:variable name="num_of_worksheets" select="count(/input:Workbook/input:Worksheet)"/>
  <!-- ZSPPLR_DEBUG_20260804_002 -->
  <!--
    Use only custom supplier-group rows to avoid repeating standard nutrients.
    Preserve the source sort order supplied by ABAP. The actual SpecID is
    resolved from the technical SUBID metadata column below.
  -->
  <xsl:variable name="group_rows" select="input:Workbook[1]/input:Worksheet/input:Table/input:Row[
    input:Cell[$g_prop_mt_flag_idx]/input:Data='TABLEDATA'
    and (normalize-space(input:Cell[$g_prop_node_idx]/input:Data)='ZSUPPLIER_GROUP'
        and (normalize-space(input:Cell[1]/input:Data)='SAP_RMS_1012_005'
          or normalize-space(input:Cell[1]/input:Data)='SAP_RMS_1012_021'
          or normalize-space(input:Cell[1]/input:Data)='SAP_RMS_1012_010'
          or normalize-space(input:Cell[1]/input:Data)='SAP_RMS_1012_022'
          or normalize-space(input:Cell[1]/input:Data)='SAP_RMS_1012_025'))]"/>
  <xsl:variable name="property_rows" select="input:Workbook[1]/input:Worksheet/input:Table/input:Row[input:Cell[$g_prop_mt_flag_idx]/input:Data='TABLEDATA' or input:Cell[$g_prop_mt_flag_idx]/input:Data='METADATA']"/>
  <xsl:variable name="hidden_dropdown_col_count">
    <xsl:call-template name="p_flat_property_max_dropdown_columns">
      <xsl:with-param name="rows" select="$property_rows"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="open_page">
    <xsl:with-param name="title" select="'Data'"/>
    <xsl:with-param name="column_profile" select="'Data'"/>
    <xsl:with-param name="rows" select="$property_rows"/>
    <xsl:with-param name="hidden_dropdown_col_count" select="number($hidden_dropdown_col_count)"/>
  </xsl:call-template>

  <xsl:choose>
    <xsl:when test="$num_of_worksheets = 2"><!-- Processing of two worksheet related data -->
      <xsl:call-template name="display_spec_data">
        <xsl:with-param name="rows" select="input:Workbook[1]/input:Worksheet[1]/input:Table/input:Row"/>
      </xsl:call-template>
      <xsl:call-template name="display_property_tree">
        <xsl:with-param name="num_of_worksheets" select="$num_of_worksheets"/>
        <xsl:with-param name="rows" select="$property_rows"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$num_of_worksheets = 1"><!-- Processing of one worksheet related data -->
    <!-- It must be found out which worksheet's related data is represented.
         Either Specification Data or Property related data.-->

      <xsl:variable name="nodes_tmp"><!-- get the rows that represent different nodes in idx -->
        <xsl:call-template name="get_distinct">
          <xsl:with-param name="rows" select="//input:Table/input:Row[input:Cell[4]/input:Data/text() = 'METADATA']"/>
          <xsl:with-param name="idx" select="2"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="nodes" select="$nodes_tmp/input:Row/input:Cell[2]/input:Data/text()"/><!-- name of nodes -->
      <xsl:variable name="node_found"><!-- Check if the existing values exist in the metadata -->
        <xsl:for-each select="$general_meta//group[@node]/@node">
          <xsl:variable name="e_node" select="."/>
          <xsl:for-each select="$nodes">
            <xsl:variable name="i_node" select="."/>
            <xsl:if test="$e_node = $i_node">X</xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="string-length($node_found) > 0">
          <xsl:call-template name="display_spec_data">
            <xsl:with-param name="rows" select="input:Workbook[1]/input:Worksheet[1]/input:Table/input:Row"/>
          </xsl:call-template>
          <xsl:if test="count($property_rows) > 0">
            <xsl:call-template name="display_property_tree">
              <xsl:with-param name="num_of_worksheets" select="$num_of_worksheets"/>
              <xsl:with-param name="rows" select="$property_rows"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name="display_property_tree">
           <xsl:with-param name="num_of_worksheets" select="$num_of_worksheets"/>
           <xsl:with-param name="rows" select="$property_rows"/>
         </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

  </xsl:choose>


  <xsl:call-template name="close_data_page">
    <xsl:with-param name="rows" select="$property_rows"/>
  </xsl:call-template>
  <xsl:call-template name="open_page">
    <xsl:with-param name="title" select="'Groups'"/>
    <xsl:with-param name="column_profile" select="'Groups'"/>
    <xsl:with-param name="rows" select="$group_rows"/>
    <xsl:with-param name="hidden_dropdown_col_count" select="0"/>
  </xsl:call-template>
  <xsl:call-template name="display_group_sheet">
    <xsl:with-param name="rows" select="$group_rows"/>
  </xsl:call-template>
  <xsl:call-template name="close_page"/>
  <xsl:call-template name="close_document"/>
</xsl:template>


<!-- ************************************************************************************************-->
<!-- Template for 'Specification Data' -->
<!-- ************************************************************************************************-->
<xsl:template name="display_spec_data">
  <xsl:param name="rows"/>
  <!-- Display general data -->
<!--   <xsl:call-template name="display_group">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="group_id" select="'0100'"/>
    <xsl:with-param name="chapter_number" select="2"/>
  </xsl:call-template> -->
</xsl:template>

<!-- ************************************************************************************************-->
<!-- Display output information -->
<!-- ************************************************************************************************-->
<!-- <xsl:template name="display_output_info">
  <xsl:param name="rows"/>          contains only header rows

  <xsl:call-template name="heading">
    <xsl:with-param name="level">1</xsl:with-param>
    <xsl:with-param name="text" select="concat('1. ', $rows[1]/input:Cell[2])"/>
  </xsl:call-template>

  <xsl:call-template name="open_table"/>

  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="''"/>
  </xsl:call-template>
  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="''"/>
  </xsl:call-template>
  <xsl:call-template name="close_row"/>
  <xsl:call-template name="close_table_header"/>

  <xsl:call-template name="open_table_body"/>
  <xsl:for-each select="$rows[position() = 2 or position() = 3 or position() = 4 or position() = 6]">
    <xsl:call-template name="open_row"/>
    <xsl:call-template name="draw_cell">
      <xsl:with-param name="style">th10</xsl:with-param>
      <xsl:with-param name="text" select="input:Cell[1]/input:Data"/>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="position() = 1">  originally it is $rows[2]
        <xsl:call-template name="draw_cell">
          <xsl:with-param name="style">s30d</xsl:with-param>
          <xsl:with-param name="datatype">D</xsl:with-param>
          <xsl:with-param name="text" select="input:Cell[2]/input:Data"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="draw_cell">
          <xsl:with-param name="style">s30s</xsl:with-param>
          <xsl:with-param name="text" select="input:Cell[2]/input:Data"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="close_row"/>
  </xsl:for-each>
  <xsl:call-template name="close_table_body"/>

  <xsl:call-template name="close_table"/>

</xsl:template>
 -->
<!-- ************************************************************************************************-->
<!-- Display group recursively -->
<!-- ************************************************************************************************-->
<xsl:template name="display_group">
  <xsl:param name="rows"/>
  <xsl:param name="group_id"/>
  <xsl:param name="parent_title"/>
  <xsl:param name="chapter_number"/>
  <xsl:param name="chapter_parent"></xsl:param>

  <xsl:variable name="group_md" select="$general_meta/descendant::group[@id = $group_id]"/>
  <xsl:variable name="level" select="count($group_md/ancestor::group) + 1"/>
<!--
  Chapter numbering might come from the meta file too. In that case each group will
  have fix numbering regardless of the display order within the raw xml.
  <xsl:variable name="level_number" select="$group_md/@level_number"/>-->
  <xsl:variable name="level_number">
    <xsl:choose>
      <xsl:when test="$chapter_parent=''"><xsl:value-of select="concat($chapter_number,'.')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat($chapter_parent, $chapter_number,'.')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="desc" select="$group_md/@name"/>
  <xsl:variable name="num_of_fields" select="count($group_md/field)"/>

<!--  <xsl:variable name="has_subgroup_data" select="'yes'"/>-->
  <xsl:variable name="has_subgroup_data">
    <xsl:call-template name="has_subgroup_data">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="col_idx" select="$g_sdm_node_idx"/>
      <xsl:with-param name="group" select="$group_md"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$has_subgroup_data='yes'"><!-- Display level and subgroup only if there is data -->
      <!-- get rows for the given group -->
      <xsl:variable name="curr_data" select="$rows[input:Cell[$g_sdm_node_idx]/input:Data = $group_md/@node]"/>
      <!-- get group description -->

      <!-- Draw the heading of the current level -->
      <xsl:if test="not($group_md/@display-header) or $group_md/@display-header='yes'">
        <xsl:choose>
          <xsl:when test="$level &gt; 2">
            <!-- display joined columns only if parent has @header_with_specs -->
            <xsl:choose>
              <xsl:when test="count($group_md/ancestor::*[@header_with_specs = 'yes']) = 0">
                <xsl:call-template name="empty_row_raw"/>
                <xsl:call-template name="heading">
                  <xsl:with-param name="text" select="concat($level_number, ' ', $parent_title,': ', $desc)"/>
                  <xsl:with-param name="level" select="3"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="datarows">
                  <xsl:call-template name="get_first_data_of_nodes">
                    <xsl:with-param name="rows" select="$rows"/>
                    <xsl:with-param name="col_idx" select="$g_sdm_node_idx"/>
                    <xsl:with-param name="groups" select="$group_md/descendant-or-self::*[@node]"/>
                    <xsl:with-param name="position" select="1"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="empty_row_raw_bd"><xsl:with-param name="rows" select="$datarows/*"/></xsl:call-template>
                <xsl:call-template name="heading3_bd">
                  <xsl:with-param name="text" select="concat($level_number, ' ', $parent_title,': ', $desc)"/>
                  <xsl:with-param name="rows" select="$datarows/*"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="empty_row_raw"/>
            <xsl:call-template name="heading">
              <xsl:with-param name="text" select="concat($level_number, ' ', $desc)"/>
              <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
         </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- display the fields (if there is any) -->
      <xsl:call-template name="display_fields">
        <xsl:with-param name="rows" select="$curr_data"/>
        <xsl:with-param name="all_rows" select="$rows"/>
        <xsl:with-param name="group" select="$group_md"/>
      </xsl:call-template>

      <!-- display the next level -->
      <xsl:variable name="children" select="$group_md/group"/>
      <xsl:for-each select="$children">
        <xsl:variable name="child_id" select="./@id"/>
        <xsl:variable name="node_position" select="count($general_meta/descendant::group[@id = $child_id]/preceding-sibling::*) + 1"/>
        <xsl:variable name="pre_max_ch_number">
          <xsl:call-template name="preceding_data_groups">
            <xsl:with-param name="rows" select="$rows"/>
            <xsl:with-param name="col_idx" select="$g_sdm_node_idx"/>
            <xsl:with-param name="group" select="$general_meta/descendant::group[@id = $child_id]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="display_group">
          <xsl:with-param name="rows" select="$rows"/>
          <xsl:with-param name="group_id" select="./@id"/>
          <xsl:with-param name="parent_title" select="$desc"/>
          <xsl:with-param name="chapter_number" select="$pre_max_ch_number+1"/>
          <xsl:with-param name="chapter_parent" select="$level_number"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise><!-- No data to display--></xsl:otherwise>
  </xsl:choose>
</xsl:template>
<!-- ************************************************************************************************-->
<!-- Display the specifications as part of the header -->
<!-- ************************************************************************************************-->
<xsl:template name="display_specs_header">
  <xsl:param name="rows"/>

  <!-- get tabledata rows -->
  <xsl:variable name="datarows" select="$rows[input:Cell[$g_sdm_mt_flag_idx]/input:Data[.='TABLEDATA']]"/>
  <xsl:variable name="num_of_datarows" select="count($datarows)"/>

  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="open_row"/>
    <xsl:call-template name="draw_cell">
      <xsl:with-param name="text" select="''"/>
      <xsl:with-param name="style" select="'th14'"/>
    </xsl:call-template>
    <!-- rows are sorted by recipes                                           -->
    <!-- we write always only the last occurence of the recipe to the output  -->
    <!-- cells are merged based on the number of the given recipe in the list -->
    <xsl:for-each select="$datarows">
      <xsl:variable name="act_id" select="./input:Cell[$g_sdm_specid_idx]/input:Data/text()"/>
      <xsl:variable name="next_idx" select="position()+1"/>
      <xsl:variable name="next_id" select="$datarows[$next_idx]/input:Cell[$g_sdm_specid_idx]/input:Data/text()"/>

      <xsl:if test="$next_idx > $num_of_datarows or $act_id != $next_id">
        <xsl:variable name="across" select="count($datarows[input:Cell[$g_sdm_specid_idx]/input:Data/text() = $act_id])-1"/>
        <xsl:call-template name="draw_cell">
          <xsl:with-param name="text" select="$act_id"/>
          <xsl:with-param name="style" select="'th15'"/>
          <xsl:with-param name="colspan" select="$across"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  <xsl:call-template name="close_row"/>
  <xsl:call-template name="close_table_header"/>

</xsl:template>

<!-- ************************************************************************************************-->
<!-- Template for displaying the field for a given group -->
<!-- ************************************************************************************************-->

<xsl:template name="display_fields">
  <xsl:param name="rows"/>
  <xsl:param name="all_rows"/>
  <xsl:param name="group"/>

  <xsl:call-template name="open_table"/>

  <!-- display the SPECs as part of the header if necessary only for transposed table -->
  <xsl:if test="($OUTPUT = 'excel' and $group/@header_with_specs = 'yes') or
                ($OUTPUT = 'html' and $group/@display = 'transpose')">
    <!-- TODO: check if the group itself is assigned to a node -->
      <xsl:variable name="groups_with_node" select="$group/descendant-or-self::*[@node]"/>
      <xsl:variable name="node"             select="$groups_with_node[1]/@node"/>
<!--          <xsl:variable name="datarows"         select="$rows[input:Cell[$g_sdm_node_idx]/input:Data = $node]"/>-->
      <xsl:variable name="datarows">
        <xsl:call-template name="get_first_data_of_nodes">
          <xsl:with-param name="rows" select="$all_rows"/>
          <xsl:with-param name="col_idx" select="$g_sdm_node_idx"/>
          <xsl:with-param name="groups" select="$group/descendant-or-self::*[@node]"/>
          <xsl:with-param name="position" select="1"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="display_specs_header">
        <xsl:with-param name="rows" select="$datarows/*"/>
      </xsl:call-template>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$group/@display = 'transpose'"> <!-- use transpose display-->
      <xsl:call-template name="transpose_table">
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="field_list" select="$group/field"/>
        <xsl:with-param name="group" select="$group"/>
        <xsl:with-param name="all_rows" select="$all_rows"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$group/@display = 'normal'"> <!-- use normal table display-->
       <xsl:call-template name="table_display">
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="fieldlist" select="$group/field"/>
         <xsl:with-param name="master_column_idx" select="$g_sdm_specid_idx"/>
       </xsl:call-template>
    </xsl:when>
  </xsl:choose>

  <xsl:call-template name="close_table"/>

</xsl:template>

<!-- ************************************************************************************************-->
<!-- Template for: Transponate Table
     Parameters:
       - rows: the rows that must be transponated
       - field_list: list of fields that are allowed to be displayed. Their order
                     defines the final display order.
                     The field list can be defined in the top of this file. In order
                     to be applied for the current template the corresponding node
                     mus be passed from the calling template.
    -->
<!-- ************************************************************************************************-->
<xsl:template name="transpose_table">
  <xsl:param name="rows"/>
  <xsl:param name="field_list"/>
  <xsl:param name="group"/>
  <xsl:param name="all_rows"/>

  <xsl:variable name="offset" select="$g_sdm_specid_idx"/>
  <xsl:variable name="datarows" select="$rows[input:Cell[$g_sdm_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
  <xsl:variable name="metarows" select="$rows[input:Cell[$g_sdm_mt_flag_idx][input:Data[.='METADATA']]]"/>

  <xsl:variable name="related_node" select="$group/@related-node"/>
  <xsl:choose>
    <xsl:when test="$group/@related-node and count($all_rows[input:Cell[$g_sdm_node_idx]/input:Data=$related_node]) = 0 ">
      <!-- Do not display anything if a group has a related node that does not
           have any data at all.-->
    </xsl:when>
    <!-- display all fields in the transpose-->
    <xsl:when test="$field_list = ''">
      <!-- loop through the field names -->
      <xsl:for-each select="$rows[1]/input:Cell[position()>$offset]">
        <xsl:variable name="idx" select="position()+$offset"/>
        <xsl:call-template name="transpose_column">
          <xsl:with-param name="datarows" select="$datarows"/>
          <xsl:with-param name="metarows" select="$metarows"/>
          <xsl:with-param name="col_idx" select="$idx"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
    <!-- filter by predefined list of attributes -->
    <xsl:otherwise>
      <xsl:for-each select="$field_list">
        <xsl:variable name="field_id" select="."/>
        <!-- loop through the field names -->
        <xsl:for-each select="$rows[1]/input:Cell[position()>$offset]">
          <!-- check if the field id exists in the row-->
          <xsl:if test="input:Data = $field_id">
            <xsl:variable name="idx" select="position()+$offset"/>
            <xsl:call-template name="transpose_column">
              <xsl:with-param name="metarows" select="$metarows"/>
              <xsl:with-param name="datarows" select="$datarows"/>
              <xsl:with-param name="col_idx" select="$idx"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- ************************************************************************************************-->
<!-- Transpose column -->
<!-- ************************************************************************************************-->
<xsl:template name="transpose_column">
  <xsl:param name="datarows"/>
  <xsl:param name="metarows"/>
  <xsl:param name="col_idx"/>

  <xsl:variable name="num_of_datarows" select="count($datarows)"/>

  <xsl:call-template name="open_row"/>
  <!-- display description of the field-->
  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="$metarows[2]/input:Cell[$col_idx]/input:Data"/>
    <xsl:with-param name="style" select="'th11'"/>
  </xsl:call-template>

  <!-- loop through data -->
  <xsl:for-each select="$datarows">        <!-- display only TABLEDATA -->
    <xsl:variable name="act_idx" select="position()"/>
    <xsl:variable name="act_spec" select="./input:Cell[$g_sdm_specid_idx]/input:Data/text()"/>
    <xsl:variable name="next_idx" select="position()+1"/>
    <xsl:variable name="next_spec" select="$datarows[$next_idx]/input:Cell[$g_sdm_specid_idx]/input:Data/text()"/>

    <!-- determine style of the cell -->
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="$act_idx = $num_of_datarows">
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data"/>
            <xsl:with-param name="style_prefix">s30</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$act_idx = 1 and $act_spec = $next_spec">
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data"/>
            <xsl:with-param name="style_prefix">s35</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$act_idx = 1">
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data"/>
            <xsl:with-param name="style_prefix">s36</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$act_spec = $next_spec">
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data"/>
            <xsl:with-param name="style_prefix">s34</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$act_spec != $next_spec">
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data"/>
            <xsl:with-param name="style_prefix">s33</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="draw_cell">
      <xsl:with-param name="text" select="./input:Cell[$col_idx]/input:Data"/>
      <xsl:with-param name="style" select="$style"/>
      <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[$col_idx]/input:Data/text()"/>
    </xsl:call-template>
    </xsl:for-each>
  <xsl:call-template name="close_row"/>

</xsl:template>

<!-- ************************************************************************************************-->
<!-- This template needs to be finalized.
    main purpose is to display a table with a reordered columns and only
    the configured columns can be displayed.
       - rows: the rows of the table including metadata information
       - fieldlist: it contains the fields we would like to display
       - master_column_idx: (optional) index of the master column
    -->
<!-- ************************************************************************************************-->
<xsl:template name="table_display">
  <xsl:param name="rows"/>
  <xsl:param name="fieldlist"/>
  <xsl:param name="master_column_idx"/>

  <xsl:variable name="datarows" select="$rows[input:Cell[$g_sdm_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
  <xsl:variable name="metarows" select="$rows[input:Cell[$g_sdm_mt_flag_idx][input:Data[.='METADATA']]]"/>

  <!-- display the header -->
  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="table_row_display">
    <xsl:with-param name="metarows" select="$metarows"/>
    <xsl:with-param name="datarow" select="$metarows[2]"/>
    <xsl:with-param name="master_column_idx" select="$master_column_idx"/>
    <xsl:with-param name="fieldlist" select="$fieldlist"/>
    <xsl:with-param name="style" select="'th13'"/>
    <xsl:with-param name="is_header" select="true()"/>
  </xsl:call-template>
  <xsl:call-template name="close_table_header"/>

  <!-- display the data -->
  <xsl:for-each select="$datarows">
    <xsl:call-template name="table_row_display">
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="datarow" select="."/>
      <xsl:with-param name="master_column_idx" select="$master_column_idx"/>
      <xsl:with-param name="fieldlist" select="$fieldlist"/>
    </xsl:call-template>
  </xsl:for-each>

</xsl:template>



<!-- ************************************************************************************************-->
<!-- Table row display-->
<!-- ************************************************************************************************-->
<xsl:template name="table_row_display">
  <xsl:param name="metarows"/>
  <xsl:param name="datarow"/>
  <xsl:param name="fieldlist"/>
  <xsl:param name="master_column_idx" select="$master_column_idx"/>
  <xsl:param name="style">s30</xsl:param>
  <xsl:param name="is_header" select="false()"/>

  <xsl:variable name="offset" select="$g_sdm_specid_idx"/>
  <xsl:variable name="metarow_field_ids" select="$metarows[1]"/>
  <xsl:variable name="metarow_field_types" select="$metarows[3]"/>

  <xsl:call-template name="open_row"/>

  <xsl:if test="$master_column_idx != ''"> <!-- display a leading column for each row -->
    <xsl:variable name="master_col_style">
      <xsl:choose>
        <xsl:when test="$is_header">th18</xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="get_cell_style">
            <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[number($master_column_idx)]/input:Data"/>
            <xsl:with-param name="style_prefix">s33</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="draw_cell">
      <xsl:with-param name="text" select="$datarow/input:Cell[$master_column_idx]/input:Data"/>
      <xsl:with-param name="style" select="$master_col_style"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:for-each select="$fieldlist"> <!-- loop through the field names -->
    <xsl:variable name="field_id" select="."/>
    <xsl:for-each select="$metarow_field_ids/input:Cell[position()>$offset]">
      <!-- check if the field id exists in the row-->
      <xsl:if test="input:Data = $field_id">
        <xsl:variable name="idx" select="position()+$offset"/>
        <!-- display the value of the field -->

        <xsl:variable name="cellstyle">
          <xsl:choose>
            <xsl:when test="$is_header">th13</xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="get_cell_style">
                <xsl:with-param name="datatype" select="$metarows[3]/input:Cell[number($idx)]/input:Data"/>
                <xsl:with-param name="style_prefix">s30</xsl:with-param>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="datatype">
          <xsl:choose>
            <xsl:when test="$is_header">S</xsl:when>
            <xsl:otherwise><xsl:value-of select="$metarow_field_types/input:Cell[$idx]/input:Data/text()"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="draw_cell">
          <xsl:with-param name="text" select="$datarow/input:Cell[$idx]/input:Data/text()"/>
          <xsl:with-param name="style" select="$cellstyle"/>
          <xsl:with-param name="datatype" select="$datatype"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>     <!-- data cell -->
  </xsl:for-each>  <!-- fields to be displayed -->

  <xsl:call-template name="close_row"/>
</xsl:template>

<!-- ============================================================================================== -->
<!-- ============================================================================================== -->
<!--                                  PROPERTY TREE PROCESSING                                      -->
<!-- ============================================================================================== -->
<!-- ============================================================================================== -->


<!-- ============================================================================================== -->
<!-- Template for 'Property Tree' -->
<!-- ============================================================================================== -->
<xsl:template name="display_property_tree">
  <xsl:param name="num_of_worksheets"/> <!-- number of worksheets in the input document -->
  <xsl:param name="rows"/>   <!-- data rows -->

  <!-- Display Header -->
  <!-- <xsl:if test="count($rows) > 0">
    <xsl:call-template name="empty_row_raw"/>
    <xsl:call-template name="heading">
     <xsl:with-param name="text" select="'Properties'"/>
     <xsl:with-param name="level" select="1"/>
    </xsl:call-template>
  </xsl:if> -->
  <xsl:variable name="chapter_parent" select="$num_of_worksheets+1"/>

  <xsl:choose>
    <xsl:when test="$property_meta/node[1]/@display-property-tree = 'flat'">
      <xsl:call-template name="p_flat_property_tree">
        <xsl:with-param name="rows" select="$rows"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <!-- get distinct property values -->
      <xsl:variable name="properties" select="$rows/input:Cell[$g_prop_idx]/input:Data/text()[generate-id()=generate-id(key('properties',.)[1])]"/>
      <xsl:for-each select="$properties"><!-- Process the properties after eachother -->
        <xsl:variable name="prop" select="."/>
        <xsl:call-template name="prop_processor">
          <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_idx]/input:Data[.=$prop]]"/>
          <xsl:with-param name="prop" select="$prop"/>
          <xsl:with-param name="chapter_number" select="position()"/>
          <xsl:with-param name="chapter_parent" select="concat($chapter_parent,'.')"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display property tree in one flat table                                                        -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_tree">
  <xsl:param name="rows"/>

  <!-- <xsl:call-template name="empty_row_raw"/> -->
  <xsl:call-template name="open_table"/>
  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Property Tree'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Prop tree type'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'PT node'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'VAT'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'VAT ID'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Instance'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Attribute'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Additional Information'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Characteristic Name'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Characteristic Value'"/><xsl:with-param name="style" select="'th13'"/></xsl:call-template>
  <xsl:call-template name="close_row"/>
  <xsl:call-template name="close_table_header"/>

  <xsl:variable name="properties" select="$rows/input:Cell[$g_prop_idx]/input:Data/text()[generate-id()=generate-id(key('properties',.)[1])]"/>
  <xsl:for-each select="$properties">
    <xsl:variable name="prop" select="."/>
    <xsl:call-template name="p_flat_property">
      <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_idx]/input:Data[.=$prop]]"/>
    </xsl:call-template>
  </xsl:for-each>

  <xsl:call-template name="close_table"/>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display one property in flat table rows                                                        -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property">
  <xsl:param name="rows"/>

  <xsl:for-each select="$property_meta/node">
    <xsl:variable name="node" select="."/>
    <xsl:variable name="node_id" select="$node/@id"/>
    <xsl:variable name="node_rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node_id]"/>
    <xsl:variable name="datarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
    <xsl:variable name="metarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>

    <xsl:for-each select="$datarows">
      <xsl:variable name="datarow" select="."/>
      <xsl:for-each select="$metarows[1]/input:Cell[position()>$g_prop_specid_idx]/input:Data">
        <xsl:variable name="field_name" select="."/>
        <xsl:variable name="idx" select="position()+$g_prop_specid_idx"/>
        <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
        <xsl:if test="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'
                      and not($field_conf/@display='no')
                      and not(starts-with(normalize-space($field_name), '__'))">
          <xsl:call-template name="p_flat_property_row">
            <xsl:with-param name="datarow" select="$datarow"/>
            <xsl:with-param name="metarows" select="$metarows"/>
            <xsl:with-param name="col_idx" select="$idx"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display one characteristic as a flat table row                                                  -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_row">
  <xsl:param name="datarow"/>
  <xsl:param name="metarows"/>
  <xsl:param name="col_idx"/>

  <!-- ZSPPLR_XSL_DEBUG_20260816_003: hide group-backed rows by actual VAT id/description. -->
  <xsl:variable name="flat_vat_id" select="normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data)"/>
  <xsl:variable name="flat_vat_desc" select="normalize-space($datarow/input:Cell[$g_prop_desc_idx]/input:Data)"/>
  <xsl:variable name="hide_group_vat_row" select="
    $flat_vat_id='SAP_RMS_1012_005'
    or $flat_vat_id='SAP_RMS_1012_010'
    or $flat_vat_id='SAP_RMS_1012_021'
    or $flat_vat_id='SAP_RMS_1012_022'
    or $flat_vat_id='SAP_RMS_1012_025'
    or $flat_vat_id='SAP_EHS_1012_003'
    or $flat_vat_desc='Standard Composition'
    or $flat_vat_desc='Allergens'
    or $flat_vat_desc='Nutrient Composition'
    or $flat_vat_desc='Diet Suitability'
    or $flat_vat_desc='Religious Certificate Compliance'
    or $flat_vat_desc='Genetically Modified Ingredients'"/>

  <xsl:if test="not($hide_group_vat_row)">
  <xsl:variable name="instance">
    <xsl:call-template name="p_get_field_value">
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="datarow" select="$datarow"/>
      <xsl:with-param name="field_name" select="'META_INSTANCE'"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- ZSPPLR_XSL_DEBUG_20260816_004: column H uses the explicit Additional Information metadata row. -->
  <xsl:variable name="additional_info_row" select="$metarows[
    normalize-space(input:Cell[$g_prop_specid_idx]/input:Data)='Additional Information'
    or normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='5'
  ][1]"/>
  <xsl:variable name="additional_info_raw" select="$additional_info_row/input:Cell[$col_idx]/input:Data"/>
  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUES||'"/>
  <xsl:variable name="additional_info">
    <xsl:choose>
      <xsl:when test="contains($additional_info_raw, $allowed_values_separator)">
        <xsl:value-of select="substring-before($additional_info_raw, $allowed_values_separator)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$additional_info_raw"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="allowed_values">
    <xsl:if test="contains($additional_info_raw, $allowed_values_separator)">
      <xsl:value-of select="substring-after($additional_info_raw, $allowed_values_separator)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:call-template name="p_flat_property_allowed_value_tokens">
    <xsl:with-param name="datarow" select="$datarow"/>
    <xsl:with-param name="metarows" select="$metarows"/>
    <xsl:with-param name="col_idx" select="$col_idx"/>
    <xsl:with-param name="instance" select="$instance"/>
    <xsl:with-param name="additional_info" select="$additional_info"/>
    <xsl:with-param name="allowed_values" select="$allowed_values"/>
  </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display one flat property row for each predefined characteristic value token                    -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_allowed_value_tokens">
  <xsl:param name="datarow"/>
  <xsl:param name="metarows"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="instance"/>
  <xsl:param name="additional_info"/>
  <xsl:param name="allowed_values"/>

  <xsl:variable name="char_value">
    <xsl:choose>
      <xsl:when test="contains($allowed_values, '||ALLOWED_VALUE||')">
        <xsl:value-of select="substring-before($allowed_values, '||ALLOWED_VALUE||')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$allowed_values"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="p_draw_flat_property_row">
    <xsl:with-param name="datarow" select="$datarow"/>
    <xsl:with-param name="metarows" select="$metarows"/>
    <xsl:with-param name="col_idx" select="$col_idx"/>
    <xsl:with-param name="instance" select="$instance"/>
    <xsl:with-param name="additional_info" select="$additional_info"/>
    <xsl:with-param name="char_value" select="$char_value"/>
    <xsl:with-param name="allowed_values" select="$allowed_values"/>
  </xsl:call-template>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Format the current value like its matching allowed value token                                  -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_resolve_allowed_value">
  <xsl:param name="current_value"/>
  <xsl:param name="allowed_values"/>

  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUE||'"/>
  <xsl:variable name="current_value_key" select="normalize-space($current_value)"/>
  <xsl:variable name="allowed_value">
    <xsl:choose>
      <xsl:when test="contains($allowed_values, $allowed_values_separator)">
        <xsl:value-of select="substring-before($allowed_values, $allowed_values_separator)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$allowed_values"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="allowed_code" select="substring-before($allowed_value, '|')"/>
  <xsl:variable name="allowed_desc">
    <xsl:choose>
      <xsl:when test="contains($allowed_value, '|')">
        <xsl:value-of select="substring-after($allowed_value, '|')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$allowed_value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="normalize-space($allowed_values) = ''">
      <xsl:value-of select="$current_value"/>
    </xsl:when>
    <xsl:when test="
      normalize-space($allowed_value) = $current_value_key
      or (contains($allowed_value, '|') and normalize-space($allowed_code) = $current_value_key)
      or (contains($allowed_value, '|') and normalize-space($allowed_desc) = $current_value_key)">
      <xsl:value-of select="$allowed_value"/>
    </xsl:when>
    <xsl:when test="contains($allowed_values, $allowed_values_separator)">
      <xsl:call-template name="p_flat_property_resolve_allowed_value">
        <xsl:with-param name="current_value" select="$current_value"/>
        <xsl:with-param name="allowed_values" select="substring-after($allowed_values, $allowed_values_separator)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$current_value"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Draw one characteristic row in the flat property table                                          -->
<!-- ============================================================================================== -->
<xsl:template name="p_draw_flat_property_row">
  <xsl:param name="datarow"/>
  <xsl:param name="metarows"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="instance"/>
  <xsl:param name="additional_info"/>
  <xsl:param name="char_value"/>
  <xsl:param name="allowed_values"/>
  <xsl:variable name="characteristic_name_raw" select="normalize-space($metarows[1]/input:Cell[$col_idx]/input:Data)"/>
  <xsl:variable name="characteristic_name">
    <xsl:choose>
      <xsl:when test="starts-with($characteristic_name_raw, '__FTEXT_') or starts-with($characteristic_name_raw, '_FTEXT_')">
        <xsl:value-of select="concat(normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data), '_001')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$characteristic_name_raw"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$datarow/input:Cell[$g_prop_desc_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <!-- ZSPPLR_XSL_DEBUG_20260817_001: column B shows lt_selection-property_tree exported in the node description cell. -->
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$datarow/input:Cell[$g_prop_node_desc_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$datarow/input:Cell[$g_prop_vac_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$datarow/input:Cell[$g_prop_desc_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$datarow/input:Cell[$g_prop_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$instance"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$metarows[2]/input:Cell[$col_idx]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$additional_info"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$characteristic_name"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="$char_value"/>
    <xsl:with-param name="datatype" select="'S'"/>
  </xsl:call-template>
  <xsl:call-template name="p_flat_property_dropdown_source_cells">
    <xsl:with-param name="allowed_values" select="$allowed_values"/>
  </xsl:call-template>
  <xsl:call-template name="close_row"/>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Write dropdown source values into hidden cells after column J                                   -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_dropdown_source_cells">
  <xsl:param name="allowed_values"/>

  <xsl:variable name="allowed_value_count">
    <xsl:call-template name="p_flat_property_allowed_value_count">
      <xsl:with-param name="allowed_values" select="$allowed_values"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="number($allowed_value_count) > 1">
    <xsl:call-template name="p_flat_property_dropdown_source_cells_unique">
      <xsl:with-param name="allowed_values" select="$allowed_values"/>
      <xsl:with-param name="seen_values" select="''"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="p_flat_property_dropdown_source_cells_unique">
  <xsl:param name="allowed_values"/>
  <xsl:param name="seen_values"/>

  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUE||'"/>
  <xsl:variable name="seen_values_separator" select="'||SEEN_ALLOWED_VALUE||'"/>
  <xsl:variable name="allowed_value">
    <xsl:choose>
      <xsl:when test="contains($allowed_values, $allowed_values_separator)">
        <xsl:value-of select="substring-before($allowed_values, $allowed_values_separator)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$allowed_values"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="allowed_value_key" select="normalize-space($allowed_value)"/>
  <xsl:variable name="seen_value_token" select="concat($seen_values_separator, $allowed_value_key, $seen_values_separator)"/>

  <xsl:choose>
    <xsl:when test="normalize-space($allowed_values) = ''"/>
    <xsl:when test="contains($seen_values, $seen_value_token)">
      <xsl:call-template name="p_flat_property_dropdown_source_cells_unique">
        <xsl:with-param name="allowed_values" select="substring-after($allowed_values, $allowed_values_separator)"/>
        <xsl:with-param name="seen_values" select="$seen_values"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$allowed_value"/>
        <xsl:with-param name="datatype" select="'S'"/>
        <xsl:with-param name="style" select="'zhidden'"/>
      </xsl:call-template>
      <xsl:if test="contains($allowed_values, $allowed_values_separator)">
        <xsl:call-template name="p_flat_property_dropdown_source_cells_unique">
          <xsl:with-param name="allowed_values" select="substring-after($allowed_values, $allowed_values_separator)"/>
          <xsl:with-param name="seen_values" select="concat($seen_values, $seen_value_token)"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Count dropdown source values                                                                    -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_allowed_value_count">
  <xsl:param name="allowed_values"/>

  <xsl:call-template name="p_flat_property_unique_allowed_value_count">
    <xsl:with-param name="allowed_values" select="$allowed_values"/>
    <xsl:with-param name="seen_values" select="''"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="p_flat_property_unique_allowed_value_count">
  <xsl:param name="allowed_values"/>
  <xsl:param name="seen_values"/>

  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUE||'"/>
  <xsl:variable name="seen_values_separator" select="'||SEEN_ALLOWED_VALUE||'"/>
  <xsl:variable name="allowed_value">
    <xsl:choose>
      <xsl:when test="contains($allowed_values, $allowed_values_separator)">
        <xsl:value-of select="substring-before($allowed_values, $allowed_values_separator)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$allowed_values"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="allowed_value_key" select="normalize-space($allowed_value)"/>
  <xsl:variable name="seen_value_token" select="concat($seen_values_separator, $allowed_value_key, $seen_values_separator)"/>

  <xsl:choose>
    <xsl:when test="normalize-space($allowed_values) = ''">0</xsl:when>
    <xsl:when test="contains($allowed_values, $allowed_values_separator)">
      <xsl:variable name="remaining_count">
        <xsl:call-template name="p_flat_property_unique_allowed_value_count">
          <xsl:with-param name="allowed_values" select="substring-after($allowed_values, $allowed_values_separator)"/>
          <xsl:with-param name="seen_values">
            <xsl:choose>
              <xsl:when test="contains($seen_values, $seen_value_token)">
                <xsl:value-of select="$seen_values"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($seen_values, $seen_value_token)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($seen_values, $seen_value_token)">
          <xsl:value-of select="number($remaining_count)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1 + number($remaining_count)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="contains($seen_values, $seen_value_token)">0</xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Determine the widest helper-list column span needed                                             -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_max_dropdown_columns">
  <xsl:param name="rows"/>

  <xsl:call-template name="p_flat_property_max_dropdown_columns_values">
    <xsl:with-param name="values" select="$rows/input:Cell/input:Data[contains(., '||ALLOWED_VALUES||')]"/>
    <xsl:with-param name="max_count" select="0"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="p_flat_property_max_dropdown_columns_values">
  <xsl:param name="values"/>
  <xsl:param name="max_count"/>

  <xsl:choose>
    <xsl:when test="count($values) = 0">
      <xsl:value-of select="$max_count"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="allowed_values" select="substring-after($values[1], '||ALLOWED_VALUES||')"/>
      <xsl:variable name="allowed_value_count">
        <xsl:call-template name="p_flat_property_allowed_value_count">
          <xsl:with-param name="allowed_values" select="$allowed_values"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="p_flat_property_max_dropdown_columns_values">
        <xsl:with-param name="values" select="$values[position()>1]"/>
        <xsl:with-param name="max_count">
          <xsl:choose>
            <xsl:when test="number($allowed_value_count) &gt; number($max_count)">
              <xsl:value-of select="number($allowed_value_count)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="number($max_count)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Add Excel dropdown validations for flat characteristic-value cells                              -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_dropdown_validations">
  <xsl:param name="rows"/>

  <xsl:variable name="properties" select="$rows/input:Cell[$g_prop_idx]/input:Data/text()[generate-id()=generate-id(key('properties',.)[1])]"/>
  <xsl:call-template name="p_flat_property_dropdown_validation_properties">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="properties" select="$properties"/>
    <xsl:with-param name="row_no" select="2"/>
  </xsl:call-template>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Walk flat properties while carrying the emitted Excel row number                                -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_dropdown_validation_properties">
  <xsl:param name="rows"/>
  <xsl:param name="properties"/>
  <xsl:param name="row_no"/>

  <xsl:if test="count($properties) > 0">
    <xsl:variable name="prop" select="$properties[1]"/>
    <xsl:variable name="prop_rows" select="$rows[input:Cell[$g_prop_idx]/input:Data[.=$prop]]"/>
    <xsl:variable name="property_output_row_count">
      <xsl:call-template name="p_flat_property_output_row_count">
        <xsl:with-param name="rows" select="$prop_rows"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="p_flat_property_dropdown_validation_property">
      <xsl:with-param name="rows" select="$prop_rows"/>
      <xsl:with-param name="row_no" select="$row_no"/>
    </xsl:call-template>

    <xsl:call-template name="p_flat_property_dropdown_validation_properties">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="properties" select="$properties[position()>1]"/>
      <xsl:with-param name="row_no" select="$row_no + number($property_output_row_count)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Count rows emitted by the same filters used by p_flat_property                                  -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_output_row_count">
  <xsl:param name="rows"/>

  <xsl:call-template name="p_flat_property_output_row_count_nodes">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="nodes" select="$property_meta/node"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="p_flat_property_output_row_count_nodes">
  <xsl:param name="rows"/>
  <xsl:param name="nodes"/>

  <xsl:choose>
    <xsl:when test="count($nodes) = 0">0</xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node" select="$nodes[1]"/>
      <xsl:variable name="node_id" select="$node/@id"/>
      <xsl:variable name="node_rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node_id]"/>
      <xsl:variable name="datarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
      <xsl:variable name="metarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>
      <xsl:variable name="field_count">
        <xsl:call-template name="p_flat_property_visible_field_count">
          <xsl:with-param name="metarows" select="$metarows"/>
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="fields" select="$metarows[1]/input:Cell[position()>$g_prop_specid_idx]/input:Data"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="node_row_count">
        <xsl:call-template name="p_flat_property_output_row_count_datarows">
          <xsl:with-param name="datarows" select="$datarows"/>
          <xsl:with-param name="field_count" select="number($field_count)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="remaining_row_count">
        <xsl:call-template name="p_flat_property_output_row_count_nodes">
          <xsl:with-param name="rows" select="$rows"/>
          <xsl:with-param name="nodes" select="$nodes[position()>1]"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="number($node_row_count) + number($remaining_row_count)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="p_flat_property_output_row_count_datarows">
  <xsl:param name="datarows"/>
  <xsl:param name="field_count"/>

  <xsl:choose>
    <xsl:when test="count($datarows) = 0">0</xsl:when>
    <xsl:otherwise>
      <xsl:variable name="datarow" select="$datarows[1]"/>
      <xsl:variable name="flat_vat_id" select="normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data)"/>
      <xsl:variable name="flat_vat_desc" select="normalize-space($datarow/input:Cell[$g_prop_desc_idx]/input:Data)"/>
      <xsl:variable name="hide_group_vat_row" select="
        $flat_vat_id='SAP_RMS_1012_005'
        or $flat_vat_id='SAP_RMS_1012_010'
        or $flat_vat_id='SAP_RMS_1012_021'
        or $flat_vat_id='SAP_RMS_1012_022'
        or $flat_vat_id='SAP_RMS_1012_025'
        or $flat_vat_id='SAP_EHS_1012_003'
        or $flat_vat_desc='Standard Composition'
        or $flat_vat_desc='Allergens'
        or $flat_vat_desc='Nutrient Composition'
        or $flat_vat_desc='Diet Suitability'
        or $flat_vat_desc='Religious Certificate Compliance'
        or $flat_vat_desc='Genetically Modified Ingredients'"/>
      <xsl:variable name="current_row_count">
        <xsl:choose>
          <xsl:when test="$hide_group_vat_row">0</xsl:when>
          <xsl:otherwise><xsl:value-of select="number($field_count)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="remaining_row_count">
        <xsl:call-template name="p_flat_property_output_row_count_datarows">
          <xsl:with-param name="datarows" select="$datarows[position()>1]"/>
          <xsl:with-param name="field_count" select="number($field_count)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="number($current_row_count) + number($remaining_row_count)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="p_flat_property_visible_field_count">
  <xsl:param name="metarows"/>
  <xsl:param name="node"/>
  <xsl:param name="fields"/>

  <xsl:choose>
    <xsl:when test="count($fields) = 0">0</xsl:when>
    <xsl:otherwise>
      <xsl:variable name="field_name" select="$fields[1]"/>
      <xsl:variable name="idx" select="count($fields[1]/parent::input:Cell/preceding-sibling::input:Cell) + 1"/>
      <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
      <xsl:variable name="current_field_count">
        <xsl:choose>
          <xsl:when test="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'
                          and not($field_conf/@display='no')
                          and not(starts-with(normalize-space($field_name), '__'))">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="remaining_field_count">
        <xsl:call-template name="p_flat_property_visible_field_count">
          <xsl:with-param name="metarows" select="$metarows"/>
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="fields" select="$fields[position()>1]"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="number($current_field_count) + number($remaining_field_count)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Add dropdown validations for one flat property                                                  -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_dropdown_validation_property">
  <xsl:param name="rows"/>
  <xsl:param name="row_no"/>

  <xsl:call-template name="p_flat_property_dropdown_validation_nodes">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="nodes" select="$property_meta/node"/>
    <xsl:with-param name="row_no" select="$row_no"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="p_flat_property_dropdown_validation_nodes">
  <xsl:param name="rows"/>
  <xsl:param name="nodes"/>
  <xsl:param name="row_no"/>

  <xsl:if test="count($nodes) > 0">
    <xsl:variable name="node" select="$nodes[1]"/>
    <xsl:variable name="node_id" select="$node/@id"/>
    <xsl:variable name="node_rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node_id]"/>
    <xsl:variable name="datarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
    <xsl:variable name="metarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>
    <xsl:variable name="node_row_count">
      <xsl:call-template name="p_flat_property_output_row_count_nodes">
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="nodes" select="$nodes[1]"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="p_flat_property_dropdown_validation_datarows">
      <xsl:with-param name="datarows" select="$datarows"/>
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="row_no" select="$row_no"/>
    </xsl:call-template>

    <xsl:call-template name="p_flat_property_dropdown_validation_nodes">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="nodes" select="$nodes[position()>1]"/>
      <xsl:with-param name="row_no" select="$row_no + number($node_row_count)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="p_flat_property_dropdown_validation_datarows">
  <xsl:param name="datarows"/>
  <xsl:param name="metarows"/>
  <xsl:param name="node"/>
  <xsl:param name="row_no"/>

  <xsl:if test="count($datarows) > 0">
    <xsl:variable name="datarow" select="$datarows[1]"/>
    <xsl:variable name="fields" select="$metarows[1]/input:Cell[position()>$g_prop_specid_idx]/input:Data"/>
    <xsl:variable name="field_count">
      <xsl:call-template name="p_flat_property_visible_field_count">
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="fields" select="$fields"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="flat_vat_id" select="normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data)"/>
    <xsl:variable name="flat_vat_desc" select="normalize-space($datarow/input:Cell[$g_prop_desc_idx]/input:Data)"/>
    <xsl:variable name="hide_group_vat_row" select="
      $flat_vat_id='SAP_RMS_1012_005'
      or $flat_vat_id='SAP_RMS_1012_010'
      or $flat_vat_id='SAP_RMS_1012_021'
      or $flat_vat_id='SAP_RMS_1012_022'
      or $flat_vat_id='SAP_RMS_1012_025'
      or $flat_vat_id='SAP_EHS_1012_003'
      or $flat_vat_desc='Standard Composition'
      or $flat_vat_desc='Allergens'
      or $flat_vat_desc='Nutrient Composition'
      or $flat_vat_desc='Diet Suitability'
      or $flat_vat_desc='Religious Certificate Compliance'
      or $flat_vat_desc='Genetically Modified Ingredients'"/>

    <xsl:if test="not($hide_group_vat_row)">
      <xsl:call-template name="p_flat_property_dropdown_validation_fields">
        <xsl:with-param name="fields" select="$fields"/>
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="row_no" select="$row_no"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:call-template name="p_flat_property_dropdown_validation_datarows">
      <xsl:with-param name="datarows" select="$datarows[position()>1]"/>
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="row_no">
        <xsl:choose>
          <xsl:when test="$hide_group_vat_row"><xsl:value-of select="$row_no"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$row_no + number($field_count)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="p_flat_property_dropdown_validation_fields">
  <xsl:param name="fields"/>
  <xsl:param name="metarows"/>
  <xsl:param name="node"/>
  <xsl:param name="row_no"/>

  <xsl:if test="count($fields) > 0">
    <xsl:variable name="field_name" select="$fields[1]"/>
    <xsl:variable name="idx" select="count($fields[1]/parent::input:Cell/preceding-sibling::input:Cell) + 1"/>
    <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
    <xsl:variable name="is_visible_field"
      select="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'
              and not($field_conf/@display='no')
              and not(starts-with(normalize-space($field_name), '__'))"/>

    <xsl:if test="$is_visible_field">
      <xsl:call-template name="p_flat_property_dropdown_validation">
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="col_idx" select="$idx"/>
        <xsl:with-param name="row_no" select="$row_no"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:call-template name="p_flat_property_dropdown_validation_fields">
      <xsl:with-param name="fields" select="$fields[position()>1]"/>
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="row_no">
        <xsl:choose>
          <xsl:when test="$is_visible_field"><xsl:value-of select="$row_no + 1"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$row_no"/></xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Add one dropdown validation to column J                                                        -->
<!-- ============================================================================================== -->
<xsl:template name="p_flat_property_dropdown_validation">
  <xsl:param name="metarows"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="row_no"/>

  <xsl:variable name="additional_info_row" select="$metarows[
    normalize-space(input:Cell[$g_prop_specid_idx]/input:Data)='Additional Information'
    or normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='5'
  ][1]"/>
  <xsl:variable name="additional_info_raw" select="$additional_info_row/input:Cell[$col_idx]/input:Data"/>
  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUES||'"/>
  <xsl:variable name="allowed_values">
    <xsl:if test="contains($additional_info_raw, $allowed_values_separator)">
      <xsl:value-of select="substring-after($additional_info_raw, $allowed_values_separator)"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="allowed_value_count">
    <xsl:call-template name="p_flat_property_allowed_value_count">
      <xsl:with-param name="allowed_values" select="$allowed_values"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="last_source_col" select="10 + number($allowed_value_count)"/>

  <xsl:if test="number($allowed_value_count) > 1">
    <xsl:text disable-output-escaping="yes">&lt;DataValidation xmlns="urn:schemas-microsoft-com:office:excel"&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;Range&gt;R</xsl:text>
    <xsl:value-of select="$row_no"/>
    <xsl:text disable-output-escaping="yes">C10&lt;/Range&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;Type&gt;List&lt;/Type&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;UseBlank/&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;Value&gt;=Data!R</xsl:text>
    <xsl:value-of select="$row_no"/>
    <xsl:text disable-output-escaping="yes">C11:R</xsl:text>
    <xsl:value-of select="$row_no"/>
    <xsl:text disable-output-escaping="yes">C</xsl:text>
    <xsl:value-of select="$last_source_col"/>
    <xsl:text disable-output-escaping="yes">&lt;/Value&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;/DataValidation&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display group values in a second worksheet                                                     -->
<!-- ============================================================================================== -->
<xsl:template name="display_group_sheet">
  <xsl:param name="rows"/>

  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'VAT Description'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Identifier'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'VAT ID'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'SpecID'"/><xsl:with-param name="style" select="'zgreyh'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Target Value'"/><xsl:with-param name="style" select="'th13'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Amount (Allergen)'"/><xsl:with-param name="style" select="'th13'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'Amount UoM(PPM)'"/><xsl:with-param name="style" select="'th13'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="'UoM'"/><xsl:with-param name="style" select="'th13'"/></xsl:call-template>
  <xsl:call-template name="close_row"/>
  <xsl:call-template name="close_table_header"/>

  <xsl:for-each select="$rows">
    <xsl:variable name="source_row" select="."/>
    <xsl:variable name="metadata_row" select="$source_row/preceding-sibling::input:Row[input:Cell[$g_prop_mt_flag_idx]/input:Data='METADATA' and normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='1'][1]"/>
    <!--
      Some matching TABLEDATA rows are instance/header rows. For example,
      Religious Certificate Compliance/Instances carries SAP_RMS_1012_022 in
      multiple cells, but its metadata has no SUBID. Those rows are not group
      detail rows and must not be written to sheet 2.
    -->
    <xsl:variable name="subid_idx">
      <xsl:for-each select="$metadata_row/input:Cell">
        <xsl:if test="normalize-space(input:Data)='SUBID'">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="spec_id" select="normalize-space($source_row/input:Cell[number(normalize-space($subid_idx))]/input:Data)"/>
    <xsl:if test="normalize-space($subid_idx) != '' and $spec_id != ''">
      <xsl:call-template name="p_group_specid_row">
        <xsl:with-param name="spec_id" select="$spec_id"/>
        <xsl:with-param name="source_row" select="$source_row"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display one group row                                                                          -->
<!-- ============================================================================================== -->
<xsl:template name="p_group_specid_row">
  <xsl:param name="spec_id"/>
  <xsl:param name="source_row"/>
  <xsl:variable name="metadata_row" select="$source_row/preceding-sibling::input:Row[input:Cell[$g_prop_mt_flag_idx]/input:Data='METADATA' and normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='1'][1]"/>
  <!-- Identifier is read by technical column name because IDENT1 can appear at
       different physical positions for different value assignment layouts. -->
  <xsl:variable name="ident1_idx">
    <xsl:for-each select="$metadata_row/input:Cell">
      <xsl:if test="normalize-space(input:Data)='IDENT1'">
        <xsl:value-of select="position()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$source_row/input:Cell[2]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$source_row/input:Cell[number(normalize-space($ident1_idx))]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$source_row/input:Cell[1]/input:Data"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="$spec_id"/><xsl:with-param name="style" select="'zgrey'"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="''"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="''"/></xsl:call-template>
  <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="''"/></xsl:call-template>
  <xsl:choose>
    <xsl:when test="normalize-space($source_row/input:Cell[1]/input:Data)='SAP_RMS_1012_005'">
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$source_row/input:Cell[
          position() = count($metadata_row/input:Cell[
            normalize-space(input:Data)='COMPEXP_STEXT'][1]/preceding-sibling::input:Cell) + 1
          and $metadata_row/input:Cell[normalize-space(input:Data)='COMPEXP_STEXT']
        ]/input:Data"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="draw_cell"><xsl:with-param name="text" select="''"/></xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="close_row"/>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Get a property row field value by technical field name                                          -->
<!-- ============================================================================================== -->
<xsl:template name="p_get_field_value">
  <xsl:param name="metarows"/>
  <xsl:param name="datarow"/>
  <xsl:param name="field_name"/>

  <xsl:for-each select="$metarows[1]/input:Cell[position()>$g_prop_lnum_idx]">
    <xsl:variable name="idx" select="position()+$g_prop_lnum_idx"/>
    <xsl:if test="input:Data = $field_name">
      <xsl:value-of select="$datarow/input:Cell[$idx]/input:Data"/>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Template for Property Processor -->
<!-- ============================================================================================== -->
<xsl:template name="prop_processor">
  <xsl:param name="rows"/>          <!-- rows of a given property including all nodes -->
  <xsl:param name="prop"/>          <!-- technical name of the property -->
  <xsl:param name="chapter_number"/><!-- current chapter number -->
  <xsl:param name="chapter_parent"/><!-- chapter number of the parent -->

  <xsl:variable name="desc" select="$rows[1]/input:Cell[$g_prop_desc_idx]/input:Data"/>
  <xsl:variable name="prop_desc" select="concat($chapter_parent,$chapter_number,'. ', $desc)"/>

  <!-- Display Heading for property -->
  <xsl:call-template name="empty_row_raw"/>
  <xsl:call-template name="heading">
    <xsl:with-param name="text" select="$prop_desc"/>
    <xsl:with-param name="level" select="2"/>
  </xsl:call-template>

  <!-- Display the property Nodes -->
  <xsl:if test="count($rows) > 0">
      <xsl:call-template name="p_display_property">
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="node" select="$property_meta/node[1]"/>
        <xsl:with-param name="chapter_id" select="1"/>
        <xsl:with-param name="chapter_parent" select="concat($chapter_parent,$chapter_number)"/>
      </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- ============================================================================================== -->
<!-- Template for displaying a property node -->
<!-- ============================================================================================== -->
<xsl:template name="p_display_property">
  <xsl:param name="rows"/>          <!-- all rows for a given property-->
  <xsl:param name="node"/>          <!-- node that is basis of the row processing -->
  <xsl:param name="chapter_id"/>    <!-- current chapter number -->
  <xsl:param name="chapter_parent"/><!-- chapter number of the parent -->

  <xsl:variable name="data" select="$rows[input:Cell[$g_prop_mt_flag_idx]/input:Data='TABLEDATA']"/>
  <xsl:variable name="prop_desc" select="$rows[1]/input:Cell[$g_prop_desc_idx]/input:Data"/>
  <xsl:variable name="curr_data" select="$data[input:Cell[$g_prop_node_idx]/input:Data=$node/@id]"/>

  <!-- calculate the next chapter number within the property -->
  <xsl:variable name="next_chapter_id">
    <xsl:choose>
      <xsl:when test="count($curr_data) > 0">
        <xsl:value-of select="$chapter_id+1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$chapter_id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Display -->
  <xsl:if test="count($curr_data) > 0">
    <xsl:variable name="display" select="$node/@display"/>
    <xsl:variable name="node_desc" select="$curr_data[1]/input:Cell[$g_prop_node_desc_idx]/input:Data"/>
    <!-- Display Heading of the Node-->
    <xsl:if test="not($node/@display-header) or $node/@display-header='yes'">
      <xsl:call-template name="empty_row_raw"/>
      <xsl:call-template name="heading">
        <xsl:with-param name="text" select="concat($chapter_parent, '.', $chapter_id, ' ' ,$prop_desc,': ', $node_desc)"/>
        <xsl:with-param name="level" select="3"/>
      </xsl:call-template>
      <xsl:call-template name="empty_row_raw"/>
    </xsl:if>

    <!-- Display data-->
    <xsl:call-template name="open_table"/>
    <xsl:choose>
      <xsl:when test="$display = 'normal'">       <!-- display normal table -->
        <xsl:call-template name="p_table_display">
          <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node/@id]"/>
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$display = 'transpose'">  <!-- display transposed table -->
        <xsl:if test="not($node/@display-spec-header) or $node/@display-spec-header='yes'">
          <xsl:call-template name="p_display_specs_header">
            <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node/@id]"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="p_transpose_table">
          <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node/@id]"/>
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="close_table"/>
  </xsl:if>

  <!-- JUMP to the next node -->
  <xsl:variable name="node_idx" select="count($node/preceding-sibling::*) + 1"/>
  <xsl:if test="$node_idx &lt; count($property_meta/node)">
    <xsl:call-template name="p_display_property">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="node" select="$property_meta/node[$node_idx+1]"/>
      <xsl:with-param name="chapter_id" select="$next_chapter_id"/>
      <xsl:with-param name="chapter_parent" select="$chapter_parent"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display the specifications as part of the header -->
<!-- ============================================================================================== -->
<xsl:template name="p_display_specs_header">
  <xsl:param name="rows"/>

  <!-- get tabledata rows -->
  <xsl:variable name="datarows" select="$rows[input:Cell[$g_prop_mt_flag_idx]/input:Data[.='TABLEDATA']]"/>
  <xsl:variable name="num_of_datarows" select="count($datarows)"/>

  <xsl:call-template name="open_table_header"/>

  <xsl:call-template name="open_row"/>

  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="''"/>
    <xsl:with-param name="style" select="'th14'"/>
  </xsl:call-template>

  <xsl:for-each select="$datarows">
    <xsl:variable name="act_id" select="./input:Cell[$g_prop_specid_idx]/input:Data/text()"/>
    <xsl:variable name="next_idx" select="position()+1"/>
    <xsl:variable name="next_id" select="$datarows[$next_idx]/input:Cell[$g_prop_specid_idx]/input:Data/text()"/>

    <xsl:if test="$next_idx > $num_of_datarows or $act_id != $next_id">
      <xsl:variable name="across" select="count($datarows[input:Cell[$g_prop_specid_idx]/input:Data/text() = $act_id])-1"/>
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$act_id"/>
        <xsl:with-param name="style" select="'th15'"/>
        <xsl:with-param name="colspan" select="$across"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:for-each>
  <xsl:call-template name="close_row"/>
  <xsl:call-template name="close_table_header"/>

</xsl:template>

<!-- ============================================================================================== -->
<!-- Template for displaying a property node -->
<!-- ============================================================================================== -->
<xsl:template name="p_transpose_table">
  <xsl:param name="rows"/>
  <xsl:param name="node"/>

  <xsl:variable name="offset" select="$g_prop_specid_idx"/>
  <!-- ZSPPLR_XSL_DEBUG_20260813_001 hide Standard Composition from the first sheet -->
  <xsl:variable name="datarows"
    select="$rows[
      input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]
      and normalize-space(input:Cell[$g_prop_idx]/input:Data) != 'SAP_EHS_1012_003'
      and normalize-space(input:Cell[$g_prop_specid_idx]/input:Data) != 'SAP_EHS_1012_003'
    ]"/>
  <xsl:variable name="metarows" select="$rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>

  <!-- loop through the field names of meta -->
  <xsl:for-each select="$node/field[not(@display)]">
    <xsl:variable name="field" select="."/>
    <xsl:for-each select="$metarows[1]/input:Cell[position()>$offset]">
      <!-- check if the field id exists in the row-->
      <xsl:if test="input:Data = $field">
        <xsl:variable name="idx" select="position()+$offset"/>
        <xsl:call-template name="p_transpose_column">
          <xsl:with-param name="metarows" select="$metarows"/>
          <xsl:with-param name="datarows" select="$datarows"/>
          <xsl:with-param name="col_idx" select="$idx"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>

  <!-- loop through the datarows-->
  <xsl:if test="$node/@display-input-fields='yes'">       <!-- display the input fields only the customizing allows it -->
    <xsl:for-each select="$metarows[1]/input:Cell[position()>$offset]/input:Data">
      <xsl:variable name="field_name" select="."/>
      <xsl:variable name="idx" select="position()+$offset"/>
      <xsl:if test="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'">
        <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
        <xsl:choose>
          <xsl:when test="count($field_conf) = 0 or $field_conf/@display='yes'"><!-- no customizing exists, display the field -->
            <xsl:call-template name="p_transpose_column">
              <xsl:with-param name="metarows" select="$metarows"/>
              <xsl:with-param name="datarows" select="$datarows"/>
              <xsl:with-param name="col_idx" select="$idx"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$field_conf/@display='no'">
            <!-- do not display the field -->
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:if>

</xsl:template>

<!-- ============================================================================================== -->
<!-- Transpose property column -->
<!-- ============================================================================================== -->
<xsl:template name="p_transpose_column">
  <xsl:param name="metarows"/>
  <xsl:param name="datarows"/>
  <xsl:param name="col_idx"/>

  <xsl:variable name="num_of_datarows" select="count($datarows)"/>

  <xsl:call-template name="open_row"/>
    <!-- display description of the field-->
    <xsl:variable name="desc" select="$metarows[2]/input:Cell[$col_idx]/input:Data"/>
    <xsl:call-template name="draw_cell">
      <xsl:with-param name="text" select="$desc"/>
      <xsl:with-param name="style" select="'th11'"/>
    </xsl:call-template>

    <!-- loop through data -->
    <xsl:for-each select="$datarows">        <!-- display only TABLEDATA -->
      <xsl:variable name="act_idx" select="position()"/>
      <xsl:variable name="act_spec" select="./input:Cell[$g_prop_specid_idx]/input:Data/text()"/>
      <xsl:variable name="next_idx" select="position()+1"/>
      <xsl:variable name="next_spec" select="$datarows[$next_idx]/input:Cell[$g_prop_specid_idx]/input:Data/text()"/>

      <xsl:variable name="value" select="./input:Cell[$col_idx]/input:Data/text()"/>

      <!-- determine style of the cell -->
      <xsl:variable name="style">
        <xsl:choose>
          <xsl:when test="$act_idx = $num_of_datarows">
            <xsl:call-template name="get_cell_style">
              <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data"/>
              <xsl:with-param name="style_prefix">s30</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$act_idx = 1 and $act_spec = $next_spec">
            <xsl:call-template name="get_cell_style">
              <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data"/>
              <xsl:with-param name="style_prefix">s35</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$act_idx = 1">
            <xsl:call-template name="get_cell_style">
              <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data"/>
              <xsl:with-param name="style_prefix">s36</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$act_spec = $next_spec">
            <xsl:call-template name="get_cell_style">
              <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data"/>
              <xsl:with-param name="style_prefix">s34</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$act_spec != $next_spec">
            <xsl:call-template name="get_cell_style">
              <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data"/>
              <xsl:with-param name="style_prefix">s33</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <!-- Draw the Cell -->
<!--      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$value"/>
        <xsl:with-param name="style" select="$style"/>
      </xsl:call-template>-->

      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$value"/>
        <xsl:with-param name="style" select="$style"/>
        <xsl:with-param name="datatype" select="$metarows[4]/input:Cell[$col_idx]/input:Data/text()"/>
      </xsl:call-template>

    </xsl:for-each>
  <xsl:call-template name="close_row"/>
</xsl:template>

<!-- ============================================================================================== -->
<!-- Display vertival table                                                                         -->
<!-- ============================================================================================== -->
<xsl:template name="p_table_display">
  <xsl:param name="rows"/>  <!-- rows of a given node -->
  <xsl:param name="node"/>  <!-- node -->
  <xsl:param name="master_column_idx"/>

  <!-- ZSPPLR_XSL_DEBUG_20260813_002 hide Standard Composition from the first sheet -->
  <xsl:variable name="datarows"
    select="$rows[
      input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]
      and normalize-space(input:Cell[$g_prop_idx]/input:Data) != 'SAP_EHS_1012_003'
      and normalize-space(input:Cell[$g_prop_specid_idx]/input:Data) != 'SAP_EHS_1012_003'
    ]"/>
  <xsl:variable name="metarows" select="$rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>

  <!-- display the header -->
  <xsl:call-template name="open_table_header"/>
  <xsl:call-template name="p_table_row_display">
    <xsl:with-param name="metarows" select="$metarows"/>
    <xsl:with-param name="datarow" select="$metarows[2]"/>
    <xsl:with-param name="node" select="$node"/>
    <xsl:with-param name="is_header" select="true()"/>
  </xsl:call-template>
  <xsl:call-template name="close_table_header"/>

  <!-- display the data -->
  <xsl:for-each select="$datarows">
    <xsl:call-template name="p_table_row_display">
      <xsl:with-param name="metarows" select="$metarows"/>
      <xsl:with-param name="datarow" select="."/>                             <!-- Current row -->
      <xsl:with-param name="node" select="$node"/>                    <!-- special fields from customizing -->
    </xsl:call-template>
  </xsl:for-each>

</xsl:template>



<!-- ============================================================================================== -->
<!-- Display vertical table row                                                                     -->
<!-- ============================================================================================== -->
<xsl:template name="p_table_row_display">
  <xsl:param name="metaheader"/>
  <xsl:param name="metarows"/>
  <xsl:param name="datarow"/>
  <xsl:param name="node"/>
  <xsl:param name="style">s30</xsl:param>         <!-- default cell style prefix -->
  <xsl:param name="headerstyle">th13</xsl:param>  <!-- Default header style -->
  <xsl:param name="is_header" select="false()"/>

  <xsl:variable name="offset" select="$g_prop_lnum_idx"/>
  <xsl:variable name="metarow_field_ids" select="$metarows[1]"/>
  <xsl:variable name="metarow_field_types" select="$metarows[4]"/>

  <xsl:call-template name="open_row"/> <!-- start a new row -->

  <!-- loop through the field names of meta -->
  <xsl:for-each select="$node/field">
    <xsl:variable name="field" select="."/>
    <xsl:for-each select="$metarow_field_ids/input:Cell[position()>$offset]">
      <xsl:variable name="idx" select="position()+$offset"/>
      <xsl:if test="input:Data = $field and not($field/@display)">

        <xsl:variable name="cellstyle">
          <xsl:choose>
            <xsl:when test="$is_header"><xsl:value-of select="$headerstyle"/></xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="get_cell_style">
                <xsl:with-param name="datatype" select="$metarow_field_types/input:Cell[number($idx)]/input:Data"/>
                <xsl:with-param name="style_prefix" select="$style"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="datatype">
          <xsl:choose>
            <xsl:when test="$is_header">S</xsl:when>
            <xsl:otherwise><xsl:value-of select="$metarow_field_types/input:Cell[$idx]/input:Data/text()"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="draw_cell">
          <xsl:with-param name="text" select="$datarow/input:Cell[$idx]/input:Data/text()"/>
          <xsl:with-param name="style" select="$cellstyle"/>
          <xsl:with-param name="datatype" select="$datatype"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>

  <!-- loop through the datarow's input fields-->
  <xsl:if test="$node/@display-input-fields='yes'">       <!-- display the input fields only the customizing allows it -->
    <xsl:for-each select="$metarow_field_ids/input:Cell[position()>$offset]">
      <xsl:variable name="field_name" select="."/>
      <xsl:variable name="idx" select="position()+$offset"/>
      <xsl:if test="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'">
        <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
        <xsl:choose>
          <xsl:when test="count($field_conf) = 0 or $field_conf/@display='yes'"><!-- no customizing exists, display the field -->

            <xsl:variable name="cellstyle">
              <xsl:choose>
                <xsl:when test="$is_header"><xsl:value-of select="$headerstyle"/></xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="get_cell_style">
                    <xsl:with-param name="datatype" select="$metarow_field_types/input:Cell[number($idx)]/input:Data"/>
                    <xsl:with-param name="style_prefix" select="$style"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="datatype">
              <xsl:choose>
                <xsl:when test="$is_header">S</xsl:when>
                <xsl:otherwise><xsl:value-of select="$metarow_field_types/input:Cell[$idx]/input:Data/text()"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:call-template name="draw_cell">
              <xsl:with-param name="text" select="$datarow/input:Cell[$idx]/input:Data/text()"/>
              <xsl:with-param name="style" select="$cellstyle"/>
              <xsl:with-param name="datatype" select="$datatype"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$field_conf/@display='no'">
            <!-- do not display the field -->
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:if>

  <xsl:call-template name="close_row"/> <!-- close the row -->
</xsl:template>

<!-- .............................................................................................. -->
<!-- .............................................................................................. -->
<!--                                 RENDERER TEMPLATES                                             -->
<!-- .............................................................................................. -->
<!-- .............................................................................................. -->


<!-- .............................................................................................. -->
<!-- Util template:
     Heading
       - text: text to be displayed as a Heading.
       - level: depth of the heading text in a hierarchy
    -->
<!-- .............................................................................................. -->
<xsl:template name="heading">
  <xsl:param name="text"/>
  <xsl:param name="level"/>

  <xsl:variable name="style">
    <xsl:choose>
      <xsl:when test="$level=1">h1</xsl:when>
      <xsl:when test="$level=2">h2</xsl:when>
      <xsl:when test="$level=3">h3</xsl:when>
      <xsl:otherwise>h4</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
      <xsl:value-of select="$text"/>
      <xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:call-template name="open_row"/>
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="style" select="$style"/>
      </xsl:call-template>
      <xsl:call-template name="close_row"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- .............................................................................................. -->
<!-- Util template:
     Heading3
       - text: text to be displayed as a Heading.
       - rows: rows gives the number of columns with border
    -->
<!-- .............................................................................................. -->
<xsl:template name="heading3_bd">
  <xsl:param name="text"/>
  <xsl:param name="rows"/>

  <xsl:call-template name="open_row"/>
  <xsl:call-template name="draw_cell">
    <xsl:with-param name="text" select="$text"/>
    <xsl:with-param name="style" select="'h3'"/>
  </xsl:call-template>
  <xsl:for-each select="$rows[position()>3]">
    <xsl:call-template name="draw_cell">
      <xsl:with-param name="text" select="''"/>
      <xsl:with-param name="style" select="'s31s'"/>
    </xsl:call-template>
  </xsl:for-each>
  <xsl:call-template name="close_row"/>

</xsl:template>


<!-- .............................................................................................. -->
<!-- Util template:
     empty_row
       - text: text to be displayed as a Heading.
     It simply inserts an empty row before and after the heading.
    -->
<!-- .............................................................................................. -->
<xsl:template name="empty_row_raw">

 <xsl:choose>
   <xsl:when test="$OUTPUT = 'html'"/>  <!-- in html we use <br/> only afer tables -->
   <xsl:otherwise>    <!-- default is excel -->
      <xsl:call-template name="open_row"/>
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="''"/>
    <!--      <xsl:with-param name="style" select="'s22'"/>-->
      </xsl:call-template>
      <xsl:call-template name="close_row"/>
    </xsl:otherwise>
  </xsl:choose>



</xsl:template>

<!-- .............................................................................................. -->
<!-- Util template:
     empty_row
     It simply inserts an empty row before and after the heading with bordered columns
    -->
<!-- .............................................................................................. -->
<xsl:template name="empty_row_raw_bd">
  <xsl:param name="rows"/>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'"/>  <!-- in html we use <br/> only afer tables -->
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:call-template name="open_row"/>
      <xsl:call-template name="draw_cell">
        <xsl:with-param name="text" select="''"/>
      </xsl:call-template>
      <xsl:for-each select="$rows[position()>3]">
        <xsl:call-template name="draw_cell">
          <xsl:with-param name="text" select="''"/>
          <xsl:with-param name="style" select="'s31s'"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:call-template name="close_row"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- .............................................................................................. -->
<!-- Util template:
     draw a cell and replace all new line character with &#10;
    -->
<!-- .............................................................................................. -->
<!--<xsl:template name="draw_cell">
  <xsl:param name="text"/>
  <xsl:param name="style"></xsl:param>
  <xsl:param name="colspan"></xsl:param>
  <xsl:param name="datatype">S</xsl:param>

  <xsl:variable name="value">
    <xsl:call-template name="string-replace-all">
      <xsl:with-param name="text" select="$text" />
      <xsl:with-param name="replace" select="'&#10;'" />
      <xsl:with-param name="by" select="'&amp;#10;'" />
    </xsl:call-template>
  </xsl:variable>-->

  <!-- Build the Cell tag's attributes -->
  <!--<xsl:variable name="cell_attributes">
    <xsl:if test="string-length($style) > 0">
      <xsl:text> ss:StyleID=&quot;</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text>&quot;</xsl:text>
    </xsl:if>
    <xsl:if test="string-length($colspan) > 0">
      <xsl:text> ss:MergeAcross=&quot;</xsl:text>
      <xsl:value-of select="$colspan"/>
      <xsl:text>&quot;</xsl:text>
    </xsl:if>
  </xsl:variable>-->

  <!-- Display the cell with it's content -->
  <!--<xsl:text disable-output-escaping="yes">&lt;Cell</xsl:text>
  <xsl:value-of select="$cell_attributes"/>
  <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
  <Data ss:Type="String"><xsl:value-of  disable-output-escaping="yes" select="$value"/></Data>
  <xsl:text disable-output-escaping="yes">&lt;/Cell&gt;</xsl:text>
</xsl:template>-->

<!-- .............................................................................................. -->
<!-- Template:  open_document -->
<!-- .............................................................................................. -->
<xsl:template name="open_document">
  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes">&lt;html&gt;</xsl:text>
      <head>
        <xsl:text disable-output-escaping="yes">&lt;meta http-equiv="Content-Type" content="text/html;charset=UTF-8"&gt;</xsl:text>
        <xsl:call-template name="styles_for_html"/>
      </head>
      <xsl:text disable-output-escaping="yes">&lt;body&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:processing-instruction name="mso-application">
        <xsl:text>progid="Excel.Sheet"</xsl:text>
      </xsl:processing-instruction>

      <xsl:text disable-output-escaping="yes">&lt;Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
        xmlns:o="urn:schemas-microsoft-com:office:office"
        xmlns:x="urn:schemas-microsoft-com:office:excel"
        xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
        xmlns:html="http://www.w3.org/TR/REC-html40"&gt;</xsl:text>

        <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
          <ProtectStructure>False</ProtectStructure>
          <ProtectWindows>False</ProtectWindows>
        </ExcelWorkbook>

         <!-- Generate Style information -->
        <xsl:call-template name="z_styles_for_excel">
          <xsl:with-param name="date_format"   select="rcp:pattern('excel', 'D', $date_pattern_id)"/>
          <xsl:with-param name="time_format"   select="rcp:pattern('excel', 'T', $time_pattern_id)"/>
          <xsl:with-param name="number_format" select="rcp:pattern('excel', 'N', $number_pattern_id)"/>
          <xsl:with-param name="int_format"    select="rcp:pattern('excel', 'I', $number_pattern_id)"/>
        </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  z_styles_for_excel
     Local copy of the standard style set plus grey-fill styles for locked/reference columns.
     -->
<!-- .............................................................................................. -->
<xsl:template name="z_styles_for_excel">
  <xsl:param name="date_format"/>
  <xsl:param name="time_format"/>
  <xsl:param name="number_format"/>
  <xsl:param name="int_format"/>

  <Styles>
    <Style ss:ID="Default" ss:Name="Normal">
      <Alignment ss:Vertical="Bottom"/>
      <Borders/>
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="11" ss:Color="#000000"/>
      <Interior/>
      <NumberFormat/>
      <Protection/>
    </Style>
    <Style ss:ID="string">
      <NumberFormat ss:Format="@"/>
    </Style>
    <Style ss:ID="integer">
      <NumberFormat ss:Format="{$int_format}"/>
    </Style>
    <Style ss:ID="number">
      <NumberFormat ss:Format="{$number_format}"/>
    </Style>
    <Style ss:ID="date">
      <NumberFormat ss:Format="{$date_format}"/>
    </Style>
    <Style ss:ID="time">
      <NumberFormat ss:Format="{$time_format}"/>
    </Style>
    <Style ss:ID="h1">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="18" ss:Color="#000000" ss:Bold="1" ss:Underline="Single"/>
    </Style>
    <Style ss:ID="h2">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="16" ss:Color="#000000" ss:Bold="1"/>
    </Style>
    <Style ss:ID="h3">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="14" ss:Color="#000000" ss:Bold="1" ss:Underline="Single"/>
    </Style>
    <Style ss:ID="h4">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
    </Style>
    <Style ss:ID="s30s" ss:Parent="string">
      <Alignment ss:WrapText="1"/>
    </Style>
    <Style ss:ID="s30i" ss:Parent="integer"/>
    <Style ss:ID="s30n" ss:Parent="number"/>
    <Style ss:ID="s30d" ss:Parent="date"/>
    <Style ss:ID="s30t" ss:Parent="time"/>
    <Style ss:ID="s31s" ss:Parent="string">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s31i" ss:Parent="integer">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s31n" ss:Parent="number">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s31d" ss:Parent="date">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s31t" ss:Parent="time">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s32s" ss:Parent="string">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s32i" ss:Parent="integer">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s32n" ss:Parent="number">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s32d" ss:Parent="date">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s32t" ss:Parent="time">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s33s" ss:Parent="string">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s33i" ss:Parent="integer">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s33n" ss:Parent="number">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s33d" ss:Parent="date">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s33t" ss:Parent="time">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s34s" ss:Parent="string">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s34i" ss:Parent="integer">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s34n" ss:Parent="number">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s34d" ss:Parent="date">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s34t" ss:Parent="time">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s35s" ss:Parent="string">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s35i" ss:Parent="integer">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s35n" ss:Parent="number">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s35d" ss:Parent="date">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s35t" ss:Parent="time">
      <Alignment ss:WrapText="1"/>
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Dash" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="s36s" ss:Parent="string">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s36i" ss:Parent="integer">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s36n" ss:Parent="number">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s36d" ss:Parent="date">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s36t" ss:Parent="time">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="s60">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="12" ss:Color="#000000"/>
      <Interior/>
    </Style>
    <Style ss:ID="th10">
      <Font ss:FontName="Calibri" CharSet="238" Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
    </Style>
    <Style ss:ID="th11" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="th12" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="th13" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="th14" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
      </Borders>
    </Style>
    <Style ss:ID="th15" ss:Parent="th14">
      <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
    </Style>
    <Style ss:ID="th16" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="th17" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="th18" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
      </Borders>
    </Style>
    <Style ss:ID="zgrey" ss:Parent="string">
      <Alignment ss:WrapText="1"/>
      <Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
    </Style>
    <Style ss:ID="zgreyh" ss:Parent="th10">
      <Borders>
        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
      </Borders>
      <Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
    </Style>
    <Style ss:ID="zhidden" ss:Parent="string"/>
  </Styles>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_document -->
<!-- .............................................................................................. -->
<xsl:template name="close_document">
  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;/body&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;/Workbook&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  open_page
       - title  :  the title of the page
     -->
<!-- .............................................................................................. -->
<xsl:template name="open_page">
  <xsl:param name="title"/>
  <xsl:param name="column_profile" select="'Data'"/>
  <xsl:param name="rows"/>
  <xsl:param name="hidden_dropdown_col_count" select="0"/>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;Worksheet ss:Name=&quot;</xsl:text>
      <xsl:value-of select="$title"/>
      <xsl:text disable-output-escaping="yes">&quot;&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes">&lt;Table&gt;</xsl:text>
      <xsl:choose>
        <xsl:when test="$column_profile = 'Groups'">
          <xsl:call-template name="group_sheet_columns">
            <xsl:with-param name="rows" select="$rows"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="data_sheet_columns">
            <xsl:with-param name="rows" select="$rows"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="hidden_dropdown_columns">
        <xsl:with-param name="count" select="$hidden_dropdown_col_count"/>
      </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  data_sheet_columns -->
<!-- .............................................................................................. -->
<xsl:template name="data_sheet_columns">
  <xsl:param name="rows"/>

  <xsl:call-template name="profile_columns">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="count" select="10"/>
    <xsl:with-param name="profile" select="'Data'"/>
  </xsl:call-template>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  group_sheet_columns -->
<!-- .............................................................................................. -->
<xsl:template name="group_sheet_columns">
  <xsl:param name="rows"/>

  <xsl:call-template name="profile_columns">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="count" select="8"/>
    <xsl:with-param name="profile" select="'Groups'"/>
  </xsl:call-template>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  profile_columns -->
<!-- .............................................................................................. -->
<xsl:template name="profile_columns">
  <xsl:param name="rows"/>
  <xsl:param name="count"/>
  <xsl:param name="profile"/>
  <xsl:param name="col_idx" select="1"/>

  <xsl:if test="$col_idx &lt;= $count">
    <xsl:call-template name="profile_column">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="col_idx" select="$col_idx"/>
      <xsl:with-param name="profile" select="$profile"/>
    </xsl:call-template>
    <xsl:call-template name="profile_columns">
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="count" select="$count"/>
      <xsl:with-param name="profile" select="$profile"/>
      <xsl:with-param name="col_idx" select="$col_idx + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  profile_column -->
<!-- .............................................................................................. -->
<xsl:template name="profile_column">
  <xsl:param name="rows"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="profile"/>
  <xsl:param name="min_width" select="50"/>
  <xsl:param name="max_width" select="300"/>
  <xsl:param name="width_factor" select="7"/>
  <xsl:param name="padding" select="2"/>

  <xsl:variable name="max_len">
    <xsl:choose>
      <xsl:when test="$profile = 'Groups'">
        <xsl:call-template name="group_column_max_length">
          <xsl:with-param name="rows" select="$rows"/>
          <xsl:with-param name="col_idx" select="$col_idx"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="data_column_max_length">
          <xsl:with-param name="rows" select="$rows"/>
          <xsl:with-param name="col_idx" select="$col_idx"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="calculated_width" select="number($max_len) * $width_factor + $padding"/>
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="$calculated_width &lt; $min_width"><xsl:value-of select="$min_width"/></xsl:when>
      <xsl:when test="$calculated_width &gt; $max_width"><xsl:value-of select="$max_width"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="format-number($calculated_width, '0')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <Column ss:AutoFitWidth="0" ss:Width="{$width}"/>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  data_column_max_length -->
<!-- .............................................................................................. -->
<xsl:template name="data_column_max_length">
  <xsl:param name="rows"/>
  <xsl:param name="col_idx"/>

  <xsl:variable name="header">
    <xsl:call-template name="data_column_header">
      <xsl:with-param name="col_idx" select="$col_idx"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="properties" select="$rows/input:Cell[$g_prop_idx]/input:Data/text()[generate-id()=generate-id(key('properties',.)[1])]"/>

  <xsl:call-template name="data_column_max_length_properties">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="properties" select="$properties"/>
    <xsl:with-param name="col_idx" select="$col_idx"/>
    <xsl:with-param name="max_len" select="string-length($header)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="data_column_header">
  <xsl:param name="col_idx"/>

  <xsl:choose>
    <xsl:when test="$col_idx = 1">Property Tree</xsl:when>
    <xsl:when test="$col_idx = 2">Prop tree type</xsl:when>
    <xsl:when test="$col_idx = 3">PT node</xsl:when>
    <xsl:when test="$col_idx = 4">VAT</xsl:when>
    <xsl:when test="$col_idx = 5">VAT ID</xsl:when>
    <xsl:when test="$col_idx = 6">Instance</xsl:when>
    <xsl:when test="$col_idx = 7">Attribute</xsl:when>
    <xsl:when test="$col_idx = 8">Additional Information</xsl:when>
    <xsl:when test="$col_idx = 9">Characteristic Name</xsl:when>
    <xsl:otherwise>Characteristic Value</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="data_column_max_length_properties">
  <xsl:param name="rows"/>
  <xsl:param name="properties"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="max_len"/>

  <xsl:choose>
    <xsl:when test="count($properties) = 0">
      <xsl:value-of select="$max_len"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="prop" select="$properties[1]"/>
      <xsl:variable name="property_max_len">
        <xsl:call-template name="data_column_max_length_nodes">
          <xsl:with-param name="rows" select="$rows[input:Cell[$g_prop_idx]/input:Data[.=$prop]]"/>
          <xsl:with-param name="nodes" select="$property_meta/node"/>
          <xsl:with-param name="col_idx" select="$col_idx"/>
          <xsl:with-param name="max_len" select="$max_len"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="data_column_max_length_properties">
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="properties" select="$properties[position() &gt; 1]"/>
        <xsl:with-param name="col_idx" select="$col_idx"/>
        <xsl:with-param name="max_len" select="number($property_max_len)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="data_column_max_length_nodes">
  <xsl:param name="rows"/>
  <xsl:param name="nodes"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="max_len"/>

  <xsl:choose>
    <xsl:when test="count($nodes) = 0">
      <xsl:value-of select="$max_len"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node" select="$nodes[1]"/>
      <xsl:variable name="node_id" select="$node/@id"/>
      <xsl:variable name="node_rows" select="$rows[input:Cell[$g_prop_node_idx]/input:Data=$node_id]"/>
      <xsl:variable name="node_max_len">
        <xsl:call-template name="data_column_max_length_datarows">
          <xsl:with-param name="datarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='TABLEDATA']]]"/>
          <xsl:with-param name="metarows" select="$node_rows[input:Cell[$g_prop_mt_flag_idx][input:Data[.='METADATA']]]"/>
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="col_idx" select="$col_idx"/>
          <xsl:with-param name="max_len" select="$max_len"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="data_column_max_length_nodes">
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
        <xsl:with-param name="col_idx" select="$col_idx"/>
        <xsl:with-param name="max_len" select="number($node_max_len)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="data_column_max_length_datarows">
  <xsl:param name="datarows"/>
  <xsl:param name="metarows"/>
  <xsl:param name="node"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="max_len"/>

  <xsl:choose>
    <xsl:when test="count($datarows) = 0">
      <xsl:value-of select="$max_len"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="datarow" select="$datarows[1]"/>
      <xsl:variable name="flat_vat_id" select="normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data)"/>
      <xsl:variable name="flat_vat_desc" select="normalize-space($datarow/input:Cell[$g_prop_desc_idx]/input:Data)"/>
      <xsl:variable name="hide_group_vat_row" select="
        $flat_vat_id='SAP_RMS_1012_005'
        or $flat_vat_id='SAP_RMS_1012_010'
        or $flat_vat_id='SAP_RMS_1012_021'
        or $flat_vat_id='SAP_RMS_1012_022'
        or $flat_vat_id='SAP_RMS_1012_025'
        or $flat_vat_id='SAP_EHS_1012_003'
        or $flat_vat_desc='Standard Composition'
        or $flat_vat_desc='Allergens'
        or $flat_vat_desc='Nutrient Composition'
        or $flat_vat_desc='Diet Suitability'
        or $flat_vat_desc='Religious Certificate Compliance'
        or $flat_vat_desc='Genetically Modified Ingredients'"/>
      <xsl:variable name="row_max_len">
        <xsl:choose>
          <xsl:when test="$hide_group_vat_row">
            <xsl:value-of select="$max_len"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="data_column_max_length_fields">
              <xsl:with-param name="fields" select="$metarows[1]/input:Cell[position() &gt; $g_prop_specid_idx]/input:Data"/>
              <xsl:with-param name="metarows" select="$metarows"/>
              <xsl:with-param name="node" select="$node"/>
              <xsl:with-param name="datarow" select="$datarow"/>
              <xsl:with-param name="col_idx" select="$col_idx"/>
              <xsl:with-param name="max_len" select="$max_len"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="data_column_max_length_datarows">
        <xsl:with-param name="datarows" select="$datarows[position() &gt; 1]"/>
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="col_idx" select="$col_idx"/>
        <xsl:with-param name="max_len" select="number($row_max_len)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="data_column_max_length_fields">
  <xsl:param name="fields"/>
  <xsl:param name="metarows"/>
  <xsl:param name="node"/>
  <xsl:param name="datarow"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="max_len"/>

  <xsl:choose>
    <xsl:when test="count($fields) = 0">
      <xsl:value-of select="$max_len"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="field_name" select="$fields[1]"/>
      <xsl:variable name="idx" select="count($fields[1]/parent::input:Cell/preceding-sibling::input:Cell) + 1"/>
      <xsl:variable name="field_conf" select="$node/field[.=$field_name][1]"/>
      <xsl:variable name="is_visible_field"
        select="$metarows[3]/input:Cell[$idx]/input:Data = 'BF'
                and not($field_conf/@display='no')
                and not(starts-with(normalize-space($field_name), '__'))"/>
      <xsl:variable name="field_max_len">
        <xsl:choose>
          <xsl:when test="$is_visible_field">
            <xsl:call-template name="max_value_length">
              <xsl:with-param name="max_len" select="$max_len"/>
              <xsl:with-param name="value">
                <xsl:call-template name="data_column_output_value">
                  <xsl:with-param name="datarow" select="$datarow"/>
                  <xsl:with-param name="metarows" select="$metarows"/>
                  <xsl:with-param name="source_col_idx" select="$idx"/>
                  <xsl:with-param name="output_col_idx" select="$col_idx"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="$max_len"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="data_column_max_length_fields">
        <xsl:with-param name="fields" select="$fields[position() &gt; 1]"/>
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="datarow" select="$datarow"/>
        <xsl:with-param name="col_idx" select="$col_idx"/>
        <xsl:with-param name="max_len" select="number($field_max_len)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="data_column_output_value">
  <xsl:param name="datarow"/>
  <xsl:param name="metarows"/>
  <xsl:param name="source_col_idx"/>
  <xsl:param name="output_col_idx"/>

  <xsl:variable name="additional_info_row" select="$metarows[
    normalize-space(input:Cell[$g_prop_specid_idx]/input:Data)='Additional Information'
    or normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='5'
  ][1]"/>
  <xsl:variable name="additional_info_raw" select="$additional_info_row/input:Cell[$source_col_idx]/input:Data"/>
  <xsl:variable name="allowed_values_separator" select="'||ALLOWED_VALUES||'"/>
  <xsl:variable name="allowed_values" select="substring-after($additional_info_raw, $allowed_values_separator)"/>
  <xsl:variable name="characteristic_name_raw" select="normalize-space($metarows[1]/input:Cell[$source_col_idx]/input:Data)"/>

  <xsl:choose>
    <xsl:when test="$output_col_idx = 1"><xsl:value-of select="$datarow/input:Cell[$g_prop_desc_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 2"><xsl:value-of select="$datarow/input:Cell[$g_prop_node_desc_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 3"><xsl:value-of select="$datarow/input:Cell[$g_prop_vac_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 4"><xsl:value-of select="$datarow/input:Cell[$g_prop_desc_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 5"><xsl:value-of select="$datarow/input:Cell[$g_prop_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 6">
      <xsl:call-template name="p_get_field_value">
        <xsl:with-param name="metarows" select="$metarows"/>
        <xsl:with-param name="datarow" select="$datarow"/>
        <xsl:with-param name="field_name" select="'META_INSTANCE'"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$output_col_idx = 7"><xsl:value-of select="$metarows[2]/input:Cell[$source_col_idx]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 8">
      <xsl:choose>
        <xsl:when test="contains($additional_info_raw, $allowed_values_separator)">
          <xsl:value-of select="substring-before($additional_info_raw, $allowed_values_separator)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$additional_info_raw"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$output_col_idx = 9">
      <xsl:choose>
        <xsl:when test="starts-with($characteristic_name_raw, '__FTEXT_') or starts-with($characteristic_name_raw, '_FTEXT_')">
          <xsl:value-of select="concat(normalize-space($datarow/input:Cell[$g_prop_idx]/input:Data), '_001')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$characteristic_name_raw"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="contains($allowed_values, '||ALLOWED_VALUE||')">
          <xsl:value-of select="substring-before($allowed_values, '||ALLOWED_VALUE||')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$allowed_values"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  group_column_max_length -->
<!-- .............................................................................................. -->
<xsl:template name="group_column_max_length">
  <xsl:param name="rows"/>
  <xsl:param name="col_idx"/>

  <xsl:variable name="header">
    <xsl:call-template name="group_column_header">
      <xsl:with-param name="col_idx" select="$col_idx"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="group_column_max_length_rows">
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="col_idx" select="$col_idx"/>
    <xsl:with-param name="max_len" select="string-length($header)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="group_column_header">
  <xsl:param name="col_idx"/>

  <xsl:choose>
    <xsl:when test="$col_idx = 1">VAT Description</xsl:when>
    <xsl:when test="$col_idx = 2">Identifier</xsl:when>
    <xsl:when test="$col_idx = 3">VAT ID</xsl:when>
    <xsl:when test="$col_idx = 4">SpecID</xsl:when>
    <xsl:when test="$col_idx = 5">Target Value</xsl:when>
    <xsl:when test="$col_idx = 6">Amount (Allergen)</xsl:when>
    <xsl:when test="$col_idx = 7">Amount UoM(PPM)</xsl:when>
    <xsl:otherwise>UoM</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="group_column_max_length_rows">
  <xsl:param name="rows"/>
  <xsl:param name="col_idx"/>
  <xsl:param name="max_len"/>

  <xsl:choose>
    <xsl:when test="count($rows) = 0">
      <xsl:value-of select="$max_len"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="source_row" select="$rows[1]"/>
      <xsl:variable name="metadata_row" select="$source_row/preceding-sibling::input:Row[input:Cell[$g_prop_mt_flag_idx]/input:Data='METADATA' and normalize-space(input:Cell[$g_prop_lnum_idx]/input:Data)='1'][1]"/>
      <xsl:variable name="subid_idx">
        <xsl:for-each select="$metadata_row/input:Cell">
          <xsl:if test="normalize-space(input:Data)='SUBID'">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="spec_id" select="normalize-space($source_row/input:Cell[number(normalize-space($subid_idx))]/input:Data)"/>
      <xsl:variable name="row_max_len">
        <xsl:choose>
          <xsl:when test="normalize-space($subid_idx) != '' and $spec_id != ''">
            <xsl:call-template name="max_value_length">
              <xsl:with-param name="max_len" select="$max_len"/>
              <xsl:with-param name="value">
                <xsl:call-template name="group_column_output_value">
                  <xsl:with-param name="source_row" select="$source_row"/>
                  <xsl:with-param name="metadata_row" select="$metadata_row"/>
                  <xsl:with-param name="spec_id" select="$spec_id"/>
                  <xsl:with-param name="output_col_idx" select="$col_idx"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="$max_len"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="group_column_max_length_rows">
        <xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
        <xsl:with-param name="col_idx" select="$col_idx"/>
        <xsl:with-param name="max_len" select="number($row_max_len)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="group_column_output_value">
  <xsl:param name="source_row"/>
  <xsl:param name="metadata_row"/>
  <xsl:param name="spec_id"/>
  <xsl:param name="output_col_idx"/>

  <xsl:variable name="ident1_idx">
    <xsl:for-each select="$metadata_row/input:Cell">
      <xsl:if test="normalize-space(input:Data)='IDENT1'">
        <xsl:value-of select="position()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$output_col_idx = 1"><xsl:value-of select="$source_row/input:Cell[2]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 2"><xsl:value-of select="$source_row/input:Cell[number(normalize-space($ident1_idx))]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 3"><xsl:value-of select="$source_row/input:Cell[1]/input:Data"/></xsl:when>
    <xsl:when test="$output_col_idx = 4"><xsl:value-of select="$spec_id"/></xsl:when>
    <xsl:when test="$output_col_idx = 8 and normalize-space($source_row/input:Cell[1]/input:Data)='SAP_RMS_1012_005'">
      <xsl:value-of select="$source_row/input:Cell[
        position() = count($metadata_row/input:Cell[
          normalize-space(input:Data)='COMPEXP_STEXT'][1]/preceding-sibling::input:Cell) + 1
        and $metadata_row/input:Cell[normalize-space(input:Data)='COMPEXP_STEXT']
      ]/input:Data"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template name="max_value_length">
  <xsl:param name="max_len"/>
  <xsl:param name="value"/>

  <xsl:variable name="value_len" select="string-length(normalize-space($value))"/>
  <xsl:choose>
    <xsl:when test="$value_len &gt; $max_len"><xsl:value-of select="$value_len"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$max_len"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  hidden_dropdown_columns -->
<!-- .............................................................................................. -->
<xsl:template name="hidden_dropdown_columns">
  <xsl:param name="count"/>

  <xsl:if test="$count &gt; 0">
    <Column ss:AutoFitWidth="0" ss:Hidden="1" ss:Width="0"/>
    <xsl:call-template name="hidden_dropdown_columns">
      <xsl:with-param name="count" select="$count - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_page -->
<!-- .............................................................................................. -->
<xsl:template name="close_page">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;/Table&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes">&lt;/Worksheet&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  close_data_page -->
<!-- .............................................................................................. -->
<xsl:template name="close_data_page">
  <xsl:param name="rows"/>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;/Table&gt;</xsl:text>
      <xsl:if test="$ENABLE_DROPDOWN_VALIDATION = 'X' or $ENABLE_DROPDOWN_VALIDATION = 'x' or $ENABLE_DROPDOWN_VALIDATION = 'TRUE' or $ENABLE_DROPDOWN_VALIDATION = 'true'">
        <xsl:call-template name="p_flat_property_dropdown_validations">
          <xsl:with-param name="rows" select="$rows"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:text disable-output-escaping="yes">&lt;/Worksheet&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  open_table -->
<!-- .............................................................................................. -->
<xsl:template name="open_table">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;table&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_table -->
<!-- .............................................................................................. -->
<xsl:template name="close_table">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;/table&gt;&lt;br/&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  open_table_header -->
<!-- .............................................................................................. -->
<xsl:template name="open_table_header">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;thead&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_table_header -->
<!-- .............................................................................................. -->
<xsl:template name="close_table_header">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;/thead&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  open_table_body -->
<!-- .............................................................................................. -->
<xsl:template name="open_table_body">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;tbody&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_table_body -->
<!-- .............................................................................................. -->
<xsl:template name="close_table_body">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;/tbody&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise/>    <!-- default is excel -->
  </xsl:choose>
</xsl:template>

<!-- .............................................................................................. -->
<!-- Template:  open_row -->
<!-- .............................................................................................. -->
<xsl:template name="open_row">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;tr&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;Row xmlns="urn:schemas-microsoft-com:office:spreadsheet" ss:AutoFitHeight="1"&gt;</xsl:text>  <!--N2650797 long txt  &lt;Row&gt  -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- .............................................................................................. -->
<!-- Template:  close_row -->
<!-- .............................................................................................. -->
<xsl:template name="close_row">
 <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:text disable-output-escaping="yes">&lt;/tr&gt;</xsl:text>
    </xsl:when>
    <xsl:otherwise>    <!-- default is excel -->
      <xsl:text disable-output-escaping="yes">&lt;/Row&gt;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ************************************************************************************************-->
<!-- Template:  add_cell -->
<!-- ************************************************************************************************-->
<xsl:template name="draw_cell">
  <xsl:param name="style">s30s</xsl:param>
  <xsl:param name="datatype">S</xsl:param>
  <xsl:param name="text"/>
  <xsl:param name="colspan">0</xsl:param>
  <xsl:param name="font_color"/>

  <xsl:variable name="value">
    <xsl:call-template name="format_data">
      <xsl:with-param name="datatype" select="$datatype"/>
      <xsl:with-param name="data" select="$text"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="formatted_data">
    <xsl:call-template name="string-replace-all">
      <xsl:with-param name="text" select="$value" />
      <xsl:with-param name="replace" select="'&#10;'" />
      <xsl:with-param name="by" select="'&amp;#10;'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:choose>
        <xsl:when test="string-length($formatted_data) = 0 and $colspan = 0">
          <td class="{$style}">
            <xsl:if test="string-length($font_color) > 0"><xsl:attribute name="style">color:<xsl:value-of select="$font_color"/></xsl:attribute></xsl:if>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
          </td>
        </xsl:when>
        <xsl:when test="string-length($formatted_data) = 0 and $colspan != 0">
          <td class="{$style}" colspan="{$colspan}">
            <xsl:if test="string-length($font_color) > 0"><xsl:attribute name="style">color:<xsl:value-of select="$font_color"/></xsl:attribute></xsl:if>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
          </td>
        </xsl:when>
        <xsl:when test="$colspan = 0">
          <td class="{$style}">
            <xsl:if test="string-length($font_color) > 0"><xsl:attribute name="style">color:<xsl:value-of select="$font_color"/></xsl:attribute></xsl:if>
            <xsl:value-of disable-output-escaping="yes" select="$formatted_data"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="num_of_columns" select="$colspan+1"/>
          <td class="{$style}" colspan="{$num_of_columns}">
            <xsl:if test="string-length($font_color) > 0"><xsl:attribute name="style">color:<xsl:value-of select="$font_color"/></xsl:attribute></xsl:if>
            <xsl:value-of disable-output-escaping="yes" select="$formatted_data"/>
          </td>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>    <!-- default is excel -->
      <xsl:variable name="celltype">
        <xsl:call-template name="convert_datatype_for_excel">
          <xsl:with-param name="datatype" select="$datatype"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="across" select="$colspan"/>

      <xsl:choose>
        <xsl:when test="string-length($formatted_data) = 0 and $across = 0"> <!-- empty cell -->
          <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet" ss:StyleID="{$style}"/> <!-- N2650797 long txt format excel -->
        </xsl:when>
        <xsl:when test="string-length($formatted_data) = 0 and $across != 0"> <!-- empty merged cell -->
          <Cell ss:MergeAcross="{$across}" ss:StyleID="{$style}"/>
        </xsl:when>
        <xsl:when test="$across = 0"> <!-- not empty cell -->
          <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet" ss:StyleID="{$style}">   <!-- N2650797 long txt format excel -->
            <ss:Data xmlns="http://www.w3.org/TR/REC-html40" ss:Type="{$celltype}">
              <xsl:choose>
                <xsl:when test="string-length($font_color) > 0">
                  <html:Font html:Color="{$font_color}"><xsl:value-of disable-output-escaping="yes" select="$formatted_data"/></html:Font>
                </xsl:when>
                <xsl:otherwise><xsl:value-of disable-output-escaping="yes" select="$formatted_data"/></xsl:otherwise>
              </xsl:choose>
            </ss:Data>  <!-- N2650797 long txt format excel -->
          </Cell>
        </xsl:when>
        <xsl:otherwise> <!-- not empty merged cell -->
          <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet" ss:MergeAcross="{$across}" ss:StyleID="{$style}"> <!-- N2650797 long txt format excel -->
            <ss:Data xmlns="http://www.w3.org/TR/REC-html40" ss:Type="{$celltype}">
              <xsl:choose>
                <xsl:when test="string-length($font_color) > 0">
                  <html:Font html:Color="{$font_color}"><xsl:value-of disable-output-escaping="yes" select="$formatted_data"/></html:Font>
                </xsl:when>
                <xsl:otherwise><xsl:value-of disable-output-escaping="yes" select="$formatted_data"/></xsl:otherwise>
              </xsl:choose>
            </ss:Data> <!-- N2650797 long txt format excel -->
          </Cell>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="convert_datatype_for_excel">
  <xsl:param name="datatype"/>
  <xsl:choose>
    <xsl:when test="$datatype = 'I'">Number</xsl:when>  <!-- Integer -->
    <xsl:when test="$datatype = 'N'">Number</xsl:when>  <!-- Number -->
    <xsl:when test="$datatype = 'D'">DateTime</xsl:when>  <!-- Date -->
    <xsl:when test="$datatype = 'T'">DateTime</xsl:when>  <!-- Time -->
    <xsl:otherwise>String</xsl:otherwise>  <!-- handled as 'S' (String) -->
 </xsl:choose>
</xsl:template>

<xsl:template name="format_data">
  <xsl:param name="datatype">S</xsl:param>
  <xsl:param name="data"/>

  <xsl:variable name="pattern_id">
    <xsl:choose>
      <xsl:when test="$datatype = 'D'">
        <xsl:value-of select="$date_pattern_id"/>
      </xsl:when>
      <xsl:when test="$datatype = 'T'">
        <xsl:value-of select="$time_pattern_id"/>
      </xsl:when>
      <xsl:when test="$datatype = 'N' or $datatype = 'I'">
        <xsl:value-of select="$number_pattern_id"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$OUTPUT = 'html'">
      <xsl:value-of select="rcp:format('html', string($data), string($datatype), string($pattern_id))"/>
    </xsl:when>
    <xsl:when test="$OUTPUT = 'excel'">
      <xsl:choose>
        <xsl:when test="$datatype = 'S' and contains($data,'&lt;strong&gt;') or contains($data,'&lt;em&gt;')
                        or contains($data,'&lt;h1&gt;') or contains($data,'&lt;h2&gt;') or contains($data,'&lt;blockqoute&gt;') or contains($data,'&lt;p&gt;') "> <!--N2650797 long txt format   1.$field!='' and $field/@html_snippet='yes  -->
          <xsl:value-of select="rcp:format('excel', string($data), 'S', 'H')"/>
        </xsl:when>                                                                                                                                               <!-- /N2650797 long txt format -->
        <xsl:when test="$datatype = 'S'">
          <xsl:value-of select="rcp:format('excel', string($data), 'S', '')"/>
        </xsl:when>
        <!-- excel cannot handle dates before 1900 -->
        <xsl:when test="$datatype = 'D' and string-length($data) != 0 and number(substring($data, 1, 4)) &lt; 1900"/>
        <xsl:otherwise>
          <xsl:value-of select="$data"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$data"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
<!-- Template [End] -->
