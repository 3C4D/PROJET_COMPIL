// Fonction principale de la VM

#include <stdlib.h>
#include <stdio.h>
#include "../../GenTexte/inc/GenTexte.h"

int main(int argc, char *argv[]){
  FILE *fic;

  // Vérification du nombre d'argument
  if(argc < 2){
    fprintf(stderr, "Usage : %s <fichier>\n", argv[0]);
    fprintf(stderr, "   <fichier> : programme cpyrr compilé\n");
    exit(-1);
  }

  // Vérification du fichier
  if((fic = fopen(argv[1], "r")) == NULL){
    fprintf(stderr, "Erreur lors de l'ouverture du fichier %s\n", argv[1]);
    exit(-1);
  }

  generer_tables(fic);
  exit(0);
}
