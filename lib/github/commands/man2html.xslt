<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="head">
    </xsl:template>

    <xsl:template match="table[@class='head']">
        <header>
            <xsl:apply-templates select="tr/td|text()" />
        </header>
    </xsl:template>

    <xsl:template match="td[@class='head-ltitle']">
	<p align="center"><b><xsl:copy-of select="text()"></xsl:copy-of></b></p>
    </xsl:template>
    <xsl:template match="td[@class='head-vol']">
      <xsl:if test="string-length(.)>0">
	<p align="center"><xsl:copy-of select="text()"></xsl:copy-of></p>
      </xsl:if>
    </xsl:template>
    <xsl:template match="td[@class='head-rtitle']">
    </xsl:template>

    <xsl:template match="table[@class='foot']">
<hr />
      <footer>
        <xsl:apply-templates select="tr/td|text()" />
      </footer>
    </xsl:template>

    <xsl:template match="td[@class='foot-date']">
		<p>Date: <xsl:copy-of select="text()"></xsl:copy-of></p>
    </xsl:template>
    <xsl:template match="td[@class='foot-os']">
		<p>OS: <xsl:copy-of select="text()"></xsl:copy-of></p>
    </xsl:template>

    <xsl:template match="h1[@class='Sh']/a[@class='selflink']">
        <xsl:copy-of select="text()"></xsl:copy-of>
    </xsl:template>

<!-- //
    <xsl:template match="h1">
        <h2><xsl:value-of select="."/></h2>
    </xsl:template>
// -->

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

<!-- //
    </xsl:template>
// -->
</xsl:stylesheet>
