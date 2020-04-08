#!/bin/bash

#Funcion que muestra la ayuda
function ayuda(){
    echo "Este script se ha creado con la finalidad de comprimir los archivos de log que se encuentren en un directorio"
    echo "Dejando solamente uno de los archivos de log en el mismo."
    echo "Ejecución del script"
    echo "./TP1EJ4.sh -f 'path_de_los_archivos_de_log' -z 'path_del_directorio_donde_se_hara_el_Zip' -e 'nombre_empresa'"
    echo "El parámetro -e 'nombre_empresa' es opcional. En caso de no enviarlo, el script aplicará para cada una de las empresas"
    echo "Los parámetros -f 'path_de_los_archivos_de_log' -z 'path_del_directorio_donde_se_hara_el_Zip' son obligatorios"
	exit 0
} 

#Funcion que me hace salir del script si los parámetros no son correctos
function salir1(){
    echo "El numero de parametros no es correcto"
    echo "Ingrese './TP1EJ4.sh -h' O './TP1EJ4.sh -?' O './TP1EJ4.sh -help' para ver la ayuda"
    exit 1
}

#Funcion que me hace salir del script si la ruta de archivos de log ingresada no es válida
function salir2(){
    echo "La ruta de los archivos de Log no es un directorio VALIDO";
	exit 2;
}

#Funcion que me hace salir del script si la ruta donde se hara el Zip ingresada no es válida
function salir25(){
    echo "La ruta del directorio donde se hará el Zip no es un directorio VALIDO";
	exit 25;
}

#Funcion que me hace salir del script si la ruta de archivos de log ingresada está vacía
function salir3(){
    echo "No hay archivos en el directorio que usted pasó por parámetro";
	exit 3;
}

#Verifico si el usuario quiere ver la ayuda
if [ $1 = "-h" -o $1 = "-?" -o $1 = "-help" ]
then
	ayuda
fi

#valido que el numero de parametro sea correcto
if [ $# -ne 4 ]; then
    if [ $# -ne 6 ]; then
        salir1
    fi
fi

#valido que la primer ruta pasada sea un directorio
if [ ! -d "$2" ] 
then
	salir2
fi

#valido que la ruta pasada tenga archivos
dato=$(ls -1 "$2" | wc -l)

if [ "$dato" -eq 0 ] 
then
	salir3
fi

#valido que la segunda ruta pasada sea un directorio
if [ ! -d "$4" ] 
then
	salir25
fi

#Me muevo al directorio sobre el que quiero trabajar
cd "$2"

#Lo que tengo que revisar es si me pasaron 4 parámetros. Si esto es verdad, no tengo el nombre de ninguna empresa 
if [ $# -eq 4 ]; then
    archivos=$( find -maxdepth 1 -name "*.log")
fi

declare -A nombreEmpresas
repetidos=0

for f in $archivos
    do
        seRepitio=1
        nuevoNombre=`echo $f | sed "s/log//" | tr -d '[0-9],-'./`
        for a in ${nombreEmpresas[@]}
        do
            if [ "$a" == "$nuevoNombre" ]; then
                seRepitio=0
            fi
        done 
        if [ $seRepitio -eq 1 ]; then
            nombreEmpresas[$repetidos]+=$nuevoNombre
            let "repetidos++"
        fi
    done

echo "Empresas: "
echo
for f in ${nombreEmpresas[@]}
do
    echo $f
done

#Si tengo 6 parámetros, quiere decir que me pasaron el nombre de una empresa 
if [ $# -eq 6 ]; then
    empresa=$6  #me guardo el nombre de la empresa
    archivos=$( find -maxdepth 1 -name "$empresa-[0-9]*.log") #me quedo con los archivos que sean de esa empresa
    contador=0  #contador para saber cuantos archivos tengo. lo necesitaré para validad datos más adelante
    for i in $archivos  #cuento los archivos
    do
        let "contador++"
    done
    if [ $contador -eq 0 ]; then    #si el contador es 0, no tengo archivos. No puedo seguir
        echo "No se han encontrado archivos para la empresa $empresa en el directorio"
        exit 4
    fi
    if [ $contador -eq 1 ]; then    #si el contador es 1, la empresa solo tiene un archivo de log. No hace falta seguir
        echo "La empresa $empresa solo tiene un archivo de log. No hace falta comprimir"
        exit 5
    fi
    mayor=0     #uso esta bandera para saber cuál es el número de mayor tamaño
    for f in $archivos  #recorro los archivos y me iré quedando con los números. así sabré cual es el mayor
    do
        nuevoNombre=`echo $f | tr -d '[a-z],-'./`
        if [ $mayor -lt $nuevoNombre ]; then
            mayor=$nuevoNombre
        fi
    done
    comparacion="./$empresa-$mayor.log" #nombre del último archivo de log. lo usaré para comparar
    cd $2   #me muevo al directorio donde están los archivos de Log. Así no tendré problemas
    for a in $archivos
    do
        if [ $a != $comparacion ]; then #me fijo si un archivo tiene nombre distinto al archivo que se va a quedar en la carpeta
            zip -m "$4/$empresa" $a #si se cumple la condición, lo agrego al archivo zip
        fi
    done
fi

