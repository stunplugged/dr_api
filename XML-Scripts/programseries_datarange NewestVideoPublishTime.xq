for $x in doc("programseries.xml")/ArrayOfProgramSerie/ProgramSerie
let $date as xs:dateTime := xs:dateTime($x/NewestVideoPublishTime/data())
where $date gt xs:dateTime("2013-12-30T15:04:00")
  and $date lt xs:dateTime("2014-01-14T00:00:00")
return  
    $x