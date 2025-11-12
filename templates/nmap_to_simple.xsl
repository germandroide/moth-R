<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nmap="http://nmap.org/schemas/nmap.xml">
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/nmaprun">
        <xsl:apply-templates select="host[status/@state='up']"/>
    </xsl:template>

    <xsl:template match="host">
        <xsl:apply-templates select="ports/port[state/@state='open']"/>
    </xsl:template>

    <xsl:template match="port">
        <xsl:value-of select="@portid"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="service/@name"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="concat(service/@product, ' ', service/@version)"/>
        <xsl:if test="position() != last()">
            <xsl:text>&#xA;</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
