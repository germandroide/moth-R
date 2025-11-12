<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Evidencia Nmap</title>
                <script src="https://cdn.tailwindcss.com"></script>
                <style>
                    body { font-family: 'Courier New', Courier, monospace; }
                </style>
            </head>
            <body class="bg-gray-900 text-green-400 p-4">
                <div class="container mx-auto">
                    <h1 class="text-2xl font-bold mb-4 border-b border-green-500 pb-2">Evidencia Detallada de Nmap</h1>
                    <xsl:apply-templates select="/nmaprun/host"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="host">
        <div class="bg-gray-800 p-4 rounded-lg shadow-lg">
            <h2 class="text-xl text-cyan-400 mb-2">Host: <xsl:value-of select="address[@addrtype='ipv4']/@addr"/></h2>
            <p class="mb-4">Estado: <span class="font-bold"><xsl:value-of select="status/@state"/></span></p>

            <table class="min-w-full bg-gray-900 border border-gray-700">
                <thead>
                    <tr class="bg-gray-700">
                        <th class="py-2 px-4 border-b border-gray-600 text-left">Puerto</th>
                        <th class="py-2 px-4 border-b border-gray-600 text-left">Protocolo</th>
                        <th class="py-2 px-4 border-b border-gray-600 text-left">Estado</th>
                        <th class="py-2 px-4 border-b border-gray-600 text-left">Servicio</th>
                        <th class="py-2 px-4 border-b border-gray-600 text-left">Producto/Versión</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="ports/port[state/@state='open']">
                        <xsl:sort select="@portid" data-type="number"/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="port">
        <tr class="hover:bg-gray-700">
            <td class="py-2 px-4 border-b border-gray-600"><xsl:value-of select="@portid"/></td>
            <td class="py-2 px-4 border-b border-gray-600"><xsl:value-of select="@protocol"/></td>
            <td class="py-2 px-4 border-b border-gray-600 text-yellow-300"><xsl:value-of select="state/@state"/></td>
            <td class="py-2 px-4 border-b border-gray-600"><xsl:value-of select="service/@name"/></td>
            <td class="py-2 px-4 border-b border-gray-600">
                <xsl:value-of select="service/@product"/>
                <xsl:if test="service/@version">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="service/@version"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
