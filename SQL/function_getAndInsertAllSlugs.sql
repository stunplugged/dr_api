DROP FUNCTION IF EXISTS getAndInsertAllSlugs() CASCADE;

CREATE OR REPLACE FUNCTION getAndInsertAllSlugs() RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
    slugs	text[];
	dummy   VARCHAR;
    count	integer default 0;
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

select getAndInsertAllSlugs();