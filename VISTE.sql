select *
from fct_presenze fp
join d_anagrafica_scd d
on fp.id_dip = d.id_dip
where fp.id_dip = 7;

select fp.id_year_month, sum(fp.orepres), sum(fp.orepermes) 
from fct_presenze fp
join d_anagrafica_scd da
on fp.id_dip = da.id_dip
where fp.id_dip = 7
group by fp.id_year_month;

select rank() over (partition by fp.id_year_month order by sum(fp.orepres))
from fct_presenze fp
join d_unita_scd du
on fp.id_unt = du.id_unt;

with agg_prese as (
    select
        fp.id_unt,
        fp.id_year_month,
        sum(fp.orepres) as tot_orepres
    from
        fct_presenze fp
    join
        d_unita_scd du
    on fp.id_unt = du.id_unt
    group by fp.id_unt,fp.id_year_month
)
select
id_unt,
id_year_month,
  tot_orepres,
  RANK() OVER (PARTITION BY id_year_month ORDER BY tot_orepres DESC) AS rank_mensile
FROM agg_prese;


select fp.id_unt, du.desc_unt, sum(fp.orepres)
from
    fct_presenze fp
join
    d_unita_scd du
on fp.id_unt = du.id_unt
group by fp.id_unt, du.desc_unt;


-- V1: PRIMI 5 RUOLI X NUMERO DI ORE LAVORATE IN TOTALE NEGLI ULTIMI 3 MESI
create or replace force view vgldm.mv_query_1 (id_ruolo, desc_ruolo, tot_ore)
as
with agg_pres as( -- seleziona tutti i ruoli raggruppati, con la somma delle ore
    select 
        fp.id_ruolo,
        dr.desc_ruolo,
        sum(fp.orepres) tot_ore
    from fct_presenze fp
    join d_ruoli_merge dr
    on fp.id_ruolo = dr.id_ruolo
    group by fp.id_ruolo,
        dr.desc_ruolo),
ranked as(
    select 
        id_ruolo,
        desc_ruolo,
        tot_ore,
        rank() over (order by tot_ore desc) ranked
        from agg_pres
    )
select id_ruolo,
        desc_ruolo,
        tot_ore
from ranked
where ranked <= 5;

-- V2: conta il numero di persone che lavorano nei 5 ruoli con più ore lavorate
create or replace force view vgldm.v_query_2(id_ruolo, tot_persone) as 
WITH ruoli AS (
    SELECT
        id_ruolo
    FROM
        mv_query_1
), -- seleziona id dei 5 ruoli con più ore
 persone AS (
    SELECT DISTINCT
        p.id_dip,
        p.id_ruolo
    FROM
             d_anagrafica_scd a
        JOIN fct_presenze  p ON a.id_dip = p.id_dip
        JOIN d_ruoli_merge r ON p.id_ruolo = r.id_ruolo
        JOIN ruoli ON r.id_ruolo = ruoli.id_ruolo
)   -- seleziona id_dipendenti senza ripetizioni (questo per togliere le 
    -- ripetizioni dovute alle presenze nei vari giorni)
SELECT
    id_ruolo,
    COUNT(*) tot_persone
FROM
    persone
GROUP BY
    id_ruolo;

-- V3: mette insieme le 2 viste precedenti e aggiunge una colonna con la proporzione
create or replace force view vgldm.v_query_3(id_ruolo,desc_ruolo, tot_ore, tot_persone, prop) as
WITH ore AS (
    SELECT
        *
    FROM
        mv_query_1
), persone AS (
    SELECT
        *
    FROM
        v_query_2
)
SELECT
    o.id_ruolo, o.desc_ruolo, o.tot_ore, p.tot_persone, round((tot_ore/tot_persone),2) prop
FROM
         ore o
    JOIN persone p ON o.id_ruolo = p.id_ruolo
    order by tot_ore/tot_persone desc;
    

-- V4 fa come V3 ma per tutti i ruoli, così da avere un giusto rank
create or replace force view v_query_4(id_ruolo, desc_ruolo, tot_ore, tot_persone, prop) as
with 
all_ruo as(
    select r.id_ruolo,
            r.desc_ruolo,
            sum(fp.orepres) tot_ore
    from fct_presenze fp
    join d_ruoli_merge r
    on fp.id_ruolo = r.id_ruolo
    group by r.id_ruolo,
            r.desc_ruolo),
ranked as (
    select id_ruolo,
            desc_ruolo,
            tot_ore,
            rank() over (order by tot_ore desc) ranked
    from all_ruo),
persone as (
    select
        p.id_ruolo, count(*) tot_persone
        from d_anagrafica_scd a
        join fct_presenze p
        on a.id_dip = p.id_dip
        group by p.id_ruolo)

    select 
        r.id_ruolo, 
        r.desc_ruolo, 
        r.tot_ore, 
        p.tot_persone, 
        round(r.tot_ore/p.tot_persone, 2) prop 
    from ranked r
    join persone p
    on r.id_ruolo = p.id_ruolo
    order by r.tot_ore/p.tot_persone desc;

-- v5 mostra il totale di ore lavorate nei diversi giorni della settimana
create or replace force view v_query_5(day_of_week, day_name, tot_ore) as
select dp.day_of_week, dp.day_name, sum(p.orepres) tot_ore
from fct_presenze p
join d_period dp
on p.id_period = dp.id_period
group by dp.day_of_week, dp.day_name
order by dp.day_of_week;

-- v6 mostra, per ogni giorno della settimana il numero totale di persone che
-- lavora in quel giorno, questo per ogni mese
select 

    
    
