function BPR(tmin_ij::Float32, f_ij::Int16 ,p_ij::Float32, α::Float64 = 0.2, β::Float64 = 10.) # Funciona bien!! 
    t = tmin_ij *(1+α*(f_ij / p_ij)^β)
    return t
end

#en vez de recalcular identifica quiénes son tmin fij pij, calculamos desde la red

#El plan inicial de viaje de todos es el otorgado por el algoritmo de Dijkstra, cada auto necesita su pareja OD
function Planes_de_viaje(Red::red,pares_OD::Array{Int32,2})
    PV = []
    for i in 1:length(pares_OD[:,1])
        j,k = Dijkstra(pares_OD[i,1],pares_OD[i,2], Red)
        push!(k,0)
        push!(PV,k)
    end
    return PV
end

function restart(Autos::autos)
    Autos.avance = zeros(Autos.N)
    Autos.Vel = zeros(Autos.N)
    Autos.ruta_animacion=[]
    Autos.t_propio = zeros(Autos.N)
    for i in 1:Autos.N #reasignación de valores en vez de push
        o = Autos.PV[i][1]
        Autos.arista[i,:] = [0,o]
        push!(Autos.ruta_animacion,[])
    end
end