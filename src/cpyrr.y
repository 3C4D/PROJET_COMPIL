%{
#include<stdlib.h>
#include<stdio.h>
#include "../arbres/inc/arbres.h"
#include "../inc/fct_aux_yacc.h"
#include "../TabLexico/inc/TabLexico.h"
#include "../TabRepresentation/inc/TabRepresentation.h"
#include "../TabDecla/inc/TabDecla.h"
#include "../inc/macros_arbres.h"

char *yytext;
int yylex();
int yyerror();

extern int nb_ligne;

int tab_var_format[40];
int tab_arg_appel[40];

int syntaxe_correcte = 1;
int erreur_semantique = 0;
int num_region = 0;
int num_region_engendree;
int num_declaration;
int diff = 0;

int nb_parametres;
int nb_champs;
int nb_dim;
int aff_arbre = 0;

// Variables aidant à la vérification sémantique des types (expressions, aff)
int type_var_affectation = 0;
int type_g = 0;
int type_d = 0;
int type = 0;
int numero_var = INIT;

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
  int typ4;
}
%token<typ2> IDF CSTE_ENTIERE CSTE_CHAINE TRUE FALSE
%token<typ2> CSTE_CARACTERE

%token<typ3> CSTE_REELLE

%type<typ2> declaration_type declaration_fonction declaration_variable
%type<typ2> liste_champs liste_param liste_dimensions liste_parametres
%type<typ2> une_dimension un_champ un_param dimension
%type<typ2> nom_type type_simple declaration_procedure
%type<typ2> suite_declaration_type

%type<typ1> afficher suite_afficher composante_afficher lire liste_variables
%type<typ1> variable appel liste_args un_arg expression concatenation
%type<typ1> liste_arguments un_booleen e1 e2 e3 e4 e5 operateur_comp
%type<typ1> condition sinon tant_que affectation corps_variable
%type<typ1> instruction liste_instructions suite_liste_inst corps programme
%type<typ1> resultat_retourne

%%
programme : PROG corps {$$ = $2; change_deplacement(0); /*On initialise à 0*/}

corps : liste_declarations liste_instructions {$$ = $2;}
      | liste_instructions {$$ = $1;}
      ;

liste_declarations : declaration
                   | liste_declarations declaration
                   ;

liste_instructions : DEBUT suite_liste_inst FIN {
  $$ = $2;
  if(aff_arbre){
    printf("######## LISTE D'INSTRUCTION ########\n");
    afficher_arbre($$);
    printf("\n");
  }
}
                   ;

suite_liste_inst : instruction {
  $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_LISTE_INSTR, -1, -1.0),
      $1
    );
}
                 | instruction suite_liste_inst  {
                   $$ = concat_pere_fils(
                       creer_noeud(-1, -1, A_LISTE_INSTR, -1, -1.0),
                       concat_pere_frere(
                           $1,
                           $2
                          )
                      );
                 }
                 ;

declaration : declaration_type
            | declaration_variable POINT_VIRGULE
            | declaration_procedure
            | declaration_fonction
            ;

declaration_type : TYPE IDF DEUX_POINTS suite_declaration_type {
  inserer_tab_declaration(
      $2,
      $4,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    );
}
                 ;

suite_declaration_type : STRUCT {
    /*Réservation d'une case pour mettre le nombre de champs*/
    nb_champs = 0;
    change_premier_indice(inserer_tab_representation_type(-99, -1, TYPE_STRUCT));

    /*On remet à 0 pour dire qu'on est dans une nouvelle structure*/
    change_deplacement_struct(0);
}
                        liste_champs FSTRUCT {
    /*Mise à jour de la première case, on retrouve l'indice de la première
    case*/

    stocker_table_representation(premier_indice(), nb_champs);
    $$= TYPE_STRUCT;
    if(verif_surchage_struct(premier_indice(),nb_ligne) == -1){
      erreur_semantique++;
    }
}
                       | TABLEAU {
      nb_dim = 0;
      /*On reserve 2cases, une pour le type des éléments, une pour le nombre de
      dimension*/
      change_premier_indice(inserer_tab_representation_type(-99,-99, TYPE_TAB));
}

                        dimension DE nom_type POINT_VIRGULE {
      /*Mise à jour des 2 premières cases*/
      stocker_table_representation(premier_indice(), $5);
      stocker_table_representation(premier_indice()+1, nb_dim);
      $$ = TYPE_TAB;
}
                       ;

