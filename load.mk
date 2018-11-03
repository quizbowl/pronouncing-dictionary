.PHONY: download upload

SHEET_EXPORT_URL:=\
	"https://docs.google.com/spreadsheets/d/15gC3ZxAGfF16mQ-gCZ3btkt-jGjpzRBv5rWpIKdST7s/export?format=csv&gid=0"

download:
	wget $(SHEET_EXPORT_URL) -O pgs.csv

upload: html
	scp index.html lang.html category.html author.html tournament.html pg-dictionary.css *.js \
		pg-dictionary.xml pg-dictionary.xsl functions.xsl \
		gwinnett:~/minkowski.space/quizbowl/pronouncing-dictionary/
