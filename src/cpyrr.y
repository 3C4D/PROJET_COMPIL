%{
#include<stdlib.h>
#include<stdio.h>
#include "../arbres/inc/arbres.h"
#include "../inc/fct_aux_yacc.h"
#include "../TabLexico/inc/TabLexico.h"
#include "../TabRepresentation/inc/TabRepresentation.h"
#include "../TabDecla/inc/TabDecla.h"
#include "../inc/macros_arbres.h"
#include "../TabRegion/inc/TabRegion.h"
#include "../GenTexte/inc/GenTexte.h"
#include "../inc/couleur.h"

int yylex();
int yyerror();

extern FILE *programme;
extern char *yytext;
extern int nb_ligne;
extern int ligne_act;
extern FILE *yyin;
extern int colonne;

extern int tab_format[MAX_FORMAT+1];
extern int pile_region[MAX_REGION+1];
extern int deplacement_var[MAX_REGION];
extern int deplacement_structure;
extern int nis_region;

// Flags d'affichage
int flags[] = {0, 0, 0, 0, 0};

int tab_var_format[40];
int tab_arg_appel[40];

// Tableaux servant à la vérification sémantiques des retours de fct/proc
int inst_retour[40];

int syntaxe_correcte = 1;
int erreur_semantique = 0;
int num_region = 0;
int num_region_engendree;
int num_declaration;
int diff = 0;

// Variable servant à déterminer si l'on est dans une imbrication
// (ex : dans un if)
int imbrique = 0;

int nb_parametres;
int nb_champs;
int nb_dim;

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
programme : PROG {
          change_NIS(1);
          change_deplacement(0);
          inst_retour[0] = 0;
}
          corps {$$ = $3; inserer_tab_region(deplacement(), 0);}
          ;

corps : liste_declarations liste_instructions {
  $$ = $2; inserer_arbre_tab_region($2);
}
      ;

liste_declarations : liste_declarations_type
                     liste_declarations_variable
                     liste_declarations_proc_fct
                   ;

liste_declarations_type :
                        | liste_declarations_type
                          declaration_type
                        ;

liste_declarations_variable :
                            | liste_declarations_variable
                              declaration_variable
                              POINT_VIRGULE
                            ;

liste_declarations_proc_fct :
                            | liste_declarations_proc_fct
                              une_declaration_proc_fct
                            ;

une_declaration_proc_fct :   declaration_procedure
                           | declaration_fonction
                           ;


liste_instructions : DEBUT suite_liste_inst FIN {
  $$ = $2;
  if(flags[4]){
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

declaration_type : TYPE IDF DEUX_POINTS suite_declaration_type {
  if(inserer_tab_declaration(
      $2,
      $4,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    ) == -1){
      erreur_semantique++;
    };
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
      /*Vérification de l'existance du type*/

      if(num_decla_type($5) == -1){
        print_erreur_semantique("type nom déclaré.");
        erreur_semantique++;
      }
      /*Mise à jour des 2 premières cases*/
      stocker_table_representation(premier_indice(), num_decla_type($5));
      stocker_table_representation(premier_indice()+1, nb_dim);
      $$ = TYPE_TAB;
}
                       ;

dimension : CROCHET_OUVRANT liste_dimensions CROCHET_FERMANT {$$ = $2;}
          ;

liste_dimensions : une_dimension { $$ = $1; }
                 | liste_dimensions VIRGULE une_dimension
                ;

une_dimension : CSTE_ENTIERE SOULIGNE CSTE_ENTIERE {
  nb_dim += 1;
  /*Vérification de l'ordre des bornes*/
  if($1 > $3){
    print_erreur_semantique("problème de dimension dans le tableau, bornes inversées.");
    erreur_semantique++;
  }
  $$=inserer_tab_representation_type($1, $3, TYPE_TAB);
}
              ;

liste_champs : un_champ POINT_VIRGULE {$$ = $1;}
             | liste_champs un_champ POINT_VIRGULE
             ;

un_champ : IDF DEUX_POINTS nom_type {
  nb_champs += 1;
  if(num_decla_type($3) == -1){
    char erreur[400];
    sprintf(
      erreur,
      "type du champs %d de la structure non déclaré.",
      nb_champs
    );
    print_erreur_semantique(erreur);
    erreur_semantique++;
  }
  $$ = inserer_tab_representation_type(num_decla_type($3), $1, TYPE_STRUCT);
  stocker_table_representation($$+2, deplacement_struct());
  change_deplacement_struct(deplacement_struct() + valeur_exec_tab_decla($3));

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
   if(num_decla_type($4) == -1){
     print_erreur_semantique("variable de type non déclaré.");
     erreur_semantique++;
   }
   num_declaration = inserer_tab_declaration($2, VAR, tete_pile_region(), num_decla_type($4), nb_ligne);
   if(num_declaration == -1){
     erreur_semantique++;
   }
   inserer_exec_tab_decla(num_declaration, deplacement());
   change_deplacement(valeur_exec_tab_decla(valeur_description_tab_decla(num_declaration)));
}
                      ;

declaration_procedure : PROCEDURE IDF {
  int num_avant;
  nb_parametres = 0;
  /*On reserve une case pour le nombre de parametres*/
  change_premier_indice(inserer_tab_representation_type(-99,-1, PROC));

  if(inserer_tab_declaration(
      $2,
      PROC,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    ) == -1){
      erreur_semantique++;
    }

  num_avant = tete_pile_region();
  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
  change_NIS(1); //Car on rentre dans une région

  inserer_exec_tab_decla(num_decla($2, PROC, num_avant),tete_pile_region());
}
                      liste_parametres {
  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), nb_parametres);

}
                      corps {
   change_NIS(-1); //Car on sort d'une région
   inserer_tab_region(deplacement(), nis());

   depiler_pile_region();
}
                      ;

declaration_fonction  : FONCTION IDF {
  int num_avant;
  nb_parametres = 0;
  /*On reserve 2 cases pour le nombre de parametres
  et la nature du renvoie*/
  change_premier_indice(inserer_tab_representation_type(-99,-99,FCT));

  if(inserer_tab_declaration(
      $2,
      FCT,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    ) == -1 ){
      erreur_semantique++;
    }

  num_avant = tete_pile_region();
  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
  change_NIS(1); //On ajoute un niveau d'imbrication car on rentre dans une nouvelle région

  inserer_exec_tab_decla(num_decla($2, FCT, num_avant),tete_pile_region());
}
                        liste_parametres RETOURNE type_simple {
  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), $6);
  stocker_table_representation(premier_indice()+1, nb_parametres);
}
                    corps {
  if(inst_retour[tete_pile_region()] == 0){
    char erreur[400];
    sprintf(
      erreur,
      "aucune instruction de retour pour la fonction %s.",
      lexeme($2)
    );

    print_erreur_semantique(erreur);
    erreur_semantique++;
  }
  change_NIS(-1); //Car on sort d'une région
  inserer_tab_region(deplacement(), nis());
  depiler_pile_region();
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
  if(num_declaration == -1){
    erreur_semantique++;
  }
  inserer_exec_tab_decla(num_declaration, deplacement());
  change_deplacement(valeur_exec_tab_decla(valeur_description_tab_decla(num_declaration)));
}
         ;

