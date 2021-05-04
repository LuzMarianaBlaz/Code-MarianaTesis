include("objetos.jl")

# Ejemplo de función speed
function max_speed(u::Int,
    position_array::Array{Array{Float64,1},1}=[[0.,0.]])
    x_array = [first(element) for element in position_array]
if position_array[u][1] < maximum(x_array)/2.
    return 50
else
    return 30
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

function BPR(tmin_ij::Float, f_ij::Float ,p_ij::Float, α::Float = 0.2, β::Float = 10.) 
    t = tmin_ij *(1+α*(f_ij / p_ij)^β)
    return t
end