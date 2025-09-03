CREATE OR REPLACE PACKAGE BODY pkg_alimentazione_01_custom AS 
-- PLOAD UNT
    PROCEDURE p_main IS

        v_id_run           NUMBER;                     -- id del caricamento
        v_id_dper          VARCHAR2(8);               --id della data del periodo di riferimento
        v_stmt             VARCHAR2(32767);           -- stringa statement
        v_count            NUMBER;
        v_exist            NUMBER(1);
        v_periodo          NUMBER(8);                 -- partizione
        v_procedura        VARCHAR2(255) := 'PKG_ALIMENTAZIONE_01_CUSTOM.PMAIN';
        v_nome_tab_part    VARCHAR2(30);              --nome tabella partizionata
        v_nome_part        VARCHAR2(30);              --nome partizione
        v_esiste_part      NUMBER(1);
        v_ini_caric        DATE;                       -- data inizio caricamento
        v_fin_caric        DATE;                       -- data fine caricamento
        v_scarti_01_scarti NUMBER;                     -- conta il num di righe scartate
        exception_errore EXCEPTION;                  -- eccezione dichiarata
        v_count_master     NUMBER := 0;               -- contatore relativo allo status delle eccezioni
    BEGIN
        v_id_run := seq_id_run.nextval;   -- sequenza
        v_ini_caric := sysdate;
        BEGIN
        -- STEP 1 -- estraggo periodo dalla tabella GRP00_UNTPER
            BEGIN
                SELECT
                    id_per
                INTO v_id_dper
                FROM
                    grp00_untper
                WHERE
                    ROWNUM = 1;

                v_stmt := 'select id_per into v_id_per from GRP00_UNTPER WHERE rownum = 1';
                v_nome_part := 'P_' || to_char(v_id_dper);   --  ad uso della gestione delle partizioni per le tabelle 02 - vedi step successivi

                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 1,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'Caricamento del periodo '
                              || v_id_dper
                              || ' del flusso '
                              || 'UNITA'
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 1,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'ERRORE: periodo non trovato per il flusso' || 'UNITA'
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master
                    RAISE exception_errore;
            END;
        -- STEP 2 - Tronco la floating table 01
            BEGIN
                v_stmt := 'TRUNCATE TABLE GRP01_UNT';
                EXECUTE IMMEDIATE v_stmt;
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 2,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 2 - TRUNCATE TABLE '
                              || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 2,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 2 - ERRORE in TRUNCATE TABLE '
                                  || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master
                    RAISE exception_errore;
            END;
-- --------------------------------------------------------------------------------------------
        -- STEP 3 Popolo la floating table 01        
            BEGIN
                INSERT /* + APPEND */ INTO grp01_unt (
                    id_per,
                    cod_unt,
                    desc_unt
                )
                    SELECT
                        TO_NUMBER(id_per),
                        TO_NUMBER(cod_unt),
                        desc_unt
                    FROM
                        grp00_untper a,
                        grp00_unt    b
                    WHERE
                            pkg_controls_01.f_is_numeric(id_per) = 1
                        AND pkg_controls_01.f_is_numeric(cod_unt) = 1
                        AND a.id_per = v_id_dper;

                v_stmt := 'insert /* + APPEND */ 
            into GRP01_UNT
            (ID_PER, COD_UNT, DESC_UNT)
            select to_number(ID_PER), to_number(COD_UNT), to_number(DESC_UNT)
            from 
            GRP00_UNTPER A, GRP00_UNT B
            where 
            PKG_CONTROLS_01.f_is_numeric(ID_PER) = 1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)= 1
            and A.ID_PER = v_id_dper';
                COMMIT;
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 3,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 3 - Inserimenti effettuati nella floating table:'
                              || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 3,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 3 - Problemi di inserimento nella floating table:'
                                  || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master
                    RAISE exception_errore;
            END;
