#!/bin/bash
####################################################################################
#Script criado por Danilo Neto, feito no Oracle Linux 7
#Versão do Oracle: 12c R2
#Esse script foi criado apenas para fins didáticos, integrando comandos do RMAN com 
#shell script e agendamento no crontab
####################################################################################

clear
#Verificando se o usuário que está executando o script é o usuário oracle
if [[ ${USER,,} != "oracle" ]]
then
	echo "Erro, esse script pode ser executado apenas com o usuario oracle!"
	exit 1
fi

#Criando uma pasta para centralizar os backup, nesse script a pasta é criada na home do usuário oracle.
if [[ -d '/home/oracle/backup_rman' ]]
then
	echo ""	
else
	mkdir /home/oracle/backup_rman
	if [[ $? -ne 0 ]]
	then
		echo 'Não foi possivel criar a pasta no caminho /home/oracle/backup_rman'
		exit 1
	fi
fi

cd /home/oracle/backup_rman
#Criando subpastas dentro da pasta backup_rman para cada backup feito no rman
DIA=$(date +%d%m%y%H%M%S)
PASTA="backup_rman_$DIA"
mkdir $PASTA

#Executando um  backup full simples do Oracle junto com o spfile,controlfile e os archivelogs

rman target/ <<EOF
run{
backup as compressed backupset full database tag = 'FULL_FULL_database' format '/home/oracle/backup_rman/$PASTA/full_database_%T_%I_%d_%s.bkp';
backup as compressed backupset spfile tag = 'full_full_spfile' format '/home/oracle/backup_rman/$PASTA/full_spfile_%T_%I_%d_%s.bkp';
backup as compressed backupset current controlfile tag = 'full_full_controlfile' format '/home/oracle/backup_rman/$PASTA/full_controlfile_%T_%I_%d_%s.bkp';
backup as compressed backupset archivelog all delete all input tag = 'full_full_archivelog' format '/home/oracle/backup_rman/$PASTA/full_archive_%T_%I_%d_%s.bkp';
}
EOF
