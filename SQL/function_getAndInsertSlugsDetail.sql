DROP FUNCTION IF EXISTS getAndInsertSlugsDetail() CASCADE;

CREATE OR REPLACE FUNCTION getAndInsertSlugsDetail(p_slug VARCHAR) RETURNS VARCHAR AS $$
<< outerblock >>
DECLARE
  title				text;
  description			text;
  shortName			text;
  newestVideoId			integer;
  newestVideoPublishTime	timestamp without time zone;
  videoCount			integer;
  webCmsImagePath		text;
  tag_value			text[];
BEGIN
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/Title/text()', downloadedXML.documentContent) FROM downloadedXML);
  title := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/Description/text()', downloadedXML.documentContent) FROM downloadedXML);
  description := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/ShortName/text()', downloadedXML.documentContent) FROM downloadedXML);
  shortName := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/NewestVideoId/text()', downloadedXML.documentContent) FROM downloadedXML);
  newestVideoId := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/NewestVideoPublishTime/text()', downloadedXML.documentContent) FROM downloadedXML);
  newestVideoPublishTime := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/VideoCount/text()', downloadedXML.documentContent) FROM downloadedXML);
  videoCount := tag_value[1];
  tag_value := (SELECT xpath('//ProgramSerie[Slug='''|| p_slug ||''']/WebCmsImagePath/text()', downloadedXML.documentContent) FROM downloadedXML);
  webCmsImagePath := tag_value[1];    

  INSERT INTO programSerie (Slug, Title, Description, ShortName, NewestVideoId, NewestVideoPublishTime, VideoCount, WebCmsImagePath)
  VALUES (p_slug, title, description, shortName, newestVideoId, newestVideoPublishTime, videoCount, webCmsImagePath);
  RETURN 'title';
END;
$$ LANGUAGE plpgsql;
