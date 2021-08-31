#!bin/bash

questionSAMBA="Nome do novo compartilhamento SAMBA"
msgBemVindo="
	Bem vindo ao projeto de redes de computadores!

	Aqui eu usei shell script pra fazer programas
	básicos que configuram o sistema
"
title_continua="Adicionar mais um usuario ?"
msg_continua="Deseja adicionar mais um usuario ?"
question_comment="Digite um comentario para o compartilhamento" 
question_permissions="Quais seram as permições do compartilhamento"

function msg {
	echo "

=========================================================================================



			       $1



=========================================================================================

	"
}

function addShare {
	share_name=$1
	dir_name=$2
	users=$3
	comment="$4"
	w_r=$5

	case $w_r in

		"w")

			echo "
[$share_name]
	path=$dir_name
	valid users=${users[*]}
	comment="$comment"
	writable=yes
			">>/etc/samba/smb.conf;;
		"r")

			echo "
[$share_name]
	path=$dir_name
	valid users=${users[*]}
	comment="$comment"
	readble=yes
			">>/etc/samba/smb.conf;;

		"wr")

			echo "
[$share_name]
	path=$dir_name
	valid users=${users[*]}
	comment="$comment"
	writable=yes
	readble=yes
			">>/etc/samba/smb.conf;;

		*)

			echo "
[$share_name]
	path=$dir_name
	valid users=${users[*]}
	comment="$comment"
			">>/etc/samba/smb.conf;;
	esac

}

function addHost {
	echo "$1 $2" >> /etc/hosts
}

function addUser {

	user_name=$1

	exists=`grep -c "^$user_name" /etc/passwd`

	if [ $exists -eq 0 ]; then
		dialog --title "New User" --msgbox "Criando o usuario $user_name" 10 30
		useradd -m $user_name
		passwd $user_name
	fi

	dialog --title "New User" --msgbox "Agora defina a nova senha SAMBA" 10 30
	smbpasswd -a $user_name


}

function createDir {
	dir=$1
	if ! [ -d $dir ]
	then
		if [ ${dir:0:1} = "/" ]; then
			mkdir $dir
			chmod 777 $dir
		else
			mkdir "/$dir"
			chmod 777 "/$dir"
		fi
	fi
}



if ! [ -x "$(command -v dialog)" ]; then
	msg "INICIANDO A INSTALAÇÂO DO DIALOG"

	sudo apt-get install dialog

	msg "FINALIZADA A INSTALAÇÂO DO DIALOG"
fi


dialog --title "Bem vindo" --msgbox "$msgBemVindo" 10 60

menu_do=$(dialog --menu "Qual Configuração você deseja fazer:" 20 40 20\
	1 "novo compartilhamento SAMBA"\
	2 "novo host" --stdout 
)

case $menu_do in
	1)

		count=0
		i=0
		users=()

		share_name=$(dialog --inputbox "$questionSAMBA" 10 30 --stdout)
		comment=$(dialog --inputbox "$question_comment" 10 30 --stdout)
		dir_name=$(dialog --inputbox "Digite o nome do diretório" 10 30 --stdout)

		while [ $count -eq 0 ]
		do
			user_name=$(dialog --inputbox "nome do usuario $i" 10 30 --stdout)

			addUser "$user_name"    # add on samba and system
			users[$i]="$user_name"  # add on array

			if ! dialog --title "$title_continua" --yesno "$msg_continua" 10 30
			then
				count=1
			fi
			i=$[$i+1]
		done

		createDir $dir_name

		p_do=$(dialog --menu "$question_permissions" 20 40 20\
		1 "Leitura"\
		2 "Escrita"\
		3 "Leitura e escrita"\
		4 "Nenhuma" --stdout )

		case $p_do in
			1) addShare "$share_name" "$dir_name" "${users[*]}" "$comment" "r";;
			2) addShare "$share_name" "$dir_name" "${users[*]}" "$comment" "w";;
			3) addShare "$share_name" "$dir_name" "${users[*]}" "$comment" "wr";;
			*) addShare "$share_name" "$dir_name" "${users[*]}" "$comment" "";;
		esac

		dialog --title "Sucesso!" --msgbox "
		==========================================
		 Compartilhamento adicionado com sucesso!
		==========================================


		$(tail -10 /etc/samba/smb.conf)
		" 30 50

		;;

	2)
		host_name=$(dialog --inputbox "Nome do novo host" 10 30 --stdout)
		host_ip=$(dialog --inputbox "IP do novo host" 10 30 --stdout)

		addHost $host_ip $host_name

		dialog --title "Sucesso!" --msgbox "
		==========================================
		       Host adicionado com sucesso!
		==========================================


		$(cat /etc/hosts)
		" 40 50;;

	*)
		;;
esac


