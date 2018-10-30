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
    <xsl:copy-of select="text()"></xsl:copy-of>
  </xsl:template>

  <!-- The rest is ported styles from mandoc default CSS -->
  <xsl:template match="table[@class='head']|table[@class='foot']">
    <xsl:copy>
      <xsl:attribute name="style">width: 100%;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="td[@class='head-rtitle']|td[@class='foot-os']">
    <xsl:copy>
      <xsl:attribute name="style">text-align: right;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="td[@class='head-vol']">
    <xsl:copy>
      <xsl:attribute name="style">text-align: center;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="div[@class='Nd']|div[@class='Bf']|div[@class='Op']">
    <xsl:copy>
      <xsl:attribute name="style">display: inline;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="span[@class='Pa']|span[@class='Ad']">
    <xsl:copy>
      <xsl:attribute name="style">font-style: italic;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="span[@class='Ms']|dl[@class='BL-diag']/dt">
    <xsl:copy>
      <xsl:attribute name="style">font-weight: bold;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="code[@class='Nm']|code[@class='Fl']|code[@class='Cm']|code[@class='Ic']|code[@class='In']|code[@class='Fd']|code[@class='Fn']|code[@class='Cd']">
    <xsl:copy>
      <xsl:attribute name="style">font-weight: bold; font-family: inherit;</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
