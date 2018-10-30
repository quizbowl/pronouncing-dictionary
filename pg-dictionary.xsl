<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pg="http://schema.quizbowl.technology/xml/pg-dictionary"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs pg"
	version="2.0">

	<xsl:import href="functions.xsl"/>

	<xsl:output method="xhtml" indent="yes"/>

	<xsl:template match="/pg-dictionary">
		<xsl:text disable-output-escaping="yes">&#10;&lt;!DOCTYPE html&gt;&#10;</xsl:text>
		<html xml:lang="en">
			<head>
				<meta charset="utf-8"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link type="text/css" rel="stylesheet" href="pg-dictionary.css"/>
			</head>
			<body>
				<header>
					<h1>Quizbowl Pronouncing Dictionary</h1>
				</header>
				<article>
					<xsl:for-each-group select="entry"
						group-by="pg:indexSymbol(form/orth[1])">
						<xsl:sort select="current-grouping-key()"/>
<!--                        <h2>
							<xsl:value-of select="current-grouping-key()"/>
							<small>
								<xsl:value-of select="count(current-group())"/>
							</small>
						</h2>-->
						
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<br />
					</xsl:for-each-group>

					<xsl:for-each-group select="entry" group-by="key('entryKey', .)">
						<xsl:sort select="current-grouping-key()"/>
						<xsl:value-of select="."/>
						<xsl:element name="{current-grouping-key()}">
							<xsl:copy-of select="current-group()"/>
						</xsl:element>
					</xsl:for-each-group>

				</article>

				<footer>
					<p>Last updated <time><xsl:value-of select="pg:format-date(current-dateTime())" /></time></p>
				</footer>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="date | submission | stemmable | quizbowl-source"/>

	<xsl:template match="entry">
		<section class="entry">
			<xsl:if test="form">
				<xsl:apply-templates select="form"/>
			</xsl:if>

			<xsl:if test="lang">
				<span class="etym">
					<xsl:apply-templates select="lang"/>
				</span>
			</xsl:if>

			<xsl:if test="usage">
				<div class="usage">
					<xsl:apply-templates select="usage"/>
				</div>
			</xsl:if>

			<xsl:if test="meta/citation">
				<div class="citations">
					<xsl:for-each select="meta/citation">
						<xsl:sort select="@type"/>
						<xsl:apply-templates select="."/>
						<xsl:if test="position() != last()">
							<xsl:call-template name="orl"/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</xsl:if>

			<xsl:if test="meta/review">
				<div class="reviews">
					<xsl:apply-templates select="meta/review"/>
				</div>
			</xsl:if>

		</section>
	</xsl:template>

	<xsl:template match="entry/form/orth">
		<b class="headword">
			<xsl:apply-templates/>
		</b>
		<xsl:call-template name="orsame"/>
	</xsl:template>
	<xsl:template match="orth">
		<xsl:apply-templates/>
		<xsl:call-template name="orsame"/>
	</xsl:template>

	<xsl:template match="pron">
		<xsl:if test="preceding-sibling::pron and not(@lang = preceding-sibling::pron/@lang)">
			<xsl:apply-templates select="@lang"/>
		</xsl:if>
		<xsl:element name="span">
			<xsl:choose>
				<xsl:when test="@notation = 'IPA'">
					<xsl:attribute name="class">pron IPA</xsl:attribute>
					<!--<xsl:text>[</xsl:text>-->
					<xsl:apply-templates/>
					<!--<xsl:text>]</xsl:text>-->
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">pron</xsl:attribute>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

		<xsl:if test="not(@lang) or @lang = following-sibling::pron/@lang">
			<xsl:call-template name="orsame"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="pron/@lang" xml:space="default">
		<xsl:element name="a">
			<xsl:attribute name="class">lang first last</xsl:attribute>
			<xsl:attribute name="href">
				<xsl:text>#lang=</xsl:text>
				<xsl:value-of select="(.)"/>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="(.)"/>
			</xsl:attribute>
			<xsl:value-of select="pg:langLookupCanonicalName(.)"/>
		</xsl:element>
		<xsl:text>&#xa0;</xsl:text>
	</xsl:template>

	<xsl:template match="lang">
		<xsl:element name="a">
			<xsl:attribute name="class">
				<xsl:text>lang</xsl:text>
				<xsl:if test="not(preceding-sibling::lang)"> main first</xsl:if>
				<xsl:if test="not(following-sibling::lang)"> last</xsl:if>
			</xsl:attribute>
			<xsl:attribute name="href">
				<xsl:text>#lang=</xsl:text>
				<xsl:value-of select="(.)"/>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="(.)"/>
			</xsl:attribute>
			<xsl:value-of select="pg:langLookupCanonicalName(.)"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="usage/*[name() != 'stemmable']">
		<xsl:element name="span">
			<xsl:attribute name="class">
				<xsl:value-of select="name()"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
		<xsl:call-template name="or"/>
	</xsl:template>

	<xsl:template match="review">
		<div class="review">
			<xsl:apply-templates select="author"/>
			<xsl:text>: </xsl:text>
			<xsl:for-each select="@*">
				<xsl:call-template name="abbr"/>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="citation">
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="@url"/>
			</xsl:attribute>
			<xsl:value-of select="@type"/>
		</a>
		<xsl:if test="count(*) > 0">
			<xsl:text>: </xsl:text>
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="related-entry">
		<span class="h">see also</span>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

</xsl:stylesheet>
