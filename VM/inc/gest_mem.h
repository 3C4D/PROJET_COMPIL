// Module de gestion de la mémoire

#ifndef GEST_MEM_H_
#define GEST_MEM_H_

void *safe_malloc(int taille);
void *safe_realloc(void *espace, int taille);

#endif