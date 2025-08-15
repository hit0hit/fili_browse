# Fili_browse
Este script SQL cria uma tabela chamada "FILI_BROWSE" com colunas específicas para armazenar informações sobre imagens de colaboradores. Além disso, inclui um gatilho (trigger) chamado "BI_FILI_BROWSE" que é executado antes de uma inserção na tabela. Aqui estão algumas explicações sobre cada parte do script:

1. **Criação da Tabela:**
   ```sql
   CREATE TABLE "FILI_BROWSE" (
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
   CREATE OR REPLACE EDITIONABLE TRIGGER "BI_FILI_BROWSE"
   BEFORE INSERT ON "FILI_BROWSE"
   FOR EACH ROW
   BEGIN
     IF :NEW."EMPLOYEE_ID" IS NULL THEN
       SELECT "FILI_BROWSE_SEQ".NEXTVAL INTO :NEW."EMPLOYEE_ID" FROM sys.dual;
     END IF;
   END;
   ```
   - Este é um gatilho "BEFORE INSERT" que é acionado antes de inserir um novo registro na tabela.
   - Se "EMPLOYEE_ID" for nulo, ele usa uma sequência chamada "FILI_BROWSE_SEQ" para gerar um novo valor.

3. **Ativação do Gatilho:**
   ```sql
   ALTER TRIGGER "BI_FILI_BROWSE" ENABLE;
   ```
   - Esta instrução ativa o gatilho para que ele comece a responder aos eventos.

Lembre-se de que, ao usar letras maiúsculas nos nomes de tabela e coluna, você precisará sempre referenciar esses objetos usando aspas duplas. Certifique-se de ajustar conforme necessário para atender aos requisitos do seu sistema.






# Procedimento de Importação de Imagem

Este procedimento PL/SQL é responsável por excluir registros existentes na tabela IMG para um determinado ID e inserir novos registros com base nos dados da tabela temporária APEX_APPLICATION_TEMP_FILES.

## Procedimento PL/SQL

```sql
DECLARE
   lp NUMBER := 0;
BEGIN
   -- Exclui registros existentes na tabela FILI_BROWSE para o ID fornecido
   DELETE FROM IMG WHERE ID = :P64_ID;

   -- Itera sobre os registros da tabela temporária APEX_APPLICATION_TEMP_FILES
   FOR lp IN (SELECT * FROM APEX_APPLICATION_TEMP_FILES)
   LOOP
      -- Insere novos registros na tabela FILI_BROWSE
      INSERT INTO IMG (
         FILENAME,
         CONTENT,
         MIMETYPE,
         LAST_UPDATE,
         ID
      ) VALUES (
         lp.FILENAME,
         lp.BLOB_CONTENT,
         lp.MIME_TYPE,
         lp.CREATED_ON,
         :P64_ID
      );
   END LOOP;
END;
```

### Uso

Este procedimento é utilizado para atualizar ou adicionar imagens associadas a um determinado ID. Certifique-se de fornecer o valor apropriado para o item de página `:ID` antes de executar este bloco PL/SQL.

### Exemplo de Teste

Para testar o procedimento, você pode seguir estas etapas:

1. **Preparação**: Certifique-se de ter uma tabela temporária APEX_APPLICATION_TEMP_FILES populada com dados de imagem válidos.
2. **Configuração**: Substitua o valor de `:ID` por um ID de colaborador existente.
3. **Execução**: Execute o bloco PL/SQL no Oracle APEX.
4. **Verificação**: Confirme se os registros associados ao ID foram corretamente excluídos e os novos registros foram inseridos na tabela IMG.

### Observações

- Antes de executar este bloco PL/SQL, certifique-se de que os dados na tabela temporária APEX_APPLICATION_TEMP_FILES estão corretos e contêm as informações necessárias para a inserção na tabela IMG.
- O bloco DELETE garante que registros antigos associados ao mesmo ID sejam removidos antes da inserção de novos dados.



## Atualização de Dados na Tabela FILI_BROWSE

Este bloco SQL é responsável por atualizar os dados na tabela `FILI_BROWSE` com informações provenientes da tabela temporária `APEX_APPLICATION_TEMP_FILES`.

### Instrução SQL

