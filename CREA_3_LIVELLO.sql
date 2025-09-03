/******************************************************************************

             Connettersi come system e lanciare questo script.
 
******************************************************************************/ 

-------------------------------------------------------------- 
----------------CREAZIONE NUOVO UTENTE------------------------
--------------------------------------------------------------

DROP USER VGLMV CASCADE;

CREATE USER VGLMV
IDENTIFIED BY vglmv
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;

-- RUOLI E PRIVILEGI DA ASSEGNARE ALL'UTENTE:
-- RUOLI
GRANT CONNECT TO VGLMV;
GRANT DBA TO VGLMV;
GRANT RESOURCE TO VGLMV;
ALTER USER VGLMV DEFAULT ROLE NONE;
-- PRIVILEGI
GRANT MERGE ANY VIEW TO VGLMV;
GRANT CREATE ANY TABLE TO VGLMV;
GRANT UNLIMITED TABLESPACE TO VGLMV;
GRANT DEBUG CONNECT SESSION TO VGLMV;
GRANT DROP ANY DIRECTORY TO VGLMV;
GRANT CREATE ANY DIRECTORY TO VGLMV;
GRANT DEBUG ANY PROCEDURE TO VGLMV;
GRANT QUERY REWRITE TO VGLMV;
GRANT UPDATE ANY TABLE TO VGLMV;
GRANT CREATE ANY PROCEDURE TO VGLMV;
GRANT CREATE ANY VIEW TO VGLMV;
GRANT CREATE ANY MATERIALIZED VIEW TO VGLMV;
GRANT CREATE SEQUENCE TO VGLMV;
GRANT CREATE TABLE TO VGLMV;
GRANT SELECT ANY TABLE TO VGLMV;
GRANT CREATE SESSION TO VGLMV;



-------------
GRANT SELECT ON VGLDM.D_UNITA_SCD TO VGLMV;
GRANT SELECT ON VGLDM.FCT_PRESENZE TO VGLMV;

GRANT GLOBAL QUERY REWRITE TO VGLMV;
--------------------------------------------------------
--  DDL for Materialzed view
--------------------------------------------------------

	CREATE MATERIALIZED VIEW MV_ORE_PER_UNT
	BUILD IMMEDIATE
	REFRESH ON DEMAND
	ENABLE QUERY REWRITE
	AS
		SELECT DESC_UNT, SUM(OREPRES)
		FROM VGLDM.D_UNITA_SCD JOIN VGLDM.FCT_PRESENZE
		USING (ID_UNT)
		GROUP BY DESC_UNT;


	CREATE MATERIALIZED VIEW MV_ORE_PER_RUOLO
	BUILD IMMEDIATE
	REFRESH FORCE ON DEMAND
	ENABLE QUERY REWRITE
	AS SELECT DESC_RUOLO, SUM(OREPRES)
		FROM VGLDM.D_RUOLI_MERGE JOIN VGLDM.FCT_PRESENZE
		USING (ID_RUOLO)
		GROUP BY DESC_RUOLO; 	 

--Raccogliere le statisticeh dopo la creazione delle viste materialzzate

/*
------------------------------------------------------------
--Collegarsi come VGLMV 
--Eseguire il blocco anonimo che crea il gruppo di mv
------------------------------------------------------------
	
BEGIN
 DBMS_REFRESH.MAKE(NAME => 'ORE_REFRESH_GROUP',
 LIST => 'ORE_PER_UNT_MV,ORE_PER_RUOLO_MV',
 NEXT_DATE => SYSDATE,
 INTERVAL => 'SYSDATE+ 1') ;
END;
*/
ALTER SESSION SET QUERY_REWRITE_ENABLED = FALSE;

	EXPLAIN PLAN FOR
SELECT DESC_UNT, SUM(OREPRES)
		FROM VGLDM.D_UNITA_SCD JOIN VGLDM.FCT_PRESENZE
		USING (ID_UNT)
		GROUP BY DESC_UNT;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/*
Plan hash value: 3578172057
 
--------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name         | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |              |    23 |  2093 |   859   (5)| 00:00:01 |       |       |
|   1 |  HASH GROUP BY                |              |    23 |  2093 |   859   (5)| 00:00:01 |       |       |
|   2 |   NESTED LOOPS                |              |    23 |  2093 |   858   (5)| 00:00:01 |       |       |
|   3 |    NESTED LOOPS               |              |    23 |  2093 |   858   (5)| 00:00:01 |       |       |
|   4 |     VIEW                      | VW_GBC_5     |    23 |   598 |   858   (5)| 00:00:01 |       |       |
|   5 |      HASH GROUP BY            |              |    23 |   115 |   858   (5)| 00:00:01 |       |       |
|   6 |       PARTITION LIST ALL      |              |   435K|  2124K|   829   (2)| 00:00:01 |     1 |     4 |
|   7 |        TABLE ACCESS FULL      | FCT_PRESENZE |   435K|  2124K|   829   (2)| 00:00:01 |     1 |     4 |
|*  8 |     INDEX UNIQUE SCAN         | UNITA_PK     |     1 |       |     0   (0)| 00:00:01 |       |       |
|   9 |    TABLE ACCESS BY INDEX ROWID| D_UNITA_SCD  |     1 |    65 |     0   (0)| 00:00:01 |       |       |
--------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   8 - access("D_UNITA_SCD"."ID_UNT"="ITEM_1")
 
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - this is an adaptive plan
   */
    
ALTER SESSION SET QUERY_REWRITE_ENABLED = TRUE;
	EXPLAIN PLAN FOR
SELECT DESC_UNT, SUM(OREPRES)
		FROM VGLDM.D_UNITA_SCD JOIN VGLDM.FCT_PRESENZE
		USING (ID_UNT)
		GROUP BY DESC_UNT;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


/*
Plan hash value: 614374269
 
-----------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                |    24 |  1560 |     2   (0)| 00:00:01 |
|   1 |  MAT_VIEW REWRITE ACCESS FULL| MV_ORE_PER_UNT |    24 |  1560 |     2   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------
 
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
*/

-- OGNI GIORNO FA IL REFRESH
BEGIN
 DBMS_REFRESH.MAKE(NAME => 'ORE_REFRESH_GROUP',
 LIST => 'VGLMV.MV_ORE_PER_UNT,VGLMV.MV_ORE_PER_RUOLO',
 NEXT_DATE => SYSDATE,
 INTERVAL => 'SYSDATE+ 1') ;
END;

-----------------------------------------------------------
--  DDL for Package di refresh delle viste materialzzate
-----------------------------------------------------------

CREATE OR REPLACE PACKAGE VGLMV.PKG_REFRESH
AS
	PROCEDURE p_refresh;
END;

--------------------------------------------------------------
--  DDL for Body Package di refresh delle viste materialzzate
--------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY VGLMV.PKG_REFRESH
AS
	PROCEDURE p_refresh AS
        BEGIN
            DBMS_MVIEW.REFRESH('MV_ORE_PER_UNT');
            DBMS_MVIEW.REFRESH('MV_ORE_PER_RUOLO');
        END;
END;

--------Controllare dall'explain plan di opportune queries la possibilità di query rewrite.