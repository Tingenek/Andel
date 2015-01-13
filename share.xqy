xquery version "1.0-ml"; 
declare namespace xdmp="http://marklogic.com/xdmp";  
declare namespace search="http://marklogic.com/appservices/search";
declare namespace rapi="http://marklogic.com/rest-api";

declare namespace xf="http://www.w3.org/2002/xforms"; 
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsltforms="http://www.agencexml.com/xsltforms";
declare namespace ev="http://www.w3.org/2001/xml-events";

let $today:= xs:date(fn:current-date())

let $myuser:= (xdmp:get-current-user(),'anonymous')[1] 
let $mypersondoc := concat("/andel/",$myuser,"/me.xml")
let $myname := if(fn:doc-available($mypersondoc) ) then doc($mypersondoc)/document/subject/text() else xdmp:redirect-response(concat("newuser.xqy?user=",$myuser)) 

(: Form has doc id? :)
let $mydocurl :=xdmp:get-request-field("id","/")
		 
(:create the XForm :)	 
let $input :=
<page title="Andel - Share" user="{$myuser}">
	<header>
		<xf:model id="m_andel">
		
		<!-- Set some simple types -->
		<xs:schema>
        <xs:simpleType name="mySubject" >
          <xs:restriction base="xf:string">
            <xs:maxLength value="50"/>
          </xs:restriction>
        </xs:simpleType>
  
         <xs:simpleType name="mySummary" >
          <xs:restriction base="xf:string">
            <xs:maxLength value="1000"/>
          </xs:restriction>
        </xs:simpleType>
         
		<xs:simpleType name="myLink">
  			<xs:restriction base="xs:anyURI">
    			<xs:pattern value="http:.*"/>
  			</xs:restriction>
		</xs:simpleType>
      </xs:schema>
		
		<xf:instance id="user" xmlns="">
		{doc($mypersondoc)}
		</xf:instance>
		
		<xf:instance id="security" xmlns="">	
			<data>
			<user>{xdmp:get-current-user()}</user>
			<fullname>{$myname}</fullname>
			<url>{$mydocurl}</url>
			<action>load</action>
			</data>	
		</xf:instance>
		
		<xf:instance id="andel" xmlns="">
		<data/>
		</xf:instance>
		
		<!-- SUBMISSIONS -->
		
		<!-- Save/Update -->
		<xf:submission id="save_me" action="util/save.xqy"
				omit-xml-declaration="yes" method="post" replace="instance" ref="instance('andel')">
				<xf:action ev:event="xforms-submit-done">
					<xf:message>
						<xf:output value="concat('Saved: ',event('response-reason-phrase'))" />
					</xf:message>
				</xf:action>
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="concat('Error: ',event('error-type'))" />
					</xf:message>
				</xf:action>
		</xf:submission>
		
		<!-- Delete -->
		<xf:submission id="delete_me" action="util/delete.xqy"
				omit-xml-declaration="yes" method="get" replace="none" ref="instance('andel')">
				<xf:action ev:event="xforms-submit-done">
					<xf:message>
						<xf:output value="concat('Deleted: ',event('response-reason-phrase'))" />
					</xf:message>
				</xf:action>
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="concat('Error: ',event('error-type'))" />
					</xf:message>
				</xf:action>
		</xf:submission>
		
		<!-- Fetch -->
		<xf:submission id="fetch_me" action="util/fetch.xqy"
			omit-xml-declaration="yes" method="get" replace="instance" instance="andel" ref="instance('security')">
				<xf:action ev:event="xforms-submit-done" if="instance('andel')/owner/@id = ''">	
				<!-- Empty so set owner -->	
				<xf:setvalue ref="instance('andel')/owner/@id" value="instance('security')/user"/>
				<xf:setvalue ref="instance('andel')/owner" value="instance('security')/fullname"/>			
				</xf:action>
				<xf:action ev:event="xforms-submit-done">	
				<xf:toggle><xf:case value="concat('section_',instance('andel')/category)" /></xf:toggle>			
				</xf:action>
			
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="concat('Error: ',event('error-type'))" />
					</xf:message>
				</xf:action>
		</xf:submission>
			
		
		<!-- BINDINGS -->
			<xf:bind nodeset="instance('andel')/subject" required="true()" type="mySubject"/>
			<xf:bind nodeset="instance('andel')/summary" required="true()" type="mySummary"/>
			<xf:bind nodeset="instance('andel')/link" required="not(../category='note')" type="mylink" />
			
			
		<!-- SETUPS -->
			<xf:action ev:event="xforms-ready">
			<xf:send submission="fetch_me" />
			</xf:action>
			
		</xf:model>

	</header>
	
	<!-- Left navigation -->
	<navigation>
		<xf:switch class="localnav">
			<!-- HELP SECTION / PER TYPE of SHARE-->
				<xf:case id="section_link">
				<h2>Link</h2>
				<p>Lets you share pages, links and downloadable content like pdfs from internal and external web sites.
				</p><br/>
				<h4>What goes where?</h4>
				<dl>
				<dd>Subject:</dd>
				<dt>A (short) title for your page, i.e. <cite>MoJ Daily Court Lists</cite></dt>
				<dd>Links To:</dd>
				<dt>The full link to the page or resource, i.e. <a href="http://www.justice.gov.uk/courts/court-lists">http://www.justice.gov.uk/courts/court-lists</a>
				<br/>Note. You can right-click on a link to get it's address.
				</dt>
				<dd>Summary:</dd>
				<dt>A description of the resource. Keep it brief - think index card; maybe 10 lines max.<br/>
				Remember you can put hashtags in the text like #victim or #moj to identify this share for searching later.
				</dt>
				</dl>
				</xf:case>
				<xf:case id="section_note">
				<h2>Note</h2>
				<p>Notes don't point anywhere. PostIt&#174; notes for bits of information.</p><br/>
				<h4>What goes where?</h4>
				<dl>
				<dd>Subject:</dd>
				<dt>A <emp>short</emp> title for you note</dt>
				<dd>Links To:</dd>
				<dt>Opional. Use it if you want to though.</dt>
				<dd>Summary:</dd>
				<dt>The text for your note. You've only got about 10 lines, so please be concise.</dt>
				</dl>
				</xf:case>
				<xf:case id="section_person">
				<h2>Person</h2>
				<p>Lets you share information about people.<br/>Remember: No <u>personal</u> information. 
				</p><br/>
				<h4>What goes where?</h4>
				<dl>
				<dd>Subject:</dd>
				<dt>Full name, e.g. <cite>Fred Bloggs</cite></dt>
				<dd>Links To:</dd>
				<dt>If it's a work entry, then use their login name, e.g. <cite>fredbloggsmlw</cite>.
				If they're external, it's optional but something like their Twitter feed/Blog page might be useful.
				</dt>
				<dd>Summary:</dd>
				<dt>A description of who they are, where they work and any contact information you can responsibly share.<br/>
				Remember you can put hashtags in the text like #headoffice, #police, #cpunit to identify or group this person for searching later.
				</dt>
				</dl>
				</xf:case>
				<xf:case id="section_place">
				<h2>Place</h2>
				<p>Lets you share information about places: offices, train stations, airports or your favorite coffee shop. 
				</p><br/>
				<h4>What goes where?</h4>
				<dl>
				<dd>Subject:</dd>
				<dt>Name of the place, e.g. <cite>King Edward House</cite></dt>
				<dd>Links To:</dd>
				<dt>A good place for a Google Map link perhaps?
				</dt>
				<dd>Summary:</dd>
				<dt>What it is, opening hours, contact information, web-site etc.<br/>
				Remember you can put hashtags in the text like #headoffice, #coffeshop to identify or group this person for searching later.
				</dt>
				</dl>
				</xf:case>
			</xf:switch>		
		
		
		
	</navigation>

	<!-- Main Content -->
	<content>

	<xf:group ref="instance('andel')" id="shead" class="blockform" >
	<h2><xf:output value="concat(owner,' (',owner/@id,') is sharing:')"/></h2>
		<xf:output value="if(id='','&#160;New Share',id)"><xf:label>Id: </xf:label></xf:output>
		<span class="btn_delete"><xf:trigger id="delete" >
				<xf:label>Delete</xf:label>
				<xf:action ev:event="DOMActivate">
					<xf:setvalue ref="instance('security')/action" value="'delete'"/>
					<xf:send submission="fetch_me" />
				</xf:action>
		</xf:trigger>
		</span>
		<xf:input ref="subject" incremental="false"><xf:label>Subject: </xf:label></xf:input>
		<xf:select1 appearance="full" ref="category" incremental="false">
		<xf:label>Category: </xf:label>	
		<xf:item><xf:label>Link</xf:label><xf:value>link</xf:value></xf:item>
		<xf:item><xf:label>Person</xf:label><xf:value>person</xf:value></xf:item>
		<xf:item><xf:label>Place</xf:label><xf:value>place</xf:value></xf:item>
		<xf:item><xf:label>Note</xf:label><xf:value>note</xf:value></xf:item>

		<xf:action ev:event="xforms-value-changed">
				<xf:toggle><xf:case value="concat('section_',../category)" /></xf:toggle>
		</xf:action>
		</xf:select1>
		<xf:input ref="link" incremental="false"><xf:label>Links To: </xf:label></xf:input>
		<xf:textarea ref="summary" incremental="false"><xf:label>Summary: </xf:label></xf:textarea>
		<xf:output value="modified"><xf:label>Last Saved: </xf:label></xf:output>
		   	
		</xf:group>
		<hr/>
		<!-- Save -->		
		<xf:trigger id="save">
				<xf:label>Save or Update</xf:label>
				<xf:action if="is-valid(instance('andel')) = true()" ev:event="DOMActivate">
					<xf:send submission="save_me" />
				</xf:action>
		</xf:trigger>
		
		<!-- New Share -->
		<xf:trigger id="new">
				<xf:label>New Share</xf:label>
				<xf:action ev:event="DOMActivate">
				<!-- Reset the current URL and reload -->
				<xf:setvalue ref="instance('security')/url" value="''"/>
				<xf:send submission="fetch_me" />
				</xf:action>
		</xf:trigger>
		<!-- Delete -->
		
		
	</content>
</page>

return (xdmp:set-response-content-type("application/xml"),
xdmp:xslt-invoke("resources/xslt/xml2html.xsl",document{$input}))