xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
(: Import data from resources folder :)
let $dummy := xdmp:set-response-content-type("application/xml")

(: Files are relative to modules root in resources/data/[user] :)
let $base := xdmp:modules-root() || 'resources/data/'
let $users := for $d in xdmp:filesystem-directory($base)/dir:entry/dir:pathname/text() where substring-after($d,".") = "" return $d  
let $files:= for $f in xdmp:filesystem-directory($users)/dir:entry/dir:pathname return $f/text()
let $andel:= for $x in $files where substring-after($x,".") = "xml" return xdmp:document-get($x)

(: Write them out in /andel/[owner]/*.xml with collection as category:)
let $results:= for $doc in $andel
  let $id := $doc/document/id/text()
  let $owner := string($doc/document/owner/@id)
  let $category := if($id='me') then ($doc/document/category/text(),'user') else ($doc/document/category/text())
  let $folder := concat("/andel/",$owner,"/",$id,".xml")
  return (<file>{$folder}</file>,xdmp:document-insert($folder,$doc,(),$category))
    
return <results>{$results}</results>