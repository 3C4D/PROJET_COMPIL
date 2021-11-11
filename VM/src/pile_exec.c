#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "../inc/pile_exec.h"
#include "../inc/gest_mem.h"

// Vérifie qu'il y a assez d'espace pour empiler
void pilex_verif_esp(pilex px);


// Initialise un fragment de pile
mem mem_init(blob data, types nat, int id){
  mem ret = {nat, id, data};
  return ret;
}

// Initialise un objet pile d'execution
pilex pilex_init(int taille){
  pilex px = safe_malloc(sizeof (struct pilex_s));
  px->pile = safe_malloc(sizeof (mem) * taille);
  px->base = 0;
  px->sommet = -1;
  px->espace = taille;

  return px;
}

// Libère l'espace occupé par l'objet pile d'execution
void pilex_liberer(pilex px){
  if (px != NULL){
    free(px->pile);
    free(px);
  }
}

// Vérifie qu'il y a assez d'espace pour empiler
void pilex_verif_esp(pilex px){
  if (px->sommet >= px->espace - 1){
    // On double l'espace de la pile jusqu'à en avoir assez
    while (px->sommet >= px->espace - 1){
      px->espace *= 2;
    }
    px->pile = safe_realloc(px->pile, px->espace * sizeof (mem));
  }
}

// Retourne 1 si la pile d'execution est vide 0 sinon
int pilex_vide(pilex px){
  return (px->sommet == -1);
}

// Empile un élément
void pilex_emp(mem m, pilex px){
  pilex_verif_esp(px);
  px->pile[++px->sommet] = m;
}

// Dépile un élément
mem pilex_dep(pilex px){
    if (px->sommet >= 0){
    return px->pile[px->sommet--];
  } else {
    return mem_init(0, VOID, -1);
  }
}

// Empile un espace vide de n éléments
void pilex_empn(int n, pilex px){
  void *deb;
  px->sommet += n;
  pilex_verif_esp(px);
  deb = (void *) (px->pile + px->sommet - (n - 1));
  memset(deb, 0, sizeof (mem) * n);
}

// Depile un espace de n éléments
void pilex_depn(int n, pilex px){
  if (n > px->sommet + 1){ n = px->sommet + 1; }
  px->sommet -= n;
}

// Modifie la memoire à l'index i
void pilex_modval(mem val, int i, pilex px){
  if (i <= px->sommet && i >= 0){
    px->pile[i] = val;
  }
}

// Modifie la memoire en sommet de pile
void pilex_modsom(mem val, pilex px){
  pilex_modval(val, pilex_possom(px), px);
}

// Modifie la memoire à la base + un decalage dec
void pilex_modbase(mem val, int dec, pilex px){
  pilex_modval(val, pilex_posbase(px) + dec, px);
}

// Récupère la memoire à l'index i
mem pilex_recval(int i, pilex px){
  if (i <= px->sommet  && i >= 0){
    return px->pile[i];
  } else {
    return mem_init(0, VOID, -1);
  }
}

// Récupère la memoire en sommet de pile
mem pilex_recsomval(pilex px){
  return pilex_recval(px->sommet, px);
}

// Récupère la memoire à la base + un decalage dec
mem pilex_recbaseval(int dec, pilex px){
  return pilex_recval(px->base + dec, px);
}

// Déplace la base courante de la pile d'execution
void pilex_deplbase(int nouv_bc, pilex px){
  if (nouv_bc > px->sommet){
    px->base = px->sommet;
  } else if(nouv_bc < 0){
    px->base = 0;
  } else {
    px->base = nouv_bc;
  }
}

// Donne la position de la base d'une pile d'execution
int pilex_posbase(pilex px){
  return px->base;
}

// Donne la position du sommet d'une pile d'execution
int pilex_possom(pilex px){
  return px->sommet;
}

//Affiche le contenu de la pile d'execution
void pilex_aff(pilex px, int lim){
  mem tmp;
  bool valb;
  char valc;
  int vali;
  double vald;

  if (pilex_vide(px)){
    printf("Pile d'execution vide\n");
    return;
  }

  if (lim < 0 || lim > pilex_possom(px)){
    lim = pilex_possom(px);
  } 

  printf("\n-----===========# Pile d'execution #===========-----\n");
  printf("┌────────────┬────────────────┬────────────────────┐\n");
  printf("│   Nature   │       ID       │       Memoire      │\n");
  for (int i = 0; i <= lim; i++){
    tmp = pilex_recval(i, px);

    printf("├────────────┼────────────────┼────────────────────┤\n");

    switch (tmp.nat){
    case REGAPPL:
      printf("│ Reg. appel │  N°%-12d│ %-19ld│", tmp.id, tmp.data);
      break;

    case REGENGL:
      printf("│ Reg. englo │  N°%-12d│ %-19ld│", tmp.id, tmp.data);
      break;

    case BOOL:
      valb = blob2bool(tmp.data);
      printf("│    BOOL    │   %-13d│", tmp.id);
      if (valb){ printf("        TRUE        │"); 
      } else { printf("       FALSE        │"); }
      break;

    case CHAR:
      valc = blob2char(tmp.data);
      printf("│    CHAR    │   %-13d│%7s", tmp.id, "");
      if (valc >= ' ' && valc <= '~'){
        printf(" \'%c\'%9s│", valc, "");
      } else {
        switch (valc){
          case '\0': printf(" \'\\%c\'%8s│", '0', ""); break;
          case '\a': printf(" \'\\%c\'%8s│", 'a', ""); break;
          case '\b': printf(" \'\\%c\'%8s│", 'b', ""); break;
          case '\f': printf(" \'\\%c\'%8s│", 'f', ""); break;
          case '\n': printf(" \'\\%c\'%8s│", 'n', ""); break;
          case '\r': printf(" \'\\%c\'%8s│", 'r', ""); break;
          case '\t': printf(" \'\\%c\'%8s│", 't', ""); break;
          case '\v': printf(" \'\\%c\'%8s│", 'v', ""); break;
          
          default: printf("\'\\x%02hhx\'%7s│", valc, ""); break;
        }
      }
      
      break;

    case INT:
      vali = blob2int(tmp.data);
      printf("│    INT     │   %-13d│%7s%-13d│", tmp.id, "", vali);
      break;

    case DOUBLE:
      vald = blob2double(tmp.data);
      printf("│   DOUBLE   │   %-13d│%7s%-13.5f│", tmp.id, "", vald);
      break;

    case VOID:
      printf("│    VOID    │   %-13d│ 0x%016lx │", tmp.id, tmp.data);
      break;
    
    default:
      printf("│    ????    │      ????      │        ????        │");
      break;
    }

    if (i == pilex_posbase(px)){
      printf(" <- Base Courante");
    } else if (i % 5 == 0){
      printf(" %d", i);
    }
    printf("\n");
  }
  printf("└────────────┴────────────────┴────────────────────┘\n");
}