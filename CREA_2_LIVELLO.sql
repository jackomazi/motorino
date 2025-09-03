/******************************************************************************

             Connettersi come system e lanciare questo script.
 
******************************************************************************/ 

-------------------------------------------------------------- 
----------------CREAZIONE NUOVO UTENTE------------------------
--------------------------------------------------------------

DROP USER VGLDM CASCADE;

CREATE USER VGLDM   ---- CREA UTENTE DATA MART
IDENTIFIED BY vgldm
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;

--RUOLI E PRIVILEGI DA ASSEGNARE ALL'UTENTE:
-- 3 RUOLI
GRANT CONNECT TO VGLDM;
GRANT DBA TO VGLDM;
GRANT RESOURCE TO VGLDM;
ALTER USER VGLDM DEFAULT ROLE NONE;
-- 15 PRIVILEGI
GRANT MERGE ANY VIEW TO VGLDM;
GRANT CREATE ANY TABLE TO VGLDM;
GRANT UNLIMITED TABLESPACE TO VGLDM;
GRANT DEBUG CONNECT SESSION TO VGLDM;
GRANT DROP ANY DIRECTORY TO VGLDM;
GRANT CREATE ANY DIRECTORY TO VGLDM;
GRANT DEBUG ANY PROCEDURE TO VGLDM;
GRANT QUERY REWRITE TO VGLDM;
GRANT UPDATE ANY TABLE TO VGLDM;
GRANT CREATE ANY PROCEDURE TO VGLDM;
GRANT CREATE ANY VIEW TO VGLDM;
GRANT CREATE SEQUENCE TO VGLDM;
GRANT CREATE TABLE TO VGLDM;
GRANT SELECT ANY TABLE TO VGLDM;
GRANT CREATE SESSION TO VGLDM;
GRANT EXECUTE ON VGLSA.PKG_UTILS_01 TO VGLDM; --per poter utilizzare la procedura p_audit_log

--concediamo i privilegi di lettura e scrittura sulle directory all'utente DWH02
--GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.EXT_DATA_DIR TO VGLDM WITH GRANT OPTION;  
--GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.EXT_BAD_DIR TO VGLDM WITH GRANT OPTION;
--GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.EXT_LOG_DIR TO VGLDM WITH GRANT OPTION;

--------------------------------------------------------
--  DDL for Sequence
--------------------------------------------------------

   CREATE SEQUENCE  VGLDM.SEQ_ID_ANA_SCD  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


   CREATE SEQUENCE  VGLDM.SEQ_ID_LOTTO  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


   CREATE SEQUENCE  VGLDM.SEQ_ID_RUOLI  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


   CREATE SEQUENCE  VGLDM.SEQ_ID_UNT_SCD  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


   CREATE SEQUENCE  VGLDM.SEQ_WRK_AUDIT_LOG  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
   
--------------------------------------------------------
--  DDL for Table 
--------------------------------------------------------

  CREATE TABLE VGLDM.D_ANAGRAFICA_SCD 
   (	ID_DIP NUMBER(8,0), 
	COD_DIP NUMBER(5,0), 
	COD_UNT NUMBER(5,0), 
	COD_RUOLO VARCHAR2(10 BYTE), 
	COGNOME VARCHAR2(50 BYTE), 
	NOME VARCHAR2(50 BYTE), 
	DT_INI_UNT DATE, 
	TIPO_CTR VARCHAR2(50 BYTE), 
	COD_CTR VARCHAR2(10 BYTE), 
	COD_LIV VARCHAR2(10 BYTE), 
	DT_INI_LIV DATE, 
	DT_INI_MNS DATE, 
	MATRICOLA VARCHAR2(10 BYTE), 
	CF VARCHAR2(16 BYTE), 
	SESSO VARCHAR2(10 BYTE), 
	DT_NASCITA DATE, 
	TIPO_RAPP VARCHAR2(10 BYTE), 
	DT_INI_TIPO_CTR DATE, 
	DT_FINE_TIPO_CTR DATE, 
	DT_INI_RAPP DATE, 
	DT_FINE_RAPP DATE, 
	AMBITO VARCHAR2(10 BYTE), 
	TIPO_ASS VARCHAR2(10 BYTE), 
	DT_PROROGA_TERMINE DATE, 
	DT_CTR_SOST_MAT DATE, 
	QTA_PART_TIME VARCHAR2(10 BYTE), 
	TITOLARE1 VARCHAR2(50 BYTE), 
	TITOLARE2 VARCHAR2(50 BYTE), 
	MOTIVO_PROMOZIONE VARCHAR2(50 BYTE), 
	FASCICOLO_AGGIORNATO VARCHAR2(50 BYTE), 
	TITOLO_STUDIO VARCHAR2(10 BYTE), 
	DESC_CTR VARCHAR2(50 BYTE), 
	DESC_LIV VARCHAR2(50 BYTE), 
	D_INS DATE, 
	D_UPD DATE, 
	D_INIVAL NUMBER(6,0), 
	D_ENDVAL NUMBER(6,0), 
	LAST_ID_PER NUMBER(6,0)
   );


  CREATE TABLE VGLDM.D_PERIOD 
   (	ID_PERIOD NUMBER(8,0), 
	ID_YEAR_MONTH NUMBER(6,0), 
	DAY DATE, 
	DAY_OF_WEEK NUMBER(1,0), 
	DAY_OF_MONTH NUMBER(2,0), 
	DAY_OF_YEAR NUMBER(3,0), 
	DAY_NAME VARCHAR2(20 BYTE), 
	DAY_NAMES VARCHAR2(20 BYTE), 
	FLAG_H NUMBER(1,0), 
	WEEK_OF_MONTH NUMBER(1,0), 
	WEEK_OF_YEAR NUMBER(2,0), 
	MONTH_NUM NUMBER(2,0), 
	MONTH_NUMC VARCHAR2(2 BYTE), 
	MONTH_NAME VARCHAR2(10 BYTE), 
	MONTH_NAMES VARCHAR2(3 BYTE), 
	QUARTER NUMBER(1,0), 
	SEMESTER NUMBER(1,0), 
	YEAR_NUM VARCHAR2(10 BYTE)
   );


  CREATE TABLE VGLDM.D_RUOLI_MERGE 
   (	ID_RUOLO NUMBER(8,0), 
	COD_RUOLO VARCHAR2(10 BYTE), 
	DESC_RUOLO VARCHAR2(100 BYTE), 
	D_INS DATE, 
	D_UPD DATE, 
	LAST_ID_PER NUMBER(6,0)
   );


  CREATE TABLE VGLDM.D_UNITA_SCD 
   (	ID_UNT NUMBER(8,0), 
	COD_UNT NUMBER(5,0), 
	DESC_UNT VARCHAR2(100 BYTE), 
	COD_ACR VARCHAR2(10 BYTE), 
	DESC_ACR VARCHAR2(100 BYTE), 
	D_INS DATE, 
	D_UPD DATE, 
	D_INIVAL NUMBER(6,0), 
	D_ENDVAL NUMBER(6,0), 
	LAST_ID_PER NUMBER(6,0)
   );


  CREATE TABLE VGLDM.FCT_PRESENZE 
   (	ID_PERIOD NUMBER(8,0), 
	ID_YEAR_MONTH NUMBER(6,0), 
	ID_DIP NUMBER(8,0), 
	ID_UNT NUMBER(8,0), 
	ID_RUOLO NUMBER(8,0), 
	OREPRES NUMBER(4,2),
	ORESTRAOR NUMBER(4,2), 
	OREPERMES NUMBER(4,2)
   )
  PARTITION BY LIST (ID_YEAR_MONTH) 
 (PARTITION QZP_PALTRI  VALUES (DEFAULT) 
  TABLESPACE USERS NOCOMPRESS ) ;


  CREATE TABLE VGLDM.WRK_ANAGRAFICA_FLUSSI 
   (	VAL_TBL_NAME VARCHAR2(200 BYTE), 
	FLG_DISPONIBILE VARCHAR2(1 BYTE), 
	FLG_ORDERBY NUMBER(5,0), 
	NOTE_LISTA_FLUSSI VARCHAR2(4000 BYTE), 
	NOTE_LISTA_VIEW VARCHAR2(4000 BYTE)
   );


  CREATE TABLE VGLDM.WRK_AUDIT_CARICAMENTI 
   (	ID_LOTTO NUMBER, 
	VAL_TBL_NAME VARCHAR2(255 BYTE), 
	ID_PER NUMBER(6,0), 
	DTA_INIZIO DATE, 
	DTA_FINE DATE, 
	COD_STATO VARCHAR2(45 BYTE), 
	D_INS DATE
   );


  CREATE TABLE VGLDM.WRK_AUDIT_LOG 
   (	ID_LOG NUMBER, 
	ID_LOTTO NUMBER, 
	COD_FLUSSO VARCHAR2(100 BYTE), 
	LIVELLO NUMBER(1,0), 
	PROCEDURA VARCHAR2(100 BYTE), 
	SQL_CODE NUMBER, 
	ERROR_MESSAGE VARCHAR2(4000 BYTE), 
	STMT VARCHAR2(4000 BYTE), 
	NOTE VARCHAR2(4000 BYTE), 
	D_INS DATE DEFAULT SYSDATE
   );


  CREATE TABLE VGLDM.WRK_CONFIGURAZIONE 
   (	VAL_TBL_NAME VARCHAR2(30 BYTE), 
	VAL_INS_QUERY VARCHAR2(4000 BYTE)
   );
  
  
  --------------------------------------------------------
