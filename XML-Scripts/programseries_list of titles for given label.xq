declare namespace dr = "http://www.dr.dk";

declare function dr:countProgramSeriesOfCategory
  ( $programseriesFileName as xs:string, $category as xs:string ) as element()*{
    
    let $progSeries := doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie/Labels[string=$category]/..
    return (
      <programSeriesCategory>
        <nameCategory>{$category}</nameCategory>
        <countProgSeries>{count($progSeries)}</countProgSeries>
        {
         for $progSerie in $progSeries
           (:alternativ: return $progSerie/ancestor::node()[1]:)
           return $progSerie
         }
      </programSeriesCategory>
    )
};


declare function dr:videosOfCategory
( $programseriesFileName as xs:string,  $programseriesVideoFileName as xs:string, $category as xs:string ) as element()*{

  let $progSeries := dr:countProgramSeriesOfCategory($programseriesFileName, $category )
  return(
    for $progSerie in $progSeries
    return 
    
  )

};




  
dr:countProgramSeriesOfCategory("programseries.xml",'kultur' )


(:
//ArrayOfProgramSerie/ProgramSerie/Labels[string='kultur']/../Title,
count(//ArrayOfProgramSerie/ProgramSerie/Labels[string='kultur']/../Title)

:)

