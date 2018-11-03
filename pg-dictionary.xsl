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

	<xsl:template match="/">
		<xsl:call-template name="view">
			<xsl:with-param name="view" tunnel="yes">index</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="view">
			<xsl:with-param name="view" tunnel="yes">lang</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="view">
			<xsl:with-param name="view" tunnel="yes">category</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="view">
			<xsl:with-param name="view" tunnel="yes">author</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="view">
			<xsl:with-param name="view" tunnel="yes">tournament</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="view">
		<xsl:param name="view" tunnel="yes"/>

		<xsl:result-document href="{$view}.html">
			<xsl:call-template name="skeleton"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template name="skeleton">
		<xsl:text disable-output-escaping="yes">&#10;&lt;!DOCTYPE html&gt;&#10;</xsl:text>
		<html xml:lang="en">
			<head>
				<meta charset="utf-8"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link type="text/css" rel="stylesheet" href="pg-dictionary.css"/>
				<script type="text/javascript" src="controls.js"/>
			</head>
			<body>
				<a name="top"/>
				<header>
					<h1><a href="./">Quizbowl Pronouncing Dictionary</a></h1>
					<dl>
						<dt>Editor:</dt>
						<dd>Ophir Lifshitz</dd>
						<dt>Status:</dt>
						<dd>Draft. Almost all entries not by <a class="author" data-author="OL" href="author.html#OL">OL</a> are unverified and are probably inaccurate.</dd>
						<dt>Last updated:</dt>
						<dd><time><xsl:value-of select="pg:format-date(current-dateTime())" /></time> Showing a 5% sample of all entries.</dd>
						<dt>Coming soon:</dt>
						<dd>Filter
							<a class="link" href="lang.html">by language</a>,
							<a class="link" href="category.html">by category</a>,
							<a class="link" href="author.html">by author</a>,
							<a class="link" href="tournament.html">by tournament</a>,
							by review scores.</dd>
					</dl>
				</header>
				<article>
					<xsl:apply-templates/>
				</article>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="/pg-dictionary">
		<xsl:param name="view" tunnel="yes"/>

		<xsl:for-each-group select="entry" group-by="
			if ($view='index')      then @initial                   else
			if ($view='lang')       then lang                       else
			if ($view='category')   then usage/(category|context)   else
			if ($view='author')     then meta/author                else
			if ($view='tournament') then meta/quizbowl-source/@name else
			0">
			<xsl:sort select="current-grouping-key()"/>

			<div>
				<h2 id="{current-grouping-key()}">
					<a href="#{current-grouping-key()}">
						<xsl:value-of select="current-grouping-key()"/>
					</a>
					<xsl:call-template name="heading-right"/>
				</h2>
				<xsl:call-template name="columns"/>
			</div>
		</xsl:for-each-group>
	</xsl:template>

	<xsl:template name="heading-right">
		<xsl:variable name="count" select="count(current-group())"/>
		<span class="heading-right">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$count"/>
			<xsl:choose><xsl:when test="$count=1"> entry</xsl:when><xsl:otherwise> entries</xsl:otherwise></xsl:choose>
			<xsl:text> </xsl:text>
			<a href="#top">Top ↑</a>
		</span>
	</xsl:template>
	<xsl:template name="columns">
		<div class="columns">
			<xsl:for-each select="current-group()">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="date | submission | stemmable"/>

	<xsl:template match="entry">
		<section class="entry" id="{@id}">

			<a href="#{@id}" class="mr">
				<xsl:apply-templates select="form/orth"/>
			</a>
			<xsl:call-template name="sp" />
			<span class="mr">
				<xsl:apply-templates select="form/pron"/>
			</span>
			<xsl:call-template name="sp" />

			<span class="etym mr">
				<xsl:apply-templates select="lang"/>
			</span>
			<xsl:call-template name="sp" />

			<xsl:apply-templates select="meta/author"/>

			<div class="usage">
				<xsl:apply-templates select="usage"/>
			</div>

			<div class="citations">
				<xsl:for-each select="meta/citation">
					<xsl:sort select="@type"/>
					<xsl:apply-templates select="."/>
					<xsl:if test="position() != last()">
						<xsl:call-template name="orl"/>
					</xsl:if>
				</xsl:for-each>
			</div>

			<div class="reviews">
				<xsl:apply-templates select="meta/review"/>
			</div>

			<xsl:if test="meta/related-entry">
				<div class="related-entry">
					<span class="h">see also</span>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="meta/related-entry"/>
				</div>
			</xsl:if>

			<div class="extlinks">
				<a href="https://forvo.com/search/{form/orth[1]}">Forvo</a>
				<xsl:text> | </xsl:text>
				<xsl:apply-templates select="meta/quizbowl-source"/>
			</div>

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
		<xsl:variable name="skip" select="not(preceding-sibling::pron) or (@lang = preceding-sibling::pron/@lang)"/>
		<xsl:if test="not($skip)">
			<xsl:apply-templates select="@lang"/>
		</xsl:if>
		<span>
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
		</span>

		<xsl:if test="not(@lang) or @lang = following-sibling::pron/@lang">
			<xsl:call-template name="orsame"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="pron/@lang">
		<xsl:call-template name="lang">
			<xsl:with-param name="class"> first last</xsl:with-param>
		</xsl:call-template>
		<xsl:text>&#xa0;</xsl:text>
	</xsl:template>

	<xsl:template match="lang">
		<xsl:call-template name="lang">
			<xsl:with-param name="class">
				<xsl:if test="not(preceding-sibling::lang)"> main first</xsl:if>
				<xsl:if test="not(following-sibling::lang)"> last</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="lang">
		<xsl:param name="class" />
		<a class="lang {$class}" href="lang.html#{.}" title="{.}">
			<xsl:value-of select="pg:langLookupCanonicalName(.)"/>
		</a>
	</xsl:template>

	<xsl:template match="usage/category|usage/context">
		<a class="{name()}" href="category.html#{.}">
			<xsl:apply-templates/>
		</a>
		<xsl:call-template name="or"/>
	</xsl:template>
	<xsl:template match="usage/definition">
		<span class="{name()}">
			<xsl:apply-templates/>
		</span>
		<xsl:call-template name="or"/>
	</xsl:template>

	<xsl:template match="review">
		<div class="review">
			<span>
			<xsl:if test="author">
				<xsl:apply-templates select="author"/>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:for-each select="@*">
				<xsl:call-template name="abbr"/>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			</span>

			<xsl:call-template name="radar"/>
		</div>
	</xsl:template>

	<xsl:template match="citation">
		<xsl:if test="@url">
			<a href="{@url}" class="link"><xsl:value-of select="@type"/> ref</a>
			<xsl:if test="count(*) > 0">
				<xsl:text>: </xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="citation[@type='audio']">
		<span class="audio-controls">
			<audio preload="none" src="{@url}"/>
    		<button onclick="toggleAudio(this)">&#9658;</button>
    	</span>
	</xsl:template>

	<xsl:template match="author">
		<a class="author" data-author="{.}" href="author.html#{.}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>

	<xsl:template match="related-entry">
		<a href="#{@ref}" class="link">
			<xsl:apply-templates/>
		</a>
		<xsl:call-template name="or"/>
	</xsl:template>

	<xsl:template match="quizbowl-source">
		<a href="{@url}" title="{name}" target="_blank">
			<xsl:text>Locate</xsl:text>
			<xsl:if test="@name != 'MW'">
				<xsl:text> in </xsl:text>
				<xsl:value-of select="@name" />
			</xsl:if>
			<xsl:text>&#xa0;»</xsl:text>
		</a>
	</xsl:template>

</xsl:stylesheet>
