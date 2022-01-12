#include <stdlib.h>
#include <stdio.h>

#include "../inc/io.h"
#include "../inc/blob.h"
#include "../inc/eval.h"
#include "../inc/execution.h"
#include "../../inc/macros_arbres.h"
#include "../../GenTexte/inc/GenTexte.h"
#include "../../TabDecla/inc/TabDecla.h"
#include "../../TabLexico/inc/TabLexico.h"
#include "../../TabRegion/inc/TabRegion.h"
#include "../../TabRepresentation/inc/TabRepresentation.h"

/* Opérations booléennes */
ninja bool_op(ninja a, bool (* op)(bool, bool), ninja b);
bool et (bool a, bool b);
bool ou (bool a, bool b);
bool non (bool a, bool b);

/* Opérations de comparaisons */
ninja cmp_op(ninja a, bool (* op)(blob, blob, types), ninja b);
bool inf(blob a, blob b, types t);
bool infeq(blob a, blob b, types t);
bool sup(blob a, blob b, types t);
bool supeq(blob a, blob b, types t);
bool eq(blob a, blob b, types t);
bool diff(blob a, blob b, types t);

/* Opérations arithmétiques */
ninja artihm_op(ninja a, blob (* op)(blob, blob, types), ninja b);
blob plus(blob a, blob b, types t);
blob moins(blob a, blob b, types t);
blob mult(blob a, blob b, types t);
blob divi(blob a, blob b, types t);
blob mod(blob a, blob b, types t);

// Unifie les types des 2 variables numériques
types uninumtype(ninja *a, ninja *b);


// Évalue la valeur de l'arbre a de manière récursive
ninja eval_arbre(arbre a){
  var_info var;
  ninja n = init_ninja(0, VOID);
  if (est_vide(a)){ return n; }

  switch (a->nature){
  case A_EXPRESSION : return eval_arbre(a->fils_gauche);

  case A_PLUS :
    return artihm_op(
      eval_arbre(a->fils_gauche),
      plus,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_MOINS :
    return artihm_op(
      eval_arbre(a->fils_gauche),
      moins,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_MULT :
    return artihm_op(
      eval_arbre(a->fils_gauche),
      mult,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_DIV :
    return  artihm_op(
      eval_arbre(a->fils_gauche),
      divi,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_MODULO :
    return artihm_op(
      eval_arbre(a->fils_gauche),
      mod,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_ET :
    return bool_op(
      eval_arbre(a->fils_gauche),
      et,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_OU :
    return bool_op(
      eval_arbre(a->fils_gauche),
      ou,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_NON :
    return bool_op(
      eval_arbre(a->fils_gauche),
      non,
      init_ninja(0, BOOL));

  case A_EGAL :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      eq,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_DIFFERENT :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      diff,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_SUP :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      sup,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_SUP_EGAL :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      supeq,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_INF :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      inf,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_INF_EGAL :
    return cmp_op(
      eval_arbre(a->fils_gauche),
      infeq,
      eval_arbre(a->fils_gauche->frere_droit));

  case A_CSTE_ENT : return init_ninja(int2blob(a->entier), INT);

  case A_CSTE_REEL : return init_ninja(double2blob(a->reel), DOUBLE);

  case A_CSTE_CHAR : return init_ninja(char2blob((char)a->entier), CHAR);

  case A_CSTE_CHAINE :
    return init_ninja(ptr2blob((void *)lexeme(a->numlex)), PTR);

  case A_TRUE : return init_ninja(bool2blob(true), BOOL);

  case A_FALSE : return init_ninja(bool2blob(false), BOOL);

  case A_APPEL_FCT :
    exec_arbre(a);
    return retval_g;

  case A_VAR :
    var = info_pile_var(a);
    return init_ninja(pilex_recval(var.dec, pile_exec_g).data, var.nat);

  default:
    err_exec("Eval: Noeud non reconnu", true);
  }

  return n;
}


/* Opérations booléennes */
ninja bool_op(ninja a, bool (* op)(bool, bool), ninja b){
  return init_ninja(op(blob2bool(a.val), blob2bool(b.val)), BOOL);
}

// Opération: ⋀
bool et (bool a, bool b){ return a && b; }
// Opération: ⋁
bool ou (bool a, bool b){ return a || b; }
// Opération: ¬
bool non (bool a, bool b){ return !a; }


/* Opérations de comparaisons */
ninja cmp_op(ninja a, bool (* op)(blob, blob, types), ninja b){
  if (op != eq && op != diff){
    if (!est_num(a) || !est_num(b)){
      return init_ninja(0, VOID);
    }
  }

  types t = uninumtype(&a, &b);

  return init_ninja(op(a.val, b.val, t), BOOL);
}

// Opération: <
bool inf(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) < blob2char(b);
    case INT:
      return blob2int(a) < blob2int(b);
    case DOUBLE:
      return blob2double(a) < blob2double(b);
    default: return false;
  }
}

// Opération: ⩽
bool infeq(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) <= blob2char(b);
    case INT:
      return blob2int(a) <= blob2int(b);
    case DOUBLE:
      return blob2double(a) <= blob2double(b);
    default: return false;
  }
}

// Opération: >
bool sup(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) > blob2char(b);
    case INT:
      return blob2int(a) > blob2int(b);
    case DOUBLE:
      return blob2double(a) > blob2double(b);
    default: return false;
  }
}

// Opération: ⩾
bool supeq(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) >= blob2char(b);
    case INT:
      return blob2int(a) >= blob2int(b);
    case DOUBLE:
      return blob2double(a) >= blob2double(b);
    default: return false;
  }
}