dimension : CROCHET_OUVRANT liste_dimensions CROCHET_FERMANT {$$ = $2;}
          ;

liste_dimensions : une_dimension { $$ = $1;}
                 | liste_dimensions VIRGULE une_dimension
                ;

une_dimension : CSTE_ENTIERE SOULIGNE CSTE_ENTIERE {
  nb_dim += 1;$$=inserer_tab_representation_type($1, $3, TYPE_TAB);
}
              ;

liste_champs : un_champ {$$ = $1;}
             | liste_champs POINT_VIRGULE un_champ
             ;

un_champ : IDF DEUX_POINTS nom_type {
  nb_champs += 1; $$ = inserer_tab_representation_type($3, $1, TYPE_STRUCT);
  stocker_table_representation($$+2, deplacement_struct());
  change_deplacement_struct(deplacement_struct() + valeur_exec_tab_decla($3));
  printf("%d \n", deplacement_struct());
}
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

declaration_variable  : VARIABLE IDF DEUX_POINTS nom_type {
   num_declaration = inserer_tab_declaration($2, VAR, tete_pile_region(), $4, nb_ligne);
   inserer_exec_tab_decla(num_declaration, deplacement());
   change_deplacement(deplacement() + valeur_exec_tab_decla(valeur_description_tab_decla(num_declaration)));
}
                      ;

declaration_procedure : PROCEDURE IDF {
  nb_parametres = 0;
  /*On reserve une case pour le nombre de parametres*/
  change_premier_indice(inserer_tab_representation_type(-99,-1, PROC));
  /*On remet à 0 la champs déplacement_var*/
  change_deplacement(0);

  inserer_tab_declaration(
      $2,
      PROC,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    );

  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
}
                      liste_parametres {
  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), nb_parametres);

}                   corps {
    num_region_engendree = tete_pile_region();
    depiler_pile_region();

    /*On remet le deplacement à 0 car on sort de la région*/
    change_deplacement(0);

   inserer_exec_tab_decla(num_decla($2, PROC, tete_pile_region()),num_region_engendree);

}
                      ;

declaration_fonction  : FONCTION IDF{
  nb_parametres = 0;
  /*On reserve 2 cases pour le nombre de parametres
  et la nature du renvoie*/
  change_premier_indice(inserer_tab_representation_type(-99,-99,FCT));
  /*On remet à 0 la champs déplacement_var*/
  change_deplacement(0);


  inserer_tab_declaration(
      $2,
      FCT,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    );
  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
}
                        liste_parametres RETOURNE type_simple {

  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), $6);
  stocker_table_representation(premier_indice()+1, nb_parametres);
}                   corps {
  num_region_engendree = tete_pile_region();
  depiler_pile_region();

  /*On remet le deplacement à 0 car on sort de la région*/
  change_deplacement(0);

 inserer_exec_tab_decla(num_decla($2, FCT, tete_pile_region()),num_region_engendree);
}
                      ;

liste_parametres : PARENTHESE_OUVRANTE liste_param PARENTHESE_FERMANTE {$$=$2;}
                 | {$$ = 0;}
                 ;

liste_param : un_param {$$ = $1;}
            | liste_param POINT_VIRGULE un_param
            ;

un_param : IDF DEUX_POINTS type_simple {
  nb_parametres+=1;

  inserer_tab_representation_type($3, $1, FCT);
  num_declaration = inserer_tab_declaration($1, PARAMETRE, tete_pile_region(), $3, nb_ligne);
  inserer_exec_tab_decla(num_declaration, deplacement());
  change_deplacement(deplacement() + valeur_exec_tab_decla(valeur_description_tab_decla(num_declaration)));
}
         ;

