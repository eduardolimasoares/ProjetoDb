CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS ltree;

CREATE OR REPLACE FUNCTION to_unaccent(input text) 
  RETURNS text
AS
$BODY$
    select unaccent(lower(input));
$BODY$
LANGUAGE sql
IMMUTABLE;

DROP TABLE IF EXISTS "userpermission";
CREATE TABLE "userpermission" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	userpermission ("name") 
VALUES
	('Admin'),
	('Gestor'),
	('Inspetor'),
	('Executor');

DROP TABLE IF EXISTS "sectors";
CREATE TABLE "sectors" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	sectors ("name") 
VALUES
	('GIBB'),
	('GIOF'),
	('GIOS'),
	('GIOC'),
	('GIOC Manutenção');

DROP TABLE IF EXISTS "serviceorderstatus";
CREATE TABLE "serviceorderstatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	serviceorderstatus ("name") 
VALUES
	('Abertas'),
	('Em andamento'),
	('Fechadas'),
	('Cancelado'),
	('Todas');

DROP TABLE IF EXISTS "areasgi";
CREATE TABLE "areasgi" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	areasgi ("name") 
VALUES
	('Beneficiamento'),
	('Ferrovia'),
	('Secagem'),
	('Embarque');

DROP TABLE IF EXISTS "inspectionstatus";
CREATE TABLE "inspectionstatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	inspectionstatus ("name") 
VALUES
	('Pendentes'),
	('Em andamento'),
	('Finalizado'),
	('Todas');

DROP TABLE IF EXISTS "inspectionfrequencystatus";
CREATE TABLE "inspectionfrequencystatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	inspectionfrequencystatus ("name") 
VALUES
	('Diária'),
	('Quinzenal'),
	('Mensal'),
	('Trimestral'),
	('Anual'),
	('Imediata');

DROP TABLE IF EXISTS "serviceordercriticality";
CREATE TABLE "serviceordercriticality" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	serviceordercriticality ("name") 
VALUES
	('Baixa'),
	('Média'),
	('Alta');


DROP TABLE IF EXISTS "users";
CREATE TABLE "users" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255),
  "email" varchar(255) UNIQUE,
  "password" varchar(255),
  "userpermission_id" bigint,
  "disabled" bool not null default false,
  "generatedpassword" bool,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "users" ADD FOREIGN KEY ("userpermission_id") REFERENCES "userpermission" ("id");


DROP TABLE IF EXISTS "userssectors";
CREATE TABLE "userssectors" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" bigint,
  "sector_id" bigint
);
ALTER TABLE "userssectors" ADD FOREIGN KEY ("sector_id") REFERENCES "sectors" ("id");
ALTER TABLE "userssectors" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

