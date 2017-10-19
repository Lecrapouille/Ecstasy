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
unit UAltitude;

interface

uses UTypege,
     UCaractere,
     Sysutils,
     UTerrain,
     UVille,
     UMath;

function Altitude(x,y : real) : real;
function QuellePartition(const x,y : real) : TCouple;
function QuelleRoute(const x,y : real) : TTriplet;
procedure ModuloCarte(var P : TVecteur2D);

implementation

{******************************  Altitude  *************************************
 *
 *  Nom        : function Altitude(x,y : real) : real;
 *  Parametres : La position X et Y d'un objet (voiture, par exemple).
 *  Retourne   : l' altitude de la route.
 *
 *******************************************************************************}
function Altitude(x,y : real) : real;
var Resultat : TTriplet;
Pos : TPosition;
begin
   if x > TAILLE_MAP_X then x := x - TAILLE_MAP_X
   else if x < 0 then x := x + TAILLE_MAP_X;

   if y > TAILLE_MAP_Y then y := y - TAILLE_MAP_Y
   else if y < 0 then y := y + TAILLE_MAP_Y;


   Resultat := QuelleRoute(x,y);
   with MaVille[Resultat.x,Resultat.y] do
   begin
      case Resultat.z of
         ROUTE_0 : Pos.z := Route0.Pente * (x - Route0.TabPos[0].x) + Route0.TabPos[0].z;
         ROUTE_1 : Pos.z := Route1.Pente * (y - Route1.TabPos[0].y) + Route1.TabPos[0].z;
         LECARREFOUR : Pos.z := Carrefour.TabPos[0].z;
         MAISONS : if Resultat.y = RANGEE_DU_FLEUVE then Pos.z := PROFONDEUR_FLEUVE  // tombe dans l'eau
         else if TypeDuBloc = EST_UN_BLOC then Pos.z := AltitudeDuTrottoir(Resultat.x,Resultat.y,x,y)  // dans les immeubles
         else Pos.z := AltitudeDuTerrain(Resultat.x,Resultat.y,x,y);
      end;
   end;
   result := Pos.z;
end;

{*******************************************************************************
 *
 *  Nom        : function QuellePartition(x,y : real) : TCouple;
 *  Parametres : La position X et Y d'un objet (voiture, par exemple).
 *  Retourne   : Un couple (A,B). La ville est une matrice (array). La fonction
 *               retourne les 2 numeros de la matrice.
 *
 *******************************************************************************}
function QuellePartition(const x,y : real) : TCouple;
var Couple : Tcouple;
begin
   Couple.x := trunc(x / TAILLE_BLOC_X) mod NB_BLOC_MAX_X;
   Couple.y := trunc(y / TAILLE_BLOC_Y) mod NB_BLOC_MAX_Y;
   result := couple;
end;

{*******************************************************************************
 *
 * Nom        : QuelleRoute(x,y : real) : TTriplet;
 * Parametres : La position X et Y d'un objet (voiture, par exemple).
 * Retourne   : Un triplet (A,B,C) où A et B designent le numero de la matrice
 *              (qui represente la ville) et C sur quelle route se trouve la voiture.
 *              Si C = 0 alors l'objet est sur la Route N°0,
 *              Si C = 1 alors l'objet est sur la Route N°1,
 *              Si C = 2 alors l'objet est sur la Route Carrefour,
 *              Si C = 3 alors l'objet est dans les immeubles ou dans le fleuve.
 * Remarques  : Voir l'unite UVille pour la structure de la ville.
 *
 *******************************************************************************}
function QuelleRoute(const x, y : real) : TTriplet;
var Resultat : TTriplet; Couple : TCouple;
begin
   Couple := QuellePartition(x, y);
   if y <= MaVille[Couple.x, Couple.y].carrefour.TabPos[2].y then
   begin
      if x < MaVille[Couple.x, Couple.y].carrefour.TabPos[2].x
      then
         Resultat.z := LECARREFOUR
      else
         Resultat.z := ROUTE_0
   end
   else
   begin
      if x < MaVille[Couple.x, Couple.y].carrefour.TabPos[2].x
      then
         Resultat.z := ROUTE_1
      else
         Resultat.z := MAISONS
   end;

   Resultat.x := Couple.x; Resultat.y := Couple.y;
   result := resultat;
end;

procedure ModuloCarte(var P : TVecteur2D);
begin
   if P.x > TAILLE_MAP_X then P.x := P.x - TAILLE_MAP_X
   else if P.x < 0 then P.x := P.x + TAILLE_MAP_X;

   if P.y > TAILLE_MAP_Y then P.y := P.y - TAILLE_MAP_Y
   else if P.y < 0 then P.y := P.y + TAILLE_MAP_Y;
end;

end.