--  Popolamento tabelle di configurazione   
----------------------------------------------------------
-- 
REM INSERTING into VGLDM.WRK_CONFIGURAZIONE

SET DEFINE OFF;
Insert into VGLDM.WRK_CONFIGURAZIONE (VAL_TBL_NAME,VAL_INS_QUERY) values ('D_RUOLI_MERGE','MERGE INTO D_RUOLI_MERGE A 
USING V_RUOLI_MERGE B 
ON (A.COD_RUOLO = B.COD_RUOLO) 
WHEN MATCHED THEN 
UPDATE SET 
   A.DESC_RUOLO = B.DESC_RUOLO,  
   A.D_UPD = SYSDATE,
   A.LAST_ID_PER = B.ID_PER 
WHEN NOT MATCHED THEN 
INSERT (
       ID_RUOLO, 
       COD_RUOLO, 
       DESC_RUOLO,
       D_INS,
       LAST_ID_PER
      ) 
VALUES (
       SEQ_ID_RUOLI.NEXTVAL, 
       B.COD_RUOLO, 
       B.DESC_RUOLO, 
       SYSDATE,
       B.ID_PER
      )
');
Insert into VGLDM.WRK_CONFIGURAZIONE (VAL_TBL_NAME,VAL_INS_QUERY) values ('D_UNITA_SCD','BEGIN P_LOAD_UNITA_SCD(); END;');
Insert into VGLDM.WRK_CONFIGURAZIONE (VAL_TBL_NAME,VAL_INS_QUERY) values ('FCT_PRESENZE','INSERT INTO FCT_PRESENZE(
ID_PERIOD, 
	ID_YEAR_MONTH , 
	ID_DIP, 
	ID_UNT, 
	ID_RUOLO, 
	OREPRES,
	ORESTRAOR, 
	OREPERMES
                       )
       SELECT  ID_PERIOD, 
	ID_YEAR_MONTH , 
	ID_DIP, 
	ID_UNT, 
	ID_RUOLO, 
	OREPRES,
	ORESTRAOR, 
	OREPERMES 
FROM V_INSERT_PRESENZE');
Insert into VGLDM.WRK_CONFIGURAZIONE (VAL_TBL_NAME,VAL_INS_QUERY) values ('D_ANAGRAFICA_SCD','BEGIN P_LOAD_ANA_SCD();END;');


REM INSERTING into VGLDM.WRK_ANAGRAFICA_FLUSSI
SET DEFINE OFF;
Insert into VGLDM.WRK_ANAGRAFICA_FLUSSI (VAL_TBL_NAME,FLG_DISPONIBILE,FLG_ORDERBY,NOTE_LISTA_FLUSSI,NOTE_LISTA_VIEW) values ('D_ANAGRAFICA_SCD','Y','1','ANAGRAFICA','V_ANAGRAFICA_SCD');
Insert into VGLDM.WRK_ANAGRAFICA_FLUSSI (VAL_TBL_NAME,FLG_DISPONIBILE,FLG_ORDERBY,NOTE_LISTA_FLUSSI,NOTE_LISTA_VIEW) values ('D_RUOLI_MERGE','Y','2','RUOLI','V_RUOLI_MERGE');
Insert into VGLDM.WRK_ANAGRAFICA_FLUSSI (VAL_TBL_NAME,FLG_DISPONIBILE,FLG_ORDERBY,NOTE_LISTA_FLUSSI,NOTE_LISTA_VIEW) values ('D_UNITA_SCD','Y','3','UNITA,ACCREDITAMENTO','V_UNITA_SCD');
Insert into VGLDM.WRK_ANAGRAFICA_FLUSSI (VAL_TBL_NAME,FLG_DISPONIBILE,FLG_ORDERBY,NOTE_LISTA_FLUSSI,NOTE_LISTA_VIEW) values ('FCT_PRESENZE','Y','4','PRESENZE','V_INSERT_PRESENZE');

  
  
--------------------------------------------------------
--  DDL for View 
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW VGLDM.V_ANAGRAFICA_SCD (ID_PER, COD_DIP, COD_UNT, COD_RUOLO, COGNOME, NOME, DT_INI_UNT, TIPO_CTR, COD_CTR, COD_LIV, DT_INI_LIV, DT_INI_MNS, MATRICOLA, CF, SESSO, DT_NASCITA, TIPO_RAPP, DT_INI_TIPO_CTR, DT_FINE_TIPO_CTR, DT_INI_RAPP, DT_FINE_RAPP, AMBITO, TIPO_ASS, DT_PROROGA_TERMINE, DT_CTR_SOST_MAT, QTA_PART_TIME, TITOLARE1, TITOLARE2, MOTIVO_PROMOZIONE, FASCICOLO_AGGIORNATO, TITOLO_STUDIO, DESC_CTR, DESC_LIV) AS 
  SELECT   ID_PER,
            COD_DIP,
            COD_UNT,
            COD_RUOLO,
            COGNOME,
            NOME,
            DT_INI_UNT,
            TIPO_CTR,
            COD_CTR,
            COD_LIV,
            DT_INI_LIV,
            DT_INI_MNS,
            MATRICOLA,
            CF,
            SESSO,
            DT_NASCITA,
            TIPO_RAPP,
            DT_INI_TIPO_CTR,
            DT_FINE_TIPO_CTR,
            DT_INI_RAPP,
            DT_FINE_RAPP,
            AMBITO,
            TIPO_ASS,
            DT_PROROGA_TERMINE,
            DT_CTR_SOST_MAT,
            QTA_PART_TIME,
            TITOLARE1,
            TITOLARE2,
            MOTIVO_PROMOZIONE,
            FASCICOLO_AGGIORNATO,
            TITOLO_STUDIO,
            DESC_CTR,
            DESC_LIV
     FROM   VGLSA.GRP02_ANA
     WHERE  VGLSA.GRP02_ANA.id_per = (SELECT   id_per
                                      FROM     VGLDM.v_wrk_last_acquisizione
                                      WHERE    cod_flusso = 'ANAGRAFICA');

 /*  CREATE OR REPLACE FORCE VIEW "VGLDM"."V_INSERT_PRESENZE" ("ID_PERIOD", "ID_YEAR_MONTH", "ID_DIP", "ID_UNT", "ID_RUOLO", "OREPRES", "ORESTRAOR", "OREPERMES") AS 

  SELECT   a.id_per,
           p.id_year_month,
           b.id_dip,
           c.id_unt,
           d.id_ruolo,
           a.orepres,
           a.orestraor,
           a.orepermes
    FROM   VGLSA.GRP02_PRS a,
           VGLSA.GRP02_UNT u,
           VGLSA.GRP02_RUO m,
           D_ANAGRAFICA_SCD b,
           D_UNITA_SCD c,
           D_RUOLI_MERGE d,
           D_PERIOD p 
    WHERE  c.cod_unt = b.cod_unt
           and u.cod_unt = c.cod_unt
        AND d.cod_ruolo = b.cod_ruolo
         AND d.cod_ruolo = m.cod_ruolo
           AND  a.cf = b.cf
         AND a.data_pres = p.day
        AND a.id_per = (SELECT   id_per
                           FROM   v_wrk_last_acquisizione
                           WHERE   cod_flusso = 'PRESENZE');*/
CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGLDM"."V_INSERT_PRESENZE" ("ID_PERIOD", "ID_YEAR_MONTH", "ID_DIP", "ID_UNT", "ID_RUOLO", "OREPRES", "ORESTRAOR", "OREPERMES") AS 
  SELECT   p.id_period,
           p.id_year_month,
           b.id_dip,
           c.id_unt,
           d.id_ruolo,
           a.orepres,
           a.orestraor,
           a.orepermes
    FROM   VGLSA.GRP02_PRS a,  -- tabelle 02 delle presenze, unica select da
                               -- primo livello, questo perchè sto selezionando
                               -- i fatti, e i fatti non ci sono nelle dimensioni
           --VGLSA.GRP02_UNT u,
           --VGLSA.GRP02_RUO m,
           D_ANAGRAFICA_SCD b, -- dimensione del dipendente
           D_UNITA_SCD c,      -- dimensione delle unita
           D_RUOLI_MERGE d,    -- dimensiore dei ruoli
           D_PERIOD p          -- dimensione del periodo
    WHERE  c.cod_unt = b.cod_unt
           --and u.cod_unt = c.cod_unt
        AND d.cod_ruolo = b.cod_ruolo
        -- AND d.cod_ruolo = m.cod_ruolo
           AND  a.cf = b.cf
           and to_date(to_char(a.data_pres,'YYYYMM'),'YYYYMM') between TO_DATE(b.d_inival, 'YYYYMM') and to_date(nvl(b.d_endval,999901), 'YYYYMM')
        and to_date(to_char(a.data_pres,'YYYYMM'),'YYYYMM') between TO_DATE(c.d_inival, 'YYYYMM') and to_date(nvl(c.d_endval,999901), 'YYYYMM')
         AND a.data_pres = p.day
        AND a.id_per = (SELECT   id_per         -- seleziona solo 
                                                --righe ultima acquisizione
                           FROM   v_wrk_last_acquisizione
                           WHERE   cod_flusso = 'PRESENZE')
                           ;


  CREATE OR REPLACE FORCE VIEW VGLDM.V_RUOLI_MERGE (ID_PER, COD_RUOLO, DESC_RUOLO) AS 
  SELECT   ID_PER,
            COD_RUOLO,
            DESC_RUOLO
     FROM   VGLSA.GRP02_RUO
     WHERE  VGLSA.GRP02_RUO.ID_PER = (SELECT   ID_PER
                                      FROM     VGLDM.V_WRK_LAST_ACQUISIZIONE
                                      WHERE    COD_FLUSSO = 'RUOLI');


  CREATE OR REPLACE FORCE VIEW VGLDM.V_UNITA_SCD (ID_PER, COD_UNT, DESC_UNT, COD_ACR, DESC_ACR) AS 
  (SELECT   A.ID_PER,
            A.COD_UNT,
            A.DESC_UNT,
            C.COD_ACR,
            B.DESC_ACR
     FROM   VGLSA.GRP02_UNT A , VGLSA.COGE02_UNTACR C , VGLSA.ASL02_ACR B 
     WHERE  A.COD_UNT=C.COD_UNT(+) AND C.COD_ACR=B.COD_ACR(+) 
     
     AND   A.ID_PER = (SELECT   ID_PER
                        FROM    VGLDM.V_WRK_LAST_ACQUISIZIONE
                        WHERE   COD_FLUSSO='UNITA')
    and a.id_per = b.id_per
    and b.id_per = c.id_per);
                        


  CREATE OR REPLACE FORCE VIEW VGLDM.V_WRK_LAST_ACQUISIZIONE (COD_FLUSSO, ID_LOTTO, ID_PER) AS 
  SELECT   COD_FLUSSO, MAX (ID_RUN) AS ID_RUN, MAX (ID_PER) AS ID_PER
       FROM   VGLSA.WRK_AUDIT_CARICAMENTI
   GROUP BY   COD_FLUSSO
   ORDER BY   ID_PER DESC;
   
--------------------------------------------------------
--  DDL for Index 
--------------------------------------------------------

  CREATE UNIQUE INDEX VGLDM.UNITA_PK ON VGLDM.D_UNITA_SCD (ID_UNT);

  CREATE UNIQUE INDEX VGLDM.ANAGRAFICA_PK ON VGLDM.D_ANAGRAFICA_SCD (ID_DIP);

  CREATE UNIQUE INDEX VGLDM.PERIOD_PK ON VGLDM.D_PERIOD (ID_PERIOD);

  CREATE UNIQUE INDEX VGLDM.RUOLI_PK ON VGLDM.D_RUOLI_MERGE (ID_RUOLO);
  
--------------------------------------------------------
--  Constraints for Table 
--------------------------------------------------------

  ALTER TABLE VGLDM.D_UNITA_SCD ADD CONSTRAINT UNITA_PK PRIMARY KEY (ID_UNT)
  USING INDEX ;

  ALTER TABLE VGLDM.D_RUOLI_MERGE ADD CONSTRAINT RUOLI_PK PRIMARY KEY (ID_RUOLO)
  USING INDEX;

  ALTER TABLE VGLDM.D_PERIOD ADD CONSTRAINT PERIOD_PK PRIMARY KEY (ID_PERIOD)
  USING INDEX;
  
  ALTER TABLE VGLDM.D_ANAGRAFICA_SCD ADD CONSTRAINT ANAGRAFICA_PK PRIMARY KEY (ID_DIP)
  USING INDEX;

--------------------------------------------------------
--  DDL for Package PKG_ALIMENTAZIONE_02
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE VGLDM.PKG_ALIMENTAZIONE_02 AS
  PROCEDURE p_main;
END PKG_ALIMENTAZIONE_02;

/
--------------------------------------------------------
--  DDL for Package PKG_UTILS_02
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE VGLDM.PKG_UTILS_02 AS

    PROCEDURE p_audit_caricamenti (
      p_id_lotto   IN   NUMBER,
      p_val_tbl_name   IN   VARCHAR2,
      p_id_PER        IN   NUMBER,
      p_data_inizio    IN   DATE,
      p_data_fine      IN   DATE,
      p_cod_stato      IN   VARCHAR2,
      p_d_ins          IN   DATE
   );
   
     PROCEDURE p_audit_log (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_livello      IN   NUMBER,
      p_procedura    IN   VARCHAR2,
      p_sqlcode      IN   NUMBER,
      p_sqlerror_m   IN   VARCHAR2,
      p_stmt         IN   VARCHAR2,
      p_note         IN   VARCHAR2      
   );
   
   PROCEDURE truncate_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_nome_part    IN   VARCHAR2
   );
   
   PROCEDURE create_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_nome_part    IN   VARCHAR2
   );
   
   FUNCTION f_get_partition_name (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_id_PER      IN   NUMBER
   )
      RETURN VARCHAR2;
   
   FUNCTION f_check_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_part_name    IN   VARCHAR2
   )
      RETURN NUMBER;
      
   FUNCTION f_get_fact_table
      RETURN VARCHAR2;
   
  
