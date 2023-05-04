#!/bin/bash
## WIP
source iterators-plotting.sh

HOMEM="/home/aramis/Mariana"
cd $HOMEM
mkdir -p Sim

BASE="${HOMEM}/Images/MemColectiva-VelHomogenea-Omniscientes/DivNte"
BASEREAD='"/home/aramis/Mariana/Sim/MemColectiva-VelHomogenea-Omniscientes/DivNte"'
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
        cp ${HOMEM}/Paquete/create-plots.jl create-plots-RS${tamano_red}-N${n_cars}.jl
        
        # cambiar los parametros del archivo
        sed -i -e 's/TAMANORED/'$tamano_red'/'  create-plots-RS${tamano_red}-N${n_cars}.jl 
        sed -i -e 's/NCARS/'$n_cars'/'  create-plots-RS${tamano_red}-N${n_cars}.jl
        sed -i -e 's,SIMPATH,'${BASEREAD}',' create-plots-RS${tamano_red}-N${n_cars}.jl
        
        echo $(pwd) create-plots-RS${tamano_red}-N${n_cars}.jl 
        nohup /home/aramis/bin/julia/julia create-plots-RS${tamano_red}-N${n_cars}.jl | tee output.log &
    done
done