mutable struct red
    n::Int32 #número de vértices
    m::Int64 #número de aristas
    vecinos::Array{Array{Int32,1},1} #estructura de red, quién está conectado con quién
    t_min::Array{Array{Float32,1},1} #los tiempos mínimos (a velocidad máxima) de la arista correspondiente
    distancias::Array{Array{Float32,1},1} # la longitud de calle de la arista correspondiente
    capacidad::Array{Array{Float32,1},1} #la capacidad de la arista correspondiente (el número de autos que caben)
    en_arista::Array{Array{Int16,1},1}#cuántos autos hay en cada arista
    
    function red(vecinos, t_min, dist, cap)
        n = length(vecinos)
        m = 0
        if n == length(t_min) && n == length(dist) && n == length(cap)
            
            for i in 1:n
                m += length(vecinos[i])       
            end
            en_arista = 0*deepcopy(vecinos)
                
            new(n, m, vecinos, t_min, dist, cap, en_arista)
            
        else
            error("Todas las características deben tener el mismo tamaño")
        end
        
    end
    
end

mutable struct autos
    
    N::Int32 ##Número de autos, del orden de 5 millones
    arista::Array{Int64,2}
    avance::Array{Float32,1} #Avance en la arista
    TS::Array{Float32,1} #Tiempos de salida
    PV::Array{Array{Int32,1},1} #Plan de viaje
    Vel::Array{Float32,1} #Velocidades
    TR::Array{Array{Array{Any,1},1},1} #Tiempos de recorrido
    p_final::Array{Int32,2}
    ruta_animacion::Array{Array{Int32,1}}
    t_propio::Array{Float32,1}
    sd::Array{Array{Array{Any,1},1},1} #desviación estándar del tiempo de ruta
    
    function autos(OD::Array{Int32,2},Red::red)
        #El avance y la velocidad para todos serán originalmente cero:
        N = length(OD[:,1])
        avance = zeros(N)
        Vel = zeros(N)
        TR = []
        sd = []
        PV = Planes_de_viaje(Red,OD)
        TS = sort!(rand(N)*1.)  #el 100 representa la longitud del intervalo en el cual todos saldrán (segundos)
        arista = zeros(N,2)
        p_final = zeros(N,2)
        ruta_animacion = []
        t_propio = zeros(N)

        #=La arista original para todos será [0,O], donde O es el vértice de origen,
        los tiempos de recorrido (TR) para cada auto será una lista de los tiempos de recorrido en cada arista,
        esto se obtiene a partir de Red=#
        
        for i in 1:N #reasignación de valores en vez de push
            o = OD[i,1]
            d = OD[i,2]
            arista[i,:] = [0,o]
            p_final[i,:] = [d,0]
            push!(TR,deepcopy(Red.t_min))
            push!(sd,deepcopy(Red.t_min)*0)
            push!(ruta_animacion,[])
        end
        new(N,arista,avance,TS,PV,Vel,TR,p_final,ruta_animacion,t_propio,sd)
    end
end