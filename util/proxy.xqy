xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace search="http://marklogic.com/appservices/search";

(: Highlight #tags in summary :)
(: Recursive typeswitch code shamelessly poached from 
http://blog.davidcassel.net/2014/01/recursive-descent-in-xquery :)
declare function local:change($node)
{
  typeswitch($node)
  case element(summary) return
   element {fn:node-name($node)} {cts:highlight($node, "#*", concat('&lt;a href="" class="tag"&gt;',$cts:text,'&lt;/a&gt;'))/node()}
  case element() return 
    element { fn:node-name($node) } {
      $node/@*,
      $node/node() ! local:change(.)
    }
  default return $node
};


(: Proxy a request to a REST server on a different port :)

let $doc := document {xdmp:get-request-body()}
let $start := xdmp:get-request-header("AndelStart","10")
let $rest_server := xdmp:get-request-header("AndelREST","localhost:8005")

let $uri := concat("http://",$rest_server,"/v1/search?start=",$start)

let $options := <options xmlns="xdmp:http">
                   <!--
                   <authentication>
                       <username></username>
                       <password></password>
                    </authentication>
                    -->
                    <headers>
                       <content-type>application/xml</content-type>
                    </headers>
                   </options>
				
let $httppost:= xdmp:http-post($uri,$options,text{xdmp:quote($doc)})
                    
return local:change($httppost[2]/node())                 
                    
                    
