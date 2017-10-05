#!/bin/bash
if [[ "$1" == "-h" ]] || [[ "$1" == "-?" ]] || [[ "$1" == "-help" ]] ;then
	echo "Modo de empleo 1 : ./Ejercicio4.sh ARCHIVO_VIAJE_TREN.csv ARCHIVO_RUTA.csv"
	echo "Ejemplo : ./Ejercicio4.sh T09_07_08_retiro_tucuman.csv retiro_tucuman.csv" 	
	echo ""
	echo "Ejercicio4.sh comparara los horarios de llegada con los estimados e informara si se retraso o adelanto y en que ciudad, si se cumplieran todos los horarios asi lo notificara."
	echo ""
	echo "Modo de empleo 2 : ./Ejercicio4.sh -r DIRECTORIO"
	echo ""
	echo "Ejercicio4.sh sumara el total de pasajeros, el monto y la cantidad de viajes de cada tren de acuerdo a los archivos de viajes que se encuentren en el directorio pasado por parametro"
	exit 0
fi
if [[ $# -lt 2 ]]; then
	echo "cantidad de parametros incorrecta"
	exit 1
fi
if [[ $1 == "-r" ]];then
	if [[$0 -gt 2]];then
	dirini="$*"
	directory="$(echo -e "{dirini}" | sed -e 's/^-r*//' | tr -d '[:space:]')"
	else
		directory = $2
	fi
	if [[ -d $directory ]]; then
		tren=01
	for tren in {1..20}
	do
	pasajeros=0
	monto=0
	cantidad_viajes=0
		if [ $tren -lt 10 ];then
			list=$(find $1 -name "T0$tren*")
		else
			list=$(find $1 -name "T$tren*")
		fi
			array=(${list// / })
		for i in "${array[@]}"
		do
			((cantidad_viajes++))
			read pasajeros <<< $(echo foo | awk -F";" -v pas=$pasajeros '{pas+=$5}END{print pas}' $i )
			read monto <<< $(echo foo | awk -F";" -v mont=$monto '{mont+=$6}END{print mont}' $i )
		done
		echo "TREN $tren"
		echo "Pasajeros = $pasajeros"
		echo "monto = $monto"
		echo "Cantidad de viajes = $cantidad_viajes"
	done
	else
		echo "no existe el directorio $2"
		exit 2
	fi
fi
if [[ ! -f $1 ]]; then
	echo " $1 no es un archivo"
	exit 3
fi
if [[ ! -s $1 ]]; then
		echo "Archivo $1 Vacio"
		exit 4
fi
if [[ ! -f $2 ]]; then
	echo "$2 no es un archivo"
	exit 5
fi
if [[ ! -s $2 ]]; then
		echo "Archivo $2 Vacio"
		exit 6
fi
		awk -F";" '
BEGIN{
i=0
arr[0] = "Lunes"
arr[1] = "Martes"
arr[2] = "Miercoles"
arr[3] = "Jueves"
arr[4] = "Viernes"
arr[5] = "Sabado"
arr[6] = "Domingo"
}
FNR==NR{ a[$1]=$0 ; next ; bien = 1 }{
		split( a[$1] , Linea , ";")
		if( $3 == "Hora"){}
		else{
			if ( $2 == Linea[2]){
			if( $3 < Linea[4]){
				horaStr = $3
				split( horaStr , hora , ":")
				split(Linea[4] , hora2 , ":")
				dif = hora2[1]*60 + hora2[2] - hora[1]*60 - hora[2]
				print "Llego tarde a" , $1 , "por" , dif , "minutos"
				bien = 0
			}
			if( $3 > Linea[4]){
				horaStr = $3
				split( horaStr , hora , ":")
				split(Linea[4] , hora2 , ":")
				dif = hora[1]*60 + hora[2] - hora2[1]*60 - hora2[2]
				print "Llego temprano a" , $1 , "por" , dif , "minutos"
				bien = 0
			}
			if( $3 == Linea[4]){
				print "Llego bien a la estación de" , $1
			}}
			else{
					while( $2 != arr[i]){
						i++}
					while(linea[2] != arr[j] ){
						j++}
					if(i>j){
					i-=j
					print "Llego", i , "dias antes a", $1
					bien =0}
					else{
					j-=i
					print "Llego", j, "dias tarde a", $1
					bien = 0}	
			 }
		}
		if (bien == 1){
			print "Cumplio todos los horarios"
		}
	}' $1 $2
#fi


