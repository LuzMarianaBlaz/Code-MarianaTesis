mutable struct network
    digraph::SimpleDiGraph{Int64}
    position_array::Array{Array{Float64,1},1}
    city_matrix::Array{Float64,3} 
    function network(digraph::SimpleDiGraph{Int64},
            position_array::Array{Array{Float64,1},1},
            city_matrix::Array{Float64,3})
        new(digraph,position_array,city_matrix)
    end
end

mutable struct auto
    #origen, destino y tiempo de salida
    o::Int64
    d::Int64
    ts::Float64

    #constante h 
    h::Float64

    #memoria de las velocidades en los nodos
    speed_memory::Dict{Int64,Float64}

    #camino A*
    astarpath::Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}

    ##Información del nodo del que acaban de salir y el avance respecto a este
    last_node::Int64
    avance::Float64

    #si el auto ya salió o no
    is_out::Bool
    
    function auto(o::Int64, d::Int64, ts::Float64, h::Float64,Red::network)
        speed_memory = Dict{Int64, Float64}()
        Astarpath=LightGraphs.a_star(Red.digraph,
            o, d,red_cuadrada.city_matrix[:,:,3],n -> TimeEuclideanHeuristic(n,
                d,Red.position_array))
        last_node = o
        avance = 0.
        is_out = false
        new(o,d,ts,h,speed_memory,Astarpath,last_node,avance,is_out)
    end
end