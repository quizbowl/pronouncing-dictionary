#!/usr/bin/env python
#-*- coding: utf-8 -*-
import unicodecsv as csv
import sys
import codecs

from lxml import etree
import re

import random
import urllib
from collections import Counter
from unidecode import unidecode
from slugify import UniqueSlugify
slugify = UniqueSlugify(translate=None, safe_chars=u"-.'\"‘’“”–", separator="_")

DEBUG = True

doc = etree.parse('base.xml')
root = doc.getroot()

cols = [
	'word','pg',
	'utility','familiarity',
	'submitted_by','submit_date','reviewed_by','review_date', 'review_notes',
	'accuracy','decipherability',
	# 'duplicate',
	'stemmable','category','subcategory','context','definition',
	'pg_ipa',
	'lang','original_lang',
	'reference','audio_reference','word_in_reference','pg_in_reference',
	'qb_source','word_in_qb_source','pg_in_qb_source',
	'author','see_also'
	# 'exemplar', 'ex'
]
rel_map = {
	u'=': 'canonical',
	u'≠': 'confusable',
}

# DSL description:
#   | delimits alternatives
#   TODO: \ naively escapes special characters like |, but \ cannot be escaped itself.
#     (Naive because it's implemented ad hoc by the simplest lookbehind)
#
#   , is used instead of | in `original_lang`
#
#   : delimits lang prefix (see regex below)
#     Currently, lang prefix is allowed in all fields except `review_notes`
#
#   {} wraps internal links in `definition`
#
#   =≠ etc. prefixes in `see_also`
#
#   other minor details may affect specific fields; read the code to understand

lang_prefix_re = '^(?:([a-z][^:]+):)?(.*)$'
def extract_lang_prefix(str):
	return re.match(lang_prefix_re, str).groups()

def split(parent, child_name, joined_text, type_value=None, extract_lang=True):
	for val in joined_text.split('|'):
		if val:
			if extract_lang:
				lang, text = extract_lang_prefix(val)
			else:
				lang, text = None, val
			child = etree.SubElement(parent, child_name)
			child.text = text
			if lang:
				child.set('lang', lang)
				if child_name == 'pron':
					child.set('notation', 'IPA')
			if type_value:
				child.set('type', type_value)

def attr(parent, attr_name, text):
	if text:
		parent.set(attr_name, text)

def initial(word):
	word_upper_alphanum_only = word.upper() #re.sub('\\W', '', word.upper(), flags=re.UNICODE)
	initial = unidecode(word_upper_alphanum_only)[:1]
	if re.match('^[A-Z]$', initial):
		return initial
	elif re.match('^[0-9]$', initial):
		return '#'
	else:
		return '$'

