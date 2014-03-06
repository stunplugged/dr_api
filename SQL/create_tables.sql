drop table if exists downloadeXML cascade;
drop table if exists slugLabel cascade;
drop table if exists programSerie cascade;
drop table if exists label cascade;

create table downloadeXML
(
documentTitle			character(100),
documentContent 		xml,
primary key(documentTitle)
);
  
create table programSerie
(
programSerieNo			serial,
Slug 					character(100),
Title					character(100),
Description				character(4000),
ShortName				character(100),
NewestVideoId			integer,
NewestVideoPublishTime	timestamp without time zone,
VideoCount				integer,
WebCmsImagePath			character(500),
primary key(programSerieNo)
);
create index 
  on programSerie
  (Slug);

create table label
(
labelNo			serial,
labelTxt		character(50),
primary key(labelNo)
);

create table slugLabel
(
programSerieNo	integer,
labelNo			integer,
primary key(programSerieNo, labelNo),
foreign key(programSerieNo) references programSerie(programSerieNo),
foreign key(labelNo) references label(labelNo)
);




