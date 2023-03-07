%{

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

extern int nLineas;
int nErrores = 0;

FILE *yyin;
FILE *yyout;
FILE *yyoutc;
void yyerror(const char* msg) {
    fprintf(yyoutc, "\nLinea: %d - %s", nLineas, msg);
    nErrores++;
}
int yylex(void);

struct simbolo 
{
	char nombre[30];
	int tipo; // int 1 | float 2 | char 3 | string 4 | boolean 5
	int cte; // si 1 | no 0
	int init; // si 1 | no 0
	struct simbolo *sig;
};
struct simbolo *tablaSim = NULL;
struct simbolo *simUlt = NULL;

struct simbolo* buscarSimbolo(struct simbolo *tablaSim, char nombre[30]);
void insertarSimbolo(char nombre[30], int tipo, int cte, int init);
void declararTipo( int tipo);
void errorIncremento(char nombre[30]);

%}
%union{
	char nombre[30];
	int tipo;
}


/*define los tokens*/
%token COMENTARIO
%token <nombre> ID
%token DEFINE
%token MAIN
%token <tipo> NUM
%token <tipo> CADENA
%token <tipo> CARACTER
%token <tipo> BOOLVAL
%token <tipo> INT
%token <tipo> FLOAT
%token <tipo> CHAR
%token <tipo> STRING
%token <tipo> BOOLEAN
%type <tipo> cte
%type <tipo> tipo
%type <tipo> expresion
%token PRINTF
%token SCANF
%token ELSE
%token IF
%token SWITCH
%token CASE
%token BREAK
%token WHILE
%token FOR

%left '+' '-'
%left '*' '/'
%left UNARIO


%%
programa:	declaracionesCtes declaracionesVariables MAIN '(' ')' '{' declaracionesVariables instrucciones '}'
 
;
declaracionesCtes: /*vacia*/
                  | declaracionCte declaracionesCtes
;
declaracionCte: '#' DEFINE ID cte {
				        fprintf(yyout,"\nDeclaracion cte");
	      				
					insertarSimbolo($3, $4, 1, 1);
	      			  }
	      | COMENTARIO                               
	      | error { yyerror("Error: En declaracion de constantes.");}
;
cte: NUM { $$ = $1; }
   | CADENA { $$ = $1; }
   | CARACTER { $$ = $1; }
   | BOOLVAL { $$ = $1; }
;



declaracionesVariables: /*vacia*/
		      |  declaracionesVariable declaracionesVariables
;
declaracionesVariable: tipo IDs ';' {
		     			fprintf(yyout,"\nDeclaracion variable");
					declararTipo($1);

				   }
		     | COMENTARIO
	  	     | error { yyerror("Error: En declaracion de variables.");}
;

IDs: IDs ',' IDs
   | ID { insertarSimbolo ($1, 0, 0, 0); }   
   | ID '=' cte { insertarSimbolo($1, $3 * (-1), 0, 1); }
;
tipo: INT { $$ = $1; }
    | FLOAT { $$ = $1; }
    | CHAR { $$ = $1; }
    | STRING { $$ = $1; }
    | BOOLEAN { $$ = $1; }
;



instrucciones: /*vacia*/
	    | instruccion instrucciones
;
instruccion: asignacion {fprintf(yyout,"\n Instruccion asignacion");}
	   | visualizacion {fprintf(yyout,"\n Instruccion visualizacion");}
	   | lectura {fprintf(yyout,"\n Instruccion lectura");}
	   | incremento {fprintf(yyout,"\n Instruccion incremento");}
	   | condicional {fprintf(yyout,"\n Instruccion condicional");}
	   | repetitiva {fprintf(yyout,"\n Instruccion repetitiva");}
	   | COMENTARIO
 	   | error  { yyerror("Error: En una instrucción.");}
;

asignacion: ID '=' expresion ';' {
				       struct simbolo* pos = buscarSimbolo(tablaSim, $1);
					if(pos == NULL)
					{
   					     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no declarado",nLineas+1, $1); 
					     nErrores++;
					} 
					else if(pos->cte == 1)
					{
   					     	fprintf(yyoutc,"\nERROR: linea %d: Constante %s no modificable",nLineas+1, $1); 
					     nErrores++;
					}
					else
					{       
						if(pos->tipo == $3)
							pos->init = 1;
						else
						{
   					     		fprintf(yyoutc,"\nERROR: linea %d: Identificador de distinto tipo",nLineas+1); 
					     		nErrores++;
						}
					}
	      			 } 
;
expresion: ID {
				       struct simbolo* pos = buscarSimbolo(tablaSim, $1);
					if(pos == NULL)
					{
   					     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no declarado",nLineas+1, $1); 
					     nErrores++;
					}    
					else
					{       if (pos->init == 0)
					        {
   					              fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no inicializado",nLineas+1, $1); 
					              nErrores++;
					        }	
						$$ = pos->tipo;
					}
	      } 
	 | cte  { $$ = $1; }
	 | expresion operador expresion {
					if($1 > 2 && $3 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",nLineas+1); 
					    nErrores++;
					}
						 $$ = $1;
					}
	 | '(' expresion ')' {
					if($2 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",nLineas+1); 
					    nErrores++;
					}
						 $$ = $2;
				}
	 | '-' expresion  %prec UNARIO  {
					if($2 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",nLineas+1); 
					    nErrores++;
					}
						$$ = $2;
					 }
;
operador: '+' | '-' | '*' | '/'
;

visualizacion: PRINTF '(' visualizado ')' ';' 
;
visualizado: expresion
	   | expresion ',' visualizado
;

