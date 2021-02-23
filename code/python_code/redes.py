import numpy.random as rand

class Nodo:
    def __init__(self, nodo_id:str):
        self.id = nodo_id
        self.vecinos = []

    def _nuevo_vecino(self, vecino_id:str):
        self.vecinos.append(vecino_id)
    
    def cual_id(self):
        return self.id

class Arista:
    def __init__(self,par_ordenado:str, max_vel:float, longitud:float, capacidad:int):
        self.nodos = par_ordenado.split(',') 
        self.max_vel = max_vel
        self.longitud = longitud
        self.capacidad = capacidad
        self.num_autos = 0
        self.t_min = longitud/max_vel

    def _agrega_auto(self):
        self.num_autos += 1

    def _quita_auto(self):
        self.num_autos -= 1

    def costo(self):
        alpha = 0.2
        beta = 10.
        return self.t_min * (1.+alpha*(self.num_autos/self.capacidad)**beta)

class Red:
    def __init__(self):
        self.nodos = dict()
        self.aristas = dict()
        self.n = 0
        self.m = 0
    
    def _agrega_nodo(self, nodo_id:str):
        self.n += 1
        nodo = Nodo(nodo_id)
        self.nodos[nodo_id] = nodo
        return 
    
    def nodo_de_id(self, nodo_id:str):
        if nodo_id in self.nodos:
            return self.nodos[nodo_id]
        else: 
            return None
    
    def _agrega_arista(self, par_ordenado:str, max_vel:float, longitud:float, capacidad:int):
        self.m += 1
        u, v = par_ordenado.split(',')
        if u not in self.nodos:
            self._agrega_nodo(u)
        if v not in self.nodos:
            self._agrega_nodo(v)
        self.nodos[u]._nuevo_vecino(v) 

        arista = Arista(par_ordenado,max_vel,longitud,capacidad)
        self.aristas[par_ordenado] = arista
        return
    
    def arista_de_id(self, par_ordenado):
        if par_ordenado in self.aristas:
            return self.aristas[par_ordenado]
        else: 
            return None

def genera_red_cuadrada(n_lado:int, max_vel_dist:list, long_dist:list, cap_dist:list):
    """
    Genera una red cuadrada
    Parámetros:
    n_lado: el número de vértices por lado de la red,
    lista de dos entradas, la media y la desviación estándar de:
    max_vel_dist: la distribución de velocidades máximas
    long_dist: la distribución de longitudes de arista
    cap_dist: la distribución de capacidades
    """
    rc = Red()
    n = int(n_lado ** 2)
    m = int(2*n_lado**2-2*n_lado)*2
    max_vel = rand.normal(max_vel_dist[0],max_vel_dist[1], m)
    longitudes = rand.normal(long_dist[0],long_dist[1], m)
    cap = rand.normal(cap_dist[0],cap_dist[1], m)

    pares = []
    for i in range(n):

        vecinos_i = []

        if i >= n_lado:
            vecinos_i.append(str(i-n_lado))
            
        if i < n_lado*(n_lado-1):
            vecinos_i.append(i+n_lado) 

        if i%n_lado > 0:
            vecinos_i.append(i-1)

        if i%n_lado < n_lado - 1:
            vecinos_i.append(i+1)

        for vec in vecinos_i:
            pares.append(str(i)+','+str(vec))
    
    for i in range(n):
        rc._agrega_nodo(str(i))
    
    for i in range(m):
        rc._agrega_arista(pares[i],max_vel[i],longitudes[i],cap[i])
    
    return rc


