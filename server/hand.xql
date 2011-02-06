xquery version "1.0";

import module namespace json="http://www.json.org";
import module namespace pokerdbservices="http://www.spyker.com/pokerDBServices" at "pokerdb-services.xql";

let
    $gamenum := xs:integer(request:get-parameter('gamenum', ())),
    $handnum := xs:integer(request:get-parameter('handnum', ())) + 1,
    $xml :=
<root>
{
    pokerdbservices:getHand($gamenum, $handnum)
}
</root>

return json:contents-to-json($xml)