instruction : affectation POINT_VIRGULE {
  $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_AFFECTATION, -1, -1.0),
      $1
    );
}
            | condition {$$ = $1;}
            | tant_que {$$ = $1;}
            | afficher POINT_VIRGULE {$$ = $1;}
            | lire POINT_VIRGULE {$$ = $1;}
            | appel POINT_VIRGULE {

          // Un appel sans exploitation de la valeur de retour doit être une
          // procedure, sinon erreur
          int num_decl_appel = num_decla($1->numlex, PROC, -1);

          if(num_decl_appel == -1){ // Rien de déclaré pour ce lexème
            fprintf(
              stderr,
              "\nErreur l:%d -> procedure %s non déclarée.\n",
              nb_ligne,
              lexeme($1->numlex)
              );
          }
          else{
            $1->numdecl = num_decl_appel;
            $1->nature = A_APPEL_PROC;
            if(verif_arg_appel(num_decl_appel, tab_arg_appel, nb_ligne) == -1){
              erreur_semantique++;
            }
          }

          $$ = $1;
        }
        | VIDE POINT_VIRGULE {$$ = creer_noeud(-1, -1, A_VIDE, -1, -1.0);}
        | RETOURNE resultat_retourne POINT_VIRGULE {
          $$ = concat_pere_fils(
              creer_noeud(-1, -1, A_RETOURNE, -1, -1.0),
              $2
            );
        }
            ;

resultat_retourne : un_arg {$$ = $1;}
                  | {$$ = creer_arbre_vide();}
                  ;

appel : IDF {tab_arg_appel[0] = 0;} liste_arguments {
  $$ = concat_pere_fils(
    creer_noeud(
      $1,
      -1,
      -1,
      -1,
      -1
    ),
    $3
  );

}
      ;

liste_arguments : PARENTHESE_OUVRANTE liste_args PARENTHESE_FERMANTE {
  $$ = $2;;
}
                ;

liste_args : un_arg {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_LISTE_ARG, -1, -1.0), $1);
}
           | un_arg VIRGULE liste_args {
             $$ = concat_pere_fils(
               creer_noeud(-1, -1, A_LISTE_ARG, -1, -1.0),
               concat_pere_frere($1, $3)
               );
           }
           | {$$ = creer_arbre_vide();}
           ;

un_arg : expression {$$ = $1;
                     tab_arg_appel[0]++;

                     tab_arg_appel[tab_arg_appel[0]]=type;}
       ;

 condition : SI expression ALORS liste_instructions sinon {
   if(est_vide($5)){
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_SI_ALORS, -1, -1.0),
         concat_pere_frere(
           $2,
           concat_pere_frere($4, $5)
         )
       );
    }
    else{
      $$ = concat_pere_fils(
          creer_noeud(-1, -1, A_SI_ALORS_SINON, -1, -1.0),
          concat_pere_frere(
            $2,
            concat_pere_frere($4, $5)
          )
        );
     }
 }
          ;

sinon : SINON liste_instructions {
  $$ = $2;
}
      | {$$ = creer_arbre_vide();}
      ;

tant_que : TANT_QUE expression FAIRE liste_instructions {
  $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_TANT_QUE, -1, -1.0),
      concat_pere_frere($2, $4)
    );
}

affectation : variable {type_var_affectation = type;} OPAFF expression {

  // Affectation de deux choses de type différent
  if(type_var_affectation != type){
    fprintf(
      stderr,
      "\nErreur l:%d -> affectation de deux choses de types différents.\n",
      nb_ligne
    );
    erreur_semantique++;
    $$ = creer_noeud(-1, -1, -1, -1, -1.0);
  }
  else{
    $$ = concat_pere_fils(
        creer_noeud(-1, -1, A_AFFECTATION, -1, -1.0),
        concat_pere_frere(
          $1,
          $4
        )
      );
    }
}
            ;

