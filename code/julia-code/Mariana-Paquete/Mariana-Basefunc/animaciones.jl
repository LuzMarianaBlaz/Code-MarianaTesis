function complete!(autos, times)
    max_num = length(times)
    for auto in autos
        dif = max_num - length(auto.posicion)
        append!(auto.posicion, [auto.posicion[end] for i in 1:dif])
        auto.posicion = auto.posicion[indexin(unique(times), times)]

    end
end

function continuos_time!(times,autos)
    x_out = []
    y_out = []
    x_dest=[]
    y_dest=[]

    times = round.(times, digits = 2)
    push!(times,times[end]+5.)
    complete!(autos,times)
    times = times[indexin(unique(times), times)]
    
    new_times = times[1]:0.01:times[end]
    
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
        size_all = size(df)[1]
        
        dest = position_array[auto.d]

        df_llego = subset(subset(df, :x => x -> x .==dest[1]),:y => y -> y .==dest[2])
        
        times_llego = df_llego[!,"time"]
        size_llego = size(df_llego)[1]
        
        df_out = subset(df, :time => t -> in(times_llego).(t) .== 0)


        push!(x_out,vcat(df_out[! ,"x"],[NaN for i in 1:(size_llego)]))
        push!(y_out,vcat(df_out[! ,"y"],[NaN for i in 1:(size_llego)]))
        
        push!(x_dest,vcat([NaN for i in 1:(size_all-size_llego)],df_llego[! ,"x"]))
        push!(y_dest,vcat([NaN for i in 1:(size_all-size_llego)],df_llego[! ,"y"]))
        
    end
    return new_times, x_out, y_out, x_dest, y_dest
        
end

function which_different(A,B)
    findall(x->x==1, A .!= B)
end


function plot_digraph(g, position_array; attribute_matrix = ones(nv(g),nv(g)),
    separated_edges = false, c1 = colorant"red", c2 = colorant"green",
    min_value = 0., max_value = 100.0)
    
    fig = plot()

    num_colors = floor(Int,(round(max_value, digits=2)*10^2))
    if attribute_matrix != ones(nv(g),nv(g))
        cols = range(c1,stop=c2,length=num_colors)
    else
        cols = ["black" for i in 1:num_colors]
    end

    for e in collect(edges(g))
        u = src(e)
        v = dst(e)

        pos_u = deepcopy(position_array[u])
        pos_v = deepcopy(position_array[v])

        if separated_edges
            if which_different(pos_u,pos_v)[1] == 1
                if pos_u[1] < pos_v[1]
                    pos_u[2] -= 2. 
                    pos_v[2] -= 2.
                else
                    pos_u[2] += 2. 
                    pos_v[2] += 2.
                end
            end

            if which_different(pos_u,pos_v)[1] == 2
                if pos_u[2] < pos_v[2]
                    pos_u[1] -= 2. 
                    pos_v[1] -= 2.
                else
                    pos_u[1] += 2. 
                    pos_v[1] += 2.
                end
            end
        end

        m = (max_value*100.0-1.0)/(max_value-min_value)
        b = 1.0 - min_value*(max_value*100.0-1.0)/(max_value-min_value)
        order = floor(Int,(m*attribute_matrix[u,v]+b))
        edge_color = cols[order] 

        plot!([pos_u[1],pos_v[1]],[pos_u[2],pos_v[2]],
              color=edge_color,
              linewidth=2.,label="", aspect_ratio=1)
    end
    return(fig, cols)
end