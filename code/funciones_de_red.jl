function Distance(ϕ1::Float64,λ1::Float64,ϕ2::Float64,λ2::Float64)

    y = (ϕ1-ϕ2)*111. #valor en metros, luego multiplicar por 1000
    x = (λ1-λ2)*105. 

    return sqrt(x^2+y^2)*1000.
end

function Dijkstra(x1::Int32, x2::Int32, Red::red)
    #= TODO: Cambiar la función para que utilice Hashing (diccionarios) y priority queues para los vértices =#
    ∞ = Inf
    #### PASO 1  ####
    Distancias_x1 = zeros(Red.n)
    ##Distancias a los vertices desde x1
    Distancias_NV = [[∞,i] for i in 1:Red.n]
    Ruta = []
    #vertices no visitados
    Vertices_unv = [i for i in 1:Red.n]
    if !(x2 in Vertices_unv)
        return ∞, []
    end
    for i in 1:Red.n 
        if i ≠ Int(x1)
            Distancias_x1[i] = ∞
            push!(Ruta, [x1])
        else
            push!(Ruta, [x1])
        end
    end
    ### Termina PASO 1 ###
    ### PASO 2 ###
    x = Red.vecinos[x1]
    y = Red.t_min[x1]
    for i in 1:length(x)
        Distancias_x1[Int(x[i])] = y[i]
        Rutacopia = copy(Ruta[Int(x1)])
        push!(Rutacopia, x[i])
        Ruta[Int(x[i])] = copy(Rutacopia)
        Distancias_NV[Int(x[i])][1] = y[i]
    end   
    i = Int(findall(in(x1), Vertices_unv)[1])
    deleteat!(Vertices_unv, i)
    deleteat!(Distancias_NV, i)  
 #   filter!(e -> e ≠ x1, Vertices_unv)
    ### Termina PASO 2 ####
    while x2 in Vertices_unv
         ### PASO 3 ####
        k = argmin(Distancias_NV)
        j = Int(Distancias_NV[k][2])
        x = Red.vecinos[j]
        y = Red.t_min[j]
        for i in 1:length(x)
            #    Distancias_x1[x[1][i]] = x[2][i]
            dist_xi_x1 = Distancias_NV[k][1]+y[i]
            
            if dist_xi_x1 < Distancias_x1[Int(x[i])]
                Distancias_x1[Int(x[i])] = dist_xi_x1
                Rutacopia = copy(Ruta[j])
                push!(Rutacopia, Int(x[i]))
                Ruta[Int(x[i])] = copy(Rutacopia)
                b = [algo[2] for algo in Distancias_NV]
                jj = findall(in(x[i]), b)  
                if length(jj)>0
                    Distancias_NV[Int(jj[1])][1] = dist_xi_x1
                end
            end     
        end   
        ### Termina PASO 3 ###
        ### PASO 4 ###
        i2 = findall(in(j), Vertices_unv)[1]
        deleteat!(Vertices_unv, i2)
        deleteat!(Distancias_NV, i2)  
        if length(Distancias_NV)>0
            i3 = argmin(Distancias_NV)
            dis = Distancias_NV[i3][1]
            if dis == ∞
                return ∞, []
            end
        end
        #### Termina paso 4 *Aunque continua abajo ####
        
        #### Paso 5 ####
    end  
    #### Paso 4 final ###
    return Distancias_x1[Int(x2)], Ruta[x2]
end    

#= TODO :
    - Implementar la función de heurística de la distancia faltante estimada
    - implementar el algoritmo A* modificado
    =#