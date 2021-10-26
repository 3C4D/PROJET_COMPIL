#include <stdio.h>
#include <stdlib.h>
#include "../../TabLexico/inc/TabLexico.h"
#include "../../TabRepresentation/inc/TabRepresentation.h"
#include "../inc/TabDecla.h"
#include "../../inc/fct_aux_yacc.h"

/*Initialise la table des déclarations*/
void init_tab_decla(){
  int i;

  /*Initialisation des types de bases*/
  TableDeclaration[0].nature = TYPE_BASE;
  TableDeclaration[0].suivant = -1;
  TableDeclaration[0].num_region = -1;
  TableDeclaration[0].description = -1;
  TableDeclaration[0].exec = 1;

  TableDeclaration[1].nature = TYPE_BASE;
  TableDeclaration[1].suivant = -1;
  TableDeclaration[1].num_region = -1;
  TableDeclaration[1].description = -1;
  TableDeclaration[1].exec = 1;

  TableDeclaration[2].nature = TYPE_BASE;
  TableDeclaration[2].suivant = -1;
  TableDeclaration[2].num_region = -1;
  TableDeclaration[2].description = -1;
  TableDeclaration[2].exec = 1;

  TableDeclaration[3].nature = TYPE_BASE;
  TableDeclaration[3].suivant = -1;
  TableDeclaration[3].num_region = -1;
  TableDeclaration[3].description = -1;
  TableDeclaration[3].exec = 1;

  for(i=4; i<MAX_TAB_DECLA; i++){
    TableDeclaration[i].nature = -1;
    TableDeclaration[i].suivant = -1;
    TableDeclaration[i].num_region= -1;
    TableDeclaration[i].description = -1;
    TableDeclaration[i].exec= -1;
  }
}

/*-----------------------------------------------------------------------------
  Utilité fonction : Retourne le numéro dans la table des déclaration du lexème
                    courant
  Paramètres : - num_lexico : numéro lexicographique du lexeme courant
              - nature
              - num_region_engendree : (Procédure ou fonction) numéro de la
              région engendrée, -1 pour les autres nature.
              - num_region
              - num_represention_type : (Variable ou paramatère) numéro de
                déclaration du type du lexème
               courant OU (procédure, fonction, structure, tableau) l'indice dans
               la table des représentation
              - nb_ligne : numéro de la ligne à laquelle on est.
 -----------------------------------------------------------------------------*/