--INSERT INTO users ("name", email, "password", userpermission_id, generatedpassword) VALUES('Djalma', 'djalma@admin.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 1, NULL);
INSERT INTO users ("name", email, "password", userpermission_id, generatedpassword) VALUES ('Admin', 'admin@admin.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 1, NULL);
--INSERT INTO users ("name", email, "password", userpermission_id, generatedpassword) VALUES ('Alessandro Dias', 'alessandro.dias@mrn.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 1, NULL);

--INSERT INTO userssectors (user_id,  sector_id) VALUES(1, 1), (1, 2);
--INSERT INTO userssectors (user_id,  sector_id) VALUES(2, 1), (2, 2);

--ALTER SEQUENCE userssectors_id_seq RESTART WITH 3;


DROP TABLE IF EXISTS "points";
CREATE TABLE "points" (
  "id" BIGSERIAL PRIMARY KEY,
  "code" varchar(255),
  "name" varchar(255),
  "latitude" varchar(255),
  "longitude" varchar(255),
  "reference_point" varchar(255),
  "areagi_id" bigint,
  "disabled" bool Default false
);

ALTER TABLE "points" ADD FOREIGN KEY ("areagi_id") REFERENCES "areasgi" ("id");

DROP TABLE IF EXISTS "questionnairetemplate";
CREATE TABLE "questionnairetemplate" (
  "id" BIGSERIAL PRIMARY KEY,
  "name"  varchar(255),
  "deleted" bool Default false
);


DROP TABLE IF EXISTS "inspection";
CREATE TABLE "inspection" (
  "id" BIGSERIAL PRIMARY KEY,
  "areagi_id" bigint,
  "point_id" bigint,
  "inspectionfrequencystatus_id" bigint,
  "sector_id" bigint,
  "questionnairetemplate_id" bigint,
  "deleted" bool Default false,
  "reference_date"timestamp DEFAULT NULL,
  "created_at" timestamp DEFAULT NULL,
  "updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "inspection" ADD FOREIGN KEY ("point_id") REFERENCES "points" ("id");
ALTER TABLE "inspection" ADD FOREIGN KEY ("inspectionfrequencystatus_id") REFERENCES "inspectionfrequencystatus" ("id");
ALTER TABLE "inspection" ADD FOREIGN KEY ("sector_id") REFERENCES "sectors" ("id");
ALTER TABLE "inspection" ADD FOREIGN KEY ("questionnairetemplate_id") REFERENCES "questionnairetemplate" ("id");

DROP TABLE IF EXISTS "questionnaire";
CREATE TABLE "questionnaire" (
  "id" BIGSERIAL PRIMARY KEY,
  "inspection_id" bigint,
  "questionnairetemplate_id" bigint,
  "deleted" bool Default false,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "questionnaire" ADD FOREIGN KEY ("inspection_id") REFERENCES "inspection"("id");
ALTER TABLE "questionnaire" ADD FOREIGN KEY ("questionnairetemplate_id") REFERENCES "questionnairetemplate"("id");

DROP TABLE IF EXISTS "multioptions";
CREATE TABLE "multioptions" (
  "id" BIGSERIAL PRIMARY KEY,
  "option" varchar(255),
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

INSERT INTO 
	multioptions ("option") 
VALUES
	('sim'),
	('não'),
	('conforme'),
('não conforme');


DROP TABLE IF EXISTS "questioncriticality";
CREATE TABLE "questioncriticality" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255),
  "is_active" bool DEFAULT true
);

INSERT INTO 
	questioncriticality (name) 
VALUES
	('Baixa'),
	('Média'),
	('Alta');


DROP TABLE IF EXISTS "serviceorder";
CREATE TABLE "serviceorder" (
  "id" BIGSERIAL PRIMARY KEY,
  "cancel_reason" varchar(255),
  "number" varchar(255),
  "reference_code" varchar(255),
  "observation" varchar(255),
  "criticality_id" bigint DEFAULT NULL,
  "item_id" bigint DEFAULT NULL,
  "photographicregistersrelation_id" bigint DEFAULT NULL,
  "point_id" bigint DEFAULT NULL,
  "question_id" bigint DEFAULT NULL,
  "sector_id" bigint DEFAULT NULL,
  "serviceorderstatus_id" bigint DEFAULT NULL,
  "questionnairetemplate_id" bigint DEFAULT NULL,
  "questionnaire_uid" varchar(255) NULL DEFAULT NULL,
  "inspection_id" bigint DEFAULT NULL,
  "reporter_id" bigint DEFAULT NULL,
  "responsible_id" bigint DEFAULT NULL,
  "deleted" bool Default false,
  "closed_at" timestamp DEFAULT NULL,
  "opened_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);



DROP TABLE IF EXISTS "questions";
CREATE TABLE "questions" (
  "id" BIGSERIAL PRIMARY KEY,
  "label" varchar(255),
  "title" varchar(255),
  "comments" varchar(255),
  "show_text_field" bool Default false,
  "multioptionscreate_os" bigint
);

DROP TABLE IF EXISTS "items";
CREATE TABLE "items" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255),
  "questionnairetemplate_id" bigint,
  "not_applied" bool Default false,
  "deleted" bool Default false
);
ALTER TABLE "items" ADD FOREIGN KEY ("questionnairetemplate_id") REFERENCES "questionnairetemplate"("id");

DROP TABLE IF EXISTS "itemsquestions";
CREATE TABLE "itemsquestions" (
  "id" BIGSERIAL PRIMARY KEY,
  "item_id" bigint,
  "question_id" bigint
);
ALTER TABLE "itemsquestions" ADD FOREIGN KEY ("item_id") REFERENCES "items"("id");
ALTER TABLE "itemsquestions" ADD FOREIGN KEY ("question_id") REFERENCES "questions"("id");

DROP TABLE IF EXISTS "questionsoptions";
CREATE TABLE "questionsoptions" (
  "id" BIGSERIAL PRIMARY KEY,
  "questions_id" bigint,
  "multioptions_id" bigint,
  "order" bigint,
  "deleted" bool Default false
);
ALTER TABLE "questionsoptions" ADD FOREIGN KEY ("questions_id") REFERENCES "questions"("id");
ALTER TABLE "questionsoptions" ADD FOREIGN KEY ("multioptions_id") REFERENCES "multioptions"("id");



DROP TABLE IF EXISTS "inspectionstarted";
CREATE TABLE "inspectionstarted" (
  "id" BIGSERIAL PRIMARY KEY,
  "uid" varchar(255),
  "inspection_id" bigint,
  "inspector_id" bigint,
  "inspectionstatus_id" bigint,
  "date" timestamp DEFAULT NULL,
  "deleted" bool Default false,
  "created_at" timestamp DEFAULT NULL,
  "updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "inspectionstarted" ADD FOREIGN KEY ("inspection_id") REFERENCES "inspection" ("id");
ALTER TABLE "inspectionstarted" ADD FOREIGN KEY ("inspector_id") REFERENCES "users" ("id");
ALTER TABLE "inspectionstarted" ADD FOREIGN KEY ("inspectionstatus_id") REFERENCES "inspectionstatus" ("id");



DROP TABLE IF EXISTS "questionnaireresponse";
CREATE TABLE "questionnaireresponse" (
  "id" BIGSERIAL PRIMARY KEY,
  "uid" varchar(255),
  "inspectionstarted_id" bigint,
  "questionnairetemplate_id" bigint,
  "general_observations" varchar(255),
  "deleted" bool Default false,
  "created_at" timestamp DEFAULT NULL,
  "updated_at" timestamp DEFAULT (now())
);
--ALTER TABLE "questionnaireresponse" ADD FOREIGN KEY ("questionnaire_id") REFERENCES "questionnaire"("id");
--ALTER TABLE "questionnaireresponse" ADD FOREIGN KEY ("questions_id") REFERENCES "questions"("id");
--ALTER TABLE "questionnaireresponse" ADD FOREIGN KEY ("multioptions_id") REFERENCES "multioptions"("id");

DROP TABLE IF EXISTS "questionsresponse";
CREATE TABLE "questionsresponse" (
  "id" BIGSERIAL PRIMARY KEY,
  "uid" varchar(255),
  "item_id" bigint,
  "question_id" bigint,
  "questionnaireresponse_id" bigint,
  "response" varchar(255),
  "multioptionresponse_id" bigint,
  "inspectionstarted_id" bigint,
  "os_id" bigint,
  "deleted" bool Default false,
  "questioncriticality_id" bigint,
  "not_applied" bool Default false,
  "observation"  TEXT,
  "general_observations" varchar(255)

);
  ALTER TABLE "questionsresponse" ADD FOREIGN KEY ("questioncriticality_id") REFERENCES "questioncriticality"("id");

DROP TABLE IF EXISTS "photographicregisters";
CREATE TABLE "photographicregisters" (
  "id" BIGSERIAL PRIMARY KEY,
  "image" TEXT,
  "latitude" varchar(255),
  "longitude" varchar(255),
  "image_extension"  TEXT,
  "deleted" bool Default false,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

DROP TABLE IF EXISTS "photographicregistersrelation";
CREATE TABLE "photographicregistersrelation" (
  "id" BIGSERIAL PRIMARY KEY,
  "photographicregisters_id" bigint NULL DEFAULT NULL,
  "uid" varchar(255),
  "serviceorder_id" varchar(255),
  "item_id" bigint,
  "question_id" bigint,
  "questionnaire_uid" varchar(255) NULL DEFAULT NULL
);
ALTER TABLE "photographicregistersrelation" ADD FOREIGN KEY ("photographicregisters_id") REFERENCES "photographicregisters"("id");
--ALTER TABLE "photographicregistersrelation" ADD FOREIGN KEY ("serviceorder_id") REFERENCES "serviceorder"("id");
--ALTER TABLE "photographicregistersrelation" ADD FOREIGN KEY ("questionnaire_id") REFERENCES "questionnaire"("id");



DROP TABLE IF EXISTS "companyconfig";
CREATE TABLE "companyconfig" (
  "id" BIGSERIAL PRIMARY KEY,
  "logo" TEXT,
  "logo_fill" TEXT,
  "name" varchar(255),
  "company_id"  bigint,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

DROP TABLE IF EXISTS "log";
CREATE TABLE "log" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" bigint,
  "logs" TEXT,
  "company_id"  bigint,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "log" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

DROP TABLE IF EXISTS "itemresponse";
CREATE TABLE "itemresponse" (
  "id" BIGSERIAL PRIMARY KEY,
  "uid" varchar(255),
  "not_applied" bool Default false,
  "created_at" timestamp DEFAULT NULL,
  "updated_at" timestamp DEFAULT (now())
);
