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
    <xsl:variable name="PSNLogfilename">HH20100918 T308745157 No Limit Hold'em Freeroll.txt</xsl:variable>
    
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
            <xsl:if test="starts-with(., 'PokerStars Game ')">
                <hand>
                <xsl:value-of select="."/>
                </hand>
            </xsl:if>
            <xsl:if test="starts-with(., concat('Dealt to ', $PSNUsername))">
                <hole>
                <xsl:value-of select="."/>
                </hole>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': bets'))">
                <bets>
                <xsl:value-of select="."/>
                </bets>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': calls'))">
                <calls>
                <xsl:value-of select="."/>
                </calls>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': folds'))">
                <folds>
                <xsl:value-of select="."/>
                </folds>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': checks'))">
                <checks>
                <xsl:value-of select="."/>
                </checks>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': raises'))">
                <raises>
                <xsl:value-of select="."/>
                </raises>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': posts big blind'))">
                <bigblind>
                <xsl:value-of select="."/>
                </bigblind>
            </xsl:if>
            <xsl:if test="starts-with(., concat($PSNUsername, ': posts small blind'))">
                <smallblind>
                <xsl:value-of select="."/>
                </smallblind>
            </xsl:if>
            <xsl:if test="starts-with(., '*** FLOP ***')">
                <flop>
                <xsl:value-of select="."/>
                </flop>
            </xsl:if>
            <xsl:if test="starts-with(., '*** TURN ***')">
                <turn>
                <xsl:value-of select="."/>
                </turn>
            </xsl:if>
            <xsl:if test="starts-with(., '*** RIVER ***')">
                <river>
                <xsl:value-of select="."/>
                </river>
            </xsl:if>
<!-- comes in the summary anyway            
            <xsl:if test="starts-with(., 'Total pot ')">
                <pot>
                <xsl:value-of select="."/>
                </pot>
            </xsl:if>
-->            
            <xsl:if test="starts-with(., 'Seat ') and (contains(., ' and won ') or contains(., ' collected '))">
                <winner>
                    <xsl:if test="contains(., $PSNUsername)">
                        <xsl:attribute name="self">true</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </winner>
            </xsl:if>
            <xsl:if test="starts-with(., 'Seat ') and contains (., $PSNUsername) and contains(., ' in chips')">
                <seatSummary>
                <xsl:value-of select="."/>
                </seatSummary>
            </xsl:if>
            <xsl:if test="contains(., 'is the button')">
                <tableSummary>
                <xsl:value-of select="."/>
                </tableSummary>
            </xsl:if>
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
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="calls">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="folds">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="smallblind">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="bigblind">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="checks">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="raises">
        <xsl:copy-of select="."/>
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