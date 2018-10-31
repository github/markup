<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Default: match anything and apply templates to it -->
  <xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Turn these into breaks -->
  <xsl:template match="div[@class='Pp']">
    <br/><br/>
  </xsl:template>

  <!-- Headers don't need to be linking to themselves -->
  <xsl:template match="a[@class='permalink']">
    <xsl:apply-templates />
  </xsl:template>

  <!-- Remove the header table -->
  <xsl:template match="table[@class='head']" />

  <!-- These were display: inline, so just give the content -->
  <xsl:template match="div[@class='Nd']|div[@class='Bf']|div[@class='Op']">
    <xsl:apply-templates />
  </xsl:template>

  <!-- These were display: italic -->
  <xsl:template match="span[@class='Pa']|span[@class='Ad']">
    <em><xsl:apply-templates /></em>
  </xsl:template>

  <!-- These were font-weight: bold -->
  <xsl:template match="span[@class='Ms']|dl[@class='BL-diag']/dt">
    <strong><xsl:apply-templates /></strong>
  </xsl:template>

  <!-- These were font-weight: bold -->
  <xsl:template match="code[@class='Nm']|code[@class='Fl']|code[@class='Cm']|code[@class='Ic']|code[@class='In']|code[@class='Fd']|code[@class='Fn']|code[@class='Cd']">
    <strong><tt><xsl:apply-templates /></tt></strong>
  </xsl:template>

  <xsl:template match="table[@class='foot']">
    <xsl:apply-templates select="tr/td[@class='foot-date']" />
  </xsl:template>

  <xsl:template match="td[@class='foot-date']">
    <p><strong>Date:<xsl:copy-of select="text()" /></strong></p>
  </xsl:template>
</xsl:stylesheet>
