-- Find beskrivelsen til serien "se-ein-ding".
select xpath('//ProgramSerie[Slug="so-ein-ding"]/Description/text()', downloadedXML.documentContent)
from downloadedXML