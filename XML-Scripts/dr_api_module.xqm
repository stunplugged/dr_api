xquery version "1.0";
module namespace dr = 'http://www.dr.dk';


(:==============================================================================
"Global" variable definition 
===============================================================================:)
declare variable $dr:PROGRAMSERIES_FILE_NAME := 'programseries.xml';




(:==============================================================================
ProgramSeriesVideo 
===============================================================================:)

declare function dr:programSeriesVideoBroadcastDateInterval
( $programseriesVideoFileName as xs:string, $dateStart as xs:dateTime, $dateStop as xs:dateTime) as element()*{
  for $progSerVideoElement in doc($programseriesVideoFileName)/ArrayOfProgramSerieVideo/ProgramSerieVideo
  let $broadCastTime := dr:getBroadCastTime($progSerVideoElement/BroadcastTime)
  where $broadCastTime ge $dateStart and $broadCastTime le $dateStop
  return $progSerVideoElement
}; 


(: Catching: <BroadcastTime xsi:nil="true" /> :)
declare function dr:getBroadCastTime
($broadCastTimeElement as element() ) as xs:dateTime{
  if( not($broadCastTimeElement/text()) ) then (
       (xs:dateTime("1900-01-01T00:00:00"))
    ) else (
      (xs:dateTime($broadCastTimeElement/text()))
    ) 
};




(:==============================================================================
ProgramSeries - List of labels 
===============================================================================:)

declare function dr:getProgramSeriesCategory
  ( $programseriesFileName as xs:string) as element()*{
    
    let $progSerieLabels := distinct-values(doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie/Labels/string/text())
    return (
      <countCategory>{count($progSerieLabels)}</countCategory>,
      (
      for $label in $progSerieLabels
        return <category>{$label}</category>
      )
    )
};
  


(:==============================================================================
ProgramSeries - List of titles for given label
===============================================================================:)

declare function dr:programSeriesOfCategory
  ( $programseriesFileName as xs:string, $category as xs:string ) as element()*{
    
    let $progSeries := doc($programseriesFileName)/ArrayOfProgramSerie/
    ProgramSerie/Labels[string=$category]/..
    return (
      <programSeriesCategory>
        <nameCategory>{$category}</nameCategory>
        <countProgSeries>{count($progSeries)}</countProgSeries>
        {
         for $progSerie in $progSeries
           return $progSerie
         }
      </programSeriesCategory>
    )
};

declare function dr:videosOfCategory
( $programseriesFileName as xs:string,  $programseriesVideoFileName as xs:string, $category as xs:string ) as element()*{

  let $programSeriesCategory := dr:programSeriesOfCategory($programseriesFileName, $category )
  return(
    for $videoId in $programSeriesCategory//ProgramSerie/NewestVideoId/text()
      return(
        let $programSerieVideo := doc($programseriesVideoFileName)//ProgramSerieVideo[Id = $videoId]
        return $programSerieVideo
      )
  )
};



(:==============================================================================
ProgramSeries - Video Id sort
===============================================================================:)

declare function dr:videoIdCountExpire
  ( $videoId as xs:integer, $programseriesFileName as xs:string, $videoFileName as xs:string ) as element()*{
    
    let $progSerie := doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie
    let $progVideo := doc($videoFileName)/ArrayOfProgramSerieVideo/ProgramSerieVideo
    return(
      <VideoCount>{$progSerie[NewestVideoId = $videoId]/VideoCount/text()}</VideoCount>,
      <ExpireTime>{$progVideo[Id = $videoId]/ExpireTime/text()}</ExpireTime>
    )
  };
  
  
declare function dr:programSeriesOfDateInterval
( $programseriesFileName as xs:string, $dateStart as xs:dateTime, $dateStop as xs:dateTime) as node()*{
  for $x in doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie 
  let $date as xs:dateTime := xs:dateTime($x/NewestVideoPublishTime/text())
  where $date gt $dateStart and $date lt $dateStop
  return $x
}; 

  

declare function dr:videoIdsSinceDate
( 
$programseriesFileName as xs:string, $sinceDate as xs:dateTime ) as element()*{
  for $progSerie in dr:programSeriesOfDateInterval($programseriesFileName, $sinceDate, fn:current-dateTime() )
  return
    $progSerie/NewestVideoId
};


declare function dr:countVideoSlugs
  ($slugName as xs:string, $videoFileName as xs:string ) as xs:integer{

    count(for $programSerieVideo in doc($videoFileName)//ProgramSerieVideo
          where $programSerieVideo[ProgramSerieSlug = $slugName] and $programSerieVideo/Expired/text() = "false"
          return $programSerieVideo)
};


declare function dr:checkVideoCount
  ($slugName as xs:string, $programseriesFileName as xs:string, $videoFileName as xs:string ) as element()*{
    let $totalCount := doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie[Slug = $slugName]/VideoCount/text()
    return( 
      <totalVideoCount>{$totalCount}</totalVideoCount>,
      <availableVideoCount>{dr:countVideoSlugs($slugName, $videoFileName)}</availableVideoCount>
     )
};





(:==============================================================================
ProgramSeries - compare
===============================================================================:)

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
  

(:Returns node: "ProgramSerie" with Slug = slugValue, otherwise nothing:)
declare function dr:findProgramSerie
 ($slugName as xs:string, $fileName as xs:string) as node()* {
   let  $progSeries := doc($fileName)//ProgramSerie
   return  
    $progSeries[Slug=$slugName]
 };

  
(:Join file 1 and 2 with Slug, return all Slugs, found in both files
Version with direct tag: <Slug> :)
declare function dr:joinSlug
  ( $nameFile1 as xs:string, $nameFile2 as xs:string ) as element(Slug)*{
    
      for $progSeries1 in doc($nameFile1)//ProgramSerie/Slug,
      $progSeries2 in doc($nameFile2)//ProgramSerie/Slug 
      where $progSeries1 = $progSeries2
      return 
          <Slug>{$progSeries1/text()}</Slug> 
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
        $progSeries1/text()
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
            text {$elementFile1/text()}
          },
          element contentFile2{
             text {$elementFile2/text()}
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
            text {$elementFile1/text()}
          },
          element contentFile2{
             text {$elementFile2/text()}
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

