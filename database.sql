CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS ltree;
CREATE EXTENSION "uuid-ossp";
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
	('ADMINISTRATOR'),
	('EXPERT'),
	('CLIENT');

DROP TABLE IF EXISTS "userstatus";
CREATE TABLE "userstatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	userstatus ("name") 
VALUES
	('ACTIVE'),
	('INACTIVE');

-- -----------------------------------------------------
-- users
-- -----------------------------------------------------

DROP TABLE IF EXISTS "users";
CREATE TABLE "users" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255),
  "email" varchar(255) UNIQUE,
  "cpf" varchar(255) UNIQUE,
  "phone" varchar(255) DEFAULT '',
  "password" varchar(255),
  "thumbnail" varchar(255) DEFAULT '',
  "userpermission_id" bigint,
  "professional_experience" varchar(255) DEFAULT '',
  "status" bigint,
  "acivated" bool DEFAULT true,
  "active" bool DEFAULT true,
  "url" text NULL,
  "available_to_attend" bool DEFAULT true,
  "customer_metadata" jsonb NULL,
  "iugu_id" text NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  "last_accessed_at" timestamp DEFAULT (now())
);
ALTER TABLE "users" ADD FOREIGN KEY ("userpermission_id") REFERENCES "userpermission" ("id");
ALTER TABLE "users" ADD FOREIGN KEY ("status") REFERENCES "userstatus" ("id");

INSERT INTO users ("name", email, "password", userpermission_id, status) VALUES ('Admin', 'admin@admin.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 1, 1);
INSERT INTO users ("name", email, "password", userpermission_id, status) VALUES('Expert 1', 'expert@expert.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 2, 1);
INSERT INTO users ("name", email, "password", userpermission_id, status) VALUES('Expert 2', 'expert2@expert.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 2, 1);
INSERT INTO users ("name", email, "password", userpermission_id, status) VALUES ('Client 1', 'client@client.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 3, 1);
INSERT INTO users ("name", email, "password", userpermission_id, status) VALUES ('Client 2', 'client2@client.com', '$2a$04$G9w/EBxLC7hJ2LPEFTYoseQn1sGtiDsTke4ufdM3IfMtKEeK8bEni', 3, 1);



-- -----------------------------------------------------
-- requeststatus
-- -----------------------------------------------------
DROP TABLE IF EXISTS "requeststatus";
CREATE TABLE "requeststatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	requeststatus ("name") 
VALUES
	('CREATED'),
	('AWAITING_PAYMENT'),
	('OPEN'),
	('WAITING_ANALYSIS'),
	('RETURNED'),
	('IN_PROGRESS'),
	('ANALYSIS_SENT'),
	('DONE');


-- -----------------------------------------------------
-- requests
-- -----------------------------------------------------
DROP TABLE IF EXISTS "requests";
CREATE TABLE "requests" (
  "id" BIGSERIAL PRIMARY KEY,
  "expert_acceptance" bool DEFAULT false,
  "categories_id" bigint,
  "status" bigint,
  "title" varchar(255) DEFAULT '',
  "details" text,
  "value" decimal(100,2),
  "height" decimal NULL,
  "width" decimal NULL,
  "depth" decimal NULL,
  "expert_id" bigint DEFAULT NULL,
  "client_id" bigint,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now()),
  "deleted_at" timestamp DEFAULT NULL
 );
 
 ALTER TABLE "requests" ADD FOREIGN KEY ("expert_id") REFERENCES "users" ("id");
 ALTER TABLE "requests" ADD FOREIGN KEY ("client_id") REFERENCES "users" ("id");
 ALTER TABLE "requests" ADD FOREIGN KEY ("status") REFERENCES "requeststatus" ("id");

-- -----------------------------------------------------
-- categorystatus
-- -----------------------------------------------------
DROP TABLE IF EXISTS "categorystatus";
CREATE TABLE "categorystatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	categorystatus ("name") 
VALUES
	('ACTIVE'),
	('INACTIVE');


-- -----------------------------------------------------
-- category
-- -----------------------------------------------------
DROP TABLE IF EXISTS "category";
CREATE TABLE "category" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255),
  "status_id" bigint,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);
 ALTER TABLE "category" ADD FOREIGN KEY ("status_id") REFERENCES "categorystatus" ("id");

-- -----------------------------------------------------
-- requestscategories
-- -----------------------------------------------------
DROP TABLE IF EXISTS "requestscategories";
CREATE TABLE "requestscategories" (
  "request_id" bigint,
  "category_id" bigint
);
 ALTER TABLE "requestscategories" ADD FOREIGN KEY ("request_id") REFERENCES "requests" ("id");
 ALTER TABLE "requestscategories" ADD FOREIGN KEY ("category_id") REFERENCES "category" ("id");

-- -----------------------------------------------------
-- categoryparent
-- -----------------------------------------------------
DROP TABLE IF EXISTS "categoryparent";
CREATE TABLE "categoryparent" (
  "child_id" bigint,
  "parent_id" bigint
);
 ALTER TABLE "categoryparent" ADD FOREIGN KEY ("child_id") REFERENCES "category" ("id");
 ALTER TABLE "categoryparent" ADD FOREIGN KEY ("parent_id") REFERENCES "category" ("id");

INSERT INTO category ("name", status_id, created_at, updated_at) VALUES('Pintura', 1, NOW(), NOW());

-- -----------------------------------------------------
-- analysis
-- -----------------------------------------------------
DROP TABLE IF EXISTS "analysis";
CREATE TABLE "analysis" (
	"id" BIGSERIAL PRIMARY KEY,
  "request_id" bigint NULL,
	"analysis_content" text NULL,
	"notes" text NULL,
	"price" decimal(100, 2) NULL,
	"secure_price" decimal(100, 2) NULL,
	"is_draft" bool  DEFAULT false,
  "url" text NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "analysis" ADD FOREIGN KEY ("request_id") REFERENCES "requests" ("id");

-- -----------------------------------------------------
-- requestimages
-- -----------------------------------------------------
DROP TABLE IF EXISTS "requestimages";
CREATE TABLE "requestimages" (
	"id" BIGSERIAL PRIMARY KEY,
 	"request_id" bigint NULL,
	"url" text NULL,
	"name" varchar(255) DEFAULT '',
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "requestimages" ADD FOREIGN KEY ("request_id") REFERENCES "requests" ("id");

-- -----------------------------------------------------
-- address
-- -----------------------------------------------------
DROP TABLE IF EXISTS "address";
CREATE TABLE "address" (
	"id" uuid NOT NULL DEFAULT uuid_generate_v4 (),
	"user_id" bigint NULL,
	"zip_code" text NULL,
	"street" text NULL,
	"number" text NULL,
	"complement" text NULL,
	"district" text NULL,
	"state" text NULL,
	"city" text NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now()),
	UNIQUE(id)
);
ALTER TABLE "address" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");


-- -----------------------------------------------------
-- registration
-- -----------------------------------------------------
DROP TABLE IF EXISTS "registration";
CREATE TABLE "registration" (
	"id" uuid NOT NULL DEFAULT uuid_generate_v4 (),
	"user_id" bigint NULL,
	"name" text NULL,
	"document" text NULL,
	"municipal_registration" text NULL,
	"phone" text NULL,
	"email" text NULL,
	"address_id" uuid NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now()),
	UNIQUE(id)
);
ALTER TABLE "registration" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "registration" ADD FOREIGN KEY ("address_id") REFERENCES "address" ("id");


-- -----------------------------------------------------
-- invoice
-- -----------------------------------------------------
DROP TABLE IF EXISTS "invoice";
CREATE TABLE "invoice" (
	"id" uuid NOT NULL DEFAULT uuid_generate_v4 (),
 	"registration_id" uuid NULL,
 	"user_id" bigint NULL,
 	"request_id" bigint NULL,
	"url" text NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now()),
	UNIQUE(id)
);
ALTER TABLE "invoice" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "invoice" ADD FOREIGN KEY ("registration_id") REFERENCES "registration" ("id");
ALTER TABLE "invoice" ADD FOREIGN KEY ("request_id") REFERENCES "requests" ("id");


