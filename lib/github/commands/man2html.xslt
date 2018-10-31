<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Default: match anything and apply templates to it -->
  <xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Strip all the attributes off of these -->
  <xsl:template match="h1">
    <h1><xsl:apply-templates /></h1>
  </xsl:template>

  <!-- Turn these into paragraphs -->
  <xsl:template match="div[@class='Pp']">
    <p><xsl:apply-templates /></p>
  </xsl:template>

  <!-- Indent these -->
  <xsl:template match="div[@class='Bd-indent' or @class='Bd Bd-indent']">
    <ul><xsl:apply-templates /></ul>
  </xsl:template>

  <!-- Headers don't need to be linking to themselves -->
  <xsl:template match="a[@class='permalink']">
    <xsl:apply-templates />
  </xsl:template>

  <!-- Pull the manual-text div out -->
  <xsl:template match="div[@class='manual-text']">
    <xsl:apply-templates />
  </xsl:template>

  <!-- These were display: inline, so just give the content -->
  <xsl:template match="div[@class='Nd' or @class='Bf' or @class='Op']">
    <xsl:apply-templates />
  </xsl:template>

  <!-- These were display: italic -->
  <xsl:template match="span[@class='Pa' or @class='Ad']">
    <em><xsl:apply-templates /></em>
  </xsl:template>

  <!-- These were font-weight: bold -->
  <xsl:template match="span[@class='Ms']">
    <b><xsl:apply-templates /></b>
  </xsl:template>

  <xsl:template match="dl[@class='BL-diag']/dt">
    <b><xsl:apply-templates /></b>
  </xsl:template>

  <xsl:template match="code[@class='Nm' or @class='Fl' or @class='Cm' or @class='Ic' or @class='In' or @class='Fd' or @class='Fn' or @class='Cd']">
    <b><code><xsl:apply-templates /></code></b>
  </xsl:template>

  <!-- Remove header table -->
  <xsl:template match="table[@class='head']"/>

  <!-- Reformat footer table and pull some header stuff into it -->
  <xsl:template match="table[@class='foot']">
    <hr/>
    <table>
      <xsl:apply-templates select="//td[text() and text() != '()' and @class='head-ltitle']"/>
      <xsl:apply-templates select="//td[text() and text() != '()' and @class='head-vol']"/>
      <xsl:apply-templates select="//td[text() and text() != '()' and @class='foot-os']"/>
      <xsl:apply-templates select="//td[text() and text() != '()' and @class='foot-date']"/>
    </table>
  </xsl:template>

  <!-- Turn head header/footer cells into rows -->
  <xsl:template match="td[@class='head-ltitle']">
    <tr><td><em>Title:</em></td><td><xsl:apply-templates /></td></tr>
  </xsl:template>

  <xsl:template match="td[@class='head-vol']">
    <tr><td><em>Volume:</em></td><td><xsl:apply-templates /></td></tr>
  </xsl:template>

  <xsl:template match="td[@class='foot-date']">
    <tr><td><em>Date:</em></td><td><xsl:apply-templates /></td></tr>
  </xsl:template>

  <xsl:template match="td[@class='foot-os']">
    <tr><td><em>Manual:</em></td><td><xsl:apply-templates /></td></tr>
  </xsl:template>
</xsl:stylesheet>
