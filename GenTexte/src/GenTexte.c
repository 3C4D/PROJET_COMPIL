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
void generer_texte_intermediaire(FILE *fic){
  int i;

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
    fprintf(fic, "-99|-99|-99|-99|-99.0|");
    i++;
  }
}

// Fonction générant les tables à partir du texte intermédiaire
void generer_tables(FILE *fic){
  // Initialisation des tables
  init_table_lexico();
  init_tab_decla();
  init_tab_representation_type();
  init_tab_region();

  // Chargement des diverses tables
  charger_table_lexico(fic);
  charger_table_decla(fic);
  charger_table_representation(fic);
  charger_table_region(fic);
}
