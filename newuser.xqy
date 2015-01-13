xquery version "1.0-ml"; 
declare namespace xdmp="http://marklogic.com/xdmp";  
declare namespace search="http://marklogic.com/appservices/search";
declare namespace rapi="http://marklogic.com/rest-api";

declare namespace xf="http://www.w3.org/2002/xforms"; 
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsltforms="http://www.agencexml.com/xsltforms";
declare namespace ev="http://www.w3.org/2001/xml-events";

let $today:= xs:date(fn:current-date())

(: Get Current User :)
let $myuser:= (xdmp:get-current-user(),'anonymous')[1] 
 
let $input :=
<page title="Andel - New User" user="{$myuser}">
	<header>
		<xf:model>
									
		<xf:instance id="andel" xmlns="">
		<document>
			<id>me</id>
			<owner id="{$myuser}"></owner>
			<link></link>
			<category>person</category>
			<subject></subject>
			<summary></summary>
		</document>
		</xf:instance>
		
		<xf:submission id="save_me" action="util/save.xqy"
				omit-xml-declaration="yes" method="post" replace="instance" ref="instance('andel')">
				<xf:action ev:event="xforms-submit-done">	
					<xf:message>
						<xf:output value="concat('Saved: ',event('response-reason-phrase'))" />
					</xf:message>
					
					<!-- Jump to index -->
	 				<xf:load resource="index.xqy" show="replace"/>
      			
	
				</xf:action>
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="concat('Error: ',event('response-reason-phrase'))" />
					</xf:message>
				</xf:action>
		</xf:submission>
		
		<!-- BINDINGS -->
			<xf:bind nodeset="instance('andel')/subject" required="true()" />
			<xf:bind nodeset="instance('andel')/summary" required="true()" />
			<xf:bind nodeset="instance('andel')/link" required="false()" />
			<xf:bind nodeset="instance('andel')/category" readonly="true()" />
			<xf:bind nodeset="instance('andel')/owner" calculate="../subject"/>
		
			<!-- ANY SETUPS -->
			<xf:action ev:event="xforms-ready">
			</xf:action>
			
			
			
		</xf:model>

	</header>
	
	<!-- Left navigation -->
	<navigation>
		<div class="localnav">
				<h2>New User</h2>
				<p>Hello. I can't find a Person with your id ({$myuser})<br/>
				Please enter your full name and a bit about yourself.</p>
				<br/>
				<h4>What goes where?</h4>
				<dl>
				<dd>Subject:</dd>
				<dt>Your full name, e.g. <cite>Fred Bloggs</cite></dt>
				<dd>Link:</dd>
				<dt>It's optional but somewhere people can find out a bit more about you. Say your Twitter feed/Blog page.
				</dt>
				<dd>Summary:</dd>
				<dt>A description of who you are, where you work and any contact information you can responsibly share.<br/>
				Remember you can put hashtags in the text like #headoffice, #cpteam to help searching later.
				</dt>
				</dl>
		</div>	
		
	</navigation>

	<!-- Main Content -->
	<content>
	<xf:group ref="instance('andel')" id="shead" class="blockform" >
		<xf:output value="owner"><xf:label>Owner: </xf:label></xf:output>
		<xf:input ref="subject" incremental="false"><xf:label>Subject: </xf:label></xf:input>
		<xf:select1 appearance="full" ref="category" incremental="false">
		<xf:label>Category: </xf:label>	
		<xf:item><xf:label>Link</xf:label><xf:value>link</xf:value></xf:item>
		<xf:item><xf:label>Document</xf:label><xf:value>document</xf:value></xf:item>
		<xf:item><xf:label>Note</xf:label><xf:value>note</xf:value></xf:item>
		<xf:item><xf:label>Person</xf:label><xf:value>person</xf:value></xf:item>
		<xf:item><xf:label>Place</xf:label><xf:value>place</xf:value></xf:item>
		<xf:item><xf:label>Image</xf:label><xf:value>image</xf:value></xf:item>
		<xf:item><xf:label>Event</xf:label><xf:value>event</xf:value></xf:item>
		<xf:action ev:event="xforms-value-changed">
				<xf:toggle><xf:case value="concat('section_',../category)" /></xf:toggle>
		</xf:action>
		</xf:select1>
		<xf:input ref="link" incremental="false"><xf:label>Links To: </xf:label></xf:input>
		<xf:textarea ref="summary" incremental="false"><xf:label>Summary: </xf:label></xf:textarea>
		<hr/>		
		<xf:trigger id="new">
				<xf:label>Share This</xf:label>
				<xf:action if="is-valid(*) = true()" ev:event="DOMActivate">
					<xf:send submission="save_me" />
				</xf:action>
		</xf:trigger>
		</xf:group>
	</content>
</page>

return (xdmp:set-response-content-type("application/xml"),
xdmp:xslt-invoke("resources/xslt/xml2html.xsl",document{$input}))