function complete!(autos)
    max_num = maximum([length(auto.posicion) for auto in autos])
    for auto in autos
        dif = max_num - length(auto.posicion)
        append!(auto.posicion, [auto.posicion[end] for i in 1:dif])
    end
end


function continuos_time!(times,autos)
    complete!(autos)
    coordenadasx_grafica = []
    coordenadasy_grafica = []

    times = round.(times, digits = 1)
    new_times = times[1]:0.1:times[end]+2
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