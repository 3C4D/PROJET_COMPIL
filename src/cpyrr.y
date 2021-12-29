%{
#include<stdlib.h>
#include<stdio.h>
#include <string.h>
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
int tab_arg_appel[40][40];
int num_champ = -1;

int num_avant; //Num région déclaration d'une fonction

// Tableaux servant à la vérification sémantiques des retours de fct/proc
int inst_retour[40];

int syntaxe_correcte = 1;
int erreur_semantique = 0;
int num_region = 0;
int num_region_engendree;
int num_declaration;
int diff = 0;

int num_ligne_decla;

int nom_type;

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

%type<typ2> moins declaration_type declaration_fonction declaration_variable
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

declaration_type : TYPE IDF {num_ligne_decla = nb_ligne; nom_type = $2;} DEUX_POINTS suite_declaration_type {
  if(inserer_tab_declaration(
      $2,
      $5,
      tete_pile_region(),
      premier_indice(),
      nb_ligne
    ) == -1){
      char erreur[400];
      int num_decla_type;

      if(num_decla($2, TYPE_STRUCT, tete_pile_region()) != -1){
        num_decla_type = num_decla($2, TYPE_STRUCT, tete_pile_region());
      }else{
        num_decla_type = num_decla($2, TYPE_TAB, tete_pile_region());
      }

      if(nature(num_decla_type) == TYPE_STRUCT){
        int ligne_decla_type  = valeur_tab_representation(
          valeur_description_tab_decla(num_decla_type)+ 1 + 3*valeur_tab_representation(valeur_description_tab_decla(num_decla_type))
          );
        sprintf(erreur,
          "Il existe déjà une structure de nom %s dans la région %s ligne %d",
          lexeme($2),
          nom_reg(tete_pile_region()),
          ligne_decla_type
          );

      }else if(nature(num_decla_type) == TYPE_TAB){
        int ligne_decla_type  = valeur_tab_representation(
          valeur_description_tab_decla(num_decla_type) + 2 + 2*valeur_tab_representation(valeur_description_tab_decla(num_decla_type)+1)
          );

        sprintf(erreur,
          "Il existe déjà un tableau de nom %s dans la région %s ligne %d",
          lexeme($2),
          nom_reg(tete_pile_region()),
          ligne_decla_type
          );
      }
      print_erreur_semantique(erreur);
      erreur_semantique++; //On signale quand même l'erreur
    };
    ajouter_table_represention(num_ligne_decla); //Ligne de la déclaration du type
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
    if(verif_surcharge_struct(premier_indice(),num_ligne_decla, nom_type) == -1){
      fprintf(stderr, "Erreur d'insertion dans la table des representations");
      erreur_semantique++; //On signale l'erreur
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
        char erreur[400];
        if(tete_pile_region() == 0){
          sprintf(erreur,
            "Type des éléments du tableau %s déclaré ligne %d non déclaré, le type '%s' n'existe pas la région %s",
            lexeme(nom_type),
            num_ligne_decla,
            lexeme($5),
            nom_reg(tete_pile_region())
           );

        }else{
          sprintf(erreur,
            "Type des éléments du tableau %s déclaré ligne %d non déclaré, le type '%s' n'existe pas la région %s ni dans ses régions englobantes",
            lexeme(nom_type),
            num_ligne_decla,
            lexeme($5),
            nom_reg(tete_pile_region())
           );
        }
        print_erreur_semantique(erreur);
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
    char erreur[400];
    sprintf(
      erreur,
      "Problème de dimensions dans le tableau %s déclarée ligne %d, la borne inférieure et la borne supérieure de la dimension numéro %d sont inversées -> (borne inf) %d > %d (borne sup)",
      lexeme(nom_type),
      num_ligne_decla,
      nb_dim,
      $1,
      $3
    );
    print_erreur_semantique(erreur);
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
    if(tete_pile_region() == 0){
      sprintf(
      erreur,
      "Le type du champs numéro %d de la structure %s declarée ligne %d est non déclaré, le type '%s' n'existe pas dans la region %s.",
      nb_champs,
      lexeme(nom_type),
      num_ligne_decla,
      lexeme($3),
      nom_reg(tete_pile_region())
      );
    }else{
      sprintf(
      erreur,
      "Le type du champs numéro %d de la structure %s declarée ligne %d est non déclaré, le type '%s' n'existe pas dans la region %s ni dans ses régions englobantes.",
      nb_champs,
      lexeme(nom_type),
      num_ligne_decla,
      lexeme($3),
      nom_reg(tete_pile_region())
      );
    }
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

declaration_variable  : VARIABLE {num_ligne_decla= nb_ligne;} IDF DEUX_POINTS nom_type {
   if(num_decla_type($5) == -1){
     char erreur[400];
     if(tete_pile_region() == 0){
       sprintf(erreur,
       "La variable %s est de type non déclaré, le type '%s' n'existe pas dans la région %s",
       lexeme($3),
       lexeme($5),
       nom_reg(tete_pile_region())
       );
     }else{
       sprintf(erreur,
       "La variable %s est de type non déclaré, le type '%s' n'existe pas dans la région %s ni dans ses régions englobantes",
       lexeme($3),
       lexeme($5),
       nom_reg(tete_pile_region())
       );
     }

     print_erreur_semantique(erreur);
     erreur_semantique++;
   }
   num_declaration = inserer_tab_declaration($3, VAR, tete_pile_region(), num_decla_type($5), nb_ligne);
   /*Vérification de la surcharge*/

   if(num_declaration == -1){
     char erreur[400];
     int num_decla_type;
     if(num_decla($3, PARAMETRE, tete_pile_region()) != -1){
       num_decla_type = num_decla($3, PARAMETRE, tete_pile_region());
     }else{
       num_decla_type = num_decla($3, VAR, tete_pile_region());
     }

     if(nature(num_decla_type) == PARAMETRE){
       sprintf(erreur,
         "Il existe déjà un parametre de nom %s dans la région %s, il est donc impossible de définir la variable %s ligne %d",
         lexeme($3),
         nom_reg(tete_pile_region()),
         lexeme($3),
         num_ligne_decla
         );

     }else if(nature(num_decla_type) == VAR){
       sprintf(erreur,
         "Il existe déjà une variable de nom %s dans la région %s, il est donc impossible de redéfinir la variable %s ligne %d",
         lexeme($3),
         nom_reg(tete_pile_region()),
         lexeme($3),
         num_ligne_decla
         );
     }
     print_erreur_semantique(erreur);
     erreur_semantique++; //On signale quand même l'erreur
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
      char erreur[500];
      int region_induite = valeur_exec_tab_decla(num_decla($2, PROC, tete_pile_region()));
      int region_dec = region(num_decla($2, PROC, tete_pile_region()));
      sprintf(erreur,
        "Il existe déjà une procédure %s définie ligne %d dans la région %s numéro %d, il est donc impossible de la redéfinir dans cette région",
        lexeme($2),
        ligne_decla(region_induite),
        nom_reg(region_dec),
        region_dec
        );
      print_erreur_semantique(erreur);
      erreur_semantique++; //On signale l'erreur
    }

  num_avant = tete_pile_region();
  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
  change_ligne_decla(nb_ligne); //On mémorise le numéro de la ligne de déclaration
  inserer_nom_region_tab_region(lexeme($2)); //On mémorise le nom de la région
  change_deplacement(nis() + 1); //On réserve la place pour les chainages statiques/dynamique
  change_NIS(1); //Car on rentre dans une région

  inserer_exec_tab_decla(num_decla($2, PROC, num_avant),tete_pile_region());
}
                      liste_parametres {
  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), nb_parametres);
  ajouter_table_represention(ligne_decla(tete_pile_region()));

}
                      corps {
   fermeture_arbre_proc($6);
   change_NIS(-1); //Car on sort d'une région
   inserer_tab_region(deplacement(), nis());
   depiler_pile_region();
}
                      ;

declaration_fonction  : FONCTION IDF {
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
      char erreur[500];
      int region_induite = valeur_exec_tab_decla(num_decla($2, FCT, tete_pile_region()));
      int region_dec = region(num_decla($2, FCT, tete_pile_region()));
      sprintf(erreur,
        "Il existe déjà une fonction %s définie ligne %d dans la région %s numéro %d , il est donc impossible de la redéfinir dans cette région",
        lexeme($2),
        ligne_decla(region_induite),
        nom_reg(region_dec),
        region_dec
        );
      print_erreur_semantique(erreur);
      erreur_semantique++; //On signale l'erreur
    }

  num_avant = tete_pile_region();
  /*Mise à jour des num de région*/
  num_region++;
  empiler_pile_region(num_region);
  change_ligne_decla(nb_ligne); //On mémorise le numéro de la ligne de déclaration
  inserer_nom_region_tab_region(lexeme($2)); //On mémorise le nom de la région
  change_deplacement(nis() + 1); //On réserve la place pour les chainages statiques/dynamique
  change_NIS(1); //On ajoute un niveau d'imbrication car on rentre dans une nouvelle région


  inserer_exec_tab_decla(num_decla($2, FCT, num_avant),tete_pile_region());
}
                        liste_parametres RETOURNE type_simple {
  /*Mise à jour de la première case*/
  stocker_table_representation(premier_indice(), $6);
  stocker_table_representation(premier_indice()+1, nb_parametres);
  ajouter_table_represention(ligne_decla(tete_pile_region()));
}
                    corps {
  if(inst_retour[tete_pile_region()] == 0){
    char erreur[400];
    sprintf(
      erreur,
      "Aucune instruction de retour pour la fonction %s déclarée ligne %d dans la région %s numéro %d. La fonction devrait renvoyer un element de type %s",
      lexeme($2),
      ligne_decla(tete_pile_region()),
      nom_reg(num_avant),
      num_avant,
      lexeme(decl2lex(valeur_tab_representation(valeur_description_tab_decla($2))))
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
  /*Vérification de la surcharge*/
  if(num_declaration == -1){
    char erreur[400];
    int num_decla_type;

    if(num_decla($1, PARAMETRE, tete_pile_region()) != -1){
      num_decla_type = num_decla($1, PARAMETRE, tete_pile_region());
    }else{
      num_decla_type = num_decla($1, VAR, tete_pile_region());
    }

    if(nature(num_decla_type) == PARAMETRE){
      sprintf(erreur,
        "Il existe déjà un parametre de nom %s dans la région %s déclarée ligne %d, il est donc impossible de rédéfinir un paramètre de nom même nom dans cette région",
        lexeme($1),
        nom_reg(tete_pile_region()),
        ligne_decla(tete_pile_region())
        );

    }else if(nature(num_decla_type) == VAR){
      sprintf(erreur,
        "Il existe déjà une variable de nom %s dans la région %s déclarée ligne %d, il est donc impossible de définir un paramètre de même nom dans cette région",
        lexeme($1),
        nom_reg(tete_pile_region()),
        ligne_decla(tete_pile_region())
        );
    }
    print_erreur_semantique(erreur);
    erreur_semantique++; //On signale quand même l'erreur
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
            if(tete_pile_region() == 0){
              sprintf(
               erreur,
               "Il n'existe pas de procédure %s déclarée dans la région %s",
               lexeme($1->numlex),
               nom_reg(tete_pile_region())
              );
            }else{
             sprintf(
              erreur,
              "Il n'existe pas de procédure %s déclarée dans la région %s numéro %d ni dans ses regions englobantes.",
              lexeme($1->numlex),
              nom_reg(tete_pile_region()),
              tete_pile_region()
             );
           }
           print_erreur_semantique(erreur);
           erreur_semantique++;
        }else{
            $1->numdecl = num_decl_appel;
            $1->nature = A_APPEL_PROC;
            if(verif_arg_appel(
              num_decl_appel,
              tab_arg_appel[tab_arg_appel[0][0]],
              nb_ligne
            ) == -1){
              erreur_semantique++; //On signale l'erreur
            }
          }

          /* Un appel de moins dans le tableau d'appel */
          tab_arg_appel[0][0]--;

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
  char erreur[1000];
  if(nature(num_decl_reg(tete_pile_region())) != FCT){
    if(region(num_decl_reg(tete_pile_region())) == 0){
      sprintf(
      erreur,
      "Il existe une instruction de retour pour la procédure %s déclarée ligne %d dans la région %s, ce qui est non conforme à une procédure.",
      lexeme(decl2lex(num_decl_reg(tete_pile_region()))),
      valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())) + valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())))*2 +1 ),
      nom_reg(region(num_decl_reg(tete_pile_region())))
      );
    }else{
      sprintf(
      erreur,
      "Il existe une instruction de retour pour la procédure %s déclarée ligne %d dans la région %s numéro %d, ce qui est non conforme à une procédure.",
      lexeme(decl2lex(num_decl_reg(tete_pile_region()))),
      valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())) + valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())))*2 +1 ),
      nom_reg(region(num_decl_reg(tete_pile_region()))),
      region(num_decl_reg(tete_pile_region()))
      );
    }
    print_erreur_semantique(erreur);
    erreur_semantique++;
  }
  else if(
    valeur_tab_representation(
      valeur_description_tab_decla(num_decl_reg(tete_pile_region()))
    )
    != type
  ){
    if(region(num_decl_reg(tete_pile_region())) == 0){
      sprintf(
      erreur,
      "Le type de retour de la fonction %s déclarée ligne %d dans la région %s n'est pas le bon. Prototype : func %s(",
      lexeme(decl2lex(num_decl_reg(tete_pile_region()))),
      ligne_decla(tete_pile_region()),
      nom_reg(region(num_decl_reg(tete_pile_region()))),
      lexeme(decl2lex(num_decl_reg(tete_pile_region())))
      );
    }else{
      sprintf(
      erreur,
      "Le type de retour de la fonction %s déclarée ligne %d dans la région %s numero %d n'est pas le bon. Prototype : func %s(",
      lexeme(decl2lex(num_decl_reg(tete_pile_region()))),
      ligne_decla(tete_pile_region()),
      nom_reg(region(num_decl_reg(tete_pile_region()))),
      region(num_decl_reg(tete_pile_region())),
      lexeme(decl2lex(num_decl_reg(tete_pile_region())))
      );
    }
    /*Prototype de la fonction à afficher */
    char erreur_bis[500];
    int nb_arg = valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())) + 1);
    int indice = valeur_description_tab_decla(num_decl_reg(tete_pile_region()))+2;
    for(int i =1; i<nb_arg;i++){
      sprintf(
      erreur_bis,
      "%s;",
      lexeme(valeur_tab_representation(indice))
      );
      strcat(erreur, erreur_bis);
      indice += 2;
    }
    sprintf(
      erreur_bis,
       "%s) return %s",
      lexeme(valeur_tab_representation(indice)),
      lexeme(valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region()))))
    );

    strcat(erreur, erreur_bis);

    print_erreur_semantique(erreur);
    erreur_semantique++;
  }
  else if(!imbrique){
    inst_retour[tete_pile_region()]++;
  }
}
                  | {

    $$ = creer_arbre_vide();
    if(nature(num_decl_reg(tete_pile_region())) == FCT){
      char erreur[400];
      sprintf(
        erreur,
        "L'instruction de retour de la fonction %s déclarée ligne %d dans la région %s numéro %d est vide. La fonction devrait renvoyer un élément de type %s",
        lexeme(decl2lex(num_decl_reg(tete_pile_region()))),
        ligne_decla(tete_pile_region()),
        nom_reg(region(num_decl_reg(tete_pile_region()))),
        region(num_decl_reg(tete_pile_region())),
        lexeme(decl2lex(valeur_tab_representation(valeur_description_tab_decla(num_decl_reg(tete_pile_region())))))
        );
      print_erreur_semantique(erreur);
      erreur_semantique++;
    }
}
                  ;

