xquery version "1.0";

module namespace pdbservices="http://www.spyker.com/pokerDBServices";

declare namespace xmldb = "http://exist-db.org/xquery/xmldb"; 

declare function pdbservices:getAllGames() as node()* {
    let $allGames := collection('/db/poker')//hands,
    $trace2 := trace("blah", "blah")
    return
        for $ii in $allGames return
            <hands gamename="{ $ii/@gamename }" gamenum="{ $ii/@gamenum}"/>
};

declare function pdbservices:getChipCountForGame($gameNum as xs:integer) as xs:integer* {
    let
        $games := collection('/db/poker')//hands[@gamenum = $gameNum],
        $alert := if (count($games) > 1) then trace($gameNum, "***** Error:  more than one game with gamenum = ") else (),
        $game := $games[1],
        $chips := $game/hand/@chipCount,
        $lastHand := $game/hand[last()],
        $chipsPlusEnd := ($chips, $lastHand/seatsAfterHand/seat[@seatNum = $lastHand/@seatNumber]/@chips)
    return 
        $chipsPlusEnd    
};

declare function pdbservices:getGameSummary($gameNum as xs:integer) as node() {
    let
        $games := collection('/db/poker')//hands[@gamenum = $gameNum],
        $alert := if (count($games) > 1) then trace($gameNum, "***** Error:  more than one game with gamenum = ") else (),
        $game := $games[1],
        $startingChipCount := $game/hand[1]/@chipCount,
        $lastHand := $game/hand[last()],
        $seatNum := $game/hand[1]/seatNumber,
        $afterLastHandChips := $lastHand/seatsAfterHand/seat[@seatNum = $lastHand/@seatNumber]/@chips,
        $numberOfHands := count($game/hand),
        $numberOfAllIns := count($game/hand/node()[@self eq 'true'][@all-in eq 'true']),
        $percentOfFlopsSeen := pdbservices:getSeenFlopPercentage($game/hand),
        $percentOfFlopsSeenWhenInBigBlind := pdbservices:getSeenFlopPercentageWhenInBigBlind($game/hand),
        $percentOfFlopsSeenWhenInSmallBlind := pdbservices:getSeenFlopPercentageWhenInSmallBlind($game/hand),
        $percentOfFlopsSeenWhenInOtherPositions := pdbservices:getSeenFlopPercentageWhenInNonBlindsPosititon($game/hand)
    return
        <gameSummary
            startingChipCount="{ $startingChipCount }"
            endingChipCount="{ $afterLastHandChips }"
            numberOfHands="{ $numberOfHands }"
            numberOfAllIns="{ $numberOfAllIns }"
            percentOfFlopsSeen="{ $percentOfFlopsSeen }"
            percentOfFlopsSeenWhenInBigBlind="{ $percentOfFlopsSeenWhenInBigBlind }"
            percentOfFlopsSeenWhenInSmallBlind="{ $percentOfFlopsSeenWhenInSmallBlind }"
            percentOfFlopsSeenWhenInOtherPositions="{ $percentOfFlopsSeenWhenInOtherPositions }"
        />
};

declare function pdbservices:getHand($gameNum as xs:integer, $handNum as xs:integer) as node() {
    let
        $hand := collection('/db/poker')//hands[@gamenum = $gameNum]/hand[$handNum],
        $alert := if (count($hand) ne 1) then trace(($gameNum, $handNum), "***** Error:  gamenum and handnum error = ") else ()
    return 
        $hand    
};


declare function pdbservices:getSeenFlopPercentage($hands as node()*) as xs:integer {
    let
        $total := count($hands),
        $sawFlopHands :=
            for $hand in $hands
            (: TODO: what happens when no flop ? :)
            where not($hand/flop >> $hand/folds[@self = 'true']) 
            return
                $hand,
        $sawFlopCount := count($sawFlopHands)
    return
        if ($total = 0) then 0 else xs:integer(xs:double($sawFlopCount) div xs:double($total) * 100.0)
};

declare function pdbservices:getSeenFlopPercentageWhenInBigBlind($hands as node()*) as xs:integer {
    let $justThoseHands := $hands[bigblind/@self = 'true']
    return pdbservices:getSeenFlopPercentage($justThoseHands)
};

declare function pdbservices:getSeenFlopPercentageWhenInSmallBlind($hands as node()*) as xs:integer {
    let $justThoseHands := $hands[smallblind/@self = 'true']
    return pdbservices:getSeenFlopPercentage($justThoseHands)
};

declare function pdbservices:getSeenFlopPercentageWhenInNonBlindsPosititon($hands as node()*) as xs:integer {
    let $justThoseHands := $hands except ($hands[smallblind/@self = 'true'], $hands[bigblind/@self = 'true'])
    return pdbservices:getSeenFlopPercentage($justThoseHands)
};