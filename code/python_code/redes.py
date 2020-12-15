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