CREATE TABLE  "Img_colaborador" 
   (	"EMPLOYEE_ID" NUMBER, 
	"FILENAME" VARCHAR2(100), 
	"CONTENT" BLOB, 
	"MIMETYPE" VARCHAR2(50), 
	"LAST_UPDATE" DATE, 
	"CHAR_SET" VARCHAR2(100), 
	 CONSTRAINT "PK_EMPDOCS" PRIMARY KEY ("EMPLOYEE_ID")
  USING INDEX  ENABLE
   )
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_Img_colaborador" 
  before insert on "Img_colaborador"               
  for each row  
begin   
  if :NEW."EMPLOYEE_ID" is null then 
    select "Img_colaborador_SEQ".nextval into :NEW."EMPLOYEE_ID" from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "BI_Img_colaborador" ENABLE
/
