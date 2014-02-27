declare namespace dr = "http://www.dr.dk";
declare function dr:leftExceptRight
  ( $leftSide as xs:anyAtomicType*, $rightSide as xs:anyAtomicType* ) as xs:anyAtomicType* {
    distinct-values($leftSide[not(.=$rightSide)])
  };


declare function dr:compareElement
  ( $element1 as xs:anyAtomicType*, $element2 as xs:anyAtomicType* ) as xs:anyAtomicType* {
    if($element1 eq $element2)
      
    else
     
  };


let $progSeries1 := doc("programseries.xml")//ProgramSerie
let $progSeries2 := doc("programseries_video_reference.xml")//ProgramSerie
let $leftHandSide := dr:leftExceptRight($progSeries1/Slug, $progSeries2/Slug)
let $rightHandSIde := dr:leftExceptRight($progSeries2/Slug, $progSeries1/Slug)

return 
<differences>
  <removedElementDoc1>
   {
     for  $progSeries3 in doc("programseries.xml")//ProgramSerie,
       $t in $leftHandSide
     where   $progSeries3/Slug = $t
     return $progSeries3
  }
  </removedElementDoc1>


  <addedElementDoc2>
   {
 (:    for  $progSeries4 in doc("programseries_video_reference.xml")//ProgramSerie,
       $t in $rightHandSIde
     where   $progSeries4/Slug = $t
     return $progSeries4:)
     dr:compareElement(<test2>test1</test2>, <test3>test1</test3>)
    
     
  }     
  </addedElementDoc2>

  


</differences>




 
 