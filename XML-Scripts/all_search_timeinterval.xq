declare namespace dr = "http://www.dr.dk";

(:Is working:)

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
  if( not($broadCastTimeElement/data()) ) then (
       (xs:dateTime("1900-01-01T00:00:00"))
    ) else (
      (xs:dateTime($broadCastTimeElement/data()))
    ) 
};

dr:programSeriesVideoBroadcastDateInterval("all.xml", xs:dateTime('2013-12-30T15:04:00'), xs:dateTime('2014-01-14T00:00:00.000'))
