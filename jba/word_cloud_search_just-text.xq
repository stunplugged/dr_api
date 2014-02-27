for $x in ft:tokens('programseries')
order by number($x/@count) descending
return ($x/text(), '
')