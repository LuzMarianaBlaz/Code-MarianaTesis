import redes

if __name__ == '__main__':

    r = redes.Red()

    r._agrega_nodo('a')
    r._agrega_nodo('b')
    r._agrega_nodo('c')
    r._agrega_nodo('d')
    r._agrega_nodo('e')
    r._agrega_nodo('f')

    r._agrega_arista('a,c', 5., 7., 3)
    r._agrega_arista('c,d', 5., 7., 4)
    r._agrega_arista('d,b', 5., 7., 2)
    r._agrega_arista('b,a', 5., 7., 1)
    r._agrega_arista('d,e', 5., 7., 6)
    r._agrega_arista('e,d', 5., 7., 2)

    for v in r.nodos:
        print(v,r.nodos[v].vecinos)

    for par in r.aristas:
        print(par, r.aristas[par].capacidad)

    rc = redes.genera_red_cuadrada(2,[12.,0.,],[1.,0.],[13,4])
    for v in rc.nodos:
        print(v,rc.nodos[v].vecinos)

    for par in rc.aristas:
        print(par, rc.aristas[par].max_vel, rc.aristas[par].longitud, rc.aristas[par].capacidad)