appel : IDF {
  /* Un appel de plus */
  tab_arg_appel[0][0]++;

  /* On initialise le tableau d'argument de l'appel */
  tab_arg_appel[tab_arg_appel[0][0]][0] = 0;

} liste_arguments {
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
  $$ = $2;
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
                     tab_arg_appel[tab_arg_appel[0][0]][0]++;

                     tab_arg_appel
                      [tab_arg_appel[0][0]]
                      [tab_arg_appel[tab_arg_appel[0][0]][0]] =type;
}
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

  // Mauvais type opérande gauche
  if(type_var_affectation > 3){
    char erreur[500];
    sprintf(
      erreur,
      "L'opérande de gauche est de type %s (declaré ligne %d), ce qui n'est pas un type simple. Pour rappel, les types simples sont int, float, bool, et char.",
      lexeme(decl2lex(type_var_affectation)),
      valeur_tab_representation(valeur_description_tab_decla(type_var_affectation)+ 1 + 3*valeur_tab_representation(valeur_description_tab_decla(type_var_affectation)))
      );
    print_erreur_semantique(erreur);
    erreur_semantique++;
    $$ = creer_noeud(-1, -1, -1, -1, -1.0);
  }
  // Mauvais type opérande droite
  else if(type > 3){
    char erreur[500];
    sprintf(
      erreur,
      "L'opérande de droite est de type %s (declaré ligne %d), ce qui n'est pas un type simple. Pour rappel, les types simples sont int, float, bool, et char.",
      lexeme(decl2lex(type)),
      valeur_tab_representation(valeur_description_tab_decla(type)+ 1 + 3*valeur_tab_representation(valeur_description_tab_decla(type)))
      );
    print_erreur_semantique(erreur);
    erreur_semantique++;
    $$ = creer_noeud(-1, -1, -1, -1, -1.0);
  }
  // Affectation de deux choses de type différent
  else if(type_var_affectation != type){
    char erreur[500];
    sprintf(
      erreur,
      "L'opérande de gauche est de type %s, et l'opérande de droite est de type %s. Les types étant différents, l'affectation ligne %d n'est donc pas possible",
      lexeme(type_var_affectation),
      lexeme(type),
      nb_ligne
      );
    print_erreur_semantique(erreur);
    erreur_semantique++;
    $$ = creer_noeud(-1, -1, -1, -1, -1.0);
  }
  else{
    $$ = concat_pere_frere(
          concat_pere_fils(
              creer_noeud(-1, -1, A_VAR, -1, -1.0),
              $1
            ),
          $4
        );
    }
}
            ;