lectura: SCANF '(' ID ')' ';' {
				       struct simbolo* pos = buscarSimbolo(tablaSim, $3);
					if(pos == NULL)
					{
   					     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no declarado",nLineas+1, $3); 
					     nErrores++;
					} 
					else if(pos->cte == 1)
					{
   					     	fprintf(yyoutc,"\nERROR: linea %d: Constante %s no modificable",nLineas+1, $3); 
					     nErrores++;
					}
					else
					{
						pos->init = 1;
					}
			      }	
;

incremento: ID '+' '+' ';' {
				errorIncremento($1);
	        	   } 
	  | ID '-' '-' ';' {
				errorIncremento($1);
	        	   } 
;

condicional: IF '(' expbool ')' '{' instrucciones '}' ELSE '{' instrucciones '}'
	   | IF '(' expbool ')' '{' instrucciones '}' 
	   | SWITCH '(' ID ')' '{' cases '}'
;

cases: CASE cte ':' instruccion BREAK ';' 
     | CASE cte ':' instruccion BREAK ';' cases 
;

expbool: expresion {fprintf(yyout,"\n Instruccion comparacion");}
	| '(' expbool ')' {fprintf(yyout,"\n Instruccion comparacion");}
	| '!' expresion {fprintf(yyout,"\n Instruccion comparacion");} 
	| expresion igualacion expresion {
						fprintf(yyout,"\n Instruccion comparacion");
						if($1 != $3 && ($1 > 2 || $3 >2))
						{
   					     		fprintf(yyoutc,"\nERROR: linea %d: Expresiones de distinto tipo",nLineas+1); 
							nErrores++;
						}
					 } 
	| expbool '|' '|' expbool  {fprintf(yyout,"\n Instruccion comparacion");}
	| expbool '&' '&' expbool {fprintf(yyout,"\n Instruccion comparacion");}
;
igualacion: '=' '=' | '!' '=' | '<' '=' | '<' | '>' '=' | '>'
;

repetitiva: WHILE '(' expbool ')' '{' instrucciones '}' 
	  | FOR '(' expresion ';' expbool ';' expresion ')' '{' instrucciones '}'
;

%%

int main()
{
	yyin=fopen("ejemplo.c","r");
	yyoutc=fopen("salida.txt","w");
	yyout=fopen("salidacompleta.txt","w");
	// Comprobamos los posibles errores del fichero de lectura.
	if(yyin == NULL )
	{
		printf("ERROR DE APERTURA DEL FICHERO DE LECTURA\n");
		return 0;
	}
	// Comprobamos los posibles errores del fichero de escritura
	if(yyout == NULL )
	{
		printf("ERROR DE APERTURA DEL FICHERO DE ESCRITURA\n");
		return 0;
	}
	if(yyoutc == NULL )
	{
		printf("ERROR DE APERTURA DEL FICHERO DE ESCRITURA COMPLETA\n");
		return 0;
	}
	yyparse();
	fprintf(yyout,"\n Numero de lineas: %d",nLineas);
	if(nErrores == 0)
	{
		fprintf(yyoutc,"\n Todo correcto numero de lineas: %d",nLineas);
		printf("\n Todo correcto numero de lineas: %d\n",nLineas);
	}
	else
	{
		fprintf(yyoutc,"\nNumero de errores semanticos: %d",nErrores);
		printf("\nNumero de errores semanticos: %d\n",nErrores);
	}

}
struct simbolo* buscarSimbolo(struct simbolo *tablaSim, char nombre[30])
{
	struct simbolo *this = tablaSim;
	
	if(this == NULL)
	{
		return NULL;
	}
	while(this != NULL)
	{
		if(strcmp(this->nombre, nombre) == 0)
			return this;
		this = this->sig;
	}
	return NULL;
}


void insertarSimbolo(char nombre[30], int tipo, int cte, int init)
{
	  struct simbolo* pos = buscarSimbolo(tablaSim, nombre);
	  if(pos != NULL)
	  {
   	       fprintf(yyoutc,"\nERROR: linea %d: Identificador %s redeclarado",nLineas+1, nombre); 
	       nErrores++;
	  } 
	  else
	  {
	  	struct simbolo *tmp;
	  	tmp = (struct simbolo*) malloc(sizeof(struct simbolo));
	  	strcpy(tmp->nombre, nombre);
	  	tmp->tipo = tipo;
	  	tmp->cte = cte;
	  	tmp->init = init;
	  	tmp->sig = NULL;

	  	if(tablaSim == NULL)
	  	{
	  		tablaSim = tmp;         
	  		simUlt = tmp;
	  	} 
	  	else
	  	{		
	  	       simUlt->sig = tmp;
	  	       simUlt = tmp;
	  	}
	  	
	  }
}


void errorIncremento(char nombre[30])
{
	     struct simbolo* pos = buscarSimbolo(tablaSim, nombre);
	      if(pos == NULL)
	      {
   	           fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no declarado",nLineas+1, nombre); 
	           nErrores++;
	      } 
	      else if(pos->tipo > 2)
	      {
   	             fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no numerico",nLineas+1,nombre); 
	           nErrores++;
	      }
	      else if(pos->init == 0)
	      {
   	           fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no inicializado",nLineas+1, nombre); 
	           nErrores++;
	      }
}


void declararTipo( int tipo)
{
	struct simbolo *this = tablaSim;
	
	if(this == NULL)
	{
		return;
	}
	while(this != NULL)
	{
		if( this->tipo <= 0)
		{
			if(this->tipo * (-1) != tipo && this->init == 1)
			{
   				fprintf(yyoutc,"\nERROR: linea %d: Valor de distinto tipo",nLineas+1); 
				nErrores++;
			}
			this->tipo = tipo;
		}
		this = this->sig;
	}
}

