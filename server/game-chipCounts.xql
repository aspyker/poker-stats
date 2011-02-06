xquery version "1.0";

import module namespace json="http://www.json.org";
declare namespace request = "http://exist-db.org/xquery/request";

import module namespace pokerdbservices="http://www.spyker.com/pokerDBServices" at "pokerdb-services.xql";


let
    (: TODO - not hardcoded, but from url / param :)
    $gamenum := xs:integer(request:get-parameter('gamenum', ())),
    $chipCounts := pokerdbservices:getChipCountForGame($gamenum),
    $gameSummary := pokerdbservices:getGameSummary($gamenum),
    $xml :=
<root>
{
    for $ii in $chipCounts return
        <items>{ xs:integer($ii) }</items>
}
        <startingChipCount>{ data($gameSummary/@startingChipCount) }</startingChipCount>
        <endingChipCount>{ data($gameSummary/@endingChipCount) }</endingChipCount>
        <numberOfHands>{ data($gameSummary/@numberOfHands) }</numberOfHands>
        <numberOfAllIns>{ data($gameSummary/@numberOfAllIns) }</numberOfAllIns>
        <percentOfFlopsSeen>{ data($gameSummary/@percentOfFlopsSeen) }</percentOfFlopsSeen>
        <percentOfFlopsSeenWhenInBigBlind>{ data($gameSummary/@percentOfFlopsSeenWhenInBigBlind) }</percentOfFlopsSeenWhenInBigBlind>
        <percentOfFlopsSeenWhenInSmallBlind>{ data($gameSummary/@percentOfFlopsSeenWhenInSmallBlind) }</percentOfFlopsSeenWhenInSmallBlind>
        <percentOfFlopsSeenWhenInOtherPositions>{ data($gameSummary/@percentOfFlopsSeenWhenInOtherPositions) }</percentOfFlopsSeenWhenInOtherPositions>
</root>

return json:xml-to-json($xml)