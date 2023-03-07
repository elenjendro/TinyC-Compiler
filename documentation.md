**Hecho por: Juan Vázquez López y Alejandro Prieto Ramírez.**

# Zona de C:

En la zona de C definiremos el código C que debe estar implementado antes del análisis sintáctico.

Empezamos declarando las librerias necesarias.

```c

	%{

	#include <string.h>
	#include <stdlib.h>
	#include <stdio.h>

```

Así declaramos e inicializamos las variables contador.

- nLinea
: una variable contador para llevar la cuenta del número de lineas. Al provenir del lexico esta variable ya esta inicializada.
- nErrores
: una contador que lleva la cuenta del número de errores.

```c

	extern int nLineas;
	int nErrores = 0;

```
Seguimos definiendo los ficheros a utilizar. Cabe destacar los siguientes ficheros:

- yyout
: registrara los datos que hemos utilizado durante el desarrollo para comprobar el funcionamiento en el fichero salidacompleta.txt.
- yyoutc
: este por otro lado registrara los mensajes de error en un fichero salida.txt.

```c      

	FILE *yyin;
	FILE *yyout;
	FILE *yyoutc;

```
Después implementamos las funcionalidades del análisis definiendo:

- yyerror
: que recibirá un mensaje de error, imprimiendolo junto con la linea en que esta. Además sumara uno a el numero de errores totales. 

```c

	void yyerror(const char* msg) {
	    fprintf(yyoutc, "\nLinea: %d - %s", nLineas, msg);
	    nErrores++;
	}
	int yylex(void);

```

Por otro lado tendremos que definir la estructura de nuestra tabla de símbolos. Para definir la estructura decidimos utilizar listas enlazadas. 
Cada elemento se compondra de:

- nombre
: Almacenamos el nombre del símbolo.
- tipo
: Almacena los siguientes valores en función de su tipo: int 1 , float 2 , char 3 , string 4 , boolean 5.
- cte
: Indica si es contante (1) o si no lo es (1).
- init
: Indica si eestá inicializado (1) o si no lo está (1).
- sig
: Un puntero que apunta al siguiente elemento.

Para almacenar nuestra tabla de símbolos tendremos:

- tablasSim
: que será un puntero que apunte al primer elemento de nuestra lista.
- simUlt
: otro puntero que apunta al último de la lista.

Por último declaramos la estructura de la función buscarSimbolo() que comprobará si un símbolo se encuentra en la tabla devolviendolo si está y así poder hacer los tratamientos requeridos.

```c

	struct simbolo 
	{
		char nombre[30];
		int tipo; // int 1 | float 2 | char 3 | string 4| boolean 5
		int cte; // si 1 | no 0
		int init; // si 1 | no 0
		struct simbolo *sig;
	};
	struct simbolo *tablaSim = NULL;
	struct simbolo *simUlt = NULL;

	struct simbolo* buscarSimbolo(struct simbolo *tablaSim, char nombre[30]);

	%}

```



# Zona de Definiciones:

## Sintáctico:

### Tokens:

- COMENTARIO
: reconoce los comentarios.
- ID
: reconoce los identificadores.
- DEFINE
: reconoce la palabre define.
- MAIN
: reconoce la palabra main.
- NUM
: reconoce los números.
- CADENA
: reconoce las cadenas.
- CARACTER
: reconoce los caracteres.
- BOOLVAL
: reconoce la palabra reservada true o false.
- INT
: reconoce la palabra reservada int.
- FLOAT
: reconoce la palabra reservada float.
- CHAR
: reconoce la palabra reservada char.
- STRING
: reconoce la palabra reservada string.
- BOOLEAN
: reconoce la palabra reservada bool.
- PRINTF
: reconoce la palabra reservada printf.
- SCANF
: reconoce la palabra reservada scanf.
- ELSE
: reconoce la palabra else.
- IF
: reconoce la palabra if.
- WHILE
: reconoce la palabra while.

```c

	/*define los tokens*/
	%token COMENTARIO
	%token ID
	%token DEFINE
	%token MAIN
	%token NUM
	%token CADENA
	%token CARACTER
	%token BOOLVAL
	%token INT
	%token FLOAT
	%token CHAR
	%token STRING
	%token BOOLEAN
	%token PRINTF
	%token SCANF
	%token ELSE
	%token IF
	%token WHILE

```


### Aclaraciones de preferencia:

Por otro lado definimos que la multiplicación y división sean preferentes a la suma y la resta y que la aparición individual sobre todos(de esta forma podremos controlar los casos en lso que un elemento es precedidido por -).

```c

	%left '+' '-'
	%left '*' '/'
	%left UNARIO

```


## Semántico:

