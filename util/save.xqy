xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace s="http://www.w3.org/2005/xpath-functions";

let $body := xdmp:get-request-body()
let $owner := string($body/document/owner/@id)
let $id := ($body/document/id/text(), fn:generate-id($body))[1] 
let $category := if($id='me') then 
($body/document/category/text(),'user') 
else ($body/document/category/text())
let $summary := $body/document/summary/text()

let $b := <document>
<id>{$id}</id>
<modified>{fn:adjust-date-to-timezone(fn:current-date(),())}</modified>
{$body/node()/*[not(self::id or self::modified or self::tags)]}
<tags>
{for $x in fn:analyze-string($summary, "[#][A-Za-z0-9]+","m")/s:match
return <tag>{$x/text()}</tag>
}
</tags>
</document>

let $folder := concat("/andel/",$owner,"/",$id,".xml")
(: let $d := xdmp:log($folder) :)

let $save := xdmp:document-insert($folder,$b,(),$category)

return $b
