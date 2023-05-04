using DataFrames, GraphPlot, Impute, Colors, Plots, StatsPlots
using Statistics, Random, Distributions, JLD, StatsBase

import GR
GR.inline("png")

dir = "/home/aramis/Mariana/Paquete/Basefunc/"

include(dir*"funciones_de_red.jl")
include(dir*"objetos.jl")
include(dir*"dinamica_conductores.jl")
include(dir*"animaciones.jl")
include(dir*"plotting.jl")

days_per_repetition = 100;
number_of_cars = NCARS;
tamano_red = TAMANORED;
sim_path = SIMPATH;
diag_start = [7.,160.];
pendiente = -pi/5;

function max_speed(u::Int,
    position_array::Array{Array{Float64,1},1}=[[0.,0.]])
    return 12
    #x_array = [first(element) for element in position_array]
    #if position_array[u][1] < maximum(x_array)/2.
        #return 15. #m/s
    #else
        #return 8. #m/s
    #end
end
    
#red_cuadrada = make_churubusco(tamano_red, diag_start, pendiente, both_ways=false);
red_cuadrada = make_div_del_norte(tamano_red, diag_start, pendiente, both_ways=false);
#red_cuadrada = create_square_network(tamano_red, both_ways=false);
SquareNet= red_cuadrada.digraph;
position_array = red_cuadrada.position_array;
city_mt = red_cuadrada.city_matrix;
    
f = x -> [max_speed(i,j,x) for i in 1:length(x),j in 1:length(x)];
vels = f(position_array);

print("Saving red architecture \n");
fig, colors = plot_digraph(SquareNet, position_array, attribute_matrix=vels, 
                            separated_edges=true, c1 = colorant"red", c2 = colorant"green",
                            min_value=10.0, max_value=12.0);
fig = plot!(fig, title="Arquitectura de red (distribución de velocidades máximas)");

savefig(fig, "red-arch.png");

simulations_path = sim_path*"/redsize"*string(tamano_red)*"/"

moving_average(vs,n) = [mean(vs[(i-n):(i+n)]) for i in n+1:(length(vs)-n)]

function get_nice_axes(arr)
        return [minimum(arr) - (maximum(arr)-minimum(arr))/100 - 0.0001,
        maximum(arr) + (maximum(arr)-minimum(arr))/100 + 0.0001]
    end

