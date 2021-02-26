import redes

if __name__ == '__main__':

    r = redes.Red()

    r.agrega_nodo('a')
    r.agrega_nodo('b')
    r.agrega_nodo('c')
    r.agrega_nodo('d')
    r.agrega_nodo('e')
    r.agrega_nodo('f')

    r.agrega_arista('a,c', 5., 7., 3)
    r.agrega_arista('c,d', 5., 7., 4)
    r.agrega_arista('d,b', 5., 7., 2)
    r.agrega_arista('b,a', 5., 7., 1)
    r.agrega_arista('d,e', 5., 7., 6)
    r.agrega_arista('e,d', 5., 7., 2)

    for v in r.nodos:
        print(v,r.nodos[v].vecinos)

    for par in r.aristas:
        print(par, r.aristas[par].capacidad)

    rc = redes.genera_red_cuadrada(3,[12.,0.,],1.,[13,4],mapa=True)
    for v in rc.nodos:
        print(v,rc.nodos[v].vecinos,rc.nodos[v].lugar)

    for par in rc.aristas:
        print(par, rc.aristas[par].max_vel, rc.aristas[par].longitud, rc.aristas[par].capacidad)
    print(rc.ismap)

    #TODO: Pruebas del algoritmo base