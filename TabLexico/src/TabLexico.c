#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../inc/TabLexico.h"

/*----------------------------------------------------------------------------
  Utilité : Renvoie le HashCode du lexème
  Paramatère : - lexeme : le lexeme en question
  ----------------------------------------------------------------------------*/
int calcul_hashcode(char * lexeme){
  int hc = 0;
  int i = 1;
  char c = lexeme[0];

  while(c != '\0'){
    hc += c;
    c = lexeme[i];
    i = i+1;
  }

  /*Transformation en modulo 32*/
  hc = hc%32;
  return hc;
}

/* Initialise la table lexicographique */
void init_table_lexico(){
  int i;

  /*Initialisation de la table de HashCode*/
  for(i=0; i<32 ; i++){
    TableHC[i] = -1;
  }

  /*Initialisation de la table lexicographique*/
  for(i=0; i<500 ;i++){
    TableLexico[i].longueur = -1;
    TableLexico[i].lexeme = NULL;
    TableLexico[i].suivant = -1;
  }
}

/*----------------------------------------------------------------------------
Utilité : Insere le lexème dans la table lexico, et retourne le numero
lexicographique.
Paramatère : - lexeme : le lexeme en question
----------------------------------------------------------------------------*/
int inserer_tab_lex(char * lexeme){
  int hcl, numLexicoLc, longueurLexeme;
  char c;
  int premierLexeme;
  int lexemePrecedent;
  int i=0;

  /*On recherche la premier case vide de la table lexicographique*/
  while(TableLexico[i].lexeme != NULL){
    i++;
  }
  numLexicoLc = i; /*L'indice de la première case vide correspond au potentiel
                  numéro lexicographique du lexeme courant*/

  /*On calcule la longueur du lexeme courant*/
  c = lexeme[0];
  longueurLexeme=0;
  i=1;

  while(c != '\0'){
    longueurLexeme++;
    c = lexeme[i];
    i++;
  }

  /*Il faut mettre à jour la case suivant de la table lexicographique du lexeme
  précédent, s'il existe*/

  hcl = calcul_hashcode(lexeme);
  /*Si le lexème courant est le premier lexeme de HashCode hcl, alors on remplir
  la table de hc, et on n'a aucune mise à jour à faire */
  if(TableHC[hcl] == -1){
    TableHC[hcl] = numLexicoLc; /*On insère le numéro lexicographique du lexeme
                                  courant*/
    TableLexico[numLexicoLc].lexeme =(char*)malloc(sizeof(char)*(longueurLexeme+1));
    /*On insère en toute sécurité le lexème car on sait qu'il ne peut pas être
     en double*/
     for(int j =0; j<longueurLexeme;j++){
       TableLexico[numLexicoLc].lexeme[j]=lexeme[j];
     }
     TableLexico[numLexicoLc].lexeme[longueurLexeme]='\0';

    TableLexico[numLexicoLc].longueur = longueurLexeme;
    return numLexicoLc;
  }else{
    premierLexeme = TableHC[hcl];
    /*On vérifie que les deux lexemes soient différents avant de faire quoi
    que ce soit*/
    if(TableLexico[premierLexeme].longueur == longueurLexeme){
      if(strcmp(TableLexico[premierLexeme].lexeme, lexeme)==0){
        /*Nos deux lexemes sont identiques, on renvoie donc le numéro
        lexicographique de celui déjà présent dans la table*/
        return premierLexeme;
      }
    }

    /*Le but est de rechercher le premier lexeme de même Hashcode que notre lexeme
    qui n'a pas de suivant*/
    lexemePrecedent = premierLexeme;
    while(TableLexico[lexemePrecedent].suivant != -1){
      /*Le potentiel lexeme précédent change*/
      lexemePrecedent = TableLexico[lexemePrecedent].suivant;

      /*On vérifie à chaque fois que le lexeme ne soit pas identique à un déjà
      présent dans la table*/
      if(TableLexico[lexemePrecedent].longueur == longueurLexeme){
        if(strcmp(TableLexico[lexemePrecedent].lexeme, lexeme)==0){
          /*Nos deux lexemes sont identiques, on renvoie donc le numéro
          lexicographique de celui déjà présent dans la table*/
          return lexemePrecedent;
        }
      }
    }

    /*Une fois notre lexeme en question trouvé, on indique que sont suivant
    devient notre lexeme courant*/
    TableLexico[lexemePrecedent].suivant = numLexicoLc ;
    /*Et on insère notre lexeme*/
    TableLexico[numLexicoLc].lexeme =(char*)malloc(sizeof(char)*(longueurLexeme+1));
    for(int j =0; j<longueurLexeme;j++){
      TableLexico[numLexicoLc].lexeme[j]=lexeme[j];
    }
    TableLexico[numLexicoLc].lexeme[longueurLexeme]='\0';
    /*Et sa longueur*/
    TableLexico[numLexicoLc].longueur = longueurLexeme;

    return numLexicoLc;
  }
}


/*----------------------------------------------------------------------------
  Utilité : Retourne le lexème dont le numéro léxicographique est num_lexico
  Paramatère : - num_lexico : le numéro lexicographique du lexème à retourner.
  ----------------------------------------------------------------------------*/
char * lexeme(int num_lexico){
  return TableLexico[num_lexico].lexeme;
}

/* Affiche la table lexicographique */
void affiche_table_lexico(){
  int i,j;
  i=0;
  j=1;

  while(TableLexico[i].lexeme !=NULL){
    i++;
    j++;
  }
  printf("\n---------------------TABLE LEXICOGRAPHIQUE-----------------------\n");
  printf("/--------+----------------+---------------------------+---------\\\n");
  printf("| Numlex |    Longueur    |           Lexeme          | Suivant |\n");
  printf("|--------+----------------+---------------------------+---------|\n");
  for(i=0; i<j; i++){
    printf("|   %-3d  |       %-8d |     %-21s |    %-4d |\n",i,TableLexico[i].longueur, TableLexico[i].lexeme,
    TableLexico[i].suivant);
  }
  printf("\\--------+----------------+---------------------------+---------/\n");
}
