xquery version "1.0";

module namespace cardfun="http://www.spyker.com/cardFunctions";

declare function cardfun:endingChipCount2($hand as node()) as xs:integer {
    return 1;
(:
    let
        $startingChipCount := $hand/@chipCount,
        $calls := $hand//call[@self = 'true'],
        $bets := $hand//bet[@self = 'true],
        $raises := $hand//raises[@self = 'true'],
        $blinds := $hand//smallblind[@self = 'true'] | $hand//bigblind[@self = 'true']
        $callsCost := sum($calls/ammount),
        $bets := sum($bets/ammount),
        raises are tricky as they are stateful in how much they represent
        $raises := sum(
        
    let $allGames := collection('/db/poker')//hands,
    $trace2 := trace("blah", "blah")
    return
        for $ii in $allGames return
            <hands gamename="{ $ii/@gamename }" gamenum="{ $ii/@gamenum}"/>
:)
};

declare function cardfun:perActionSum($actions as node()*, $smallBlind as node(), $bigBlind as node()) as xs:integer {
    let
        $lastRaise := $actions/raise[last()]
        
};

declare function cardfun:endingChipCountForHand($hand as node()) as xs:integer {
    let
        $startingChipCount := $hand/@chipCount,
        $smallBlind := $hand/smallBlind,
        $bigBlind := $hand/bigBlind,
        (: Need to handle antes :)        
        $allActionsPreFlop := $hand//node() >> $hand/hole << $hand/flop,
        $allActionsOnFlop := $hand/node() >> $hand/flop << $hand/turn,
        $allActionsOnTurn := $hand/node() >> $hand/turn << $hand/river,
        $allActionsOnRiver := $hand/node() >> $hand/river,
        $sumOfAmmountPreFlop := cardfun:perActionSum($allActionsPreFlop, $smallBlind, $bigBlind)
};