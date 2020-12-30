from . import redes
#Algoritmo A* normal

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



def A_star(red,heuristica,origen,destino):
    #Paso 1: Genera los conjuntos abierto y cerrado
    abierto = []
    cerrado = []

    #Paso 2: Creación de un nodo final y un nodo inicial
    inicial = Tree_node(origen,None) #no tiene nodo padre pues es la raiz del arbol de busqueda
    final = Tree_node(destino, None) #aun no sabemos el padre

    #Paso 3: Agrega el nodo inicio al conjunto abierto
    abierto.append(inicial)

    #Paso 4: Mientras haya elementos en abierto:
    while len(open) > 0:
        #4.1 Ordena los nodos de menor a mayor costo
        abierto.sort()
        #4.2 Pone al nodo de menor costo en el conjunto cerrado
        nodo_actual = abierto.pop(0)
        cerrado.append(nodo_actual)
        #4.3 Si el nodo es el destino, construye el camino y lo devuelve
        if nodo_actual == final:
            return construye_camino()
        #4.4 Si no es el destino, se requiere la lista de vecinos
        vecinos = red.consigue_nodo(nodo_actual.node_id).vecinos
        #Para cada vecino:
        for vecino in vecinos:
            vec = Tree_node(vecino.id, nodo_actual)

            ##4.4.1 Revisa si está en el conjunto cerrado y si es así lo ignora
            if vec in cerrado:
                pass
            ##4.4.2 Calcula el costo del camino pasando por ese nodo
            vec.pre_costo = nodo_actual.pre_costo + costo_arista
            vec.costo_futuro = heuristica(vec,destino)
            vec.costo_total = vec.pre_costo + vec.costo_futuro

            ##4.4.3 Revisa si el vecino está en el conjunto abierto y si es así revisa si mejor al costo
            ##4.4.4 Si no estaba en el abierto, o si estaba pero el costo mejoró se pone en el abierto

    #5. Si el abierto queda vacío y no se encuentra un camino se regresa None
    return None


##TODO: Método construye_camino, metodo costo arista
def construye_camino():
    return None
def costo_arista():
    return 0.