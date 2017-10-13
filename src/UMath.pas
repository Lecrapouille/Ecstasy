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
function PositionZSurTriangle(p1, p2, p3, p : Tvecteur) : real;
function PointDansTriangle(p0, p1, p2, p : Tvecteur) : Boolean;

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
function PositionZSurTriangle(p1, p2, p3, p : Tvecteur) : real;
var det, l1, l2, l3 : real;
begin
        det := (p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y);

        l1 := ((p2.y - p3.y) * (p.x - p3.x) + (p3.x - p2.x) * (p.y - p3.y)) / det;
        l2 := ((p3.y - p1.y) * (p.x - p3.x) + (p1.x - p3.x) * (p.y - p3.y)) / det;
        l3 := 1.0 - l1 - l2;

        result := l1 * p1.z + l2 * p2.z + l3 * p3.z;
end;

{ http://jsfiddle.net/PerroAZUL/zdaY8/1/ }
function PointDansTriangle(p0, p1, p2, p : Tvecteur) : Boolean;
var DoubleArea, sign, s, t : real;
begin
    // Area = 0.5f * DoubleArea
    DoubleArea := -p1.y * p2.x + p0.y * (-p1.x + p2.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y;
    if DoubleArea < 0.0 then sign := -1.0 else sign := 1.0;
    s := (p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * p.x + (p0.x - p2.x) * p.y) * sign;
    t := (p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * p.x + (p1.x - p0.x) * p.y) * sign;

    result := (s > 0.0) AND (t > 0.0) AND ((s + t) < DoubleArea * sign);
end;

end.

