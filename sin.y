%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

extern int yylex();
void yyerror(const char *s);
extern FILE *yyin;

FILE *output;
char *output_code = NULL;  // Variable para almacenar el código generado

char* concat(const char* s1, const char* s2) {
    if (s1 == NULL) return strdup(s2);
    if (s2 == NULL) return strdup(s1);
    char* result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

char* wrap_with_indent(const char* code, int indent_level) {
    int indent_size = 4;
    int total_indent = indent_level * indent_size;
    size_t code_len = strlen(code);
    size_t result_size = code_len + total_indent * 20 + 1;  // Aumentar tamaño del buffer para múltiples líneas
    char* result = malloc(result_size);
    result[0] = '\0';  // Inicializar como cadena vacía

    const char* line_start = code;
    while (*line_start != '\0') {
        // Añadir indentación
        char* ptr = result + strlen(result);
        for (int i = 0; i < total_indent; i++) {
            *ptr++ = ' ';
        }
        *ptr = '\0';

        // Copiar línea hasta el siguiente '\n' o fin de cadena
        const char* line_end = strchr(line_start, '\n');
        if (line_end == NULL) {
            strcat(result, line_start);
            break;
        } else {
            strncat(result, line_start, line_end - line_start + 1);
            line_start = line_end + 1;
        }
    }

    return result;
}

int indent_level = 0;

%}

%union {
    int intval;
    char *strval;
}

%token <intval> NUMBER
%token <strval> IDENTIFIER
%token FOR WHILE IF ELSE PRINT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON ASSIGN
%token PLUS MINUS TIMES DIVIDE EQ
%token LT GT  // Agregar estos tokens

%type <strval> program stmt_list stmt expr

%left ELSE
%right ASSIGN
%left PLUS MINUS
%left TIMES DIVIDE
%left LT GT  // Definir la precedencia de los operadores de comparación

%%

program:
    stmt_list { 
        fprintf(stderr, "program -> stmt_list\n"); 
        output_code = $1;  // Guardar el código generado
    }
    ;

stmt_list:
    stmt_list stmt { 
        char *new_stmt_list = concat($1, $2);
        free($1);  // Liberar memoria previa
        free($2);
        $$ = new_stmt_list; 
        fprintf(stderr, "stmt_list -> stmt_list stmt: %s\n", $$); 
    }
    | stmt { $$ = $1; fprintf(stderr, "stmt_list -> stmt: %s\n", $$); }
    ;

