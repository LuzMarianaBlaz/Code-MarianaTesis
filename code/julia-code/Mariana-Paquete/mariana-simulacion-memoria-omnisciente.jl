using DataFrames, CSV, GraphPlot, Impute, Plots, Colors, Statistics, Random, Distributions, JLD
dir = "/home/aramis/Mariana/Paquete/Basefunc/"
#dir = "../Mariana-Paquete/Mariana-Basefunc/"

include(dir*"funciones_de_red.jl")
include(dir*"objetos.jl")
include(dir*"dinamica_conductores.jl")
include(dir*"animaciones.jl")

# Parametros
tamano_red = TAMANORED;
doble_sentido = false;
center_h_dist = 0.5;
sd_h_dist = 0;
h_distribution = Normal(center_h_dist, sd_h_dist);
n_cars = NCARS;
ti = 0.0;
tf = 150;
n_dias = 100;
path_jld = "OUTFILEMARIANA";
diag_start = [7.,160.];
pendiente = -pi/5;

# Generacion de la red
#red_cuadrada = make_div_del_norte(tamano_red, diag_start, pendiente, both_ways=doble_sentido);
#red_cuadrada = make_churubusco(tamano_red, diag_start, pendiente, both_ways=doble_sentido);

red_cuadrada = create_square_network(tamano_red, both_ways=doble_sentido);
SqNet= red_cuadrada.digraph;
m = nv(SqNet);
posarr = red_cuadrada.position_array;
city_mt = red_cuadrada.city_matrix;

# Generacion de los autos
autos = generate_autos(m,tamano_red, red_cuadrada,n_cars,ti,tf,h_distribution);
tiempos_de_salida_snapshot = [auto.ts for auto in autos];
collective_memory = [Dict{Int64, Float64}() for i in 1:2];

# simulacion
day_simulacion = 1;

save(path_jld, "t", "test")

while day_simulacion < n_dias+1
    print("día $(day_simulacion) \n")
    times, vels, matrix_density, autos_atorados = simulacion!(0., red_cuadrada, autos);
    distance_summ = distance_summary(autos, red_cuadrada)
    travel_times = times_summary(autos)
    indexes = restart_with_omniscient_mem(autos, collective_memory,
                                          red_cuadrada, tiempos_de_salida_snapshot)
    information_array = [distance_summ, travel_times, indexes, vels, matrix_density, autos_atorados]

    jldopen(path_jld, "r+") do file
        write(file, string("day", day_simulacion), information_array)
    end

    print(mean(distance_summ ./ travel_times),"\n")
    global day_simulacion += 1
end