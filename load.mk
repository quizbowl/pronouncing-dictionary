.PHONY: download upload

SHEET_EXPORT_URL:=\
	"https://docs.google.com/spreadsheets/d/15gC3ZxAGfF16mQ-gCZ3btkt-jGjpzRBv5rWpIKdST7s/export?format=csv&gid=0"


download: pg-dictionary.csv
pg-dictionary.csv:
	wget $(SHEET_EXPORT_URL) -O $@

upload: html
	rsync -R $(HTMLS) \
		pg-dictionary.css *.js \
		pg-dictionary.xml pg-dictionary.xsl functions.xsl \
		pg-dictionary.csv \
		assets/images/* \
		gwinnett:~/minkowski.space/quizbowl/pronouncing-dictionary/
