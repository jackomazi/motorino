/* Creazione utente VGLSA
*/

DROP USER vglsa CASCADE;

CREATE USER vglsa IDENTIFIED BY vglsa;

GRANT connect, resource, dba TO vglsa;

/* Creazione directory
   Nella directory VGL si trovano altre tre directory (asl, coge e grp)
   che corrispondono ai diversi flussi gestionali (accreditamenti, pinzettature e presenze)
   ognuno dei quali contiene a sua volta le tre directory: 
   - data (che contiene i file dei flussi di dati),
   - bad (che contiene i file con gli scarti di conversione) e
   - log (che contiene i file di log).
   Bisogna creare le directory oracle associate a queste tre directory e 
   assegnargli il path che permette di trovarle.
*/

CREATE OR REPLACE DIRECTORY asl_data_dir AS 'c:\vgl\asl\data';
CREATE OR REPLACE DIRECTORY asl_bad_dir AS 'c:\vgl\asl\bad';
CREATE OR REPLACE DIRECTORY asl_log_dir AS 'c:\vgl\asl\log';
CREATE OR REPLACE DIRECTORY coge_data_dir AS 'c:\vgl\coge\data';
CREATE OR REPLACE DIRECTORY coge_bad_dir AS 'c:\vgl\coge\bad';
CREATE OR REPLACE DIRECTORY coge_log_dir AS 'c:\vgl\coge\log';
CREATE OR REPLACE DIRECTORY grp_data_dir AS 'c:\vgl\grp\data';
CREATE OR REPLACE DIRECTORY grp_bad_dir AS 'c:\vgl\grp\bad';
CREATE OR REPLACE DIRECTORY grp_log_dir AS 'c:\vgl\grp\log';
CREATE OR REPLACE DIRECTORY flussi AS 'C:\vgl\script_elenco_flussi\Flussi';
CREATE OR REPLACE DIRECTORY flussi_log AS 'C:\vgl\script_elenco_flussi\Flussi_log';

/* Assegnazione privilegi utente VGLSA
*/

GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.ASL_DATA_DIR TO VGLSA WITH GRANT OPTION;  
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.ASL_BAD_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.ASL_LOG_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.COGE_DATA_DIR TO VGLSA WITH GRANT OPTION;  
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.COGE_BAD_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.COGE_LOG_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.GRP_DATA_DIR TO VGLSA WITH GRANT OPTION;  
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.GRP_BAD_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.GRP_LOG_DIR TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.FLUSSI TO VGLSA WITH GRANT OPTION;
GRANT EXECUTE, READ, WRITE ON DIRECTORY SYS.FLUSSI_LOG TO VGLSA WITH GRANT OPTION;

/* Creazione sequence
*/

CREATE SEQUENCE vglsa.seq_id_caricamenti;
CREATE SEQUENCE vglsa.seq_id_run;
CREATE SEQUENCE vglsa.seq_id_master;
CREATE SEQUENCE vglsa.seq_id_log;

/* Creazione tabelle
*/

CREATE TABLE vglsa.asl00_acr (
    cod_acr  VARCHAR2(100 BYTE),
    desc_acr VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY asl_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE asl_bad_dir : 'ASL00_ACR_SCARTI'
            NODISCARDFILE
            LOGFILE asl_log_dir : 'ASL00_ACR_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( asl_data_dir : 'accreditamenti.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.asl00_acrper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY asl_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE asl_bad_dir : 'ASL00_ACRPER_SCARTI'
            NODISCARDFILE
            LOGFILE asl_log_dir : 'ASL00_ACRPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( asl_data_dir : 'accreditamenti.csv' )
);

CREATE TABLE vglsa.asl01_acr (
    id_per   NUMBER(6, 0),
    cod_acr  VARCHAR2(10 BYTE),
    desc_acr VARCHAR2(100 BYTE)
);

CREATE TABLE vglsa.asl01_acr_scarti (
    id_run   NUMBER,
    id_per   VARCHAR2(100 BYTE),
    cod_acr  VARCHAR2(100 BYTE),
    desc_acr VARCHAR2(100 BYTE),
    d_ins    DATE DEFAULT sysdate
);

