using DataStructures
using GraphPlot
using LightGraphs
using LinearAlgebra

street_len = 40.0

function distance_matrix(x)
    return [norm(x[i]-x[j]) for i in 1:length(x), j in 1:length(x)]
end


function mySimpleGraph(n::Integer)
    red = SimpleDiGraph(n,round(Int,n*(n-1)/20))
    position_array = [rand(2)*street_len for i in 1:n]
    return red, position_array, distance_matrix(position_array)
end


function SquareDiGraph(n::Integer; doble_sentido = false)
    red = SimpleDiGraph(n^2)
    if doble_sentido
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
    else
        set1 = vcat([i for i in 1:2:n], [i for i in n+1:2:2*n-1])
        if n%2!=0
            push!(set1,0)
        end        
        for i in 1:n^2
            i_neighboors = []
            if i > n && (i%(n*2) in set1)
                push!(i_neighboors, i-n)
            end
            if i ≤ n*(n-1) && !(i%(n*2) in set1)
                push!(i_neighboors, i+n)
            end
            if i%n != 1 && (i%(n*2) in 1:n)
                push!(i_neighboors, i-1)
            end
            if i%n != 0 && !(i%(n*2) in 1:n)
                push!(i_neighboors, i+1)
            end
            if i < n 
                push!(i_neighboors, i+1)
            end
            if i%n == 1
                push!(i_neighboors, i+n)
            end
            if i%n == 0
                objeto = (n%2==0 && i!=n) ? i-n : (n%2==1 && i!=n*n) ? i+n : 7
                if objeto != 7
                    push!(i_neighboors,objeto)
                end
            end
            for neighboor in i_neighboors
                add_edge!(red, i, neighboor)
            end
        end
    end

    position_array = [[(i-1)%n, div(i-0.01,n)] for i in 1:n^2]*street_len #las calles miden <street_len>m;
    return red, position_array, distance_matrix(position_array)
end

### To add diagonals ###
function horizontal_range(diag_start, ordenada, pendiente, sidenum, step = 100.)
    rang = []
    u = diag_start[2]

    while u >= 0. && ((u-ordenada)/pendiente) < (sidenum-1.)*street_len
        push!(rang,round.([(u-ordenada)/pendiente, u], digits=5))
        u -= step
    end
    return(rang)
end

function vertical_range(diag_start, ordenada, pendiente, sidenum, step = 100.)
    rang = []
    u = round(diag_start[1]/street_len, digits=0)+street_len

    while u <= (sidenum-1)*street_len
        push!(rang,[u,round(pendiente*u+ordenada,digits=5)])
        u += step
    end
    return(rang)
end

function paste_diagonal(nw, position_array, new_positions)
    original_number = nv(nw)
    
    for element in new_positions
        coord = findall(x -> x %street_len == 0., element)[1]
        val = element[coord]
        vertices = findall(x -> (x[coord] == val && norm(x[coord%2+1]-element[coord%2+1])<street_len), position_array)
        
        add_vertex!(nw)
        vertex_num = nv(nw)

        if has_edge(nw,vertices[1], vertices[2])
            add_edge!(nw,vertices[1],vertex_num)
            add_edge!(nw,vertex_num,vertices[2])
            rem_edge!(nw, vertices[1], vertices[2])
        end
        if has_edge(nw,vertices[2], vertices[1])
            add_edge!(nw,vertices[2],vertex_num)
            add_edge!(nw,vertex_num,vertices[1])
            rem_edge!(nw, vertices[2], vertices[1])
        end
        
        if vertex_num > original_number+1
            add_edge!(nw,vertex_num-1,vertex_num)
        end
        
        push!(position_array, element)
    end
    return nw, position_array, distance_matrix(position_array)
end

function add_diagonal!(nw, position_array,diag_start, pendiente, sidenum, step = 100.)
    ordenada = -diag_start[1]*pendiente + diag_start[2]
    hr = horizontal_range(diag_start, ordenada, pendiente, sidenum, step)
    vr = vertical_range(diag_start, ordenada, pendiente, sidenum, step)
    new_positions = sort(vcat(hr,vr), by = x -> x[1])
    nw, position_array, distm = paste_diagonal(nw, position_array, new_positions)
    return nw, position_array, distm, new_positions
end

### To make slow corners ###

