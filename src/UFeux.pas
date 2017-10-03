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
procedure TextureBlending(Chemin : string; var TabTexture : TTabTexture;
                          x,y,z : real; ech : integer; c1,c2,c3 : byte);

implementation

Procedure glBindTexture(target: GLEnum; texture: GLuint); Stdcall; External 'OpenGL32.dll';

{*******************************************************************************
 *
 *                             TEXTURE + BLENDING
 *
 *   parametres :
 *      Chemin : l'endroit ou se trouve la texture
 *      var TabTexture : Tableau pouvant contenir plusieurs textures
 *      x,y,z : position de la texture
 *      ech :  echelle  de la texture
 *      c1,c2,c3 : couleur Rouge, Verte, Bleue
 *
 *******************************************************************************}
procedure TextureBlending(Chemin : string;
                          var TabTexture : TTabTexture;
                          x,y,z : real;  // position
                          ech : integer; // echelle
                          c1,c2,c3 : byte); // couleur
var numero : gluint;
begin
   LoadTexture(Chemin, numero, false);
   if (glIsList(TabTexture.elt[TabTexture.long])) then glDeleteLists(TabTexture.elt[TabTexture.long],1);
   TabTexture.elt[TabTexture.long] := glGenLists(1);
   glNewList(TabTexture.elt[TabTexture.long],GL_COMPILE);
   glEnable(GL_BLEND);
   glDepthMask(GL_FALSE);
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, numero);

   glPushMatrix();
   glTranslatef(x,y,z);
   glcolor4f(c1,c2,c3,1);
   glBegin(GL_QUADS);
   glTexCoord2f(0, 0);  glVertex3f(-1*ech,-1*ech, 0);
   glTexCoord2f(1, 0);  glVertex3f( 1*ech,-1*ech, 0);
   glTexCoord2f(1, 1);  glVertex3f( 1*ech, 1*ech, 0);
   glTexCoord2f(0, 1);  glVertex3f(-1*ech, 1*ech, 0);
   glEnd();
   glPopMatrix();

   glDepthMask(GL_TRUE);
   glDisable(GL_BLEND);
   glDisable(GL_TEXTURE_2D);
   glEndList();
   TabTexture.long := TabTexture.long+1;
end;

{*******************************************************************************
 *
 *  Creation de 12 listes d'affichage pour l'eclairage des feux tricolores
 *
 *******************************************************************************}
procedure DisplayListFeuxTricolores();
var px,py,pz : real; TabTexture : TTabTexture;
begin
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
   gltranslated(px-3,py+10.4,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-3,py+10.4+6.4,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le premier feu}
   if (glIsList(TabPart[1])) then glDeleteLists(TabPart[1],1);
   TabPart[1] := glGenLists(1);
   glNewList(TabPart[1],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-3,py+11.2,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-3,py+11.2+6.4,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge esur le premier feu}
   if (glIsList(TabPart[2])) then glDeleteLists(TabPart[2],1);
   TabPart[2] := glGenLists(1);
   glNewList(TabPart[2],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-2,py+12,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-2,py+12+7.9,pz+0.6+HAUTEUR_FEU_TRICOLORE);
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
   gltranslated(px+3,py-10.4,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3,py-10.4-6.4,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le deuxieme feu}
   if (glIsList(TabPart[4])) then glDeleteLists(TabPart[4],1);
   TabPart[4] := glGenLists(1);
   glNewList(TabPart[4],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+3,py-11.2,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3,py-11.2-6.4,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge sur le deuxieme feu}
   if (glIsList(TabPart[5])) then glDeleteLists(TabPart[5],1);
   TabPart[5] := glGenLists(1);
   glNewList(TabPart[5],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+3,py-12.1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+3,py-12.1-6.4,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();


   ////
   {Lumiere verte sur le troisieme feu}
   px := MaVille[0,0].Carrefour.TabPos[3].x;
   py := MaVille[0,0].Carrefour.TabPos[3].y;
   pz := 0;//MaVille[0,0].Carrefour.TabPos[3].z;

   if (glIsList(TabPart[6])) then glDeleteLists(TabPart[6],1);
   TabPart[6] := glGenLists(1);
   glNewList(TabPart[6],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-10.4,py-1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-10.4-6.4,py-1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le troisieme feu}
   if (glIsList(TabPart[7])) then glDeleteLists(TabPart[7],1);
   TabPart[7] := glGenLists(1);
   glNewList(TabPart[7],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-11.2,py-1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-11.2-6.4,py-1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge sur le troisieme feu}
   if (glIsList(TabPart[8])) then glDeleteLists(TabPart[8],1);
   TabPart[8] := glGenLists(1);
   glNewList(TabPart[8],GL_COMPILE);
   glpushMatrix();
   gltranslated(px-12.1,py-1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px-12.1-6.4,py-1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
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
   gltranslated(px+10.4,py+1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+10.4+6.4,py+1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[1]);
   glPopMatrix();
   GlEndList();

   {Lumiere orange sur le quatrieme feu}
   if (glIsList(TabPart[10])) then glDeleteLists(TabPart[10],1);
   TabPart[10] := glGenLists(1);
   glNewList(TabPart[10],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+11.2,py+1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+11.2+6.4,py+1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[2]);
   glPopMatrix();
   GlEndList();

   {Lumiere rouge esur le quatrieme feu}
   if (glIsList(TabPart[11])) then glDeleteLists(TabPart[11],1);
   TabPart[11] := glGenLists(1);
   glNewList(TabPart[11],GL_COMPILE);
   glpushMatrix();
   gltranslated(px+12.1,py+1,pz+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();

   glpushMatrix();
   gltranslated(px+12.1+6.4,py+1,pz+0.4+HAUTEUR_FEU_TRICOLORE);
   glrotated(90,1,0,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();
end;

end.
