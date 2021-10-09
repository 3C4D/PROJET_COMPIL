%{
#include<stdlib.h>
#include<stdio.h>

char *yytext;
int yylex();
int yyerror();

extern int nb_ligne;

int syntaxe_correcte = 1;
int erreur_semantique = 0;
int tab_format[40];
int tab_var_format[40];

// fonction permettant de déterminer combien et quels formats simples se
// trouvent dans une chaine de caractère
void format(char *str){
  char *ptr = str;

  tab_format[0] = 0;

  while(*ptr != '\0'){
    if(*ptr == '%'){
      if(*(ptr+1) == 'd'
      || *(ptr+1) == 'f'
      || *(ptr+1) == 'c'
      || *(ptr+1) == 's'
      ){
        tab_format[0]++;
        tab_format[tab_format[0]] = *(ptr+1)-'a';
      }
    }
    ptr++;
  }
}

%}

%token PROG DEBUT FIN
%token POINT_VIRGULE DEUX_POINTS CROCHET_OUVRANT CROCHET_FERMANT OPAFF
%token EGAL DIFFERENT SUP SUP_EGAL INF INF_EGAL
%token PARENTHESE_OUVRANTE PARENTHESE_FERMANTE SOULIGNE VIRGULE POINT
%token TYPE STRUCT FSTRUCT TABLEAU
%token ENTIER REEL BOOLEEN CARACTERE CHAINE
%token CSTE_ENTIERE CSTE_REELLE CSTE_CHAINE CSTE_CARACTERE
%token VARIABLE IDF
%token SI ALORS SINON PROCEDURE FONCTION RETOURNE TANT_QUE FAIRE DE
%token VIDE
%token ET OU NON
%token PLUS MOINS MULT DIV MODULO
%token TRUE FALSE
%token AFFICHER LIRE

%%
programme : PROG corps

corps : liste_declarations liste_instructions
      | liste_instructions
      ;

liste_declarations : declaration
                   | liste_declarations declaration
                   ;

liste_instructions : DEBUT suite_liste_inst FIN
                   ;

suite_liste_inst : instruction
                 | suite_liste_inst instruction
                 ;

declaration : declaration_type
            | declaration_variable POINT_VIRGULE
            | declaration_procedure
            | declaration_fonction
            ;

declaration_type : TYPE IDF DEUX_POINTS suite_declaration_type
                 ;

suite_declaration_type : STRUCT liste_champs FSTRUCT
                       | TABLEAU dimension DE nom_type POINT_VIRGULE
                       ;

dimension : CROCHET_OUVRANT liste_dimensions CROCHET_FERMANT
          ;

liste_dimensions : une_dimension
                 | liste_dimensions VIRGULE une_dimension
                 ;

une_dimension : expression SOULIGNE expression
              ;

liste_champs : un_champ
             | liste_champs POINT_VIRGULE un_champ
             ;

un_champ : IDF DEUX_POINTS nom_type
         ;

nom_type : type_simple
         | IDF
         ;

type_simple : ENTIER
            | REEL
            | BOOLEEN
            | CARACTERE
            | CHAINE CROCHET_OUVRANT CSTE_ENTIERE CROCHET_FERMANT
            ;

declaration_variable  : VARIABLE IDF DEUX_POINTS nom_type
                      ;

declaration_procedure : PROCEDURE IDF liste_parametres corps
                      ;

declaration_fonction  : FONCTION IDF liste_parametres RETOURNE type_simple corps
                      ;

liste_parametres : PARENTHESE_OUVRANTE liste_param PARENTHESE_FERMANTE
                 |
                 ;

liste_param : un_param
            | liste_param POINT_VIRGULE un_param
            ;

un_param : IDF DEUX_POINTS type_simple
         ;

instruction : affectation POINT_VIRGULE
            | condition
            | tant_que
            | afficher POINT_VIRGULE
            | lire POINT_VIRGULE
            | appel POINT_VIRGULE
            | VIDE POINT_VIRGULE
            | RETOURNE resultat_retourne POINT_VIRGULE
            ;

resultat_retourne : un_arg
                  |
                  ;

appel : IDF liste_arguments
      ;

liste_arguments : PARENTHESE_OUVRANTE liste_args PARENTHESE_FERMANTE
                ;

