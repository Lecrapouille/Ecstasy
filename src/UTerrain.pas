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


CONST NB_SUB = 32;
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

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure LoadRawFile(strName : String);
//var F : File;
begin
   //  AssignFile(F, strName);
   //{$I-}
   //   Reset(F, 1);
   //{$I+}
   //  if IOResult <> 0 then
   //  begin
   //    MessageBox(0, 'Il n''y a pas de Height Map au format *.RAW!', 'Error', MB_OK);
   //    Exit;
   //  end;
   //  BlockRead(F,iiiiiiii,sizeof(image));
   //  CloseFile(F);
end;

procedure TerrainAleatoire(a,b, {Elv1,Elv2,Elv3,Elv4,}ElvMax : integer);
var i,j : byte;
begin
   with MaVille[a,b] do
   begin
      {Terrain[0,0]           := Elv1;
       Terrain[0,NB_SUB]      := Elv2;
       Terrain[NB_SUB,0]      := Elv3;
       Terrain[NB_SUB,NB_SUB] := Elv4;

       for i := 1 to NB_SUB-1 do
       Terrain[}



      for i := 1 to 16 do
      begin
         for j := 1 to 16 do
         begin
            Terrain[i,j] := 0.97*Terrain[i-1,j-1]+0.03*random(ElvMax);
            Terrain[32-i,32-j] := Terrain[i,j];
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
   // glEndList();
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure NouveauTerrain(a,b : byte);
begin
   //LoadRawFile('data/Terrain/terrain.raw');
   TerrainAleatoire(a,b,200);
   CreerTerrain(a,b);
end;

end.
