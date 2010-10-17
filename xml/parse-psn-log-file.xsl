<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pp="http://www.spyker.com/pokerParser"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl pp xs"
    version="2.0">

    <xsl:variable name="PSNUsername">TheSpikerMan</xsl:variable>
    
    <xsl:variable name="PSNLogdirectory">file:///C:/users/aspyker/appdata/Local/PokerStars/HandHistory/TheSpikerMan/</xsl:variable>
    
    <xsl:variable name="PSNLogfilename1">HH20100915 T311570838 No Limit Hold'em 200 + 15.txt</xsl:variable>
    <xsl:variable name="PSNLogfilename2">HH20100918 T308745085 No Limit Hold'em Freeroll.txt</xsl:variable>
    <xsl:variable name="PSNLogfilename3">HH20100918 T308745157 No Limit Hold'em Freeroll.txt</xsl:variable>
    <xsl:variable name="PSNLogfilename">HH20101010 T319269255 No Limit Hold'em Freeroll.txt</xsl:variable>
    
    <xsl:variable name="filename"><xsl:value-of select="concat($PSNLogdirectory, '/', $PSNLogfilename)"/></xsl:variable>
    <xsl:output method="xml" indent="yes"/>

    <xsl:function name="pp:whichSeatIsTheButtonAndTableSize" as="attribute()*">
        <xsl:param name="tableSummary" as="xs:string"/>
        <xsl:analyze-string select="$tableSummary"
            regex="Table .* (\d)-max Seat #(\d) is the button">
            <xsl:matching-substring>
                <xsl:attribute name="tableMaxSize"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
                <xsl:attribute name="buttonSeat"><xsl:value-of select="regex-group(2)"/></xsl:attribute> 
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message terminate="no">Error matching tableSummary</xsl:message>
                <xsl:attribute name="tableMaxSize">0</xsl:attribute>
                <xsl:attribute name="buttonSeat">0</xsl:attribute> 
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="pp:seatNumberAndCurrentChipcount" as="attribute()*">
        <xsl:param name="seatSummary" as="xs:string"/>
        <xsl:variable name="isSittingOut" as="xs:boolean" select="contains($seatSummary, 'is sitting out')"/>
        <xsl:analyze-string select="$seatSummary"
            regex="Seat (\d): .*\((\d*) in chips\).*">
            <xsl:matching-substring>
                <xsl:attribute name="seatNumber"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
                <xsl:attribute name="chipCount"><xsl:value-of select="regex-group(2)"/></xsl:attribute>
                <xsl:if test="$isSittingOut">
                    <xsl:attribute name="isSittingOut">true</xsl:attribute>
                </xsl:if>                
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message terminate="no">Error matching seatSummary</xsl:message>
                <xsl:attribute name="seatNumber">0</xsl:attribute>
                <xsl:attribute name="chipCount">0</xsl:attribute> 
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="pp:getHandTime" as="attribute()*">
        <xsl:param name="summary" as="xs:string"/>
        <xsl:attribute name="time"><xsl:value-of select="substring(tokenize($summary, '-')[last()], 2)"/></xsl:attribute>
    </xsl:function>
    
    <xsl:function name="pp:buttonPositionTableSizeAndCurrentChipCountAndTime" as="attribute()*">
        <xsl:param name="hand" as="node()"/>
        <xsl:copy-of select="pp:whichSeatIsTheButtonAndTableSize($hand/following-sibling::tableSummary[1])"/>
        <xsl:copy-of select="pp:seatNumberAndCurrentChipcount($hand/following-sibling::seatSummary[1])"/>
        <xsl:copy-of select="pp:getHandTime($hand)"/>
    </xsl:function>

    <xsl:function name="pp:getLogLines" as="node()">
        <xsl:param name="logFilename" as="xs:string"/>
        <xsl:variable name="lines">
        <lines>
        <xsl:for-each select="tokenize(unparsed-text($logFilename), '\r?\n')">
            <xsl:choose>
                <xsl:when test="starts-with(., 'PokerStars Game ')">
                    <hand>
                    <xsl:value-of select="."/>
                    </hand>
                </xsl:when>
                <xsl:when test="starts-with(., concat('Dealt to ', $PSNUsername))">
                    <hole>
                    <xsl:value-of select="."/>
                    </hole>
                </xsl:when>
                <xsl:when test="contains(., ': bets ')">
                    <bets>
                    <xsl:value-of select="."/>
                    </bets>
                </xsl:when>
                <xsl:when test="contains(., ': calls ')">
                    <calls>
                    <xsl:value-of select="."/>
                    </calls>
                </xsl:when>
                <xsl:when test="contains(., ': folds')">
                    <folds>
                    <xsl:value-of select="."/>
                    </folds>
                </xsl:when>
                <xsl:when test="contains(., ': mucks hand')">
                    <mucks>
                    <xsl:value-of select="."/>
                    </mucks>
                </xsl:when>
                <xsl:when test="contains(., ': checks')">
                    <checks>
                    <xsl:value-of select="."/>
                    </checks>
                </xsl:when>
                <xsl:when test="contains(., ': raises ')">
                    <raises>
                    <xsl:value-of select="."/>
                    </raises>
                </xsl:when>
                <xsl:when test="contains(., ': posts big blind')">
                    <bigblind>
                    <xsl:value-of select="."/>
                    </bigblind>
                </xsl:when>
                <xsl:when test="contains(., ': posts small blind')">
                    <smallblind>
                    <xsl:value-of select="."/>
                    </smallblind>
                </xsl:when>
                <xsl:when test="starts-with(., '*** FLOP ***')">
                    <flop>
                    <xsl:value-of select="."/>
                    </flop>
                </xsl:when>
                <xsl:when test="starts-with(., '*** TURN ***')">
                    <turn>
                    <xsl:value-of select="."/>
                    </turn>
                </xsl:when>
                <xsl:when test="starts-with(., '*** RIVER ***')">
                    <river>
                    <xsl:value-of select="."/>
                    </river>
                </xsl:when>
    <!-- comes in the summary anyway            
                <xsl:when test="starts-with(., 'Total pot ')">
                    <pot>
                    <xsl:value-of select="."/>
                    </pot>
                </xsl:when>
    -->            
                <xsl:when test="starts-with(., 'Seat ') and (contains(., ' and won ') or contains(., ' collected '))">
                    <winner>
                        <xsl:if test="contains(., $PSNUsername)">
                            <xsl:attribute name="self">true</xsl:attribute>
                        </xsl:if>
                        <!-- note that we're explicitly losing any "and won" statements from other players -->
                        <xsl:value-of select="."/>
                    </winner>
                </xsl:when>
                <xsl:when test="starts-with(., 'Seat ') and contains (., $PSNUsername) and contains(., ' in chips')">
                    <seatSummary>
                    <xsl:value-of select="."/>
                    </seatSummary>
                </xsl:when>
                <xsl:when test="contains(., 'is the button')">
                    <tableSummary>
                    <xsl:value-of select="."/>
                    </tableSummary>
                </xsl:when>
                <!-- Board summary  -->
                <xsl:when test="starts-with(., 'Board [')"/>
                <!-- so far not doing anything with other seat summaries -->
                <xsl:when test="starts-with(., 'Seat ') and not(contains (., $PSNUsername)) and contains(., ' in chips')"/>
                <!-- so far not doing anything lost summaries -->
                <xsl:when test="starts-with(., 'Seat ') and contains(., ' and lost with ')"/>
                <!-- so far not doing anything lost summaries -->
                <xsl:when test="starts-with(., 'Seat ') and contains(., ' folded before ')"/>
                <!-- so far not doing anything lost summaries -->
                <xsl:when test="starts-with(., 'Seat ') and contains(., ' folded on the ')"/>
                <!-- so far not doing anything with the antes -->
                <xsl:when test="contains (., ': posts the ante ')"/>
                <!-- handled in dealt to -->
                <xsl:when test=". = '*** HOLE CARDS ***'"/> 
                <xsl:when test=". = '*** SHOW DOWN ***'"/>
                <xsl:when test=". = '*** SUMMARY ***'"/>
                <xsl:when test=". = '*** SUMMARY ***'"/>
                <xsl:when test="contains(., 'is sitting out')"/>
                <xsl:when test="contains(., 'has returned')"/>
                <xsl:when test="contains(., 'has timed out')"/>
                <xsl:when test="contains(., 'is connected')"/>
                <xsl:when test="contains(., 'said, ')"/>
                <xsl:when test="contains(., 'doesn''t show hand')"/>
                <xsl:when test="contains(., 'Total pot ')"/>
                <xsl:when test="contains(., ' returned to ')"/>
                <xsl:when test=". = ''"/>
                <xsl:otherwise>
                    <xsl:message><xsl:value-of select="."/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:for-each>
        </lines>
        </xsl:variable>
        <xsl:sequence select="$lines"></xsl:sequence>
    </xsl:function>
    
    <xsl:template name="init">
        <xsl:apply-templates select="pp:getLogLines($filename)"/>
    </xsl:template>
    
    <xsl:template match="lines">
        <hands>
        <!-- TODO:  Would be nice to take the first hand element and use this to get the title of the game
            PokerStars Game #49812863754: Tournament #308745085, Freeroll  Hold'em No Limit - Level I (200/400) - 2010/09/18 15:30:11 ET
        -->
        <xsl:for-each select="hand">
            <hand>
                <xsl:copy-of select="pp:buttonPositionTableSizeAndCurrentChipCountAndTime(.)"/>
