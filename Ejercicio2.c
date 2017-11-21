
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <dirent.h>


typedef char* tinfo;

typedef struct t{
char *files[30];
unsigned long int cant;
unsigned long int vocales;
unsigned long int consonantes;
unsigned long int otros;
char* mayor;
struct tm f_ult;
char* menor;
struct tm f_pri;
char* primero;
char* ultimo;
char* dirsal;
unsigned long int cant_mayor;
unsigned long int cant_menor;
}t;


typedef struct snodo
{
    tinfo           info;
    struct  snodo   *sig;
}tnodo, *tpila;


void CrearPila(tpila *p)
{
    *p = NULL;
}

int SacarDePila (tpila *p, tinfo *d)
{
	
    tnodo *aux;
    if (*p == NULL)
        return 0;
	
    	aux = *p;
	*d = aux->info;   //en esta linea explota todo :C	
	*p = aux->sig;
    free(aux);
    return 1;
}


int PonerEnPila(tpila *p,tinfo d)
{
    tnodo *nue = (tnodo *)malloc(sizeof(tnodo));
    if(nue==NULL)
        return 0;
    nue->info = d;
    nue->sig = *p;
    *p = nue;
    return 1;
}
void mostrar(t* param){
	printf("%s\n",param->files[0]);
}
void func(t *param){ 
	//t* files = (t*) param;
	int i,j;
	int mayorvoc;
	unsigned long int total;
	char *linea;
	FILE *fp;
	FILE *fichero;
	char* str;
	time_t ini = time(NULL);
	time_t fin = time(NULL);
	printf("\tENTRE AL THREAD\n");
	printf("Archivo: %s\n",param->files[0]);
	printf("Direccion del archivo:%p\n",param->files[0]);
	for(i=0;i<(param->cant);i++)
	{
		//abro el archivo a analizar
		fp = fopen(param->files[i],"rt");
		if(fp)
		{	//inicializo en 0
			total = param->vocales = param->consonantes = param->otros = 0;
			
			//hora de inicio
			struct tm tini = *localtime(&ini);

			//leo los caracteres
			fgets(linea,sizeof(linea),fp);
			while(*linea)
			{
				if((*linea >= 65 && *linea <= 90) || (*linea >=97 && *linea <= 122))
				{
	if(*linea == 65 || *linea == 69 || *linea == 73 || *linea == 79 || *linea == 85 || *linea == 97 || *linea == 101 || *linea == 105 || *linea == 111 || *linea == 117)
						{
							param->vocales++;			
						}
					else
						param->consonantes++;

				}	
				else
				{
					param->otros++;
				}	
				fgets(linea,sizeof(linea),fp);
			}
			//sumo todos los caracteres
			total = param->vocales + param->consonantes + param->otros;
			//hora de fin
			struct tm tfin = *localtime(&fin);
			//si es el primer archivo pongo el primero si el ultimo, el ultimo
			if(!i)
			{
				param->f_pri = tfin;
				strcpy(param->primero,param->files[i]); //esto no esta andando :C
			}
			else if(i==(param)->cant-1)
			{
				param->f_ult = tfin;
				strcpy(param->ultimo,param->files[i]); //esto no esta andando :C
			}		
			//grabo los datos del archivo
			strcpy(str,param->dirsal); //ver esto
			strcat(str,param->files[i]);   //creo el directorio con el archivo
			fichero = fopen(str,"wt");
			fprintf(fichero, "%d:%d:%d\n%lu\n%lu\n%lu\n%lu\n%d:%d:%d\n",tini.tm_hour,tini.tm_min,tini.tm_sec,(long int)pthread_self(),param->vocales,param->consonantes,param->otros,tfin.tm_hour,tfin.tm_min,tfin.tm_sec);//poner datos en archivo de salida 
				
			fclose(fichero);
			fclose(fp);
			//guardo los mayores y menores	
			if(total > param->cant_mayor)
				{
					param->cant_mayor = total;
					strcpy(param->mayor,param->files[i]); //esto no esta andando :C
				}
			if(total < param->cant_mayor)
			{
				param->cant_menor = total;
				strcpy(param->menor,param->files[i]);
			}
		}
		else{
			printf("error abriendo %p\t%s\t%d\n",&param->files[i],param->files[i],i); //no esta andando :C
		}
	}
}





unsigned int validarParametro(char *c, unsigned int *ret)
{
    unsigned int a=1;
    *ret=0;
	
    if(ret == NULL || c==NULL || (*c)=='\0')
        return 0;
   
	do
    {
        if ((*c)>='0' && (*c) <='9'){
            *ret = a*(*ret) + (int)(*c-'0');    
            a=10;
        }
        else
            return 0;
        c++; 
    }while (*c!='\0');
	
    return 1;
}


