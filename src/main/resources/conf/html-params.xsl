<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:param name="glossary.sort" select="1"></xsl:param>

<xsl:param name="generate.section.toc.level" select="1"></xsl:param>

<xsl:param name="admon.graphics" select="1"></xsl:param>
<xsl:param name="admon.graphics.path">images/icons/admon/</xsl:param>
<xsl:param name="admon.graphics.extension">.png</xsl:param>

<xsl:param name="navig.graphics.path">images/icons/</xsl:param>
<xsl:param name="navig.graphics" select="0"></xsl:param>

<xsl:param name="callout.graphics" select="0"/>
<xsl:param name="callout.unicode" select="1"/>
<xsl:param name="callout.unicode.number.limit" select="10"/>

<xsl:param name="generate.legalnotice.link" select="1"/>
<xsl:param name="legalnotice.filename">legalnotice.html</xsl:param>

<xsl:param name="generate.revhistory.link" select="1"/>

<xsl:param name="use.id.as.filename" select="1"></xsl:param>

</xsl:stylesheet>

