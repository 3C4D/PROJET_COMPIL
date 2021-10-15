%{
#include<stdlib.h>
#include<stdio.h>
#include "../arbres/inc/arbres.h"
#include "../inc/fct_aux_yacc.h"
#include "../TabLexico/inc/TabLexico.h"
#include "../TabRepresentation/inc/TabRepresentation.h"
#include "../TabDecla/inc/TabDecla.h"

char *yytext;
int yylex();
int yyerror();

extern int nb_ligne;

int syntaxe_correcte = 1;
int erreur_semantique = 0;
int tab_var_format[40];

int num_region = 0;
int diff = 0;

int nb_parametres;
int nb_champs;
int nb_dim;
int premier_indice;
%}

%token PROG DEBUT FIN
%token POINT_VIRGULE DEUX_POINTS CROCHET_OUVRANT CROCHET_FERMANT OPAFF
%token EGAL DIFFERENT SUP SUP_EGAL INF INF_EGAL
%token PARENTHESE_OUVRANTE PARENTHESE_FERMANTE SOULIGNE VIRGULE POINT
%token TYPE STRUCT FSTRUCT TABLEAU
%token ENTIER REEL BOOLEEN CARACTERE CHAINE
%token VARIABLE
%token SI ALORS SINON PROCEDURE FONCTION RETOURNE TANT_QUE FAIRE DE
%token VIDE
%token ET OU NON
%token PLUS MOINS MULT DIV MODULO
%token AFFICHER LIRE


%union{
  arbre typ1;
  int typ2;
  double typ3;
  char typ4;
}
%token<typ2> IDF CSTE_ENTIERE CSTE_CHAINE TRUE FALSE
%token<typ2> CSTE_REELLE
%token<typ2> CSTE_CARACTERE

%type<typ2> declaration_type declaration_fonction declaration_variable declaration_procedure
%type<typ2> liste_champs liste_param liste_dimensions liste_parametres
%type<typ2> une_dimension un_champ un_param dimension
%type<typ2> nom_type type_simple
%type<typ2> suite_declaration_type

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
                   {$$ = inserer_tab_declaration($2, $4, tete_pile_region(), premier_indice, nb_ligne);}
                 ;

suite_declaration_type : STRUCT {nb_champs = 0;
                               /*Réservation d'une case pour mettre le nombre
                                   de champs*/
                                premier_indice = inserer_tab_representation_type(0, -1);}
                        liste_champs FSTRUCT
                      {/*Mise à jour de la première case*/
                        /*On retrouve l'indice de la première case*/

                       TableRepresentation[premier_indice] = nb_champs;
                     $$= TYPE_STRUCT;}
                       | TABLEAU {nb_dim =0;
                         /*On reserve 2cases, une pour le type des éléments, une
                         pour le nombre de dimension*/
                          premier_indice = inserer_tab_representation_type(0,0);}

                        dimension DE nom_type POINT_VIRGULE {
                          /*Mise à jour des 2 premières cases*/
                          TableRepresentation[premier_indice-1] = $5;
                          TableRepresentation[premier_indice] = nb_dim;
                          premier_indice--;
                          $$ = TYPE_TAB;}
                       ;

dimension : CROCHET_OUVRANT liste_dimensions CROCHET_FERMANT {$$ = $2;}
          ;

liste_dimensions : une_dimension { $$ = $1;}
                 | liste_dimensions VIRGULE une_dimension
                ;

une_dimension : CSTE_ENTIERE SOULIGNE CSTE_ENTIERE {nb_dim += 1;$$=inserer_tab_representation_type($1, $3);}
              ;

liste_champs : un_champ {$$ = $1;}
             | liste_champs POINT_VIRGULE un_champ
             ;

un_champ : IDF DEUX_POINTS nom_type { nb_champs += 1;$$ = inserer_tab_representation_type($3, $1);}
         ;

nom_type : type_simple {$$ = $1;}
         | IDF {$$ = $1;}
         ;

type_simple : ENTIER {$$= 0;}
            | REEL {$$=1;}
            | BOOLEEN {$$ = 2;}
            | CARACTERE {$$ = 3;}
            | CHAINE CROCHET_OUVRANT CSTE_ENTIERE CROCHET_FERMANT {$$ = 4;}
            ;

declaration_variable  : VARIABLE IDF DEUX_POINTS nom_type
                      {$$ = inserer_tab_declaration($2, VAR, tete_pile_region(), $4, nb_ligne);}
                      ;

declaration_procedure : PROCEDURE { nb_parametres = 0;
                                  /*On reserve une case pour le nombre de parametres*/
                                   premier_indice= inserer_tab_representation_type(0,-1);

                                   /*Mise à jour des num de région*/
                                   num_region++;
                                   empiler_pile_region(num_region);
                                  }
                        IDF liste_parametres {
  /*Mise à jour de la première case*/
  TableRepresentation[premier_indice] = nb_parametres;

}                   corps{
  $$=inserer_tab_declaration($3, PROC, tete_pile_region(depiler_pile_region()), premier_indice, nb_ligne);
}
                      ;

declaration_fonction  : FONCTION {nb_parametres = 0;
                                /*On reserve 2 cases pour le nombre de parametres
                                et la nature du renvoie*/
                                 premier_indice = inserer_tab_representation_type(0,0);
                                 /*Mise à jour des num de région*/
                                 num_region++;
                                 empiler_pile_region(num_region);
                                 }
                        IDF liste_parametres RETOURNE type_simple {

  /*Mise à jour de la première case*/
  TableRepresentation[premier_indice-1] = $6;
  TableRepresentation[premier_indice] = nb_parametres;
  premier_indice--;
}                   corps {
  $$= inserer_tab_declaration($3, FCT, tete_pile_region(depiler_pile_region()), premier_indice, nb_ligne);
}
                      ;

liste_parametres : PARENTHESE_OUVRANTE liste_param PARENTHESE_FERMANTE {$$=$2;}
                 | {$$ = 0;}
                 ;

liste_param : un_param {$$=$1;}
            | liste_param POINT_VIRGULE un_param
            ;

un_param : IDF DEUX_POINTS type_simple {nb_parametres+=1; $$ = inserer_tab_representation_type($3, $1);
                                        inserer_tab_declaration($1, PARAMETRE, tete_pile_region(), $3, nb_ligne);}
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
  init_pile_region();
  init_table_lexico();
  init_tab_decla();
  init_tab_representation_type();
  yyparse();

  if(syntaxe_correcte){
    printf("\nSYNTAXE CORRECTE\n\n");
  }
  if(erreur_semantique){
    fprintf(stderr, "\nERREURS SEMANTIQUES\n\n");
  }

  afficher_tab_representation();
  printf("\n\n");
  afficher_tab_declaration();
  printf("\n\n");
  affiche_table_lexico();
  printf("\n\n");

}
