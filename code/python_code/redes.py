import numpy.random as rand

class Nodo:
    def __init__(self, nodo):
        self.id = nodo
        self.vecinos = []

    def nuevo_vecino(self, vecino):
        self.vecinos.append(vecino)
    
    def cual_id(self):
        return self.id

class Arista:
    def __init__(self,par_ordenado, max_vel, longitud, capacidad):
        self.nodos = par_ordenado.split(',') 
        self.max_vel = max_vel
        self.longitud = longitud
        self.capacidad = capacidad
        self.num_autos = 0
        self.t_min = longitud/max_vel

    def agrega_auto(self):
        self.num_autos += 1

    def quita_auto(self):
        self.num_autos -= 1

class Red:
    def __init__(self):
        self.nodos = {}
        self.aristas = {}
        self.n = 0
        self.m = 0
    
    def agrega_vertice(self, nodo_id):
        self.n += 1
        nodo = Nodo(nodo_id)
        self.nodos[nodo_id] = nodo
        return nodo
    
    def consigue_nodo(self, nodo_id):
        if nodo_id in self.nodos:
            return self.nodos[nodo_id]
        else: 
            return None
    
    def agrega_arista(self, par_ordenado, max_vel, longitud, capacidad):
        self.m += 1
        u, v = par_ordenado.split(',')
        if u not in self.nodos:
            self.agrega_vertice(u)
        if v not in self.nodos:
            self.agrega_vertice(v)
        self.nodos[u].nuevo_vecino(v) 

        arista = Arista(par_ordenado,max_vel,longitud,capacidad)
        self.aristas[par_ordenado] = arista
        return(arista)
    
    def consigue_arista(self, par_ordenado):
        if par_ordenado in self.aristas:
            return self.aristas[par_ordenado]
        else: 
            return None

def genera_red_cuadrada(n_lado, max_vel_dist, long_dist, cap_dist):
    rc = Red()
    n = int(n_lado ** 2)
    m = int(2*n_lado**2-2*n_lado)
    m = m*2
    max_vel = rand.normal(max_vel_dist[0],max_vel_dist[1], m)
    longitudes = rand.normal(long_dist[0],long_dist[1], m)
    cap = rand.normal(cap_dist[0],cap_dist[1], m)

    pares = []
    for i in range(n):

        vecinos_i = []

        if i >= n_lado:
            vecinos_i.append(i+n_lado)
            
        if i < n_lado*(n_lado-1):
            vecinos_i.append(i-n_lado) 

        if i%n_lado > 0:
            vecinos_i.append(i+1)

        if i%n_lado < n_lado - 1:
            vecinos_i.append(i-1)

        for vec in vecinos_i:
            pares.append(str(i)+','+str(vec))
    
    for i in range(n):
        rc.agrega_vertice(str(i))
    
    for i in range(m):
        rc.agrega_arista(pares[i],max_vel[i],longitudes[i],cap[i])
    
    return rc


