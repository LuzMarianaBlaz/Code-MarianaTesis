include("objetos.jl")
include("funciones_de_red.jl")

"""
    max_speed(u, position_array)
Returns the maximum speed in a given vertex ``u```.
"""
function max_speed(u::Int,
    position_array::Array{Array{Float64,1},1}=[[0.,0.]])
    x_array = [first(element) for element in position_array]
    if position_array[u][1] < maximum(x_array)/2.
        return 15. #m/s
    else
        return 8. #m/s
    end
end


"""
    max_speed(u, v, position_array)
Returns the maximum speed in the edge ``uv``.
"""
function max_speed(u::Int,v::Int, 
    position_array::Array{Array{Float64,1},1})
    return (max_speed(u, position_array)+max_speed(v,position_array))/2.
end


"""
    speed(u, position_array, speed_memory)
Returns the estimated speed in vertex ``v`` for a driver given its `speed_memory`,
if there is not previous experience of the driver in such vertex, then it returns
the maximum speed reported for that vertex according to `max_speed`.
"""
function speed(u::Int, 
    position_array::Array{Array{Float64,1},1},
    speed_memory=Dict{Int64,Float64}())
    return get(speed_memory, u, max_speed(u, position_array))
end


"""
    speed(u, v, position_array, speed_memory)
Returns the estimated between nodes ``u`` and ``v`` for a driver given its `speed_memory`,
if there is not previous experience of the driver in such vertices, then it returns
the maximum speed reported between those nodes according to `max_speed`.
"""
function speed(u::Int,v::Int, 
    position_array::Array{Array{Float64,1},1},
    speed_memory=Dict{Int64,Float64}())
    return (speed(u, position_array, speed_memory)+speed(v,position_array,speed_memory))/2
end


function modify_vels(Auto::auto, Red::network)
    m,k,l = size(Red.city_matrix)
    mean_speed_memory = mean_vel_from_memories(Auto.speed_memories)
    return([speed(i,j,Red.position_array, mean_speed_memory) for i in 1:m, j in 1:m])
end

"""
    update_Astarpath(auto, red)
Updates the A* path for a driver (auto) in the network (red), taking into account
the new information the driver has stored in its `speed_memory`. 
"""
function update_Astarpath(Auto::auto, Red::network)
    memory_weight_matrix = distance_matrix(Red.position_array)./modify_vels(Auto, Red)
    estimated_weight_matrix = Red.city_matrix[:,:,1]
    weight_matrix = (1-Auto.h)*estimated_weight_matrix + Auto.h*memory_weight_matrix
    mean_speed_memory = mean_vel_from_memories(Auto.speed_memories)
    
    return (LightGraphs.a_star(Red.digraph,
    Auto.o, Auto.d,weight_matrix, n -> MemoryHeuristic(n, Auto.d, Red.position_array,
    Auto.h,mean_speed_memory)))
end


"""
    BPR(tmin_ij, f_ij, p_ij, α, β)
Returns the modified time in edge ``ij``, given the flux ``f_{ij}`` and capacity ``p_{ij}`` in
that edge. Following the formula:
``t = tmin_{ij} *(1.0+α*(f_{ij} / p_{ij})^β)``

Default values: α=0.2, β=10.
"""
function BPR(tmin_ij::Float64, f_ij::Float64 ,p_ij::Float64, α::Float64 = 0.2, β::Float64 = 10.) 
    t = tmin_ij *(1.0+α*(f_ij / p_ij)^β)
    return t
end


"""
    sig_ts(tiempo_universal, red, autos)
Calculates in how much time (with respect to `tiempo universal`) is the next departure for a car in 
the `autos` array, in the network `red`, returns that next time step and which car is the one to depart.

A departure only occurs if there is space in the street the driver wants to go. If no car can depart (or all of
them are alreay on route) the function returns infinite as next time step and `nothing` as the next car to depart.
"""
function sig_ts(tiempo_universal::Float64, Red::network, Autos::Array{auto,1})
    # Construimos el arreglo de los autos que no han salido y los ordenamos según tiempo de salida
    Estacionados = [auto for auto in Autos if !(auto.is_out)]
    p=sortperm([auto.ts for auto in Estacionados])
    Estacionados = Estacionados[p]
    for i in 1:length(Estacionados)
            u = Estacionados[i].o
            v = dst(Estacionados[i].astarpath[1])
        #si la calle a la que debe salir tiene espacio:
            if Red.city_matrix[u,v,3] + 1 <= Red.city_matrix[u,v,2]
                # Regresamos el siguiente auto que puede salir y su tiempo de salida 
                sts = Estacionados[i].ts-tiempo_universal
                car = Estacionados[i]
                return sts, car
            else
                Estacionados[i].ts += 0.5 + 0.5 * rand()
            end
    end

    sts = Inf
    car = nothing
    return sts, car
end

