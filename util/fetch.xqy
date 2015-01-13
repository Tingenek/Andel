xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace search="http://marklogic.com/appservices/search";

let $empty_doc := 
		<document>
			<id></id>
			<owner id=""></owner>
			<link></link>
			<category>link</category>
			<subject></subject>
			<summary></summary>
		</document>

(: Get the document :)
let $myurl :=xdmp:get-request-field("url","/")
(: Get the action :)
let $myaction := xdmp:get-request-field("action","fetch")

(: Fetch/Delete :)
let $return_doc := if(not(fn:doc-available($myurl))) 
	then $empty_doc
	else (
	if ($myaction = "delete") 
	then (xdmp:document-delete($myurl),$empty_doc)
	else fn:doc($myurl))
		
return $return_doc
