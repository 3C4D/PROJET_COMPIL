#include <stdio.h>
#include <stdlib.h>
#include "../../TabLexico/inc/TabLexico.h"
#include "../inc/TabDecla.h"
#define MAX_TAB_DECLA 3000
#define TYPE_STRUCT 1
#define TYPE_TAB 2 /*Type tableau*/
#define VAR 3 /*Variable*/
#define PARAMETRE 4
#define PROC 5 /*Procédure*/
#define FCT 6 /*Fonctions*/

tabDecla TableDeclaration[MAX_TAB_DECLA];

/*Initialise la table des déclarations*/
void init_tab_decla(){
  int i;
  for(i=0; i<MAX_TAB_DECLA; i++){
    TableDeclaration[i].nature = -1;
    TableDeclaration[i].suivant = -1;
    TableDeclaration[i].num_region=-1;
    TableDeclaration[i].description = -1;
    TableDeclaration[i].exec=-1;
  }
}


/*-----------------------------------------------------------------------------
  Utilité fonction : Retourne le numéro dans la table des déclaration du lexème courant
  Paramètres : - lexeme
              - nature
              - num_region
              - nb_champs : (pour structure, tableau, procedure, fonction) : nombre de
                             (champs, dimensions, paramètres)
              - num_represention_type : (Variable ou paramatère) numéro de déclaration du type du lexème
               courant OU (procédure, fonction, structure, tableau) l'indice dans
               la table des représentation
 -----------------------------------------------------------------------------*/
int inserer_tab_declaration(char *lexeme, int nature, int num_region, int nb_champs, int type, int num_represention_type){
    int i;
    int num_decla;
    int num_lexico;

    /*-------------------------------------------------------------------------
      On va déterminer si le lexème va dans la table primaire, ou dans la zone
      de débordement
    -------------------------------------------------------------------------*/

    num_lexico = inserer_tab_lex(lexeme); /*On récupère le numéro lexico du
                                            lexeme courant*/

    if(TableDeclaration[num_lexico].nature == -1){ /*Si il n'y a jamais encore eu
                                                   de lexème identiques insérés
                                                   dans la table*/
      num_decla = num_lexico; /*On va donc insérer les informations du lexème
                              à l'indice num_lexico*/

    }else{ /*Sinon, on va cherche la premier case vide dans la zone de débordement*/
      i = MAX_TAB_LEX;  /*Donne le premier indice de la zone de débordement*/
      while(TableDeclaration[i].nature != -1){ /*Tant que la case i n'est pas libre*/
        i++;
      }
      num_decla = i; /*Première case libre trouvé dans la zone de débordement*/

      /*-----------------------------------------------------------------------
        On remet à jour le chainage
        ----------------------------------------------------------------------*/
      i = num_lexico;
      while(TableDeclaration[i].suivant != -1){ /*On regarde si il y a un suivant*/
        i = TableDeclaration[i].suivant;
      }
      TableDeclaration[i].suivant = num_decla;
    }

    /*-------------------------------------------------------------------------
      On insère le numéro de la région où se trouve le lexème courant
    --------------------------------------------------------------------------*/
    TableDeclaration[num_decla].num_region = num_region;

    /*-------------------------------------------------------------------------
       On insère la nature du lexème courant
       -----------------------------------------------------------------------*/
    switch (nature) {
      case TYPE_STRUCT:
        TableDeclaration[num_decla].nature = 1;
        break;
      case TYPE_TAB:
        TableDeclaration[num_decla].nature = 2;
        break;
      case VAR:
        TableDeclaration[num_decla].nature = 3;
        break;
      case PARAMETRE:
        TableDeclaration[num_decla].nature = 4;
        break;
      case PROC:
        TableDeclaration[num_decla].nature = 5;
        break;
      case FCT:
        TableDeclaration[num_decla].nature = 6;
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
      TableDeclaration[num_decla].description = num_represention_type;
      TableDeclaration[num_decla].exec = -1;  /*laisse vide pour le moment*/

    }else if((nature == VAR) || (nature == PARAMETRE)){
      TableDeclaration[num_decla].description = num_represention_type;
      TableDeclaration[num_decla].exec = -1;  /*laisse vide pour le moment*/

    }else if((nature == PROC) || (nature == FCT)){
      TableDeclaration[num_decla].description = num_represention_type;
      TableDeclaration[num_decla].exec = -1;  /*laisse vide pour le moment*/

    }else{
      printf("Problème dans la nature du lexeme dans la table des déclarations\n");
      exit(-1);
    }
    return num_decla;
}

/*Affiche la table des déclarations*/
/* void afficher_tab_declaration(){

}*/