<!--                
                <summary><xsl:value-of select="."/></summary>
-->                
                <xsl:apply-templates select="
                    if (not(./following-sibling::hand[1])) then
                        following-sibling::*
                    else
                        following-sibling::*[. &lt;&lt; current()/following-sibling::hand[1]]
                "/>
            </hand>
        </xsl:for-each>
        </hands>
    </xsl:template>

    <xsl:template match="tableSummary">
        <!-- hand reads to this following-sibling -->
    </xsl:template>
    
    <xsl:template match="seatSummary">
        <!-- hand reads to this following-sibling -->
    </xsl:template>
    
    <xsl:template match="hole">
        <hole>
            <xsl:analyze-string select="."
                regex=".* \[([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc])\]">
                <xsl:matching-substring>
                    <cards>
                        <card><xsl:value-of select="regex-group(1)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(2)"></xsl:value-of></card> 
                    </cards>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </hole>
    </xsl:template>
    
    <xsl:template match="flop">
        <flop>
        <xsl:analyze-string select="."
            regex="\*\*\* FLOP \*\*\* \[([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc])\]">
        <xsl:matching-substring>
        <cards>
            <card><xsl:value-of select="regex-group(1)"></xsl:value-of></card> 
            <card><xsl:value-of select="regex-group(2)"></xsl:value-of></card> 
            <card><xsl:value-of select="regex-group(3)"></xsl:value-of></card> 
        </cards>
        </xsl:matching-substring>
        <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
        </xsl:analyze-string>
        </flop>
    </xsl:template>
    
    <xsl:template match="turn">
        <turn>
            <xsl:analyze-string select="."
                regex="\*\*\* TURN \*\*\* \[([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc])\] \[([AKQJT987654321][hdsc])\]">
                <xsl:matching-substring>
                    <cards>
                        <card><xsl:value-of select="regex-group(1)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(2)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(3)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(4)"></xsl:value-of></card> 
                    </cards>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </turn>
    </xsl:template>
    
    <xsl:template match="river">
        <river>
            <xsl:analyze-string select="."
                regex="\*\*\* RIVER \*\*\* \[([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc]) ([AKQJT987654321][hdsc])\] \[([AKQJT987654321][hdsc])\]">
                <xsl:matching-substring>
                    <cards>
                        <card><xsl:value-of select="regex-group(1)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(2)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(3)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(4)"></xsl:value-of></card> 
                        <card><xsl:value-of select="regex-group(5)"></xsl:value-of></card> 
                    </cards>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </river>
    </xsl:template>
    
    <xsl:template match="bets">
        <bets>
            <xsl:analyze-string select="."
                regex="^(.*): bets (\d*)\s*(and is all-in)?">
                <xsl:matching-substring>
                    <xsl:variable name="better" select="regex-group(1)"/>
                    <xsl:variable name="ammount" select="regex-group(2)"/>
                    <xsl:variable name="all-in" select="regex-group(3)"/>
                    <xsl:if test="$better = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="ammount"><xsl:value-of select="$ammount"/></xsl:attribute>
                    <xsl:if test="$all-in">
                        <xsl:attribute name="all-in">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </bets>
    </xsl:template>
    
    <xsl:template match="calls">
        <calls>
            <xsl:analyze-string select="."
                regex="^(.*): calls (\d*)\s*(and is all-in)?">
                <xsl:matching-substring>
                    <xsl:variable name="caller" select="regex-group(1)"/>
                    <xsl:variable name="ammount" select="regex-group(2)"/>
                    <xsl:variable name="all-in" select="regex-group(3)"/>
                    <xsl:if test="$caller = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="ammount"><xsl:value-of select="$ammount"/></xsl:attribute>
                    <xsl:if test="$all-in">
                        <xsl:attribute name="all-in">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </calls>
    </xsl:template>
    
    <xsl:template match="folds">
        <folds>
            <xsl:analyze-string select="."
                regex="^(.*): folds ">
                <xsl:matching-substring>
                    <xsl:variable name="person" select="regex-group(1)"/>
                    <xsl:if test="$person = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </folds>
    </xsl:template>
    
    <xsl:template match="mucks">
        <mucks>
            <xsl:analyze-string select="."
                regex="^(.*): mucks hand ">
                <xsl:matching-substring>
                    <xsl:variable name="person" select="regex-group(1)"/>
                    <xsl:if test="$person = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </mucks>
    </xsl:template>

    <xsl:template match="smallblind">
        <smallblind>
            <xsl:analyze-string select="."
                regex="^(.*): posts small blind (\d*)\s*(and is all-in)?">
                <xsl:matching-substring>
                    <xsl:variable name="person" select="regex-group(1)"/>
                    <xsl:variable name="ammount" select="regex-group(2)"/>
                    <xsl:variable name="all-in" select="regex-group(3)"/>
                    <xsl:if test="$person = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="ammount"><xsl:value-of select="$ammount"/></xsl:attribute>
                    <xsl:if test="$all-in">
                        <xsl:attribute name="all-in">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </smallblind>
    </xsl:template>
    
    <xsl:template match="bigblind">
        <bigblind>
            <xsl:analyze-string select="."
                regex="^(.*): posts big blind (\d*)\s*(and is all-in)?">
                <xsl:matching-substring>
                    <xsl:variable name="person" select="regex-group(1)"/>
                    <xsl:variable name="ammount" select="regex-group(2)"/>
                    <xsl:variable name="all-in" select="regex-group(3)"/>
                    <xsl:if test="$person = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="ammount"><xsl:value-of select="$ammount"/></xsl:attribute>
                    <xsl:if test="$all-in">
                        <xsl:attribute name="all-in">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </bigblind>
    </xsl:template>
    
    <xsl:template match="checks">
        <checks>
            <xsl:analyze-string select="."
                regex="^(.*): checks ">
                <xsl:matching-substring>
                    <xsl:variable name="person" select="regex-group(1)"/>
                    <xsl:if test="$person = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </checks>
    </xsl:template>
    
    <xsl:template match="raises">
        <raises>
            <xsl:analyze-string select="."
                regex="^(.*): raises (\d*) to (\d*)\s*(and is all-in)?">
            <xsl:matching-substring>
                <xsl:variable name="raiser" select="regex-group(1)"/>
                <xsl:variable name="from" select="regex-group(2)"/>
                <xsl:variable name="to" select="regex-group(3)"/>
                <xsl:variable name="all-in" select="regex-group(4)"/>
                    <xsl:if test="$raiser = $PSNUsername">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="from"><xsl:value-of select="$from"/></xsl:attribute>
                    <xsl:attribute name="to"><xsl:value-of select="$to"/></xsl:attribute>
                    <xsl:if test="$all-in">
                        <xsl:attribute name="all-in">true</xsl:attribute>
                    </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
            </xsl:analyze-string>
        </raises>
    </xsl:template>
    
    <xsl:template match="winner">
        <winner>
        <xsl:copy-of select="@self"/>
        <xsl:choose>
            <xsl:when test="contains(., ' collected ')">
                <xsl:analyze-string select="."
                    regex="Seat \d: .* collected \((\d*)\).*">
                    <xsl:matching-substring>
                        <xsl:attribute name="total"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="contains(., ' and won ')">
                <xsl:analyze-string select="."
                    regex="Seat \d: .* and won \((\d*)\).*">
                    <xsl:matching-substring>
                        <xsl:attribute name="total"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>******* ERROR *******</xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <error><xsl:value-of select="."/></error>
            </xsl:otherwise>
        </xsl:choose>
        </winner>
    </xsl:template>
</xsl:stylesheet>