variable : IDF {
  if(est_vide_pile_variable() || tete_pile_variable().nature != CHAMP){
    int num_decla_idf = num_decla_variable($1);

    // Elément non déclaré
    if(num_decla_idf == -1){
      char erreur[400];
      if(tete_pile_region() == 0){
        sprintf(
          erreur,
          "Il n'existe pas de variable %s dans la région %s.",
          lexeme($1),
          nom_reg(tete_pile_region())
          );
      }else{
      sprintf(
        erreur,
        "Il n'existe pas de variable %s dans la région %s numéro %d ni dans ses régions englobantes.",
        lexeme($1),
        nom_reg(tete_pile_region()),
        tete_pile_region()
        );
      }
      print_erreur_semantique(erreur);
      erreur_semantique++;
    }
    // Cet IDF correspond à une variable (ou à un paramètre)
    else {
      type = valeur_description_tab_decla(num_decla_idf);

      if(nature(type) == TYPE_STRUCT){      // TYPE_STRUCT
        empiler_pile_variable(STRUCTURE, type);
      }
      else if(nature(type) == TYPE_TAB){    // TYPE_TAB
        int i;
        int dimensions = valeur_tab_types(valeur_description_tab_decla(type)+1);
        empiler_pile_variable(TAB, valeur_tab_types(valeur_description_tab_decla(type)));
        for(i = 0; i < dimensions; i++){
          empiler_pile_variable(
            DIMENSION,
            valeur_tab_types(valeur_description_tab_decla(type))
          );
        }
      }
      else{                                 // TYPE_BASE
        empiler_pile_variable(VAR_SIMPLE, type);
      }
    }
  }
  else {
    if(tete_pile_variable().nature == CHAMP){
      int i = 0;
      // Premier indice de la struct dans la table des types
      int indice_struct = valeur_description_tab_decla(type);
      int indice_lexeme_champ = indice_struct + 2;

      depiler_pile_variable();

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

      if(type == -1){   // ERREUR
        char erreur[400];
        sprintf(
          erreur,
          "%s : aucun champ correspondant.",
          lexeme($1)
          );
        print_erreur_semantique(erreur);
        erreur_semantique++;
        empiler_pile_variable(VAR_SIMPLE, 0);
      }
      else{             // PAS ERREUR, ON EMPILE
        if(nature(type) == TYPE_STRUCT){      // TYPE_STRUCT
          empiler_pile_variable(STRUCTURE, type);
        }
        else if(nature(type) == TYPE_TAB){    // TYPE_TAB
          int i;
          int dim = valeur_tab_types(valeur_description_tab_decla(type)+1);
          empiler_pile_variable(TAB, valeur_tab_types(valeur_description_tab_decla(type)));
          for(i = 0; i < dim; i++){
            empiler_pile_variable(
              DIMENSION,
              valeur_tab_types(valeur_description_tab_decla(type))
            );
          }
        }
        else{                                 // TYPE_BASE
          empiler_pile_variable(VAR_SIMPLE, type);
        }
      }
    }
    else{ // Cas n'arrivant normalement jamais
      print_erreur_semantique("pas un champ");
      erreur_semantique++;
    }
  }
}


  corps_variable {
    int num_decla_idf = num_decla_variable($1);

    if(tete_pile_variable().nature == CHAMP){  // CHAMP
      $$ = concat_pere_fils(
        creer_noeud($1, -1, A_CHAMP, -1, -1.0),
        $3
      );
      depiler_pile_variable();
    }
    else if(tete_pile_variable().nature == VAR_SIMPLE){
      $$ = creer_noeud(
            $1,
            num_decla_idf,
            A_VAR_SIMPLE,
            -1,
            -1
          );
      depiler_pile_variable();
    }
    else if(tete_pile_variable().nature == TAB){
      $$ = concat_pere_fils(
          creer_noeud($1, num_decla_idf, A_TAB, -1, -1.0),
          $3
        );
      depiler_pile_variable();
    }
    else if(tete_pile_variable().nature == STRUCTURE){
      $$ = concat_pere_fils(
        creer_noeud($1, num_decla_idf, A_STRUCT, -1, -1.0),
        $3
      );
      depiler_pile_variable();
    }
    else if(!est_vide_pile_variable()){ // PROBLEME RENCONTRE
      if(tete_pile_variable().nature == DIMENSION){
        print_erreur_semantique(
          "Pas assez d'indice."
        );
        erreur_semantique++;
        while(tete_pile_variable().nature != TAB){
          depiler_pile_variable();
        }
        depiler_pile_variable();
      }
      erreur_semantique++;
    }
    else{
      $$ = creer_noeud(
              -1,
              -1,
              -1,
              -1,
              -1
        );
    }
  }
         ;

 corps_variable : CROCHET_OUVRANT expression CROCHET_FERMANT {
   // Vérification du type de l'expression
   if(type != TYPE_INT){
     print_erreur_semantique(
       "impossible d'indicer un tableau avec une expression non entière."
     );
     erreur_semantique++;
   }
   if(est_vide_pile_variable() || tete_pile_variable().nature != DIMENSION){
     print_erreur_semantique(
       "Trop d'indices."
     );
     erreur_semantique++;

   }
   else{
     type = tete_pile_variable().type;
     depiler_pile_variable();
   }
 }
 corps_variable {
   if(!est_vide_pile_variable() && tete_pile_variable().nature == DIMENSION){
     print_erreur_semantique(
       "Pas assez d'indice."
     );
     erreur_semantique++;
     while(tete_pile_variable().nature != TAB){
       depiler_pile_variable();
     }
   }
   if(erreur_semantique){
     $$ = creer_noeud(
         -1,
         -1,
         -1,
         -1,
         -1
       );
   }else{
     $$ = concat_pere_fils(
       creer_noeud(-1, -1, A_DIMENSION, -1, -1),
       concat_pere_frere($2, $5)
     );
   }
 }

               | POINT {
     if(nature(tete_pile_variable().type) != TYPE_STRUCT){
       print_erreur_semantique(
         "Cet objet ne possède pas de champ."
       );
       erreur_semantique++;
     }
     else{
       empiler_pile_variable(CHAMP, -1);
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
  $$ = creer_noeud($1, -1, A_CSTE_CHAINE, -1, -1.0);
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

e1 : e1 {type_g = type;} operateur_comp e2 {
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
       if($3->nature != A_EGAL && $3->nature != A_DIFFERENT){
         print_erreur_semantique(
           "comparaison d'ordre entre booleens impossible."
         );
         erreur_semantique++;
      }
    }

    type = TYPE_BOOL;
   }
   | e2 {$$ = $1;}
   ;

e2 : e2 {type_g = type;} PLUS e3 {
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
   | e2 {type_g = type;} MOINS e3 {
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
   | e2 {type_g = type;} OU e3 {
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
   | e3 {$$ = $1;}
   ;

e3 : e3 {type_g = type;} MULT e4 {
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
   | e3 {type_g = type;} DIV e4 {
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
   | e3 {type_g = type;} MODULO e4 {
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
   | e3 {type_g = type;} ET e4 {
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
   | e4 {$$ = $1;}
   ;

e4 : NON e5 {
  $$ = concat_pere_fils(creer_noeud(-1, -1, A_NON, -1, -1), $2);
  if(type != TYPE_INT && type != TYPE_BOOL){
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
   | moins CSTE_ENTIERE {
     $$ = creer_noeud(-1, -1, A_CSTE_ENT, $2*$1, -1.0);
     type = TYPE_INT;
   }
   | moins CSTE_REELLE {
     $$ = creer_noeud(-1, -1, A_CSTE_REEL, -1, $2*$1);
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
   | moins variable {
     if($1 == -1){
       $$ = concat_pere_fils(
           creer_noeud(-1, -1, A_MOINS, -1, -1.0),
           concat_pere_frere(
             creer_noeud(-1, -1, A_CSTE_ENT, 0, -1.0),
             concat_pere_fils(
                creer_noeud(-1, -1, A_VAR, -1, -1.0),
                $2
             )
           )
         );
     }
     else{
       $$ = concat_pere_fils(
            creer_noeud(-1, -1, A_VAR, -1, -1.0),
            $2
         );
      }
   }
   | moins appel  {
     // On cherche à savoir si l'on est en face d'une procedure ou bien
     // d'une fonction
     // Ici un appel de procedure sera une erreur, une procedure ne renvoyant
     // rien
     int num_decl_appel = num_decla($2->numlex, FCT, -1);

     if(num_decl_appel == -1){ // Fonction non trouvée
       // Une procedure est-elle appelée à la place ?
       num_decl_appel = num_decla($2->numlex, PROC, -1);
       if(num_decl_appel == -1){ // Rien de déclaré pour ce lexème
         char erreur[400];
         if(tete_pile_region() == 0){
           sprintf(
             erreur,
             "Il n'existe pas de fonction %s dans la région %s numéro %d. Ce qui rend impossible son appel ligne %d.",
             lexeme($2->numlex),
             nom_reg(tete_pile_region()),
             tete_pile_region(),
             nb_ligne
           );
         }else{
           sprintf(
           erreur,
           "Il n'existe pas de fonction %s dans la région %s numéro %d ni dans ses régions englobantes. Ce qui rend impossible son appel ligne %d.",
           lexeme($2->numlex),
           nom_reg(tete_pile_region()),
           tete_pile_region(),
           nb_ligne
           );
         }
         print_erreur_semantique(erreur);

         erreur_semantique++;
       }
       else{
         char erreur[400];
         if(region(num_decl_appel) == 0){
           sprintf(
             erreur,
             "%s est une procédure déclaré ligne %d dans la région %s. Ce n'est pas une fonction, elle ne renvoie donc rien, et ne peut donc pas être présente dans l'expression ligne %d.",
             lexeme($2->numlex),
             ligne_decla(valeur_exec_tab_decla(num_decl_appel)),
             nom_reg(region(num_decl_appel)),
             nb_ligne
           );
         }else{
           sprintf(
             erreur,
             "%s est une procédure déclaré ligne %d dans la région %s numero %d. Ce n'est pas une fonction, elle ne renvoie donc rien, et ne peut donc pas être présente dans l'expression ligne %d.",
             lexeme($2->numlex),
             ligne_decla(valeur_exec_tab_decla(num_decl_appel)),
             nom_reg(region(num_decl_appel)),
             region(num_decl_appel),
             nb_ligne
           );
         }
         print_erreur_semantique(erreur);
         erreur_semantique++;
       }
     }
     else{ // Réglages des élements restés en suspend durant l'appel
       $2->numdecl = num_decl_appel;
       $2->nature = A_APPEL_FCT;
       if(verif_arg_appel(
           num_decl_appel,
           tab_arg_appel[tab_arg_appel[0][0]],
           nb_ligne
         ) == -1){
         erreur_semantique++;
       }

       /* Un appel de moins dans le tableau d'appel */
       tab_arg_appel[0][0]--;

       type = valeur_tab_types(valeur_description_tab_decla(num_decl_appel));
     }

     if($1 == -1){
       $$ = concat_pere_fils(
           creer_noeud(-1, -1, A_MOINS, -1, -1.0),
           concat_pere_frere(
             creer_noeud(-1, -1, A_CSTE_ENT, 0, -1.0),
             $2
           )
        );
     }
     else{
       $$ = $2;
      }
   }
   ;

moins : MOINS {$$ = -1;}
      | {$$ = 1;}
      ;

un_booleen : TRUE {$$ = creer_noeud(-1, -1, A_TRUE, -1, -1.0);}
           | FALSE {$$ = creer_noeud(-1, -1, A_FALSE, -1, -1.0);}
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
    format(yytext, nb_ligne, "afficher");
    tab_var_format[0] = 0;
  }
  suite_afficher {
    // On compare ici le format recu

    int i;
    // Trop de formats
    if(tab_format[0] > tab_var_format[0]){
      char erreur[500];
      sprintf(
        erreur,
        "Le nombre de format (%d) est supérieur au nombre d'argument donné (%d) dans la fonction afficher ligne %d",
        tab_format[0],
        tab_var_format[0],
        nb_ligne
        );
      print_erreur_semantique(erreur);
      erreur_semantique++;
    }
    // Trop d'arguments suivants le format
    else if(tab_var_format[0] > tab_format[0]){
      char erreur[500];
      sprintf(
        erreur,
        "Le nombre d'argument (%d) de la fonction afficher est supérieur au nombre de format (%d) donné ligne %d",
        tab_var_format[0],
        tab_format[0],
        nb_ligne
        );
      print_erreur_semantique(erreur);
      erreur_semantique++;
    }
    // Les cardinaux sont cohérents, on regarde si les éléments sont cohérents
    else{
      for(i = 1; i < tab_format[0]+1; i++){
        if(tab_format[i] != tab_var_format[i] && tab_var_format[i] != -1){
          char erreur[250];
          sprintf(
            erreur,
            "Le format numéro %d (%s) de la fonction afficher ligne %d ne corespond pas avec le type (%s) de l'argument associé.",
             i,
             lexeme(tab_format[i]),
             nb_ligne,
             lexeme(decl2lex(tab_var_format[i]))
             );
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
                      if(type > 3){
                        char erreur[500];
                        sprintf(
                          erreur,
                          "La variable %s est de type %s ce qui n'est pas un type simple. Pour rappel, les types simples sont : int, float, bool et char.",
                          lexeme($1->numlex),
                          lexeme(decl2lex(type))
                          );
                        print_erreur_semantique(erreur);
                        erreur_semantique++;
                      }
                      tab_var_format[tab_var_format[0]] = type;

                      $$ = concat_pere_fils(
                          creer_noeud(-1, -1, A_VAR, -1, -1.0),
                          $1
                        );
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
        if(tete_pile_region() == 0){
          sprintf(
            erreur,
            "Il n'existe pas de procédure %s dans la région %s numéro %d. Ce qui rend impossible son appel ligne %d.",
            lexeme($1->numlex),
            nom_reg(tete_pile_region()),
            tete_pile_region(),
            nb_ligne
          );
        }else{
          sprintf(
          erreur,
          "Il n'existe pas de procédure %s dans la région %s numéro %d ni dans ses régions englobantes. Ce qui rend impossible son appel ligne %d.",
          lexeme($1->numlex),
          nom_reg(tete_pile_region()),
          tete_pile_region(),
          nb_ligne
          );
        }
        print_erreur_semantique(erreur);
        erreur_semantique++;
      }
      else{
        char erreur[400];
        sprintf(
          erreur,
          "affichage d'une procedure (%s) impossible.",
          lexeme($1->numlex)
        );
        print_erreur_semantique(erreur);
        erreur_semantique++;
      }
    }
    else{ // Réglages des élements restés en suspend durant l'appel
      $1->numdecl = num_decl_appel;
      $1->nature = A_APPEL_FCT;
      if(verif_arg_appel(
        num_decl_appel,
        tab_arg_appel[tab_arg_appel[0][0]],
        nb_ligne
      ) == -1){
        erreur_semantique++;
      }
    }

    /* Un appel de moins dans le tableau d'appel */
    tab_arg_appel[0][0]--;

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
    concat_pere_frere(
      concat_pere_fils(
        creer_noeud(-1, -1, A_VAR, -1, -1.0),
        $1
      ),
    $3)
  );
}
                | variable {
  $$ = concat_pere_fils(
      creer_noeud(-1, -1, A_LISTE_VAR, -1, -1),
      concat_pere_fils(
        creer_noeud(-1, -1, A_VAR, -1, -1.0),
        $1
      )
    );
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
    while(c != '\n' && c != EOF){
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
  while(c != '\n' && c != EOF){
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
  init_pile_variable();

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

  tab_arg_appel[0][0] = 0;

  yyparse();

  // Pas de fichier output précisé
  if(index_fic == -1 ){
    if(
      !erreur_semantique
      && syntaxe_correcte
      && (fic = fopen("a.out", "w")) == NULL){
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
