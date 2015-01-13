<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xf="http://www.w3.org/2002/xforms"
	xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:rte="http://www.agencexml.com/xsltforms/rte" xmlns:xsltforms="http://www.agencexml.com/xsltforms">

	<xsl:template match="/">
		<xsl:if test="page/header/xf:model">
			<xsl:processing-instruction name="xml-stylesheet">
				href="resources/xsltforms/xsltforms.xsl" type="text/xsl"
			</xsl:processing-instruction>
			<xsl:processing-instruction name="css-conversion">
				no
			</xsl:processing-instruction>
		</xsl:if>
		<html xmlns="http://www.w3.org/1999/xhtml">
			<head>

				<link href='http://fonts.googleapis.com/css?family=PT+Sans'
					rel='stylesheet' type='text/css' />
				<link rel="stylesheet" type="text/css" href="resources/css/simplegrid.css" />
				<link rel="stylesheet" type="text/css" href="resources/css/andel.css" />
				<script src="resources/js/jquery-1.10.2.min.js"></script>
				<script src="resources/js/andel.js"></script>
				<title>
					<xsl:value-of select="page/@title" />
				</title>

				<xsl:apply-templates select="page/header/*" />

			</head>
			<body>
				<div class="grid grid-pad">
					<div class="col-1-1">
						<div id="header" class="col-4-12">
							<h2>Andel</h2>
							<p>lets share...</p>
						</div>
						
						<div class="col-8-12">
							<span style="float:right;">
								<img src="resources/img/person.gif" title="Login" />
								&#160;<xsl:value-of select="page/@user" />
							</span>
							
						</div>
					</div>	
						<div class="col-4-12">
							<div id="localnav ">
								<xsl:apply-templates select="page/navigation/*" />
							</div>
						</div>

						<div class="col-8-12">
							<div id="content">
								<xsl:apply-templates select="page/content/*" />
							</div>
						</div>


				</div>
			</body>
		</html>
	</xsl:template>


	<xsl:template match="*">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="." />
 				</xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>

	<xsl:template match="processing-instruction()">
		<xsl:copy />
	</xsl:template>

</xsl:stylesheet>
