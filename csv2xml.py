#!/usr/bin/env python
import unicodecsv as csv
import sys
import codecs

from lxml import etree
import re

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
	'reference','audio_reference','word_in_reference','pg_in_reference',
	'qb_source','word_in_qb_source','pg_in_qb_source',
	'author','see_also'
]

lang_prefix_re = '^(?:([^:]+):)?(.*)$'
def extract_lang_prefix(str):
	return re.match(lang_prefix_re, str).groups()

def split(parent, child_name, joined_text):
	for val in joined_text.split('|'):
		if val:
			lang, text = extract_lang_prefix(val)
			child = etree.SubElement(parent, child_name)
			child.text = text
			if lang:
				child.set('lang', lang)
				if child_name == 'pron':
					child.set('notation', 'IPA')

def attr(parent, attr_name, text):
	if text:
		parent.set(attr_name, text)

rows = csv.DictReader(sys.stdin, dialect=csv.excel)
for row in rows:
	if not row['ex']: continue

	entry = etree.SubElement(root, 'entry')

	# <form>
	form = etree.SubElement(entry, 'form')
	split(form, 'orth', row['word'])
	split(form, 'pron', row['pg'])
	
	# <lang>
	split(entry, 'lang', row['lang'] + '|' + row['original_lang'].replace(',', '|'))
	
	# <usage>
	if row['category'] + row['subcategory'] + row['context'] + row['definition'] + row['stemmable']:
		usage = etree.SubElement(entry, 'usage')
		split(usage, 'category', row['category'] + '|' + row['subcategory'])
		split(usage, 'context', row['context'])
		split(usage, 'definition', row['definition'])
		split(usage, 'stemmable', row['stemmable'])

	# <meta>
	meta = etree.SubElement(entry, 'meta')
	## <author>
	split(meta, 'author', row['author'])
	## <submission>
	if row['submitted_by'] and row['submit_date']:
		submission = etree.SubElement(meta, 'submission')
		split(submission, 'author', row['submitted_by'])
		split(submission, 'date', row['submit_date'])
	## <review>
	if row['utility'] + row['familiarity'] + row['accuracy'] + row['decipherability'] + row['reviewed_by'] + row['review_date']:
		review = etree.SubElement(meta, 'review')
		attr(review, 'utility', row['utility'])
		attr(review, 'familiarity', row['familiarity'])
		attr(review, 'accuracy', row['accuracy'])
		attr(review, 'decipherability', row['decipherability'])
		split(review, 'author', row['reviewed_by'])
		split(review, 'date', row['review_date'])
	## <citation>
	if row['audio_reference']:
		citation_audio = etree.SubElement(meta, 'citation')
		citation_audio.set('type', 'audio')
		citation_audio.set('url', row['audio_reference'])
	if row['reference']:
		citation = etree.SubElement(meta, 'citation')
		citation.set('type', 'text')
		citation.set('url', row['reference'])
		citation_form = etree.SubElement(citation, 'form')
		split(citation_form, 'orth', row['word_in_reference'])
		split(citation_form, 'pron', row['pg_in_reference'])
	## <quizbowl-source>
	source = etree.SubElement(meta, 'quizbowl-source')
	source.set('url', row['qb_source_url'])
	source_form = etree.SubElement(source, 'form')
	split(source_form, 'orth', row['word_in_qb_source'])
	split(source_form, 'pron', row['pg_in_qb_source'])
	source_no_prefix = re.sub('[^|]+:', '', row['qb_source'])
	split(source, 'name', source_no_prefix)
	## <related-entry>
	split(meta, 'related-entry', row['see_also'])

doc.write(sys.stdout, encoding="utf-8", xml_declaration=True)