rows = csv.DictReader(sys.stdin, dialect=csv.excel)
random.seed(15)
for row in rows:
	if row['word'] == 'wd' and row['pg'] == 'pg': continue
	# if not (row['ex'] or random.random() > 0.95): continue

	entry = etree.SubElement(root, 'entry')
	first_orth = re.sub('\\|.*', '', row['word'])
	entry.set('id', slugify(first_orth))
	# should there be secondary ids for alternate headwords? #goiter #goitre (lang="en-GB")
	entry.set('initial', initial(first_orth))

	if row['exemplar']:
		entry.set('exemplar', row['exemplar'])

	# <form>
	form = etree.SubElement(entry, 'form')
	split(form, 'orth', row['word'])
	split(form, 'pron', row['pg'])
	
	# <lang>
	split(entry, 'lang', row['lang'])
	split(entry, 'lang', row['original_lang'].replace(',', '|'), 'original')
	
	# <usage>
	if row['category'] + row['subcategory'] + row['context'] + row['definition'] + row['stemmable']:
		usage = etree.SubElement(entry, 'usage')
		split(usage, 'stemmable', row['stemmable']) # should probably not be in <usage>
		split(usage, 'category', row['category'])
		split(usage, 'category', row['subcategory'], 'subcategory')
		split(usage, 'context', row['context'])
		if row['definition']:
			definition_split = re.split('\{([^{}]+)\}', row['definition'])
			definition = etree.SubElement(usage, 'definition')
			definition.text = definition_split[0]
			for i in range(1, len(definition_split), 2):
				text = definition_split[i]
				tail = definition_split[i+1]
				ref = super(UniqueSlugify, slugify).__call__(text)
				chunk_el = etree.SubElement(definition, 'related-entry')
				chunk_el.text = text
				chunk_el.tail = tail
				chunk_el.set('ref', ref)
				chunk_el.set('rel', 'xref')

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
	if row['utility'] + row['familiarity'] + row['accuracy'] + row['decipherability'] + row['reviewed_by'] + row['review_date'] + row['review_notes']:
		review = etree.SubElement(meta, 'review')
		attr(review, 'utility', row['utility'])
		attr(review, 'familiarity', row['familiarity'])
		attr(review, 'accuracy', row['accuracy'])
		attr(review, 'decipherability', row['decipherability'])
		split(review, 'notes', row['review_notes'], extract_lang=False)
		split(review, 'author', row['reviewed_by'])
		split(review, 'date', row['review_date'])
	## <citation>
	if row['audio_reference']:
		citation_audio = etree.SubElement(meta, 'citation')
		citation_audio.set('type', 'audio')
		citation_audio.set('url', row['audio_reference'])
	if row['reference'] + row['word_in_reference'] + row['pg_in_reference']:
		citation = etree.SubElement(meta, 'citation')
		citation.set('type', 'text')
		if row['reference']:
			citation.set('url', row['reference'])
		citation_form = etree.SubElement(citation, 'form')
		split(citation_form, 'orth', row['word_in_reference'])
		split(citation_form, 'pron', row['pg_in_reference'])
	## <quizbowl-source>
	if row['qb_source_url']:
		source = etree.SubElement(meta, 'quizbowl-source')
		source.set('url', row['qb_source_url'])
		source_form = etree.SubElement(source, 'form')
		split(source_form, 'orth', row['word_in_qb_source'])
		split(source_form, 'pron', row['pg_in_qb_source'])
		source_no_prefix = re.sub('[^|]+:', '', row['qb_source'])
		split(source, 'name', source_no_prefix)
		source_no_filename = re.sub('/.*', '', source_no_prefix).replace('_', ' ')
		source.set('name', source_no_filename)
	## <related-entry>
	# TODO: related-entries may still need to exist (if there are incoming links)
	if row['see_also']:
		related_entries = etree.SubElement(meta, 'related-entries')
	if DEBUG and row['word'] in row['definition']:
		sys.stderr.write('%-30s\t%s\n' % ( row['word'], row['definition'].replace(row['word'], '\033[4;107m' + row['word'] + '\033[0m') ))
	for text in row['see_also'].split('|'):
		if text:
			if DEBUG and text in row['definition']:
				sys.stderr.write('%-30s\t%s\t%s\n' % (
					row['word'],
					row['definition'].replace(text, '\033[4;106m' + text + '\033[0m'),
					row['see_also'].replace(text, '\033[4;106m' + text + '\033[0m')
				))
			related_entry = etree.SubElement(related_entries, 'related-entry')
			
			if text.startswith('http'):
				ref = text
				rel = 'href'
				# TODO: temporary generated link text
				text = urllib.unquote(text.split('/')[-1])
			else:
				if text.startswith(tuple(rel_map.keys())):
					# TODO: key may not always be 1 character long
					rel_symbol = text[0]
					rel = rel_map[rel_symbol]
					text = text[1:]
				else:
					rel = 'xref'
				ref = super(UniqueSlugify, slugify).__call__(text)
			related_entry.text = text
			related_entry.set('ref', ref)
			attr(related_entry, 'rel', rel)

# count how many incoming links. 0 = red, > 1 = disambig


# entry_ids = doc.xpath('/*/entry/form/orth|/*/entry/meta/related-entries/related-entry[@rel="canonical"]')
# xrefs = doc.xpath('(/*/entry/usage/definition|/*/entry/meta/related-entries)/related-entry[@rel!="incoming" and @rel!="href"]')
# sys.stderr.write( '\t'.join([i.text for i in entry_ids]) )
# sys.stderr.write( '\n\n' )
# sys.stderr.write( '\t'.join([i.text for i in xrefs]) )
# sys.stderr.write( '\n\n' )
# for xref in xrefs:
# 	sys.stderr.write( xref.text )
# 	sys.stderr.write( xref.text )

# 	missing
# 	exists
#   ambig
#   then slugify
# for entry in entry_ids:
#   for each xrefs[@ref=entry]
#     add xref[@rel=incoming]

doc.write(sys.stdout, encoding="utf-8", xml_declaration=True)