variable : IDF {

    // L'IDF ne correpond pas à un champ, on cherche ce qu'il peut être
    if(numero_var != STRUCTURE){
      int num_decla_idf = num_decla_variable($1);

      // Elément non déclaré
      if(num_decla_idf == -1){
        fprintf(
          stderr,
          "\nErreur l:%d -> %s non déclaré.\n",
          nb_ligne,
          lexeme($1)
        );
        erreur_semantique++;
      }
      // Cet IDF correspond à une variable (ou à un paramètre)
      else if(nature(num_decla_idf) == VAR
          || nature(num_decla_idf) == PARAMETRE){
        type = valeur_description_tab_decla(num_decla_idf);

        if(type > 4){     // La variable est une srtucture
          numero_var = STRUCTURE;
        }
        else{             // La variable est de type simple
          numero_var = VAR_SIMPLE;
        }
      }
      // Cet IDF correspond à tableau, le corps sera probablement une dimension
      // sinon c'est une erreur
      else if(nature(num_decla_idf) == TYPE_TAB){
        type = valeur_tab_types(
            valeur_description_tab_decla(num_decla_idf)+1
          );
        numero_var = DIMENSION;
      }
      // Cas non traité ?
      else{
        fprintf(stderr,"\nErreur...\n");
      }
    }
    // L'IDF correspond à un champ de la structure
    else {
      int i = 0;
      // Premier indice de la struct dans la table des types
      int indice_struct = valeur_description_tab_decla(type);
      int indice_lexeme_champ = indice_struct + 2;

      type = -1;
      while(i != valeur_tab_types(indice_struct) && type == -1){
        // L'IDF appelé est bien un champ de la structure
        if(valeur_tab_types(indice_lexeme_champ) == $1){
          // On retient le type et on sort
          type = valeur_tab_types(indice_lexeme_champ-1);
        }
        indice_lexeme_champ += 3;
        i++;
      }

      if(type == -1){
        fprintf(
          stderr,
          "\nErreur l:%d -> %s : aucun champ correspondant.\n",
          nb_ligne,
          lexeme($1)
        );
        erreur_semantique++;
      }
    }

} corps_variable {
  if(erreur_semantique){
    $$ = creer_noeud(
            -1,
            -1,
            -1,
            -1,
            -1
        );
  }
  else{
    int num_decla_idf = num_decla_variable($1);

    // Champs car aucune erreur sémantique et pas une variable
    if(num_decla_idf == -1){
      $$ = concat_pere_fils(
            creer_noeud(
              $1,
              -1,
              A_CHAMP,
              -1,
              -1
            ),
            $3
          );
    }
    else{
      if(nature(num_decla_idf) == VAR
           || nature(num_decla_idf) == PARAMETRE){
        $$ = concat_pere_fils(
              creer_noeud(
                $1,
                num_decla_idf,
                A_VAR,
                -1,
                -1
              ),
              $3
            );
      }
      // Cet IDF correspond à un tableau, le corps sera probablement une
      // dimension, sinon, c'est une erreur
      else{
        $$ = concat_pere_fils(
              creer_noeud(
                $1,
                num_decla_idf,
                A_TAB,
                -1,
                -1
              ),
              $3
            );
      }
    }
  }
  numero_var = INIT;
}
         ;

corps_variable : CROCHET_OUVRANT expression CROCHET_FERMANT corps_variable {

  if(numero_var == VAR_SIMPLE){
    fprintf(
      stderr,
      "\nErreur l:%d -> impossible d'indicer une variable.\n",
      nb_ligne
    );
    erreur_semantique++;
    $$ = creer_noeud(
        -1,
        -1,
        -1,
        -1,
        -1
      );
  }
  else if(numero_var == STRUCTURE){
    fprintf(
      stderr,
      "\nErreur l:%d -> impossible d'indicer une structure.\n",
      nb_ligne
    );
    erreur_semantique++;
    $$ = creer_noeud(
        -1,
        -1,
        -1,
        -1,
        -1
      );
  }
  else{
    $$ = concat_pere_fils($2, $4);
    }
}
               | POINT {

   if(numero_var == VAR_SIMPLE){
     fprintf(
       stderr,
       "\nErreur l:%d -> une variable simple ne possède pas de champs.\n",
       nb_ligne
     );
     erreur_semantique++;
   }
   else if(numero_var == DIMENSION && type < 4){
     fprintf(
       stderr,
       "\nErreur l:%d -> Un tableau de types simple n'a pas de champ.\n",
       nb_ligne
     );
     erreur_semantique++;

   }
               }
    variable {
      if(!erreur_semantique){
        $$ = $3;
      }else{
        $$ = creer_noeud(
            -1,
            -1,
            -1,
            -1,
            -1
          );
      }
    }
               | {$$ = creer_arbre_vide();}
               ;

expression : concatenation {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_EXPRESSION, -1, -1.0), $1);
  type = TYPE_STR;
}
           | e1 {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_EXPRESSION, -1, -1.0), $1);
}
           ;

