#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "../inc/io.h"
#include "../inc/eval.h"
#include "../inc/execution.h"
#include "../../inc/macros_arbres.h"
#include "../../TabDecla/inc/TabDecla.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../inc/couleur.h"

// Affiche une chaine de caratères
void aff_str(char *s);

// Affiche sur la sortie standard les variables données par args selon le format 
void io_affiche(ninja format, arbre args){
  ninja res;

  if (format.nat != PTR){
    err_exec("io_affiche: absence de format");
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
        err_exec("io_affiche: format inconnu");
        break;
      }
      args = args->fils_gauche->frere_droit;
    } else {
      putc(*msg, stdout);
    }
    msg++;
  }
}


// Affiche une chaine de caractères
void aff_str(char *s){
  while(*(++s) != '\"'){
    putc(*s, stdout);
  }
}


// Lit sur l'entrée standard les variables données par vars
void io_lire(arbre vars){
  var_info info;
  mem val;
  ninja ent;
  char buf[6];
  char c; int i; double d;

  if (est_vide(vars)){ return; }
  info = info_pile_var(vars->fils_gauche);
  ent.nat = info.nat;
  
  switch (info.nat){
    case BOOL:
      if (scanf("%5s", buf) == EOF){ err_exec("io_lire: Pb. de lecture"); }
      if (strcmp("true", buf) == 0 || strcmp("1", buf) == 0){
        ent.val = bool2blob(true);
      } else {
        ent.val = bool2blob(false);
      }
      break;

    case CHAR:
      if(scanf(" %c", &c) == EOF){ err_exec("io_lire: Pb. de lecture"); }
      ent.val = char2blob(c);
      break;

    case INT:
      if(scanf("%d", &i) == EOF){ err_exec("io_lire: Pb. de lecture"); }
      ent.val = int2blob(i);
      break;

    case DOUBLE:
      if(scanf("%lf", &d) == EOF){ err_exec("io_lire: Pb. de lecture"); }
      ent.val = double2blob(d);
      break;
    
    default:
      err_exec("io_lire: type de variable inconnu");
      break;
  }

  val = mem_init(ent.val, ent.nat, pilex_recval(info.dec, pile_exec_g).id);
  pilex_modval(val, info.dec, pile_exec_g);

  io_lire(vars->fils_gauche->frere_droit);
}


// Affiche une erreur d'exécution
void err_exec(char *msg){
  int numdecl_reg;

  fprintf(
    stderr, "%s\nErr. exec.: %s%s%s\n\tDans: ", JAUNEGRAS, msg, RESET, JAUNE
  );

  if (reg_actu_g == 0){
    fprintf(stderr, "Région initiale\n");
  } else {
    numdecl_reg = num_decl_reg(reg_actu_g);
    if (numdecl_reg != -1){
      if (nature(numdecl_reg) == PROC){
        fprintf(
          stderr, 
          "Procedure: %s (Région %d)\n", 
          lexeme(decl2lex(numdecl_reg)), 
          reg_actu_g
        );
      } else {
        fprintf(
          stderr, 
          "Fonction: %s (Région %d)\n", 
          lexeme(decl2lex(numdecl_reg)),
          reg_actu_g
        );
      }
    } else {
      fprintf(
        stderr, 
        "Région %d, Nature inconnue (/!\\ Évenement fortement anormal)",
        reg_actu_g
      );
    }
  }

  fprintf(stderr, RESET);

  pilex_aff(pile_exec_g, LIMITE_DEBUG);
  exit(-1);
}