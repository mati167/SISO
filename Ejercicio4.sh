#!/bin/bash
if [[$1 = "-h"]] || [[$1 = "-?"]] || [[$1 = "-help"]] ;then
	#hacer cosas de get-help
	exit 0
fi
if [[ $# -lt 2 ]]; then
	echo "cantidad de parametros incorrecta"
	exit 1
elif [[ $1 = "-r" ]];then
	if [[$0 -gt 2]];then
	directory="$*"
	sed '1,3 d' directory > directory
	else
		directory = $2
	if [[ -d $directory ]]; then
		echo "Es directorio"
		#es un directorio, hacer cosas de directorio
		for i in *.csv; do
			cat "$i" | awk -F "|" '{print $2}' >> nuevo.txt 
	else
		echo "no existe el directorio $2"
		exit 2
	fi
elif [[ -f $1 ]]; then
	if [[ ! -s $1 ]]; then
		echo "Archivo $1 Vacio"
		exit 3
	fi
	if [[ ! -s $2 ]]; then
		echo "Archivo $2 Vacio"
		exit 4
	fi
	echo -e "Es un Archivo"
	#es un archivo, haces cosas de archivo
	awk -F; 'BEGIN{ i=0
declare -a arr=("Lunes""Martes""Miercoles""Jueves""Viernes""Sabado""Domingo")}{
		while ($2 != ${arr[{!i}]} )
			{i++}
		while($2 != 
		
		}' $1 , $2
fi

#if [$# -gt 0 ];then
#	for ((i=1; i<=$#;i++))
#	do
#		if [-s ${!i}]
#			echo "Archivo $$i vacio"
#			exit 2
#		fi
#	done
#	fi

#for ((i=1; i<=$#;i++))
#do
#	if [-f ${!i} ]
#	else
#	echo "no existe el archivo ${!i} "
#	fi
#done

#fin validacion



