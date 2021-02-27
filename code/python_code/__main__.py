import redes
from astar import *

if __name__ == '__main__':

    r = redes.Red()

    r.agrega_nodo('a',[0.,2.])
    r.agrega_nodo('b',[1.,0.])
    r.agrega_nodo('c',[0.,1.])
    r.agrega_nodo('d',[1.,1.])
    r.agrega_nodo('e',[0.,0.])
    r.agrega_nodo('f',[7.,2.])

    r.agrega_arista('a,c', 5., 1., 1)
    r.agrega_arista('c,d', 5., 1., 1)
    r.agrega_arista('d,b', 5., 1., 1)
    r.agrega_arista('b,a', 5., 2.236, 1)
    r.agrega_arista('d,e', 5., 1.4142, 1)
    r.agrega_arista('e,d', 5., 1.4142, 1)

    for v in r.nodos:
        print(v,r.nodos[v].vecinos)

    for par in r.aristas:
        print(par, r.aristas[par].capacidad)
    print('prueba en la red pequenia')
    result = A_star(r,tiempo_euclideano,'e','a')
    print(result)


    rc = redes.genera_red_cuadrada(3,[1.,0.,],1.,[2,0],mapa=True)
    for v in rc.nodos:
        print(v,rc.nodos[v].vecinos,rc.nodos[v].lugar)

    for par in rc.aristas:
        print(par, rc.aristas[par].max_vel, rc.aristas[par].longitud, rc.aristas[par].capacidad)
    print(rc.ismap)

    print('prueba en red cuadrada')
    result = A_star(rc,tiempo_euclideano,'0','6')
    print(result)