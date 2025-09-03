execute pkg_alimentazione_01.p_main;

alter table grp00_ana drop column COD_DIP;

SELECT substr(pkg_utils_01.f_get_01_columns_list(1, 'ANAGRAFICA'), 
instr(pkg_utils_01.f_get_01_columns_list(1, 'ANAGRAFICA'), ',') + 1)
FROM dual;


select count(*) from user_tab_partitions where table_name = 'GRP02_ANA'
and partition_name = 'P_200909';

--ALTER USER VGLSA QUOTA UNLIMITED ON USERS;


execute pkg_alimentazione_01.p_main;