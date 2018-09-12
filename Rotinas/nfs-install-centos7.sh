#!/bin/bash
#######################################################################################
#nfs-install-centos7.sh								      #
#Feito em 02/08/2018 por Danilo Neto 						      #
# 										      #
#Script para a instalação do serviço NFS (Testado apenas no CentOS 7). 		      #
# 										      #
#Script escrito no CentOS 7. 							      #
# 										      #
#IMPORTANTE!! o script só é executado se o usuário for o root!!. 		      #
# 										      #
#O script faz a instalação do serviço de NFS de forma automática, onde ele 	      #
#solicita a pasta que sera utilizada para compartilhar os arquivos e se 	      #
#essa pasta poderá ser acessada por todos os hosts ou por hosts específicos. 	      #
# 										      #
#Para adicionar mais pastas ao serviço NFS basta executar o script 		      #
#mais de uma vez e indicar a pasta a ser compartilhada. 			      #
# 										      #
#######################################################################################
#Verificando se o usuário é o root! caso queira executar com outro usuário basta comentar esse primeiro bloco de if
if [[ ${USER,,} != "root" ]]
then
	echo "Por favor, faça login como Root!"
	exit 1
else
	clear
fi
#Verificando se o pacote já está instalado, caso não ele é instalado.
echo "Iniciando instalador nfs-server..."
while true
do
if [ $(yum list installed|grep nfs-utils|grep -v grep| wc -l) -ge 1 ]
then
	break
else
	echo "Instalando o pacote nfs-utils..."
	yum install nfs-utils -y
fi
done
#Arrays com as opções de input.
OPS=("" "sim" "yes" "s" "y")
OPN=("nao" "não" "n" "no")

PASTA=0
#Loop para verificar qual o diretório desejável para compartilhar arquivos.
while true
do
if [[ $SAIDA -eq 1 ]]
then
	break
fi
clear
read -p "Deseja utilizar o diretorio padrão /nfs para compartilhar arquivos do servidor nfs [S/n]? " V1
if [[ ${OPS[@]} =~ ${V1,,} ]]
then
	if [[ -e "/nfs" ]]
	then
		PASTA="/nfs"
		echo
		echo "Repositorio /nfs definido."
		break
	else
		mkdir /nfs
		PASTA="/nfs"
		echo
		echo "Repositorio /nfs definido."
		break
		fi
elif [[ ${OPN[@]} =~ ${V1,,} ]]
then
	while true
	do
		read -p "Digite o caminho do diretorio a ser compartilhado: " V2
		if [[ -e $V2 ]]
		then
			PASTA="$V2"
			echo "Diretorio $V2 definido."
			SAIDA=1
			break
		else
			echo "Erro!! Diretorio não encontrado. Verifique o caminho especificado."
		fi
	done
else
	echo "OPÇÃO INVALIDA!"
fi
done

#função para pegar os hosts desejados no compartilhamento caso opte por não compartilhar com toda a rede.
func1() {
echo
echo "Digite o IP da maquina"
read -p "IP: " IP
echo
echo "Digite a Mascara da maquina"
read -p "MASCARA: " MASC
MAQUINA="$IP/$MASC"
}

#Função para definir as opções de compartilhamento.
fun2() {
while true
do
	echo
	echo "Leia com atencao!!!"
	echo
	read -p "Deseja compartilhar a pasta $PASTA com todas as maquinas na rede?[S/n]? " RESP1
	if [[ "${OPS[@]}" =~ "${RESP1,,}" ]]
	then
		MAQUINA="*"
		break
	elif [[ "${OPN[@]}" =~ "${RESP1,,}" ]]
	then
		func1
		break
	else
		echo
		echo "OPÇAO INVALIDA!!"
fi
done

while true
do
	echo -e "\nA maquina com o IP $IP e MASCARA $MASC tem privilegios de Apenas leitura ou Leitura e escrita?\n\n[1-Apenas leitura]\n[2-Leitura e escrita]\n"
	read -p "Opcao: " RESP2
	if [[ "$RESP2" = "1" ]]
	then
		PRIV="r"
		break
	elif [[ "$RESP2" = "2" ]]
	then
		PRIV="rw"
		break
	else
		echo
		echo "OPCAO INVALIDA!!"
	fi
done
}

EXIT=0
#Bloco de loop para continuar pegando os hosts desejáveis enquanto a resposta for sim.
while true
do
	if [[ $EXIT -eq 1 ]]
	then
		break
	fi
	fun2
	echo
	echo  "$PASTA	$MAQUINA($PRIV,sync,no_root_squash,no_subtree_check)"|tee -a /etc/exports
	echo
	if [[ $MAQUINA != "*" ]]
	then
		while true
		do
			read -p "Deseja adicionar uma outra maquina? [S/n]: " NOVO
			if [[ "${OPS[@]}" =~ "${NOVO,,}" ]]
			then
				func1
				echo
				echo "$PASTA	$MAQUINA($PRIV,sync,no_root_squash,no_subtree_check)"|tee -a /etc/exports
				echo
			elif [[ "${OPN[@]}" =~ "${NOVO,,}" ]]
			then
				EXIT=1
				break
			fi
		done
	else
		break
	fi
done

GRAV_COD=()

echo "Aplicando configuraçoes finais..."
#Gerando logs em caso de falhas na inicialização dos serviços.
systemctl enable rpcbind 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[0]=$?
systemctl enable nfs-server 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log
GRAV_COD[1]=$?
systemctl enable nfs-lock 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[2]=$?
systemctl enable nfs-idmap 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[3]=$?
systemctl start rpcbind 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log
GRAV_COD[4]=$?
systemctl start nfs-server 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[5]=$?
systemctl start nfs-lock 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[6]=$?
systemctl start nfs-idmap 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[7]=$?
systemctl restart nfs-server 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[8]=$?


firewall-cmd --permanent --zone=public --add-service=nfs 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[9]=$?
firewall-cmd --permanent --zone=public --add-service=mountd 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[10]=$?
firewall-cmd --permanent --zone=public --add-service=rpc-bind 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[11]=$?
firewall-cmd --reload 1>> /var/log/nfsinstall.log 2>> /var/log/nfsinstallerro.log 
GRAV_COD[12]=$?
CS=0
for i in ${GRAV_COD[@]}
do
	if [[ $i -ge 1 ]]
	then
		CS=1
	fi
done

if [[ $CS -ge 1 ]]
then
	echo -e "\nNFS configurado com erros!! verifique os logs em /var/log/nfsinstallerro.log para mais detalhes."
else
	echo "NFS configurado com sucesso!"
fi
