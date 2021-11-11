#include <stdlib.h>
#include <stdio.h>

// Alloue de la mémoire de manière sûre
void *safe_malloc(int taille){
  void *mem = malloc(taille);
  if (mem == NULL){
    fprintf(stderr, "malloc(): Pb d'allocation\n");
    exit(-1);
  }

  return mem;
}

// Réalloue de la mémoire de manière sûre
void *safe_realloc(void *espace, int taille){
  void *mem = realloc(espace, taille);
  if (mem == NULL){
    fprintf(stderr, "realloc(): Pb d'allocation\n");
    exit(-1);
  }

  return mem;
}