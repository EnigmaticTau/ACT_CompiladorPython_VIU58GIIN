# Documentación del proceso de desarrollo y diseño del programa

## Introducción
Este documento describe el proceso de desarrollo y diseño del compilador que traduce un lenguaje fuente simple a Python. Se abordarán las decisiones de diseño, la implementación de las reglas léxicas y sintácticas, así como la generación de código y las pruebas realizadas.
## Definición de la Gramática del Lenguaje Fuente
El lenguaje fuente aceptado por este compilador se define mediante el siguiente `eBNF` (Extended Backus–Naur Form):

```shell
program          ::= stmt_list

stmt_list        ::= stmt ';' stmt_list 
                   | stmt

stmt             ::= expr 
                   | 'print' expr ';'
                   | 'if' '(' expr ')' stmt ('else' stmt)? 
                   | 'while' '(' expr ')' stmt 
                   | 'for' '(' expr ';' expr ';' expr ')' stmt 
                   | '{' stmt_list '}'

expr             ::= IDENTIFIER '=' expr 
                   | expr ('+' | '-' | '*' | '/' | '==' | '!=' | '<=' | '>=' | '<' | '>') expr 
                   | expr ('and' | 'or') expr
                   | 'not' expr
                   | '(' expr ')' 
                   | NUMBER 
                   | IDENTIFIER

```

## Decisiones de Diseño
- Se simplificó el uso de `in range()` imprimiéndolo desde la regla `for` debido a complicaciones con el programa.
- Se implementó la estructura base `IF-ELSE`.
### El programa admite las siguientes características
- **Tipos de datos**: El compilador admite diversos tipos de datos como enteros, flotantes, cadenas de texto y booleanos.
- **Estructuras de control**: Se incluyen estructuras de control como condicionales (`if`, `else`), bucles (`for`, `while`) y funciones como `print`.
- **Operadores**: Soporta operadores aritméticos (`+`, `-`, `*`, `/`), lógicos (`or`, `and`, `not`) y de comparación (`==`, `!=`, `<`, `>`, `<=`, `>=`). 
### Mantenimiento de la Indentación
- Función `wrap_with_indent`: Para manejar la indentación en estructuras de control anidadas (como `if`, `while`, y `for`), se implementó la función `wrap_with_indent`, que ajusta el nivel de indentación de las líneas de código generadas, asegurando que el código Python resultante sea válido y legible.
### Output
Para una mejor visualización de los resultados del programa, se empleó la utilización de un archivo `output.py`, el flujo del archivo es el siguiente:
- El código generado a partir del análisis sintáctico se almacena en la variable `output_code`.
- Una vez finalizado el análisis, el contenido de `output_code` se escribe en el archivo `output.py`. Esto se hace para persistir el código generado y facilitar su ejecución.
- El código generado se imprime en la consola. Esto se realiza utilizando las funciones `printf` y `fprintf`.
- Se utiliza la función `popen` para ejecutar el código generado directamente en un intérprete de Python (`python3`) y imprimir por consola el resultado del codigo traducido.
 
## Implementación
### Análisis Léxico
El análisis léxico se implementó utilizando Flex. Se definieron patrones para reconocer identificadores, números, palabras clave y operadores. Los tokens reconocidos son devueltos a Bison para el análisis sintáctico. Pueden acceder a las definiciones de tokens en [lex.l](./lex.l).
### Análisis Sintáctico y Generación de Código
El análisis sintáctico y la generación de código se implementaron con Bison. Las reglas gramaticales definieron cómo se estructuran las instrucciones del lenguaje fuente y cómo se traducen al código Python. Pueden acceder a las reglas que describen la estructura sintáctica desde [sin.y](./sin.y)
### Ejemplo de Traducción
Para una estructura de control como un bucle while, la acción semántica maneja la indentación `*wrapped_stmt` y la traducción al código Python `*while_stmt`:
```shell
stmt:
    WHILE LPAREN expr RPAREN stmt { 
        char *while_stmt = concat("while ", concat($3, ":\n"));
        indent_level++;
        char *wrapped_stmt = wrap_with_indent($5, indent_level);
        indent_level--;
        char *full_while_stmt = concat(while_stmt, wrapped_stmt);
        free($3);  // Liberar memoria previa
        free($5);
        free(while_stmt);
        free(wrapped_stmt);
        $$ = full_while_stmt;
        fprintf(stderr, "stmt -> WHILE LPAREN expr RPAREN stmt: %s\n", $$); 
    }

```

## Pruebas y Validación
### Casos de Prueba
Se desarrollaron múltiples casos de prueba para validar la funcionalidad del compilador. Los casos de prueba incluyen:
  1. **Asignaciones Simples**: Validar la traducción de asignaciones simples.
  2. **Estructuras de Control**: Probar la correcta traducción de estructuras de control como `if`, `while`, y `for`.
  3. **Operaciones Aritméticas y Comparativas**: Verificar la traducción de expresiones aritméticas y comparativas.
### Ejemplo de Caso de Prueba
Archivo de entrada `test1.c`:
```shell
x = 10;
y = 20;
if (x < y) {
    print 1;
} else {
    print 2;
}
```
Salida esperada `output.py`:
```shell
x = 10
y = 20
if x < y:
    print(1)
else:
    print(2)

```