CREATE TABLE vglsa.asl02_acr (
    id_per   NUMBER(6, 0),
    cod_acr  VARCHAR2(10 BYTE),
    desc_acr VARCHAR2(100 BYTE)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.coge00_untacr (
    cod_unt VARCHAR2(100 BYTE),
    cod_acr VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY coge_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE coge_bad_dir : 'COGE00_UNTACR_SCARTI'
            NODISCARDFILE
            LOGFILE coge_log_dir : 'COGE00_UNTACR_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( coge_data_dir : 'untacr.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.coge00_untacrper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY coge_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE coge_bad_dir : 'COGE00_UNTACRPER_SCARTI'
            NODISCARDFILE
            LOGFILE coge_log_dir : 'COGE00_UNTACRPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( coge_data_dir : 'untacr.csv' )
);

CREATE TABLE vglsa.coge01_untacr (
    id_per  NUMBER(6, 0),
    cod_unt NUMBER(5, 0),
    cod_acr VARCHAR2(10 BYTE)
);

CREATE TABLE vglsa.coge01_untacr_scarti (
    id_run  NUMBER,
    id_per  VARCHAR2(100 BYTE),
    cod_unt VARCHAR2(100 BYTE),
    cod_acr VARCHAR2(100 BYTE),
    d_ins   DATE DEFAULT sysdate
);

CREATE TABLE vglsa.coge02_untacr (
    id_per  NUMBER(6, 0),
    cod_unt NUMBER(5, 0),
    cod_acr VARCHAR2(10 BYTE)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.grp00_ana (
    cod_dip              VARCHAR2(100 BYTE),
    cod_unt              VARCHAR2(100 BYTE),
    cod_ruolo            VARCHAR2(100 BYTE),
    cognome              VARCHAR2(100 BYTE),
    nome                 VARCHAR2(100 BYTE),
    dt_ini_unt           VARCHAR2(100 BYTE),
    tipo_ctr             VARCHAR2(100 BYTE),
    cod_ctr              VARCHAR2(100 BYTE),
    cod_liv              VARCHAR2(100 BYTE),
    dt_ini_liv           VARCHAR2(100 BYTE),
    dt_ini_mns           VARCHAR2(100 BYTE),
    matricola            VARCHAR2(100 BYTE),
    cf                   VARCHAR2(100 BYTE),
    sesso                VARCHAR2(100 BYTE),
    dt_nascita           VARCHAR2(100 BYTE),
    tipo_rapp            VARCHAR2(100 BYTE),
    dt_ini_tipo_ctr      VARCHAR2(100 BYTE),
    dt_fine_tipo_ctr     VARCHAR2(100 BYTE),
    dt_ini_rapp          VARCHAR2(100 BYTE),
    dt_fine_rapp         VARCHAR2(100 BYTE),
    ambito               VARCHAR2(100 BYTE),
    tipo_ass             VARCHAR2(100 BYTE),
    dt_proroga_termine   VARCHAR2(100 BYTE),
    dt_ctr_sost_mat      VARCHAR2(100 BYTE),
    qta_part_time        VARCHAR2(100 BYTE),
    titolare1            VARCHAR2(100 BYTE),
    titolare2            VARCHAR2(100 BYTE),
    motivo_promozione    VARCHAR2(100 BYTE),
    fascicolo_aggiornato VARCHAR2(100 BYTE),
    titolo_studio        VARCHAR2(100 BYTE),
    desc_ctr             VARCHAR2(100 BYTE),
    desc_liv             VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_ANA_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_ANA_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'anagrafica.csv' )
) REJECT LIMIT 10;

CREATE TABLE "VGLSA"."GRP00_ANA_LOG" (
    "TESTO" VARCHAR2(4000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY "GRP_LOG_DIR" ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( "GRP_LOG_DIR" : 'GRP00_ANA_LOG.log' )
);

CREATE TABLE "VGLSA"."GRP00_ANA_BAD" (
    "TESTO" VARCHAR2(4000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY "GRP_BAD_DIR" ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( "GRP_BAD_DIR" : 'GRP00_ANA_SCARTI.bad' )
);

CREATE TABLE vglsa.grp00_anaper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_ANAPER_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_ANAPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'anagrafica.csv' )
);

CREATE TABLE "VGLSA"."GRP00_ANAPER_LOG" (
    "TESTO" VARCHAR2(4000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY "GRP_LOG_DIR" ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( "GRP_LOG_DIR" : 'GRP00_ANAPER_LOG.log' )
); 	

CREATE TABLE "VGLSA"."GRP00_ANAPER_BAD" (
    "TESTO" VARCHAR2(4000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY "GRP_BAD_DIR" ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( "GRP_BAD_DIR" : 'GRP00_ANAPER_SCARTI.bad' )
); 		

CREATE TABLE vglsa.grp00_prs (
    matricola VARCHAR2(100 BYTE),
    cf        VARCHAR2(100 BYTE),
    data_pres VARCHAR2(100 BYTE),
    orepres   VARCHAR2(100 BYTE),
    orestraor VARCHAR2(100 BYTE),
    orepermes VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_PRS_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_PRS_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'presenze.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.grp00_prsper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_PRSPER_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_PRSPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'presenze.csv' )
);

CREATE TABLE vglsa.grp00_ruo (
    cod_ruolo  VARCHAR2(100 BYTE),
    desc_ruolo VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_RUO_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_RUO_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'ruoli.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.grp00_ruoper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_RUOPER_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_RUOPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'ruoli.csv' )
);

CREATE TABLE vglsa.grp00_unt (
    cod_unt  VARCHAR2(100 BYTE),
    desc_unt VARCHAR2(100 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_UNT_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_UNT_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'unita.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.grp00_untper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_UNTPER_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_UNTPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'unita.csv' )
);

CREATE TABLE vglsa.grp01_ana (
    id_per               NUMBER(6, 0),
    cod_dip              NUMBER(5, 0),
    cod_unt              NUMBER(5, 0),
    cod_ruolo            VARCHAR2(10 BYTE),
    cognome              VARCHAR2(50 BYTE),
    nome                 VARCHAR2(50 BYTE),
    dt_ini_unt           DATE,
    tipo_ctr             VARCHAR2(50 BYTE),
    cod_ctr              VARCHAR2(10 BYTE),
    cod_liv              VARCHAR2(10 BYTE),
    dt_ini_liv           DATE,
    dt_ini_mns           DATE,
    matricola            VARCHAR2(10 BYTE),
    cf                   VARCHAR2(16 BYTE),
    sesso                VARCHAR2(10 BYTE),
    dt_nascita           DATE,
    tipo_rapp            VARCHAR2(10 BYTE),
    dt_ini_tipo_ctr      DATE,
    dt_fine_tipo_ctr     DATE,
    dt_ini_rapp          DATE,
    dt_fine_rapp         DATE,
    ambito               VARCHAR2(10 BYTE),
    tipo_ass             VARCHAR2(10 BYTE),
    dt_proroga_termine   DATE,
    dt_ctr_sost_mat      DATE,
    qta_part_time        VARCHAR2(10 BYTE),
    titolare1            VARCHAR2(50 BYTE),
    titolare2            VARCHAR2(50 BYTE),
    motivo_promozione    VARCHAR2(50 BYTE),
    fascicolo_aggiornato VARCHAR2(50 BYTE),
    titolo_studio        VARCHAR2(10 BYTE),
    desc_ctr             VARCHAR2(50 BYTE),
    desc_liv             VARCHAR2(50 BYTE)
);

CREATE TABLE vglsa.grp01_ana_scarti (
    id_run               NUMBER,
    id_per               VARCHAR2(100 BYTE),
    cod_dip              VARCHAR2(100 BYTE),
    cod_unt              VARCHAR2(100 BYTE),
    cod_ruolo            VARCHAR2(100 BYTE),
    cognome              VARCHAR2(100 BYTE),
    nome                 VARCHAR2(100 BYTE),
    dt_ini_unt           VARCHAR2(100 BYTE),
    tipo_ctr             VARCHAR2(100 BYTE),
    cod_ctr              VARCHAR2(100 BYTE),
    cod_liv              VARCHAR2(100 BYTE),
    dt_ini_liv           VARCHAR2(100 BYTE),
    dt_ini_mns           VARCHAR2(100 BYTE),
    matricola            VARCHAR2(100 BYTE),
    cf                   VARCHAR2(100 BYTE),
    sesso                VARCHAR2(100 BYTE),
    dt_nascita           VARCHAR2(100 BYTE),
    tipo_rapp            VARCHAR2(100 BYTE),
    dt_ini_tipo_ctr      VARCHAR2(100 BYTE),
    dt_fine_tipo_ctr     VARCHAR2(100 BYTE),
    dt_ini_rapp          VARCHAR2(100 BYTE),
    dt_fine_rapp         VARCHAR2(100 BYTE),
    ambito               VARCHAR2(100 BYTE),
    tipo_ass             VARCHAR2(100 BYTE),
    dt_proroga_termine   VARCHAR2(100 BYTE),
    dt_ctr_sost_mat      VARCHAR2(100 BYTE),
    qta_part_time        VARCHAR2(100 BYTE),
    titolare1            VARCHAR2(100 BYTE),
    titolare2            VARCHAR2(100 BYTE),
    motivo_promozione    VARCHAR2(100 BYTE),
    fascicolo_aggiornato VARCHAR2(100 BYTE),
    titolo_studio        VARCHAR2(100 BYTE),
    desc_ctr             VARCHAR2(100 BYTE),
    desc_liv             VARCHAR2(100 BYTE),
    d_ins                DATE DEFAULT sysdate
);

CREATE TABLE vglsa.grp01_prs (
    id_per    NUMBER(6, 0),
    matricola NUMBER(5, 0),
    cf        VARCHAR2(100 BYTE),
    data_pres DATE,
    orepres   NUMBER(4, 2),
    orestraor NUMBER(4, 2),
    orepermes NUMBER(4, 2)
);

CREATE TABLE vglsa.grp01_prs_scarti (
    id_run    NUMBER,
    id_per    VARCHAR2(100 BYTE),
    matricola VARCHAR2(100 BYTE),
    cf        VARCHAR2(100 BYTE),
    data_pres VARCHAR2(100 BYTE),
    orepres   VARCHAR2(100 BYTE),
    orestraor VARCHAR2(100 BYTE),
    orepermes VARCHAR2(100 BYTE),
    d_ins     DATE DEFAULT sysdate
);

CREATE TABLE vglsa.grp01_ruo (
    id_per     NUMBER(6, 0),
    cod_ruolo  VARCHAR2(10 BYTE),
    desc_ruolo VARCHAR2(100 BYTE)
);

CREATE TABLE vglsa.grp01_ruo_scarti (
    id_run     NUMBER,
    id_per     VARCHAR2(100 BYTE),
    cod_ruolo  VARCHAR2(100 BYTE),
    desc_ruolo VARCHAR2(100 BYTE),
    d_ins      DATE DEFAULT sysdate
);

CREATE TABLE vglsa.grp01_unt (
    id_per   NUMBER(6, 0),
    cod_unt  NUMBER(5, 0),
    desc_unt VARCHAR2(100 BYTE)
);

CREATE TABLE vglsa.grp01_unt_scarti (
    id_run   NUMBER,
    id_per   VARCHAR2(100 BYTE),
    cod_unt  VARCHAR2(100 BYTE),
    desc_unt VARCHAR2(100 BYTE),
    d_ins    DATE DEFAULT sysdate
);

CREATE TABLE vglsa.grp02_ana (
    id_per               NUMBER(6, 0),
    cod_dip              NUMBER(5, 0),
    cod_unt              NUMBER(5, 0),
    cod_ruolo            VARCHAR2(10 BYTE),
    cognome              VARCHAR2(50 BYTE),
    nome                 VARCHAR2(50 BYTE),
    dt_ini_unt           DATE,
    tipo_ctr             VARCHAR2(50 BYTE),
    cod_ctr              VARCHAR2(10 BYTE),
    cod_liv              VARCHAR2(10 BYTE),
    dt_ini_liv           DATE,
    dt_ini_mns           DATE,
    matricola            VARCHAR2(10 BYTE),
    cf                   VARCHAR2(16 BYTE),
    sesso                VARCHAR2(10 BYTE),
    dt_nascita           DATE,
    tipo_rapp            VARCHAR2(10 BYTE),
    dt_ini_tipo_ctr      DATE,
    dt_fine_tipo_ctr     DATE,
    dt_ini_rapp          DATE,
    dt_fine_rapp         DATE,
    ambito               VARCHAR2(10 BYTE),
    tipo_ass             VARCHAR2(10 BYTE),
    dt_proroga_termine   DATE,
    dt_ctr_sost_mat      DATE,
    qta_part_time        VARCHAR2(10 BYTE),
    titolare1            VARCHAR2(50 BYTE),
    titolare2            VARCHAR2(50 BYTE),
    motivo_promozione    VARCHAR2(50 BYTE),
    fascicolo_aggiornato VARCHAR2(50 BYTE),
    titolo_studio        VARCHAR2(10 BYTE),
    desc_ctr             VARCHAR2(50 BYTE),
    desc_liv             VARCHAR2(50 BYTE)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.grp02_prs (
    id_per    NUMBER(6, 0),
    matricola NUMBER(5, 0),
    cf        VARCHAR2(100 BYTE),
    data_pres DATE,
    orepres   NUMBER(4, 2),
    orestraor NUMBER(4, 2),
    orepermes NUMBER(4, 2)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.grp02_ruo (
    id_per     NUMBER(6, 0),
    cod_ruolo  VARCHAR2(10 BYTE),
    desc_ruolo VARCHAR2(100 BYTE)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.grp02_unt (
    id_per   NUMBER(6, 0),
    cod_unt  NUMBER(5, 0),
    desc_unt VARCHAR2(100 BYTE)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

CREATE TABLE vglsa.te_elenco_file (
    nome_file VARCHAR2(250 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY flussi ACCESS PARAMETERS (
        RECORDS DELIMITED BY'\n'
            CHARACTERSET utf8
            NOBADFILE
            NODISCARDFILE
            NOLOGFILE
        FIELDS TERMINATED BY ' ' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( flussi : 'elenco_flussi.csv' )
);

CREATE TABLE vglsa.wrk_anagrafica_flussi (
    cod_flusso      VARCHAR2(100 BYTE),
    flg_disponibile VARCHAR2(1 BYTE),
    flg_orderby     NUMBER(1, 0),
    dt_upd_flag     DATE
);

CREATE TABLE vglsa.wrk_audit_caricamenti (
    id_caricamenti      NUMBER,
    id_run              NUMBER,
    cod_flusso          VARCHAR2(100 BYTE),
    id_per              NUMBER(6, 0),
    dta_inizio          DATE,
    dta_fine            DATE,
    cod_stato           VARCHAR2(100 BYTE),
    val_scarti_external NUMBER,
    val_scarti_convert  NUMBER,
    d_ins               DATE DEFAULT sysdate
);

CREATE TABLE vglsa.wrk_audit_log (
    id_log        NUMBER,
    id_run        NUMBER,
    cod_flusso    VARCHAR2(100 BYTE),
    step          NUMBER,
    sql_code      NUMBER,
    stmt          VARCHAR2(4000 BYTE),
    error_message VARCHAR2(4000 BYTE),
    procedura     VARCHAR2(100 BYTE),
    note          VARCHAR2(4000 BYTE),
    d_ins         DATE DEFAULT sysdate
);

CREATE TABLE vglsa.wrk_audit_master (
    id_master  NUMBER,
    id_run     NUMBER,
    status     VARCHAR2(100 BYTE),
    start_date DATE,
    end_date   DATE,
    delta_run  NUMBER,
    d_ins      DATE DEFAULT sysdate
);

CREATE TABLE vglsa.wrk_configurazione (
    cod_flusso                  VARCHAR2(100 BYTE),
    name_tab_00                 VARCHAR2(100 BYTE),
    name_tab_00_per             VARCHAR2(100 BYTE),
    name_tab_01                 VARCHAR2(100 BYTE),
    name_tab_01_scarti          VARCHAR2(100 BYTE),
    name_tab_02                 VARCHAR2(100 BYTE),
    name_columns_list_01        VARCHAR2(4000 BYTE),
    name_columns_list_01_scarti VARCHAR2(4000 BYTE),
    name_columns_list_02        VARCHAR2(4000 BYTE),
    name_where_01               VARCHAR2(4000 BYTE),
    name_where_01_scarti        VARCHAR2(4000 BYTE),
    name_trasform_columns_01    VARCHAR2(4000 BYTE),
    stat_percent                NUMBER(3, 0)
);

create table vglsa.wrk_chk (
    cod_flusso                  VARCHAR2(100 BYTE),
    name_where_01               VARCHAR2(4000 BYTE),
    name_where_01_scarti        VARCHAR2(4000 BYTE)
);
/* Creazione vista vglsa.v_elenco_file
*/

CREATE OR REPLACE FORCE VIEW vglsa.v_elenco_file (
    cod_flusso
) AS
    SELECT
        upper(substr(nome_file,
                     1,
                     instr(nome_file, '.csv', - 1) - 1)) cod_flusso
    FROM
        te_elenco_file;
        
/* Creazione indice vglsa.cod_flusso_pk
*/

CREATE UNIQUE INDEX vglsa.cod_flusso_pk ON
    vglsa.wrk_configurazione (
        cod_flusso
    );

/* Popolamento tabelle di configurazione
*/

/*INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'ACCREDITAMENTI',
    'ASL00_ACR',
    'ASL00_ACRPER',
    'ASL01_ACR',
    'ASL01_ACR_SCARTI',
    'ASL02_ACR',
    'ID_PER,COD_ACR,DESC_ACR',
    'ID_RUN,ID_PER,COD_ACR,DESC_ACR,D_INS',
    'ID_PER,COD_ACR,DESC_ACR',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND LENGTH(COD_ACR)<=3',
    'LENGTH(COD_ACR)>3',
    'to_number(ID_PER),COD_ACR,DESC_ACR',
    '5'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'ANAGRAFICA',
    'GRP00_ANA',
    'GRP00_ANAPER',
    'GRP01_ANA',
    'GRP01_ANA_SCARTI',
    'GRP02_ANA',
    'ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    'ID_RUN,ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV,D_INS',
    'ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_DIP)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_UNT)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_INI_LIV)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_MNS)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_NASCITA)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_TIPO_CTR)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_FINE_TIPO_CTR)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_RAPP)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_FINE_RAPP)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_PROROGA_TERMINE)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_CTR_SOST_MAT)=1',
    'PKG_CONTROLS_01.f_is_numeric(COD_DIP)=0 OR PKG_CONTROLS_01.f_is_numeric(COD_UNT)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_UNT)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_INI_LIV)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_MNS)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_NASCITA)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_TIPO_CTR)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_FINE_TIPO_CTR)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_RAPP)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_FINE_RAPP)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_PROROGA_TERMINE)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_CTR_SOST_MAT)=0',
    'to_number(ID_PER),to_number(COD_DIP),to_number(COD_UNT),COD_RUOLO,COGNOME,NOME,to_date(DT_INI_UNT,''dd/mm/yyyy''),TIPO_CTR,
COD_CTR
,COD_LIV,to_date(DT_INI_LIV,''dd/mm/yyyy''),to_date(DT_INI_MNS,''dd/mm/yyyy''),MATRICOLA,CF,SESSO,to_date(DT_NASCITA,''dd/mm/yyyy''),
    TIPO_RAPP,to_date(DT_INI_TIPO_CTR,''dd/mm/yyyy''),to_date(DT_FINE_TIPO_CTR,''dd/mm/yyyy''),to_date(DT_INI_RAPP,''dd/mm/yyyy''),
    to_date(DT_FINE_RAPP,''dd/mm/yyyy''),AMBITO,TIPO_ASS,to_date(DT_PROROGA_TERMINE,''dd/mm/yyyy''),to_date(DT_CTR_SOST_MAT,''dd/mm/yyyy''),
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    '5'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'RUOLI',
    'GRP00_RUO',
    'GRP00_RUOPER',
    'GRP01_RUO',
    'GRP01_RUO_SCARTI',
    'GRP02_RUO',
    'ID_PER,COD_RUOLO,DESC_RUOLO',
    'ID_RUN,ID_PER,COD_RUOLO,DESC_RUOLO,D_INS',
    'ID_PER,COD_RUOLO,DESC_RUOLO',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 and LENGTH(COD_RUOLO)<=2',
    'LENGTH(COD_RUOLO)>2',
    'to_number(ID_PER),COD_RUOLO,DESC_RUOLO',
    '5'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'PRESENZE',
    'GRP00_PRS',
    'GRP00_PRSPER',
    'GRP01_PRS',
    'GRP01_PRS_SCARTI',
    'GRP02_PRS',
    'ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES,ORESTRAOR,OREPERMES',
    'ID_RUN,ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES, ORESTRAOR, OREPERMES,D_INS',
    'ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES, ORESTRAOR, OREPERMES',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(MATRICOLA)=1 AND PKG_CONTROLS_01.f_is_date_control(DATA_PRES)=1'
    ,
    'PKG_CONTROLS_01.f_is_numeric(MATRICOLA)=0 OR PKG_CONTROLS_01.f_is_date_control(DATA_PRES)=0',
    'to_number(ID_PER),to_number(MATRICOLA),CF,to_date(data_PRES,''yyyy-mm-dd''),to_number(replace(OREPRES,''.'','','')),to_number(replace(ORESTRAOR,''.'','','')),to_number(replace(OREPERMES,''.'','',''))
',
    '5'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'UNITA',
    'GRP00_UNT',
    'GRP00_UNTPER',
    'GRP01_UNT',
    'GRP01_UNT_SCARTI',
    'GRP02_UNT',
    'ID_PER,COD_UNT,DESC_UNT',
    'ID_RUN,ID_PER,COD_UNT,DESC_UNT,D_INS',
    'ID_PER,COD_UNT,DESC_UNT',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)=1',
    'PKG_CONTROLS_01.f_is_numeric(COD_UNT)=0',
    'to_number(ID_PER),to_number(COD_UNT),DESC_UNT',
    '5'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_where_01,
    name_where_01_scarti,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'UNTACR',
    'COGE00_UNTACR',
    'COGE00_UNTACRPER',
    'COGE01_UNTACR',
    'COGE01_UNTACR_SCARTI',
    'COGE02_UNTACR',
    'ID_PER,COD_UNT,COD_ACR',
    'ID_RUN,ID_PER,COD_UNT,COD_ACR,D_INS',
    'ID_PER,COD_UNT,COD_ACR',
    'PKG_CONTROLS_01.f_is_valid(COD_UNT,COD_ACR)=1 ',
    'PKG_CONTROLS_01.f_is_valid(COD_UNT,COD_ACR)=0',
    'to_number(ID_PER),to_number(COD_UNT),COD_ACR',
    '5'
);*/

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'ACCREDITAMENTI',
    'ASL00_ACR',
    'ASL00_ACRPER',
    'ASL01_ACR',
    'ASL01_ACR_SCARTI',
    'ASL02_ACR',
    'ID_PER,COD_ACR,DESC_ACR',
    'ID_RUN,ID_PER,COD_ACR,DESC_ACR,D_INS',
    'ID_PER,COD_ACR,DESC_ACR',
    'to_number(ID_PER),COD_ACR,DESC_ACR',
    '5'
);
insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'ACCREDITAMENTI',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND LENGTH(COD_ACR)<=3',
    'LENGTH(COD_ACR)>3'
);
    
    
INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'ANAGRAFICA',
    'GRP00_ANA',
    'GRP00_ANAPER',
    'GRP01_ANA',
    'GRP01_ANA_SCARTI',
    'GRP02_ANA',
    'ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    'ID_RUN,ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV,D_INS',
    'ID_PER,COD_DIP,COD_UNT,COD_RUOLO,COGNOME,NOME,DT_INI_UNT,TIPO_CTR,COD_CTR,COD_LIV,DT_INI_LIV,DT_INI_MNS,MATRICOLA,CF,SESSO,
    DT_NASCITA,TIPO_RAPP,DT_INI_TIPO_CTR,DT_FINE_TIPO_CTR,DT_INI_RAPP,DT_FINE_RAPP,AMBITO,TIPO_ASS,DT_PROROGA_TERMINE,DT_CTR_SOST_MAT,
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    'to_number(ID_PER),to_number(COD_DIP),to_number(COD_UNT),COD_RUOLO,COGNOME,NOME,to_date(DT_INI_UNT,''dd/mm/yyyy''),TIPO_CTR,
COD_CTR
,COD_LIV,to_date(DT_INI_LIV,''dd/mm/yyyy''),to_date(DT_INI_MNS,''dd/mm/yyyy''),MATRICOLA,CF,SESSO,to_date(DT_NASCITA,''dd/mm/yyyy''),
    TIPO_RAPP,to_date(DT_INI_TIPO_CTR,''dd/mm/yyyy''),to_date(DT_FINE_TIPO_CTR,''dd/mm/yyyy''),to_date(DT_INI_RAPP,''dd/mm/yyyy''),
    to_date(DT_FINE_RAPP,''dd/mm/yyyy''),AMBITO,TIPO_ASS,to_date(DT_PROROGA_TERMINE,''dd/mm/yyyy''),to_date(DT_CTR_SOST_MAT,''dd/mm/yyyy''),
    QTA_PART_TIME,TITOLARE1,TITOLARE2,MOTIVO_PROMOZIONE,FASCICOLO_AGGIORNATO,TITOLO_STUDIO,DESC_CTR,DESC_LIV',
    '5'
);

insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'ANAGRAFICA',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_DIP)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_UNT)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_INI_LIV)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_MNS)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_NASCITA)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_TIPO_CTR)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_FINE_TIPO_CTR)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_INI_RAPP)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_FINE_RAPP)=1
    AND PKG_CONTROLS_01.f_is_date_control(DT_PROROGA_TERMINE)=1 AND PKG_CONTROLS_01.f_is_date_control(DT_CTR_SOST_MAT)=1',
    'PKG_CONTROLS_01.f_is_numeric(COD_DIP)=0 OR PKG_CONTROLS_01.f_is_numeric(COD_UNT)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_UNT)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_INI_LIV)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_MNS)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_NASCITA)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_TIPO_CTR)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_FINE_TIPO_CTR)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_INI_RAPP)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_FINE_RAPP)=0
    OR PKG_CONTROLS_01.f_is_date_control(DT_PROROGA_TERMINE)=0 OR PKG_CONTROLS_01.f_is_date_control(DT_CTR_SOST_MAT)=0'
);
    

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'RUOLI',
    'GRP00_RUO',
    'GRP00_RUOPER',
    'GRP01_RUO',
    'GRP01_RUO_SCARTI',
    'GRP02_RUO',
    'ID_PER,COD_RUOLO,DESC_RUOLO',
    'ID_RUN,ID_PER,COD_RUOLO,DESC_RUOLO,D_INS',
    'ID_PER,COD_RUOLO,DESC_RUOLO',
    'to_number(ID_PER),COD_RUOLO,DESC_RUOLO',
    '5'
);

insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'RUOLI',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 and LENGTH(COD_RUOLO)<=2',
    'LENGTH(COD_RUOLO)>2'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'PRESENZE',
    'GRP00_PRS',
    'GRP00_PRSPER',
    'GRP01_PRS',
    'GRP01_PRS_SCARTI',
    'GRP02_PRS',
    'ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES,ORESTRAOR,OREPERMES',
    'ID_RUN,ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES, ORESTRAOR, OREPERMES,D_INS',
    'ID_PER,MATRICOLA,CF,DATA_PRES,OREPRES, ORESTRAOR, OREPERMES',
    'to_number(ID_PER),to_number(MATRICOLA),CF,to_date(data_PRES,''yyyy-mm-dd''),to_number(replace(OREPRES,''.'','','')),to_number(replace(ORESTRAOR,''.'','','')),to_number(replace(OREPERMES,''.'','',''))
',
    '5'
);

insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'PRESENZE',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(MATRICOLA)=1 AND PKG_CONTROLS_01.f_is_date_control(DATA_PRES)=1',
    'PKG_CONTROLS_01.f_is_numeric(MATRICOLA)=0 OR PKG_CONTROLS_01.f_is_date_control(DATA_PRES)=0'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'UNITA',
    'GRP00_UNT',
    'GRP00_UNTPER',
    'GRP01_UNT',
    'GRP01_UNT_SCARTI',
    'GRP02_UNT',
    'ID_PER,COD_UNT,DESC_UNT',
    'ID_RUN,ID_PER,COD_UNT,DESC_UNT,D_INS',
    'ID_PER,COD_UNT,DESC_UNT',
    'to_number(ID_PER),to_number(COD_UNT),DESC_UNT',
    '5'
);

insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'UNITA',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)=1',
    'PKG_CONTROLS_01.f_is_numeric(COD_UNT)=0'
);

INSERT INTO vglsa.wrk_configurazione (
    cod_flusso,
    name_tab_00,
    name_tab_00_per,
    name_tab_01,
    name_tab_01_scarti,
    name_tab_02,
    name_columns_list_01,
    name_columns_list_01_scarti,
    name_columns_list_02,
    name_trasform_columns_01,
    stat_percent
) VALUES (
    'UNTACR',
    'COGE00_UNTACR',
    'COGE00_UNTACRPER',
    'COGE01_UNTACR',
    'COGE01_UNTACR_SCARTI',
    'COGE02_UNTACR',
    'ID_PER,COD_UNT,COD_ACR',
    'ID_RUN,ID_PER,COD_UNT,COD_ACR,D_INS',
    'ID_PER,COD_UNT,COD_ACR',
    'to_number(ID_PER),to_number(COD_UNT),COD_ACR',
    '5'
);

insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'UNTACR',
    'PKG_CONTROLS_01.f_is_valid(COD_UNT,COD_ACR)=1 ',
    'PKG_CONTROLS_01.f_is_valid(COD_UNT,COD_ACR)=0'
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'ACCREDITAMENTI',
    'Y',
    '1',
    NULL
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'ANAGRAFICA',
    'Y',
    '2',
    NULL
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'RUOLI',
    'Y',
    '3',
    NULL
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'PRESENZE',
    'Y',
    '4',
    NULL
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'UNITA',
    'Y',
    '5',
    NULL
);

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'UNTACR',
    'Y',
    '6',
    NULL
);

