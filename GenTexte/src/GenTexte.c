// Fonctions permettant la génération de texte intermédiaires ainsi que de
// générations de tables à partir de texte intermédiaire

#include <stdlib.h>
#include <stdio.h>
#include "../arbres/inc/arbres.h"
#include "../TabLexico/inc/TabLexico.h"
#include "../TabRepresentation/inc/TabRepresentation.h"
#include "../TabDecla/inc/TabDecla.h"
#include "../TabRegion/inc/TabRegion.h"

// Fonction générant le texte intermédiaire à partir des tables
void generer_texte_intermediaire(char *nom_fic){
  FILE *fic;
  int i;

  // Le fichier n'existe pas (vérification précédente), on essaye de le créer
  if((fic = fopen(nom_fic, "w")) == NULL){
    fprintf(stderr, "Le fichier output ne peut pas être créé\n");
    exit(-1);
  }

  // TABLE LEXICO
  i = 0;
  while(TableLexico[i].longueur != -1){
    fprintf(
      fic,
      "%d|%s|%d|",
      TableLexico[i].longueur,
      TableLexico[i].lexeme,
      TableLexico[i].suivant
    );
    i++;
  }
  fprintf(fic, "-1|-1|-1|");

  // TABLE DECLARATION (zone normale)
  i = 0;
  while(TableDeclaration[i].nature != -1){
    fprintf(
      fic,
      "%d|%d|%d|%d|%d|",
      TableDeclaration[i].nature,
      TableDeclaration[i].suivant,
      TableDeclaration[i].num_region,
      TableDeclaration[i].description,
      TableDeclaration[i].exec
    );
    i++;
  }
  fprintf(fic, "-1|-1|-1|-1|-1|");

  // TABLE DECLARATION (zone de débordement)
  i = 500;
  while(TableDeclaration[i].nature != -1){
    fprintf(
      fic,
      "%d|%d|%d|%d|%d|",
      TableDeclaration[i].nature,
      TableDeclaration[i].suivant,
      TableDeclaration[i].num_region,
      TableDeclaration[i].description,
      TableDeclaration[i].exec
    );
    i++;
  }
  fprintf(fic, "-1|-1|-1|-1|-1|");

  // TABLE TYPES
  i = 0;
  while(TableRepresentation[i] != -1){
    fprintf(fic, "%d|", TableRepresentation[i]);
    i++;
  }
  fprintf(fic, "-1|");

  // TABLE REGIONS
  i = 0;
  while(TableRegion[i].NIS != -1){
    fprintf(fic, "%d|%d|", TableRegion[i].taille, TableRegion[i].NIS);
    sauver_arbre(fic, TableRegion[i].arbre_region);
    fprintf(fic, "-99|-99|-99|-99|-99|");
    i++;
  }
}
