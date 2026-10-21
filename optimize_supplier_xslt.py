from pathlib import Path
import re

p = Path('ZTR_SPC_EXP_MAIN_SU.xsl')
raw = p.read_bytes()
backup = Path('xslt-validation/original.xsl')
backup.parent.mkdir(exist_ok=True)
if backup.exists():
    raise SystemExit('Baseline exists; refusing to overwrite or reapply')
backup.write_bytes(raw)
s = raw.decode('latin1')
newline = '\r\n' if '\r\n' in s else '\n'
s = s.replace('\r\n', '\n')
anchor = '<!-- Root Template -->'
cache = '''<!-- Cache exact allowed-list counts once per source list. SAP already supports
     navigation of temporary trees here (as used for property_meta). -->
<xsl:key name="su_allowed_lists" match="input:Data[contains(., '||ALLOWED_VALUES||')]"
         use="substring-after(., '||ALLOWED_VALUES||')"/>
<xsl:variable name="su_allowed_counts">
  <xsl:for-each select="/input:Workbook/input:Worksheet/input:Table/input:Row/input:Cell/input:Data[contains(., '||ALLOWED_VALUES||')][generate-id() = generate-id(key('su_allowed_lists', substring-after(., '||ALLOWED_VALUES||'))[1])]">
    <su_list values="{substring-after(., '||ALLOWED_VALUES||')}">
      <xsl:call-template name="p_flat_property_unique_allowed_value_count">
        <xsl:with-param name="allowed_values" select="substring-after(., '||ALLOWED_VALUES||')"/>
        <xsl:with-param name="seen_values" select="''"/>
      </xsl:call-template>
    </su_list>
  </xsl:for-each>
</xsl:variable>

'''
s = s.replace(anchor, cache + anchor, 1)
start = s.index('<xsl:template name="p_flat_property_allowed_value_count">')
end = s.index('</xsl:template>', start) + len('</xsl:template>')
s = s[:start] + '''<xsl:template name="p_flat_property_allowed_value_count">
  <xsl:param name="allowed_values"/>
  <xsl:variable name="cached" select="$su_allowed_counts/su_list[@values = string($allowed_values)][1]"/>
  <xsl:choose>
    <xsl:when test="$cached"><xsl:value-of select="$cached"/></xsl:when>
    <xsl:otherwise>
      <!-- Preserve behavior for callers supplying a list absent from the source. -->
      <xsl:call-template name="p_flat_property_unique_allowed_value_count">
        <xsl:with-param name="allowed_values" select="$allowed_values"/>
        <xsl:with-param name="seen_values" select="''"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>''' + s[end:]
start = s.index('<xsl:template name="p_flat_property_output_row_count_datarows">')
end = s.index('</xsl:template>', start) + len('</xsl:template>')
old = s[start:end]
predicate = re.search(r'<xsl:variable name="hide_group_vat_row" select="(.*?)"/>', old, re.S).group(1)
predicate = predicate.replace('$flat_vat_id', 'normalize-space(input:Cell[$g_prop_idx]/input:Data)').replace('$flat_vat_desc', 'normalize-space(input:Cell[$g_prop_desc_idx]/input:Data)')
s = s[:start] + '''<xsl:template name="p_flat_property_output_row_count_datarows">
  <xsl:param name="datarows"/>
  <xsl:param name="field_count"/>
  <!-- Same visibility predicate; avoid recursive slicing and numeric accumulation. -->
  <xsl:value-of select="count($datarows[not(''' + predicate + ''')]) * number($field_count)"/>
</xsl:template>''' + s[end:]
p.write_bytes(s.replace('\n', newline).encode('latin1'))
print('Saved current baseline and applied two confined optimizations.')