END PKG_UTILS_02;

/
--------------------------------------------------------
--  DDL for Package Body PKG_ALIMENTAZIONE_02
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY VGLDM.PKG_ALIMENTAZIONE_02 
AS
   c_package   CONSTANT VARCHAR2 (30) := 'PKG_UTILS_02';
   c_debug     CONSTANT NUMBER (1)    := 1;
   c_warning   CONSTANT NUMBER (1)    := 2;
   c_error     CONSTANT NUMBER (1)    := 3;


PROCEDURE app_procedure
   IS     

      CURSOR curs_app
      IS
         SELECT *
         FROM   wrk_anagrafica_flussi
         WHERE  flg_disponibile = 'Y';

      record_app        wrk_anagrafica_flussi%ROWTYPE;
      
      v_id_lotto_app    NUMBER;
      v_id_PER         NUMBER;
      v_ini_caric_app   DATE;
      v_fin_caric_app   DATE;
      v_procedura       VARCHAR2 (255);
      v_stmt            VARCHAR2 (32767);
      v_nome_part       VARCHAR2 (30);
      v_esiste_part     VARCHAR2 (30); 
      
      
      
   BEGIN
      OPEN curs_app;
      v_id_lotto_app := seq_id_lotto.NEXTVAL;

      LOOP
         FETCH curs_app
         INTO  record_app;

         EXIT WHEN curs_app%NOTFOUND;
         
         v_ini_caric_app := SYSDATE;

         SELECT MAX (id_PER)
         INTO   v_id_PER
         FROM  V_WRK_LAST_ACQUISIZIONE; 

         PKG_UTILS_02.p_audit_log (p_id_lotto => v_id_lotto_app,
                      p_livello => c_debug,
                      p_cod_flusso => record_app.val_tbl_name,
                      p_procedura => NULL,
                      p_sqlcode => NULL,
                      p_sqlerror_m => NULL,
                      p_note => 'Inizio Caricamento LOTTO: ' ||
                       v_id_lotto_app ||
                       ' Tabella: ' ||
                       record_app.val_tbl_name,
                      p_stmt => null
                     );
                     
                     
