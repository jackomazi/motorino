CREATE TABLE vglsa.grp00_ugo (
    nome  VARCHAR2(100 BYTE),
    data_nascita varchar(100 byte),
    salario varchar(100 byte)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_UGO_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_UGO_LOG'
            SKIP 2
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'ugo.csv' )
) REJECT LIMIT 10;

CREATE TABLE vglsa.grp00_ugoper (
    id_per VARCHAR2(1000 BYTE)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY grp_data_dir ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            BADFILE grp_bad_dir : 'GRP00_UGOPER_SCARTI'
            NODISCARDFILE
            LOGFILE grp_log_dir : 'GRP00_UGOPER_LOG'
            SKIP 0
        FIELDS TERMINATED BY ';' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( grp_data_dir : 'ugo.csv' )
);

CREATE TABLE vglsa.grp01_ugo (
    id_per   NUMBER(6, 0),
    nome VARCHAR2(100 BYTE),
    data_nascita date,
    salario  NUMBER(10, 0)
);

CREATE TABLE vglsa.grp01_ugo_scarti (
    id_run   NUMBER,
    id_per   VARCHAR2(100 BYTE),
    nome VARCHAR2(100 BYTE),
    data_nascita VARCHAR2(100 BYTE),
    salario  VARCHAR2(100 BYTE),
    d_ins    DATE DEFAULT sysdate
);

CREATE TABLE vglsa.grp02_ugo (
    id_per   NUMBER(6, 0),
    nome VARCHAR2(100 BYTE),
    data_nascita date,
    salario  NUMBER(10, 0)
)
    PARTITION BY LIST ( id_per ) ( PARTITION p_default VALUES ( DEFAULT ) );

INSERT INTO vglsa.wrk_anagrafica_flussi (
    cod_flusso,
    flg_disponibile,
    flg_orderby,
    dt_upd_flag
) VALUES (
    'UGO',
    'Y',
    '7',
    NULL
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
    'UGO',
    'GRP00_UGO',
    'GRP00_UGOPER',
    'GRP01_UGO',
    'GRP01_UGO_SCARTI',
    'GRP02_UGO',
    'ID_PER,NOME, DATA_NASCITA, SALARIO',
    'ID_RUN,ID_PER,NOME, DATA_NASCITA, SALARIO,D_INS',
    'ID_PER,NOME, DATA_NASCITA, SALARIO',
    'to_number(ID_PER),NOME, TO_DATE(DATA_NASCITA, ''dd/mm/yyyy''), to_number(SALARIO)',
    '5'
);
insert into vglsa.wrk_chk(
    cod_flusso,
    name_where_01,
    name_where_01_scarti
)values(
    'UGO',
    'PKG_CONTROLS_01.f_is_numeric(ID_PER)=1 AND PKG_CONTROLS_01.f_is_numeric(SALARIO)=1 AND PKG_CONTROLS_01.f_is_positive(SALARIO)=1 AND PKG_CONTROLS_01.f_is_date_control(data_nascita)=1',
    'PKG_CONTROLS_01.f_is_numeric(SALARIO)=0 OR PKG_CONTROLS_01.f_is_positive(SALARIO)=0 OR PKG_CONTROLS_01.f_is_date_control(data_nascita)=0'
);

/*
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
*/
commit;