{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : https://github.com/Lecrapouille/Ecstasy
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
function PositionZSurTriangle(pA, pB, pC, p : Tvecteur) : real;
function PointDansTriangle(pA, pB, pC, p : Tvecteur) : Boolean;

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

{pA,pB,pC: points 3D du triangle, p: le point 2D a tester}
function PositionZSurTriangle(pA, pB, pC, p : Tvecteur) : real;
var a, b, c, d : real;
begin
    // Equation plan: ax+by+cz+d=0
    a := (pB.y - pA.y) * (pC.z - pA.z) - (pC.y - pA.y) * (pB.z - pA.z);
    b := (pB.z - pA.z) * (pC.x - pA.x) - (pC.z - pA.z) * (pB.x - pA.x);
    c := (pB.x - pA.x) * (pC.y - pA.y) - (pC.x - pA.x) * (pB.y - pA.y);
    d := -(a * pA.x + b * pA.y + c * pA.z);
    // z = (-d -ax -by) / c
    result := (-d - a * p.x - b * p.y) / c;
end;

function signe(pA, pB, pC: Tvecteur): real;
begin
    result := (pA.x - pC.x) * (pB.y - pC.y) - (pB.x - pC.x) * (pA.y - pC.y);
end;

{pA,pB,pC: points 3D du triangle, p: le point 2D a tester}
function PointDansTriangle(pA, pB, pC, p : Tvecteur) : Boolean;
var b1, b2, b3: Boolean;
begin
    b1 := signe(p, pA, pB) < 0.0;
    b2 := signe(p, pB, pC) < 0.0;
    b3 := signe(p, pC, pA) < 0.0;

    result := (b1 = b2) AND (b2 = b3);
end;

end.

