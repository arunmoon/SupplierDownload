"""Portable differential check. SAP functions are stubs, not SAP/Excel certification."""
from pathlib import Path
import sys, re, json
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / '.xslt-validation-deps'))
from lxml import etree as E

ROOT = Path(__file__).resolve().parents[1]
X = 'http://www.w3.org/1999/XSL/Transform'
NS = {'xsl': X}
IN = 'urn:schemas-microsoft-com:office:spreadsheet'
RCP = E.FunctionNamespace('http://www.sap.com/recipe_development')
RCP['format'] = lambda ctx, output, data, datatype, pattern: str(data)
RCP['pattern'] = lambda ctx, *args: 'General'
RCP['pattern_desc'] = lambda ctx, *args: 'General'
E.XSLT.set_global_max_depth(30000)

def compile_xsl(path):
    data = path.read_bytes().decode('latin1')
    # Namespace declarations inherited by SAP repository includes are explicit here.
    data = data.replace('<xsl:stylesheet ', '<xsl:stylesheet xmlns:exsl="http://exslt.org/common" xmlns:x="urn:schemas-microsoft-com:office:excel" ', 1)
    root = E.fromstring(data.encode('latin1'))
    includes = {'ZTR_SPC_EXP_META_SU': 'ZTR_SPC_EXP_META_SU.xsl',
                '/PLMU/TR_SPC_EXP_STYLES': 'PLMUTR_SPC_EXP_STYLES..txt',
                '/PLMU/TR_SPC_EXP_UTIL': 'PLMUTR_SPC_EXP_UTIL.xml'}
    for inc in list(root.findall('xsl:include', NS)):
        name = inc.get('{http://www.sap.com/sapxsl}name')
        src = (ROOT / includes[name]).read_bytes().decode('latin1')
        if 'xmlns:x=' not in src:
            src = src.replace('<xsl:stylesheet ', '<xsl:stylesheet xmlns:x="urn:schemas-microsoft-com:office:excel" ', 1)
        dep = E.fromstring(src.encode('latin1'))
        pos = root.index(inc)
        root.remove(inc)
        for child in dep:
            root.insert(pos, child)
            pos += 1
    for node in list(root.findall('{http://www.sap.com/sapxsl}external-function')):
        root.remove(node)
    root.find('xsl:output', NS).set('method', 'xml')
    # SAP allows temporary-tree navigation; libxslt needs explicit node-set conversion.
    trees = {v.get('name') for v in root.xpath('//xsl:variable[not(@select)][*]', namespaces=NS)}
    for node in root.iter():
        for attr in ('select', 'test'):
            expr = node.get(attr)
            if expr:
                for name in sorted(trees, key=len, reverse=True):
                    expr = re.sub(r'\$' + re.escape(name) + r'(?=/)', 'exsl:node-set($' + name + ')', expr)
                node.set(attr, expr)
    return E.XSLT(root)

def signature(output):
    # Compare complete serialized output, including all DOE markup and whitespace.
    return bytes(output)

def dropdown_fixture():
    book = E.Element('{'+IN+'}Workbook', nsmap={None: IN})
    sheet = E.SubElement(book, '{'+IN+'}Worksheet')
    table = E.SubElement(sheet, '{'+IN+'}Table')
    def row(values):
        r = E.SubElement(table, '{'+IN+'}Row')
        for value in values:
            c = E.SubElement(r, '{'+IN+'}Cell')
            E.SubElement(c, '{'+IN+'}Data').text = value
    lists = ['', 'A|Alpha', 'A|Alpha||ALLOWED_VALUE||B|Beta',
             ' A|Alpha ||ALLOWED_VALUE||A|Alpha||ALLOWED_VALUE||B|Beta',
             '||ALLOWED_VALUE||B|Beta||ALLOWED_VALUE||',
             'A|Alpha||ALLOWED_VALUE||B|Beta']
    for i, values in enumerate(lists):
        prop = 'TEST_'+str(i)
        def prefix(kind, line):
            return [prop, 'Test property', 'A', 'INSTANCES', 'Instances', kind, str(line), '']
        row(prefix('METADATA', 1) + ['META_INSTANCE', 'TEST_FIELD', '__TECH'])
        row(prefix('METADATA', 2) + ['Instance', 'Test characteristic', 'Technical'])
        row(prefix('METADATA', 3) + ['BF', 'BF', 'BF'])
        row(prefix('METADATA', 4) + ['S', 'S', 'S'])
        row(prefix('METADATA', 5) + ['', 'Hint||ALLOWED_VALUES||'+values, ''])
        for current in ('', 'A', 'B|Beta', 'Unlisted'):
            row(prefix('TABLEDATA', 1) + ['1', current, 'hidden'])
    # Exercise both suppression predicates and folder offsets.
    for prop, desc in [('SAP_RMS_1012_005', 'Test'), ('TEST_HIDDEN', 'Allergens')]:
        for line, data in [(1, 'TEST_FIELD'), (2, 'Test'), (3, 'BF'), (4, 'S'), (5, 'Hint||ALLOWED_VALUES||A||ALLOWED_VALUE||B')]:
            row([prop, desc, 'A', 'INSTANCES', 'Instances', 'METADATA', str(line), '', data])
        row([prop, desc, 'A', 'INSTANCES', 'Instances', 'TABLEDATA', '1', '', 'A'])
    row(['TEST_0', 'Folder', 'A', 'ZPT_FOLDER', 'Folder', 'TABLEDATA', '1', ''])
    return E.ElementTree(book)

def main():
    original = compile_xsl(ROOT / 'xslt-validation/original.xsl')
    optimized = compile_xsl(ROOT / 'ZTR_SPC_EXP_MAIN_SU.xsl')
    results = []
    fixtures = [(name, E.parse(str(ROOT / name))) for name in ('cv_file.xml', 'working.xml', 'working_no_validation.xml', 'working_validation_value.xml')]
    fixture = dropdown_fixture()
    fixture.write(str(ROOT / 'xslt-validation/dropdown-fixture.xml'), encoding='UTF-8', xml_declaration=True)
    fixtures.append(('dropdown-fixture.xml', fixture))
    for name, doc in fixtures:
        for enabled in ('X', ''):
            params = {'ENABLE_DROPDOWN_VALIDATION': E.XSLT.strparam(enabled)}
            a, b = signature(original(doc, **params)), signature(optimized(doc, **params))
            same = a == b
            validations = a.count(b'<DataValidation ')
            if name == 'dropdown-fixture.xml' and enabled == 'X':
                assert validations > 0, 'Fixture did not exercise validation'
            results.append({'input': name, 'validation': enabled, 'identical': same, 'bytes': len(a), 'validations': validations})
            if not same:
                (ROOT / 'xslt-validation/failed-original.xml').write_bytes(a)
                (ROOT / 'xslt-validation/failed-optimized.xml').write_bytes(b)
                raise AssertionError(results[-1])
    (ROOT / 'xslt-validation/results.json').write_text(json.dumps(results, indent=2))
    print(json.dumps(results, indent=2))

if __name__ == '__main__':
    main()