"""
    sig_ca(red, autos)
Calculates in how much time (with respect to `tiempo universal`) is the next change of edge for a car in 
the `autos` array, in the network `red`, returns that next time step and which car is the one to change edge.

A change of edge only occurs if there is space in the street the driver wants to go. If no car can change edges 
    the function returns infinite as next time step and `nothing` as the next car to depart.
"""
function sig_ca(Red::network, Autos::Array{auto,1})
    # Se construye un arreglo de los autos que están afuera
    Afuera = [auto for auto in Autos if (auto.is_out && auto.llego==0.)]
    sca = Inf
    car = nothing
                
    for auto in Afuera  
        # Revisa si ya va a alcanzar su nodo destino
        u = auto.last_node
        v = auto.next_node
        index = findall(x->src(x)==v, auto.astarpath)
        # si ya lo va a alcanzar quiere decir que no necesita ver si hay espacio en la calle siguiente    
        if length(index) == 0 
            tiempo = Red.city_matrix[u,v,4]
            longitud = norm(Red.position_array[u]-Red.position_array[v])
            auto.vel = longitud/tiempo
            # Se guarda en sca el siguiente tiempo en el que ocurrirá un cambio,
            # si se encuentra un tiempo menor se sustituye el valor de sca
            if tiempo * (longitud - auto.avance)/longitud < sca
                sca = tiempo * (longitud - auto.avance)/longitud
                car = auto
            end
        else
            # si aún no va a alcanzar su destino tiene que comprobar que en la siguiente calle haya espacio
            w = dst(auto.astarpath[index][1])
            if Red.city_matrix[v,w,3] + 1 <= Red.city_matrix[v,w,2]
                # Si hay espacio calcula en cuánto tiempo cambiaría de arista, si es menor que sca, lo sustituye
                tiempo = Red.city_matrix[u,v,4]
                longitud = norm(Red.position_array[u]-Red.position_array[v])
                auto.vel = longitud/tiempo
            
                if tiempo * (longitud - auto.avance)/longitud < sca
                    sca = tiempo * (longitud - auto.avance)/longitud
                    car = auto
                end
            end
        end
    end
    return max(sca,0.0), car
end 


"""
    which_different(A,B)
Find the indexes of the entries in arrays A, B that are different.
"""
function which_different(A,B)
    findall(x->x==1, A .!= B)
end


"""
    save_position(car, red, posicion)
saves the posicion of car in a network `red` in a given moment, in the array `posicion`.
"""
function save_position(car, Red, posicion)
    u = car.last_node
    v = car.next_node

    pos_u = deepcopy(Red.position_array[u])
    pos_v = deepcopy(Red.position_array[v])

    difcord = which_different(pos_u,pos_v)
    if length(difcord) < 1
        push!(car.posicion,posicion)
        return
    end

    if difcord[1] == 1
        if pos_u[1] < pos_v[1]
            posicion[2] -= 2. 
            posicion[2] -= 2.
        else
            posicion[2] += 2. 
            posicion[2] += 2.
        end
    end

    if difcord[1] == 2
        if pos_u[2] < pos_v[2]
            posicion[1] -= 2. 
            posicion[1] -= 2.
        else
            posicion[1] += 2. 
            posicion[1] += 2.
        end
    end

    push!(car.posicion,posicion)
end


