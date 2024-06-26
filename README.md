# ACT_CompiladorPython_VIU58GIIN
Actividad 2: Desarrollar un compilador. Asignatura 58GIIN - Estrategias Algorítmicas de la Universidad Internacional de Valencia.

## Enunciado de la actividad
Desarrollar un compilador que traduzca instrucciones de un lenguaje fuente simple a uno de tres posibles lenguajes objetivo: C, Java o Python. Los lenguajes objetivo serán asignados aleatoriamente a los alumnos de la siguiente lista:

- Martín Alejandro Castro Álvarez  // Compilador lenguaje Python
- Miguel Ángel Gagliardo // Compilador lenguaje Java
- Amisadai Martel Suárez // Compilador lenguaje C
- José Vicente Martí Olmos // Compilador lenguaje C
- Tomás Martínez Guido // Compilador lenguaje Python
- Alejandro Navarro Arroyo // Compilador lenguaje Java 
- Miguel Solé González // Compilador lenguaje Python
- Jordi Vicens Farrus// Compilador lenguaje C 

1. Definición de la gramática del lenguaje fuente. Deberá incluir operaciones básicas y estructuras de control.
2. Creación de reglas léxicas utilizando Flex, seguidas por la definición de la gramática del lenguaje fuente con Bison, incorporando las acciones semánticas para la traducción al lenguaje objetivo.
3. Generación de código para el lenguaje objetivo asignado, manteniendo la fidelidad a la sintaxis y paradigmas de dicho lenguaje.
4. Redacción de casos de prueba y documentación del proceso de desarrollo, incluyendo las decisiones de diseño.
5. El proyecto debe ser compartido a través de GitHub, conteniendo todo el código fuente y la documentación correspondiente. Un archivo README.md deberá explicar cómo ejecutar el compilador y los casos de prueba.

**Criterios de evaluación**: Se evaluará la gramática y reglas léxicas, la implementación de la generación de código, la calidad de los casos de prueba y la documentación proporcionada.

## Descripcion
Este proyecto es un compilador que traduce un lenguaje fuente simple a Python. Utiliza `Flex` para el análisis léxico y `Bison` para el análisis sintáctico y la generación de código. El objetivo es transformar un conjunto de instrucciones en un lenguaje propio a un código Python funcional. Para más información ver [DOCUMENTACION](./DOCUMENTACION.md).

## Casos de Prueba
Se han diseñado varios casos de prueba para comprobar el funcionamiento del compilador. Estos casos cubren diferentes aspectos del lenguaje fuente, incluyendo asignaciones, operaciones aritméticas, estructuras de control y bucles. El lenguaje fuente simple utilizado tiene el siguiente formato: 
```shell
x = 1;
y = 2;
if (x == 1) {
    if (y == 2) {
        print 100;
    } else {
        print 200;
    }
} else {
    print 300;
}
```
## Instrucciones de Ejecución
Para compilar el programa, utilizamos las siguientes instrucciones:
```shell
$ flex lex.l
$ bison -d sin.y
$ gcc -o run lex.yy.c sin.tab.c -lm
```
luego, para ejecutar el compilador:
```shell
$ ./run < testeos/test1.c
```
Si se desea ejecutar el **output.py** por separado:
```shell
$ python3 output.py
```
El repositorio cuenta con otra opción más práctica que es utilizar el **Makefile**, para ello es necesario contar con un bash o Linux:
```shell
$ make
```
si se desea ejecutar un test específico, se debe cambiar desde el **Makefile**:
```shell
run:
	./run < testeos/test1.c

//Comando para ejecutar el compilador con el test especifico
$ make run
```
Para eliminar los archivos creados tras la compilación del programa, se puede realizar el siguiente comando:
```shell
$ make clean
```
