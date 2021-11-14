// Fonction principale de la VM

#include <stdlib.h>
#include <stdio.h>

#include "../inc/pile_exec.h"
#include "../inc/blob.h"
#include "../inc/execution.h"

#include "../inc/blob.h"
#include "../inc/pile_exec.h"
#include "../inc/execution.h"
#include "../../arbres/inc/arbres.h"
#include "../../inc/macros_arbres.h"
#include "../../GenTexte/inc/GenTexte.h"
#include "../../TabDecla/inc/TabDecla.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../TabRegion/inc/TabRegion.h"
#include "../../TabRepresentation/inc/TabRepresentation.h"

void lancer_exec(int argc, char *argv[]){
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

  execution(fic);
}

int main(int argc, char *argv[]){
  lancer_exec(argc, argv);
  exit(0);
}