instruction : affectation POINT_VIRGULE {
  $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_AFFECTATION, -1, -1.0),
      $1
    );
}
            | condition {$$ = $1;}
            | {imbrique++;} tant_que {$$ = $2;imbrique--;}
            | afficher POINT_VIRGULE {$$ = $1;}
            | lire POINT_VIRGULE {$$ = $1;}
            | appel POINT_VIRGULE {

          // Un appel sans exploitation de la valeur de retour doit être une
          // procedure, sinon erreur
          int num_decl_appel = num_decla($1->numlex, PROC, -1);

          if(num_decl_appel == -1){ // Rien de déclaré pour ce lexème
            char erreur[400];
            sprintf(
              erreur,
              "procedure %s non déclarée.",
              lexeme($1->numlex)
            );
            print_erreur_semantique(erreur);
            erreur_semantique++;
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

resultat_retourne : un_arg {
  $$ = $1;
  if(nature(num_decl_reg(tete_pile_region())) != FCT){
    print_erreur_semantique(
      "instruction de retour non vide pour une procedure."
    );
    erreur_semantique++;
  }
  else if(
    valeur_tab_representation(
      valeur_description_tab_decla(num_decl_reg(tete_pile_region()))
    )
    != type
  ){
    print_erreur_semantique(
      "type de retour incorrect."
    );
    erreur_semantique++;
  }
  else if(!imbrique){
    inst_retour[tete_pile_region()]++;
  }
}
                  | {
    $$ = creer_arbre_vide();
    if(nature(num_decl_reg(tete_pile_region())) == FCT){
      print_erreur_semantique(
        "instruction de retour vide dans une fonction."
      );
      erreur_semantique++;
    }
}
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

 condition : {imbrique++;} SI expression
            ALORS liste_instructions {imbrique--;} sinon {
   if(est_vide($7)){
     $$ = concat_pere_fils(
         creer_noeud(-1, -1, A_SI_ALORS, -1, -1.0),
         concat_pere_frere(
           $3,
           concat_pere_frere($5, $7)
         )
       );
    }
    else{
      $$ = concat_pere_fils(
          creer_noeud(-1, -1, A_SI_ALORS_SINON, -1, -1.0),
          concat_pere_frere(
            $3,
            concat_pere_frere($5, $7)
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
    print_erreur_semantique(
      "affectation de deux choses de types différents."
    );
    erreur_semantique++;
    $$ = creer_noeud(-1, -1, -1, -1, -1.0);
  }
  else{
    $$ = concat_pere_frere(
          $1,
          $4
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
        char erreur[400];
        sprintf(erreur, "%s non déclaré.", lexeme($1));
        print_erreur_semantique(erreur);
        erreur_semantique++;
      }
      // Cet IDF correspond à une variable (ou à un paramètre)
      else if(nature(num_decla_idf) == VAR
          || nature(num_decla_idf) == PARAMETRE){
        type = valeur_description_tab_decla(num_decla_idf);

        if(type > 4){     // La variable est une srtucture
          if(nature(type) == TYPE_STRUCT){
            numero_var = STRUCTURE;
          }
          else{
            numero_var = DIMENSION;
          }
        }
        else{             // La variable est de type simple
          numero_var = VAR_SIMPLE;
        }
      }
      // Cas non traité ?
      else{
        print_erreur_semantique(
          "type inconnu."
        );
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
        char erreur[400];
        sprintf(erreur, "%s : aucun champ correspondant.", lexeme($1));
        print_erreur_semantique(erreur);
        erreur_semantique++;
      }
    }

}
  corps_variable {
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
    print_erreur_semantique("impossible d'indicer une variable.");
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
    print_erreur_semantique("impossible d'indicer une structure.");
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
     print_erreur_semantique("une variable simple ne possède pas de champs.");
     erreur_semantique++;
   }
   else if(numero_var == DIMENSION && type < 4){
     print_erreur_semantique("un tableau de types simple n'a pas de champ.");
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
       print_erreur_semantique(
         "comparaison d'un booleen avec un non booleen."
       );
       erreur_semantique++;
     }

     // Comparaison entre booleen autres que == et !=
     if(type_g == TYPE_BOOL && type_d == TYPE_BOOL){
       type = TYPE_BOOL;
       if($3->nature != EGAL && $3->nature != DIFFERENT){
         print_erreur_semantique(
           "comparaison d'ordre entre booleens impossible."
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
  if(type != TYPE_INT && type != TYPE_INT){
    print_erreur_semantique(
      "opérateur NOT sur autre chose qu'un booleen ou un entier impossible."
    );
    erreur_semantique++;
  }
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
         char erreur[400];
         sprintf(erreur, "%s non déclaré.", lexeme($1->numlex));
         print_erreur_semantique(erreur);
         erreur_semantique++;
       }
       else{
         char erreur[400];
         sprintf(
           erreur,
           "appel d'une procedure (%s) dans une expression.",
           lexeme($1->numlex)
         );
         print_erreur_semantique(erreur);
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
      print_erreur_semantique(
        "trop de formats dans la fonction afficher."
      );
      erreur_semantique++;
    }
    // Trop d'arguments suivants le format
    else if(tab_var_format[0] > tab_format[0]){
      print_erreur_semantique(
        "trop d'arguments dans la fonction afficher."
      );
      erreur_semantique++;
    }
    // Les cardinaux sont cohérents, on regarde si les éléments sont cohérents
    else{
      for(i = 1; i < tab_format[0]+1; i++){
        if(tab_format[i] != tab_var_format[i] && tab_var_format[i] != -1){
          char erreur[250];
          sprintf(erreur, "le format numéro %d ne corespond pas.", i);
          print_erreur_semantique(erreur);
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
        char erreur[400];
        sprintf(
          erreur,
          "%s non déclaré.",
          lexeme($1->numlex)
        );
        erreur_semantique++;
      }
      else{
        char erreur[400];
        sprintf(
          erreur,
          "affichage d'une procedure (%s) impossible.",
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
  int i;
  char c = '\0';

  // Plus d'une erreur sur une ligne, on passe
  if(ligne_act >= nb_ligne){
    return -1;
  }

  // On egraine jusqu'à la ligne
  for(i = ligne_act; i < nb_ligne-1; i++){
    c = '\0';
    while(c != '\n'){
      c = fgetc(programme);
    }
  }

  couleur(ROUGEGRAS);
  // On imprime la ligne précédée du numéro de ligne
  fprintf(stderr, "\nErreur de syntaxe\n");
  couleur(BLANCGRAS);
  fprintf(stderr, " %d |  ", nb_ligne);
  couleur(RESET);
  c = '\0';
  c = fgetc(programme);
  while(c != '\n'){
    fprintf(stderr, "%c", c);
    c = fgetc(programme);
  }
  couleur(BLANCGRAS);
  fprintf(stderr, "\n    |");
  for(i = 0; i < colonne+1; i++){
    fprintf(stderr, " ");
  }
  couleur(ROUGEGRAS);
  fprintf(stderr, "^\n\n");
  couleur(RESET);
  syntaxe_correcte = 0;
  return -1;
}

int main(int argc, char *argv[]){
  FILE *fic = NULL;
  int index_fic;

  init_pile_region();
  init_table_lexico();
  init_tab_decla();
  init_tab_representation_type();
  init_tab_region();

  if(argc < 2){
    usage(argv[0]);
    exit(-1);
  }

  // On redirige l'entrée standard du yacc
  if((yyin = fopen(argv[argc-1], "r")) == NULL){
    fprintf(stderr, "\nImpossible d'ouvrir le fichier %s\n", argv[argc-1]);
    usage(argv[0]);
  }
  // On initialise notre marqueur d'erreur
  else{
    if((programme = fopen(argv[argc-1], "r")) == NULL){
      fprintf(stderr, "\nImpossible d'ouvrir le fichier %s\n", argv[argc-1]);
      usage(argv[0]);
    }
  }

  index_fic = analyse_options(argv, flags);

  yyparse();

  // Pas de fichier output précisé
  if(index_fic == -1){
    if((fic = fopen("a.out", "w")) == NULL){
      fprintf(stderr, "\nImpossible d'ouvrir le fichier a.out\n");
      usage(argv[0]);
    }
  }
  // Fichier précisé, on essaye de le créer
  else{
    if(!erreur_semantique
    && syntaxe_correcte
    && (fic = fopen(argv[index_fic], "w")) == NULL){
      fprintf(stderr, "\nimpossible d'ouvrir %s\n", argv[index_fic]);
      usage(argv[0]);
    }
  }

  // L'utilisateur souhaite afficher la table lexicographique
  if(flags[0]){
    affiche_table_lexico();
    printf("\n");
  }
  // L'utilisateur souhaite afficher la table des déclarations
  if(flags[1]){
    afficher_tab_declaration();
    printf("\n");
  }
  // L'utilisateur souhaite afficher la table de représentations des types
  if(flags[2]){
    afficher_tab_representation();
    printf("\n");
  }

  // L'utilisateur souhaite afficher la table des régions
  if(flags[3]){
    afficher_tab_region();
    printf("\n");
  }



  // Génération du texte intermédiaire
  if(!erreur_semantique && syntaxe_correcte){
    generer_texte_intermediaire(fic);
  }
  exit(0);
}