function divide_edge!(edge, digraph, position_array)
    u = src(edge)
    v = dst(edge)
    vu_vec = position_array[u] - position_array[v]

    if norm(vu_vec) >= 10
        k_pos = round.(position_array[v] + (vu_vec).*5.0/norm(vu_vec), digits = 3)
        push!(position_array, k_pos)    
        add_vertex!(digraph)
        k = nv(digraph)
        add_edge!(digraph, u, k)
        add_edge!(digraph, k, v)
        rem_edge!(digraph, edge)
    end
end

function make_slow_corners(red,position_array,new_positions=[])
    if new_positions == []
        k = length(position_array)
    else
        k = length(position_array) - length(new_positions) +1 
    end
    position_array = [round.(piece,digits=3) for piece in position_array]
    for element in filter(x -> (src(x) < k || dst(x) < k),collect(edges(red)))
        divide_edge!(element, red, position_array)
    end
    return red, position_array, distance_matrix(position_array)
end

function EuclideanHeuristic(i::Integer, j::Integer,
    position_array::Array{Array{Float64,1},1})::Float64
    return norm(position_array[i]-position_array[j])
end


"""
    TimeEuclideanHeuristic(i, j, position_array)
A function that estimates the time from vertex ``i`` to vertex ``j``
if you were in a straight line path, at the maximum speed for those vertices.
"""
#### Heuristics to include in A* ###
function TimeEuclideanHeuristic(i::Integer, j::Integer,
    position_array::Array{Array{Float64,1},1})::Float64
    vel = max_speed(i,j,position_array)
    return norm(position_array[i]-position_array[j])/vel
end


"""
    MemoryHeuristic(i, j, position_array, h, )
A function that estimates the time from vertex ``i`` to vertex ``j``
if you were in a straight line path, calculated using the speed memory of a driver
the estimation is made using the formula ``(1-h)*estimated time + h*remembered time``.
"""
function MemoryHeuristic(i::Int64, j::Int64,
    position_array::Array{Array{Float64,1},1},h::Float64,
    speed_memory=Dict{Int,Float64})::Float64
    distance = norm(position_array[i]-position_array[j])
    estimation_part = distance/max_speed(i,j,position_array)
    memory_part = distance/speed(i,j,position_array,speed_memory)
    return (1-h)*estimation_part + h*memory_part
end

"""
    create_square_network(side_number, both_ways)
generates a complete network object, that contains a LightGraphs digraph, a position array
and a city matrix, a 3D object that contains information about:
- Minimum time to go trough each edge.
- Capacity of each edge.
- Number of cars in each one of the edges. It starts at cero.
- Real time to go trough each edge, following the BPR function. At the beginning is the 
    same as the minimum time.

The digraph created will be an square network with *side_number* of nodes in each side,
and will be slow in the corners.
You can choose if the streets are both-ways or not using the *both_ways* parameter
(default value: one way.)
"""
function create_square_network(side_number::Integer; both_ways=true)
    SquareNet, position_array, dist_matrix = SquareDiGraph(side_number, doble_sentido=both_ways);
    SquareNet, position_array, dist_matrix = make_slow_corners(SquareNet, position_array);
    
    m = nv(SquareNet);
    city_matrix = zeros(m,m,4);
    f = x -> [max_speed(i,j,x) for i in 1:length(x),j in 1:length(x)];
    city_matrix[:,:,1] = dist_matrix./f(position_array);
    city_matrix[:,:,2] = dist_matrix./5;
    city_matrix[:,:,4] = BPR.(city_matrix[:,:,1], city_matrix[:,:,3],city_matrix[:,:,2]);
    red_cuadrada=network(SquareNet,position_array,city_matrix);
    return red_cuadrada
end


function create_square_network_with_diagonal(side_number::Integer, diagonal_start, diagonal_slope; both_ways=true)
    SquareNet, position_array, dist_matrix = SquareDiGraph(side_number, doble_sentido=both_ways);
    nw, posarr, distm, new_positions = add_diagonal!(SquareNet, position_array, diag_start, diagonal_slope, side_number,40.);
    SquareNet, position_array, dist_matrix = make_slow_corners(nw, posarr, new_positions);
    
    m = nv(SquareNet);
    city_matrix = zeros(m,m,4);
    f = x -> [max_speed(i,j,x) for i in 1:length(x),j in 1:length(x)];
    city_matrix[:,:,1] = dist_matrix./f(position_array);
    city_matrix[:,:,2] = dist_matrix./5;
    city_matrix[:,:,4] = BPR.(city_matrix[:,:,1], city_matrix[:,:,3],city_matrix[:,:,2]);
    red_cuadrada=network(SquareNet,position_array,city_matrix);
    return red_cuadrada
end