-- ---------------------------------------------------------
        -- STEP 4  Popolo la tabella degli scarti 01_scarti
            BEGIN
                INSERT /*+ APPEND */ INTO grp01_unt_scarti (
                    id_run,
                    id_per,
                    cod_unt,
                    desc_unt,
                    d_ins
                )
                    SELECT
                        v_id_run,
                        v_id_dper,
                        cod_unt,
                        desc_unt,
                        sysdate
                    FROM
                        grp00_unt
                    WHERE
                        pkg_controls_01.f_is_numeric(cod_unt) = 0;

                v_stmt := 'INSERT /*+ APPEND */ 
            INTO GRP01_UNT_SCARTI
            (ID_RUN, ID_PER, COD_UNT, DESC_UNT, D_INS)
            SELECT v_id_run, 
                    v_id_dper,
                    COD_UNT,
                    DESC_UNT,
                    SYSDATE
            from GRP00_UNT
            where 
                PKG_CONTROLS_01.f_is_numeric(COD_UNT)=0';
                COMMIT;
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 4,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 4 - Inserimenti effettuati nella tabella degli scarti '
                              || pkg_utils_01.f_get_01_scarti_name(v_id_run, 'UNITA')
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 4,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 4 - Problemi di inserimento nella tabella '
                                  || pkg_utils_01.f_get_01_scarti_name(v_id_run, 'UNITA')
                                  || ' di scarti conversione'
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master
                    RAISE exception_errore;
            END;
        -- STEP 5 verifico esistenza della partizione 
            BEGIN
                SELECT
                    COUNT(*)
                INTO v_count
                FROM
                    user_tab_partitions
                WHERE
                        table_name = 'GRP02_UNT'
                    AND partition_name = v_nome_part;

                v_stmt := 'select count(*)
        from user_tab_partitions
        where table_name = GRP02_UNT
        and partition_name = v_nome_part';
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 5,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 5 - Partizione preesistente? ' || v_esiste_part
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 5,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 5 - Problemi verifica partizione '
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master
                    RAISE exception_errore;
            END;

            IF v_count = 1           -- esiste, si tratta di un riciclo o ricaricamento dovuto solitamente a dati sporchi 

             THEN
