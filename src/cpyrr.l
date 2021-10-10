%{
#include "../arbres/inc/arbres.h"
#include "../obj/cpyrr.tab.h"
#include "../inc/fct_aux_lex.h"
#include "../TabLexico/inc/TabLexico.h"

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
\/\*({C2}|\"{C1}*\"|\*\**{C3}|\*\**\"{C1}*\")*\*\**\/ {
  calcul_nb_ligne_comm(yytext);
}

"_" {return(SOULIGNE);}
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

"afficher"  {return(AFFICHER);}
"lire"  {return(LIRE);}

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

(0|[1-9][0-9]*) {yylval.typ2 = atoi(yytext); return(CSTE_ENTIERE);}
(0|[1-9][0-9]*)\.([0-9]*)  {yylval.typ3 = atof(yytext); return(CSTE_REELLE);}
\'.\'  {yylval.typ4 = *yytext; return(CSTE_CARACTERE);}
\"[^"]*\" {yylval.typ2 = inserer_tab_lex(yytext); return(CSTE_CHAINE);}

[a-zA-Z][a-zA-Z0-9]*  {yylval.typ2 = inserer_tab_lex(yytext); return(IDF);}

\n  {nb_ligne++;}
[ \t] ;

%%

int yywrap(){
}
