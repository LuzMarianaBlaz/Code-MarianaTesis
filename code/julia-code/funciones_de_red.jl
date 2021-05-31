using DataStructures
using GraphPlot
using LightGraphs
using LinearAlgebra

function distance_matrix(x)
    return [norm(x[i]-x[j]) for i in 1:length(x), j in 1:length(x)]
end


function mySimpleGraph(n::Integer)
    red = SimpleDiGraph(n,round(Int,n*(n-1)/20))
    position_array = [rand(2)*100. for i in 1:n]
    return red, position_array, distance_matrix(position_array)
end


function SquareDiGraph(n::Integer)
    red = SimpleDiGraph(n^2)
    
    for i in 1:n^2
        i_neighboors = []
        if i > n
            push!(i_neighboors, i-n)
        end
        if i ≤ n*(n-1)
            push!(i_neighboors, i+n)
        end
        if i%n != 1
            push!(i_neighboors, i-1)
        end
        if i%n != 0
            push!(i_neighboors, i+1)
        end
        for neighboor in i_neighboors
            add_edge!(red, i, neighboor)
        end
    end
    position_array = [[(i-1)%n, div(i-.01,n)] for i in 1:n^2]*100. #las calles miden 100m;
    return red, position_array, distance_matrix(position_array)
end


function divide_edge!(edge, digraph, position_array)
    u = src(edge)
    v = dst(edge)
   
    km1_pos = position_array[u] + (position_array[v] - position_array[u]).*0.05
    k_pos = position_array[u] + (position_array[v] - position_array[u]).*0.95

    push!(position_array,km1_pos,k_pos)    
    add_vertices!(digraph, 2)
    k = nv(digraph)
    
    add_edge!(digraph, u, k-1)
    add_edge!(digraph, k-1, k)
    add_edge!(digraph, k, v)
    rem_edge!(digraph, edge)
end

function make_slow_corners(red,position_array,dist_matrix)
    for element in collect(edges(red))
        divide_edge!(element, red, position_array)
    end
    return red, position_array, distance_matrix(position_array)
end

function EuclideanHeuristic(i::Integer, j::Integer,
    position_array::Array{Array{Float64,1},1})::Float64
    return norm(position_array[i]-position_array[j])
end

function TimeEuclideanHeuristic(i::Integer, j::Integer,
    position_array::Array{Array{Float64,1},1})::Float64
    vel = speed(i,j,position_array)
    return norm(position_array[i]-position_array[j])/vel
end

function MemoryHeuristic(i::Int64, j::Int64,
    position_array::Array{Array{Float64,1},1},h::Float64,
    speed_memory::Dict{Int,Float64}=Dict{Int,Float64})::Float64
    
distance = norm(position_array[i]-position_array[j])
estimation_part = distance/max_speed(i,j,position_array)
memory_part = distance/speed(i,j,position_array,speed_memory)

return (1-h)*estimation_part + h*memory_part
end