--STEP 0 CONTROLLO PARTIZIONI

            if(record_app.val_tbl_name = PKG_UTILS_02.f_get_fact_table()) then
                 BEGIN
            v_procedura := 'create or truncate partizioni nella '|| PKG_UTILS_02.f_get_fact_table();
            v_nome_part := 
                  PKG_UTILS_02.f_get_partition_name (v_id_lotto_app,
                                        record_app.val_tbl_name,
                                        v_id_PER
                                       );
            v_esiste_part :=
               PKG_UTILS_02.f_check_partition (v_id_lotto_app,
                                  record_app.val_tbl_name,
                                  v_nome_part
                                 );
                               
            IF v_esiste_part = 1
            THEN
               PKG_UTILS_02.truncate_partition (v_id_lotto_app,
                                   record_app.val_tbl_name,
                                   v_nome_part
                                  );
            ELSE
               PKG_UTILS_02.create_partition (v_id_lotto_app,
                                 record_app.val_tbl_name,
                                 v_nome_part
                                );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
              PKG_UTILS_02.p_audit_log (p_id_lotto => v_id_lotto_app,
                            p_livello => c_error,
                            p_cod_flusso => record_app.val_tbl_name,
                            p_procedura => c_package || '.' || v_procedura,
                            p_sqlcode => SQLCODE,
                            p_sqlerror_m => SQLERRM,
                            p_note => NULL,
                            p_stmt => null
                           );       
         END;        
            end if;
         -----------------------------------------------------------------------                        
                                   
-- STEP 1 ALIMENTAZIONE DIMENSIONI 
         BEGIN
            v_procedura := 'ALIMENTAZIONE STELLA';

            SELECT val_ins_query
            INTO   v_stmt
            FROM   wrk_configurazione
            WHERE  UPPER (val_tbl_name) = UPPER (record_app.val_tbl_name);
            
            EXECUTE IMMEDIATE v_stmt;
            
            v_fin_caric_app := SYSDATE;
          
            PKG_UTILS_02.p_audit_caricamenti(p_id_lotto => v_id_lotto_app,
                                     p_val_tbl_name => record_app.val_tbl_name,
                                     p_id_PER => v_id_PER,
                                     p_data_inizio => v_ini_caric_app,
                                     p_data_fine => v_fin_caric_app,
                                     p_cod_stato => 'CARICATO',
                                     p_d_ins => SYSDATE
                                    );
            
            PKG_UTILS_02.p_audit_log (p_id_lotto => v_id_lotto_app,
                         p_livello => c_debug,
                         p_cod_flusso => record_app.val_tbl_name,
                         p_procedura => c_package || '.' || v_procedura,
                         p_sqlcode => NULL,
                         p_sqlerror_m => NULL,
                         p_note => 'esecuzione v_stmt ' ||
                          v_id_lotto_app ||
                          ' sulla Tabella: ' ||
                          record_app.val_tbl_name ||
                          ' eseguito.',
                        p_stmt => v_stmt
                        );
            COMMIT;
             EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               PKG_UTILS_02.p_audit_log
                  (p_id_lotto => v_id_lotto_app,
                   p_livello => c_error,
                   p_cod_flusso => record_app.val_tbl_name,
                   p_procedura => c_package || '.' || v_procedura,
                   p_sqlcode => SQLCODE,
                   p_sqlerror_m => SQLERRM,
                   p_note => 'Errore esecuzione v_stmt ' ||
                    v_id_lotto_app ||
                    ' sulla Tabella: ' ||
                    record_app.val_tbl_name ||
                    ' non eseguito.' ||
                    ' Dati mancanti nella tabella di configurazione.',
                   p_stmt => v_stmt
                  );
    
          END;