int inserer_tab_declaration(int num_lexico, int nature,
                           int num_region, int num_represention_type, int nb_ligne){
    int i;
    int num_declaration;
    int taille;
    int nb_dim;
    int nb_champs;

    /*-------------------------------------------------------------------------
      On va déterminer si le lexème va dans la table primaire, ou dans la zone
      de débordement
    -------------------------------------------------------------------------*/



    if(TableDeclaration[num_lexico].nature == -1){ /*Si il n'y a jamais encore eu
                                                   de lexème identiques insérés
                                                   dans la table*/
      num_declaration = num_lexico; /*On va donc insérer les informations du lexème
                              à l'indice num_lexico*/

    }else{ /*Sinon, on va cherche la premier case vide dans la zone de débordement*/

      /*Attention surchage possible..*/
      /*On vérifie que l'élément de la table primaire, qui est le même lexeme, n'est
      pas déclaré sous la même nature, et dans la même région*/
      if((TableDeclaration[num_lexico].num_region == num_region) && (TableDeclaration[num_lexico].nature == nature)){
        switch (nature) {
          case TYPE_STRUCT:
            printf("Problème de sémantique ligne %d : structure de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          case TYPE_TAB:
            printf("Problème de sémantique ligne %d : tableau de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          case VAR:
            printf("Problème de sémantique ligne %d : variable de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          case PARAMETRE:
            printf("Problème de sémantique ligne %d : paramatère de la fonction de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          case PROC:
            printf("Problème de sémantique ligne %d : procédure de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          case FCT:
            printf("Problème de sémantique ligne %d : fonction de même nom déjà défini dans cette région\n", nb_ligne);
            break;
          default:
            exit(-1);
            break;
          }
      }


      i = MAX_TAB_LEX;  /*Donne le premier indice de la zone de débordement*/
      while(TableDeclaration[i].nature != -1){ /*Tant que la case i n'est pas libre*/

        /*Gestion de la surcharge possible*/
        /*On vérifie que l'élément i, qui est le même lexème, n'est pas déclaré
        dans la même région ET à la même nature*/

        if(num_decla(num_lexico, nature, num_region) != -1){
          switch (nature) {
            case TYPE_STRUCT:
              printf("Problème de sémantique ligne %d : structure de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            case TYPE_TAB:
              printf("Problème de sémantique ligne %d : tableau de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            case VAR:
              printf("Problème de sémantique ligne %d : variable de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            case PARAMETRE:
              printf("Problème de sémantique ligne %d : paramatère de la fonction de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            case PROC:
              printf("Problème de sémantique ligne %d : procédure de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            case FCT:
              printf("Problème de sémantique ligne %d : fonction de même nom déjà défini dans cette région\n", nb_ligne);
              break;
            default:
              exit(-1);
              break;
            }
        }
        i++;
      }
      num_declaration = i; /*Première case libre trouvé dans la zone de débordement*/

      /*-----------------------------------------------------------------------
        On remet à jour le chainage
        ----------------------------------------------------------------------*/
      i = num_lexico;
      while(TableDeclaration[i].suivant != -1){ /*On regarde si il y a un suivant*/
        i = TableDeclaration[i].suivant;
      }
      TableDeclaration[i].suivant = num_declaration;
    }

    /*-------------------------------------------------------------------------
      On insère le numéro de la région où se trouve le lexème courant
    --------------------------------------------------------------------------*/
    TableDeclaration[num_declaration].num_region = num_region;

    /*-------------------------------------------------------------------------
       On insère la nature du lexème courant
       -----------------------------------------------------------------------*/
    switch (nature) {
      case TYPE_STRUCT:
        TableDeclaration[num_declaration].nature = 1;

        /*On calcule la taille de la structure*/
        nb_champs = valeur_tab_representation(num_represention_type);
        taille = 0;

        for(i=1; i<nb_champs*3; i = i+3){
            /*On ajoute la taille du type de chaque champs*/
            taille = taille + valeur_exec_tab_decla((valeur_tab_representation(num_represention_type + i)));
        }

        break;
      case TYPE_TAB:
        TableDeclaration[num_declaration].nature = 2;

        /*On calcule la taille du tableau*/
        taille = valeur_exec_tab_decla(valeur_tab_representation(num_represention_type)); //Taille du type des éléments du tableau
        nb_dim = valeur_tab_representation(num_represention_type + 1);

        for(i=2; i<nb_dim*2 + 1; i= i+2){
          taille = taille*(valeur_tab_representation(num_represention_type +i +1) - valeur_tab_representation(num_represention_type + i ) +1 );
        }

        break;
      case VAR:
        TableDeclaration[num_declaration].nature = 3;
        break;
      case PARAMETRE:
        TableDeclaration[num_declaration].nature = 4;
        break;
      case PROC:
        TableDeclaration[num_declaration].nature = 5;
        break;
      case FCT:
        TableDeclaration[num_declaration].nature = 6;
        break;
      default:
        printf("Problème de nature du lexeme dans la table des déclarations\n");
        exit(-1);
        break;
      }

    /*------------------------------------------------------------------------
       On détermine les valeurs des champs descriptions et exec suivant la
       nature
       ----------------------------------------------------------------------*/

    if((nature == TYPE_STRUCT) || (nature == TYPE_TAB)){
      TableDeclaration[num_declaration].description = num_represention_type;
      TableDeclaration[num_declaration].exec = taille;  /*Taille de la structure, ou du tableau*/

    }else if((nature == VAR) || (nature == PARAMETRE)){
      TableDeclaration[num_declaration].description = num_represention_type;
      TableDeclaration[num_declaration].exec = -1;  /*laisse vide pour le moment*/

    }else if((nature == PROC) || (nature == FCT)){
      TableDeclaration[num_declaration].description = num_represention_type;
      TableDeclaration[num_declaration].exec = -1;  /*laisse vide pour le moment*/

    }else{
      printf("Problème dans la nature du lexeme dans la table des déclarations\n");
      exit(-1);
    }
    return num_declaration;
}

/*----------------------------------------------------------------------------
 Utilité : Rempli le champs exec pour une fonction/procédure avec le num_region_engendree
  Paramètre :  num_region_engendree : numéro de la région engendrée par la
              prodédure/fonction en question.
 ----------------------------------------------------------------------------- */
 void inserer_exec_tab_decla(int num_decla, int num_region_engendree){
   TableDeclaration[num_decla].exec = num_region_engendree;
 }



/*----------------------------------------------------------------------------
 Utilité : Retourne le champs décription à l'indice donnée dans la table des
          déclarations.
  Paramètre : - indice : indice en question.
 ----------------------------------------------------------------------------- */
 int valeur_description_tab_decla(int indice){
   return TableDeclaration[indice].description;
 }

/*Affiche la table des déclarations*/
 void afficher_tab_declaration(){
   int i = 0;
   printf("\n######################################   TABLE DES DECLARATIONS   ##############################################\n");
   printf("/--------------------------+------------+-------------+------------+-----------+-----------------+-------------\\\n");
   printf("|          Lexeme          |   Indice   |   Nature    |  Suivant   |  Région   |   Description   |  Exécution  |\n" );
   printf("+--------------------------+------------+-------------+------------+-----------+-----------------+-------------+\n" );
   while(i<30){
     switch (TableDeclaration[i].nature) {
       case TYPE_BASE :
         printf("|    %-21s |     %-6d |  TYPE_BASE  |     %-6d |     %-5d |        %-8d |      %-6d |\n", lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case TYPE_STRUCT:
         printf("|    %-21s |     %-6d | TYPE_STRUCT |     %-6d |     %-5d |        %-8d |      %-6d |\n", lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case TYPE_TAB:
         printf("|    %-21s |     %-6d |  TYPE_TAB   |     %-6d |     %-5d |        %-8d |      %-6d |\n",lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case VAR:
         printf("|    %-21s |     %-6d |  VARIABLE   |     %-6d |     %-5d |        %-8d |      %-6d |\n",lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case PARAMETRE:
         printf("|    %-21s |     %-6d |  PARAMETRE  |     %-6d |     %-5d |        %-8d |      %-6d |\n",lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case PROC:
         printf("|    %-21s |     %-6d |  PROCEDURE  |     %-6d |     %-5d |        %-8d |      %-6d |\n",lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case FCT:
         printf("|    %-21s |     %-6d |  FONCTION   |     %-6d |     %-5d |        %-8d |      %-6d |\n",lexeme(i),i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       default:
         printf("|                          |            |             |            |           |                 |             |\n");
         break;
       }
       i++;

   }
   printf("\\--------------------------+------------+-------------+------------+-----------+-----------------+-------------/\n" );

   printf("\n########################################   ZONE DE DEBORDEMENT   ###############################################\n");
   printf("/--------------------------+------------+-------------+------------+-----------+-----------------+-------------\\\n");
   printf("|                          |   Indice   |   Nature    |  Suivant   |  Région   |   Description   |  Exécution  |\n" );
   printf("+--------------------------+------------+-------------+------------+-----------+-----------------+-------------+\n" );
   i = 500;
   while(i<520){
     switch (TableDeclaration[i].nature) {
       case TYPE_STRUCT:
         printf("|                          |    %-7d | TYPE_STRUCT |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case TYPE_TAB:
         printf("|                          |    %-7d |  TYPE_TAB   |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);

       case VAR:
         printf("|                          |    %-7d |  VARIABLE   |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case PARAMETRE:
         printf("|                          |    %-7d |  PARAMETRE  |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case PROC:
         printf("|                          |    %-7d |  PROCEDURE  |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       case FCT:
         printf("|                          |    %-7d |  FONCTION   |     %-6d |     %-5d |        %-8d |      %-6d |\n", i, TableDeclaration[i].suivant,TableDeclaration[i].num_region, TableDeclaration[i].description, TableDeclaration[i].exec);
         break;
       default:
         printf("|                          |            |             |            |           |                 |             |\n");
         break;
       }
       i++;
   }
   printf("\\--------------------------+------------+-------------+------------+-----------+-----------------+-------------/\n" );
}

/*----------------------------------------------------------------------------
  Utilité : Renvoie le numéro de déclaration du lexème si il est déclaré, -1
  sinon.
  Paramatères : - num_lexico : numéro du lexème en question.
                - nature : nature du lexème en question (si c'est une procédure,
               fonction, ...)
               - region_particuliere : deux cas :
                  * egal à -1, dans ce cas on cherche le numéro de déclaration
                    du lexème (si il est déclaré) dans n'importe quelle région
                    présente dans la pile des régions.
                  * égal à la région courante , dans ce cas, on regarde si le
                  le lexème est déjà déclaré dans cette région particuliere;

  ----------------------------------------------------------------------------*/
int num_decla(int num_lexico, int nature, int region_particuliere){
  int num_decla = -1;
  int derniere_region;/*Region la plus proche de la région courante*/
  int chainage = num_lexico; /*Début du chainage*/

  if(region_particuliere == -1){
    derniere_region = -1; /*On part de rien*/
  }else{
    derniere_region = region_particuliere;
  }

  /*Tant qu'il existe une déclaration de même numéro lexicographique*/
  while((chainage != -1) && (TableDeclaration[chainage].nature != -1)){
    /*On vérifie si les natures des déclarations sont les mêmes*/
    if(TableDeclaration[chainage].nature == nature){
      /*On vérifie ensuite si la région de la déclaration en court d'examen est
      dans la pile des régions*/
      if(est_dans_pile_region(TableDeclaration[chainage].num_region) == 1){ /*si oui*/
        /*On sauvage ce numéro de déclaration si derniere_region est plus petit
        que*/
        if(TableDeclaration[chainage].num_region >= derniere_region){
          num_decla = chainage;
        }
      }
    }
    chainage = TableDeclaration[chainage].suivant;
  }

  return num_decla;
}




/*----------------------------------------------------------------------------
 Utilité : Renvoie le numéro de région d'une certaine déclaration
  Paramètre : - num_decla : numéro de déclaration en question
 ----------------------------------------------------------------------------- */
int region(int num_decla){
  return TableDeclaration[num_decla].num_region;
}

/*----------------------------------------------------------------------------
 Utilité : Renvoie la nature d'une certaine déclaration
  Paramètre : - num_decla : numéro de déclaration en question
 ----------------------------------------------------------------------------- */
int nature(int num_decla){
  return TableDeclaration[num_decla].nature;
}

/*----------------------------------------------------------------------------
 Utilité : Renvoie le champs execution d'une certaine déclaration
  Paramètre : - num_decla : numéro de déclaration en question
 ----------------------------------------------------------------------------- */
int valeur_exec_tab_decla(int num_decla){
  return TableDeclaration[num_decla].exec;
}

/*----------------------------------------------------------------------------
 Utilité :  Renvoie le numéro de déclaration d'une variable
  Paramètre : - numlex : numéro léxicographique du lexeme
 ----------------------------------------------------------------------------- */
int num_decla_variable(int numlex){
  // On recherche à quoi correspond la variable
  int num_decla_param = num_decla(numlex,PARAMETRE,-1);
  int num_decla_var = num_decla(numlex,VAR,-1);

  if(num_decla_var == -1 && num_decla_param == -1){
    return -1;
  }
  else if(num_decla_var > num_decla_param){
    return num_decla_var;           // VARIABLE SIMPLE
  }
  else{
    return num_decla_param;       // PARAMETRE
  }
  return -1;
}

// Charge la table des déclarations à partir du texte intermédiaire
void charger_table_decla(FILE *fic){
  int i = 0, retour = 0;
  // table decla (zone normale)
  do{
    retour = fscanf(
      fic,
      "%d|%d|%d|%d|%d|",
      &TableDeclaration[i].nature,
      &TableDeclaration[i].suivant,
      &TableDeclaration[i].num_region,
      &TableDeclaration[i].description,
      &TableDeclaration[i].exec
    );
    i++;
  }while(retour != -1 && TableDeclaration[i-1].nature != -1);

  i = 500;
  // table decla (zone normale)
  do{
    retour = fscanf(
      fic,
      "%d|%d|%d|%d|%d|",
      &TableDeclaration[i].nature,
      &TableDeclaration[i].suivant,
      &TableDeclaration[i].num_region,
      &TableDeclaration[i].description,
      &TableDeclaration[i].exec
    );
    i++;
  }while(retour != -1 && TableDeclaration[i-1].nature != -1);
}
