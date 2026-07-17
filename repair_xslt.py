from pathlib import Path
from xml.sax.saxutils import escape
import re

src = Path(r"c:\Users\aknmo\OneDrive\Desktop\Arun\EMEasy Workspace\PLMUTR_SPC_EXP_MAIN.txt")
out = Path(r"c:\Users\aknmo\OneDrive\Desktop\Arun\EMEasy Workspace\PLMUTR_SPC_EXP_MAIN.txt")
text = src.read_text(encoding='utf-8', errors='replace')
lines = text.splitlines()

# Helper to turn a token/attr string into XML attrs

def attr_string(raw: str) -> str:
    raw = raw.strip()
    if not raw:
        return ''
    parts = raw.split()
    out_attrs = []
    for part in parts:
        if '=' not in part:
            continue
        k, v = part.split('=', 1)
        if k in {'xmlnsinput', 'xmlnsxsl', 'xmlnssap', 'xmlnsrcp', 'xmlnsss'}:
            k = {'xmlnsinput': 'xmlns:input', 'xmlnsxsl': 'xmlns:xsl', 'xmlnssap': 'xmlns:sap', 'xmlnsrcp': 'xmlns:rcp', 'xmlnsss': 'xmlns:ss'}[k]
        if v.startswith(("'", '"')):
            v = v[1:-1]
        out_attrs.append(f'{k}="{escape(v, {"\"": "&quot;"})}"')
    return ' ' + ' '.join(out_attrs) if out_attrs else ''


def normalize_line(line: str) -> str:
    s = line.strip()
    if not s:
        return ''
    if s.startswith('!--'):
        return line
    if s.startswith('xml version'):
        return '<?xml version="1.0" encoding="ISO-8859-1"?>'

    # root declaration
    if s.startswith('xslstylesheet'):
        attrs = attr_string(s[len('xslstylesheet'):])
        return '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sap="http://www.sap.com/sapxsl" xmlns:rcp="http://www.sap.com/recipe_development" xmlns:input="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" exclude-result-prefixes="rcp input"' + attrs + '>'

    # self-contained xsl:text with opening/closing marker on same line
    m = re.match(r'^xsltext(.*)xsltext$', s)
    if m:
        body = m.group(1).strip()
        # split attrs and text content if attrs exist before the first content token
        if body:
            if '=' in body and not body.startswith(('"', "'")):
                # simple case: attrs first, then content in rest
                attr_part = ''
                content = body
                # grab the leading attr tokens only
                tokens = body.split()
                filtered = []
                for t in tokens:
                    if '=' in t:
                        filtered.append(t)
                    else:
                        break
                if filtered:
                    attr_part = ' '.join(filtered)
                    content = body[len(' '.join(filtered)):].strip()
                else:
                    content = body
                return f'<xsl:text{attr_string(attr_part)}>{escape(content)}</xsl:text>'
            return f'<xsl:text>{escape(body)}</xsl:text>'
        return '<xsl:text></xsl:text>'

    # xsl:value-of
    if s.startswith('xslvalue-of'):
        return f'<xsl:value-of{attr_string(s[len("xslvalue-of"):])}/>'

    # xsl:include / xsl:param / xsl:output / xsl:preserve-space / xsl:key
    for token, tag in [('xslinclude', 'xsl:include'), ('xslparam', 'xsl:param'), ('xsloutput', 'xsl:output'), ('xslpreserve-space', 'xsl:preserve-space'), ('xslkey', 'xsl:key')]:
        if s.startswith(token):
            return f'<{tag}{attr_string(s[len(token):])}/>'

    # xsl:call-template / xsl:with-param
    for token, tag in [('xslcall-template', 'xsl:call-template'), ('xslwith-param', 'xsl:with-param')]:
        if s.startswith(token):
            return f'<{tag}{attr_string(s[len(token):])}/>'

    # xsl:template / xsl:variable / xsl:if / xsl:for-each / xsl:choose / xsl:when / xsl:otherwise
    for token, tag in [('xsltemplate', 'xsl:template'), ('xslvariable', 'xsl:variable'), ('xslif', 'xsl:if'), ('xslfor-each', 'xsl:for-each'), ('xslchoose', 'xsl:choose'), ('xslwhen', 'xsl:when'), ('xslotherwise', 'xsl:otherwise')]:
        if s == token:
            return f'</{tag}>'
        if s.startswith(token):
            return f'<{tag}{attr_string(s[len(token):])}>'

    # sap external function tags
    for token, tag in [('sapexternal-function', 'sap:external-function'), ('sapargument', 'sap:argument'), ('sapresult', 'sap:result')]:
        if s.startswith(token):
            return f'<{tag}{attr_string(s[len(token):])}/>'

    if s == 'sapexternal-function':
        return '</sap:external-function>'

    # fallback: literal text node
    return escape(line)


out_lines = [normalize_line(line) for line in lines]
out_lines.append('</xsl:stylesheet>')
Path(r"c:\Users\aknmo\OneDrive\Desktop\Arun\EMEasy Workspace\PLMUTR_SPC_EXP_MAIN.txt").write_text('\n'.join(out_lines) + '\n', encoding='utf-8')
print('Rewrote stylesheet with XML-compatible tags.')