--STEP 2 ANALYZE TABLE  
         BEGIN
            
            v_stmt:= 'Analyze Table ' || PKG_UTILS_02.f_get_fact_table() ||
                     ' Estimate Statistics'||
                     ' Sample 5 Percent';

            EXECUTE IMMEDIATE v_stmt;
            
               PKG_UTILS_02.p_audit_log
                  (p_id_lotto => v_id_lotto_app,
                   p_livello => c_error,
                   p_cod_flusso => record_app.val_tbl_name,
                   p_procedura => c_package || '.' || v_procedura,
                   p_sqlcode => SQLCODE,
                   p_sqlerror_m => SQLERRM,
                   p_note => 'Analisi ' ||
                    v_id_lotto_app ||
                    ' sulla Tabella: ' ||
                    record_app.val_tbl_name ||
                    ' eseguita.' ,
                   p_stmt => v_stmt
                  );
            COMMIT;
         EXCEPTION
           WHEN OTHERS
            THEN
               PKG_UTILS_02.p_audit_log (p_id_lotto => v_id_lotto_app,
                            p_livello => c_error,
                            p_cod_flusso => record_app.val_tbl_name,
                            p_procedura => c_package || '.' || v_procedura,
                            p_sqlcode => SQLCODE,
                            p_sqlerror_m => SQLERRM,
                            p_note => ' Analisi della tabella ' ||
                            record_app.val_tbl_name ||
                             ' NON eseguita.',
                            p_stmt => v_stmt
                           );
                           
               COMMIT;
         END;
         
         
      END LOOP;
 
         CLOSE curs_app;
         COMMIT;
   END;
     
   PROCEDURE p_main is
    begin    
        app_procedure();        
    end;    

END;

