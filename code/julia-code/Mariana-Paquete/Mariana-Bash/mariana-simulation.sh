#!/bin/bash

source iterators.sh

HOMEM="/home/aramis/Mariana"
cd $HOMEM
mkdir -p Sim

BASE="${HOMEM}/Sim"
cd $BASE

declare -a arrR=${redsizes[*]}
declare -a arrA=${autosnums[*]}

## Hacer un ciclo para todos los tamaños de red y n_autos deseados
for tamano_red in ${arrR}
do 
    cd $BASE
    
    mkdir -p 'redsize'${tamano_red}
    cd redsize${tamano_red}
    
    for n_cars in ${arrA}
    do
        
        cd $BASE/redsize${tamano_red}/
        mkdir -p 'nautos'${n_cars}
        cd nautos${n_cars}
        
        # copiar el archivo de simulación
        cp ${HOMEM}/Paquete/mariana-simulation.jl mariana-simulation-RS${tamano_red}-N${n_cars}.jl
        
        # cambiar los parametros del archivo
        sed -i -e 's/TAMANORED/'$tamano_red'/'  mariana-simulation-RS${tamano_red}-N${n_cars}.jl 
        sed -i -e 's/NCARS/'$n_cars'/'  mariana-simulation-RS${tamano_red}-N${n_cars}.jl
        
        # correr el archivo y guardar el log
        for repetition in {1..10}
        do
            cd $BASE/redsize${tamano_red}/nautos${n_cars}/
            mkdir -p ${repetition}

            sed 's/OUTFILEMARIANA/'Datos-RS${tamano_red}-N${n_cars}-R${repetition}.csv'/'  mariana-simulation-RS${tamano_red}-N${n_cars}.jl >> mariana-simulation-RS${tamano_red}-N${n_cars}-R${repetition}.jl 
            mv mariana-simulation-RS${tamano_red}-N${n_cars}-R${repetition}.jl ${repetition}/

            export BASEDIR=${BASE}/redsize${tamano_red}/nautos${n_cars}/${repetition}/
            cd $BASEDIR

            echo $(pwd) mariana-simulation-RS${tamano_red}-N${n_cars}-R${repetition}.jl 
            nohup /home/aramis/bin/julia/julia mariana-simulation-RS${tamano_red}-N${n_cars}-R${repetition}.jl | tee output.log &
        done
    done
done