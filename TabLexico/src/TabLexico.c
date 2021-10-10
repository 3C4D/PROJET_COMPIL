// Fonctions concernant la table lexicographique

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "../inc/TabLexico.h"

cell_lexeme TableLexico[MAX_TAB_LEX];
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
  TableLexico[index].longueur = len;                          // Longueur
  TableLexico[index].lexeme = malloc((len+1) * sizeof(char)); // On alloue
  if(TableLexico[index].lexeme == NULL){                      // Vérification
    fprintf(stderr, "marche pas\n");
    exit(-1);
  }
  for(i = 0; i < len; i++){
    TableLexico[index].lexeme[i] = lexeme[i]; // Copie
  }
  TableLexico[index].lexeme[i] = '\0';        // Fin de chaine
}

// Insere le lexème dans la table lexico, retourne le numero lexicographique
int inserer_tab_lex(char *lexeme){
  cell_lexeme *case_courante;
  int len = 0, hcode = hash_code(lexeme);
  int ind_prec = 0;
  int i = 0, j = 0;


  while(lexeme[j] != '\0'){len++;j++;}      // Calcul de la longueur du lexème

  if(hash_code_table[hcode] == -1){ // Pas de lexèmes pour ce hash-code
    // On insère à la première case sans chercher son précédent, il n'en a pas
    while(TableLexico[i].longueur != -1){i++;}  // On cherche l'index vide
    insere_lexeme_index(lexeme, len, i);      // On insère le lexème
    hash_code_table[hcode] = i;               // Màj de la table de hash-code
  }
  else{                             // Un lexème pour ce hash-code

    // On cherche si le lexème est déjà dans la table grâce à la table de
    // hash-code
    case_courante = &TableLexico[hash_code_table[hcode]];

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
      ind_prec = case_courante - TableLexico; // On retient l'adresse du précédent

      // On insère désormais le lexème au premier index nul
      i = ind_prec;
      while(TableLexico[i].longueur != -1){i++;}  // On cherche l'index vide
      insere_lexeme_index(lexeme, len, i);      // On insère le lexème
      TableLexico[ind_prec].suivant = &TableLexico[i];           // Màj du suivant
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

  while(TableLexico[num_lexico].lexeme[i] != '\0'){
    mot[i] = TableLexico[num_lexico].lexeme[i];
    i++;
  }

  return mot;
}

// Affiche la table lexicographique
void affiche_table_lexico(){
  int i;
  for(i = 0; i < 20; i++){
    if(TableLexico[i].longueur != -1){
      printf("| hc : %d |", hash_code(TableLexico[i].lexeme));
    }
    else{
      printf("| hc : -1 |");
    }
    printf(" lg : %d | %s |", TableLexico[i].longueur, TableLexico[i].lexeme);
    if(TableLexico[i].suivant == NULL){
      printf(" -1 |\n");
    }
    else{
      printf(" %s |\n", TableLexico[i].suivant->lexeme);
    }
  }
}

// Initialise la table lexicographique
void init_table_lexico(){
  int i;
  for(i = 0; i < 500; i++){
    TableLexico[i].longueur = -1;
    TableLexico[i].lexeme = NULL;
    TableLexico[i].suivant = NULL;
  }

  for(i = 0; i < 32; i++){
    hash_code_table[i] = -1;
  }
}
