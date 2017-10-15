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
unit UTerrain;

interface

uses  Windows,
      math,
      OpenGL,
      //      glaux,
      UTypege,
      UMath,
      Sysutils,
      URepere;

CONST
NB_SUB_TROTTOIR = 1;
NB_SUB_TERRAIN = 16;
ELEVATION_TERRAIN = 50;

procedure CreerTrottoir(a,b : byte);
procedure CreerTerrain(a,b : byte);
function AltitudeDuTerrain(x,y : real) : real;

implementation
uses       UVille;

Procedure glBindTexture(target: GLEnum;
                        texture: GLuint);
Stdcall; External 'OpenGL32.dll';

function AltitudeDuTerrain(x,y : real) : real;
var
   a, b : integer;
   pA, pB, pC, pD, p : Tvecteur;
begin
   {a := trunc(x / LONG_ROUTE_X) mod NB_SUB_TERRAIN;
   b := trunc(y / LONG_ROUTE_Y) mod NB_SUB_TERRAIN;

   pA := Maville[a,b].Carrefour.TabPos[2];
   pB := Maville[a,b].Route0.TabPos[2];
   pC := Maville[a,b].Route1.TabPos[2];
   pD := Maville[(a+1) mod NB_BLOC_MAX_X, (b+1) mod NB_BLOC_MAX_X].Carrefour.TabPos[2];

   p.x := x;
   p.y := y;
  if PointDansTriangle(pA, pB, pC, p) then
     p.z := PositionZSurTriangle(pA, pB, pC, p)
  else
     p.z := PositionZSurTriangle(pB, pD, pC, p);

     result := p.z;} result := 0;
end;

procedure TriangleDebug(pA, pB, pC : Tvecteur);
begin
   glBegin(GL_LINE_LOOP);
   glLineWidth(4.0);
   glcolor3f(0.5,0.5,0.5);
   glVertex3f(pA.x,pA.y,pA.z+1.5);
   glVertex3f(pB.x,pB.y,pB.z+1.5);
   glVertex3f(pC.x,pC.y,pC.z+1.5);
   glEnd();
end;

procedure TriangleDebug2(pA, pB, pC : Tvecteur);
begin
   glBegin(GL_LINE_LOOP);
   glLineWidth(4.0);
   glcolor3f(0.75,0.75,0.0);
   glVertex3f(pA.x,pA.y,pA.z+1.5);
   glVertex3f(pB.x,pB.y,pB.z+1.5);
   glVertex3f(pC.x,pC.y,pC.z+1.5);
   glEnd();
end;

procedure TerrainAleatoire(a, b : integer);
var i, j, k : byte;
pA, pB, pC, pD, p : Tvecteur;
begin
   with MaVille[a,b] do
   begin
      {Recupere les position des bords du quartier}
      pA := Maville[a,b].Carrefour.TabPos[2];
      pB := Maville[a,b].Route0.TabPos[2];
      pC := Maville[a,b].Route1.TabPos[2];
      pD := Maville[(a+1) mod NB_BLOC_MAX_X, (b+1) mod NB_BLOC_MAX_Y].Carrefour.TabPos[0];

         {Sur les bords de la carte appliquer un modulo de la taille carte sur les distances}
         if pA.x >= pD.x then
         begin
            pD.x := pD.x + TAILLE_MAP_X;
         end;
         if pA.y >= pD.y then
         begin
            pD.y := pD.y + TAILLE_MAP_Y;
         end;

      Terrain[0,0]                           := pA.z;
      Terrain[NB_SUB_TERRAIN,0]              := pB.z;
      Terrain[0,NB_SUB_TERRAIN]              := pC.z;
      Terrain[NB_SUB_TERRAIN,NB_SUB_TERRAIN] := pD.z;

      //TriangleDebug2(pA, pD, pC);
      //TriangleDebug(pD, pB, pA);

      {Creation de la grille: triangulation}
      for i := 0 to NB_SUB_TERRAIN do
      begin
         k := 0;
         for j := 0 to NB_SUB_TERRAIN do
         begin
             p.x := pA.x + i * LONG_ROUTE_X / NB_SUB_TERRAIN;
             p.y := pA.y + j * LONG_ROUTE_Y / NB_SUB_TERRAIN;

             if i <= j - k then begin Terrain[i,j] := PositionZSurTriangle(pA, pD, pC, p); {DessinerRepere(p.x, p.y, Terrain[i,j]+2);} end
             else begin Terrain[i,j] := PositionZSurTriangle(pD, pB, pA, p); {DessinerRepere2(p.x, p.y, Terrain[i,j]+2);} end;
         end;
         inc(k);
      end;

      {Elevation du terrain sauf sur les bords qui doivent coller a la route}
      for i := 1 to NB_SUB_TERRAIN-1 do
      begin
         for j := 1 to NB_SUB_TERRAIN-1 do
         begin
             Terrain[i,j] := 0.97*Terrain[i,j]+0.03*random(200);
         end;
      end;
   end;
