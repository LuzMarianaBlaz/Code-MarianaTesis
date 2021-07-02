include("objetos.jl")

# Ejemplo de función speed
function max_speed(u::Int,
    position_array::Array{Array{Float64,1},1}=[[0.,0.]])
    x_array = [first(element) for element in position_array]
if position_array[u][1] < maximum(x_array)/2.
    return 15. #m/s
else
    return 8. #m/s
end
end

function max_speed(u::Int,v::Int, 
    position_array::Array{Array{Float64,1},1})
return (max_speed(u, position_array)+max_speed(v,position_array))/2.
end

function speed(u::Int, 
    position_array::Array{Array{Float64,1},1},
    speed_memory::Dict{Int,Float64}=Dict{Int,Float64}())
return get(speed_memory, u, max_speed(u, position_array))
end

function speed(u::Int,v::Int, 
    position_array::Array{Array{Float64,1},1},
    speed_memory::Dict{Int,Float64}=Dict{Int,Float64}())
return (speed(u, position_array, speed_memory)+speed(v,position_array,speed_memory))/2
end

function update_Astarpath(Auto::auto, Red::network)
    Auto.astarpath = LightGraphs.a_star(Red.digraph,
        Auto.o, Auto.d,Red.city_matrix[:,:,1],
        n -> MemoryHeuristic(n, Auto.d, Red.position_array,
            Auto.h,Auto.speed_memory))
end

function BPR(tmin_ij::Float64, f_ij::Float64 ,p_ij::Float64, α::Float64 = 0.2, β::Float64 = 10.) 
    t = tmin_ij *(1.0+α*(f_ij / p_ij)^β)
    return t
end

function sig_ts(tiempo_universal::Float64, Red::network, Autos::Array{auto,1})
    
    Autos = [auto for auto in Autos if !(auto.is_out)]
    p=sortperm([auto.ts for auto in Autos])
    Autos = Autos[p]

    if length(Autos) > 0
        u = Autos[1].o
        v = dst(Autos[1].astarpath[1])
        #si la calle a la que debe salir tiene espacio:
        if Red.city_matrix[u,v,3] < Red.city_matrix[u,v,2] 
            sts = Autos[1].ts-tiempo_universal
            car = Autos[1]
        else 
            for auto in Autos 
                if auto.o == u & v == dst(auto.astarpath[1])
                    auto.ts = auto.ts + 10.
                end
            end
                    
            p=sortperm([auto.ts for auto in Autos])
            Autos = Autos[p]
            if Autos != Autos[p]
                sts, car = sig_ts(tiempo_universal, Red, Autos)
            else
                sts=Inf
                car = nothing 
            end
        end
    else
        sts = Inf
        car = nothing
    end
    return sts, car
end

function sig_ca(Red::network, Autos::Array{auto,1})
    Autos = [auto for auto in Autos if (auto.is_out && auto.llego==0.)]
    sca = Inf
    car = nothing
                
    for auto in Autos  
        ## debe comprobar primero si puede hacer el cambio
        u = auto.last_node
        index = findall(x->src(x)==u, auto.astarpath)    
        v = dst(auto.astarpath[index][1])
        
        if Red.city_matrix[u,v,3] < Red.city_matrix[u,v,2]

            tiempo = Red.city_matrix[u,v,4]
            longitud = norm(Red.position_array[u]-Red.position_array[v])
            auto.vel = longitud/tiempo
        
            if tiempo * (longitud - auto.avance)/longitud < sca
                sca = tiempo * (longitud - auto.avance)/longitud
                car = auto
            end
        end
    end
    return sca, car
end 

function which_different(A,B)
    findall(x->x==1, A .!= B)
end

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


function simulacion!(tiempo_universal::Float64, Red::network, Autos::Array{auto,1},animacion=false)
    if animacion
        time_array = []
        m = size(Red.city_matrix,1)
        vel_matrix = zeros(m,m)
    end
    while (length([auto for auto in Autos if auto.llego!=0.]) < length(Autos))
                            sts, car_sale = sig_ts(tiempo_universal, Red, Autos)
                            sca, car_cambia = sig_ca(Red, Autos)
                            siguiente_tiempo = min(sts, sca)
                            tiempo_universal += siguiente_tiempo
                            if animacion
                                push!(time_array, tiempo_universal)
                            end
                            #print(stderr, tiempo_universal,"\n")
                            if sts < sca
                                #print(stderr, "sale un auto de ", car_sale.o, "\n")
                                car_sale.is_out = true
                                u = car_sale.o
                                v = dst(car_sale.astarpath[1])
                                Red.city_matrix[u,v,3] += 1.
                            else
                                u = car_cambia.last_node
                                car_cambia.speed_memory[u] = car_cambia.vel

                                index1 = findall(x->src(x)==u, car_cambia.astarpath)    
                                v = dst(car_cambia.astarpath[index1][1])
                                #print(stderr,"cambio en la esquina ",v,"\n")
                                Red.city_matrix[u,v,3] -= 1.
                        
                                car_cambia.last_node = v
                                if v == car_cambia.d
                                    #print(stderr, "llegué","\n")
                                    car_cambia.llego = tiempo_universal
                                    if animacion
                                        save_position(car_cambia,Red,Red.position_array[car_cambia.d])
                                    end
                                else
                                    u = v
                                    index2 = findall(x->src(x)==u, car_cambia.astarpath)    
                                    v = dst(car_cambia.astarpath[index2][1])
                                    car_cambia.next_node = v
                                    Red.city_matrix[u,v,3] += 1.      
                                end
                            end
        
                            for auto in [auto for auto in Autos if (auto.is_out && auto.llego==0.)]
                                auto.avance += auto.vel * siguiente_tiempo

                                if sca<sts && auto==car_cambia
                                    auto.avance = 0.
                                end
                                if animacion
                                    u = auto.last_node
                                    v = auto.next_node

                                    save_position(auto,Red,
                                    Red.position_array[u]+auto.avance*(Red.position_array[v]-Red.position_array[u])/norm(Red.position_array[v]-Red.position_array[u]))

                                end
                            end

                            if animacion
                                for auto in [auto for auto in Autos if !(auto.is_out)]
                                    save_position(auto,Red,[NaN,NaN])
                                end
                                vel_matrix += Red.city_matrix[:,:,4]
                            end
                            
                            Red.city_matrix[:,:,4] = BPR.(Red.city_matrix[:,:,1], Red.city_matrix[:,:,3],Red.city_matrix[:,:,2]);
                        end
                        if animacion
                            return time_array, vel_matrix/(length(time_array)-1)
                        end
                    end
        
     
                    
                    
function restart(Autos, Red)
    for auto in Autos
        auto.avance = 0.
        auto.vel = 0.
        auto.is_out = false
        auto.llego = 0.
        auto.last_node = auto.o
        auto.astarpath = update_Astarpath(auto, Red)
        auto.next_node = dst(auto.astarpath[1])
        auto.posicion = [Red.position_array[auto.o]]
    end
end