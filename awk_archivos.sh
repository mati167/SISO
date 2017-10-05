#!/bin/bash
awk -F";" '
BEGIN{
mal=0;cont=0;i=0;j=0;k=0;tot=0;declare -a arr=("Lunes","Martes","Miercoles","Jueves","Viernes","Sabado","Domingo")
}

NR==FRN
{next    #para que no tome el primer renglon,toma uno de mas del otro.
while($2 != ${arr[{!k}]}) k++
a[$k];b[$4];r[NR];tot++
}
 
{for(j=(tot-1);j>0;j--) #para ignorar el ultimo que esta de mas
{	while ($2 != ${arr[{!i}]} )
		{i++}
	hora1=b[cont]
	arrHora1=(${hora1//;/ })
	hora1=${arrHora1[0]}*60
	hora1+=${arrHora1[1]}	
	hora2=$4
	arrHora2=(${hora2//;/ })
	hora2=${arrHora2[0]}*60
	hora2+=${arrHora2[1]}
	cont++;
	res=hora1-hora2
	if(i==k)
	{
		if(res>0)
		{
			res*=-1
			print "se atraso en $1 por $res minutos"	
			mal++	
		}
		elseif(res<0)
		{
			res*=-1
			print "se adelanto en $1 por $res minutos"	
			mal++	
		}
	}
	elseif(i<k)
	{
		res*=-1
		print "TARDE      "	
		mal++	
	}
	else
	{
		res*=-1
		print "TEMPRANO      "	
		mal++	
	}
}
if ( mal=0 )
	print "todo bien" 
}}'$1 $2
