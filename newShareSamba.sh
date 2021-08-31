function addUsers {
	users=($1 $2 $3 $4 $5 $6 $7)
	
	for user in ${users[@]}
	do
		exists=`grep -c "^$user" /etc/passwd`
		
		if [ $exists -eq 0 ]; then
			echo "CRIANDO O USUARIO $user"
			useradd -m $user
			echo "DEFINA UMA SENHA PRA ELE"
			passwd $user
		fi

		echo "
		============================
		
		  samba password for $user
		
		============================
		"
	
		smbpasswd -a $user

		echo "

		============================
		
		"
	done

}

function createDir {
	dir=$1

	if [ -d $dir ]
	then
		echo "DIRETORIO JA EXISTE"	
	else
		if [ ${dir:0:1} = "/" ]; then 
			mkdir $dir
			chmod 777 $dir
		else 
			mkdir /$dir
			chmod 777 /$dir
		fi
		echo "DIRETORIO $dir CRIADO!"
	fi


}

function addSambaShare {
	# $5 -> ESCREVIVEL PELO CLIENTE
	# $6 -> LEGIVEL PELO CLIENTE	
	share=$1
	dir=$2
	users=($3)

	echo "
[$share]
	path=$dir
	vaid users=${users[*]}
	" >> /etc/samba/smb.conf

	if [ $5 = "s" ]; then 
		echo "		writable=yes" >> /etc/samba/smb.conf
	fi

	if [ $6 = "s" ]; then
		echo  "		public=yes" >> /etc/samba/smb.conf
	fi
}

read -p "NOME DO COMPARTILHAMENTO: " share_name
#read -p "COMENTARIO: " comment
read -p "DIRETÓRIO: " dir_name
read -p "NOME DOS USUARIOS(SEPARADOS COM UM ESPAÇO' ')" users
read -p "O CLIENTE VAI PODER ESCREVER NO DIRETORIO: s/N " writable
read -p "O CLIENTE VAI PODER LER NO DIRETORIO: s/N " readble

createDir $dir_name
	
addUsers $users

addSambaShare $share_name $dir_name "${users[*]}" $writable $readble

###############################################################################

clear
echo "
	=======================================================================
	
	
		    REINICIANDO O SAMBA E APLICANDO AS CONFIGURAÇÕES
	
	
	========================================================================
"
systemctl restart smbd
		
echo "


	========================================================================


		    		CONFIGURAÇÃO ATUAL smb.conf


	========================================================================

	
"
cat /etc/samba/smb.conf