concatenation : CSTE_CHAINE {
  $$ = creer_noeud($1, -1, CSTE_CHAINE, -1, -1.0);
}
              | CSTE_CHAINE PLUS concatenation {
  $$ = concat_pere_fils(
    creer_noeud(1, -1, A_CONCAT, -1, -1.0),
    concat_pere_frere(
      creer_noeud($1, -1, A_CSTE_CHAINE, -1, -1.0),
      $3
      )
  );
}
              ;

e1 : e1 {type_g = type;} PLUS e2 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_PLUS, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_arithm(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
       type = 0;
     }
     else{
       type = type_g;
     }
   }
   | e1 {type_g = type;} MOINS e2 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_MOINS, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_arithm(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
       type = 0;
     }
     else{
       type = type_g;
     }
   }
   | e1 {type_g = type;} OU e2 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_OU, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_bool(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
     }
     type = TYPE_BOOL;
   }
   | e2 {$$ = $1;}
   ;

e2 : e2 {type_g = type;} MULT e3 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_MULT, -1, -1.0),
         concat_pere_frere($1, $4)
       );

    type_d = type;
    if(verif_type_expr_arithm(type_g, type_d, nb_ligne) == -1){
      erreur_semantique++;
      type = 0;
    }
    else{
      type = type_g;
    }
   }
   | e2 {type_g = type;} DIV e3 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_DIV, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_arithm(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
       type = 0;
     }
     else{
       type = type_g;
     }
   }
   | e2 {type_g = type;} MODULO e3 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_MODULO, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_arithm(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
       type = 0;
     }
     else{
       type = type_g;
     }
   }
   | e2 {type_g = type;} ET e3 {
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_ET, -1, -1.0),
         concat_pere_frere($1, $4)
       );
     type_d = type;
     if(verif_type_expr_bool(type_g, type_d, nb_ligne) == -1){
       erreur_semantique++;
     }
     type = TYPE_BOOL;
   }
   | e3 {$$ = $1;}
   ;

e3 : e3 {type_g = type;} operateur_comp e4 {
     $$ = concat_pere_fils(
         $3,
         concat_pere_frere($1, $4)
       );

     // Vérification sémantique des types donnés
     type_d = type;

     // Comparaison de booleen avec autre chose qu'un booleen
     if((type_g == TYPE_BOOL && type_d != TYPE_BOOL)
       ||(type_g != TYPE_BOOL && type_d == TYPE_BOOL)
     ){
       fprintf(
         stderr,
         "\nErreur l:%d -> comparaison d'un booleen avec un non booleen.\n",
         nb_ligne
       );
       erreur_semantique++;
     }

     // Comparaison entre booleen autres que == et !=
     if(type_g == TYPE_BOOL && type_d == TYPE_BOOL){
       type = TYPE_BOOL;
       if($3->nature != EGAL && $3->nature != DIFFERENT){
         fprintf(
           stderr,
           "\nErreur l:%d -> comparaison d'ordre entre booleens impossible.\n",
           nb_ligne
         );
         erreur_semantique++;
      }
    }

    type = TYPE_BOOL;
   }
   | e4 {$$ = $1;}
   ;

e4 : NON e5 {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_NON, -1, -1), $2);
  type = TYPE_BOOL;
}
   | e5 {
     $$ = $1;
   }
   ;

e5 : PARENTHESE_OUVRANTE e1 PARENTHESE_FERMANTE {$$ = $2;}
   | CSTE_ENTIERE {
     $$ = creer_noeud(-1, -1, A_CSTE_ENT, $1, -1.0);
     type = TYPE_INT;
   }
   | CSTE_REELLE  {
     $$ = creer_noeud(-1, -1, A_CSTE_REEL, -1, $1);
     type = TYPE_FLOAT;
   }
   | CSTE_CARACTERE {
     $$ = creer_noeud(-1, -1, A_CSTE_CHAR, $1, -1.0);
     type = TYPE_CHAR;
   }
   | un_booleen {
     $$ = $1;
     type = TYPE_BOOL;
   }
   | variable {
     $$ = $1;
   }
   | appel  {
     // On cherche à savoir si l'on est en face d'une procedure ou bien
     // d'une fonction
     // Ici un appel de procedure sera une erreur, une procedure ne renvoyant
     // rien
     int num_decl_appel = num_decla($1->numlex, FCT, -1);

     if(num_decl_appel == -1){ // Fonction non trouvée
       // Une procedure est-elle appelée à la place ?
       num_decl_appel = num_decla($1->numlex, PROC, -1);
       if(num_decl_appel == -1){ // Rien de déclaré pour ce lexème
         fprintf(
           stderr,
           "\nErreur l:%d -> %s non déclaré.\n",
           nb_ligne,
           lexeme($1->numlex)
           );
       }
       else{
         fprintf(
           stderr,
           "\nErreur l:%d -> Appel d'une procedure (%s) dans une expression.\n",
           nb_ligne,
           lexeme($1->numlex)
           );
       }
     }
     else{ // Réglages des élements restés en suspend durant l'appel
       $1->numdecl = num_decl_appel;
       $1->nature = A_APPEL_FCT;
       if(verif_arg_appel(num_decl_appel, tab_arg_appel, nb_ligne) == -1){
         erreur_semantique++;
       }
     }

     $$ = $1;
   }
   ;

