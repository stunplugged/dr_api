declare namespace dr = "http://www.dr.dk";




(: Returns all Slugs which are in nameFileLeft, but not in nameFileRight:)
declare function dr:leftExceptRight
  ( $nameFileLeft as xs:string, $nameFileRight as xs:string ) as element(Slug)*{
    let $leftSide := doc($nameFileLeft)//ProgramSerie/Slug
    let $rightSide := doc($nameFileRight)//ProgramSerie/Slug 
    let $except := $leftSide[not(.=$rightSide)]/node()
    return 
      for $singleSlugName in $except
        return  <Slug>{$singleSlugName}</Slug>
  };
(: Old version 
declare function dr:leftExceptRight
  ( $leftSide as xs:anyAtomicType*, $rightSide as xs:anyAtomicType* ) as xs:anyAtomicType* {
    distinct-values($leftSide[not(.=$rightSide)])
  };
:) 
  
  
  

(:Returns node: "ProgramSerie" with Slug = slugValue, otherwise nothing:)
declare function dr:findProgramSerie
 ($slugName as xs:string, $fileName as xs:string) as node()* {
   let  $progSeries := doc($fileName)//ProgramSerie
   return  
    $progSeries[Slug=$slugName]
 };
(:Old Version
declare function dr:findProgramSerie
 ($slugValue as xs:string, $fileName as xs:string) as node()* {
   let  $progSeries := doc($fileName)//ProgramSerie
   return  $progSeries[Slug=$slugValue]/node()
 };
:)
  
  
  
  
(:Join file 1 and 2 with Slug, return all Slugs, found in both files
Version with direct tag: <Slug> :)
declare function dr:joinSlug
  ( $nameFile1 as xs:string, $nameFile2 as xs:string ) as element(Slug)*{
    
      for $progSeries1 in doc($nameFile1)//ProgramSerie/Slug,
      $progSeries2 in doc($nameFile2)//ProgramSerie/Slug 
      where $progSeries1 = $progSeries2
      return 
          <Slug>{$progSeries1/data()}</Slug> 
  };

(:Join file 1 and 2 with Slug, return all Slugs, found in both files
Version with element() :)
declare function dr:joinSlug1
  ( $nameFile1 as xs:string, $nameFile2 as xs:string ) as element(Slug)*{
      for $progSeries1 in doc($nameFile1)//ProgramSerie/Slug,
      $progSeries2 in doc($nameFile2)//ProgramSerie/Slug 
      where $progSeries1 = $progSeries2
      return
      element Slug{
        $progSeries1/data()
      }  
  };

 





(:Compare two elements, returns content of elementFile1 and elementFile2 if 
element name matches but not content
better use:
fn:codepoint-equal() untersucht zwei Strings anhand ihrer Unicode-Werte auf Gleichheit.
fn:compare() wertet die übergebenen Argumente aus zu:

-1, falls das erste Argument kleiner ist als das zweite
1, falls das erste Argument größer ist als das zweite
0, falls beide Argumente gleich groß sind
:)
declare function dr:compareElement1
  ( $Slug as xs:string, $elementFile1 as element()?, $elementFile2 as element()? ) as element()?{
    if( fn:codepoint-equal($elementFile1/name(),$elementFile2/name() ) ) then (
      if( fn:codepoint-equal($elementFile1, $elementFile2) ) then ( 
      ) else (
        element changedContentProgramSerie{
          attribute Slug {$Slug},
          attribute elementName {$elementFile1/name()},
          
          element contentFile1{
            text {$elementFile1/data()}
          },
          element contentFile2{
             text {$elementFile2/data()}
          }
        }
        
      )
    ) else (
        
    )
  };
 
declare function dr:compareElement
  ( $Slug as xs:string, $elementFile1 as element()?, $elementFile2 as element()? ) as element()?{
    if( fn:compare($elementFile1/name(),$elementFile2/name() ) = 0) then (
      if( fn:compare($elementFile1, $elementFile2) = 0 ) then ( 
      ) else (
        element changedContentProgramSerie{
          attribute Slug {$Slug},
          attribute elementName {$elementFile1/name()},
          
          element contentFile1{
            text {$elementFile1/data()}
          },
          element contentFile2{
             text {$elementFile2/data()}
          }
        }
        
      )
    ) else (
        
    )
  };
    
  
  
  
declare function dr:compareNodes(
  $slugName as xs:string, $nameFile1 as xs:string, $nameFile2 as xs:string
) as  xs:anyAtomicType*{
  let $nodeFile1 := dr:findProgramSerie($slugName, $nameFile1)/node()
  let $nodeFile2 := dr:findProgramSerie($slugName, $nameFile2)/node()

  return
   (: OBS!!! don't find all changes!!!
   for $index in count($nodeFile1)
     return dr:compareElement( $slugName, $nodeFile1[$index],  $nodeFile2[$index] ):)

  (:Obs cross-product!!-->Performance:)
    
   for $singleElement1 in $nodeFile1,
       $singleElement2 in $nodeFile2
     return dr:compareElement( $slugName, $singleElement1,  $singleElement2 ) 
};



declare function dr:compareDocuments
( $nameFile1 as xs:string, $nameFile2 as xs:string ) as element()*{
(
   
  <Changes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">,
 
  <removedProgramSerieFromFile1>
  {
     for $singleSlug in dr:leftExceptRight( $nameFile1, $nameFile2)
     return 
       dr:findProgramSerie($singleSlug/data(), $nameFile1)
  }
  </removedProgramSerieFromFile1>,


  <addedProgramSerieToFile2>
  {
     for $singleSlug in dr:leftExceptRight( $nameFile2, $nameFile1)
     return 
       dr:findProgramSerie($singleSlug/data(), $nameFile2)  
  }     
  </addedProgramSerieToFile2>,


  <changedContentProgramSeries>
  {
    for $singleSlug in dr:joinSlug( $nameFile1, $nameFile2 )
    return
      dr:compareNodes($singleSlug/data(), $nameFile1, $nameFile2)
  }
  </changedContentProgramSeries>,
  
  </Changes>
  )
};


declare function dr:compareDocuments2
( $nameFile1 as xs:string, $nameFile2 as xs:string ) as node()*{
  document{
    element changes{
      text {
        element test1{
          text {TESTETS}
        }
      }
    }
  }

};



(:
let $programseries_file1 := "programseries.xml"
let $programseries_file2 := "programseries_video_reference.xml"
return 

<differences>
  <removedProgramSerieFromFile1>
  {
     for $singleSlug in dr:leftExceptRight( $programseries_file1, $programseries_file2)
     return 
       dr:findProgramSerie($singleSlug/data(), $programseries_file1)
  }
  </removedProgramSerieFromFile1>


  <addedProgramSerieToFile2>
  {
     for $singleSlug in dr:leftExceptRight( $programseries_file2, $programseries_file1)
     return 
       dr:findProgramSerie($singleSlug/data(), $programseries_file2)  
  }     
  </addedProgramSerieToFile2>


  <changedContentProgramSeries>
  {
    for $singleSlug in dr:joinSlug( $programseries_file1, $programseries_file2 )
    return
      dr:compareNodes($singleSlug/data(), $programseries_file1, $programseries_file2)
  }
  </changedContentProgramSeries>

</differences>

:)


 dr:compareDocuments2("programseries.xml", "programseries_video_reference.xml")
