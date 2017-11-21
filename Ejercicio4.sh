#!/bin/bash
#TP N2, Ejercicio 4, entrega 2.
#Integrantes:
#39769558|Castillo, Tomas Eugenio
#38325166|Gonzalez Romero, Matias
#36808247|Oviedo, Leandro
#39486259|Rivero, Facundo
#40134364|Sanabria, Facundo
if [[ "$1" == "-h" ]] || [[ "$1" == "-?" ]] || [[ "$1" == "-help" ]] ;then
	echo -e "\nModo de empleo 1 : ./Ejercicio4.sh ARCHIVO_VIAJE_TREN.csv ARCHIVO_RUTA.csv"
	echo "Ejemplo : $0 T09_07_08_retiro_tucuman.csv retiro_tucuman.csv" 	
	echo ""
	echo "$0 comparara los horarios de llegada con los estimados e informara si se retraso o adelanto y en que ciudad, si se cumplieran todos los horarios asi lo notificara."
	echo -e "\n"
	echo "Modo de empleo 2 : ./Ejercicio4.sh -r DIRECTORIO"
	echo ""
	echo -e "$0 sumara el total de pasajeros, el monto y la cantidad de viajes de cada tren de acuerdo a los archivos de viajes que se encuentren en el directorio pasado por parametro\n"
	exit 0
fi
if [[ $# -lt 2 ]]; then
	echo "cantidad de parametros incorrecta"
	exit 1
fi
if [[ $1 == "-r" ]];then
	if [[ $# -gt 3 ]];then
		dirini="$*"
		directorio="$(echo -e "${dirini}" | sed -e 's/^-r .\/*//')"		
		directorio="$(echo $PWD/$directorio)"	
else
		directorio="$(echo $2)"
fi
	if [[ -d $directorio ]]; then
		tren=01
	mkfifo pipeEj4
	for tren in {1..20}
	do
	pasajeros=0
	monto=0
	cantidad_viajes=0
	contador=0
	array=()
	
		if [ $tren -lt 10 ];then
			#list=$(find "${directorio}" -name "T0$tren*")
			find "${directorio}" -name "T0$tren*" > pipeEj4 &
			 while read line;do			
				array[${contador}]=$line
				#echo -e "$contador\t${array[${contador}]}"
				contador=$((contador+1))
			done < pipeEj4
		else
			#list=$(find "${directorio}" -name "T$tren*")
			find "${directorio}" -name "T$tren*" > pipeEj4 &
			 while read line;do
				array[${contador}]=$line
				#echo -e "$contador\t${array[${contador}]}"
				((contador++))
			done < pipeEj4
		fi
		for i in "${array[@]}"
		do
			if [[ ! -z "$i" ]];then 
				((cantidad_viajes++))
			fi			
			read pasajeros <<< $(echo foo | awk -F";" -v pas=$pasajeros '{pas+=$5}END{print pas}' "$(echo ${i})" )
			read monto <<< $(echo foo | awk -F";" -v mont=$monto '{mont+=$6}END{print mont}' "$(echo ${i})" )
		done
		echo -e "\nTREN $tren"
		echo "Pasajeros = $pasajeros"
		echo "monto = $monto"
		echo -e "Cantidad de viajes = $cantidad_viajes\n"
	done
	rm pipeEj4
	else
		echo "no existe el directorio $directorio"
		exit 2
	fi
	
else
if [[ ! -f $1 ]]; then
	if [[ $1 == "-r" ]];then
		exit 3		
	fi
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
				}
			}
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
fi