un_booleen : TRUE {$$ = creer_noeud(-1, -1, A_TRUE, -1, -1.0);}
           | FALSE {$$ = creer_noeud(-1, -1, A_TRUE, -1, -1.0);}
           ;

operateur_comp : EGAL  {$$ = creer_noeud(-1, -1, A_EGAL, -1, -1.0);}
               | DIFFERENT  {$$ = creer_noeud(-1, -1, A_DIFFERENT, -1, -1.0);}
               | SUP  {$$ = creer_noeud(-1, -1, A_SUP, -1, -1);}
               | SUP_EGAL {$$ = creer_noeud(-1, -1, A_SUP_EGAL, -1, -1.0);}
               | INF  {$$ = creer_noeud(-1, -1, A_INF, -1, -1);}
               | INF_EGAL {$$ = creer_noeud(-1, -1, A_INF_EGAL, -1, -1.0);}
               ;

afficher : AFFICHER PARENTHESE_OUVRANTE CSTE_CHAINE {
    // On analyse le format donné
    format(yytext);
    tab_var_format[0] = 0;
  }
  suite_afficher {
    // On compare ici le format recu

    int i;
    // Trop de formats
    if(tab_format[0] > tab_var_format[0]){
      fprintf(stderr, "\nErreur l:%d -> afficher, trop de formats\n", nb_ligne);
      erreur_semantique++;
    }
    // Trop d'arguments suivants le format
    else if(tab_var_format[0] > tab_format[0]){
      fprintf(
        stderr,
        "\nErreur l:%d -> afficher, trop d'arguments\n",
        nb_ligne
      );
      erreur_semantique++;
    }
    // Les cardinaux sont cohérents, on regarde si les éléments sont cohérents
    else{
      for(i = 1; i < tab_format[0]+1; i++){
        if(tab_format[i] != tab_var_format[i] && tab_var_format[i] != -1){
          fprintf(stderr,
            "\nErreur l:%d -> Le format numéro %d ne corespond pas...\n",
            nb_ligne, i
          );
          erreur_semantique++;
        }
      }
    }
  }
  PARENTHESE_FERMANTE {
    $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_AFFICHER, -1, -1.0),
        concat_pere_frere(
          creer_noeud($3, -1, A_CSTE_CHAINE, -1, -1.0),
          $5
        )
      );
  }
         ;

suite_afficher : VIRGULE {
                  tab_var_format[0]++;
                }
  composante_afficher
  suite_afficher {
    $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_LISTE_ARG, -1, -1),
      concat_pere_frere($3, $4)
    );
  }
               | {
    $$ = creer_arbre_vide();
  }
               ;


