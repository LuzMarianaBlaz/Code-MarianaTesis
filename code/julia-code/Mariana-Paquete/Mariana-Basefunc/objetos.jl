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
    speed_memories::Array{Dict{Int64, Float64},1}
    speed_memory::Dict{Int64,Float64}

    #camino A*
    astarpath::Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}

    ##Información del nodo del que acaban de salir y el avance respecto a este
    last_node::Int64
    next_node::Int64
    avance::Float64
    vel::Float64
    posicion::Array{Array{Float64,1},1}

    #si el auto ya salió o no
    is_out::Bool
    llego::Float64
    
    function auto(o::Int64, d::Int64, ts::Float64, h::Float64,Red::network)
        speed_memory = Dict{Int64, Float64}()
        speed_memories = [Dict{Int64, Float64}() for i in 1:7]
        Astarpath=LightGraphs.a_star(Red.digraph,
            o, d,Red.city_matrix[:,:,1],n -> TimeEuclideanHeuristic(n,
                d,Red.position_array))
        last_node = o
        next_node = dst(Astarpath[1])
        avance = 0.
        vel = 0.
        posicion=[Red.position_array[o]]
        is_out = false
        llego = 0.
        new(o,d,ts,h,speed_memories,speed_memory,Astarpath,last_node,next_node,avance,vel,posicion,is_out,llego)
    end
end

function generate_auto(m,tamano_red,t,red, h_distribution)
    o = 1
    d = 1
    while LightGraphs.dijkstra_shortest_paths(red.digraph,o).dists[d] < min(10, tamano_red)
        o = rand(1:m)
        d = rand(1:m)
    end
    h = rand(h_distribution) #h es la porporción que corresponde a la memoria
    return auto(o,d,t,h,red)
end

function generate_autos(m, tamano_red, red, n_cars, ti, tf, h_dist)
    step = (tf-ti)/(n_cars-1)
    autos = [generate_auto(m,tamano_red, t,red, h_dist) for t in collect(ti:step:tf)]
    return autos
end