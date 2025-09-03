execute pkg_alimentazione_02.p_main;


INSERT INTO FCT_PRESENZE(
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
FROM V_INSERT_PRESENZE;

-------------------------------------------------------


-- 9473
--CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGLDM"."V_INSERT_PRESENZE" ("ID_PERIOD", "ID_YEAR_MONTH", "ID_DIP", "ID_UNT", "ID_RUOLO", "OREPRES", "ORESTRAOR", "OREPERMES") AS 
  SELECT   p.id_period,
           p.id_year_month,
           b.id_dip,
           c.id_unt,
           d.id_ruolo,
           a.orepres,
           a.orestraor,
           a.orepermes
    FROM   VGLSA.GRP02_PRS a,  -- tabelle 02 delle presenze
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


truncate table fct_presenze;




