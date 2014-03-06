DROP FUNCTION IF EXISTS getAndInsertSlugsDetail() CASCADE;

CREATE OR REPLACE FUNCTION getAndInsertSlugsDetail(p_slug VARCHAR) RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
  v_title			text;
  v_description			text;
  v_shortName			text;
  v_newestVideoId		integer;
  v_newestVideoPublishTime	timestamp without time zone;
  v_videoCount			integer;
  v_webCmsImagePath		text;
  v_tag_value			text[];
  v_labels			text[];
  v_programSerieNo		integer;
  v_labelNo			integer;
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
