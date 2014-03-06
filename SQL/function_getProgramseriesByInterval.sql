DROP FUNCTION IF EXISTS fct_programseriesByPublishInterval(startTime timestamp, stopTime timestamp ) CASCADE;

CREATE FUNCTION fct_programseriesByPublishInterval(startTime timestamp, stopTime timestamp ) returns SETOF xml --programserie
AS $$
DECLARE

BEGIN
	RETURN QUERY SELECT 
	XMLAgg( XMLElement( name "programserie",
				XMLElement( name "slug", sortedPS.slug),
				XMLElement( name "titel", sortedPS.title),
				XMLElement( name "description", sortedPS.description),
				XMLElement( name "newestvideoid", sortedPS.newestvideoid),
				XMLElement( name "newestvideopublishtime", sortedPS.newestvideopublishtime)
			)
	)
	FROM 
	(
		SELECT *
		FROM programserie AS ps
		WHERE ps.newestvideopublishtime >= startTime AND  ps.newestvideopublishtime  <= stopTime
		ORDER BY ps.newestvideopublishtime DESC
	) AS sortedPS;	
END;
$$
LANGUAGE plpgsql;


--SELECT *
--FROM fct_programseriesByPublishInterval('2013-12-30 01:00:00', '2014-04-28 01:00:00');