liste_args : un_arg
           | liste_args VIRGULE un_arg
           |
           ;

un_arg : expression
       ;

condition : SI expression
            ALORS liste_instructions
            sinon
          ;

sinon : SINON liste_instructions
      |
      ;

tant_que : TANT_QUE expression FAIRE liste_instructions

affectation : variable OPAFF expression
            ;

variable : IDF corps_variable
         ;

corps_variable : CROCHET_OUVRANT expression CROCHET_FERMANT corps_variable
               | POINT variable
               |
               ;

expression : concatenation
           | e1
           ;

concatenation : CSTE_CHAINE
              | CSTE_CHAINE PLUS concatenation
              ;

e1 : e1 PLUS e2
   | e1 MOINS e2
   | e1 OU e2
   | e2
   ;

e2 : e2 MULT e3
   | e2 DIV e3
   | e2 MODULO e3
   | e2 ET e3
   | e3
   ;

e3 : e3 operateur_comp e4;
   | e4
   ;

e4 : NON e5;
   | e5
   ;

e5 : PARENTHESE_OUVRANTE e1 PARENTHESE_FERMANTE
   | CSTE_ENTIERE
   | CSTE_REELLE
   | CSTE_CARACTERE
   | un_booleen
   | variable
   | appel
   ;

un_booleen : TRUE
           | FALSE
           ;

operateur_comp : EGAL
               | DIFFERENT
               | SUP
               | SUP_EGAL
               | INF
               | INF_EGAL
               ;

afficher : AFFICHER PARENTHESE_OUVRANTE CSTE_CHAINE {
    // On analyse le format donné
    format(yytext);
    tab_var_format[0] = 0;
  }
  suite_afficher{
    // On compare ici le format recu

    int i;
    // Trop de formats
    if(tab_format[0] > tab_var_format[0]){
      fprintf(stderr, "\nErreur l:%d -> afficher, trop de formats\n", nb_ligne);
      erreur_semantique++;
    }
    // Trop d'arguments suivants le format
    else if(tab_var_format[0] > tab_format[0]){
      fprintf(stderr, "\nErreur l:%d -> afficher, trop d'arguments\n", nb_ligne);
      erreur_semantique++;
    }
    // Les cardinaux sont cohérents, on regarde si les éléments sont cohérents
    else{
      for(i = 1; i < tab_format[0]+1; i++){
        if(tab_format[i] != tab_var_format[i]){
          fprintf(stderr,
            "\nErreur l:%d -> Le format numéro %d ne corespond pas...\n",
            nb_ligne, i
          );
          erreur_semantique++;
        }
      }
    }
  }
  PARENTHESE_FERMANTE
         ;

suite_afficher : VIRGULE {
                  tab_var_format[0]++;
                }
  composante_afficher
  suite_afficher
               |
               ;


composante_afficher : variable       {
                      // A revoir car pas encore de tabdecl
                      tab_var_format[tab_var_format[0]] = 'v'-'a';
                    }
                    | appel       {
                      // A revoir car pas encore de tabdecl
                      tab_var_format[tab_var_format[0]] = 'a'-'a';
                    }
                    | CSTE_ENTIERE       {
                      tab_var_format[tab_var_format[0]] = 'd'-'a';
                    }
                    | CSTE_REELLE       {
                      tab_var_format[tab_var_format[0]] = 'f'-'a';
                    }
                    | CSTE_CARACTERE       {
                      tab_var_format[tab_var_format[0]] = 'c'-'a';
                    }
                    | CSTE_CHAINE       {
                      tab_var_format[tab_var_format[0]] = 's'-'a';
                    }
                    ;

lire : LIRE PARENTHESE_OUVRANTE liste_variables PARENTHESE_FERMANTE
     ;

liste_variables : variable VIRGULE liste_variables
                | variable
                ;


%%

int yyerror(){
  fprintf(stderr, "\nErreur de syntaxe ligne %d : %s\n\n", nb_ligne, yytext);
  syntaxe_correcte = 0;
}

int main(){
  yyparse();

  if(syntaxe_correcte){
    printf("\nSYNTAXE CORRECTE\n\n");
  }
  if(erreur_semantique){
    fprintf(stderr, "\nERREURS SEMANTIQUES\n\n");
  }
}
