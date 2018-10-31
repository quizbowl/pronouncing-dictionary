all: html

html: pg-dictionary.html
pg-dictionary.html: pg-dictionary.xml pg-dictionary.xsl functions.xsl
	saxon -o:$@ $< $(word 2,$^)

xml: pg-dictionary.xml
pg-dictionary.xml: pgs.csv csv2xml.py base.xml
	< $< python $(word 2,$^) | xmllint --format - > $@

-include load.mk
