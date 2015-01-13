xquery version "1.0-ml"; 
declare namespace xdmp="http://marklogic.com/xdmp";  
declare namespace search="http://marklogic.com/appservices/search";
declare namespace rapi="http://marklogic.com/rest-api";

declare namespace xf="http://www.w3.org/2002/xforms"; 
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsltforms="http://www.agencexml.com/xsltforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace andel="http://tingenek.me/andel";

let $dummy := xdmp:set-response-content-type("application/xml")

(: CHANGE THIS TO TALK TO A DIFFERENT REST SERVER :)
let $rest_server := "localhost:8005"

(: Get Current User :)
let $myuser:= (xdmp:get-current-user(),'anonymous')[1] 
 
let $input :=
<page title="Andel - Search" user="{$myuser}">
	<header>
		<xf:model id="m_andel">
		
			<!-- User -->	
			<xf:instance id="security" xmlns="http://tingenek.me/andel">
				<andel:security>
					<andel:user>{xdmp:get-current-user()}</andel:user>
				</andel:security>
			</xf:instance>

			<!-- Parameters for Search -->
			<xf:instance id="search_params" xmlns="">
				<data>
					<start>1</start>
					<pageLength>10</pageLength>
										
					<!-- Template for facets -->
					<search:range-constraint-query>
						<search:constraint-name>ward</search:constraint-name>
						<search:value>Bede</search:value>
					</search:range-constraint-query>
				
					<!-- template for category/collection -->
					<search:collection-query>
    					<search:uri>place</search:uri>
  					</search:collection-query>
  					
            	</data>
					 
			</xf:instance>

	
		<!-- MarkLogic Structured Query -->
			<xf:instance id="search_control">
				<search:search>
					<search:query>
						<search:qtext></search:qtext>
						<search:and-query>
						<!-- Filters in Here -->
						</search:and-query>
					</search:query>
					<search:options>
						<search:return-metrics>false</search:return-metrics>
						<search:transform-results apply="raw">
						</search:transform-results>
						
						<search:sort-order type="xs:string"
							collation="http://marklogic.com/collation/" direction="ascending">
							<search:element ns="" name="modified" />
						</search:sort-order>
						
						<search:constraint name="category">
							<search:collection />
						</search:constraint>
						
						<search:constraint name="tag">
							<search:range type="xs:string" facet="true">
								<search:element ns="" name="tag" />
								<search:facet-option>frequency-order</search:facet-option>
        						<search:facet-option>descending</search:facet-option>
        						<search:facet-option>limit=10</search:facet-option>
							</search:range>
						</search:constraint>
						
						<search:constraint name="owner">
							<search:range type="xs:string" facet="true">
								<search:element ns="" name="owner" />
								<search:facet-option>frequency-order</search:facet-option>
        						<search:facet-option>descending</search:facet-option>
        						<search:facet-option>limit=10</search:facet-option>
					
							</search:range>
						</search:constraint>
						
						<search:constraint name="shared"> 
						<search:range type="xs:date" facet="true">
    						<search:element ns="" name="modified"/> 					
    						<search:computed-bucket lt="-P1Y" anchor="start-of-year" name="older">older</search:computed-bucket>
    						<search:computed-bucket lt="P1Y" ge="P0Y" anchor="start-of-year" name="year">year</search:computed-bucket>
    						<search:computed-bucket lt="P1M" ge="P0M" anchor="start-of-month" name="month">month</search:computed-bucket>
    						<search:computed-bucket lt="P1D" ge="P0D" anchor="start-of-day" name="today">today</search:computed-bucket>
    						<search:facet-option>descending</search:facet-option>
    					</search:range>	
    					</search:constraint>	
    										
					</search:options>
				</search:search>
			</xf:instance>

			<!-- Search Results in here.. -->
			<xf:instance id="results" xmlns="">
				<search:response>
				</search:response>
			</xf:instance>

			<!-- Search direct via REST. Needs Apache Proxy 
			<xf:submission id="get_results" method="post"
				ref="instance('search_control')" replace="instance" instance="results"
				omit-xml-declaration="yes">
				<xf:resource
					value="concat('/andel_rest/v1/search?start=',instance('search_params')/start,'&amp;pageLength=',instance('search_params')/pageLength)" />
				<xf:action ev:event="xforms-submit-done">
				</xf:action>
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="event('response-reason-phrase')" />
					</xf:message>
				</xf:action>
			</xf:submission>
			-->
			
			<!-- Search via proxy XQuery -->
			<xf:submission id="get_results" action="util/proxy.xqy"
				omit-xml-declaration="yes" method="post" replace="instance" instance="results" ref="instance('search_control')">
				<xf:header>
					<xf:name>AndelStart</xf:name>
        			<xf:value value="instance('search_params')/start"/>
    			</xf:header>
    			<xf:header>
					<xf:name>AndelREST</xf:name>
        			<xf:value>{$rest_server}</xf:value>
    			</xf:header>
				<xf:action ev:event="xforms-submit-done"/>
				
				<xf:action ev:event="xforms-submit-error">
					<xf:message>
						<xf:output value="concat('Error: ',event('response-reason-phrase'))" />
					</xf:message>
				</xf:action>
			</xf:submission>
	
			<!-- JS Target -->	
			<xf:action ev:event="add_tag">
				<xf:setvalue ref="instance('search_params')/search:range-constraint-query/search:constraint-name"
				value="'tag'" />
				<xf:setvalue
				ref="instance('search_params')/search:range-constraint-query/search:value"
				value="event('tagname')" />
				<xf:insert
				context="instance('search_control')/search:query/search:and-query"
				origin="instance('search_params')/search:range-constraint-query" />
				<xf:setvalue ref="instance('search_params')/start"
					value="'1'" />
				<xf:send submission="get_results" />
			</xf:action>

			<!-- Initial conditions on load -->
			<xf:action ev:event="xforms-ready">
			 <xf:load resource="javascript:initsl();"/>
					<xf:send submission="get_results" />
			</xf:action>
        
	
		</xf:model>

	</header>

	<!-- Left navigation -->
	<navigation>
		<!-- Filter Settings hidden if empty -->
		<xf:group ref="instance('search_control')/search:query/search:and-query[count(*) >=1]" id="filter_list">
			<div class="facet, filter">
				<h3>
					Filters
					<small>[click to remove]</small>
				</h3>
				<hr />
				<!-- Normal Facets -->
				<ul class="localnav">
					<xf:repeat nodeset="search:range-constraint-query" id="filters">
						<li>
							<xf:trigger appearance="minimal">
								<xf:label>
									<xf:output
										value="concat(search:constraint-name,'=',search:value)" />
								</xf:label>
								<!-- Delete query node for this facet -->
								<xf:action ev:event="DOMActivate">
									<xf:delete
										nodeset="instance('search_control')/search:query/search:and-query/search:range-constraint-query"
										at="index('filters')" />
									<xf:send submission="get_results" />
								</xf:action>
							</xf:trigger>
						</li>
					</xf:repeat>
					
					<!-- Collections -->
					<xf:repeat nodeset="search:collection-query" id="filters2">
						<li>
							<xf:trigger appearance="minimal">
								<xf:label>
									<xf:output
										value="concat('category','=',search:uri)" />
								</xf:label>
								<!-- Delete query node for this facet -->
								<xf:action ev:event="DOMActivate">
									<xf:delete
										nodeset="instance('search_control')/search:query/search:and-query/search:collection-query"/>
									<xf:send submission="get_results" />
								</xf:action>
							</xf:trigger>
						</li>
					</xf:repeat>
				</ul>
			</div>
		</xf:group>
		
		<!-- Filtering -->
		<xf:group ref="instance('results')" navindex="0" id="facets">
		
			<!-- Collections - special handling and icons -->		
			<xf:group ref="search:facet[@type = 'collection']">
			<div class="facet">
					<h3>
						<xf:output value="@name" />
					</h3>
					<hr />	
					<ul class="localnav">
					<xf:repeat nodeset="search:facet-value">			
					<li>				
						<xf:trigger appearance='minimal'>
							<xf:label><img style="float:left;" src="resources/img/{{.}}.gif" title="{{.}}" />
						&#160;
						<xf:output value="concat(.,'&nbsp;(',@count,')')" /></xf:label>
							<xf:action ev:event="DOMActivate">
							<xf:setvalue
							ref="instance('search_params')/search:collection-query/search:uri"
							value="context()/text()" />
							<xf:insert
							context="instance('search_control')/search:query/search:and-query"
							origin="instance('search_params')/search:collection-query" />
							<xf:send submission="get_results" />
							</xf:action>						
						</xf:trigger>

					</li>
					</xf:repeat>
					</ul>
			</div>	
			</xf:group>	
			
			<!-- Other Facets -->		
			<xf:repeat nodeset="search:facet[@type != 'collection']">
				<div class="facet">
					<h3>
						<xf:output value="@name" />
					</h3>
					<hr />
					<ul class="localnav">
						<xf:repeat nodeset="search:facet-value">
							<li>
								<xf:trigger appearance="minimal">
									<xf:label>
										<xf:output value="concat(.,'&nbsp;(',@count,')')" />
									</xf:label>
									
										<xf:action ev:event="DOMActivate">
											<xf:setvalue
												ref="instance('search_params')/search:range-constraint-query/search:constraint-name"
												value="context()/../@name" />
											<xf:setvalue
												ref="instance('search_params')/search:range-constraint-query/search:value"
												value="context()/text()" />
											<xf:insert
												context="instance('search_control')/search:query/search:and-query"
												origin="instance('search_params')/search:range-constraint-query" />
											<xf:send submission="get_results" />
										</xf:action>

								
								</xf:trigger>
							</li>
						</xf:repeat>
					</ul>
				</div>
			</xf:repeat>
		</xf:group>

	</navigation>

	<!-- Main Content -->
	<content>
		<xf:input ref="instance('search_control')/search:query/search:qtext"
			incremental="false" class="inbox">
			<xf:label>Search: </xf:label>
			<!-- Capture RTN -->
			<xf:action ev:event="DOMActivate"
				if="string-length(.) &gt;= 3 or string-length(.) = 0">
				<xf:setvalue ref="instance('search_params')/start"
					value="'1'" />
				<xf:send submission="get_results" />
			</xf:action>
			<!-- Capture ESC -->
			<xf:action ev:event="keydown" if="event('keyCode') = 27">
				<xf:setvalue ref="instance('search_control')/search:query/search:qtext"
					value="''" />
			<xf:send submission="get_results" />		
			</xf:action>

		</xf:input>
		<span class="btn_new">
		<a href="share.xqy" target="_andel">New Share</a>
		</span>
		
				
		<!-- Results -->	
		<xf:group ref="instance('results')" navindex="0" id="result_list">
			<div id="result_btns">
				<span>
					<xf:trigger id="list_next">
						<xf:label>Next</xf:label>
						<xf:action ev:event="DOMActivate"
							if="context()/@start + context()/@page-length &lt; context()/@total">
							<xf:setvalue ref="instance('search_params')/start"
								value="context()/@start + context()/@page-length" />
							<xf:send submission="get_results" />
						</xf:action>
					</xf:trigger>
					<xf:trigger id="list_prev">
						<xf:label>Prev</xf:label>
						<xf:action ev:event="DOMActivate"
							if="context()/@start &gt; context()/@page-length">
							<xf:setvalue ref="instance('search_params')/start"
								value="context()/@start - context()/@page-length" />
							<xf:send submission="get_results" />
						</xf:action>
					</xf:trigger>
				</span>
				
				<span class="result_head">
					<xf:output value="if(count(search:result),'Results','No Results')" />
				</span>
				
				<span>
				<!-- Sort (resets start) -->
				<xf:select1 ref="instance('search_control')/search:options/search:sort-order/search:element/@name">
					<xf:item><xf:label>date</xf:label><xf:value>modified</xf:value></xf:item>
					<xf:item><xf:label>subject</xf:label><xf:value>subject</xf:value></xf:item>
					<xf:item><xf:label>summary</xf:label><xf:value>summary</xf:value></xf:item>
					<xf:item><xf:label>owner</xf:label><xf:value>owner</xf:value></xf:item>
					<xf:action ev:event="xforms-value-changed">
						<xf:setvalue ref="instance('search_params')/start" value="'1'" />
						<xf:send submission="get_results" />
					</xf:action>
				<!-- Sort Order(resets start) -->	
				</xf:select1>
					
				<xf:select1 ref="instance('search_control')/search:options/search:sort-order/@direction">
					<xf:item><xf:label>ascending</xf:label><xf:value>ascending</xf:value></xf:item>
					<xf:item><xf:label>descending</xf:label><xf:value>descending</xf:value></xf:item>
					<xf:action ev:event="xforms-value-changed">
						<xf:setvalue ref="instance('search_params')/start" value="'1'" />
						<xf:send submission="get_results" />
					</xf:action>
				</xf:select1>		
				</span>
				<span class="result_totals">
					<xf:output
						value="if(count(search:result),concat('Items ',@start,'&#8594;',if(@total &lt; @start + @page-length,@total,@start + @page-length -1),' of ',@total),'No Results')" />
				</span>
			</div>
			<table id="result_table">
				<thead>
					<tr>
						<th>#</th>
						<th>Subject</th>
						<th>Summary</th>
					</tr>
				</thead>
				<tbody>
					<xf:repeat nodeset="search:result/document">
						<tr>
							<td>
								<img src="resources/img/{{category}}.gif" title="{{@category}}" />
							</td>
							<td style="width:20%">
								<!-- Edit this doc -->
								<a href="{{link}}" target="_andel"><xf:output value="subject" /></a>
							</td>
							<td>
								<xf:output value="summary" mediatype="application/xhtml+xml"/><br/>
								<span><small><xf:output value="concat('[ ',modified, ' by ',owner,']')" />&#160;
								<a href="share.xqy?id={{../@uri}}" target="_andel">edit</a></small></span>
							</td>
						</tr>
					</xf:repeat>
				</tbody>
			</table>
	</xf:group>
	</content>
</page>

return
xdmp:xslt-invoke("resources/xslt/xml2html.xsl",document{$input})