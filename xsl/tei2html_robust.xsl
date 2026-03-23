<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!--
    Version robuste :
    - CSS embarqué dans le HTML (pas de problème de chemin)
    - gestion des TEI avec namespace ET sans namespace
    - traitement visible de div[@type='titlePage']
  -->

  <xsl:template match="/">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>
          <xsl:choose>
            <xsl:when test="//*[local-name()='titleStmt']/*[local-name()='title']">
              <xsl:value-of select="normalize-space((//*[local-name()='titleStmt']/*[local-name()='title'])[1])"/>
            </xsl:when>
            <xsl:otherwise>Affichage TEI</xsl:otherwise>
          </xsl:choose>
        </title>
        <style>
          html, body {
            margin: 0;
            padding: 0;
          }

          body {
            font-family: Georgia, "Times New Roman", serif;
            background: #efe8da;
            color: #22201c;
            line-height: 1.7;
          }

          .page-shell {
            padding: 3rem 1.5rem 4rem 1.5rem;
          }

          .page-card {
            max-width: 980px;
            margin: 0 auto;
            background: #fffdf8;
            box-shadow: 0 12px 36px rgba(74, 58, 37, 0.10);
            border: 1px solid #ddd2bd;
            padding: 2.5rem 4.5rem 4rem 5.5rem;
          }

          .document-header {
            border-bottom: 1px solid #d8cdb9;
            margin-bottom: 2.2rem;
            padding-bottom: 1rem;
          }

          .document-header h1 {
            font-family: "Helvetica Neue", Arial, sans-serif;
            font-size: 2rem;
            margin: 0 0 0.5rem 0;
            color: #314554;
            letter-spacing: 0.01em;
          }

          .source {
            margin: 0;
            color: #74695e;
            font-size: 0.96rem;
          }

          .tei-text {
            font-size: 1.08rem;
          }

          p, .ab {
            margin: 0 0 1em 0;
            text-align: justify;
          }

          .div {
            margin-bottom: 1.3rem;
          }

          h2 {
            font-family: "Helvetica Neue", Arial, sans-serif;
            font-size: 1.35rem;
            margin-top: 2.2rem;
            margin-bottom: 1rem;
            color: #314554;
          }

          .pb {
            margin: 2.3rem 0 1.4rem 0;
            padding-top: 0.7rem;
            border-top: 1px solid #bcae95;
            color: #7a6d5c;
            text-align: center;
            font-size: 0.95rem;
            letter-spacing: 0.05em;
          }

          .title-page {
            margin: 2.5rem 0 3rem 0;
            padding: 4rem 2rem;
            background: #f6f0e3;
            border: 1px solid #d9ccb4;
            text-align: center;
          }

          .title-page-text {
            text-align: center;
            font-size: 1.6rem;
            line-height: 2;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            margin: 0;
          }

          .note {
            margin: 1rem 0;
            padding: 0.85rem 1rem;
            background: #f2ebde;
            border-left: 4px solid #b7a58a;
            font-size: 0.95rem;
            color: #4e473f;
          }

          .add {
            color: #0b6e4f;
            font-weight: 500;
          }

          .del {
            color: #9f2d2d;
            text-decoration: line-through;
          }

          .hi {
            font-style: italic;
          }

          ul {
            margin: 0.5rem 0 1rem 1.4rem;
          }

          li {
            margin-bottom: 0.4rem;
          }

          @media (max-width: 900px) {
            .page-card {
              padding: 1.5rem 1.5rem 2.5rem 1.8rem;
            }

            .title-page {
              padding: 2.5rem 1rem;
            }

            .title-page-text {
              font-size: 1.25rem;
              letter-spacing: 0.08em;
            }
          }
        </style>
      </head>
      <body>
        <main class="page-shell">
          <div class="page-card">
            <header class="document-header">
              <h1>
                <xsl:choose>
                  <xsl:when test="//*[local-name()='titleStmt']/*[local-name()='title']">
                    <xsl:value-of select="normalize-space((//*[local-name()='titleStmt']/*[local-name()='title'])[1])"/>
                  </xsl:when>
                  <xsl:otherwise>Document TEI</xsl:otherwise>
                </xsl:choose>
              </h1>
              <xsl:if test="//*[local-name()='sourceDesc']/*[local-name()='p']">
                <p class="source">
                  <xsl:value-of select="normalize-space((//*[local-name()='sourceDesc']/*[local-name()='p'])[1])"/>
                </p>
              </xsl:if>
            </header>

            <article class="tei-text">
              <xsl:apply-templates select="//*[local-name()='text']/*[local-name()='body']"/>
            </article>
          </div>
        </main>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:body | *[local-name()='body']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:div[@type='titlePage'] | *[local-name()='div' and @type='titlePage']">
    <section class="title-page">
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <xsl:template match="tei:div | *[local-name()='div']">
    <section class="div">
      <xsl:if test="@type">
        <xsl:attribute name="data-type"><xsl:value-of select="@type"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <xsl:template match="tei:head | *[local-name()='head']">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="tei:div[@type='titlePage']/tei:p | *[local-name()='div' and @type='titlePage']/*[local-name()='p']">
    <p class="title-page-text"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:p | *[local-name()='p']">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:ab | *[local-name()='ab']">
    <p class="ab"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:lb | *[local-name()='lb']">
    <br/>
  </xsl:template>

  <xsl:template match="tei:pb | *[local-name()='pb']">
    <div class="pb">
      <xsl:text>— Page</xsl:text>
      <xsl:if test="@n">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:if>
      <xsl:text> —</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:hi | *[local-name()='hi']">
    <span class="hi"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:add | *[local-name()='add']">
    <span class="add" title="Ajout"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:del | *[local-name()='del']">
    <span class="del" title="Suppression"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:note | *[local-name()='note']">
    <aside class="note"><xsl:apply-templates/></aside>
  </xsl:template>

  <xsl:template match="tei:list | *[local-name()='list']">
    <ul><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="tei:item | *[local-name()='item']">
    <li><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="tei:choice | *[local-name()='choice']">
    <span class="choice"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:teiHeader | *[local-name()='teiHeader']"/>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
</xsl:stylesheet>
