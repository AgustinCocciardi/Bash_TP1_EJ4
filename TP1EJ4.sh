#!/bin/bash

#Funcion que muestra la ayuda
function ayuda(){
    echo "Este script se ha creado con la finalidad de comprimir los archivos de log que se encuentren en un directorio"
    echo "Dejando solamente uno de los archivos de log en el mismo."
    echo "Ejecución del script"
    echo "./TP1EJ4.sh -f 'path_de_los_archivos_de_log' -z 'path_del_directorio_donde_se_hara_el_Zip' -e 'nombre_empresa'"
    echo "El parámetro -e 'nombre_empresa' es opcional. En caso de no enviarlo, el script aplicará para cada una de las empresas"
    echo "Los parámetros -f 'path_de_los_archivos_de_log' -z 'path_del_directorio_donde_se_hara_el_Zip' son obligatorios"
    echo "El parámetro -f 'path_de_los_archivos_de_log' puede ser una ruta absoluta o relativa"
    echo "El parámetro -z 'path_del_directorio_donde_se_hara_el_Zip' solo puede ser una ruta absoluta"
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

#Funcion que me hace salir del script si la ruta donde se hara el Zip no es válida
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

#valido que las letras sean correctas que pase como parámetro sean correctas
if [ $1 != "-f" ]; then
    echo "El primer parámetro debe ser '-f'"
    exit 100
fi

if [ $3 != "-z" ]; then
    echo "El tercer parámetro debe ser '-z'"
    exit 300
fi

if [ $# -eq 6 ]; then
    if [ $5 != "-e" ]; then
        echo "El quinto parámetro (si decide incluirlo) debe ser '-e'"
        exit 500
    fi
fi

#valido que la ruta donde están los archivos de log sea un directorio valido
if [ ! -d "$2" ] 
then
	salir2
fi

#valido que la ruta donde están los archivos de log contenga archivos
dato=$(ls -1 "$2" | wc -l)

if [ "$dato" -eq 0 ] 
then
	salir3
fi

#valido que la ruta donde se hará el zip sea un directorio valida
if [ ! -d "$4" ] 
then
	salir25
fi

#me muevo a la ruta donde se encuentran los archivos de Log. Y después guardo la ruta (PWD) en una variable
#si tengo rutas relativas, esto me será util. Si la ruta es absoluta, no hay diferencia
cd "$2"
origen=$PWD

#Me muevo al directorio sobre el que quiero trabajar
cd "$origen"

#Lo que tengo que revisar es si me pasaron 4 parámetros. 
#Si esto es verdad, tengo que aplicar el procedimiento a todas las empresas que tengan archivos de log
if [ $# -eq 4 ]; then
    archivos=$( find -maxdepth 1 -name "*.log") #extraigo todos los archivos que tengan el sufijo .log, y solo del directorio actual
fi

#declaro un array asociativo para ir guardando los nombres de las empresas que tienen archivos de log en el directorio
declare -A nombreEmpresas
#uso esta variable para ir llenando mi array asociativo
repetidos=0

for f in $archivos
    do
        seRepitio=1 #usaré esta bandera para saber si tengo que agregar el nombre de una empresa al array asociativo
        nuevoNombre=`echo $f | sed "s/log//" | tr -d '[0-9],-'./`  #con el comando sed elimino el 'log' de la extención. con el comando tr elimino los caracteres como guiones, comas o numeros
        for a in ${nombreEmpresas[@]}   #recorro el array asociativo para ir llenandolo con los nombres de las empresas
        do
            if [ "$a" == "$nuevoNombre" ]; then #si esta condiciòn se cumple, el nombre de la empresa ya está en el array
                seRepitio=0
            fi
        done 
        if [ $seRepitio -eq 1 ]; then   #si esta condiciòn se cumple, el nombre de la empresa no está en el array, así que lo guardaré
            nombreEmpresas[$repetidos]+=$nuevoNombre    #guardo el nombre de la empresa en una posiciòn del array
            let "repetidos++"   #incremento la variable repetidos para no pisar el nombre que guardé
        fi
    done

#recorro el array asociativo con el nombre de todas las empresas que tienen un archivo de log
for f in ${nombreEmpresas[@]}
do
    cd "$origen"    #me muevo al directorio origen para no tener problemas 
    empresa=$f      #iré guardando el nombre de cada empresa que esté en el array para trabajarlo
    archivos=$( find -maxdepth 1 -name "$empresa-[0-9]*.log")       #me quedo con los archivos de log de esa empresa
    contador=0  #contador para saber cuantos archivos tengo. lo necesitaré para validad datos más adelante
    for i in $archivos  #cuento los archivos
    do
        let "contador++"    #incremento la variable contador
    done
    if [ $contador -ne 1 -a $contador -ne 0 ]; then #si esta condiciòn se cumple, tengo que guardar como mìnimo un archivo en el .zip

        mayor=0     #uso esta bandera para saber cuál es el número de mayor tamaño
        for f in $archivos  #recorro los archivos y me iré quedando con los números. así sabré cual es el mayor
        do
            nuevoNombre=`echo $f | tr -d '[a-z],-'./`   #extraigo el número del nombre del archivo. Si el archivo se llama 'personal-4.log', me quedo con el 4
            if [ $mayor -lt $nuevoNombre ]; then    #si esta condiciòn se cumple, guardo el número que extraje como el mayor
                mayor=$nuevoNombre
            fi
        done

        comparacion="./$empresa-$mayor.log" #nombre del último archivo de log. lo usaré para comparar
        cd "$origen"   #me muevo al directorio donde están los archivos de Log. Así no tendré problemas
        for a in $archivos
        do
            if [ $a != $comparacion ]; then #me fijo si un archivo tiene nombre distinto al archivo que se va a quedar en la carpeta
                zip -m ""$4"/$empresa" $a #si se cumple la condición, lo agrego al archivo zip
            fi
        done

    else
        if [ $contador -eq 0 ]; then    #si se cumple esta condiciòn, la empresa no tiene archivos de log en el directorio. 
            echo "La empresa $empresa no tiene archivos de Log en el directorio"
        fi
        if [ $contador -eq 1 ]; then    #si se cumple esta condiciòn, la empresa solo tiene un archivo de log en el directorio.
            echo "La empresa $empresa solo tiene un archivo de Log en el directorio. No es necesario comprimir"
        fi
    fi
done

#Si tengo 6 parámetros, quiere decir que me pasaron el nombre de una empresa. Tendré que trabajar con esos archivos y puedo ignorar los demás
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
    cd "$origen"   #me muevo al directorio donde están los archivos de Log. Así no tendré problemas
    for a in $archivos
    do
        if [ $a != $comparacion ]; then #me fijo si un archivo tiene nombre distinto al archivo que se va a quedar en la carpeta
            zip -m ""$4"/$empresa" $a #si se cumple la condición, lo agrego al archivo zip
        fi
    done
fi