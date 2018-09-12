#!/bin/bash
#####################################################################################################################################
#backup_home.sh															    # 
#Criado em 09/07/2018 por Danilo Neto												    # 
#																    # 
#Script feito para fins didáticos seguindo os requisitos dos exercícios de instruções condicionais do professor Ricardo Prudenciato # 
#para o curso de Shell Script ministrado na plataforma udemy.									    # 
#																    #
#Script escrito no Oracle enterprise Linux 7.											    # 
#Repare que o script gera um arquivo compactado na pasta $HOME/backup do usuário, para descompactar use o comando: 		    # 
#tar -xzvf nome_do_arquivo_de_backup												    # 
#####################################################################################################################################
#
#Esse primeiro bloco verifica o horário do sistema e escreve uma mensagem na tela de acordo com o período.
clear
HORA=$(date +%H)
if [ "$HORA" -ge 00 -a "$HORA" -lt 12 ]
then
	echo "Bom dia"
	echo "$(date +%r)AM"
elif [ "$HORA" -ge 12 -a "$HORA" -lt 18 ]
then
	echo "Boa tarde"
	echo "$(date +%r)PM"
elif [ "$HORA" -ge 18 -a "$HORA" -lt 24 ]
then
	echo "Boa noite"
	echo "$(date +%r)PM"
else
	echo "Erro"
fi
#Abaixo é declarado dois arrays que servem para verificar a resposta do usuário, no caso sim e não.
V1=("sim" "s" "y" "yes" "")
V2=("nao" "no" "n" "não")
#Abaixo é iniciado toda a lógica do script para verificar se a pasta backup já existe na pasta $HOME do usuário logado e 
#tambem verifica se já foi feito um backup nos ultimos 7 dias.
read -p "Deseja criar um backup da sua home?[S][n]: " RESP
if [[ "${V1[@]}" =~ "${RESP,,}" ]] 
then
	if [ -e $HOME/backup ]
	then
	find $HOME/backup/backup_home* -type f -ctime -7 &>> /dev/null
		if [ $? -eq 0 ]
		then
			read -p "Já existe um backup criado nos ultimos 7 dias, deseja cria-lo mesmo assim?[S][n]: " BAK1
			if [[ "${V1[@]}" =~ "${BAK1,,}" ]]
			then
				(cd $HOME ; tar -czvf backup/backup_home_$(date +%Y%m%d%H%M.tar.gz) *[!"backup"]* &>> /dev/null)
			echo "Backup criado em $(ls -t $HOME/backup/backup_home_*|head -n1)"
			elif [[ "${V2[@]}" =~ "${BAK1,,}" ]]
			then
				echo "Ok! Saindo.." && sleep 1
				exit 1
			fi
		else
			(cd $HOME ; tar -czvf backup/backup_home_$(date +%Y%m%d%H%M.tar.gz) *[!"backup"]* &>> /dev/null)
			echo "Backup criado em $(ls -t $HOME/backup/backup_home_*|head -n1)"
		fi
	else
		read -p "Não foi encontrado um diretorio de backup em $HOME, deseja criar um?[S][n]: " BAK2
		if [[ "${V1[@]}" =~ "${BAK2,,}" ]]
		then
			mkdir $HOME/backup
			(cd $HOME ; tar -czvf backup/backup_home_$(date +%Y%m%d%H%M.tar.gz) *[!"backup"]* &>> /dev/null)
			echo "Backup criado em $(ls -t $HOME/backup/backup_home_*|head -n1)"
		elif [[ "${V2[@]}" =~ "${BAK2,,}" ]]
		then
			echo "OK! backup cancelado"
			exit 1
		fi
	fi
elif [[ "${V2[@]}" =~ "${RESP,,}" ]]
then
	echo "Ok! saindo.." && sleep 1
fi
