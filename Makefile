all: html

html: index.html lang.html category.html author.html tournament.html
index.html: pg-dictionary.xml pg-dictionary.xsl functions.xsl
	saxon -o:$@ $< $(word 2,$^) -TP:profile.html

xml: pg-dictionary.xml
pg-dictionary.xml: pgs.csv csv2xml.py base.xml
	< $< python $(word 2,$^) | xmllint --format - > $@

-include load.mk
