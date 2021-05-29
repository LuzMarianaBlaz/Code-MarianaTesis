include("objetos.jl")

# Ejemplo de función speed
function max_speed(u::Int,
    position_array::Array{Array{Float64,1},1}=[[0.,0.]])
    x_array = [first(element) for element in position_array]
if position_array[u][1] < maximum(x_array)/2.
    return 15 #m/s
else
    return 8 #m/s
end
end

function max_speed(u::Int,v::Int, 
    position_array::Array{Array{Float64,1},1})
return (max_speed(u, position_array)+max_speed(v,position_array))/2
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
    t = tmin_ij *(1+α*(f_ij / p_ij)^β)
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