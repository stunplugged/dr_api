declare namespace dr = "http://www.dr.dk";


declare function dr:videoIdCountExpire
  ( $videoId as xs:integer, $programseriesFileName as xs:string, $videoFileName as xs:string ) as element()*{
    
    let $progSerie := doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie
    let $progVideo := doc($videoFileName)/ArrayOfProgramSerieVideo/ProgramSerieVideo
    return(
      <VideoCount>{$progSerie[NewestVideoId = $videoId]/VideoCount/data()}</VideoCount>,
      <ExpireTime>{$progVideo[Id = $videoId]/ExpireTime/data()}</ExpireTime>
    )
  };
  
  
declare function dr:programSeriesOfDateInterval
( $programseriesFileName as xs:string, $dateStart as xs:dateTime, $dateStop as xs:dateTime) as node()*{
  for $x in doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie 
  let $date as xs:dateTime := xs:dateTime($x/NewestVideoPublishTime/data())
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



  
  dr:programSeriesOfDateInterval("programseries.xml", xs:dateTime("2013-12-30T15:04:00"), xs:dateTime("2014-01-14T00:00:00")),
  dr:videoIdCountExpire(9199, "programseries_video_reference.xml", "programseries_video.xml"),
  dr:videoIdsSinceDate("programseries.xml",xs:dateTime("2014-01-14T00:00:00") ),
  dr:checkVideoCount("tv-avisen-1955", "programseries.xml", "all.xml")