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
max_n_dias = 200;
path_csv = "OUTFILEMARIANA";

# Generacion de la red
red_cuadrada = create_square_network(tamano_red, both_ways=doble_sentido);
SqNet= red_cuadrada.digraph;
m = nv(SqNet);
posarr = red_cuadrada.position_array;
city_mt = red_cuadrada.city_matrix;

# Generacion de los autos
autos = generate_autos(m,red_cuadrada,n_cars,ti,tf,h_distribution);

# simulacion
day_simulacion = 0;
min_vels = [];
avg_vels = [];
cars_changing = [];
n_simulacion = 200;
avg_time = [];
max_time = [];
random_time = [];
index_changers = [];

while day_simulacion > 101 
    print("día $(day_simulacion) \n")
    times, vels = simulacion!(0., red_cuadrada, autos);
    min_vel, avg_vel = get_avg_vel(autos)
    t_cars = get_avg_times(autos)
    push!(min_vels,min_vel)
    push!(avg_vels,avg_vel)
    push!(avg_time, mean(t_cars))
    push!(max_time, maximum(t_cars))
    push!(random_time, t_cars[Int(floor(n_cars/2))]
        
    print(min_vel," ", avg_vel,"\n")
    n_simulacion, inexes = restart(autos, red_cuadrada)
    push!(cars_changing, n_simulacion)
    push!(index_changers, indexes)

        
    global day_simulacion += 1
end

df = DataFrame(min_vel = min_vels, 
               avg_vel = avg_vels,
               cars_changed = cars_changing,
                max_time = max_time,
                avg_time = avg_time,
                random_time = random_time,
                indexes = index_changers
               );

CSV.write(path_csv, df)