"""
    simulacion!(tiempo_universal, red, autos)
Given the network `red` and an array of drivers `autos`, generates the complete simulation until all drivers reach their destination,
the simulation goes in discrete steps of time, each one representing an action. Possible actions are:
- A car leaves its origin.
- A car changes edge.
- A car reaches its destination. 
"""
function simulacion!(tiempo_universal::Float64, Red::network, Autos::Array{auto,1})
    time_array = []
    m = size(Red.city_matrix,1)
    vel_matrix = zeros(m,m)

    # Mientras haya autos que no hayan llegado a su destino
    while (length([auto for auto in Autos if auto.llego!=0.]) < length(Autos))
        # Se calculan el siguiente cambio de arista y el siguiente tiempo de salida
        sts, car_sale = sig_ts(tiempo_universal, Red, Autos)
        sca, car_cambia = sig_ca(Red, Autos)
        siguiente_tiempo = min(sts, sca)

        # si lo que sigue es una salida de destino
        if sts < sca 
            # el tiempo universal se adelanta por siguiente_tiempo
            tiempo_universal += siguiente_tiempo
            push!(time_array, tiempo_universal)

            # se cambia el estado del auto que sale a is_out = true
            car_sale.is_out = true
            u = car_sale.o
            v = dst(car_sale.astarpath[1])
            # se aumenta en 1 al numero de autos de la arista de la que salió
            Red.city_matrix[u,v,3] += 1.

        # si lo que sigue es un cambio de arista
        elseif sca <= sts && (sca != Inf)
            # el tiempo universal se adelanta por siguiente_tiempo
            tiempo_universal += siguiente_tiempo
            push!(time_array, tiempo_universal)

            u = car_cambia.last_node
            car_cambia.speed_memory[u] = car_cambia.vel
            index1 = findall(x->src(x)==u, car_cambia.astarpath)    
            v = dst(car_cambia.astarpath[index1][1])
            # se resta un auto del número de autos de la arista que deja
            Red.city_matrix[u,v,3] -= 1.
            # se actualiza el último nodo por el que pasó el auto
            car_cambia.last_node = v
            # si con esta acción el auto llega a destino se registra el tiempo en el que llegó
            if v == car_cambia.d
                car_cambia.llego = tiempo_universal
                save_position(car_cambia,Red,Red.position_array[car_cambia.d])
            # si no ha llegado y cambia de arista se amenta el uno el número de autos a la arista a la que va
            else
                index2 = findall(x->src(x)==v, car_cambia.astarpath)    
                w = dst(car_cambia.astarpath[index2][1])
                car_cambia.next_node = w
                Red.city_matrix[v,w,3] += 1.      
            end
        else
            print("Red atascada","\n")
            print("con ", sum(Red.city_matrix[:,:,3]), " autos en ruta","\n")
            break
        end
        
        # para todos los autos que están en ruta
        for auto in [auto for auto in Autos if (auto.is_out && auto.llego==0.)]
            # el avance de los autos es su velocidad por el pedazo de tiempo que avanza la simulación
            auto.avance += auto.vel * siguiente_tiempo
            # excepto para el auto que cambió, o para autos que no pueden cambiar de arista
            # a ellos les pondremos otros avances.

            if (sca<=sts && auto==car_cambia)
                # al auto que cambió le ponemos 0
                auto.avance = 0.0
            end

            longitud = norm(Red.position_array[auto.last_node]-Red.position_array[auto.next_node])
            if (auto.avance-longitud >= 0.0)
                # a los autos que no pueden avanzar les ponemos a que avancen hasta la esquina pero no más alla
                auto.avance == (longitud)*(0.9 + 0.9*rand())
            end
            
            u = auto.last_node
            v = auto.next_node
            save_position(auto,Red,
            Red.position_array[u]+auto.avance*(Red.position_array[v]-Red.position_array[u])/norm(Red.position_array[v]-Red.position_array[u]))
        end

        for auto in [auto for auto in Autos if !(auto.is_out)]
            save_position(auto,Red,[NaN,NaN])
        end
        dist_matrix = distance_matrix(Red.position_array)
        
        # por último se actualizan los tiempos de recorrido en la red
        Red.city_matrix[:,:,4] = BPR.(Red.city_matrix[:,:,1], Red.city_matrix[:,:,3],Red.city_matrix[:,:,2]);
        vel_matrix += dist_matrix./Red.city_matrix[:,:,4];
    end
    #print("\n tiempo final"*string(tiempo_universal))
    return time_array, vel_matrix/(length(time_array))
end
        
"""
    restart(Autos, Red)
This function restarts the newtork and the cars array to start a new simulation
"""                         
function restart(Autos, Red, tiempos_de_salida_snapshot)
    i = 0
    indexes=[]
    for auto in Autos
        i +=1
        auto.ts = tiempos_de_salida_snapshot[i]
        auto.avance = 0.
        auto.vel = 0.
        auto.is_out = false
        auto.llego = 0.
        auto.last_node = auto.o
        auto.speed_memories[2:7] = auto.speed_memories[1:6]
        auto.speed_memories[1] = auto.speed_memory
        old_astar = auto.astarpath
        auto.astarpath = update_Astarpath(auto, Red)
        if old_astar != auto.astarpath
            push!(indexes,i)
        end
        auto.next_node = dst(auto.astarpath[1])
        auto.posicion = [Red.position_array[auto.o]]
        
        auto.speed_memory = Dict{Int64, Float64}()
    end
    m,k,l = size(Red.city_matrix)
    Red.city_matrix[:,:,3] = zeros(m,m)
    Red.city_matrix[:,:,4] = BPR.(Red.city_matrix[:,:,1],
        Red.city_matrix[:,:,3],Red.city_matrix[:,:,2]);   
    return indexes
end

function vels_summary(autos)
    return [mean(values(auto.speed_memory)) for auto in autos]
end

function times_summary(autos)
    return [auto.llego-auto.ts for auto in autos]
end

function mean_vel_from_memories(speed_memories)
    key_arr = []
    for dict in speed_memories
        key_arr=union(key_arr,keys(dict))
    end

    new_dict = Dict() 
    for key in key_arr
        vals = zeros(7)
        count = 0
        for dict in speed_memories
            count += 1
            vals[count]=get(dict, key, 0)
        end
        n = length(findall(x->x!=0,vals))
        val = sum(vals)/n
        new_dict[key]=val
    end
    return new_dict
end