// Opération: =
bool eq(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) == blob2char(b);
    case INT:
      return blob2int(a) == blob2int(b);
    case DOUBLE:
      return blob2double(a) == blob2double(b);
    default: return false;
  }
}

// Opération: ≠
bool diff(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return blob2char(a) != blob2char(b);
    case INT:
      return blob2int(a) != blob2int(b);
    case DOUBLE:
      return blob2double(a) != blob2double(b);
    default: return false;
  }
}


/* Opérations arithmétiques */
ninja artihm_op(ninja a, blob (* op)(blob, blob, types), ninja b){
  if (!est_num(a) || !est_num(b)){
    return init_ninja(0, VOID);
  }

  types t = uninumtype(&a, &b);

  return init_ninja(op(a.val, b.val, t), t);
}

// Opération: +
blob plus(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return char2blob(blob2char(a) + blob2char(b));
    case INT:
      return int2blob(blob2int(a) + blob2int(b));
    case DOUBLE:
      return double2blob(blob2double(a) + blob2double(b));
    default: return 0;
  }
}

// Opération: -
blob moins(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return char2blob(blob2char(a) - blob2char(b));
    case INT:
      return int2blob(blob2int(a) - blob2int(b));
    case DOUBLE:
      return double2blob(blob2double(a) - blob2double(b));
    default: return 0;
  }
}

// Opération: ×
blob mult(blob a, blob b, types t){
  switch(t){
    case CHAR:
      return char2blob(blob2char(a) * blob2char(b));
    case INT:
      return int2blob(blob2int(a) * blob2int(b));
    case DOUBLE:
      return double2blob(blob2double(a) * blob2double(b));
    default: return 0;
  }
}

// Opération: ÷
blob divi(blob a, blob b, types t){
  switch(t){
    case CHAR:
      if (blob2char(b) == 0){ err_exec("Division par 0", true); }
      return char2blob(blob2char(a) / blob2char(b));
    case INT:
      if (blob2int(b) == 0){ err_exec("Division par 0", true); }
      return int2blob(blob2int(a) / blob2int(b));
    case DOUBLE:
      if (blob2double(b) == 0){ err_exec("Division par 0", true); }
      return double2blob(blob2double(a) / blob2double(b));
    default:
      return 0;
  }
}

// Opération: % (modulo)
blob mod(blob a, blob b, types t){
  switch(t){
    case CHAR:
      if (blob2char(b) == 0) { err_exec("Modulo 0", true); }
      return char2blob(blob2char(a) % blob2char(b));
    case INT:
      if (blob2int(b) == 0) { err_exec("Modulo 0", true); }
      return int2blob(blob2int(a) % blob2int(b));
    case DOUBLE:
      if ((int)blob2double(b) == 0) { err_exec("Modulo 0", true); }
      return double2blob((double)((int)blob2double(a) % (int)blob2double(b)));
    default: return 0;
  }
}


// Unifie les types des 2 variables numériques
types uninumtype(ninja *a, ninja *b){
  types t;
  if(a->nat == DOUBLE || b->nat == DOUBLE){
    conv_double(a);
    conv_double(b);
    t = DOUBLE;
  } else if (a->nat == INT || b->nat == INT){
    conv_int(a);
    conv_int(b);
    t = INT;
  } else {
    conv_char(a);
    conv_char(b);
    t = CHAR;
  }

  return t;
}
