DROP FUNCTION IF EXISTS programseriesByPublishInterval(startTime timestamp, stopTime timestamp ) CASCADE;

CREATE FUNCTION programseriesByPublishInterval(startTime timestamp, stopTime timestamp ) returns SETOF xml
AS $$
DECLARE

BEGIN
	RETURN QUERY SELECT XMLRoot(
	(SELECT XMLElement( name "programseries",
	XMLAgg( XMLElement( name "programserie",
				XMLElement( name "slug", sortedPS.slug),
				XMLElement( name "titel", sortedPS.title),
				XMLElement( name "description", sortedPS.description),
				XMLElement( name "newestvideoid", sortedPS.newestvideoid),
				XMLElement( name "newestvideopublishtime", sortedPS.newestvideopublishtime)
			)
	))
	FROM 
	(
		SELECT *
		FROM programserie AS ps
		WHERE ps.newestvideopublishtime >= startTime AND  ps.newestvideopublishtime  <= stopTime
		ORDER BY ps.newestvideopublishtime DESC
	) AS sortedPS), VERSION '1.0', STANDALONE yes);	
END;
$$
LANGUAGE plpgsql;


--SELECT *
--FROM programseriesByPublishInterval('2013-12-30 01:00:00', '2014-04-28 01:00:00');