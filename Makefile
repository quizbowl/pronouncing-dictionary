all: xml
.PHONY: download

SHEET_EXPORT_URL:=\
	"https://docs.google.com/spreadsheets/d/15gC3ZxAGfF16mQ-gCZ3btkt-jGjpzRBv5rWpIKdST7s/export?format=csv&gid=0"

xml: pg-dictionary.xml
pg-dictionary.xml: pgs.csv base.xml
	< $< python csv2xml.py | xmllint --format - > $@

download:
	wget $(SHEET_EXPORT_URL) -O pgs.csv
