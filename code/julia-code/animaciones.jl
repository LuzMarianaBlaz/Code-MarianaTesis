function complete!(autos, times)
    max_num = length(times)
    for auto in autos
        dif = max_num - length(auto.posicion)
        append!(auto.posicion, [auto.posicion[end] for i in 1:dif])
    end
end


function continuos_time!(times,autos)
    x_out = []
    y_out = []
    x_dest=[]
    y_dest=[]

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
        size_all = size(df)[1]

        df_out = subset(df, :time => x -> x .< auto.llego)
        size_out = size(df_out)[1]

        push!(x_out,vcat(df_out[! ,"x"],[NaN for i in 1:(size_all-size_out)]))
        push!(y_out,vcat(df_out[! ,"y"],[NaN for i in 1:(size_all-size_out)]))
        
        df_dest = subset(df, :time => x -> x .>= auto.llego)
        push!(x_dest,vcat([NaN for i in 1:(size_out)],df_dest[! ,"x"]))
        push!(y_dest,vcat([NaN for i in 1:(size_out)],df_dest[! ,"y"]))
        
    end
    return new_times, x_out, y_out, x_dest, y_dest
        
end

function which_different(A,B)
    findall(x->x==1, A .!= B)
end

function plot_digraph(g; attribute_matrix = ones(nv(g),nv(g)), separated_edges = false)
    fig = plot()
    
    c1 = colorant"red"
    c2 = colorant"blue"
    
    if attribute_matrix != ones(nv(g),nv(g))
        new_matrix1 = zeros(nv(g),nv(g))
        new_matrix2 = Inf*ones(nv(g),nv(g))
        for e in collect(edges(g))
            u = src(e)
            v = dst(e)
            new_matrix1[u,v] = attribute_matrix[u,v]
            new_matrix2[u,v] = attribute_matrix[u,v]
        end

        cols = range(c1, stop=c2,
            length=floor(Int,maximum(new_matrix1))-floor(Int,minimum(new_matrix2))+1)
    else
        cols = ["black" for i in 1:ne(g)]
        new_matrix2 = attribute_matrix
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
        
    
        plot!([pos_u[1],pos_v[1]],[pos_u[2],pos_v[2]], 
            color=cols[floor(Int,attribute_matrix[u,v])-floor(Int,minimum(new_matrix2))+1],
            linewidth=2.,label="", aspect_ratio=1)
    end
    return(fig)
end