-- -----------------------------------------------------
-- payments
-- -----------------------------------------------------
DROP TABLE IF EXISTS "payments";
CREATE TABLE "payments" (
	"id" text NOT NULL DEFAULT '',
	"user_id" bigint NULL,
	"request_id" bigint NULL,
 	"invoice_id" uuid NULL,
	"url" text NULL,
	"value" numeric NULL,
	"payment_metadata" jsonb NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "payments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "payments" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoice" ("id");
ALTER TABLE "payments" ADD FOREIGN KEY ("request_id") REFERENCES "requests" ("id");

-- -----------------------------------------------------
-- notificationstatus
-- -----------------------------------------------------
DROP TABLE IF EXISTS "notificationstatus";
CREATE TABLE "notificationstatus" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" varchar(255)
);

INSERT INTO 
	notificationstatus ("name") 
VALUES
	('READ'),
	('UNREAD'),
	('DELETED');

-- -----------------------------------------------------
-- notification
-- -----------------------------------------------------
DROP TABLE IF EXISTS "notification";
CREATE TABLE "notification" (
	"id" uuid NOT NULL DEFAULT uuid_generate_v4 (),
	"user_id" bigint NULL,
	"title" text NULL,
 	"message" text NULL,
	"status_id" bigint NULL,
	"created_at" timestamp DEFAULT (now()),
	"updated_at" timestamp DEFAULT (now())
);
ALTER TABLE "notification" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "notification" ADD FOREIGN KEY ("status_id") REFERENCES "notificationstatus" ("id");

-- -----------------------------------------------------
-- usertokens
-- -----------------------------------------------------
DROP TABLE IF EXISTS "usertokens";
CREATE TABLE "usertokens" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" bigint NULL,
  "token" text NULL,
  "expiredat" timestamp DEFAULT (now())
);
ALTER TABLE "usertokens" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

-- -----------------------------------------------------
-- product
-- -----------------------------------------------------
DROP TABLE IF EXISTS "product";
CREATE TABLE "product" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" text NULL
);

-- -----------------------------------------------------
-- productprice
-- -----------------------------------------------------
DROP TABLE IF EXISTS "productprice";
CREATE TABLE "productprice" (
  "id" BIGSERIAL PRIMARY KEY,
  "price" bigint NULL,
  "discount" bigint NULL,
  "product_id" bigint NULL
);
ALTER TABLE "productprice" ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");

INSERT INTO product
(id, "name")
VALUES(1, 'analusis');

INSERT INTO productprice
(id, price, discount, product_id)
VALUES(1, 35000, 5000, 1);
