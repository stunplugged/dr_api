DROP FUNCTION IF EXISTS getAndInsertAllLabels() CASCADE;
DROP FUNCTION IF EXISTS getAndInsertAllSlugs() CASCADE;
DROP FUNCTION IF EXISTS getAndInsertSlugsDetail() CASCADE;
DROP FUNCTION IF EXISTS programseriesByPublishInterval(startTime timestamp, stopTime timestamp ) CASCADE;
DROP FUNCTION IF EXISTS programseriesOfLabel(character(50)) CASCADE;





CREATE OR REPLACE FUNCTION getAndInsertAllLabels() RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
  labels	text[];
  count		integer default 0;
  v_found	VARCHAR default 'N';
BEGIN

  labels := (SELECT xpath('//ProgramSerie/Labels/string/text()', downloadedXML.documentContent) FROM downloadedXML);

  FOR i IN array_lower(labels, 1) .. array_upper(labels, 1)
  LOOP
    v_found := NULL;
    SELECT labelNo INTO v_found FROM label WHERE label.labelTxt = labels[i];
    IF v_found IS NULL THEN
      count := count + 1;
      INSERT INTO label(labelTxt) VALUES(labels[i]);
    END IF;
  END LOOP;

  return count || ' labels found in XML document';

END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION getAndInsertAllSlugs() RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
    slugs text[];
  dummy   VARCHAR;
    count integer default 0;
BEGIN

  slugs := (SELECT xpath('//ProgramSerie/Slug/text()', downloadedXML.documentContent) FROM downloadedXML);

  FOR i IN array_lower(slugs, 1) .. array_upper(slugs, 1)
  LOOP
    dummy := getAndInsertSlugsDetail(slugs[i]);
    count := count + 1;
  END LOOP;

  return count || ' programseries found in XML document';

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION getAndInsertSlugsDetail(p_slug VARCHAR) RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
  v_title     text;
  v_description     text;
  v_shortName     text;
  v_newestVideoId   integer;
  v_newestVideoPublishTime  timestamp without time zone;
  v_videoCount      integer;
  v_webCmsImagePath   text;
  v_tag_value     text[];
  v_labels      text[];
  v_programSerieNo    integer;
  v_labelNo     integer;
BEGIN
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/Title/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_title := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/Description/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_description := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/ShortName/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_shortName := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/NewestVideoId/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_newestVideoId := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/NewestVideoPublishTime/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_newestVideoPublishTime := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/VideoCount/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_videoCount := v_tag_value[1];
  v_tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/WebCmsImagePath/text()', downloadedXML.documentContent) FROM downloadedXML);
  v_webCmsImagePath := v_tag_value[1];    

  INSERT INTO programSerie (Slug, Title, Description, ShortName, NewestVideoId, NewestVideoPublishTime, VideoCount, WebCmsImagePath)
  VALUES (p_slug, v_title, v_description, v_shortName, v_newestVideoId, v_newestVideoPublishTime, v_videoCount, v_webCmsImagePath)
  RETURNING programSerie.programSerieNo INTO v_programSerieNo;

  v_labels := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/Labels/string/text()', downloadedXML.documentContent) FROM downloadedXML);

  IF array_lower(v_labels, 1) IS NOT NULL THEN
    FOR i IN array_lower(v_labels, 1) .. array_upper(v_labels, 1)
    LOOP
      SELECT labelNo INTO v_labelNo FROM label WHERE label.labelTxt = v_labels[i];
      IF v_labelNo IS NOT NULL THEN
        INSERT INTO slugLabel (programSerieNo, labelNo) VALUES(v_programSerieNo, v_labelNo);
      END IF;
    END LOOP;
  END IF;
  
  RETURN v_title;
END;
$$ LANGUAGE plpgsql;




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



