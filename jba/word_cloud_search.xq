for $x in ft:tokens('programseries')
order by number($x/@count) descending
return (data($x/@count), '	', ($x/text()), '
')