/* Creazione funzione vglsa.fnc_check_files_disponibili
*/

CREATE OR REPLACE FUNCTION vglsa.fnc_check_files_disponibili RETURN NUMBER IS

    CURSOR c IS
    SELECT
        cod_flusso
    FROM
        wrk_anagrafica_flussi;

    v_cod_flusso  VARCHAR2(255);
    v_exists      NUMBER(1);
    v_name_tab_00 VARCHAR2(30);
    v_stmt        VARCHAR2(255);
BEGIN
    FOR r IN c LOOP
        v_cod_flusso := r.cod_flusso;
        SELECT
            COUNT(*)
        INTO v_exists
        FROM
            v_elenco_file
        WHERE
                upper(cod_flusso) = upper(v_cod_flusso)
            AND ROWNUM <= 1;

        IF ( v_exists = 1 ) THEN
            SELECT
                name_tab_00
            INTO v_name_tab_00
            FROM
                wrk_configurazione
            WHERE
                upper(cod_flusso) = upper(v_cod_flusso);

            UPDATE wrk_anagrafica_flussi
            SET
                flg_disponibile = 'Y',
                dt_upd_flag = sysdate
            WHERE
                upper(cod_flusso) = upper(v_cod_flusso);

        END IF;

    END LOOP;

    COMMIT;
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END;
/

/* Creazione package
*/

CREATE OR REPLACE PACKAGE vglsa.pkg_alimentazione_01 AS
    PROCEDURE p_main;
END;
/

