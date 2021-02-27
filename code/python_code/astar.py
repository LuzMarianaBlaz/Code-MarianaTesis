import redes
import heapq
import numpy as np

#Objetos a utilizarse en el árbol de búsqueda
class Tree_node:
    """
    Esta clase representa un nodo en el árbol de búsqueda
    de un algoritmo en gráficas. incluye un node_id, un nodo padre
    un pre_costo, un costo futuro y un costo total.
    El pre_costo es el costo de haber llegado hasta dicho nodo, el
    costo futuro corresponde a una heurística de cuánto más falta para
    llegar al destino en el algoritmo de búsqueda, el costo total es
    la suma de ambos costos.
    """

    def __init__(self, node_id: str, parent):
        self.node_id = node_id
        self.parent = parent
        self.pre_costo = 0.
        self.costo_futuro = 0.
        self.costo_total = 0.
    
    def __eq__(self, other):
        """
        revisa si dos tree nodes tienen el mismo node_id.
        """
        return self.node_id == other.node_id
    
    def __lt__(self,other):
        """
        revisa si el costo del nodo es menor que el costo de other.
        """
        return self.costo_total < other.costo_total


#Algoritmo A* clásico
def A_star(red:redes.Red,heuristica,origen:str,destino:str):
    #Paso 1: Genera los conjuntos abierto y cerrado
    abierto = []
    cerrado = []

    #Paso 2: Creación de un nodo final y un nodo inicial
    edo_inicial = Tree_node(origen,None) #no tiene nodo padre pues es la raiz del arbol de busqueda
    edo_final = Tree_node(destino, None) #aun no sabemos el padre

    #Paso 3: Agrega el nodo inicio al conjunto abierto
    abierto.append(edo_inicial)
    heapq.heapify(abierto) #abierto se vuelve un binary heap

    #Paso 4: Mientras haya elementos en abierto:
    while len(abierto) > 0:

        #4.1 Pone al nodo de menor costo en el conjunto cerrado
        edo_actual = heapq.heappop(abierto)
        cerrado.append(edo_actual)

        #4.2 Si el nodo es el destino, construye el camino y lo devuelve
        if edo_actual == edo_final:
            return construye_camino(edo_actual, edo_inicial)

        #4.3 Si no es el destino, se requiere la lista de vecinos
        nodo_actual = red.nodo_de_id(edo_actual.node_id)
        if nodo_actual is not None:
            vecinos = nodo_actual.vecinos

        #Para cada vecino:
        for vecino in vecinos:
            edo_vec = Tree_node(vecino, edo_actual)
            edo_vec.pre_costo = edo_actual.pre_costo + red.arista_de_id(str(edo_actual.node_id)+','+str(edo_vec.node_id)).costo()
            edo_vec.costo_futuro = heuristica(red,edo_vec, edo_final)
            edo_vec.costo_total = edo_vec.pre_costo + edo_vec.costo_futuro
            mejora(edo_vec, abierto, cerrado)

    #5. Si el abierto queda vacío y no se encuentra un camino se regresa None
    return None


## Método construye_camino
def construye_camino(nodo:Tree_node, nodo_origen:Tree_node):
    """
    Devuelve el camino desde el nodo origen hasta el nodo deseado.
    """
    camino = [nodo.node_id]
    while nodo.parent != nodo_origen:
        nodo = nodo.parent
        camino.append(nodo.node_id)
    camino.append(nodo_origen.node_id)
    return camino[::-1]

## Método mejora
def mejora(edo_vecino:Tree_node, abierto:list, cerrado:list):
    """
    Si el estado vecino corresponde a un nodo en abierto y el costo mejora
    se actualiza el valor del pre-costo de dicho estado, así como el nodo padre.
    Si el estado vecino corresponde a un nodo ya cerrado y el costo mejora
    se actualiza el valor del pre-costo de dicho estado y el nodo se reabre con 
    el padre del estado vecino.
    
    El estado vecino se agrega al conjunto abierto con su costo y su padre
    si no se cumple ninguna de las condiciones establecidas arriba.
    """
    append_abierto = True
    for edo in abierto:
        if edo_vecino.node_id == edo.node_id:
            append_abierto = False
        if (edo_vecino.node_id == edo.node_id) and (edo_vecino.pre_costo < edo.pre_costo):
            edo.pre_costo = edo_vecino.pre_costo
            edo.costo_total = edo.pre_costo + edo.costo_futuro
            edo.parent = edo_vecino.parent
            heapq.heapify(abierto)
            return
    for edo in cerrado:
        if (edo_vecino.node_id == edo.node_id):
            if (edo_vecino.pre_costo < edo.pre_costo):
                edo.pre_costo = edo_vecino.pre_costo
                edo.costo_total = edo.pre_costo + edo.costo_futuro
                edo.parent = edo_vecino.parent
                cerrado.remove(edo)
                heapq.heappush(abierto,edo)
                return
            else:
                append_abierto = False
    
    if append_abierto:
        heapq.heappush(abierto,edo_vecino)
    return

# TODO: Definir algunas heurísticas
def tiempo_euclideano(red:redes.Red,edo:Tree_node,edo_final:Tree_node):
    """
    Devuelve el tiempo que tomaría recorrer del edo al edo_final
    si se viajara en línea recta a la velocidad máxima reportada 
    para el mapa.
    """
    distancia = np.sqrt(
        (red.nodo_de_id(edo.node_id).lugar[0]-red.nodo_de_id(edo_final.node_id).lugar[0])**2+
        (red.nodo_de_id(edo.node_id).lugar[1]-red.nodo_de_id(edo_final.node_id).lugar[1])**2)
    velocidad = 20.
    tiempo = distancia/velocidad
    return tiempo
# Hacer la heurística tiempo euclideano, que utilice el atributo Nodo.lugar
# calcule distancia euclideana (asumir plano) y divida entre la vel promedio
# de la ciudad.

# TODO: Pruebas del algoritmo base

## TODO: Modificar el algoritmo con lo siguiente:
# - no hay reapertura de nodos
# - la heurística depende de la memoria de los conductores y la distancia euclideana
# - si hay una mejora el avance es inmediato en vez de revisar todos los posibles vecinos