Esta misma sección de codigo desde el punto de vista semántico contiene un union que definirá los tipos de los posibles valores a tomar por  yylval.
```c

	%}
	%union{
		char nombre[30];
		int tipo;
	}

```
Si analizamos los tokens desde el punto de vista semántico estos ahora recibirán una definición del tipo de valor que pueden tomar segun el union anterior. asi ID su valor sera del tipo <nombre> mientras que num sera del tipo <tipo>. 
Ademas debemos añadir ciertos type que definirán el tipo de valor que toma un símbolo no terminal.
```c

	%token <nombre> ID
	%token <tipo> NUM

	%type <tipo> cte

```

# Zona de Reglas:

##  Sintáctico:`

### Programa:

La gramática que reconoce nuestro análisis sintáctico reconoce este símbolo como el inicial. El símbolo
programa a su vez nos lleva a la siguiente estructura: 

```

    programa: declaracionesCtes declaracionesVariables MAIN '(' ')' '{'
declaracionesVariables instrucciones '}'
    
```

### Declaración De Constantes:

- declarionesCtes 
: que es un símbolo invocado por programa y puede resultar en que se encuentre vacio o declaracionCte declaracionesCtes

- declaracionCte
: símbolo invocado por por declaracionesCtes y puede seguir la siguiente estructura  _'#'_ seguido de los tokens _DEFINE ID_ vistos anteriormente y el token _cte_  que veremos en el siguiente apartado.
: Además podemos encontrar un comentario o puede ser que de un error.

- cte
: símbolo invocado por declaracionCte que puede ser un número una cadena o un caracter o un valor booleano.



```c

	declaracionesCtes: /* empty */
			 | declaracionCte declaracionesCtes

	declaracionCte: '#' DEFINE ID cte
		      | COMENTARIO
		      | error

	cte: NUM
	   | CADENA
	   | CARACTER
	   | BOOLVAL

```

### Declaración De Variables

- declaracionesVariables 
: que es un símbolo invocado por program y puede estar vacío o declaracionesVariable declaracionesVariables.

- declaracionesVariable
: es un símbolo invocado por declaracionesVariables y puede seguir la siguiente estructura _tipo_ que explicaremos en el siguiente apartado seguido del token _IDs ;_.
: Además podemos encontrar un comentario o puede que de un error.

- tipo
: es un símbolo invocado por declaracionesVariable y nos indica que el _ID_ puede ser un _INT_ o un _FLOAT_. 

- IDs
: Este simbolo agrupa las apariciones de _ID_ o _ID = cte_ o la aparición de combinaciones de las anteriores separadas por coma.

```c

	declaracionesVariables: /* empty */
			      | declaracionesVariable declaracionesVariables

	declaracionesVariable: tipo IDs ';'
			     | COMENTARIO
			     | error

	IDs: IDs ',' IDs
	   | ID
	   | ID '=' cte

	tipo: INT
	    | FLOAT
	    | CHAR
	    | STRING
	    | BOOLEAN

```

### Instrucciones:

- instrucciones
: es un símbolo invocado por program y puede estar vacío o contener instruccion instrucciones.

- instruccion
: es un símbolo invocado por instrucciones y define todos los tipos de instrucción reconocidos por el programa , un comentario o un tipo de error.

```c

	instrucciones: /* empty */
		     | instruccion instrucciones

	instruccion: asignacion
		   | visualizacion
		   | lectura
		   | incremento
		   | condicional
		   | repetitiva
		   | COMENTARIO
		   | error

```

#### Asignación:

- Esta intrucción sigue el esquema: primero el token _ID_ luego un _=_ luego el símbolo _expresion ;_

```c

	asignacion: ID '=' expresion ';'

```

#### Visualizacion:

- Esta instrución sigue el esquema: primero el token _PRINTF_ , luego entre paréntesis el símbolo _visualizado_ y por último _,_.

- Visualizado 
: es un símbolo invocado por visualizacion que puede llevar el token expresion o combinaciones de este separados por coma.
 
   
```c

	visualizacion: PRINTF '(' visualizado ')' ';'

	visualizado: expresion
		   | expresion ',' visualizado
   
```

#### Lectura:

- La instrución lectura sigue le sigiente esquema: primero el token _SCANF_ luego entre paréntesis encontramos el token _ID_ que hace referencia al elemento que afecta scanf y por último un _;_.

```c

	lectura: SCANF '(' ID ')' ';'
   
```

#### Incremento: 

- La instrcucción incremento sigue el esquema: primero el token _ID_  seguido de _++_ o _--_ haciendo esto referencia a si incrementamos o disminuimos en 1 el contenido del token _ID_.

```c

	incremento: ID '+' '+' ';'
		  | ID '-' '-' ';'

```

#### Instrucción Condicional:

