xquery version "1.0";

import module namespace json="http://www.json.org";
import module namespace pokerdbservices="http://www.spyker.com/pokerDBServices" at "pokerdb-services.xql";

let $xml :=
<root>
    <identifier>gameid</identifier>
    <label>gamename</label>
{
    let
        $dbxml := pokerdbservices:getAllGames()
    for $ii in $dbxml//hands return    
        <items>
            <gamename>{ data($ii/@gamename) }</gamename>
            <gameid>{ data($ii/@gamenum) }</gameid>
        </items>
}
</root>

return json:contents-to-json($xml)
