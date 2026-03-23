<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:alto="http://www.loc.gov/standards/alto/ns-v4#"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="alto">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <xsl:param name="page_id"/>
  <xsl:param name="source_name"/>
  
  <xsl:key name="tag-by-id"
    match="alto:OtherTag | alto:LayoutTag | alto:StructureTag"
    use="@ID"/>
  
  <xsl:key name="style-by-id"
    match="alto:TextStyle"
    use="@ID"/>
  
  <xsl:template match="/">
    <tei:TEI xml:lang="fr">
      <tei:text>
        <tei:body>
          <xsl:apply-templates select="//alto:Page"/>
        </tei:body>
      </tei:text>
    </tei:TEI>
  </xsl:template>
  
  <xsl:template match="alto:Page">
    <tei:div type="page">
      <xsl:if test="$source_name">
        <xsl:attribute name="n">
          <xsl:value-of select="$source_name"/>
        </xsl:attribute>
      </xsl:if>
      
      <tei:pb>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$page_id"/>
        </xsl:attribute>
        <xsl:if test="@PHYSICAL_IMG_NR">
          <xsl:attribute name="n">
            <xsl:value-of select="@PHYSICAL_IMG_NR"/>
          </xsl:attribute>
        </xsl:if>
      </tei:pb>
      
      <xsl:apply-templates select="alto:PrintSpace"/>
    </tei:div>
  </xsl:template>
  
  <xsl:template match="alto:PrintSpace | alto:ComposedBlock | alto:Illustration">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="alto:GraphicalElement">
    <tei:figure/>
  </xsl:template>
  
  <xsl:template match="alto:TextBlock[not(.//alto:String)]"/>
  
  <xsl:template match="alto:TextBlock[.//alto:String]">
    <xsl:variable name="type">
      <xsl:call-template name="segmonto-type">
        <xsl:with-param name="tagrefs" select="@TAGREFS"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$type = 'RunningTitle'">
        <tei:fw type="head">
          <xsl:apply-templates select="alto:TextLine"/>
        </tei:fw>
      </xsl:when>
      
      <xsl:when test="$type = 'Numbering'">
        <tei:fw type="pageNum">
          <xsl:apply-templates select="alto:TextLine"/>
        </tei:fw>
      </xsl:when>
      
      <xsl:when test="$type = 'MarginText'">
        <tei:note place="margin">
          <xsl:apply-templates select="alto:TextLine"/>
        </tei:note>
      </xsl:when>
      
      <xsl:when test="$type = 'TitlePage'">
        <tei:div type="titlePage">
          <tei:p>
            <xsl:apply-templates select="alto:TextLine"/>
          </tei:p>
        </tei:div>
      </xsl:when>
      
      <xsl:when test="$type = 'Graphic'">
        <tei:figure/>
      </xsl:when>
      
      <xsl:when test="$type = 'QuireMarks'">
        <tei:fw type="quire">
          <xsl:apply-templates select="alto:TextLine"/>
        </tei:fw>
      </xsl:when>
      
      <xsl:when test="$type = 'Stamp' or $type = 'Seal' or $type = 'Damage' or $type = 'DigitizationArtefact'">
        <tei:div>
          <xsl:attribute name="type">
            <xsl:value-of select="$type"/>
          </xsl:attribute>
          <tei:p>
            <xsl:apply-templates select="alto:TextLine"/>
          </tei:p>
        </tei:div>
      </xsl:when>
      
      <xsl:otherwise>
        <tei:div>
          <xsl:if test="string-length(normalize-space($type)) &gt; 0 and $type != 'text'">
            <xsl:attribute name="type">
              <xsl:value-of select="$type"/>
            </xsl:attribute>
          </xsl:if>
          <tei:p>
            <xsl:apply-templates select="alto:TextLine"/>
          </tei:p>
        </tei:div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="alto:TextLine">
    <xsl:variable name="line_type">
      <xsl:call-template name="segmonto-type">
        <xsl:with-param name="tagrefs" select="@TAGREFS"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$line_type = 'Heading'">
        <tei:head>
          <xsl:apply-templates/>
        </tei:head>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <tei:lb/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="alto:String">
    <xsl:variable name="style" select="key('style-by-id', @STYLEREFS)"/>
    
    <xsl:choose>
      <xsl:when test="$style/@FONTSTYLE = 'italic'">
        <tei:hi rend="italic">
          <xsl:value-of select="@CONTENT"/>
        </tei:hi>
      </xsl:when>
      <xsl:when test="$style/@FONTSTYLE = 'bold'">
        <tei:hi rend="bold">
          <xsl:value-of select="@CONTENT"/>
        </tei:hi>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@CONTENT"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="alto:SP">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="alto:HYP">
    <xsl:text>-</xsl:text>
  </xsl:template>
  
  <xsl:template match="text()"/>
  
  <xsl:template name="segmonto-type">
    <xsl:param name="tagrefs"/>
    
    <xsl:choose>
      <xsl:when test="normalize-space($tagrefs) = ''"/>
      <xsl:otherwise>
        <xsl:variable name="first">
          <xsl:choose>
            <xsl:when test="contains(normalize-space($tagrefs), ' ')">
              <xsl:value-of select="substring-before(normalize-space($tagrefs), ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($tagrefs)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="label" select="key('tag-by-id', $first)/@LABEL"/>
        
        <xsl:choose>
          <xsl:when test="$label = 'MainZone'">Main</xsl:when>
          <xsl:when test="$label = 'RunningTitleZone'">RunningTitle</xsl:when>
          <xsl:when test="$label = 'NumberingZone'">Numbering</xsl:when>
          <xsl:when test="$label = 'MarginTextZone'">MarginText</xsl:when>
          <xsl:when test="$label = 'TitlePageZone'">TitlePage</xsl:when>
          <xsl:when test="$label = 'GraphicZone'">Graphic</xsl:when>
          <xsl:when test="$label = 'DropCapitalZone'">DropCapital</xsl:when>
          <xsl:when test="$label = 'QuireMarksZone'">QuireMarks</xsl:when>
          <xsl:when test="$label = 'DamageZone'">Damage</xsl:when>
          <xsl:when test="$label = 'DigitizationArtefactZone'">DigitizationArtefact</xsl:when>
          <xsl:when test="$label = 'StampZone'">Stamp</xsl:when>
          <xsl:when test="$label = 'SealZone'">Seal</xsl:when>
          <xsl:when test="$label = 'DefaultLine'">Default</xsl:when>
          <xsl:when test="$label = 'HeadingLine'">Heading</xsl:when>
          <xsl:when test="$label = 'InterlinearLine'">Interlinear</xsl:when>
          <xsl:when test="$label = 'DropCapitalLine'">DropCapital</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$label"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>