CREATE OR REPLACE PACKAGE vglsa.pkg_controls_01 AS
    FUNCTION f_is_positive (
        str IN VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION f_is_numeric (
        str IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION f_is_date_control (
        p_data IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION f_is_valid (
        cod_u IN VARCHAR2,
        cod_a IN VARCHAR2
    ) RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE vglsa.pkg_utils_01 AS

    PROCEDURE p_audit_log (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2,
        p_step       IN NUMBER,
        p_sqlcode    IN NUMBER,
        p_stmt       IN VARCHAR2,
        p_sqlerror_m IN VARCHAR2,
        p_procedura  IN VARCHAR2,
        p_note       IN VARCHAR2
    );

    PROCEDURE p_audit_caricamenti (
        p_id_run              IN NUMBER,
        p_cod_flusso          IN VARCHAR2,
        p_id_dper             IN NUMBER,
        p_data_inizio         IN DATE,
        p_data_fine           IN DATE,
        p_cod_stato           IN VARCHAR2,
        p_val_scarti_external IN NUMBER,
        p_val_scarti_convert  IN NUMBER
    );

    PROCEDURE p_audit_master (
        p_id_run     IN NUMBER,
        p_status     IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date   IN DATE
    );

    FUNCTION f_get_00_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_00_per_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_scarti_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_02_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_scarti_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_02_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_where (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_scarti_where (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_trasform_type (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION f_get_01_scarti_count (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION f_get_st_percent (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY vglsa.pkg_controls_01 AS
--funzione per controllare che il valore sia positivo
    FUNCTION f_is_positive (
        str IN VARCHAR2
    ) RETURN NUMBER IS
        v_number NUMBER(30);
    BEGIN
        v_number := TO_NUMBER ( str );
        if v_number > 0 then
            RETURN 1;
        else
            return 0;
        end if;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

--funzione per controllare che il valore sia un numero
    FUNCTION f_is_numeric (
        str IN VARCHAR2
    ) RETURN NUMBER IS
        v_number NUMBER(30);
    BEGIN
        v_number := TO_NUMBER ( str );
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

--funzione per controllare che il valore sia una data
    FUNCTION f_is_date_control (
        p_data IN VARCHAR2
    ) RETURN NUMBER IS
        v_conversione DATE;
    BEGIN
        v_conversione := TO_DATE ( p_data, 'dd/mm/yyyy' );
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                v_conversione := TO_DATE ( p_data, 'dd-mm-yyyy' );
                RETURN 1;
            EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        v_conversione := TO_DATE ( p_data, 'dd MON yyyy' );
                        RETURN 1;
                    EXCEPTION
                        WHEN OTHERS THEN
                            BEGIN
                                v_conversione := TO_DATE ( p_data, 'mm/dd/yyyy' );
                                RETURN 1;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    BEGIN
                                        v_conversione := TO_DATE ( p_data, 'mm-dd-yy' );
                                        RETURN 1;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            BEGIN
                                                v_conversione := TO_DATE ( p_data, 'MON dd yyyy' );
                                                RETURN 1;
                                            EXCEPTION
                                                WHEN OTHERS THEN
                                                    BEGIN
                                                        v_conversione := TO_DATE ( p_data, 'yyyy/mm/dd' );
                                                        RETURN 1;
                                                    EXCEPTION
                                                        WHEN OTHERS THEN
                                                            BEGIN
                                                                v_conversione := TO_DATE ( p_data, 'yyyy-mm-dd' );
                                                                RETURN 1;
                                                            EXCEPTION
                                                                WHEN OTHERS THEN
                                                                    BEGIN
                                                                        v_conversione := TO_DATE ( p_data, 'yyyy MON dd' );
                                                                        RETURN 1;
                                                                    EXCEPTION
                                                                        WHEN OTHERS THEN
                                                                            RETURN 0;
                                                                    END;
                                                            END;
                                                    END;
                                            END;
                                    END;
                            END;
                    END;
            END;
    END;

--funzione per controllare se il codice gestionale è compatibile con la unità e gli accreditamenti esistenti 
    FUNCTION f_is_valid (
        cod_u IN VARCHAR2,
        cod_a IN VARCHAR2
    ) RETURN NUMBER IS
        v_cod_u NUMBER(2);
        v_cod_a NUMBER(2);
    BEGIN
        SELECT
            COUNT(*)
        INTO v_cod_u
        FROM
            grp02_unt a
        WHERE
                a.cod_unt = TO_NUMBER(cod_u)
            AND a.id_per = (
                SELECT
                    b.id_per
                FROM
                    coge00_untacrper b
                WHERE
                    ROWNUM = 1
            );

        SELECT
            COUNT(*)
        INTO v_cod_a
        FROM
            asl02_acr a
        WHERE
                a.cod_acr = cod_a
            AND a.id_per = (
                SELECT
                    b.id_per
                FROM
                    coge00_untacrper b
                WHERE
                    ROWNUM = 1
            );

        IF (
            v_cod_u != 0
            AND v_cod_a != 0
        ) THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

END;
/

CREATE OR REPLACE PACKAGE BODY vglsa.pkg_utils_01 AS

    c_package CONSTANT VARCHAR2(30) := 'PKG_UTILS_01';
    c_debug   CONSTANT NUMBER(1) := 1;
    c_warning CONSTANT NUMBER(1) := 2;
    c_error   CONSTANT NUMBER(1) := 3;

--procedura per popolare la tabella dei log che tiene traccia di ogni movimento 
    PROCEDURE p_audit_log (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2,
        p_step       IN NUMBER,            -- livello diventa step
        p_sqlcode    IN NUMBER,
        p_stmt       IN VARCHAR2,
        p_sqlerror_m IN VARCHAR2,
        p_procedura  IN VARCHAR2,
        p_note       IN VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;    -- permette di eseguire il commit sulle colonne della insert di cui al punto seguent 
    BEGIN
        INSERT INTO wrk_audit_log            -- insert ordinata secondo le nuove colonne
         (
            id_log,
            id_run,
            cod_flusso,
            step,                   -- livello diventa step
            sql_code,
            stmt,
            error_message,
            procedura,
            note,
            d_ins
        ) VALUES (
            seq_id_log.NEXTVAL,
            p_id_run,
            p_cod_flusso,
            p_step,
            p_sqlcode,
            p_stmt,
            p_sqlerror_m,
            p_procedura,
            p_note,
            sysdate
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Errore p_audit_log: '
                                 || to_char(sqlcode)
                                 || ': '
                                 || substr(sqlerrm, 1, 100));

    END;

   -- procedura per popolare la tabella dei caricamenti che tiene traccia dei caricamenti effettuati nelle tabelle storiche 02
    PROCEDURE p_audit_caricamenti (
        p_id_run              IN NUMBER,
        p_cod_flusso          IN VARCHAR2,
        p_id_dper             IN NUMBER,
        p_data_inizio         IN DATE,
        p_data_fine           IN DATE,
        p_cod_stato           IN VARCHAR2,
        p_val_scarti_external IN NUMBER,
        p_val_scarti_convert  IN NUMBER
    ) IS
        PRAGMA autonomous_transaction;    -- permette di eseguire il commit sulle colonne della insert di cui al punto seguent 
    BEGIN
        INSERT INTO wrk_audit_caricamenti (
            id_caricamenti,
            id_run,
            cod_flusso,
            id_per,
            dta_inizio,
            dta_fine,
            cod_stato,
            val_scarti_external,
            val_scarti_convert,
            d_ins
        ) VALUES (
            seq_id_caricamenti.NEXTVAL,
            p_id_run,
            p_cod_flusso,
            p_id_dper,
            p_data_inizio,
            p_data_fine,
            p_cod_stato,
            p_val_scarti_external,
            p_val_scarti_convert,
            sysdate
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Errore p_audit_log: '
                                 || to_char(sqlcode)
                                 || ': '
                                 || substr(sqlerrm, 1, 100));

    END;
   
-- procedura per popolare la tabella wrk_audit_master

    PROCEDURE p_audit_master (
        p_id_run     IN NUMBER,
        p_status     IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date   IN DATE
    ) IS
        PRAGMA autonomous_transaction;    -- permette di eseguire il commit sulle colonne della insert di cui al punto seguente 
    BEGIN
        INSERT INTO wrk_audit_master (
            id_master,
            id_run,
            status,
            start_date,
            end_date,
            delta_run,
            d_ins
        ) VALUES (
            seq_id_master.NEXTVAL,
            p_id_run,
            p_status,
            p_start_date,
            p_end_date,
            TO_NUMBER(p_end_date - p_start_date),
            sysdate
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Errore p_audit_log: '
                                 || to_char(sqlcode)
                                 || ': '
                                 || substr(sqlerrm, 1, 100));

    END;

-- funzione che restituisce il nome di una external table
    FUNCTION f_get_00_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura   VARCHAR2(30) := 'F_GET_00_NAME';
        v_name_tab_00 VARCHAR2(30);
    BEGIN
        SELECT
            name_tab_00
        INTO v_name_tab_00
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_tab_00;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_cod_flusso => p_cod_flusso, p_step => c_error, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

-- funzione che restituisce il nome di una external table col periodo
    FUNCTION f_get_00_per_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura       VARCHAR2(30) := 'F_GET_00_PER_NAME';
        v_name_tab_00_per VARCHAR2(30);
    BEGIN
        SELECT
            name_tab_00_per
        INTO v_name_tab_00_per
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_tab_00_per;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

--funzione che restituisce il nome di una floating table
    FUNCTION f_get_01_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura   VARCHAR2(30) := 'F_GET_01_NAME';
        v_name_tab_01 VARCHAR2(30);
    BEGIN
        SELECT
            name_tab_01
        INTO v_name_tab_01
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_tab_01;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

--funzione che restituisce il nome di una tabella degli scarti di conversione
    FUNCTION f_get_01_scarti_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura          VARCHAR2(30) := 'F_GET_01_SCARTI_NAME';
        v_name_tab_01_scarti VARCHAR2(30);
    BEGIN
        SELECT
            name_tab_01_scarti
        INTO v_name_tab_01_scarti
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_tab_01_scarti;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;   

-- funzione che restituisce il nome della tabella storica
    FUNCTION f_get_02_name (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura   VARCHAR2(30) := 'F_GET_02_NAME';
        v_name_tab_02 VARCHAR2(30);
    BEGIN
        SELECT
            name_tab_02
        INTO v_name_tab_02
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_tab_02;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);

            RETURN NULL;
    END;

--funzione che restituisce la lista delle colonne di una floating table
    FUNCTION f_get_01_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura            VARCHAR2(30) := 'F_GET_01_COLUMNS_LIST';
        v_name_columns_list_01 VARCHAR2(32767);
    BEGIN
        SELECT
            name_columns_list_01
        INTO v_name_columns_list_01
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_columns_list_01;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

-- funzione che restituisce la lista delle colonne di una tabella degli scarti di conversione
    FUNCTION f_get_01_scarti_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura                   VARCHAR2(30) := 'F_GET_01_SCARTI_COLUMNS_LIST';
        v_name_columns_list_01_scarti VARCHAR2(32767);
    BEGIN
        SELECT
            name_columns_list_01_scarti
        INTO v_name_columns_list_01_scarti
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_columns_list_01_scarti;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

--funzione che restituisce la lista di colonne della tabella storica
    FUNCTION f_get_02_columns_list (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura            VARCHAR2(30) := 'F_GET_02_COLUMNS_LIST';
        v_name_columns_list_02 VARCHAR2(32767);
    BEGIN
        SELECT
            name_columns_list_02
        INTO v_name_columns_list_02
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_columns_list_02;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

-- funzione che restituisce le condizioni di inserimento della floating table
    FUNCTION f_get_01_where (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura     VARCHAR2(30) := 'F_GET_01_WHERE';
        v_name_where_01 VARCHAR2(32767);
    BEGIN
        SELECT
            name_where_01
        INTO v_name_where_01
        FROM
            wrk_chk
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_where_01;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

-- funzione che restituisce le condizioni di inserimento della tabella degli scarti di conversione
    FUNCTION f_get_01_scarti_where (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura            VARCHAR2(30) := 'F_GET_01_SCARTI_WHERE';
        v_name_where_01_scarti VARCHAR2(32767);
    BEGIN
        SELECT
            name_where_01_scarti
        INTO v_name_where_01_scarti
        FROM
            wrk_chk
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_where_01_scarti;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

-- funzione che restituisce le trasformazioni da effettare per popolare le floating table
    FUNCTION f_get_01_trasform_type (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_procedura                VARCHAR2(30) := 'F_GET_01_TRANSFORM_TYPE';
        v_name_trasform_columns_01 VARCHAR2(32767);
    BEGIN
        SELECT
            name_trasform_columns_01
        INTO v_name_trasform_columns_01
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_name_trasform_columns_01;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => 'Problemi nella trasformazione per inserimento in tab appoggio.'
                       );
    END;

-- funzione che restituisce il numero di scarti di conversione per ciascun run
    FUNCTION f_get_01_scarti_count (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN NUMBER IS

        v_procedura VARCHAR2(255) := 'F_GET_01_SCARTI_COUNT';
        v_count     NUMBER;
        v_stringa   VARCHAR2(32767);
        v_stmt      VARCHAR2(32767);
    BEGIN
        v_stringa := f_get_01_scarti_columns_list(p_id_run, p_cod_flusso);
        v_stringa := regexp_substr(v_stringa, '[^,]+', 1, 1);
        v_stmt := 'select count('
                  || v_stringa
                  || ')'
                  || ' from '
                  || f_get_01_scarti_name(p_id_run, p_cod_flusso)
                  || ' where '
                  || v_stringa
                  || ' = '
                  || p_id_run;

        EXECUTE IMMEDIATE v_stmt
        INTO v_count;
        RETURN v_count;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => v_stmt, p_note => 'Problemi nel conteggio degli scarti di conversione');

            RETURN NULL;
    END;

--funzione che restituisce la percentuale di dati storici da analizzare 
    FUNCTION f_get_st_percent (
        p_id_run     IN NUMBER,
        p_cod_flusso IN VARCHAR2
    ) RETURN NUMBER IS
        v_procedura    VARCHAR2(30) := 'F_GET_ST_PERCENT';
        v_stat_percent NUMBER;
    BEGIN
        SELECT
            stat_percent
        INTO v_stat_percent
        FROM
            wrk_configurazione
        WHERE
            upper(cod_flusso) = upper(p_cod_flusso);

        RETURN v_stat_percent;
    EXCEPTION
        WHEN OTHERS THEN
            p_audit_log(p_id_run => p_id_run, p_step => c_error, p_cod_flusso => p_cod_flusso, p_procedura => c_package
                                                                                                              || '.'
                                                                                                              || v_procedura, p_sqlcode => sqlcode
                                                                                                              ,
                       p_sqlerror_m => sqlerrm, p_stmt => NULL, p_note => NULL);
    END;

END;
/

--------------------------------------------------------
--  DDL for Package Body PKG_ALIMENTAZIONE_01
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY vglsa.pkg_alimentazione_01 AS

   --c_package   CONSTANT VARCHAR2 (30) := 'PKG_ALIMENTAZIONE_01';
    c_debug   CONSTANT NUMBER(1) := 1;
    c_warning CONSTANT NUMBER(1) := 2;
    c_error   CONSTANT NUMBER(1) := 3;

    PROCEDURE p_main IS

        CURSOR c1 IS
        SELECT
            cod_flusso
        FROM
            wrk_anagrafica_flussi
        WHERE
            upper(flg_disponibile) = 'Y'
        ORDER BY
            flg_orderby;

        rec1               c1%rowtype;
        v_id_run           NUMBER;                     -- id del caricamento
        v_id_dper          VARCHAR2(8);               --id della data del periodo di riferimento
        v_stmt             VARCHAR2(32767);           -- stringa statement
        v_count            NUMBER;
        v_exist            NUMBER(1);
        v_periodo          NUMBER(8);                 -- partizione
        v_procedura        VARCHAR2(255) := 'PKG_ALIMENTAZIONE_01.PMAIN';
        v_nome_tab_part    VARCHAR2(30);              --nome tabella partizionata
        v_nome_part        VARCHAR2(30);              --nome partizione
        v_esiste_part      NUMBER(1);
        v_ini_caric        DATE;                       -- data inizio caricamento
        v_fin_caric        DATE;                       -- data fine caricamento
        v_scarti_01_scarti NUMBER;                     -- conta il num di righe scartate
        exception_errore EXCEPTION;                  -- eccezione dichiarata
        v_count_master     NUMBER := 0;               -- contatore relativo allo status delle eccezioni

  -- 
    BEGIN
        v_id_run := seq_id_run.nextval;   -- sequenza

        OPEN c1;
        LOOP
            FETCH c1 INTO rec1;
            EXIT WHEN c1%notfound;
            v_ini_caric := sysdate;
            BEGIN
            -- STEP 1 - Estraggo il periodo dalla tabella 00_per
                BEGIN 
                --v_procedura := 'SELECT del periodo';
                    v_stmt := 'SELECT ID_PER'
                              || ' FROM '
                              || pkg_utils_01.f_get_00_per_name(v_id_run, rec1.cod_flusso)
                              || ' WHERE rownum = 1';

                    EXECUTE IMMEDIATE v_stmt
                    INTO v_id_dper;
                    v_nome_part := 'P_' || to_char(v_id_dper);             --  ad uso della gestione delle partizioni per le tabelle 02 - vedi step successivi

                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 1, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'Caricamento del periodo '
                                                                                                        || v_id_dper
                                                                                                        || ' del flusso '
                                                                                                        || rec1.cod_flusso);

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 1, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'ERRORE: periodo non trovato per il flusso'
                                                || rec1.cod_flusso);

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master
                        RAISE exception_errore;
                END;

            -- STEP 2 - Tronco la floating table 01
                BEGIN 
                ----v_procedura := 'Truncate floating table';
                    v_stmt := 'TRUNCATE TABLE '
                              || pkg_utils_01.f_get_01_name(v_id_run, rec1.cod_flusso);
                    EXECUTE IMMEDIATE v_stmt;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 2, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 2 - TRUNCATE TABLE '
                                                                                                        || pkg_utils_01.f_get_01_name
                                                                                                        (v_id_run, rec1.cod_flusso));

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 2, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 2 - ERRORE in TRUNCATE TABLE '
                                                                                                               || pkg_utils_01.f_get_01_name
                                                                                                               (v_id_run, rec1.cod_flusso
                                                                                                               ));

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master
                        RAISE exception_errore;
                END; 

-- --------------------------------------------------------------------------------------------
            -- STEP 3 Popolo la floating table 01
                BEGIN
                --v_procedura := 'Inserimento in tab floating';
                    v_stmt := 'INSERT /*+ APPEND */ INTO '
                              || pkg_utils_01.f_get_01_name(v_id_run, rec1.cod_flusso)
                              || ' ('
                              || pkg_utils_01.f_get_01_columns_list(v_id_run, rec1.cod_flusso)
                              || ') SELECT '
                              || pkg_utils_01.f_get_01_trasform_type(v_id_run, rec1.cod_flusso)
                              || ' FROM '
                              || pkg_utils_01.f_get_00_per_name(v_id_run, rec1.cod_flusso)
                              || ' A, '
                              || pkg_utils_01.f_get_00_name(v_id_run, rec1.cod_flusso)
                              || ' B '
                              || ' WHERE '
                              || pkg_utils_01.f_get_01_where(v_id_run, rec1.cod_flusso)
                              || ' AND A.ID_PER = '''
                              || v_id_dper
                              || '''';

                    EXECUTE IMMEDIATE v_stmt;
                    COMMIT;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 3, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 3 - Inserimenti effettuati nella floating table:'
                                                                                                        || pkg_utils_01.f_get_01_name
                                                                                                        (v_id_run, rec1.cod_flusso));

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 3, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 3 - Problemi di inserimento nella floating table:'
                                                                                                               || pkg_utils_01.f_get_01_name
                                                                                                               (v_id_run, rec1.cod_flusso
                                                                                                               ));

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master
                        RAISE exception_errore;
                END;

-- ---------------------------------------------------------
             -- STEP 4  Popolo la tabella degli scarti 01_scarti
                BEGIN
                ----v_procedura := 'Inserimento in tab scarti conversione';
                    v_stmt := 'INSERT /*+ APPEND */ INTO '
                              || pkg_utils_01.f_get_01_scarti_name(v_id_run, rec1.cod_flusso)
                              || ' ('
                              || pkg_utils_01.f_get_01_scarti_columns_list(v_id_run, rec1.cod_flusso)
                              || ') '
                              || 'SELECT '
                              || v_id_run
                              || ','
                              || v_id_dper
                              || ','
                              || substr(pkg_utils_01.f_get_01_columns_list(v_id_run, rec1.cod_flusso), instr(pkg_utils_01.f_get_01_columns_list
                              (v_id_run, rec1.cod_flusso), ',') + 1)
                              || ' ,SYSDATE '
                              || ' FROM '
                              || pkg_utils_01.f_get_00_name(v_id_run, rec1.cod_flusso)
                              || ' WHERE '
                              || pkg_utils_01.f_get_01_scarti_where(v_id_run, rec1.cod_flusso);

                    EXECUTE IMMEDIATE v_stmt;
                    COMMIT;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 4, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 4 - Inserimenti effettuati nella tabella degli scarti '
                                                                                                        || pkg_utils_01.f_get_01_scarti_name
                                                                                                        (v_id_run, rec1.cod_flusso));

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 4, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 4 - Problemi di inserimento nella tabella '
                                                                                                               || pkg_utils_01.f_get_01_scarti_name
                                                                                                               (v_id_run, rec1.cod_flusso
                                                                                                               )
                                                                                                               || ' di scarti conversione'
                                                                                                               );

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master
                        RAISE exception_errore;
                END;


            -- STEP 5 verifico esistenza della partizione 
                BEGIN

               ----v_procedura := 'Create or truncate partizioni';
                    v_stmt := 'SELECT count(*)
                FROM   user_tab_partitions  
                WHERE  table_name     = '''
                              || pkg_utils_01.f_get_02_name(v_id_run, rec1.cod_flusso)
                              || ''' AND    partition_name = '''
                              || v_nome_part
                              || '''';

                    EXECUTE IMMEDIATE v_stmt
                    INTO v_count;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 5, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 5 - Partizione preesistente? '
                                            || v_esiste_part);

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 5, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 5 - Problemi verifica partizione '
                                                );

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master
                        RAISE exception_errore;
                END;

                IF v_count = 1           -- esiste, si tratta di un riciclo o ricaricamento dovuto solitamente a dati sporchi 

                 THEN
-- step 5.1 truncate partition (se v_count = 1)
                    BEGIN 
              ----v_procedura := 'Truncate partition';
                        v_stmt := 'ALTER TABLE '
                                  || pkg_utils_01.f_get_02_name(v_id_run, rec1.cod_flusso)
                                  || ' TRUNCATE PARTITION '
                                  || v_nome_part;

                        EXECUTE IMMEDIATE v_stmt;
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 51, p_sqlcode => NULL
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 5.1.1 - TRUNCATE PARTIZIONE '
                                                                                                            || pkg_utils_01.f_get_01_name
                                                                                                            (v_id_run, rec1.cod_flusso
                                                                                                            ));

                    EXCEPTION
                        WHEN OTHERS THEN
                            pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 51, p_sqlcode => sqlcode
                            , p_stmt => v_stmt,
                                                    p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 5.1.1 - ERRORE in TRUNCATE PARTIZIONE '
                                                                                                                   || pkg_utils_01.f_get_01_name
                                                                                                                   (v_id_run, rec1.cod_flusso
                                                                                                                   ));
                    END;                                     

 -- step 5.2 split partition  ((se v_count = 0)
                ELSE
                    BEGIN 
            ----v_procedura := 'Split partition';
                        v_stmt := 'ALTER TABLE '
                                  || pkg_utils_01.f_get_02_name(v_id_run, rec1.cod_flusso)
                                  || ' SPLIT PARTITION P_DEFAULT'
                                  || --------------------------------------- > hai sostituito PARTITION VGLSA con PARTITION P_DEFAULT
                                   ' VALUES ('
                                  || TO_NUMBER ( substr(v_nome_part, 3, 8) )
                                  || ')'
                                  || ' INTO (PARTITION '
                                  || v_nome_part
                                  || ', PARTITION P_DEFAULT)'; ------- > hai sostituito PARTITION VGLSA con PARTITION P_DEFAULT

                        EXECUTE IMMEDIATE v_stmt;
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 50, p_sqlcode => NULL
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 5.0.1 - CREATE PARTIZIONE '
                                                                                                            || pkg_utils_01.f_get_01_name
                                                                                                            (v_id_run, rec1.cod_flusso
                                                                                                            ));

                    EXCEPTION
                        WHEN OTHERS THEN
                            pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 50, p_sqlcode => sqlcode
                            , p_stmt => v_stmt,
                                                    p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 5.0.2 - ERRORE in CREATE PARTIZIONE '
                                                                                                                   || pkg_utils_01.f_get_01_name
                                                                                                                   (v_id_run, rec1.cod_flusso
                                                                                                                   ));
                    END;
                END IF;

             -- STEP 6  Popolo la ST 02
                BEGIN
                ----v_procedura := 'Inserimento nella tabella storica';
                    v_stmt := 'INSERT /*+ APPEND */ INTO '
                              || pkg_utils_01.f_get_02_name(v_id_run, rec1.cod_flusso)
                              || ' ('
                              || pkg_utils_01.f_get_02_columns_list(v_id_run, rec1.cod_flusso)
                              || ') SELECT '
                              || pkg_utils_01.f_get_02_columns_list(v_id_run, rec1.cod_flusso)
                              || ' FROM '
                              || pkg_utils_01.f_get_01_name(v_id_run, rec1.cod_flusso);

                    EXECUTE IMMEDIATE v_stmt;
                    COMMIT;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 6, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 6 - Inserimento nella tabella '
                                                                                                        || pkg_utils_01.f_get_02_name
                                                                                                        (v_id_run, rec1.cod_flusso)
                                                                                                        || ' effettuato.');

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 6, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 6 - Problema nell''inserimento di record nella tabella ST:'
                                                                                                               || pkg_utils_01.f_get_02_name
                                                                                                               (v_id_run, rec1.cod_flusso
                                                                                                               ));

                        v_count_master := v_count_master + 1;    -- incremento del contatore status master      
                        RAISE exception_errore;
                END;

            --STEP 7  Analizzo la tabella
                BEGIN
                ----v_procedura := 'Analisi tabella storica';
                    v_stmt := 'Analyze Table '
                              || pkg_utils_01.f_get_02_name(v_id_run, rec1.cod_flusso)
                              || ' Estimate Statistics Sample '
                              || pkg_utils_01.f_get_st_percent(v_id_run, rec1.cod_flusso)
                              || ' Percent';

                    EXECUTE IMMEDIATE v_stmt;
                    COMMIT;
                    pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 7, p_sqlcode => NULL, p_stmt => v_stmt
                    ,
                                            p_sqlerror_m => NULL, p_procedura => v_procedura, p_note => 'STEP 7 - Analizzata tabella '
                                                                                                        || pkg_utils_01.f_get_02_name
                                                                                                        (v_id_run, rec1.cod_flusso)
                                                                                                        || ' al '
                                                                                                        || pkg_utils_01.f_get_st_percent
                                                                                                        (v_id_run, rec1.cod_flusso));

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_step => 7, p_sqlcode => sqlcode
                        , p_stmt => v_stmt,
                                                p_sqlerror_m => sqlerrm, p_procedura => v_procedura, p_note => 'STEP 7 - Problema analisi della ST:'
                                                                                                               || pkg_utils_01.f_get_02_name
                                                                                                               (v_id_run, rec1.cod_flusso
                                                                                                               ));
                END;                            
       -----------------------------FINITI GLI STEP ------------------------------


                v_scarti_01_scarti := pkg_utils_01.f_get_01_scarti_count(v_id_run, rec1.cod_flusso);   
             -- Inserisco il numero degli scarti nella tabella WRK_AUDIT_CARICAMENTI

                pkg_utils_01.p_audit_caricamenti(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_id_dper => v_id_dper, p_data_inizio => v_ini_caric
                , p_data_fine => sysdate,
                                                p_cod_stato => 'CARICATO', p_val_scarti_external => NULL, p_val_scarti_convert => v_scarti_01_scarti
                                                );

            EXCEPTION
                WHEN exception_errore THEN
                    v_scarti_01_scarti := pkg_utils_01.f_get_01_scarti_count(v_id_run, rec1.cod_flusso);
                    pkg_utils_01.p_audit_caricamenti(p_id_run => v_id_run, p_cod_flusso => rec1.cod_flusso, p_id_dper => v_id_dper, p_data_inizio => v_ini_caric
                    , p_data_fine => sysdate,
                                                    p_cod_stato => 'NON CARICATO', p_val_scarti_external => NULL, p_val_scarti_convert => v_scarti_01_scarti
                                                    );

            END;    -- per racchiudere tutti gli step in un unico blocco e catturare eventuale raise nei blocchi delle eccezioni                     
        END LOOP;                             -- Passo al cod_flusso successivo

    -- -------------- Scrivo il risultato nella tabella wrk_audit_master
        BEGIN
            IF v_count_master = 0 THEN
                BEGIN
                    pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'TUTTO OK', p_start_date => v_ini_caric, --v_ini_caric
                     p_end_date => sysdate);

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'ERRORE NEL TUTTO OK', p_start_date => v_ini_caric
                        , p_end_date => sysdate);
                END;

            ELSIF v_count_master < c1%rowcount THEN
                BEGIN
                    pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'MISTO', p_start_date => v_ini_caric, p_end_date => sysdate
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'ERRORE NEL MISTO', p_start_date => v_ini_caric
                        , p_end_date => sysdate);
                END;
            ELSE
                BEGIN
                    pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'TUTTO NO', p_start_date => v_ini_caric, p_end_date => sysdate
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_master(p_id_run => v_id_run, p_status => 'ERRORE NEL TUTTO NO', p_start_date => v_ini_caric
                        , p_end_date => sysdate);
                END;
            END IF;
        END;

        CLOSE c1;
        COMMIT;
    END;

END;
/