composante_afficher : variable       {
                      // On récupère le type de la variable appellée
                      tab_var_format[tab_var_format[0]] = type;
                      $$ = $1;
                    }
                    | appel       {
    // On cherche à savoir si l'on est en face d'une procedure ou bien
    // d'une fonction
    // Ici un appel de procedure sera une erreur, une procedure ne renvoyant
    // rien
    int num_decl_appel = num_decla($1->numlex, FCT, -1);

    if(num_decl_appel == -1){ // Fonction non trouvée
      // Une procedure est-elle appelée à la place ?
      num_decl_appel = num_decla($1->numlex, PROC, -1);
      if(num_decl_appel == -1){ // Rien de déclaré pour ce lexème
        fprintf(
          stderr,
          "\nErreur l:%d -> %s non déclaré.\n",
          nb_ligne,
          lexeme($1->numlex)
          );
        erreur_semantique++;
      }
      else{
        fprintf(
          stderr,
          "\nErreur l:%d -> Affichage d'une procedure (%s) impossible.\n",
          nb_ligne,
          lexeme($1->numlex)
          );
        erreur_semantique++;
      }
    }
    else{ // Réglages des élements restés en suspend durant l'appel
      $1->numdecl = num_decl_appel;
      $1->nature = A_APPEL_FCT;
      if(verif_arg_appel(num_decl_appel, tab_arg_appel, nb_ligne) == -1){
        erreur_semantique++;
      }
    }

    $$ = $1;
                    }
                    | CSTE_ENTIERE       {
                      tab_var_format[tab_var_format[0]] = TYPE_INT;
                      $$ = creer_noeud(-1, -1, A_CSTE_ENT, $1, -1.0);
                    }
                    | CSTE_REELLE       {
                      tab_var_format[tab_var_format[0]] = TYPE_FLOAT;
                      $$ = creer_noeud(-1, -1, A_CSTE_REEL, -1, $1);
                    }
                    | TRUE       {
                      tab_var_format[tab_var_format[0]] = TYPE_BOOL;
                      $$ = creer_noeud(-1, -1, A_TRUE, 1, -1.0);
                    }
                    | FALSE       {
                      tab_var_format[tab_var_format[0]] = TYPE_BOOL;
                      $$ = creer_noeud(-1, -1, A_FALSE, -1, -1.0);
                    }
                    | CSTE_CARACTERE       {
                      tab_var_format[tab_var_format[0]] = TYPE_CHAR;
                      $$ = creer_noeud(-1, -1, A_CSTE_CHAR, $1, -1.0);
                    }
                    | CSTE_CHAINE       {
                      tab_var_format[tab_var_format[0]] = TYPE_STR;
                      $$ = creer_noeud($1, -1, A_CSTE_CHAINE, -1, -1.0);
                    }
                    ;

lire : LIRE PARENTHESE_OUVRANTE liste_variables PARENTHESE_FERMANTE {
  $$ = concat_pere_fils(
    creer_noeud(-1, -1, A_LIRE, -1, -1.0),
    $3
  );
}
     ;

liste_variables : variable VIRGULE liste_variables {
  $$ = concat_pere_fils(
    creer_noeud(-1, -1, A_LISTE_VAR, -1, -1),
    concat_pere_frere($1, $3)
  );
}
                | variable {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_LISTE_VAR, -1, -1), $1);
}
                ;


%%

int yyerror(){
  fprintf(stderr, "\nErreur de syntaxe ligne %d : %s\n\n", nb_ligne, yytext);
  syntaxe_correcte = 0;
}

int main(int argc, char *argv[]){
  init_pile_region();
  init_table_lexico();
  init_tab_decla();
  init_tab_representation_type();

  // L'utilisateur souhaite afficher l'usage correct' du compilateur
  if(argc > 1 && (argv[1][0] == 'h' || argv[1][0] == 'H')){
    usage(argv[0]);
  }
  // L'utilisateur souhaite afficher les arbres produits par le compilateur
  if(argc > 4 && atoi(argv[4]) == 1){
    aff_arbre++;
  }

  yyparse();

  if(!syntaxe_correcte){
    printf("\nLA SYNTAXE N'EST PAS RESPECTEE, COMPILATION IMPOSSIBLE\n\n");
  }
  else if(erreur_semantique){
    fprintf(
      stderr,
      "\nLA SYNTAXE EST CORRECTE MAIS IL Y A %d ERREURS SEMANTIQUES\n",
      erreur_semantique
    );
  }

  // L'utilisateur souhaite afficher la table lexicographique
  if(argc > 1 && atoi(argv[1]) == 1){
    affiche_table_lexico();
    printf("\n");
  }
  // L'utilisateur souhaite afficher la table des déclarations
  if(argc > 2 && atoi(argv[2]) == 1){
    afficher_tab_declaration();
    printf("\n");
  }
  // L'utilisateur souhaite afficher la table de représentations des types
  if(argc > 3 && atoi(argv[3]) == 1){
    afficher_tab_representation();
    printf("\n");
  }
}
