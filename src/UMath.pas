{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : www.epita.fr\~epita.fr
 * Date    : 02 Juin 2003
 * Changes : 03 Octobre 2017
 * License: GPL-3.0
 * Description :
 *
 *******************************************************************************}
unit UMath;

interface

uses
   Windows,
   Messages,
   UCaractere,
   SysUtils,
   math,
   OpenGL;

type TVecteur = record
   x,y,z : real;
end;

type TVecteur2D = record
   x,y : real;
end;

TCylindrique = record
   norme : real;
   theta : real;
   phi : real;
end;

function CreerNormale(const A,B,C : TVecteur) : TVecteur;
function CosScalaire(const A,B : TVecteur) : real;
function ProduitScalaire(const A,B : TVecteur) : real;
function Norme(const A : Tvecteur) : real;
function Distance(const A,B : TVecteur) : real;

implementation

function Distance(const A,B : TVecteur) : real;
begin
   result := sqrt ( sqr (A.x - B.x) +
                       sqr (A.y - B.y) +
                       sqr (A.z - B.z));
end;

function Norme(const A : Tvecteur) : real;
begin
   result := sqrt((A.x)*(A.x) + (A.y)*(A.y) + (A.z)*(A.z));
end;

function ProduitScalaire(const A,B : TVecteur) : real;
begin
   result := A.x*B.x + A.y*B.y + A.z*B.z;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
function CosScalaire(const A,B : TVecteur) : real;
begin
   result := ProduitScalaire(A,B) / (Norme(A)*Norme(B));
end;

function CreerVecteur(const A,B : TVecteur) : Tvecteur;
begin
   with result do
   begin
      x := B.x-A.x;
      y := B.y-A.y;
      z := B.z-A.z;
   end;
end;

function CreerNormale(const A,B,C : TVecteur) : TVecteur;
var N,P,PP : Tvecteur; d : real;
begin
   P := CreerVecteur(A,B);
   PP := CreerVecteur(A,C);

   N.x := P.y*PP.z-PP.y*P.z;
   N.y := P.z*PP.x-PP.z*P.x;
   N.z := P.x*PP.y-PP.x*P.y;

   d := sqrt(N.x*N.x+N.y*N.y+N.z*N.z);
   N.x := N.x/d;
   N.y := N.y/d;
   N.z := N.z/d;

   result := N;
end;

procedure PositionSurTriangle(const A,B,C,Position : Tvecteur);
var Normale,Resultat : TVecteur;
begin
   Normale := CreerNormale(A,B,C);
   Resultat.x := Position.x;
   Resultat.y := Position.y;
   Resultat.z := Position.x*Normale.x +
      Position.y*Normale.y +
      Position.z*Normale.z -
      (Normale.x*A.x+Normale.y*A.y+Normale.z*A.z);

   gltexte(100,100,0,0,1,floattostr(Resultat.x));
   gltexte(100,120,0,0,1,floattostr(Resultat.y));
   gltexte(100,140,0,0,1,floattostr(Resultat.z));
end;
end.

