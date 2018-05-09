<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="table[@class='head']">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:attribute name="style">width:100%</xsl:attribute>
			<xsl:apply-templates select="node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="table[@class='head']/tbody/tr/td[@class='head-vol']">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:attribute name="style">width:100%;text-align:center;border:none</xsl:attribute>
			<xsl:apply-templates select="node()" />
		</xsl:copy>
	</xsl:template>

    <xsl:template match="table[@class='foot']">
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

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>



<!-- //
    </xsl:template>
// -->
</xsl:stylesheet>
