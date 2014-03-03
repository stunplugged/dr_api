declare namespace dr = "http://www.dr.dk";

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
    for $videoId in $programSeriesCategory//ProgramSerie/NewestVideoId/data()
      return(
        let $programSerieVideo := doc($programseriesVideoFileName)//ProgramSerieVideo[Id = $videoId]
        return $programSerieVideo
      )
  )
};


  
dr:programSeriesOfCategory("programseries.xml",'kultur' ),
dr:videosOfCategory("programseries.xml", "all.xml",'kultur')



(:
//ArrayOfProgramSerie/ProgramSerie/Labels[string='kultur']/../Title,
count(//ArrayOfProgramSerie/ProgramSerie/Labels[string='kultur']/../Title)



<test>37330</test>
<test>96132</test>
<test>15954</test>
<test>55500</test>
<test>12999</test>
<test>79123</test>
<test>43432</test>
<test>2830</test>
<test>11945</test>
<test>33319</test>
<test>30706</test>
<test>62860</test>
<test>8125</test>
<test>9130</test>
<test>6962</test>
<test>25943</test>
<test>30040</test>
<test>93646</test>
<test>30478</test>
<test>8300</test>
<test>90512</test>
<test>45736</test>
<test>15120</test>
<test>43516</test>
<test>12005</test>
<test>25970</test>
<test>27185</test>
<test>26851</test>
<test>75627</test>
<test>52451</test>

:)



