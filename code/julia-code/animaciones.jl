function complete!(autos, times)
    max_num = length(times)
    for auto in autos
        dif = max_num - length(auto.posicion)
        append!(auto.posicion, [auto.posicion[end] for i in 1:dif])
    end
end


function continuos_time!(times,autos)
    coordenadasx_grafica = []
    coordenadasy_grafica = []

    times = round.(times, digits = 1)
    push!(times,times[end]+3.)
    complete!(autos,times)
    new_times = times[1]:0.1:times[end]+5.0
    
    positions = findall(x -> (x in times), new_times)
    
    for auto in autos
        xcoords = convert(Vector{Union{Missing,Float64}},ones(length(new_times)).*missing)
        ycoords = convert(Vector{Union{Missing,Float64}},ones(length(new_times)).*missing)
        
        for i in 1:length(positions)
            xcoords[positions[i]] = auto.posicion[i][1]
            ycoords[positions[i]] = auto.posicion[i][2]
        end
        df = DataFrame(time = new_times, x = xcoords, y = ycoords)
        df = Impute.interp(df)
        push!(coordenadasx_grafica,df[!,"x"])
        push!(coordenadasy_grafica,df[!,"y"])
    end
    return new_times, coordenadasx_grafica, coordenadasy_grafica
        
end

function which_different(A,B)
    findall(x->x==1, A .!= B)
end

function plot_digraph(g; attribute_matrix = ones(nv(g),nv(g)), separated_edges = false)
    fig = plot()
    
    c1 = colorant"red"
    c2 = colorant"blue"
    
    if attribute_matrix != ones(nv(g),nv(g))
        cols = range(c1, stop=c2, length=300)
    else
        cols = ["black" for i in 1:ne(g)]
    end
    
    for e in collect(edges(g))
        u = src(e)
        v = dst(e)

        pos_u = deepcopy(position_array[u])
        pos_v = deepcopy(position_array[v])
        
        
        if separated_edges
        
            if which_different(pos_u,pos_v)[1] == 1
                if pos_u[1] < pos_v[1]
                    pos_u[2] -= 1. 
                    pos_v[2] -= 1.
                else
                    pos_u[2] += 1. 
                    pos_v[2] += 1.
                end
            end

            if which_different(pos_u,pos_v)[1] == 2
                if pos_u[2] < pos_v[2]
                    pos_u[1] -= 1. 
                    pos_v[1] -= 1.
                else
                    pos_u[1] += 1. 
                    pos_v[1] += 1.
                end
            end
        end
        
        plot!([pos_u[1],pos_v[1]],[pos_u[2],pos_v[2]],
            arrow=true, color=cols[floor(Int,attribute_matrix[u,v])+1],
            linewidth=0.2,label="")
    end
    return(fig)
end