```sql
UPDATE FILI_BROWSE
SET 
   FILENAME = (SELECT FILENAME FROM APEX_APPLICATION_TEMP_FILES),
   CONTENT = (SELECT BLOB_CONTENT FROM APEX_APPLICATION_TEMP_FILES),
   MIMETYPE = (SELECT MIME_TYPE FROM APEX_APPLICATION_TEMP_FILES),
   LAST_UPDATE = (SELECT CREATED_ON FROM APEX_APPLICATION_TEMP_FILES)
WHERE ID = :ID;
```

### Uso

Esta instrução SQL é utilizada para atualizar os campos `FILENAME`, `CONTENT`, `MIMETYPE` e `LAST_UPDATE` na tabela `FILI_BROWSE` com os dados correspondentes da tabela temporária `APEX_APPLICATION_TEMP_FILES`. Certifique-se de fornecer o valor apropriado para o parâmetro `:GLOBAL_FILI_BROWSE` antes de executar esta instrução SQL.

## Observações

- Antes de executar esta instrução SQL, certifique-se de que os dados na tabela temporária `APEX_APPLICATION_TEMP_FILES` estão corretos e contêm as informações necessárias para a atualização na tabela `FILI_BROWSE`.










# Configuração do APEX para Download de Arquivos
download de arquivo botão ou link
```
create or replace PROCEDURE get_id (p_get_id  IN VARCHAR2) IS
  l_blob_content  CELL_BOLETO.CONTENT%TYPE;
  l_mime_type     CELL_BOLETO.MIMETYPE%TYPE;
  l_file_name     CELL_BOLETO.FILENAME%TYPE;
BEGIN
  SELECT CONTENT,
         MIMETYPE,
         FILENAME
  INTO   l_blob_content,
         l_mime_type,
         l_file_name
  FROM   FILI_BROWSE
  WHERE  ID = p_get_id;
  sys.HTP.init;
  sys.OWA_UTIL.mime_header(l_mime_type, FALSE);
  sys.HTP.p('Content-Length: ' || DBMS_LOB.getlength(l_blob_content));
  sys.HTP.p('Content-Disposition: filename="' || l_file_name || '"');
  sys.OWA_UTIL.http_header_close;
  sys.WPG_DOCLOAD.download_file(l_blob_content);
  apex_application.stop_apex_engine;
EXCEPTION
  WHEN apex_application.e_stop_apex_engine THEN
    NULL;
  WHEN OTHERS THEN
    HTP.p('ERRO NO ARQUIVO');
END;
```

## Item de Aplicativo

1. Crie um novo item de aplicativo.

   - **Caminho:** Componentes compartilhados > Itens de aplicativo
   - **Ação:** Clique no botão "Criar".
   - **Detalhes do Item:**
      - **Nome:** FILE_ID
      - **Escopo:** Aplicação
      - **Proteção do estado da sessão:** Soma de verificação necessária - nível do usuário
   - Clique no botão "Criar item de aplicativo".

## Processo de Inscrição

2. Crie um novo processo de inscrição.

   - **Caminho:** Componentes Compartilhados > Processos de Aplicativo
   - **Ação:** Clique no botão "Criar".
   - **Detalhes do Processo:**
      - **Nome:** GET_ID
      - **Sequência:** {aceitar o padrão}
      - **Ponto de processo:** Retorno de chamada do Ajax: execute este processo de aplicativo quando solicitado por um processo de página.
   - Clique no botão "Avançar".
   - Insira o PL/SQL necessário para realizar o download.
```
BEGIN 
  get_id(:FILE_ID); 
FIM;
```
   - Clique no botão "Avançar".
   - Selecione o tipo de condição "O usuário é autenticado (não público)".
   - Clique no botão "Criar Processo".
   - Se precisar adicionar autorização, clique no novo processo de inscrição, selecione o esquema de autorização e clique no botão "Aplicar alterações".

---

## Botão
 - No painel de propriedades, na seção “Comportamento”, selecione a “Ação” de “Redirecionar para URL”.
```
f?p=&APP_ID.:1:&APP_SESSION.:APPLICATION_PROCESS=GET_ID:::FILE_ID:MEU_ID
```
```
select 
       'f?p=&APP_ID.:1:&APP_SESSION.:APPLICATION_PROCESS=GET_FILE:::FILE_ID:'||B.ID_BOLETO||'' AS BAIXAR
from CELL_BOLETO B
 ```

## Link
```
<a href="f?p=&APP_ID.:1:&APP_SESSION.:APPLICATION_PROCESS=GET_FILE:::FILE_ID:MEU_ID">Baixar</a>
```

## Para mais informação:
https://oracle-base.com/articles/misc/apex-tips-file-download-from-a-button-or-link
