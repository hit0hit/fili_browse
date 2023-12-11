# FILI_BROWSE
Este script SQL cria uma tabela chamada "Img_colaborador" com colunas específicas para armazenar informações sobre imagens de colaboradores. Além disso, inclui um gatilho (trigger) chamado "BI_Img_colaborador" que é executado antes de uma inserção na tabela. Aqui estão algumas explicações sobre cada parte do script:

1. **Criação da Tabela:**
   ```sql
   CREATE TABLE "Img_colaborador" (
     "EMPLOYEE_ID" NUMBER,
     "FILENAME" VARCHAR2(100),
     "CONTENT" BLOB,
     "MIMETYPE" VARCHAR2(50),
     "LAST_UPDATE" DATE,
     "CHAR_SET" VARCHAR2(100),
     CONSTRAINT "PK_EMPDOCS" PRIMARY KEY ("EMPLOYEE_ID") USING INDEX ENABLE
   );
   ```
   - **"EMPLOYEE_ID":** Identificador único do colaborador.
   - **"FILENAME":** Nome do arquivo da imagem.
   - **"CONTENT":** Coluna BLOB para armazenar o conteúdo binário da imagem.
   - **"MIMETYPE":** Tipo MIME da imagem.
   - **"LAST_UPDATE":** Data da última atualização.
   - **"CHAR_SET":** Conjunto de caracteres.

2. **Criação do Gatilho (Trigger):**
   ```sql
   CREATE OR REPLACE EDITIONABLE TRIGGER "BI_Img_colaborador"
   BEFORE INSERT ON "Img_colaborador"
   FOR EACH ROW
   BEGIN
     IF :NEW."EMPLOYEE_ID" IS NULL THEN
       SELECT "Img_colaborador_SEQ".NEXTVAL INTO :NEW."EMPLOYEE_ID" FROM sys.dual;
     END IF;
   END;
   ```
   - Este é um gatilho "BEFORE INSERT" que é acionado antes de inserir um novo registro na tabela.
   - Se "EMPLOYEE_ID" for nulo, ele usa uma sequência chamada "Img_colaborador_SEQ" para gerar um novo valor.

3. **Ativação do Gatilho:**
   ```sql
   ALTER TRIGGER "BI_Img_colaborador" ENABLE;
   ```
   - Esta instrução ativa o gatilho para que ele comece a responder aos eventos.

Lembre-se de que, ao usar letras maiúsculas nos nomes de tabela e coluna, você precisará sempre referenciar esses objetos usando aspas duplas. Certifique-se de ajustar conforme necessário para atender aos requisitos do seu sistema.