end;

procedure Trottoir(a, b : integer);    // FIXME Trottoir pas Terrain
begin
   with MaVille[a,b] do
   begin
      Terrain[0,0]                             := Maville[a,b].Carrefour.TabPos[2].z;
      Terrain[NB_SUB_TROTTOIR,0]               := Maville[a,b].Route0.TabPos[2].z;
      Terrain[0,NB_SUB_TROTTOIR]               := Maville[a,b].Route1.TabPos[2].z;
      Terrain[NB_SUB_TROTTOIR,NB_SUB_TROTTOIR] := Maville[(a+1) mod NB_BLOC_MAX_X, (b+1) mod NB_BLOC_MAX_X].Carrefour.TabPos[2].z;
   end;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure ListeAffichageTerrain(a, b, subdivision : byte; texture: gluint);
var i,j : integer;
PasX,PasY : real;
P1,P2,P3,P4 : TVecteur;
begin
   PasX := LONG_ROUTE_X/subdivision;
   PasY := LONG_ROUTE_Y/subdivision;

   //if (glIsList(terrain)) then glDeleteLists(terrain,1);
   //terrain := glGenLists(1);
   //glNewList(terrain, GL_COMPILE);
   //

   //glPolygonMode(GL_FRONT, GL_LINE);
   //glPolygonMode(GL_BACK, GL_LINE);
   GlPushMatrix();

   glcullface(GL_BACK);
   glcolor3f(1,1,1);
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, texture);
   gltranslated(Maville[a,b].Carrefour.TabPos[0].x+ESPACE_CAREFOUR,
                Maville[a,b].Carrefour.TabPos[0].y+ESPACE_CAREFOUR,0);
   for i :=0 to (NB_SUB_TERRAIN-1) do
      for j :=0 to (NB_SUB_TERRAIN-1) do
      begin
         P1.x := -1+i*pasX;
         P1.y := -1+j*pasY;
         P1.z := Maville[a,b].Terrain[i,j];

         P2.x := -1+(i+1)*pasX;
         P2.y := -1+j*pasY;
         P2.z := Maville[a,b].Terrain[i+1,j];

         P3.x := -1+(i+1)*pasX;
         P3.y := -1+(j+1)*pasY;
         P3.z := Maville[a,b].Terrain[i+1,j+1];

         P4.x := -1+i*pasX;
         P4.y := -1+(j+1)*pasY;
         P4.z := Maville[a,b].Terrain[i,j+1];

         glBegin(GL_Triangles);
         glTexCoord2f(0,0); glVertex3f(P1.x,P1.y,P1.z);
         glTexCoord2f(0,1); glVertex3f(P2.x,P2.y,P2.z);
         glTexCoord2f(1,1); glVertex3f(P3.x,P3.y,P3.z);

         glTexCoord2f(0,0); glVertex3f(P1.x,P1.y,P1.z);
         glTexCoord2f(1,1); glVertex3f(P3.x,P3.y,P3.z);
         glTexCoord2f(1,0); glVertex3f(P4.x,P4.y,P4.z);
         glend();
      end;
   glDisable(GL_TEXTURE_2D);
   glcullface(GL_FRONT);

   GlPopMatrix();
   //glPolygonMode(GL_FRONT, GL_FILL);
   //glPolygonMode(GL_BACK, GL_FILL);
   // glEndList();
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure CreerTerrain(a,b : byte);
begin
   TerrainAleatoire(a, b);
   ListeAffichageTerrain(a, b, NB_SUB_TERRAIN, Text_sol);
end;

procedure CreerTrottoir(a,b : byte);
begin
   Trottoir(a, b);
   ListeAffichageTerrain(a, b, NB_SUB_TROTTOIR, Text_pont);
end;

end.
