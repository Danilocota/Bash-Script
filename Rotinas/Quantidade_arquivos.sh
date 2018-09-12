#!/bin/bash
############################################################################################################################
#quantarquivos.sh 													   #
#Feito em 15/07/2018 por Danilo Neto 											   #
#Script feito para fins didáticos seguindo os requisitos dos exercícios de instruções de loop 				   #
#ministrado pelo professor Ricardo Prudenciato para o curso de Shell Script na plataforma Udemy. 			   #
# 															   #
#Script escrito no Oracle Enterprise Linux 7 										   #
# 															   #
#IMPORTANTE!! é recomendado executar esse script como root por questões de permissões.   				   #
# 															   #
#O script análisa a $HOME de todos os usuário "Humanos" no sistema e busca a quantidade de arquivos 			   #
#MP4,MP3,PNG e JPG, obviamente o script pode ser facilmente adaptado para mais arquivos com outras 			   #
#extensões. 														   #
# 															   #
############################################################################################################################
clear 
#O comando abaixo é uma função que busca na $HOME do usuário arquivos com as extensões MP4,MP3, 
#PNG e JPG atravez do comando find juntamente com outras filtragens. 
#Note que a variável $i é declarada no loop for e o $1 é o parâmetro passado mais abaixo no código

verifica() {
		(echo -n "Arquivos $1: " ; cd $(cat /etc/passwd|grep -w $i|cut -d ":" -f6) ; find . -name "*.$1"|wc -l)
}

#Esse loop verifica cada UID no arquivo passwd sendo que por padrão todos os usuários "Humanos" no
#linux tem o UID a partir do número 1000
for i in $(cat /etc/passwd|cut -d ":" -f3)
do
	if [ $i -ge 1000 ]
	then
#Esse echo printa o nome do usuário verificado no loop e joga na tela
		echo "Usuario: $(cat /etc/passwd | grep -w $i|cut -d ":" -f1)"
#Esses 4 parametros esta chamando a função criada anteriormente juntamente com o tipo de extencao.
		verifica mp4
		verifica mp3
		verifica png
		verifica jpg
		echo 
	fi
done
