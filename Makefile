.PRECIOUS: %.xml %.xsl

HTMLS_SORTS:=lang.html category.html author.html tournament.html
HTMLS:=\
	index.html $(HTMLS_SORTS) \
	about.html entry.html writing-pgs.html references.html


all: html

html: $(HTMLS)

$(HTMLS_SORTS): index.html
index.html: pg-dictionary.xml pg-dictionary.xsl
	saxon -o:$@ $< $(word 2,$^) -TP:profile.html

%.html: %.xml page.xsl
	saxon -o:$@ $< $(word 2,$^)

page.xsl: pg-dictionary.xsl
pg-dictionary.xsl: functions.xsl

xml: pg-dictionary.xml
pg-dictionary.xml: pgs.csv csv2xml.py base.xml
	< $< python $(word 2,$^) | xmllint --format - > $@

%.xml: %.pxml
	pxslcc -h "$<" > "$@"

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=$(word 2,$^) "$<" > "$@"

-include load.mk
