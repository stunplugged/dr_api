for $progSeries in doc("programseries_video_reference.xml")/ArrayOfProgramSerie/ProgramSerie,
    $progVideo in doc("programseries_video.xml")/ArrayOfProgramSerieVideo/ProgramSerieVideo
where $progSeries/NewestVideoId = $progVideo/Id
return <video videoId="{$progSeries/NewestVideoId}"
             title="{$progSeries/Title}"
             url="{$progVideo/@VideoManifestUrl}"/>
             
             
             