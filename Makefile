all: html
.PHONY: download

SHEET_EXPORT_URL:=\
	"https://docs.google.com/spreadsheets/d/15gC3ZxAGfF16mQ-gCZ3btkt-jGjpzRBv5rWpIKdST7s/export?format=csv&gid=0"


html: pg-dictionary.html
pg-dictionary.html: pg-dictionary.xml pg-dictionary.xsl functions.xsl
	saxon -o:$@ $< $(word 2,$^)

xml: pg-dictionary.xml
pg-dictionary.xml: pgs.csv csv2xml.py base.xml
	< $< python $(word 2,$^) | xmllint --format - > $@

download:
	wget $(SHEET_EXPORT_URL) -O pgs.csv
