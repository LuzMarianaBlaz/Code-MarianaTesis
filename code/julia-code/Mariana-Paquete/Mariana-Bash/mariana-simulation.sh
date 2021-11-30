#!/bin/bash

source varSim.sh
cd
HOME=$(pwd)
mkdir -p Mariana-Sim
cd Mariana-Simulaciones

BASE="$HOME/Mariana-Sim"
cd $BASE

## Hacer un ciclo para todos los tamaños de red y n_autos deseados
# En cada paso del ciclo acceder al tamaño y n_autos
# copiar el archivo de simulación
# cambiar los parametros del archivo
# 

let REDSIZE=$5
let CARNUMBER=$2000

mkdir -p ${REDSIZE}REDSIZE
cd ${REDSIZE}REDSIZE
mkdir -p ${CARNUMBER}
cd ${CARNUMBER}

if  [[ $D -eq 2 ]]
then
    if [[ $T -eq 1 ]]
    then 
        declare -a arrP=${arr2dt1[*]}
    elif [[ $T -eq 2 ]]
    then
        declare -a arrP=${arr2dt2[*]}
    elif [[ $T -gt 2 ]]
    then
        echo Solo se puede 1 o 2 radios
        exit
    fi
      
    mkdir -p T${T}-C${C}
    cd T${T}-C${C}
    
    direct="${BASE}/${D}D/${N}/T${T}-C${C}"
    declare -a datos="N${N}-${D}D-T${T}-C${C}"
    
elif [ $D -eq 3 ]
then
    let T=1
    declare -a arrP=${arr3d[*]}
    mkdir -p C$C
    cd C$C
    
    direct="${BASE}/${D}D/${N}/C$C"
    declare datos="N${N}-${D}D-C$C"
else 
    echo Se tiene que usar dimension 2 o 3
    exit
fi

declare grepkeyword="simulacion-${datos}"
nohup bash $HOME/Paquete/Bash/deamon-kill-reestart-psaux.sh $grepkeyword $direct $LTime &
cp $HOME/Paquete/simulacion.jl ${direct}/simulacion.jl

sed -i -e "/SIMULACION/s/^#//" simulacion.jl  

sed -i -e 's/TIPO/'$T'/'  simulacion.jl 
sed -i -e 's/DIMENSION/'$D'/'  simulacion.jl 
sed -i -e 's/YAMETE/'$C'/'  simulacion.jl 
sed -i -e 's/NUMERO/'${N}'/'  simulacion.jl

ready? () {
    awake=0
    while [[ $awake -eq 0 ]] ; do
        njobs=$(ps aux | grep $grepkeyword | wc -l)
        echo $njobs $Limite
        if  [[ $njobs -lt $Limite ]]
        then
            awake=1
        else 
            let contH++
            sleep 3600
        fi
    done
}

cont=0
contR=1
contH=0
echo "Empezando" > JobsQueue.log

StatusJobs() {
    {
      echo ${cont} programas.
      echo ${contR} repeticion.
      echo ${contH} horas.
      echo ${C} crecimiento.
      echo ${i} phi.
    } >StatusJobs.log
}

trap JobsQueue SIGTERM EXIT SIGINT
JobsQueue() {
    {
    echo "Son $cont programas ejecutados";
    echo "Doing stuff for ${contH} horas "
    } >> JobsQueue.log
    exit
}

while [[ $contR -le $Repetir ]] ; do
    for i in ${arrP[@]} #arr2dt1 arr2dt2 arr2dt2p
       do
          cd ${direct}
          for k in simulacion.jl ##el archivo base
          do
             sed 's/NANI/'${i}'/'  simulacion.jl >>  simulacion-${datos}-phi${i}.jl 
             mkdir -p ${i}
             mv ${direct}/simulacion-${datos}-phi${i}.jl ${direct}/${i}/simulacion-${datos}-phi${i}.jl
          done

          Rep=1
          VAR=0
          while [ "$VAR" -eq 0 ]; do
              [[ ! -d "${direct}/${i}/${Rep}/" ]] || ((Rep++))
              [[ -d "${direct}/${i}/${Rep}/" ]] || VAR=1
          done

          cd ${direct}/${i}
          mkdir ${Rep}
          cp simulacion-${datos}-phi${i}.jl ${Rep}/simulacion-${datos}-phi${i}-R${Rep}.jl

          export BASEDIR=${direct}/${i}/${Rep}
          cd $BASEDIR
          echo "simulacion-${datos}-phi${i}-R${Rep}.jl"
          ready?
          nohup $HOME/bin/julia/julia simulacion-${datos}-phi${i}-R${Rep}.jl | tee output.log &
          ((cont++))
          cd $direct
          StatusJobs 
    done
    let contR++
done

exit