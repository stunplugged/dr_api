declare namespace dr = "http://www.dr.dk";

declare function dr:getProgramSeriesCategory
  ( $programseriesFileName as xs:string) as element()*{
    
    let $progSerieLables := distinct-values(doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie/Labels/string/text())
    return (
      <countCategory>{count($progSerieLables)}</countCategory>,
      (
      for $lable in $progSerieLables
        return <category>{$lable}</category>
      )
    )
};
  
  
dr:getProgramSeriesCategory("programseries.xml")


(: XPath:
distinct-values(/ArrayOfProgramSerie/ProgramSerie/Labels/string/text())
:)

(: Resultat: programseries.xml
dokumentar 
nyheder og aktualitet
unge
børn
kultur
dr mama
livsstil
underholdning og satire
sundhed
historie
tech og viden
religion
underholdning
politik
undervisning
film
natur
dokumentar og reportage
musik
serier
satire
tro og religion
forbruger
:)
