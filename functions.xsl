<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pg="http://schema.quizbowl.technology/xml/pg-dictionary"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	exclude-result-prefixes="xs pg math"
	version="2.0">

	<xsl:function name="pg:langGetPrefix" as="xs:string">
		<xsl:param name="langP" as="xs:string"/>
		<xsl:value-of select="tokenize($langP, '-')[1]"/>
	</xsl:function>
	<xsl:function name="pg:langLookupCanonicalName" as="xs:string">
		<xsl:param name="langP" as="xs:string"/>
		<xsl:variable name="langPrefix" select="pg:langGetPrefix($langP)"/>
		<xsl:variable name="langName" select="$langs/key('langKey', $langPrefix)/description[1]"/>
		<xsl:choose>
			<xsl:when test="$langName">
				<xsl:value-of select="$langName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('? (', $langP, ')')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="pg:format-date" as="xs:string">
		<xsl:param name="s" as="xs:dateTime"/>
		<xsl:value-of select="format-dateTime($s, '[F], [MNn] [D], [Y], [h]:[m] [P]', 'en', (), ())"/>
	</xsl:function>

	<xsl:variable name="langs" select="document('data/language-subtag-registry.xml')" as="document-node()"/>
	<xsl:key name="langKey" match="/registry/language" use="subtag"/>


	<xsl:template name="abbr">
		<xsl:variable name="abbr">
			<xsl:value-of select="name()"/>
		</xsl:variable>
		<!--<xsl:variable name="abbr">
			<xsl:choose>
				<xsl:when test="name() = 'accuracy'">acc</xsl:when>
				<xsl:when test="name() = 'decipherability'">decipher</xsl:when>
				<xsl:when test="name() = 'familiarity'">famil</xsl:when>
				<xsl:when test="name() = 'utility'">util</xsl:when>
			</xsl:choose>
		</xsl:variable>-->
		<xsl:value-of select="$abbr"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template name="orsame">
		<xsl:variable name="varName" select="name()"/>
		<xsl:if test="following-sibling::*[name() = $varName]">
			<xsl:call-template name="orl"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="or">
		<xsl:if test="following-sibling::*[name() != 'stemmable']">
			<xsl:call-template name="orl"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="orl">
		<span class="or">
			<xsl:text> | </xsl:text>
		</span>
	</xsl:template>

	<xsl:template name="sp">
		<span class="sp">
			<xsl:text> </xsl:text>
		</span>
	</xsl:template>

	<xsl:template name="radar">
		<xsl:variable name="d">
			<xsl:variable name="n" select="count(@*)"/>
			<xsl:for-each select="@*">
				<xsl:variable name="th" select="2*math:pi() * position() div $n + (math:pi())"/>
				<xsl:choose>
					<xsl:when test="position() = 1">M </xsl:when>
					<xsl:otherwise>L </xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="round((. + 2) * math:sin($th) * 1e4) div 1e4"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="round((. + 2) * math:cos($th) * 1e4) div 1e4"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
			<xsl:text>z</xsl:text>
		</xsl:variable>
		<svg width="16" viewBox="-5 -5 10 10">
			<path class="axis"  d="M 0 5 L 5 0 L 0 -5 L -5 0 z"/>
			<path class="shape" d="{$d}"/>
		</svg>
	</xsl:template>

</xsl:stylesheet>
