#!/usr/bin/env python
import unicodecsv as csv
import sys
import codecs

from lxml import etree

doc = etree.parse('base.xml')
root = doc.getroot()

cols = [
	'word','pg',
	'utility','familiarity',
	'submitted_by','submit_date','reviewed_by','review_date',
	'accuracy','decipherability',
	'stemmable','category','subcategory','context','definition',
	'pg_ipa',
	'lang','original_lang',
	'reference','audio_reference','pg_in_reference',
	'qb_source','word_in_qb_source','pg_in_qb_source',
	'author','see_also'
]

rows = list(csv.DictReader(sys.stdin, dialect=csv.excel))
for row in rows[:10]:
	entry = etree.SubElement(root, 'entry')
	for col in cols:
		if row[col] == '': continue

		el = etree.SubElement(entry, col)
		el.text = (row[col])


doc.write(sys.stdout, encoding="utf-8", xml_declaration=True)
