cpyrr

// Matrice
type matrice : array[-4_5, -4_5] of int;

// Tableau de tableau sensiblement équivalent à matrice
type tab : array[-4_5] of int;
type tabOfTab : array[-4_5] of tab;

var mat1 : matrice;
var mat2 : tabOfTab;

proc initMat
  var i : int;
  var j : int;
  {
    i := -4;
    while(i != 6) do{
      j := -4;
      while(j != 6) do{
        mat1[i][j] := 50 - 2*i+j;
        mat2[i][j] := 50 - i+2*j;
        j := j+1;
      }
      i := i+1;
    }
  }

proc afficheMat
  var i : int;
  var j : int;
  {

    afficher("Matrice : \n");

    i := -4;
    while(i != 6) do{
      j := -4;
      while(j != 6) do{
        afficher("%d  ", mat1[i][j]);
        j := j+1;
      }
      afficher("\n");
      i := i+1;
    }

    afficher("Tableau de tableau : \n");

    i := -4;
    while(i != 6) do{
      j := -4;
      while(j != 6) do{
        afficher("%d  ", mat2[i][j]);
        j := j+1;
      }
      afficher("\n");
      i := i+1;
    }
  }

proc transpose
  var i : int;
  var j : int;
  var tmp : int;
  var tmp1 : matrice;
  var tmp2 : tabOfTab;
  {

    i := -4;
    while(i != 6) do{
      j := -4;
      while(j != 6) do{
        tmp1[i][j] := mat1[j][i];
        tmp2[i][j] := mat2[j][i];
        j := j+1;
      }
      i := i+1;
    }

    i := -4;
    while(i != 6) do{
      j := -4;
      while(j != 6) do{
        mat1[i][j] := tmp1[i][j];
        mat2[i][j] := tmp2[i][j];
        j := j+1;
      }
      i := i+1;
    }
  }

{
  initMat();

  afficher("Matrices : \n");
  afficheMat();
  transpose();

  afficher("\nTransposées : \n");
  afficheMat();
}
