#!/bin/bash

source mariana-iterators.sh
cd
HOME=$(pwd)
cd Documents/Code-MarianaTesis/code/julia-code/
mkdir -p Mariana-Sim
cd Mariana-Sim

BASE="$HOME/Documents/Code-MarianaTesis/code/julia-code/Mariana-Sim"
cd $BASE

## Hacer un ciclo para todos los tamaños de red y n_autos deseados
for tamano_red in ${redsizes}
    do 
        mkdir 'redsize'${tamano_red}
        cd redsize${tamano_red}

        for n_cars in ${autosnums}
            do
                mkdir 'nautos'${n_cars}
                cd nautos${n_cars}
                # copiar el archivo de simulación
                cp $HOME/Documents/Code-MarianaTesis/code/julia-code/Mariana-Paquete/mariana-simulation.jl ./mariana-simulation-${tamano_red}-${n_cars}.jl
                # cambiar los parametros del archivo
                sed -i -e 's/TAMANORED/'$tamano_red'/'  mariana-simulation-${tamano_red}-${n_cars}.jl 
                sed -i -e 's/NCARS/'$n_cars'/'  mariana-simulation-${tamano_red}-${n_cars}.jl
                # correr el archivo y guardar el log
                for repetition in {0..3}
                do
                    sed -i -e 's/OUTFILEMARIANA/"out'$repetition'.csv"/'  mariana-simulation-${tamano_red}-${n_cars}.jl 
                    #nohup $HOME/bin/julia/julia mariana-simulation-${tamano_red}-${n_cars}.jl | tee output-$repetition.log 
                    nohup /Applications/Julia-1.5.app/Contents/Resources/julia/bin/julia mariana-simulation-${tamano_red}-${n_cars}.jl | tee output-$repetition.log 
                    sed -i -e 's/"out'$repetition'.csv"/OUTFILEMARIANA/'  mariana-simulation-${tamano_red}-${n_cars}.jl 

                done
                cd ..
            done
        cd ..
    done