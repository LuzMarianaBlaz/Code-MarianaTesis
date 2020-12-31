from . import redes
import heapq

#Objetos a utilizarse en el árbol de búsqueda
class Tree_node:

    def __init__(self, node_id, parent):
        self.node_id = node_id
        self.parent = parent
        self.pre_costo = 0.
        self.costo_futuro = 0.
        self.costo_total = 0.

    # comparacion de nodos
    def __eq__(self, other):
        return self.node_id == other.node_id
    
    # comparacion de costos 
    def __lt__(self,other):
        return self.costo_total < other.costo_total


#Algoritmo A* clásico
def A_star(red,heuristica,origen,destino):
    #Paso 1: Genera los conjuntos abierto y cerrado
    abierto = []
    cerrado = []

    #Paso 2: Creación de un nodo final y un nodo inicial
    inicial = Tree_node(origen,None) #no tiene nodo padre pues es la raiz del arbol de busqueda
    final = Tree_node(destino, None) #aun no sabemos el padre

    #Paso 3: Agrega el nodo inicio al conjunto abierto
    abierto.append(inicial)
    heapq.heapify(abierto) #abierto se vuelve un binary heap

    #Paso 4: Mientras haya elementos en abierto:
    while len(abierto) > 0:

        #4.1 Pone al nodo de menor costo en el conjunto cerrado
        nodo_actual = heapq.heappop(abierto)
        cerrado.append(nodo_actual)

        #4.2 Si el nodo es el destino, construye el camino y lo devuelve
        if nodo_actual == final:
            return construye_camino(nodo_actual, inicial)

        #4.3 Si no es el destino, se requiere la lista de vecinos
        vecinos = red.consigue_nodo(nodo_actual.node_id).vecinos

        #Para cada vecino:
        for vecino in vecinos:
            vec = Tree_node(vecino.id, nodo_actual)
            vec.pre_costo = nodo_actual.pre_costo + red.consigue_arista(str(nodo_actual.node_id)+','+str(vec.node_id)).costo
            vec.costo_futuro = heuristica(vec, final)
            vec.costo_total = vec.pre_costo + vec.costo_futuro
            mejora(vec, abierto, cerrado)

    #5. Si el abierto queda vacío y no se encuentra un camino se regresa None
    return None


## Método construye_camino
def construye_camino(nodo, nodo_origen):
    camino = [nodo.node_id]
    while nodo.parent != nodo_origen:
        nodo = nodo.parent
        camino.append(nodo.node_id)
    camino.append(nodo_origen.node_id)
    return camino[::-1]

## Método mejora
def mejora(vecino, abierto, cerrado):
    for node in abierto:
        if (vecino == node) and (vecino.pre_costo < node.pre_costo):
            node.pre_costo = vecino.pre_costo
            node.costo_total = node.pre_costo + node.costo_futuro
            node.parent = vecino.parent
            heapq.heapify(abierto)
            return
    for node in cerrado:
        if (vecino == node) and (vecino.pre_costo < node.pre_costo):
            node.pre_costo = vecino.pre_costo
            node.costo_total = node.pre_costo + node.costo_futuro
            node.parent = vecino.parent
            cerrado.remove(node)
            heapq.heappush(abierto,node)
            return
    
    heapq.heappush(abierto,vecino)
    return

# TODO: Definir algunas heurísticas

## TODO: Modificar el algoritmo con lo siguiente:
# - no hay reapertura de nodos
# - la heurística depende de la memoria de los conductores y la distancia euclideana
# - si hay una mejora el avance es inmediato en vez de revisar todos los posibles vecinos