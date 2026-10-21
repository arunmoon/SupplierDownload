"""Check the SpreadsheetML list-source fix using the portable SAP stubs."""
import re
from compare import ROOT, E, compile_xsl, dropdown_fixture

source = ROOT / 'ZTR_SPC_EXP_MAIN_SU.xsl'
baseline = ROOT / 'xslt-validation/dropdown-before-fix.xsl'
fixed = compile_xsl(source)
baseline.write_bytes(source.read_bytes().replace(b'&lt;CellRangeList/&gt;', b'').replace(b"&lt;Value&gt;'</xsl:text>\r\n    <xsl:value-of select=\"$su_data_sheet_name\"/>\r\n    <xsl:text disable-output-escaping=\"yes\">'!R", b'&lt;Value&gt;=Data!R'))
try:
    before = compile_xsl(baseline)
    fixtures = [(name, E.parse(str(ROOT / name))) for name in ('cv_file.xml', 'working.xml', 'working_no_validation.xml', 'working_validation_value.xml')]
    fixtures.append(('dropdown-fixture.xml', dropdown_fixture()))
    total = 0
    ns = {'s': 'urn:schemas-microsoft-com:office:spreadsheet', 'x': 'urn:schemas-microsoft-com:office:excel'}
    for name, doc in fixtures:
        for enabled in ('X', ''):
            args = {'ENABLE_DROPDOWN_VALIDATION': E.XSLT.strparam(enabled)}
            old = bytes(before(doc, **args))
            new = bytes(fixed(doc, **args))
            expected = re.sub(rb'<UseBlank/><Value>=Data!(R[0-9]+C11:R[0-9]+C[0-9]+)</Value>', rb"<CellRangeList/><UseBlank/><Value>'PT Data'!\1</Value>", old)
            assert new == expected, (name, enabled, 'unexpected output change')
            tree = E.fromstring(new)
            validations = tree.findall('.//x:DataValidation', ns)
            if name == 'dropdown-fixture.xml' and enabled == 'X':
                assert len(validations) == 16
            for v in validations:
                assert [E.QName(c).localname for c in v] == ['Range', 'Type', 'CellRangeList', 'UseBlank', 'Value']
                assert not v.find('x:CellRangeList', ns).text
                ref = v.findtext('x:Value', namespaces=ns)
                match = re.fullmatch(r"'PT Data'!R([0-9]+)C11:R([0-9]+)C([0-9]+)", ref)
                assert match, ref
                row, endrow, endcol = map(int, match.groups())
                assert row == endrow
                assert v.findtext('x:Range', namespaces=ns) == f'R{row}C10'
                sheet = tree.find("s:Worksheet[@s:Name='PT Data']", ns)
                cells = sheet.find('s:Table', ns).findall('s:Row', ns)[row-1].findall('s:Cell', ns)
                assert len(cells) == endcol, (row, len(cells), endcol)
            total += len(validations)
            print(f'{name}, validation={enabled!r}: passed ({len(validations)} lists)')
    print(f'Passed: 10 transformations; {total} validation references checked. Excel/SAP runtime testing remains required.')
finally:
    baseline.unlink(missing_ok=True)
