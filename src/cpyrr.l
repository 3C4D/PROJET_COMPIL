%{
#include <string.h>
#include "../arbres/inc/arbres.h"
#include "../obj/cpyrr.tab.h"
#include "../inc/fct_aux_lex.h"
#include "../TabLexico/inc/TabLexico.h"
#include "../inc/couleur.h"

extern int nb_ligne;
int colonne = 0;

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

"_" {colonne += 1; return(SOULIGNE);}
"." {colonne += 1; return(POINT);}
";" {colonne += 1; return(POINT_VIRGULE);}
":" {colonne += 1; return(DEUX_POINTS);}
"[" {colonne += 1; return(CROCHET_OUVRANT);}
"]" {colonne += 1; return(CROCHET_FERMANT);}
":=" {colonne += 2; return(OPAFF);}

"=" {colonne += 1; return(EGAL);}
">" {colonne += 1; return(SUP);}
">="  {colonne += 2; return(SUP_EGAL);}
"<" {colonne += 1; return(INF);}
"<="  {colonne += 2; return(INF_EGAL);}
"!="  {colonne += 2; return(DIFFERENT);}

"(" {colonne += 1; return(PARENTHESE_OUVRANTE);}
")" {colonne += 1; return(PARENTHESE_FERMANTE);}
"," {colonne += 1; return(VIRGULE);}

"type"  {colonne += 4; return(TYPE);}
"struct"  {colonne += 6; return(STRUCT);}
"fstruct" {colonne += 7; return(FSTRUCT);}
"array" {colonne += 5; return(TABLEAU);}

"int" {colonne += 3; return(ENTIER);}
"float" {colonne += 5; return(REEL);}
"bool"  {colonne += 4; return(BOOLEEN);}
"char"  {colonne += 4; return(CARACTERE);}
"str"  {colonne += 3; return(CHAINE);}
"var" {colonne += 3; return(VARIABLE);}
"proc"  {colonne += 4; return(PROCEDURE);}
"func"  {colonne += 4; return(FONCTION);}

"return"  {colonne += 6; return(RETOURNE);}
"void"  {colonne += 5; return(VIDE);}
"of"  {colonne += 2; return(DE);}

"afficher"  {colonne += 8; return(AFFICHER);}
"lire"  {colonne += 4; return(LIRE);}

"if"  {colonne += 2; return(SI);}
"then" {colonne += 4; return(ALORS);}
"else"  {colonne += 4; return(SINON);}

"while" {colonne += 5; return(TANT_QUE);}
"do"  {colonne += 2; return(FAIRE);}

"and" {colonne += 3; return(ET);}
"or"  {colonne += 2; return(OU);}
"not" {colonne += 3; return(NON);}

"true"  {colonne += 4; yylval.typ2 = 1; return(TRUE);}
"false" {colonne += 5; yylval.typ2 = 1; return(TRUE);}

"+" {colonne++;return(PLUS);}
"-" {colonne++;return(MOINS);}
"/" {colonne++;return(DIV);}
"*" {colonne++;return(MULT);}
"%" {colonne++;return(MODULO);}

(0|[1-9][0-9]*) {yylval.typ2 = atoi(yytext); return(CSTE_ENTIERE);}
(0|[1-9][0-9]*)\.([0-9]*)  {yylval.typ3 = atof(yytext); return(CSTE_REELLE);}
\'.\'  {yylval.typ2 = yytext[1]; return(CSTE_CARACTERE);}
\"[^"]*\" {yylval.typ2 = inserer_tab_lex(yytext); return(CSTE_CHAINE);}

[a-zA-Z][a-zA-Z0-9]*  {
  yylval.typ2 = inserer_tab_lex(yytext);
  colonne += strlen(yytext);
  return(IDF);
}

\n  {nb_ligne++; colonne = 0;}
" " {colonne ++;}
\t  {colonne += 2;}

. {
  couleur(VERTGRAS);
  fprintf(stderr, "\nErreur lexicographique\n");
  couleur(BLANCGRAS);
  fprintf(stderr, " %d |  %s", nb_ligne, yytext);
  couleur(RESET);
  fprintf(stderr, "\n\n");
}
%%

int yywrap(){
}
