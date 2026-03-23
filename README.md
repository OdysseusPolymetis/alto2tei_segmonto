# alto2tei_segmonto

Outil de conversion **ALTO → TEI**, avec une étape complémentaire de transformation **TEI → HTML** pour obtenir une visualisation simple et élégante du texte.

## 1. Objectif

Ce dépôt permet :

1. de convertir un ensemble de fichiers **ALTO XML** en un unique fichier **TEI XML** ;
2. de transformer ensuite ce fichier **TEI** en un **HTML lisible**, avec une mise en page légère.

## 2. Contenu du dépôt

- `alto2tei.py` : script principal de conversion **ALTO → TEI**
- `xsl/alto2tei.xsl` : transformation XSLT ALTO → TEI
- `xsl/replacens.xsl` : correction éventuelle de namespace ALTO
- `xsl/tei2html_robust.xsl` : transformation XSLT TEI → HTML
- `css/style.css` : feuille de style complémentaire
- `scripts/run_tei2html_v3.sh` : script de lancement pour la transformation TEI → HTML

## 3. Conversion ALTO → TEI

Le script `alto2tei.py` prend comme entrée un **dossier** contenant des fichiers ALTO `.xml` (ou `.XML`) et produit un fichier TEI unique.

### Commande minimale

```bash
python alto2tei.py chemin/vers/dossier_alto -o sortie_tei.xml
```

### Exemple
```bash
python alto2tei.py data/alto -o avare_converted.xml
```

## 4. Transformation TEI → HTML

Une fois le TEI produit, on peut générer un HTML avec la feuille XSLT fournie.

Avec `xsltproc`
```bash
xsltproc xsl/tei2html_robust.xsl avare_converted.xml > avare_converted.html
```
## 5. Résultat
La transformation TEI → HTML produit :
* un affichage lisible du texte ;
* un fond beige clair ;
* un bloc central de lecture ;
* un traitement visuel spécifique pour certaines structures, par exemple :
```xml
<div type="titlePage">
  <p>CAVARL<lb/>COMEDIE.<lb/></p>
</div>
```