int main(int argc, char *argv[])
{
int i;
int archivos;
int filesXth;
unsigned int p;
tpila pila;


//validacion de parametros
if(argc < 4)
{
	perror("Faltan parametros");
	return EXIT_FAILURE;
}
DIR* dirIn = opendir(argv[1]);
if(!dirIn){//veo si existe la entrada
perror("No existe 1\n");
return EXIT_FAILURE;
}

 if(validarParametro(argv[3],&p) < 0)
    {
	
        fprintf(stderr, "El tercer parametro  (\"%s\") no es un valor valido para paralelismo\n",argv[3]);
        return EXIT_FAILURE;
    }

DIR* dirOut = opendir(argv[2]);

if(!dirOut)
{

mkdir(argv[2],0777);
}

if(!p)
{
	perror("El paralelismo no puede ser menor que 0");
        return EXIT_FAILURE;
}
closedir(dirOut);
CrearPila(&pila);
//leo todos los archivos de la entrada
struct dirent *dir;
  if (dirIn)
  {
    while ((dir = readdir(dirIn)) != NULL)
    {
	if(strstr (dir->d_name,".txt") || strstr (dir->d_name,".sh") || strstr (dir->d_name,".cvs"))
	{	archivos++;

		PonerEnPila(&pila,dir->d_name);
	} 
    }
    closedir(dirIn);
  }
if ( archivos%p != 0 ){
        printf("El nivel de paralelismo no admite un reparto equitativo respecto a la cantidad de archivos\n");
        return EXIT_FAILURE;
    }


///ASIGNACION HILOS
    pthread_t th[p];
    filesXth = archivos/p;
    t param[p];	
	int j;	
    for(i=0;i<p;i++,j+=(archivos/p))
    {
	for(j=0;j<filesXth;j++)
		{SacarDePila (&pila,&(param[i].files[j]));
		}
	
        param[i].cant = filesXth;
	param[i].dirsal = argv[2];
	fprintf(stdout,"%s\n",param[i].files[0]);
	printf("Directioro Salida:%s\n",param[i].dirsal);
	printf("Direccion del archivo:%p\n",param[i].files[0]);
	func(&param[i]);
        if(pthread_create(&(th[i]),NULL,(void*)func,(void*)&param[i]))
            return EXIT_FAILURE;
    }
    ///ASIGNACION HILOS

//ESPERANDO QUE TERMINEN LOS THREADS
for(i=0;i<p;i++)
	pthread_join(th[i],NULL);

//INFORME
unsigned long int menor=99999999;
unsigned long int mayor =0;
char* nom_mayor;
char* nom_menor;
char* nom_pri;
char* nom_ult;
time_t t_prim;
time_t t_ult;
time_t primero_auxiliar;
time_t ultimo_auxiliar;
for(i=0;i<p;i++)
{
	printf("\tThread: %lu\n",(long int)th[i]);
	for(j=0;j<filesXth;j++)
	{
		printf("%s\n",*param[i].files);
	}
	if(param[i].cant_mayor > mayor)
	{
		mayor = param[i].cant_mayor;
		strcpy(nom_mayor,param[i].mayor);
	}
	if(param[i].cant_menor < menor)
	{
		menor = param[i].cant_menor;
		strcpy(nom_menor,param[i].menor);
	}
	//if(comparar_fecha(&param[i].f_pri,&prim) < 0)
	  primero_auxiliar = mktime(&param[i].f_pri);
	  if(difftime(primero_auxiliar,t_prim) < 0)	
	{
		t_prim = primero_auxiliar;
		strcpy(nom_pri,param[i].primero);
	}
	ultimo_auxiliar = mktime(&param[i].f_ult);
	if(difftime(ultimo_auxiliar,t_ult) > 0)
	//if(comparar_fecha(&param[i].f_ult,&ult) > 0)
	{
		t_ult = ultimo_auxiliar;
		strcpy(nom_ult,param[i].ultimo);
	}
}
struct tm prim = *localtime(&t_prim);
struct tm ult = *localtime(&t_ult);
printf("Archivo con menor cantidad de caracteres: %s\tTotal: %lu\n",nom_menor,menor);
printf("Archivo con mayor cantidad de caracteres: %s\tTotal: %lu\n",nom_mayor,mayor);
printf("Archivo que finalizo primero: %s\tHora: %d:%d:%d\n",nom_pri,prim.tm_hour,prim.tm_min,prim.tm_sec);
printf("Archivo que finalizo ultimo: %s\tHora: %d:%d:%d\n",nom_ult,ult.tm_hour,ult.tm_min,ult.tm_sec);
return 0;
}
