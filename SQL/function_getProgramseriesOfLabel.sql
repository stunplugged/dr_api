DROP FUNCTION IF EXISTS programseriesOfLabel(character(50)) CASCADE;

CREATE FUNCTION programseriesOfLabel(labelName character(50) ) returns SETOF xml
AS $$
DECLARE

BEGIN
	
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
		
	FROM   programserie ps, sluglabel sla, label la
	WHERE  la.labeltxt = labelName
	AND    sla.labelno = la.labelno
	AND    sla.programserieno = ps.programserieno
	), VERSION '1.0', STANDALONE yes
	);
	
END;
$$
LANGUAGE plpgsql;


--SELECT *
--FROM programseriesOfLabel('kultur');