stmt:
    expr SEMICOLON { 
        char *new_stmt = concat($1, ";\n");
        free($1);  // Liberar memoria previa
        $$ = new_stmt; 
        fprintf(stderr, "stmt -> expr SEMICOLON: %s\n", $$); 
    }
    | PRINT expr SEMICOLON { 
        char *print_stmt = concat("print(", concat($2, ");\n"));
        free($2);  // Liberar memoria previa
        $$ = print_stmt; 
        fprintf(stderr, "stmt -> PRINT expr SEMICOLON: %s\n", $$); 
    }
    | IF LPAREN expr RPAREN stmt %prec IF { 
        char *if_stmt = concat("if ", concat($3, ":\n"));
        indent_level++;
        char *wrapped_stmt = wrap_with_indent($5, indent_level);
        indent_level--;
        char *full_if_stmt = concat(if_stmt, wrapped_stmt);
        free($3);  // Liberar memoria previa
        free($5);
        free(if_stmt);
        free(wrapped_stmt);
        $$ = full_if_stmt;
        fprintf(stderr, "stmt -> IF LPAREN expr RPAREN stmt: %s\n", $$); 
    }
    | IF LPAREN expr RPAREN stmt ELSE stmt {
        char *if_stmt = concat("if ", concat($3, ":\n"));
        indent_level++;
        char *wrapped_if_stmt = wrap_with_indent($5, indent_level);
        indent_level--;
        char *else_stmt = wrap_with_indent("else:\n", indent_level);
        indent_level++;
        char *wrapped_else_stmt = wrap_with_indent($7, indent_level);
        indent_level--;
        char *full_if_else_stmt = concat(if_stmt, concat(wrapped_if_stmt, concat(else_stmt, wrapped_else_stmt)));
        free($3);  // Liberar memoria previa
        free($5);
        free($7);
        free(if_stmt);
        free(wrapped_if_stmt);
        free(else_stmt);
        free(wrapped_else_stmt);
        $$ = full_if_else_stmt;
        fprintf(stderr, "stmt -> IF LPAREN expr RPAREN stmt ELSE stmt: %s\n", $$);
    }
    | WHILE LPAREN expr RPAREN stmt { 
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
    | FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN stmt { 
        char *init_expr = $3;
        char *cond_expr = $5;
        char *update_expr = $7;
        char *loop_body = $9;

        char range_expr[256];
        snprintf(range_expr, sizeof(range_expr), "i in range(%s, %s, %s):\n", init_expr ? init_expr : "0", cond_expr, update_expr);

        char *for_stmt = concat("for ", concat(range_expr, loop_body));

        free(init_expr);
        free(cond_expr);
        free(update_expr);
        free(loop_body);

        $$ = for_stmt;
        fprintf(stderr, "stmt -> FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN stmt: %s\n", $$); 
    }
    | LBRACE stmt_list RBRACE { 
        indent_level++;
        char *wrapped_stmt_list = wrap_with_indent($2, indent_level);
        indent_level--;
        $$ = wrapped_stmt_list;
        free($2);  // Liberar memoria previa
        fprintf(stderr, "stmt -> LBRACE stmt_list RBRACE: %s\n", $$); 
    }
    ;

expr:
    IDENTIFIER ASSIGN expr { 
        char *assign_expr = concat($1, concat(" = ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = assign_expr; 
        fprintf(stderr, "expr -> IDENTIFIER ASSIGN expr: %s\n", $$); 
    }
    | expr PLUS expr { 
        char *plus_expr = concat($1, concat(" + ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = plus_expr; 
        fprintf(stderr, "expr -> expr PLUS expr: %s\n", $$); 
    }
    | expr MINUS expr { 
        char *minus_expr = concat($1, concat(" - ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = minus_expr; 
        fprintf(stderr, "expr -> expr MINUS expr: %s\n", $$); 
    }
    | expr TIMES expr { 
        char *times_expr = concat($1, concat(" * ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = times_expr; 
        fprintf(stderr, "expr -> expr TIMES expr: %s\n", $$); 
    }
    | expr DIVIDE expr { 
        char *divide_expr = concat($1, concat(" / ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = divide_expr; 
        fprintf(stderr, "expr -> expr DIVIDE expr: %s\n", $$); 
    }
    | expr EQ expr { 
        char *eq_expr = concat($1, concat(" == ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = eq_expr; 
        fprintf(stderr, "expr -> expr EQ expr: %s\n", $$); 
    }
    | expr LT expr {  // Agregar esta regla
        char *lt_expr = concat($1, concat(" < ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = lt_expr; 
        fprintf(stderr, "expr -> expr LT expr: %s\n", $$); 
    }
    | expr GT expr {  // Agregar esta regla si también usas '>'
        char *gt_expr = concat($1, concat(" > ", $3));
        free($1);  // Liberar memoria previa
        free($3);
        $$ = gt_expr; 
        fprintf(stderr, "expr -> expr GT expr: %s\n", $$); 
    }
    | LPAREN expr RPAREN { 
        char *paren_expr = concat("(", concat($2, ")"));
        free($2);  // Liberar memoria previa
        $$ = paren_expr; 
        fprintf(stderr, "expr -> LPAREN expr RPAREN: %s\n", $$); 
    }
    | NUMBER { 
        char buffer[32];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
        fprintf(stderr, "expr -> NUMBER: %s\n", $$); 
    }
    | IDENTIFIER { 
        $$ = strdup($1); 
        fprintf(stderr, "expr -> IDENTIFIER: %s\n", $$); 
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }

    yyparse();

    if (output_code) {
        output = fopen("output.py", "w");
        if (output) {
            fprintf(output, "%s", output_code);
            fclose(output);
        } else {
            fprintf(stderr, "Could not open output file\n");
        }

        // Mostrar el contenido de output_code en la terminal
        printf("---------------------------------\n");
        printf("%s", output_code);
        printf("---------------------------------\n");

        // Ejecutar el código traducido directamente
        printf("Ejecutando el codigo generado...\n");
        FILE *p = popen("python3 -", "w");
        if (p == NULL) {
            fprintf(stderr, "Could not execute python3\n");
        } else {
            fprintf(p, "%s", output_code);
            int status = pclose(p);
            if (status == -1) {
                fprintf(stderr, "Error closing the pipe\n");
            } else {
                printf("Python script executed with status: %d\n", status);
            }
        }
    }

    return 0;
}
