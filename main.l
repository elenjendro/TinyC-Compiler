%{

  #include "y.tab.h"

  
  int nLineas=0;
%}
operador ("="|"+"|"-"|"*"|"/"|"%"|"!"|">"|"<"|"&")
separador (","|"."|";"|"("|")"|"["|"]"|"{"|"}"|"#")
letra [a-zA-Z]
digito [0-9]
identificador {letra}({letra}|{digito})*
cadena (\"[^"]*\")
caracter (\'([^']|"\\"{letra})\')
entero {digito}+
real {digito}+("."){digito}+(("e"("-")?{digito}))?
comentario (("/""/"(.)*))


%s CODE COMMENT
%%
		{BEGIN(CODE);}
<CODE>"/*" {
	fprintf(yyout,"\n Ha reconocida un comentario largo que ignoraremos\n");
	BEGIN(COMMENT);}
<COMMENT>. {;}
<COMMENT>\n {nLineas++;}
<COMMENT>"*/" {BEGIN(CODE);}
<CODE>{comentario} {
	fprintf(yyout,"\n COMENTARIO");
	return COMENTARIO;
}
<CODE>{real} {
	fprintf(yyout,"\n NUM");
	yylval.tipo = 2;
	return NUM;
}
<CODE>{entero} {
	fprintf(yyout,"\n NUM");
	yylval.tipo = 1;
	return NUM;
}
<CODE>{cadena} {
	fprintf(yyout,"\n CADENA");
	yylval.tipo = 4;
	return CADENA;
}
<CODE>{caracter} {
	fprintf(yyout,"\n CARACTER");
	yylval.tipo = 3;
	return CARACTER;
}
<CODE>true {
	fprintf(yyout,"\n TRUE");
	yylval.tipo = 5;
	return BOOLVAL;
}
<CODE>false {
	fprintf(yyout,"\n FALSE");
	yylval.tipo = 5;
	return BOOLVAL;
}
<CODE>[ \t]	;
<CODE>define  {
	fprintf(yyout,"\n DEFINE");
	return DEFINE;
}
<CODE>main {
	fprintf(yyout,"\n MAIN");
	return MAIN;
}
<CODE>int  {
	fprintf(yyout,"\n INT");
	yylval.tipo = 1;
	return INT;
}
<CODE>float  {
	fprintf(yyout,"\n FLOAT");
	yylval.tipo = 2;
	return FLOAT;
}
<CODE>char  {
	fprintf(yyout,"\n CHAR");
	yylval.tipo = 3;
	return CHAR;
}
<CODE>string  {
	fprintf(yyout,"\n STRING");
	yylval.tipo = 4;
	return STRING;
}
<CODE>bool  {
	fprintf(yyout,"\n BOOLEAN");
	yylval.tipo = 5;
	return BOOLEAN;
}

<CODE>printf {
	fprintf(yyout,"\n PRINTF");
	return PRINTF;
}
<CODE>scanf {
	fprintf(yyout,"\n SCANF");
	return SCANF;
}
<CODE>if {
	fprintf(yyout,"\n IF");
	return IF;
}
<CODE>else {
	fprintf(yyout,"\n ELSE");
	return ELSE;
}
<CODE>switch {
	fprintf(yyout,"\n SWITCH");
	return SWITCH;
}
<CODE>case {
	fprintf(yyout,"\n CASE");
	return CASE;
}
<CODE>break {
	fprintf(yyout,"\n BREAK");
	return BREAK;
}

<CODE>while {
	fprintf(yyout,"\n WHILE");
	return WHILE;
}
<CODE>for {
	fprintf(yyout,"\n FOR");
	return FOR;
}
<CODE>{separador} {
	fprintf(yyout,"\n%c",yytext[0]);
	return yytext[0];
}
<CODE>{operador} {
	fprintf(yyout,"\n%c",yytext[0]);
	return yytext[0];
}
<CODE>{identificador}	{
	fprintf(yyout,"\n ID");
	strcpy(yylval.nombre, yytext);
	return ID;
}
<CODE>\n  {
	nLineas++;
}

<CODE>.	{fprintf(yyout,"\n %c",yytext[0]);
	return yytext[0];}

%%

int yywrap(){
    return 1;
}
