.PHONY: pgs.csv

SHEET_EXPORT_URL:=\
	"https://docs.google.com/spreadsheets/d/15gC3ZxAGfF16mQ-gCZ3btkt-jGjpzRBv5rWpIKdST7s/export?format=csv&gid=0"

pgs.csv:
	wget $(SHEET_EXPORT_URL) -O $@