- La instrucción condicional puede ser un token _IF_ seguido de una _expbool_  de las _instrucciones_  el con o sin el token _ELSE_. Además puede ser un _SWITCH_  llamando a un _ID_ entre paréntesis y a _CASES_ entre corchetes.

- CASES
: puede ser un _CASE_ seguido de _ctei : instruccion BREAK ;_ y la repetición de mas _CASES_.

- expbool
: es un símbolo invocado por la instrucción condicional que puede ser un _expresion_ , otra expbool , una expresión precedido por distinto o entre paréntesis, la igualación de dos expresiones o dos expbool con un operador _and_ o _or_. 

- igualación 
: reconoce las combinaciones de los operadores _=><!_.

```c

	condicional: IF '(' expbool ')' '{' instrucciones '}' ELSE '{' instrucciones '}'
				| IF '(' expbool ')' '{' instrucciones '}'
				| SWITCH '(' ID ')' '{' cases '}'

	cases: CASE cte ':' instruccion BREAK ';' 
	     | CASE cte ':' instruccion BREAK ';' cases 


	expbool: expresion
	       | '(' expbool ')'
	       | '!' expresion
	       | expresion igualacion expresion
	       | expbool '|' '|' expbool
	       | expbool '&' '&' expbool

	igualacion: '=' '='
		  | '!' '='
		  | '<' '='
		  | '<'
		  | '>' '='
		  | '>'

```
#### Instrcución repetitiva :

- La instrucción repetitiva sigue un esquema parecido al de la condicional. En este empezamos con el token _WHILE_ y luego como en el if una expbool seguida de sus instrcuccines. O bien un _FOR_.
  
```c

	repetitiva: WHILE '(' expbool ')' '{' instrucciones '}'
			  | FOR '(' expresion ';' expbool ';' expresion ')' '{' instrucciones '}'

```
#### Elemento expresion

- El símbolo expresión pueder hacer referencia al token _ID_ o al token _cte_ , además puede ser un conjunto con la estructuctura _expresion operador_ expresion y una expresion entre paréntesis o precedida por un menos.

- operador

: este símbolo es llamado por expresión y engloba los caracteres de suma, resta, multiplicación y división.

```c

	expresion: ID
			| cte
			| expresion operador expresion
			| '(' expresion ')'
			| '-' expresion

	operador: '+'
			| '-'
			| '*'
			| '/'

```

## Semántica:

### buscarSimbolo:

- A esta fucnión le pasamos la tabla de símbolos  y el nombre que queremos buscar. A mayores declaramos una variable this que tomará la posición actual de la lista. 
- Para empezar a recorrer debemos comprobar que la tabla no está vacía si este es el caso devolveremos _null_ ; si no mientras la posición actual no sea nula recorrerenmos la lista comprobando que el nomre de la posición en la que nos encontramos no coincida con el nombre que recibimos como parámetro. En el caso de que los nombres coincidan devolvemos el elemento y si no devolveremos _null_.

```c

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

```

### insertarSimbolo:

- A esta fucnción le pasamos el nombre del objeto que queremos insertar, el tipo del elemento , y dos variables una para saber si es una constante y la otra nos indicca si está inicializado. A mayores llamamos dentro a la función buscarSimbolo y guardamos su resultado en una variable a la que llamamos _pos_. 
- Si _pos_ es distinto de nulo indica que no está declarado (incrementamos el uno el contador de errores).
- Si _pos_ es nulo creamos un nuevo símbolo que reserva en memoria un espacio y almacena en el los nuevos datos, luego modificamos los punteros de la lista para que apunten al nuevo elemento

```c

	void insertarSimbolo(char nombre[30], int tipo, int cte, int init)
	{
		  struct simbolo* pos = buscarSimbolo(tablaSim, nombre);
		  if(pos != NULL)
		  {
		       fprintf(yyoutc,"\nERROR: linea %d: Identificador %s redeclarado",
nLineas+1, nombre); 
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

```

### declararTipo:

- Esta función es utilizada a la hora de declarar las variables para asignar su tipo una vez han sido insertados todos los _ID_ de la expresion _declararVariable_. Así recorrera la tabla de símbolos buscando los elementos con  tipo 0 o negativo y en ese caso les dara el tipo que recibe como parametro y comprobara si los elementos inicializados tienen el mismo tipo, mostrando un error si no es igual. 

```c

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
					fprintf(yyoutc,"\nERROR: linea %d: Valor de distinto tipo",
nLineas+1); 
					nErrores++;
				}
				this->tipo = tipo;
			}
			this = this->sig;
		}
	}

```

### errorIncremento:

- A esta función recibe el nombre del elemento que está comprobando y comprueba que: esté inicializado, esté declarado y el tipo sea o entero o real.

