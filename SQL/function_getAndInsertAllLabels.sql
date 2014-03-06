DROP FUNCTION IF EXISTS getAndInsertAllLabels() CASCADE;

CREATE OR REPLACE FUNCTION getAndInsertAllLabels() RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
  slugs		text[];
  count		integer default 0;
  v_found	VARCHAR default 'N';
BEGIN

  slugs := (SELECT xpath('//ProgramSerie/Labels/string/text()', downloadedXML.documentContent) FROM downloadedXML);

  FOR i IN array_lower(slugs, 1) .. array_upper(slugs, 1)
  LOOP
    v_found := NULL;
    SELECT labelNo INTO v_found FROM label WHERE label.labelTxt = slugs[i];
    IF v_found IS NULL THEN
      count := count + 1;
      INSERT INTO label(labelTxt) VALUES(slugs[i]);
    END IF;
  END LOOP;

  return count || ' labels found in XML document';

END;
$$ LANGUAGE plpgsql;