-- step 5.1 truncate partition (se v_count = 1)
                BEGIN
                    v_stmt := 'ALTER TABLE GRP02_UNT 
                    TRUNCATE PARTITION ' || v_nome_part;
                    EXECUTE IMMEDIATE v_stmt;
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 51,
                        p_sqlcode    => NULL,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => NULL,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 5.1.1 - TRUNCATE PARTIZIONE '
                                  || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(
                            p_id_run     => v_id_run,
                            p_cod_flusso => 'UNITA',
                            p_step       => 51,
                            p_sqlcode    => sqlcode,
                            p_stmt       => v_stmt,
                            p_sqlerror_m => sqlerrm,
                            p_procedura  => v_procedura,
                            p_note       => 'STEP 5.1.1 - ERRORE in TRUNCATE PARTIZIONE '
                                      || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                        );
                END;                                     

 -- step 5.2 split partition  ((se v_count = 0)
            ELSE
                BEGIN
        ----v_procedura := 'Split partition';
                    v_stmt := 'ALTER TABLE GRP02_UNT'
                              || ' SPLIT PARTITION P_DEFAULT'
                              || --------------------------------------- > hai sostituito PARTITION VGLSA con PARTITION P_DEFAULT
                               ' VALUES ('
                              || TO_NUMBER ( substr(v_nome_part, 3, 8) )
                              || ')'
                              || ' INTO (PARTITION '
                              || v_nome_part
                              || ', PARTITION P_DEFAULT)'; ------- > hai sostituito PARTITION VGLSA con PARTITION P_DEFAULT
                    EXECUTE IMMEDIATE v_stmt;
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 50,
                        p_sqlcode    => NULL,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => NULL,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 5.0.1 - CREATE PARTIZIONE '
                                  || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_log(
                            p_id_run     => v_id_run,
                            p_cod_flusso => 'UNITA',
                            p_step       => 50,
                            p_sqlcode    => sqlcode,
                            p_stmt       => v_stmt,
                            p_sqlerror_m => sqlerrm,
                            p_procedura  => v_procedura,
                            p_note       => 'STEP 5.0.2 - ERRORE in CREATE PARTIZIONE '
                                      || pkg_utils_01.f_get_01_name(v_id_run, 'UNITA')
                        );
                END;
            END IF;

     -- STEP 6  Popolo la ST 02
            BEGIN
                INSERT /*+ APPEND */ INTO grp02_unt (
                    id_per,
                    cod_unt,
                    desc_unt
                )
                    SELECT
                        id_per,
                        cod_unt,
                        desc_unt
                    FROM
                        grp01_unt;

                v_stmt := 'INSERT /*+ APPEND */ 
        INTO GRP02_UNT
        (ID_PER, COD_UNT, DESC_UNT)
        select ID_PER, COD_UNT, DESC_UNT
        from
        GRP01_UNT';
                COMMIT;
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 6,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 6 - Inserimento nella tabella '
                              || pkg_utils_01.f_get_02_name(v_id_run, 'UNITA')
                              || ' effettuato.'
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 6,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 6 - Problema nell''inserimento di record nella tabella ST:'
                                  || pkg_utils_01.f_get_02_name(v_id_run, 'UNITA')
                    );

                    v_count_master := v_count_master + 1;    -- incremento del contatore status master      
                    RAISE exception_errore;
            END;
        --STEP 7  Analizzo la tabella
            BEGIN
                ----v_procedura := 'Analisi tabella storica';
                v_stmt := 'Analyze Table GRP02_UNT'
                          || ' Estimate Statistics Sample 5'
                          || ' Percent';
                EXECUTE IMMEDIATE v_stmt;
                COMMIT;
                pkg_utils_01.p_audit_log(
                    p_id_run     => v_id_run,
                    p_cod_flusso => 'UNITA',
                    p_step       => 7,
                    p_sqlcode    => NULL,
                    p_stmt       => v_stmt,
                    p_sqlerror_m => NULL,
                    p_procedura  => v_procedura,
                    p_note       => 'STEP 7 - Analizzata tabella '
                              || pkg_utils_01.f_get_02_name(v_id_run, 'UNITA')
                              || ' al '
                              || pkg_utils_01.f_get_st_percent(v_id_run, 'UNITA')
                );

            EXCEPTION
                WHEN OTHERS THEN
                    pkg_utils_01.p_audit_log(
                        p_id_run     => v_id_run,
                        p_cod_flusso => 'UNITA',
                        p_step       => 7,
                        p_sqlcode    => sqlcode,
                        p_stmt       => v_stmt,
                        p_sqlerror_m => sqlerrm,
                        p_procedura  => v_procedura,
                        p_note       => 'STEP 7 - Problema analisi della ST:'
                                  || pkg_utils_01.f_get_02_name(v_id_run, 'UNITA')
                    );
            END;                            
       -----------------------------FINITI GLI STEP ------------------------------
            v_scarti_01_scarti := pkg_utils_01.f_get_01_scarti_count(v_id_run, 'UNITA');   
             -- Inserisco il numero degli scarti nella tabella WRK_AUDIT_CARICAMENTI

            pkg_utils_01.p_audit_caricamenti(
                p_id_run              => v_id_run,
                p_cod_flusso          => 'UNITA',
                p_id_dper             => v_id_dper,
                p_data_inizio         => v_ini_caric,
                p_data_fine           => sysdate,
                p_cod_stato           => 'CARICATO',
                p_val_scarti_external => NULL,
                p_val_scarti_convert  => v_scarti_01_scarti
            );

        EXCEPTION
            WHEN exception_errore THEN
                v_scarti_01_scarti := pkg_utils_01.f_get_01_scarti_count(v_id_run, 'UNITA');
                pkg_utils_01.p_audit_caricamenti(
                    p_id_run              => v_id_run,
                    p_cod_flusso          => 'UNITA',
                    p_id_dper             => v_id_dper,
                    p_data_inizio         => v_ini_caric,
                    p_data_fine           => sysdate,
                    p_cod_stato           => 'NON CARICATO',
                    p_val_scarti_external => NULL,
                    p_val_scarti_convert  => v_scarti_01_scarti
                );
           -- per racchiudere tutti gli step in un unico blocco e catturare eventuale raise nei blocchi delle eccezioni                     
        END;

        BEGIN
            IF v_count_master = 0 THEN
                BEGIN
                    pkg_utils_01.p_audit_master(
                        p_id_run     => v_id_run,
                        p_status     => 'TUTTO OK',
                        p_start_date => v_ini_caric, --v_ini_caric
                        p_end_date   => sysdate
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_master(
                            p_id_run     => v_id_run,
                            p_status     => 'ERRORE NEL TUTTO OK',
                            p_start_date => v_ini_caric,
                            p_end_date   => sysdate
                        );
                END;

            ELSE
                BEGIN
                    pkg_utils_01.p_audit_master(
                        p_id_run     => v_id_run,
                        p_status     => 'TUTTO NO',
                        p_start_date => v_ini_caric,
                        p_end_date   => sysdate
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        pkg_utils_01.p_audit_master(
                            p_id_run     => v_id_run,
                            p_status     => 'ERRORE NEL TUTTO NO',
                            p_start_date => v_ini_caric,
                            p_end_date   => sysdate
                        );
                END;
            END IF;
        END;

        COMMIT;
    END;

END;