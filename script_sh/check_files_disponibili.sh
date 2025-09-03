#!/usr/bin/sh

#Configurazione variabili ambiente Oracle
#ORACLE_HOME='C:\Oracle\product\11.2.0\dbhome_1'
ORACLE_HOME='C:\app\Administrator\product\11.2.0\dbhome_1'
ORACLE_SID='orcl'
oracle_usr='VGLSA'
oracle_pwd='VGLSA'

#Configurazione variabili ambiente script
log_dir='/cygdrive/c/vgl/script_elenco_flussi/Flussi_log'
data_dir='/cygdrive/c/vgl/script_elenco_flussi/Flussi/'
data_dir1='/cygdrive/c/vgl/script_elenco_flussi/Flussi/elenco_flussi1.csv'
data_dir2='/cygdrive/c/vgl/script_elenco_flussi/Flussi/elenco_flussi2.csv'
data_dir3='/cygdrive/c/vgl/script_elenco_flussi/Flussi/elenco_flussi3.csv'
rec_dati_dir1='/cygdrive/c/vgl/grp/data/'
rec_dati_dir2='/cygdrive/c/vgl/asl/data/'
rec_dati_dir3='/cygdrive/c/vgl/coge/data/'
script_dir='/cygdrive/c/vgl/script_sh/'
script='check_files_disponibili'
log_file=${log_dir}/${script}.log


#Procedura per scrittura log
write_log()
{
  testo=$*
  start=1
  dim=200
  timestamp=$(date "+%Y%m%d_%H%M%S")
  lun=$(expr length "$testo")
  until [[ $lun -lt $start ]]; do
    stringa=$(expr substr "$testo" $start $dim)
    echo "$timestamp~$stringa" >>$log_file
    start=$(expr $start + $dim)
  done
}


#Aggiornamento elenco file: inserisce nel file 'elenco_flussi' tutti i flussi che sono 
#presenti nelle tre directory data di vgl(asl,coge,grp) mediante la concatenazione dei file 
#contenenti singolarmente i flussi delle directory asl,coge,grp rispettivamente. 
write_log "Aggiornamento elenco file..."
#GRP
cd $rec_dati_dir1
ls | grep csv > $data_dir1
ret=$?
write_log "Aggiornamento elenco file con esito $ret"
cd $script_dir
#ASL
cd $rec_dati_dir2
ls | grep csv > $data_dir2
ret=$?
write_log "Aggiornamento elenco file con esito $ret"
cd $script_dir
#COGE
cd $rec_dati_dir3
ls | grep csv > $data_dir3
ret=$?
write_log "Aggiornamento elenco file con esito $ret"
cd $script_dir
#CONCATENO FILE
cd $data_dir
ls
CAT elenco_flussi1.csv elenco_flussi2.csv elenco_flussi3.csv > elenco_flussi.csv

#Lancio procedura PL/SQL per aggiornamento anagrafica file, ovvero legge i flussi presenti in 'elenco_flussi' e setta su 'Y' il flaf disponibili
#Se va tutto a buon fine restituisce 0 e quindi ret=0 altrimenti 1 e quindi ret=1. 
write_log "Lancio procedura PL/SQL..."

sqlplus -s ${oracle_usr}/${oracle_pwd}@${ORACLE_SID} <<EOF
   WHENEVER SQLERROR EXIT 99
   SET HEAD OFF
   SET FEED OFF
   SET PAGES 0
   variable ret number
   
      begin 
      
      :ret := fnc_check_files_disponibili;
      
	  
      exception
      when others then
      :ret := 5;
      end;
   /
   
   exit :ret
EOF

#Controllo esito sqlplus
ret=$?
write_log "Esito procedura PL/SQL $ret"

echo "ret=$ret"

#Shell script terminato
write_log "Shell script terminato con esito $ret"

exit;