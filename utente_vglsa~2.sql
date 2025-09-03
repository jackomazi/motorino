select to_number(ID_PER), to_number(COD_UNT), DESC_UNT
            from 
            GRP00_UNTPER A, GRP00_UNT B
            where 
            PKG_CONTROLS_01.f_is_numeric(ID_PER) = 1 AND PKG_CONTROLS_01.f_is_numeric(COD_UNT)= 1
            and A.ID_PER = '200909';
            
execute PKG_ALIMENTAZIONE_01_CUSTOM.p_main;