for i in 1:10
    ## Save path 
    local_path = string(i)*"repetition/"
    mkdir(local_path)
    
    
        ## Information
    print("Reading files  \n")
    reads = load(simulations_path*"nautos"*string(number_of_cars)*"/"*string(i)*"/Datos-RS"*string(tamano_red)*"-N"*string(number_of_cars)*"-R"*string(i)*".jld");

    (day_speed_average,
    day_speed_mode,
    day_time_average,
    day_time_mode,
    day_distance_average,
    day_distance_mode,
    daily_mean_indexes,
    daily_count_indexes,
    day_nan_proportion) = get_information_by_day(days_per_repetition, number_of_cars, reads);

    (car_speed_average,
    car_speed_mode,
    car_time_average,
    car_time_mode,
    car_distance_average,
    car_distance_mode)= get_information_by_car(days_per_repetition, number_of_cars, reads);

    (daily_mean_red_vels,
    daily_count_red_vels,
    daily_red_final_saturation) = red_daily_information(days_per_repetition, number_of_cars, reads);

    autos_atorados = autos_atorados_info(days_per_repetition, reads);

    df = summary_df(days_per_repetition, number_of_cars, reads);
    
    ## Plots
    print("Plotting  \n")

    ## plot 1
    plot1 = plot([i*1.0 for i in 11:length(day_time_mode)-10],
    moving_average(day_time_mode, 10),
    label="Moda: promedio móvil",
    xlabel="Día",
    ylabel="Tiempo de recorrido",
    title="Tiempo según el número de día",
    xlimits=[0,102],
    ylimits=get_nice_axes(day_time_mode));

    plot1 = plot!(plot1,
    [i*1.0 for i in 1:length(day_time_mode)],
    day_time_mode,
    label="Moda: Valor del día");
    savefig(plot1, local_path*"mode-day-time.png")
    
    ## plot 2
    plot2 = plot([i*1.0 for i in 11:length(day_time_average)-10],
    moving_average(day_time_average, 10),
    label="Media: promedio móvil",
    xlabel="Día",
    ylabel="Tiempo de recorrido",
    title="Tiempo según el número de día",
    xlimits=[0,102],
    ylimits=get_nice_axes(day_time_average));

    plot2 = plot!(plot2,
    [i*1.0 for i in 1:length(day_time_average)],
    day_time_average,
    label="Media: Valor del día");
    savefig(plot2, local_path*"avg-day-time.png")
    
    ## plot 3
    plot3 = @df df histogram(:times,
    title="Tiempo de recorrido diario",
    xlabel="Tiempo de recorrido",
    ylabel="Cuenta",
    palette=palette([:red, :blue], length(:times)),
    legend=false, bins=100, alpha=0.5);
    savefig(plot3, local_path*"histiempo.png")
    
    ## plot velocidades
    daily_red_vels = [reads[string("day",i)][4] for i in 1:days_per_repetition];
    fig, colors = plot_digraph(SquareNet, position_array, attribute_matrix=mean(daily_red_vels), 
                            separated_edges=true, c1 = colorant"red", c2 = colorant"green",
                            min_value=10.0, max_value=12.0);
    fig = plot!(fig, title="Distribución promedio de velocidades")
    savefig(fig, local_path*"avg-red-vel.png")
    
    ## plot 4
    plot4 = plot([i*1.0 for i in 11:length(day_speed_mode)-10],
    moving_average(day_speed_mode, 10),
    label="Moda: promedio móvil",
    xlabel="Día",
    ylabel="Velocidad promedio en el recorrido",
    title="Velocidad según el número de día",
    xlimits=[0,102],
    ylimits=get_nice_axes(day_speed_mode));

    plot4 = plot!(plot4,
    [i*1.0 for i in 1:length(day_speed_mode)],
    day_speed_mode,
    label="Moda: Valor del día");
    savefig(plot4, local_path*"mode-day-vel.png")
    
    ## plot 5
    plot5 = plot([i*1.0 for i in 11:length(day_speed_average)-10],
    moving_average(day_speed_average, 10),
    label="Media: promedio móvil",
    xlabel="Día",
    ylabel="Velocidad promedio en el recorrido",
    title="Velocidad según el número de día",
    xlimits=[0,102],
    ylimits=get_nice_axes(day_speed_average));

    plot5 = plot!(plot5,
    [i*1.0 for i in 1:length(day_speed_average)],
    day_speed_average,
    label="Media: Valor del día");
    savefig(plot5, local_path*"avg-day-vel.png")
    
    ## plot 6
    plot6 = @df df histogram(:speeds,
    title="Velocidades diarias",
    xlabel="Velocidad durante el recorrido",
    ylabel="Cuenta",
    palette=palette([:red, :blue],length(:speeds)),
    legend=false,
    bins=100,
    alpha=0.5);
    savefig(plot6, local_path*"histvel.png")
    
    #plot 7
    plot7 = plot([i*1.0 for i in 11:length(day_distance_average)-10],
    moving_average(day_distance_average, 10),
    label="Media: promedio móvil",
    xlabel="Día",
    ylabel="Distancia promedio en el recorrido",
    title="Distancia según el número de día",
    xlimits=[0,102],
    ylimits=get_nice_axes(day_distance_average));

    plot7 = plot!(plot7,
    [i*1.0 for i in 1:length(day_distance_average)],
    day_distance_average,
    label="Media: Valor del día");
    savefig(plot7, local_path*"avg-day-distance.png")
    
    #plot 8
    plot8 = plot([i*1.0 for i in 11:length(daily_count_indexes)-10],
    moving_average(daily_count_indexes,10),
    label="Cuenta: Promedio móvil",
    xlabel="Día",
    ylabel="indice",
    title="Numero de autos cambiando",
    xlimits=[0,102],
    ylimits=get_nice_axes(daily_count_indexes));

    plot8 = plot!(plot8,[i*1.0 for i in 1:length(daily_count_indexes)],
    daily_count_indexes,
    label="Cuenta: Valor",
    )
    savefig(plot8, local_path*"avg-changing-cars.png")
    
    
    # Para las graficas de saturacion
    xvals = collect(keys(autos_atorados));
    I = sortperm(xvals);
    yvals_atorados = getindex.(collect(values(autos_atorados)),1);
    yvals_snapshot = getindex.(collect(values(autos_atorados)),2);


    xvals_ordered = xvals[I];
    yvals_atorados_ordered = yvals_atorados[I];
    yvals_snapshot_ordered = yvals_snapshot[I];

    J = findall(>(50), yvals_snapshot_ordered);

    xvals_ss = xvals_ordered[J];
    yvals_atorados_ss = yvals_atorados_ordered[J];
    yvals_snapshot_ss = yvals_snapshot_ordered[J];

    K = findall(>(0), yvals_atorados_ss);
    
    #plot 9
    if length(xvals_ss[K]) > 0
        plot9 = scatter(xvals_ss[K],
        yvals_atorados_ss[K],
        xlabel="Autos en la red al mismo tiempo",
        ylabel="Proporción de veces que se atora",
        label="",
        xlimits=get_nice_axes(xvals_ss[K]),
        ylimits=get_nice_axes(yvals_atorados_ss[K]))
        savefig(plot9, local_path*"autos-autorados-mean.png")
    end
    
    ## plot 10
    plot10 = scatter(xvals_ss,
    yvals_snapshot_ss,
    xlabel="Autos en la red al mismo tiempo",
    ylabel="Frecuencia",
    label="valor",
    xlimits=get_nice_axes(xvals_ss),
    ylimits=get_nice_axes(yvals_snapshot_ss));

    plot10 = plot!(plot10, xvals_ss[11:end-10],
        moving_average(yvals_snapshot_ss,10),
        label = "Promedio móvil");
    savefig(plot10, local_path*"autos-autorados-count.png")

    ## Summarized info
    print("Saving summarized info  \n")
        
    daily_red_final_saturation = [reads[string("day",i)][5] for i in 1:days_per_repetition];
    daily_red_final_saturation = daily_red_final_saturation;

    nonzero_saturations = daily_red_final_saturation[sum.(daily_red_final_saturation) .> 0];
    avg_nonzero_saturations = daily_red_final_saturation[1];
    if length(nonzero_saturations) > 0
        avg_nonzero_saturations = mean(nonzero_saturations);
    end
    
    save(local_path*"summary.jld", "summary", [mean(daily_red_vels[20:end]), avg_nonzero_saturations, mean(day_speed_average[20:end]), mean(day_time_average[20:end]), mean(day_distance_average[20:end]), mean(daily_count_indexes[20:end]), autos_atorados, day_nan_proportion])

end
    
print("Removing folder on Sim \n")
rm(simulations_path*"nautos"*string(number_of_cars)*"/", recursive=true)
        