from . import redes

if __name__ == '__main__':

    r = redes.Red()

    r.agrega_vertice('a')
    r.agrega_vertice('b')
    r.agrega_vertice('c')
    r.agrega_vertice('d')
    r.agrega_vertice('e')
    r.agrega_vertice('f')

    r.agrega_arista('a,c', 5., 7., 3)
    r.agrega_arista('c,d', 5., 7., 4)
    r.agrega_arista('d,b', 5., 7., 2)
    r.agrega_arista('b,a', 5., 7., 1)
    r.agrega_arista('d,e', 5., 7., 6)
    r.agrega_arista('e,d', 5., 7., 2)

    for v in r.nodos:
        print(r.nodos[v].vecinos)

    for par in r.aristas:
        print(r.aristas[par].capacidad)