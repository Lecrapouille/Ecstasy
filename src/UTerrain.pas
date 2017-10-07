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
      Sysutils;


CONST NB_SUB = 1;
ECHELLE_VERT = 0;

//VAR
//nbSubdivise : integer = NB_SUB_INIT;
//EchelleVert : real = ECHELLE_VERT_INIT;
//TextureDeFond : Gluint;

procedure NouveauTerrain(a,b : byte);

implementation
uses       UVille;

Procedure glBindTexture(target: GLEnum;
                        texture: GLuint);
Stdcall; External 'OpenGL32.dll';

procedure TerrainAleatoire(a,b,ElvMax : integer);
var i,j,aa,bb : byte;
begin
   with MaVille[a,b] do
   begin
       {if a = 0 then aa := NB_BLOC_MAX_X - 1 else aa := a - 1;
       if b = 0 then bb := NB_BLOC_MAX_Y - 1 else bb := b - 1;}
       if a = (NB_BLOC_MAX_X - 1) then aa := 0 else aa := a + 1;
       if b = (NB_BLOC_MAX_Y - 1) then bb := 0 else bb := b + 1;

       Terrain[0,0]           := Maville[a,b].Carrefour.TabPos[2].z;
       Terrain[NB_SUB,NB_SUB] := Maville[aa,bb].Carrefour.TabPos[2].z;

       Terrain[NB_SUB,0]      := Maville[a,b].Route0.TabPos[2].z;
       Terrain[0,NB_SUB]      := Maville[a,b].Route1.TabPos[2].z;


      for i := 1 to NB_SUB do
      begin
         for j := 1 to NB_SUB do
         begin
            //Terrain[i,j] := 0.97*Terrain[i-1,j-1]+0.03*random(ElvMax);
            //Terrain[i,j] := Terrain[i-1,j-1];
         end;
      end;
   end;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure CreerTerrain(a,b : byte);
var i,j : integer;
PasX,PasY : real;
P1,P2,P3,P4 : TVecteur;
begin
   PasX := LONG_ROUTE_X/NB_SUB;
   PasY := LONG_ROUTE_Y/NB_SUB;

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
   glBindTexture(GL_TEXTURE_2D, Text_sol);
   gltranslated(Maville[a,b].Carrefour.TabPos[0].x+ESPACE_CAREFOUR,
                Maville[a,b].Carrefour.TabPos[0].y+ESPACE_CAREFOUR,0);
   for i :=0 to NB_SUB-1 do
      for j :=0 to NB_SUB-1 do
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
procedure NouveauTerrain(a,b : byte);
begin
   TerrainAleatoire(a,b,200);
   CreerTerrain(a,b);
end;

end.
