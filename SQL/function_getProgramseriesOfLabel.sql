DROP FUNCTION IF EXISTS fct_programseriesOfLabel(character(50)) CASCADE;

CREATE FUNCTION fct_programseriesOfLabel(labelName character(50) ) returns SETOF xml --programserie
AS $$
DECLARE

BEGIN
	--RETURN QUERY SELECT *
	
RETURN QUERY 
	SELECT XMLRoot(
		(SELECT XMLElement( name "programseries",
		XMLAgg( XMLElement( name "programserie",
				XMLElement( name "slug", ps.slug),
				XMLElement( name "titel", ps.title),
				XMLElement( name "description", ps.description),
				XMLElement( name "newestvideoid", ps.newestvideoid),
				XMLElement( name "newestvideopublishtime", ps.newestvideopublishtime)
				)	
			)
		)
		
	FROM programserie AS ps
	NATURAL JOIN
	(
		SELECT sla.programserieno
		FROM sluglabel AS sla
		WHERE  sla.labelno = (
			SELECT la.labelno
			FROM label as la
			WHERE labeltxt = labelName
		)
	)selNo), VERSION '1.0', STANDALONE yes
	);
	
END;
$$
LANGUAGE plpgsql;



