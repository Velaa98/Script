#!/bin/bash
#. errores 
#Incluimos el fichero que contiene las variables de error para poder llamarlas desde las funciones.

#Si no hay parámetros recorre el fichero help y lo muestra por pantalla.
function mostrar_ayuda {
	backIFS=$IFS	#Guardamos el valor de $IFS
	while IFS='' read -r linea || [[ -n "$linea" ]]; do
		printf "%s\n" "$linea"
	done < help
	IFS=$backIFS	#Devolvemos $IFS al valor original
}

#Comprobar que virtualbox está instalado 
function comprobar_instalacion_virtualbox {
	v_version=$(dpkg -S virtualbox | cut -d ":" -f 1 | sort | uniq)	#Averigua la versión de Virtualbox si está instalada

	if [ $v_version ]
	then
		if [ $v_version == 'virtualbox.*' ] # Si hay una versión de VirtualBox comprueba su estado
		then
			if `dpkg -s $v_version | egrep Status:` != "Status: install ok installed" # Si su estado no es instalado
			then
				preguntar_instalacion
			fi
		fi
	else
		echo "Error: No hay ninguna versión de VirtualBox"
		preguntar_instalacion
	fi
}

# Pregunta si quieres instalar VirtualBox-5.1
function preguntar_instalacion {
	# Mientras no responda o responda diferente a s/n	
	while [ ! $resp ] || ( [ $resp != n ] && [ $resp != s ] ) 
	do	
		read -p "¿Desea instalar el paquete Virtualbox-5.1 (s/n)? " resp		
	done
	if [ $resp == s ]
	then
		if $(lsb_release -a | egrep Codename:) != "Codename:       stretch"
		then
			wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
			wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
			echo "deb http://download.virtualbox.org/virtualbox/debian stretch contrib"
		fi
		apt-get update #&> /dev/null
		apt-get install -y --allow-unauthenticated virtualbox-5.1 #&> /dev/null
	else
		exit
	fi
}
