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

void test_pile(){
  mem val;
  pilex px = pilex_init(5);
  val = mem_init(999, INT, 12);
  pilex_emp(val, px);
  val = mem_init(0, REGENGL, 1);
  pilex_emp(val, px);
  val = mem_init('W', CHAR, 28376);
  pilex_emp(val, px);
  val = mem_init('\n', CHAR, 28376);
  pilex_emp(val, px);
  val = mem_init('\x0a', CHAR, 28376);
  pilex_emp(val, px);
  val = mem_init('W', CHAR, 28376);
  pilex_emp(val, px);
  pilex_depn(1, px);
  pilex_empn(10, px);
  val = mem_init(1, BOOL, 1337);
  pilex_emp(val, px);

  pilex_aff(px, -1);
}

void test_blob(){
  char *e = "Hell World";
  printf("%p\n", e);
  blob b = ptr2blob((void *) e);
  printf("%016lx\n", b);
  char *i = (char *) blob2ptr(b);
  printf("%p\n", i);

  printf("%s\n", i);
}

void narmol(int argc, char *argv[]){
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
  narmol(argc, argv);
  //test_pile();
  //test_blob();
  exit(0);
}
