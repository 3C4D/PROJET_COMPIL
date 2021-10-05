%{
#include "../obj/cpyrr.tab.h"
int nb_ligne = 1;
%}

C1 [^"]
C2 [^"*]
C3 [^"*/]

%%
"cpyrr" {return(PROG);}
\{  {return(DEBUT);}
\}  {return(FIN);}

\/\/.*$ ;
\/\*({C2}|\"{C1}*\"|\*\**{C3}|\*\**\"{C1}*\")*\*\**\/ ;

"." {return(POINT);}
";" {return(POINT_VIRGULE);}
":" {return(DEUX_POINTS);}
"[" {return(CROCHET_OUVRANT);}
"]" {return(CROCHET_FERMANT);}
":=" {return(OPAFF);}

"=" {return(EGAL);}
">" {return(SUP);}
">="  {return(SUP_EGAL);}
"<" {return(INF);}
"<="  {return(INF_EGAL);}
"!="  {return(DIFFERENT);}

"(" {return(PARENTHESE_OUVRANTE);}
")" {return(PARENTHESE_FERMANTE);}
".." {return(POINT_POINT);}
"," {return(VIRGULE);}

"type"  {return(TYPE);}
"struct"  {return(STRUCT);}
"fstruct" {return(FSTRUCT);}
"array" {return(TABLEAU);}

"int" {return(ENTIER);}
"float" {return(REEL);}
"bool"  {return(BOOLEEN);}
"char"  {return(CARACTERE);}
"str"  {return(CHAINE);}
"var" {return(VARIABLE);}
"proc"  {return(PROCEDURE);}
"func"  {return(FONCTION);}

"return"  {return(RETOURNE);}
"void"  {return(VIDE);}
"of"  {return(DE);}

"if"  {return(SI);}
"then" {return(ALORS);}
"else"  {return(SINON);}

"while" {return(TANT_QUE);}
"do"  {return(FAIRE);}

"and" {return(ET);}
"or"  {return(OU);}
"not" {return(NON);}

"true"  {return(TRUE);}
"false" {return(FALSE);}

"+" {return(PLUS);}
"-" {return(MOINS);}
"/" {return(DIV);}
"*" {return(MULT);}
"%" {return(MODULO);}

(0|[1-9][0-9]*) {return(CSTE_ENTIERE);}
(0|[1-9][0-9]*)\.([0-9]*)  {return(CSTE_REELLE);}
\'.\'  {return(CSTE_CARACTERE);}
\"[^"]*\" {return(CSTE_CHAINE);}

\n  {nb_ligne++;}
[ \t] ;

[a-zA-Z][a-zA-Z0-9]*  {return(IDF);}

%%

int yywrap(){
}
