mutable struct network
    digraph::SimpleDiGraph{Int64}
    position_array::Array{Array{Float64,1},1}
    time_matrix::Array{Float64,2}
    function network(digraph::SimpleDiGraph{Int64},
            position_array::Array{Array{Float64,1},1},
            weight_matrix::Array{Float64,2})
        new(digraph,position_array,weight_matrix)
    end
end

mutable struct auto
    #origen, destino y tiempo de salida
    o::Int64
    d::Int64
    ts::Float64

    #constante h 
    h::Float64

    #Red
    red::network

    #memoria de las velocidades en los nodos
    speed_memory::Dict{Int64,Float64}

    #camino A*
    astarpath::Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}

    ##Información del nodo del que acaban de salir y el avance respecto a este
    last_node::Int64
    avance::Float64
    
    function auto(o::Int64, d::Int64, ts::Float64, h::Float64,Red::network)
        speed_memory = Dict{Int64, Float64}()
        Astarpath=LightGraphs.a_star(Red.digraph,
            o, d,Red.time_matrix,n -> TimeEuclideanHeuristic(n,
                d,Red.position_array))
        last_node = o
        avance = 0.
        new(o,d,ts,h,Red,speed_memory,Astarpath,last_node,avance)
    end
end