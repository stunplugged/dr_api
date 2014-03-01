declare namespace dr = "http://www.dr.dk";


declare function dr:videoIdCountExpire
  ( $videoId as xs:integer, $programseriesFileName as xs:string, $videoFileName as xs:string ) as element()*{
    
    let $progSeries := doc($programseriesFileName)/ArrayOfProgramSerie/ProgramSerie
    let $progVideo := doc($videoFileName)/ArrayOfProgramSerieVideo/ProgramSerieVideo
    return(
      <VideoCount>{$progSeries[NewestVideoId = $videoId]/VideoCount/data()}</VideoCount>,
      <ExpireTime>{$progVideo[Id = $videoId]/ExpireTime/data()}</ExpireTime>
    )
  };
  
  
  dr:videoIdCountExpire(9199, "programseries_video_reference.xml", "programseries_video.xml")
  