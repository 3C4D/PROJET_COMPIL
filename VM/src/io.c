#include <stdlib.h>
#include <stdio.h>

#include "../inc/io.h"
#include "../inc/eval.h"
#include "../../inc/macros_arbres.h"

void aff_str(char *s);

void io_affiche(ninja format, arbre args){
  ninja res;

  if (format.nat != PTR){
    fprintf(stderr, "Err: io_affiche: absence de format\n");
    exit(-1);
  }

  char *msg = (char *)blob2ptr(format.val);
  msg++;

  while (*msg != '\"'){
    if (*msg == '\\'){
        msg++;
        switch (*msg){
          case 'a': printf("\a"); break;
          case 'b': printf("\b"); break;
          case 'f': printf("\f"); break;
          case 'n': printf("\n"); break;
          case 'r': printf("\r"); break;
          case 't': printf("\t"); break;
          case 'v': printf("\v"); break;
          
          default: break;
        }
    } else if (*msg == '%'){
      msg++;
      res = eval_arbre(args->fils_gauche);
      switch (*msg){
      case 'b':
        if (blob2bool(res.val)){
          printf("TRUE");
        } else {
          printf("FALSE");
        }
        break;

      case 'c':
        printf("%c", blob2char(res.val));
        break;

      case 'd':
        printf("%d", blob2int(res.val));
        break;

      case 'f':
        printf("%lf", blob2double(res.val));
        break;

      case 's':
        aff_str((char *)blob2ptr(res.val));
        break;

      default:
        fprintf(stderr, "Err: io_affiche: format inconnu\n");
        exit(-1);
        break;
      }
      args = args->fils_gauche->frere_droit;
    } else {
      putc(*msg, stdout);
    }
    msg++;
  }
}

void aff_str(char *s){
  while(*(++s) != '\"'){
    putc(*s, stdout);
  }
}