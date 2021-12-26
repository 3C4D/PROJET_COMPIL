#include <string.h>
#include <stdio.h>

#include "../inc/blob.h"

// Conversion entre les constantes types de l'arbre d'execution et de la pile
types type_conv(int i){
  switch (i){
    case 0: return INT;
    case 1: return DOUBLE;
    case 2: return BOOL;
    case 3: return CHAR;
    
    default: return VOID;
  }
}


/* Conversions de type primitif vers blob */

// Conversion de bool vers blob
blob bool2blob(bool b){
  blob bl = 0;
  memcpy(&bl, &b, sizeof(bool));
  return b;
}

// Conversion de char vers blob
blob char2blob(char c){
  blob b = 0;
  memcpy(&b, &c, sizeof(char));
  return b;
}

// Conversion de int vers blob
blob int2blob(int i){
  blob b = 0;
  memcpy(&b, &i, sizeof(int));
  return b;
}

// Conversion de double vers blob
blob double2blob(double d){
  blob b = 0;
  memcpy(&b, &d, sizeof(double));
  return b;
}

// Conversion de pointeur vers blob
blob ptr2blob(void *p){
  blob b = 0;
  memcpy(&b, &p, sizeof(double));
  return b;
}

/* Conversions de blob vers type primitif */

// Conversion de blob vers bool
bool blob2bool(blob bl){
  bool b = 0;
  memcpy(&b, &bl, sizeof(bool));
  return b != false;
}

// Conversion de blob vers char
char blob2char(blob b){
  char c = 0;
  memcpy(&c, &b, sizeof(char));
  return c;
}

// Conversion de blob vers int
int blob2int(blob b){
  int i = 0;
  memcpy(&i, &b, sizeof(int));
  return i;
}

// Conversion de blob vers double
double blob2double(blob b){
  double d = 0;
  memcpy(&d, &b, sizeof(double));
  return d;
}

// Conversion de blob vers pointeur
void *blob2ptr(blob b){
  void *p = NULL;
  memcpy(&p, &b, sizeof(double));
  return p;
}


/* Fonction sur les variables versatiles */

// Initialise une variable versatile
ninja init_ninja(blob b, types t){
  ninja n = {b, t};
  return n;
}

// Affiche une variable versatile
void aff_ninja(ninja n){
  switch (n.nat){
  case BOOL:
    if (n.val){
      printf("TRUE (BOOL)");
    } else {
      printf("FALSE (BOOL)");
    }
    break;

  case CHAR:
    printf("\\x%02x (CHAR)", blob2char(n.val));
    break;

  case INT:
    printf("%d (INT)", blob2int(n.val));
    break;

  case DOUBLE:
    printf("%lf (DOUBLE)", blob2double(n.val));
    break;
  
  default:
    printf("%016lx (?%d?)", n.val, n.nat);
    break;
  }
}

// Retourne true si une variable versatile est numérique, false sinon
bool est_num(ninja n){
  if (n.nat == CHAR || n.nat == INT || n.nat == DOUBLE){
    return true;
  } else {
    return false;
  }
}

// Conversion d'une variable versatile vers char 
void conv_char(ninja *n){
  if (!est_num(*n)){ return; }

  char c = '\0';
  switch(n->nat){
    case INT: 
      c = (char) blob2int(n->val); 
      break;
    case DOUBLE: 
      c = (char) blob2double(n->val); 
      break;
    default: return;
  }

  n->val = char2blob(c);
  n->nat = CHAR;
}

// Conversion d'une variable versatile vers int
void conv_int(ninja *n){
  if (!est_num(*n)){ return; }

  int i = 0;
  switch(n->nat){
    case CHAR: 
      i = (int) blob2char(n->val); 
      break;
    case DOUBLE: 
      i = (int) blob2double(n->val); 
      break;
    default: return;
  }

  n->val = int2blob(i);
  n->nat = INT;
}

// Conversion d'une variable versatile vers double
void conv_double(ninja *n){
  if (!est_num(*n)){ return; }

  double d = 0.0;
  switch(n->nat){
    case CHAR: 
      d = (double) blob2char(n->val); 
      break;
    case INT: 
      d = (double) blob2int(n->val); 
      break;
    default: return;
  }

  n->val = double2blob(d);
  n->nat = DOUBLE;
}