#include <string.h>
#include <stdio.h>

#include "../inc/blob.h"

types type_conv(int i){
  switch (i){
    case 0: return INT;
    case 1: return DOUBLE;
    case 2: return BOOL;
    case 3: return CHAR;
    
    default: return VOID;
  }
}

blob bool2blob(bool b){
  blob bl = 0;
  memcpy(&bl, &b, sizeof(bool));
  return b;
}

blob char2blob(char c){
  blob b = 0;
  memcpy(&b, &c, sizeof(char));
  return b;
}

blob int2blob(int i){
  blob b = 0;
  memcpy(&b, &i, sizeof(int));
  return b;
}

blob double2blob(double d){
  blob b = 0;
  memcpy(&b, &d, sizeof(double));
  return b;
}

blob ptr2blob(void *p){
  blob b = 0;
  memcpy(&b, &p, sizeof(double));
  return b;
}

bool blob2bool(blob bl){
  bool b = 0;
  memcpy(&b, &bl, sizeof(bool));
  return b != false;
}

char blob2char(blob b){
  char c = 0;
  memcpy(&c, &b, sizeof(char));
  return c;
}

int blob2int(blob b){
  int i = 0;
  memcpy(&i, &b, sizeof(int));
  return i;
}

double blob2double(blob b){
  double d = 0;
  memcpy(&d, &b, sizeof(double));
  return d;
}

void *blob2ptr(blob b){
  void *p = NULL;
  memcpy(&p, &b, sizeof(double));
  return p;
}

ninja init_ninja(blob b, types t){
  ninja n = {b, t};
  return n;
}

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

bool est_num(ninja n){
  if (n.nat == CHAR || n.nat == INT || n.nat == DOUBLE){
    return true;
  } else {
    return false;
  }
}

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