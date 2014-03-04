xquery version "1.0";
import module namespace dr='http://www.dr.dk' at 'dr_api_module.xqm';

(:
dr:programSeriesVideoBroadcastDateInterval("all.xml", xs:dateTime('2013-12-30T15:04:00'), xs:dateTime('2014-01-14T00:00:00.000'))

dr:getProgramSeriesCategory("programseries.xml")

dr:programSeriesOfCategory("programseries.xml",'kultur' ),
dr:videosOfCategory("programseries.xml", "all.xml",'kultur')


dr:programSeriesOfDateInterval("programseries.xml", xs:dateTime("2013-12-30T15:04:00"), xs:dateTime("2014-01-14T00:00:00")),
dr:videoIdCountExpire(9199, "programseries_video_reference.xml", "programseries_video.xml"),
dr:videoIdsSinceDate("programseries.xml",xs:dateTime("2014-01-14T00:00:00") ),
dr:checkVideoCount("tv-avisen-1955", "programseries.xml", "all.xml")
:)

declare variable $programseries_file1 := "programseries.xml";
declare variable $programseries_file2 := "programseries_video_reference.xml";

<differences>
  <removedProgramSerieFromFile1>
  {
     for $singleSlug in dr:leftExceptRight( $programseries_file1, $programseries_file2)
     return 
       dr:findProgramSerie($singleSlug/text(), $programseries_file1)
  }
  </removedProgramSerieFromFile1>


  <addedProgramSerieToFile2>
  {
     for $singleSlug in dr:leftExceptRight( $programseries_file2, $programseries_file1)
     return 
       dr:findProgramSerie($singleSlug/text(), $programseries_file2)  
  }     
  </addedProgramSerieToFile2>


  <changedContentProgramSeries>
  {
    for $singleSlug in dr:joinSlug( $programseries_file1, $programseries_file2 )
    return
      dr:compareNodes($singleSlug/text(), $programseries_file1, $programseries_file2)
  }
  </changedContentProgramSeries>

</differences>
