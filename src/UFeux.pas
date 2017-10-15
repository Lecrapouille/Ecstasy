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
unit UFeux;

interface

uses Opengl,
     UVille,
     UTextures,
     Utypege;

procedure DisplayListFeuxTricolores();

implementation

{*******************************************************************************
 *
 *  Creation de 12 listes d'affichage pour l'eclairage des feux tricolores
 *
 *******************************************************************************}
procedure DisplayListFeuxTricolores();
var px,py,pz,offsetFeux : real; TabTexture : TTabTexture;
begin
   {Place les feux avant ou apres le carrefour}
   if Params.CarrefourAmericain then offsetFeux := ESPACE_CAREFOUR else offsetFeux := 0;

   TabTexture.long := 0;
   TextureBlending('data\textures\particule.bmp',TabTexture,0,0,0,8,1,0,0);
   TextureBlending('data\textures\particule.bmp',TabTexture,0,0,0,8,0,1,0);
   TextureBlending('data\textures\particule.bmp',TabTexture,0,0,0,8,1,1,0);

   {Lumiere verte sur le premier feu}
   px := MaVille[0,0].Carrefour.TabPos[0].x;
   py := MaVille[0,0].Carrefour.TabPos[0].y;
   pz := 0;

   if (glIsList(TabPart[0])) then glDeleteLists(TabPart[0],1);
   TabPart[0] := glGenLists(1);
   glNewList(TabPart[0],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+16, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+29, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le premier feu}
   if (glIsList(TabPart[1])) then glDeleteLists(TabPart[1],1);
   TabPart[1] := glGenLists(1);
   glNewList(TabPart[1],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+18, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+31, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge sur le premier feu}
   if (glIsList(TabPart[2])) then glDeleteLists(TabPart[2],1);
   TabPart[2] := glGenLists(1);
   glNewList(TabPart[2],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+20, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-3+offsetFeux, py+33, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();

   {Lumiere verte sur le deuxieme feu}
   px := MaVille[0,0].Carrefour.TabPos[2].x;
   py := MaVille[0,0].Carrefour.TabPos[2].y;
   pz := 0;

   if (glIsList(TabPart[3])) then glDeleteLists(TabPart[3],1);
   TabPart[3] := glGenLists(1);
   glNewList(TabPart[3],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-15.5, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-29, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le deuxieme feu}
   if (glIsList(TabPart[4])) then glDeleteLists(TabPart[4],1);
   TabPart[4] := glGenLists(1);
   glNewList(TabPart[4],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-17.5, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-31, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge sur le deuxieme feu}
   if (glIsList(TabPart[5])) then glDeleteLists(TabPart[5],1);
   TabPart[5] := glGenLists(1);
   glNewList(TabPart[5],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-19.5, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3-offsetFeux, py-33, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();

   {Lumiere verte sur le troisieme feu}
   px := MaVille[0,0].Carrefour.TabPos[3].x;
   py := MaVille[0,0].Carrefour.TabPos[3].y;
   pz := 0;

   if (glIsList(TabPart[6])) then glDeleteLists(TabPart[6],1);
   TabPart[6] := glGenLists(1);
   glNewList(TabPart[6],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-15, py-3+offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-29, py-3+offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le troisieme feu}
   if (glIsList(TabPart[7])) then glDeleteLists(TabPart[7],1);
   TabPart[7] := glGenLists(1);
   glNewList(TabPart[7],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-18, py-3+offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-31, py-3+offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge sur le troisieme feu}
   if (glIsList(TabPart[8])) then glDeleteLists(TabPart[8],1);
   TabPart[8] := glGenLists(1);
   glNewList(TabPart[8],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-19, py-3+offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-32, py-3+offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();

   {Lumiere verte sur le quatrieme feu}
   px := MaVille[0,0].Carrefour.TabPos[1].x;
   py := MaVille[0,0].Carrefour.TabPos[1].y;
   pz := 0;//MaVille[0,0].Carrefour.TabPos[1].z;

   if (glIsList(TabPart[9])) then glDeleteLists(TabPart[9],1);
   TabPart[9] := glGenLists(1);
   glNewList(TabPart[9],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+16, py+3-offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+29, py+3-offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le quatrieme feu}
   if (glIsList(TabPart[10])) then glDeleteLists(TabPart[10],1);
   TabPart[10] := glGenLists(1);
   glNewList(TabPart[10],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+18, py+3-offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+31, py+3-offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge esur le quatrieme feu}
   if (glIsList(TabPart[11])) then glDeleteLists(TabPart[11],1);
   TabPart[11] := glGenLists(1);
   glNewList(TabPart[11],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+20, py+3-offsetFeux, pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+33, py+3-offsetFeux, pz+1+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();
end;

end.
