for $program score $score in //ArrayOfProgramSerie/ProgramSerie/Description[ft:contains(text(), ("restaurant", "laks"), { "mode": "any" })]/..
order by $score descending
return <result>
     <title> {$program//Title} </title>
          <score> {$score} </score>
     </result>