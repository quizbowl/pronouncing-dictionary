.PRECIOUS: %.xml %.xsl

HTMLS_SORTS:=lang.html lang-family.html category.html author.html tournament.html
HTMLS:=\
	index.html $(HTMLS_SORTS) \
	about.html entry.html writing-pgs.html lang-specific.html references.html contributors.html


all: html

html: $(HTMLS)

# FIXME may need to change left side to pg-dictionary.xsl, or move above
pg-dictionary.xsl: data/lang-family-tree.xml


$(HTMLS_SORTS): index.html
index.html: pg-dictionary.xml pg-dictionary.xsl
	saxon -o:$@ $< $(word 2,$^) -TP:profile.html

lang-specific.html: lang-specific.xml lang-specific.xsl
	saxon -o:$@ $< $(word 2,$^)

%.html: %.xml page.xsl
	saxon -o:$@ $< $(word 2,$^)

lang-specific.xsl: page.xsl
page.xsl: pg-dictionary.xsl
pg-dictionary.xsl: functions.xsl sitemap.xml

xml: pg-dictionary.xml
pg-dictionary.xml: pg-dictionary.csv csv2xml.py base.xml
	< $< python $(word 2,$^) | xmllint --format - > $@

%.xml: %.pxml transformers/xslt2.edf
	pxslcc -h --add=$(word 2,$^) "$<" > "$@"

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=$(word 2,$^) "$<" > "$@"

-include load.mk
