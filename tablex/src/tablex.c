// Fonctions concernant la table lexicographique
// Auteurs : Réalisé une fois par tous les membres du groupe

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "../inc/tablex.h"

cell_lexeme tablexico[500];
int hash_code_table[32];

// Retourne le hash-code du lexème
int hash_code(char *lexeme){
  int i = 0, hash_code = 0;

  while(lexeme[i] != '\0'){
    hash_code += lexeme[i];
    i++;
  }
  return hash_code % 32;
}

// Fonction d'insertion du lexèle en connaissant l'index précis de l'insertion
// ainsi que la longueur du lexème (fonction locale)
void insere_lexeme_index(char *lexeme, int len, int index){
  int i;
  tablexico[index].longueur = len;                          // Longueur
  tablexico[index].lexeme = malloc((len+1) * sizeof(char)); // On alloue
  if(tablexico[index].lexeme == NULL){                      // Vérification
    fprintf(stderr, "marche pas\n");
    exit(-1);
  }
  for(i = 0; i < len; i++){
    tablexico[index].lexeme[i] = lexeme[i]; // Copie
  }
  tablexico[index].lexeme[i] = '\0';        // Fin de chaine
}

// Insere le lexème dans la table lexico, retourne le numero lexicographique
int inserer(char *lexeme){
  cell_lexeme *case_courante;
  int len = 0, hcode = hash_code(lexeme);
  int ind_prec = 0;
  int i = 0, j = 0;


  while(lexeme[j] != '\0'){len++;j++;}      // Calcul de la longueur du lexème

  if(hash_code_table[hcode] == -1){ // Pas de lexèmes pour ce hash-code
    // On insère à la première case sans chercher son précédent, il n'en a pas
    while(tablexico[i].longueur != -1){i++;}  // On cherche l'index vide
    insere_lexeme_index(lexeme, len, i);      // On insère le lexème
    hash_code_table[hcode] = i;               // Màj de la table de hash-code
  }
  else{                             // Un lexème pour ce hash-code

    // On cherche si le lexème est déjà dans la table grâce à la table de
    // hash-code
    case_courante = &tablexico[hash_code_table[hcode]];

    // On parcourt les suivants en s'assurant que le lexème n'y est pas déjà
    while(
      case_courante->suivant != NULL
      && len != case_courante->longueur
      && strcmp(case_courante->lexeme, lexeme)
    ){
      case_courante = case_courante->suivant;
    }

    if( // Si le dernier suivant ne correspond ni en longueur, ni en chaine
      len != case_courante->longueur
      || strcmp(case_courante->lexeme, lexeme)
    ){
      ind_prec = case_courante - tablexico; // On retient l'adresse du précédent

      // On insère désormais le lexème au premier index nul
      i = ind_prec;
      while(tablexico[i].longueur != -1){i++;}  // On cherche l'index vide
      insere_lexeme_index(lexeme, len, i);      // On insère le lexème
      tablexico[ind_prec].suivant = &tablexico[i];           // Màj du suivant
    }
  }
  return i;
}

// Retourne le lexème associé à ce numéro lexicographique
char *lexeme(int num_lexico){
  int i = 0;
  char *mot = malloc(100 * sizeof(char));

  if(mot == NULL){
    fprintf(stderr, "marche pas\n");
    exit(-1);
  }

  while(tablexico[num_lexico].lexeme[i] != '\0'){
    mot[i] = tablexico[num_lexico].lexeme[i];
    i++;
  }

  return mot;
}

// Affiche la table lexicographique
void affiche_table_lexico(){
  int i;
  for(i = 0; i < 20; i++){
    if(tablexico[i].longueur != -1){
      printf("| hc : %d |", hash_code(tablexico[i].lexeme));
    }
    else{
      printf("| hc : -1 |");
    }
    printf(" lg : %d | %s |", tablexico[i].longueur, tablexico[i].lexeme);
    if(tablexico[i].suivant == NULL){
      printf(" -1 |\n");
    }
    else{
      printf(" %s |\n", tablexico[i].suivant->lexeme);
    }
  }
}

// Initialise la table lexicographique
void init_table_lexico(){
  int i;
  for(i = 0; i < 500; i++){
    tablexico[i].longueur = -1;
    tablexico[i].lexeme = NULL;
    tablexico[i].suivant = NULL;
  }

  for(i = 0; i < 32; i++){
    hash_code_table[i] = -1;
  }
}
