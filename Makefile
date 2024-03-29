.PRECIOUS: %.xml %.xsl
.PHONY: all html xml valid

HTMLS_SORTS:=lang.html lang-tree.html category.html category-tree.html author.html tournament.html
HTMLS:=\
	index.html $(HTMLS_SORTS) \
	about.html entry.html writing-pgs.html lang-specific.html references.html contributors.html

XMLLINT:=| XMLLINT_INDENT='	' xmllint --format -


all: html

html: $(HTMLS)

# FIXME may need to change left side to pg-dictionary.xsl, or move above
index.html: data/lang-tree.xml data/category-tree.xml

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
	< $< python $(word 2,$^) $(XMLLINT) > $@

%.xml: %.pxml transformers/xslt2.edf
	pxslcc -h --add=$(word 2,$^) "$<" $(XMLLINT) > "$@"

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=$(word 2,$^) "$<" $(XMLLINT) > "$@"

valid: pg-dictionary.rng pg-dictionary.xml
	xmllint --noout --relaxng $^
pg-dictionary.rng: pg-dictionary.rnc
	trang $< $@


-include load.mk
