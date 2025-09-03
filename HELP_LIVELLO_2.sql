
SELECT UPPER(TRIM(VAL_TBL_NAME))
          FROM WRK_ANAGRAFICA_FLUSSI
          WHERE UPPER(TRIM(VAL_TBL_NAME)) LIKE 'FCT%';
          
SELECT table_name,
             partition_name
      FROM   user_tab_partitions
      WHERE  table_name = pkg_utils_02.f_get_fact_table 
      AND    partition_name = 'P_202503';
      
      
      
BEGIN P_LOAD_ANA_SCD();
END;
/
SELECT ID_DIP,COD_UNT,COD_RUOLO
      FROM   D_ANAGRAFICA_SCD       -- se la dimensione è vuota, alza eccezione
                                    -- NODATAFOUND e riempie la dimensione con
                                    -- i valori della lista
      WHERE  COD_DIP  = 363
      AND    D_ENDVAL  IS NULL;
      
      
      
      

MERGE INTO D_RUOLI_MERGE A -- FA OPERAZIONI SU D_RUOLI_MERGE
USING V_RUOLI_MERGE B      -- CONFRONTANDO CON LA RELATIVA VISTA
ON (A.COD_RUOLO = B.COD_RUOLO) 
WHEN MATCHED THEN          -- SE TROVA UN COD_RUOLO IN ENTRAMBI
UPDATE SET                 -- FA L'UPDATE
   A.DESC_RUOLO = B.DESC_RUOLO,  
   A.D_UPD = SYSDATE,
   A.LAST_ID_PER = B.ID_PER 
WHEN NOT MATCHED THEN      -- SE NELLA DIMENSIONE NON C'è IL COD_RUOLO
INSERT (                   --  LO AGGIUNGE
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
      );
      
