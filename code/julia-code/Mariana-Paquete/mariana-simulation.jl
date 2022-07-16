using DataFrames, CSV, GraphPlot, Impute, Plots, Colors, Statistics, Random, Distributions
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
n_dias = 50;
path_csv = "OUTFILEMARIANA";

# Generacion de la red
red_cuadrada = create_square_network(tamano_red, both_ways=doble_sentido);
SqNet= red_cuadrada.digraph;
m = nv(SqNet);
posarr = red_cuadrada.position_array;
city_mt = red_cuadrada.city_matrix;

# Generacion de los autos
autos = generate_autos(m,tamano_red, red_cuadrada,n_cars,ti,tf,h_distribution);

# simulacion
day_simulacion = 0;
n_simulacion = 200;

while day_simulacion < n_dias+1
    print("día $(day_simulacion) \n")
    times, vels = simulacion!(0., red_cuadrada, autos);
    vels_summ = vels_summary(autos)
    travel_times = times_summary(autos)
    indexes = restart(autos, red_cuadrada)


    df = DataFrame(speeds = [vels_summ],
                times = [travel_times],
                indexes = [indexes]
               )

    CSV.write(path_csv, df, append=true, writeheader = (day_simulacion==0))

    print(mean(vels_summ),"\n")
    global day_simulacion += 1
end