/
--------------------------------------------------------
--  DDL for Package Body PKG_UTILS_02
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY VGLDM.PKG_UTILS_02 
AS
   c_package   CONSTANT VARCHAR2 (30) := 'PKG_UTILS_02';
   c_debug     CONSTANT NUMBER (1)    := 1;
   c_warning   CONSTANT NUMBER (1)    := 2;
   c_error     CONSTANT NUMBER (1)    := 3;

   PROCEDURE p_audit_caricamenti (
      p_id_lotto   IN   NUMBER,
      p_val_tbl_name   IN   VARCHAR2,
      p_id_PER        IN   NUMBER,
      p_data_inizio    IN   DATE,
      p_data_fine      IN   DATE,
      p_cod_stato      IN   VARCHAR2,
      p_d_ins          IN   DATE
   )
   IS
      v_procedura   VARCHAR2 (30) := 'P_AUDIT_CARICAMENTI';
   BEGIN
      INSERT INTO wrk_audit_caricamenti
                  (id_lotto,
                   val_tbl_name,
                   id_per,
                   dta_inizio,
                   dta_fine,
                   cod_stato,
                   d_ins
                  )
           VALUES (p_id_lotto,
                   p_val_tbl_name,
                   p_id_PER,
                   p_data_inizio,
                   p_data_fine,
                   p_cod_stato,
                   p_d_ins
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log
            (p_id_lotto => p_id_lotto,
             p_livello => c_error,
             p_cod_flusso => p_val_tbl_name,
             p_procedura => c_package || '.' || v_procedura,
             p_sqlcode => SQLCODE,
             p_sqlerror_m => SQLERRM,
             p_note => 'Errore nella insert della tabella WRK_AUDIT_CARICAMENTI',
             p_stmt => null
            );
   END;
  PROCEDURE p_audit_log (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_livello      IN   NUMBER,
      p_procedura    IN   VARCHAR2,
      p_sqlcode      IN   NUMBER,
      p_sqlerror_m   IN   VARCHAR2,
      p_stmt         IN   VARCHAR2,
      p_note         IN   VARCHAR2   
   )
   IS
   BEGIN
      INSERT INTO wrk_audit_log
                  (id_log,
                   id_lotto,
                   cod_flusso,
                   livello,
                   procedura,
                   sql_code,
                   error_message,
                   stmt,
                   note,
                   d_ins                  
                  )
           VALUES (seq_wrk_audit_log.NEXTVAL,
                   p_id_lotto,
                   p_cod_flusso,
                   p_livello,
                   p_procedura,
                   p_sqlcode,
                   p_sqlerror_m,
                   p_stmt,
                   p_note,
                   SYSDATE                                 
                  );

      COMMIT;
   END; 
   --Funzione che restituisce il nome di una partizione
   FUNCTION f_get_partition_name (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_id_PER      IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      v_procedura   VARCHAR2 (30) := 'F_GET_PARTITION_NAME';
      v_part_name   VARCHAR2 (10);
   BEGIN
      v_part_name := 'P_' || TO_CHAR (p_id_per);
      RETURN v_part_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log (p_id_lotto => p_id_lotto,
                      p_livello => c_error,
                      p_cod_flusso => p_cod_flusso,
                      p_procedura => c_package || '.' || v_procedura,
                      p_sqlcode => SQLCODE,
                      p_sqlerror_m => SQLERRM,
                      p_note => NULL,
                      p_stmt => null
                     );
         RETURN NULL;
   END;
   
 -- funzione che controlla l'esistenza di una specifica partizione nella fact table
   FUNCTION f_check_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_part_name    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      v_procedura       VARCHAR2 (30) := 'F_CHECK_PARTITION';
      nome_tabella      VARCHAR2 (30);
      nome_partizione   VARCHAR2 (30);
      nome_fact_table   VARCHAR2 (200 BYTE) := f_get_fact_table();
   BEGIN
      SELECT table_name,
             partition_name
      INTO   nome_tabella,
             nome_partizione
      FROM   user_tab_partitions
      WHERE  table_name = nome_fact_table 
      AND    partition_name = p_part_name;

      RETURN 1;              
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log
                    (p_id_lotto => p_id_lotto,
                     p_livello => c_warning,
                     p_cod_flusso => p_cod_flusso,
                     p_procedura => c_package || '.' || v_procedura,
                     p_sqlcode => SQLCODE,
                     p_sqlerror_m => SQLERRM,
                     p_note => 'La partizione ' ||
                      p_part_name ||
                      ' non esiste oppure la tab storica non esiste',
                     p_stmt => 'SELECT table_name,partition_name 
                                INTO nome_tabella, nome_partizione
                                FROM   user_tab_partitions
                                WHERE  table_name = ' || nome_fact_table
                    );
         RETURN 0;
      WHEN OTHERS
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log
            (p_id_lotto => p_id_lotto,
             p_livello => c_error,
             p_cod_flusso => p_cod_flusso,
             p_procedura => c_package || '.' || v_procedura,
             p_sqlcode => SQLCODE,
             p_sqlerror_m => SQLERRM,
             p_note => 'Errore nella funzione che controlla l''esistenza della partizione con nome:' ||
              p_part_name,
             p_stmt => 'SELECT table_name,partition_name 
                        INTO nome_tabella, nome_partizione
                        FROM   user_tab_partitions
                        WHERE  table_name = '|| nome_fact_table
            );
         RETURN 0;
   END;  
   
   -- procedura che di troncare una specifica partizione della fact table
   PROCEDURE truncate_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_nome_part    IN   VARCHAR2
   )
   IS
      v_procedura       VARCHAR2 (255)   := 'TRUNCATE_PARTITION';
      v_stmt            VARCHAR2 (32767);
      nome_fact_table   VARCHAR2 (200 BYTE) := f_get_fact_table();
   BEGIN
      v_stmt :=
         'ALTER TABLE ' ||
        nome_fact_table|| 
         ' TRUNCATE PARTITION ' ||
         p_nome_part;

      EXECUTE IMMEDIATE v_stmt;

      VGLDM.PKG_UTILS_02.p_audit_log
               (p_id_lotto => p_id_lotto,
                p_livello => c_debug,
                p_cod_flusso => p_cod_flusso,
                p_procedura => c_package || '.' || v_procedura,
                p_sqlcode => NULL,
                p_sqlerror_m => NULL,
                p_note => 'Troncata la partizione ' ||
                 p_nome_part ||
                 ' dalla tabella ' || nome_fact_table,
                p_stmt => v_stmt
               );
   EXCEPTION
      WHEN OTHERS
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log (p_id_lotto => p_id_lotto,
                      p_livello => c_error,
                      p_cod_flusso => p_cod_flusso,
                      p_procedura => c_package || '.' || v_procedura,
                      p_sqlcode => SQLCODE,
                      p_sqlerror_m => SQLERRM,
                      p_note => NULL,
                      p_stmt => v_stmt
                     );
   END;
   
   -- procedura che crea una partizione sulle fact table
   PROCEDURE create_partition (
      p_id_lotto     IN   NUMBER,
      p_cod_flusso   IN   VARCHAR2,
      p_nome_part    IN   VARCHAR2
   )
   IS
      v_procedura       VARCHAR2 (255)   := 'CREATE_PARTITION';
      v_stmt            VARCHAR2 (32767);
      nome_fact_table   VARCHAR2 (200 BYTE) := f_get_fact_table();
   BEGIN
      v_stmt :=
         'ALTER TABLE ' || nome_fact_table ||
         ' SPLIT PARTITION QZP_PALTRI' ||
         ' VALUES (' ||
         TO_NUMBER (SUBSTR (p_nome_part,
                            3,
                            10
                           )) ||
         ')' ||
         ' INTO (PARTITION ' ||
         p_nome_part ||
         ', PARTITION QZP_PALTRI)';

      EXECUTE IMMEDIATE v_stmt;

      VGLDM.PKG_UTILS_02.p_audit_log
               (p_id_lotto => p_id_lotto,
                p_livello => c_debug,
                p_cod_flusso => p_cod_flusso,
                p_procedura => c_package || '.' || v_procedura,
                p_sqlcode => NULL,
                p_sqlerror_m => NULL,
                p_note => 'Create partizione ' ||
                 p_nome_part ||
                 ' nella tabella ' || nome_fact_table,
                p_stmt => v_stmt
               );
   EXCEPTION
      WHEN OTHERS
      THEN
         VGLDM.PKG_UTILS_02.p_audit_log (p_id_lotto => p_id_lotto,
                      p_livello => c_error,
                      p_cod_flusso => p_cod_flusso,
                      p_procedura => c_package || '.' || v_procedura,
                      p_sqlcode => SQLCODE,
                      p_sqlerror_m => SQLERRM,
                      p_note => 'Problemi nella creazione della partizione',
                      p_stmt => v_stmt
                     );
   END;
   
   
   FUNCTION f_get_fact_table
      RETURN VARCHAR2
      IS
        v_table_name      VARCHAR2 (200 BYTE);
      BEGIN
      
          SELECT UPPER(TRIM(VAL_TBL_NAME))INTO v_table_name
          FROM WRK_ANAGRAFICA_FLUSSI
          WHERE UPPER(TRIM(VAL_TBL_NAME)) LIKE 'FCT%';
          
          RETURN v_table_name;
      
      END;
END;

/
--------------------------------------------------------
--  DDL for Procedure P_LOAD_ANA_SCD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE VGLDM.P_LOAD_ANA_SCD 
IS
  CURSOR c1
  IS
    SELECT  ID_PER,
            COD_DIP,
            COD_UNT,
            COD_RUOLO,
            COGNOME,
            NOME,
            DT_INI_UNT,
            TIPO_CTR,
            COD_CTR,
            COD_LIV,
            DT_INI_LIV,
            DT_INI_MNS,
            MATRICOLA,
            CF,
            SESSO,
            DT_NASCITA,
            TIPO_RAPP,
            DT_INI_TIPO_CTR,
            DT_FINE_TIPO_CTR,
            DT_INI_RAPP,
            DT_FINE_RAPP,
            AMBITO,
            TIPO_ASS,
            DT_PROROGA_TERMINE,
            DT_CTR_SOST_MAT,
            QTA_PART_TIME,
            TITOLARE1,
            TITOLARE2,
            MOTIVO_PROMOZIONE,
            FASCICOLO_AGGIORNATO,
            TITOLO_STUDIO,
            DESC_CTR,
            DESC_LIV
    FROM    VGLDM.V_ANAGRAFICA_SCD;
  
  r1 c1%ROWTYPE;
  v_ID_DIP          VGLDM.D_ANAGRAFICA_SCD.ID_DIP%TYPE;
  v_COD_UNT         VGLDM.D_ANAGRAFICA_SCD.COD_UNT%TYPE;
  v_COD_RUOLO       VGLDM.D_ANAGRAFICA_SCD.COD_RUOLO%TYPE;
  
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO r1;
    EXIT
  WHEN c1%NOTFOUND;
    
    BEGIN
      SELECT ID_DIP,COD_UNT,COD_RUOLO
      INTO   v_ID_DIP,v_COD_UNT,v_COD_RUOLO
      FROM   D_ANAGRAFICA_SCD
      WHERE  COD_DIP  = r1.COD_DIP
      AND    D_ENDVAL  IS NULL;

     --SYS.DBMS_OUTPUT.PUT_LINE (' dipendente  ' ||r1.COD_DIP || v_COD_UNT || r1.COD_UNT || r1.COD_RUOLO || v_COD_RUOLO);
     BEGIN --BLOCCO IF
     IF (v_COD_UNT != r1.COD_UNT or v_COD_RUOLO != r1.COD_RUOLO ) 
        THEN
            
            SYS.DBMS_OUTPUT.PUT_LINE ('storicizzo'   );
             
            UPDATE D_ANAGRAFICA_SCD
            SET    D_ENDVAL = TO_number(TO_CHAR(ADD_MONTHS(to_date(r1.ID_PER,'YYYYMM'),-1),'YYYYMM')),
                   D_UPD = sysdate
            WHERE  ID_DIP = v_ID_DIP; 

            INSERT
            INTO D_ANAGRAFICA_SCD
              (
                ID_DIP,
                COD_DIP,
                COD_UNT,
                COD_RUOLO,
                COGNOME,
                NOME,
                DT_INI_UNT,
                TIPO_CTR,
                COD_CTR,
                COD_LIV,
                DT_INI_LIV,
                DT_INI_MNS,
                MATRICOLA,
                CF,
                SESSO,
                DT_NASCITA,
                TIPO_RAPP,
                DT_INI_TIPO_CTR,
                DT_FINE_TIPO_CTR,
                DT_INI_RAPP,
                DT_FINE_RAPP,
                AMBITO,
                TIPO_ASS,
                DT_PROROGA_TERMINE,
                DT_CTR_SOST_MAT,
                QTA_PART_TIME,
                TITOLARE1,
                TITOLARE2,
                MOTIVO_PROMOZIONE,
                FASCICOLO_AGGIORNATO,
                TITOLO_STUDIO,
                DESC_LIV,
                D_INIVAL,
                D_ENDVAL,
                D_INS,
                D_UPD,
                LAST_ID_PER
              )
              VALUES
              ( seq_ID_ANA_SCD.NEXTVAL,
                r1.COD_DIP ,
                r1.COD_UNT,
                r1.COD_RUOLO,
                r1.COGNOME,
                r1.NOME,
                r1.DT_INI_UNT,
                r1.TIPO_CTR,
                r1.COD_CTR,
                r1.COD_LIV,
                r1.DT_INI_LIV,
                r1.DT_INI_MNS,
                r1.MATRICOLA,
                r1.CF,
                r1.SESSO,
                r1.DT_NASCITA,
                r1.TIPO_RAPP,
                r1.DT_INI_TIPO_CTR,
                r1.DT_FINE_TIPO_CTR,
                r1.DT_INI_RAPP,
                r1.DT_FINE_RAPP,
                r1.AMBITO,
                r1.TIPO_ASS,
                r1.DT_PROROGA_TERMINE,
                r1.DT_CTR_SOST_MAT,
                r1.QTA_PART_TIME,
                r1.TITOLARE1,
                r1.TITOLARE2,
                r1.MOTIVO_PROMOZIONE,
                r1.FASCICOLO_AGGIORNATO,
                r1.TITOLO_STUDIO,
                r1.DESC_LIV,
                r1.id_per,
                NULL,
                SYSDATE,
                NULL,
                r1.ID_PER
              );
        
      ELSE
        
           UPDATE  D_ANAGRAFICA_SCD
           SET     TIPO_CTR =              r1.TIPO_CTR,
                   COD_CTR =               r1.COD_CTR,
                   COD_LIV =               r1.COD_CTR,
                   DT_INI_LIV =            r1.DT_INI_LIV,
                   DT_INI_MNS =            r1.DT_INI_MNS,
                   TIPO_RAPP =             r1.TIPO_RAPP,
                   DT_INI_TIPO_CTR =       r1.DT_INI_TIPO_CTR,
                   DT_FINE_TIPO_CTR =      r1.DT_FINE_TIPO_CTR,
                   DT_INI_RAPP =           r1.DT_INI_RAPP,
                   DT_FINE_RAPP =          r1.DT_FINE_RAPP,
                   AMBITO =                r1.AMBITO,
                   TIPO_ASS =              r1.TIPO_ASS,
                   DT_PROROGA_TERMINE =    r1.DT_PROROGA_TERMINE,
                   DT_CTR_SOST_MAT =       r1.DT_CTR_SOST_MAT,
                   QTA_PART_TIME =         r1.QTA_PART_TIME,
                   TITOLARE1 =             r1.TITOLARE1,
                   TITOLARE2 =             r1.TITOLARE2,
                   MOTIVO_PROMOZIONE =     r1.MOTIVO_PROMOZIONE,
                   FASCICOLO_AGGIORNATO =  r1.FASCICOLO_AGGIORNATO,
                   TITOLO_STUDIO =         r1.TITOLO_STUDIO,
                   DESC_LIV =              r1.DESC_LIV,
                   D_UPD =                 SYSDATE,
                   LAST_ID_PER =           r1.ID_PER
           WHERE   ID_DIP  = v_ID_DIP;
    
      END IF;
      END;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    begin
    INSERT
      INTO D_ANAGRAFICA_SCD
              (
                ID_DIP,
                COD_DIP,
                COD_UNT,
                COD_RUOLO,
                COGNOME,
                NOME,
                DT_INI_UNT,
                TIPO_CTR,
                COD_CTR,
                COD_LIV,
                DT_INI_LIV,
                DT_INI_MNS,
                MATRICOLA,
                CF,
                SESSO,
                DT_NASCITA,
                TIPO_RAPP,
                DT_INI_TIPO_CTR,
                DT_FINE_TIPO_CTR,
                DT_INI_RAPP,
                DT_FINE_RAPP,
                AMBITO,
                TIPO_ASS,
                DT_PROROGA_TERMINE,
                DT_CTR_SOST_MAT,
                QTA_PART_TIME,
                TITOLARE1,
                TITOLARE2,
                MOTIVO_PROMOZIONE,
                FASCICOLO_AGGIORNATO,
                TITOLO_STUDIO,
                DESC_LIV,
                D_INIVAL,
                D_ENDVAL,
                D_INS,
                D_UPD,
                LAST_ID_PER
              )
              VALUES
              ( seq_ID_ANA_SCD.NEXTVAL,
                r1.COD_DIP ,
                r1.COD_UNT,
                r1.COD_RUOLO ,
                r1.COGNOME,
                r1.NOME,
                r1.DT_INI_UNT,
                r1.TIPO_CTR,
                r1.COD_CTR,
                r1.COD_LIV,
                r1.DT_INI_LIV,
                r1.DT_INI_MNS,
                r1.MATRICOLA,
                r1.CF,
                r1.SESSO,
                r1.DT_NASCITA,
                r1.TIPO_RAPP,
                r1.DT_INI_TIPO_CTR,
                r1.DT_FINE_TIPO_CTR,
                r1.DT_INI_RAPP,
                r1.DT_FINE_RAPP,
                r1.AMBITO,
                r1.TIPO_ASS,
                r1.DT_PROROGA_TERMINE,
                r1.DT_CTR_SOST_MAT,
                r1.QTA_PART_TIME,
                r1.TITOLARE1,
                r1.TITOLARE2,
                r1.MOTIVO_PROMOZIONE,
                r1.FASCICOLO_AGGIORNATO,
                r1.TITOLO_STUDIO,
                r1.DESC_LIV,
                r1.id_per,
                NULL,
                SYSDATE,
                NULL,
                r1.ID_PER
              );
    end;
              
    END;
    
  END LOOP;
  
  COMMIT; 
  CLOSE c1;
EXCEPTION
WHEN OTHERS THEN
  begin
    ROLLBACK;
  end;
END;

/
--------------------------------------------------------
--  DDL for Procedure P_LOAD_PERIOD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE VGLDM.P_LOAD_PERIOD (p_from NUMBER, p_to NUMBER)
IS
 i DATE;
 v_proc VARCHAR2 (200);
 p_to_date DATE;
 v_flag_holiday number(1);
 v_semester number(1);
BEGIN
 v_proc := 'TRUNCATE TABLE D_PERIOD';
 EXECUTE IMMEDIATE v_proc;
 i := TO_DATE (p_from, 'yyyymmdd');
 p_to_date := TO_DATE (p_to, 'yyyymmdd');
 WHILE i <= p_to_date
 LOOP

 i := i + 1;
 -- in inglese 'SUN' e 'SAT'
 IF TO_CHAR (i, 'DY') = 'SAB' OR TO_CHAR (i, 'DY') = 'DOM' THEN
    v_flag_holiday:=1;
 ELSE 
    v_flag_holiday:=0;
 END IF;
 
 IF TO_NUMBER (TO_CHAR (i, 'MM'))<7 THEN
 v_semester:=1;
 ELSE 
 v_semester:=0;
 END IF;
 
 
 INSERT INTO VGLDM.D_PERIOD(ID_PERIOD,ID_YEAR_MONTH, DAY, DAY_OF_WEEK, DAY_OF_MONTH,DAY_OF_YEAR ,DAY_NAME, DAY_NAMES,FLAG_H ,WEEK_OF_MONTH ,
            WEEK_OF_YEAR ,MONTH_NUM , MONTH_NUMC, MONTH_NAME, MONTH_NAMES, QUARTER ,SEMESTER, YEAR_NUM)
 VALUES (
 TO_NUMBER(TO_CHAR(i,'YYYYMMDD')),
 TO_NUMBER(TO_CHAR(i,'YYYYMM')),
 i,
 TO_NUMBER (TO_CHAR (i, 'D')), 
 TO_NUMBER (TO_CHAR (i, 'DD')),
 TO_NUMBER (TO_CHAR (i, 'DDD')),
 TO_CHAR (i, 'DAY'),
 TO_CHAR (i, 'DY'),
 v_flag_holiday,
 TO_NUMBER (TO_CHAR (i, 'W')),
 TO_NUMBER (TO_CHAR (i, 'IW')), 
 TO_NUMBER (TO_CHAR (i, 'MM')),
 TO_CHAR (i, 'MM'), 
 TO_CHAR (i, 'MONTH'),
 TO_CHAR (i, 'MON'), 
 TO_NUMBER (TO_CHAR (i, 'Q')),
 v_semester,
 TO_CHAR (i, 'YYYY'));
 
 END LOOP;
END p_load_period;



/
--------------------------------------------------------
--  DDL for Procedure P_LOAD_UNITA_SCD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE VGLDM.P_LOAD_UNITA_SCD 
IS
  CURSOR c1
  IS
    SELECT  COD_UNT,
            DESC_UNT,
            COD_ACR,
            DESC_ACR,
            ID_PER
    FROM VGLDM.V_UNITA_SCD;
  
  r1 c1%ROWTYPE;
  v_ID_UNT          VGLDM.D_UNITA_SCD.ID_UNT%TYPE;
  v_COD_ACR         VGLDM.D_UNITA_SCD.COD_ACR%TYPE;
  
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO r1;
    EXIT
  WHEN c1%NOTFOUND;
    BEGIN
    
      SELECT ID_UNT,COD_ACR
      INTO   v_ID_UNT,v_COD_ACR
      FROM VGLDM.D_UNITA_SCD
      WHERE COD_UNT  = r1.COD_UNT
      AND D_ENDVAL  IS NULL;

     SYS.DBMS_OUTPUT.PUT_LINE (' unita  ' ||r1.COD_UNT || r1.DESC_UNT || v_COD_ACR || r1.COD_ACR   );
          
      IF (nvl(v_COD_ACR, -99) != nvl(r1.COD_ACR, -99)) 
        THEN
         BEGIN
             
             UPDATE VGLDM.D_UNITA_SCD
              SET D_ENDVAL = TO_number(TO_CHAR(ADD_MONTHS(to_date(r1.ID_PER,'YYYYMM'),-1),'YYYYMM')),
                  D_UPD = sysdate
             WHERE ID_UNT = v_ID_UNT; 
      
            INSERT
            INTO VGLDM.D_UNITA_SCD
              (
                ID_UNT,
                COD_UNT,
                DESC_UNT,
                COD_ACR,
                DESC_ACR,
                D_INIVAL,
                D_ENDVAL,
                D_INS,
                D_UPD,
                LAST_ID_PER
              )
              VALUES
              ( seq_ID_UNT_SCD.NEXTVAL,
                r1.COD_UNT ,
                r1.DESC_UNT,
                r1.COD_ACR ,
                r1.DESC_ACR ,
                r1.id_per,
                NULL,
                SYSDATE,
                NULL,
                r1.id_PER
              );
      
     END;   
      ELSE
      begin
        
        UPDATE VGLDM.D_UNITA_SCD
         SET DESC_UNT    = r1.DESC_UNT,
             DESC_ACR    = r1.DESC_ACR,
             d_upd       = SYSDATE,
             LAST_ID_PER = r1.ID_PER
        WHERE id_UNT  = v_ID_UNT;
    
      end;
      END IF;
      
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    BEGIN
   SYS.DBMS_OUTPUT.PUT_LINE ('errore NO_DATA_FOUND');
      INSERT
      INTO D_UNITA_SCD
        (
          ID_UNT,
          COD_UNT,
          DESC_UNT,
          COD_ACR,
          DESC_ACR,
          D_INIVAL,
          D_ENDVAL,
          D_INS,
          D_UPD,
          LAST_ID_PER
        )
        VALUES
        ( seq_ID_UNT_SCD.NEXTVAL,
          r1.COD_UNT ,
          r1.DESC_UNT,
          r1.COD_ACR ,
          r1.DESC_ACR ,
          r1.id_per,
          NULL,
          SYSDATE,
          NULL,
          r1.ID_PER
        );
        COMMIT;
      END;
    END;
  END LOOP;
  COMMIT;
  CLOSE c1;
EXCEPTION
WHEN OTHERS THEN
  begin
    SYS.DBMS_OUTPUT.PUT_LINE ('errore OTHERS');
    ROLLBACK;
  end;
END;

/
--------------------------------------------------------
--  ESEGUIRE P_LOAD_PERIOD:
--------------------------------------------------------

BEGIN 
  vgldm.p_load_period(20081231, 20191230);
  COMMIT; 
END;

/******************************************************************************

    Per eseguire il PACKAGE Alimentazione02 connettersi a VGLDM e lanciare:
	
	        execute vgldm.pkg_alimentazione_02.p_main();
 
******************************************************************************/ 
