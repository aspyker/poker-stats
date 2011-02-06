<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pp="http://www.spyker.com/pokerParser"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="pp xsl xs" version="2.0">
    
    <xsl:function name="pp:calculateMoneyPerStep" as="xs:integer">
        <xsl:param name="seatNum" as="xs:integer"/>
        <xsl:param name="currentMoney" as="xs:integer"/>
        <xsl:param name="steps" as="node()*"/>
        
        <xsl:choose>
            <xsl:when test="$steps[self::raises][last()]/@seatNum = $seatNum">
                <xsl:value-of select="$currentMoney + $steps[self::raises][last()]/@to"/>
            </xsl:when>
            <xsl:when test="$steps[self::raises][last()]/@seatNum = $seatNum">
                <xsl:value-of select="$currentMoney + $steps[self::bets][last()]/@ammount"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$currentMoney + sum($steps[@seatNum = $seatNum]/@ammount)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="pp:seatSummaryAfterHand" as="node()">
        <xsl:param name="startSeatSummary" as="node()"/>
        <xsl:param name="chipsPutIntoPot" as="node()"/>
        <xsl:param name="winners" as="node()*"/>
        
        <seatsAfterHand>
        <xsl:for-each select="$startSeatSummary/seat">
            <xsl:variable name="chipsInPot" select="data($chipsPutIntoPot/chipCountIntoPot/seat[@seatNum = current()/@seatNum]/@chipCountIntoPot)" as="xs:integer"/>
            <xsl:variable name="wonChips" select="sum($winners[@seatNum = current()/@seatNum]/@total)"/>
            <seat seatNum="{ @seatNum }" player="{ @player }" chips="{ @chips - $chipsInPot + $wonChips }"/>
        </xsl:for-each>
        </seatsAfterHand>
    </xsl:function>
    
    <xsl:function name="pp:seatSummaryAfterHand2" as="node()">
        <xsl:param name="hand" as="node()"/>
        <xsl:variable name="startingChipCount" select="$hand/@chipCount"/>
        <xsl:variable name="seats" select="$hand/seats"/>
        <xsl:variable name="actionsPreFlop"
            select="if ($hand/flop) then
                $hand/flop/preceding-sibling::*[not(local-name(.) = 'seats') and not(local-name(.) = 'hole')]
            else
                $hand/node()[not(local-name(.) = 'seats') and not(local-name(.) = 'hole')]"/>
        <xsl:variable name="actionsOnFlop"
            select="if ($hand/flop and not($hand/turn)) then
                        $hand/flop/following-sibling::*
                    else if ($hand/flop and $hand/turn) then
                        $hand/flop/following-sibling::*[$hand/turn >> .]
                    else ()"/><!-- must be not(flop) which means all actions were already handled -->
        <xsl:variable name="actionsOnTurn"
            select="if ($hand/turn and not($hand/river)) then
                        $hand/turn/following-sibling::*
                    else if ($hand/turn and $hand/river) then
                        $hand/turn/following-sibling::*[$hand//river >> .]
                    else ()"/><!-- must be not(turn) which means all actions were already handled -->                    
        <xsl:variable name="actionsOnRiver"
            select="if ($hand/river) then
                        $hand/river/following-sibling::*[not(local-name(.) = 'winner')]
                    else ()"/><!-- must be not(river) which means all actions were already handled -->
        <xsl:variable name="runningChipCountIntoPotPerSeatStart">
            <chipCountIntoPot>
                <xsl:for-each select="$seats/seat">
                    <seat seatNum="{ @seatNum }" chipCountIntoPot="0"/>
                </xsl:for-each>
            </chipCountIntoPot>
        </xsl:variable>
        <xsl:variable name="runningChipCountIntoPotPerSeatPreFlop">
            <chipCountIntoPot>
                <xsl:for-each select="$runningChipCountIntoPotPerSeatStart/chipCountIntoPot/seat">
                    <seat seatNum="{ @seatNum }" chipCountIntoPot="{ pp:calculateMoneyPerStep(current()/@seatNum, current()/@chipCountIntoPot, $actionsPreFlop) }"/>
                </xsl:for-each>
            </chipCountIntoPot>
        </xsl:variable>
        <xsl:variable name="runningChipCountIntoPotPerSeatOnFlop">
            <chipCountIntoPot>
                <xsl:for-each select="$runningChipCountIntoPotPerSeatPreFlop/chipCountIntoPot/seat">
                    <seat seatNum="{ @seatNum }" chipCountIntoPot="{ pp:calculateMoneyPerStep(current()/@seatNum, current()/@chipCountIntoPot, $actionsOnFlop) }"/>
                </xsl:for-each>
            </chipCountIntoPot>
        </xsl:variable>
        <xsl:variable name="runningChipCountIntoPotPerSeatOnTurn">
            <chipCountIntoPot>
                <xsl:for-each select="$runningChipCountIntoPotPerSeatOnFlop/chipCountIntoPot/seat">
                    <seat seatNum="{ @seatNum }" chipCountIntoPot="{ pp:calculateMoneyPerStep(current()/@seatNum, current()/@chipCountIntoPot, $actionsOnTurn) }"/>
                </xsl:for-each>
            </chipCountIntoPot>
        </xsl:variable>
        <xsl:variable name="runningChipCountIntoPotPerSeatOnRiver">
            <chipCountIntoPot>
                <xsl:for-each select="$runningChipCountIntoPotPerSeatOnTurn/chipCountIntoPot/seat">
                    <seat seatNum="{ @seatNum }" chipCountIntoPot="{ pp:calculateMoneyPerStep(current()/@seatNum, current()/@chipCountIntoPot, $actionsOnRiver) }"/>
                </xsl:for-each>
            </chipCountIntoPot>
        </xsl:variable>
        <xsl:copy-of select="pp:seatSummaryAfterHand($seats, $runningChipCountIntoPotPerSeatOnRiver, $hand/winner)"/> 
    </xsl:function>
    
</xsl:stylesheet>