```c

	void errorIncremento(char nombre[30])
	{
		     struct simbolo* pos = buscarSimbolo(tablaSim, nombre);
		      if(pos == NULL)
		      {
			   fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no declarado",
nLineas+1, nombre); 
			   nErrores++;
		      } 
		      else if(pos->tipo > 2)
		      {
			     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no numerico",
nLineas+1,nombre); 
			   nErrores++;
		      }
		      else if(pos->init == 0)
		      {
			   fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no inicializado",
nLineas+1, nombre); 
			   nErrores++;
		      }
	}

```

### Tipo:

- La expresión que encotramos en tipo _$$=$1_ indica que el elemento tipo guarda el valor de _$1_.

```c

	tipo: INT { $$ = $1; }
	    | FLOAT { $$ = $1; }
	    | CHAR { $$ = $1; }
	    | STRING { $$ = $1; }
	    | BOOLEAN { $$ = $1; }
	;

```

### Asignacion:

- Esta pieza de código comprueba que el elemento está declarado, no es una constante y que los tipos coinciden. Si lo anterior es correcto indica que el elmento actual está inicializado.


```c

	asignacion: ID '=' expresion ';' {
					       struct simbolo* pos = buscarSimbolo(tablaSim, $1);
						if(pos == NULL)
						{
						     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no 
declarado",nLineas+1, $1); 
						     nErrores++;
						} 
						else if(pos->cte == 1)
						{
							fprintf(yyoutc,"\nERROR: linea %d: Constante %s no 
modificable",nLineas+1, $1); 
						     nErrores++;
						}
						else
						{       
							if(pos->tipo == $3)
								pos->init = 1;
							else
							{
								fprintf(yyoutc,"\nERROR: linea %d: Identificador 
de distinto tipo",nLineas+1); 
								nErrores++;
							}
						}
					 } 
	;

```

### Expresion:

- Comprobamos que el _ID_ esté declarado e inicializado y si está declarado asignamos a expresión el tipo de la posición actual.

```c

	expresion: ID {
					       struct simbolo* pos = buscarSimbolo(tablaSim, $1);
						if(pos == NULL)
						{
						     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no 
declarado",nLineas+1, $1); 
						     nErrores++;
						}    
						else
						{       if (pos->init == 0)
							{
							      fprintf(yyoutc,"\nERROR: linea %d: Identificador %s 
no inicializado",nLineas+1, $1); 
							      nErrores++;
							}	
							$$ = pos->tipo;
						}
		      } 

```

- Para las siguientes operaciones de caracter numérico debemos comprobar a mayores que solo las realizan valores numéricos.

```c

	 | expresion operador expresion {
					if($1 > 2 && $3 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",
nLineas+1); 
					    nErrores++;
					}
						 $$ = $1;
					}
	 | '(' expresion ')' {
					if($2 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",
nLineas+1); 
					    nErrores++;
					}
						 $$ = $2;
				}
	 | '-' expresion  %prec UNARIO  {
					if($2 > 2)
					{
					    fprintf(yyoutc,"\nERROR: linea %d: Expresion no numerico",
nLineas+1); 
					    nErrores++;
					}
						$$ = $2;
					 }
;

```

### Lectura:

- Si el elmento está declarado y no es una constante, este se marca como incializado.


```c

	lectura: SCANF '(' ID ')' ';' {
					       struct simbolo* pos = buscarSimbolo(tablaSim, $3);
						if(pos == NULL)
						{
						     fprintf(yyoutc,"\nERROR: linea %d: Identificador %s no 
declarado",nLineas+1, $3); 
						     nErrores++;
						} 
						else if(pos->cte == 1)
						{
							fprintf(yyoutc,"\nERROR: linea %d: Constante %s no 
modificable",nLineas+1, $3); 
						     nErrores++;
						}
						else
						{
							pos->init = 1;
						}
				      }	
	;

```






# Zona de Funciones del Usuario:


## Funcion Main:


Controlamos los posibles errores de apertura del fichero a leer y a escribir.




```c

	if(yyin == NULL )
	{
		printf("ERROR DE APERTURA\n");
		return 0;

	}
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

```

Llamamos a la función que solicita a yylex los tokens de entrada y hace las respectivas comprobaciones.

```c

	yyparser();

```

Por último imprimimos un mensaje de todo correcto o error en la salida.txt segun el número de errores.

```c

	if(nErrores == 0)
		fprintf(yyoutc,"\n Todo correcto numero de lineas: %d",nLineas);
	else
		fprintf(yyoutc,"\nNumero de errores semanticos: %d",nErrores);

```



# Contenido extra:

Se adjunta al trabajo un MakeFile para que se pueda ver como hemos compilado el proyecto simplemente llamando a la comando:

- make
: lo compila y ejecuta.
- make open
: lo compila ejecuta y muestra con less el fichero de salida.txt.
- make opencomplete:
: hace lo que make pero muestra en less el fichero de salidacompleta.txt.
