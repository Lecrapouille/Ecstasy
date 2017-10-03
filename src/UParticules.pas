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
unit UParticules;

interface

uses Opengl, UMath, UTypege;

const NB_PART = 200;
NB_PART_PLUIE = 200;
SIMPLE = 0;
MISSILE = 1;
ARTIFICE = 2;

Type TPParticule = ^TParticule;
TParticule = record
   A : TVecteur;  // Acceleration
   P : TVecteur;  // Position
   V : TVecteur;  // Vitesse
   C : TVecteur;   // Couleur
   Life : integer; // Vie
   Generation : integer;  // type de particules
   Next : TPParticule;
end;

TSysteme = class(TObject)
public
   ListeParticule : TPParticule;
   constructor create();
   procedure Actualise(var liste : TPParticule);
private
   procedure AjoutUneParticule(const ax,ay,az, vx,vy,vz, px,py,pz {c1,c2,c3} : real;
                               const Life : integer;
                               const Generation : integer;
                               var liste : TPParticule);
   procedure Affiche(Particule : TPParticule);
   procedure Physique(Particule : TPParticule);
   procedure Erase(var liste : TPParticule);
end;

TPluie = class(TSysteme)
public
   constructor create(const P : TVecteur);
   procedure Actualise(const P : TVecteur; var liste : TPParticule);
   //  private
   //    procedure Affiche(Particule : TPParticule);
end;

var Systeme : TSysteme;
Pluie : TPluie;

procedure Fumee();

implementation

Procedure glBindTexture(target: GLEnum;
                        texture: GLuint);
Stdcall; External 'OpenGL32.dll';

function RandomIntervale(const nb : integer) : integer;
var ran1,ran2 : integer;
begin
   ran1 := random(2);
   ran2 := random(nb)+1;

   if ran1 = 0 then result := -ran2
   else result := ran2;
end;

{*******************************************************************************
 *
 *                             SYSTEME DE PARTICULE
 *
 *******************************************************************************}

procedure TSysteme.AjoutUneParticule(const ax,ay,az, vx,vy,vz, px,py,pz {c1,c2,c3} : real;
                                     const Life : integer;
                                     const Generation : integer;
                                     var liste : TPParticule);
var Temp : TPParticule;
begin
   new(temp);
   temp^.Life := Life;
   temp^.Generation := Generation;

   temp^.A.x := ax;
   temp^.A.y := ay;
   temp^.A.z := az;

   temp^.V.x := vx;
   temp^.V.y := vy;
   temp^.V.z := vz;

   temp^.P.x := px;
   temp^.P.y := py;
   temp^.P.z := pz;

   temp^.next := liste;
   liste := temp;
end;

procedure TSysteme.Affiche(Particule : TPParticule);
begin
   glDisable(GL_CULL_FACE);
   glEnable(GL_BLEND);
   glDepthMask(GL_FALSE);
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, Text_part);

   glPushMatrix();
   gltranslated(Particule^.P.x,Particule^.P.y,Particule^.P.z);
   glrotated(90,1,1,0);
   glscaled(0.3,0.3,0.3);
   glcolor3f(1,1,1);
   glBegin(GL_QUADS);
   glTexCoord2f(0, 0);  glVertex3f(-1,-1, 0);
   glTexCoord2f(1, 0);  glVertex3f( 1,-1, 0);
   glTexCoord2f(1, 1);  glVertex3f( 1, 1, 0);
   glTexCoord2f(0, 1);  glVertex3f(-1, 1, 0);
   glEnd();
   glPopMatrix();

   glDisable(GL_TEXTURE_2D);
   glDepthMask(GL_TRUE);
   glDisable(GL_BLEND);
   glEnable(GL_CULL_FACE);
end;

procedure TSysteme.Physique(Particule : TPParticule);
begin
   with Particule^ do
   begin
      V.x := V.x + A.x;
      V.y := V.y + A.y;
      V.z := V.z + A.z;
      P.x := P.x + V.x;
      P.y := P.y + V.y;
      P.z := P.z + V.z;
      Life := Life-1;
   end;
end;


procedure TSysteme.Actualise(var liste : TPParticule);
var temp : TPParticule; i : integer;
begin
   if liste <> NIL then
   begin
      if (liste^.Life <= 0) then
      begin
         temp := liste;
         liste := liste^.Next;
         Dispose(temp);
         Actualise(liste);
      end else
      begin
         Physique(liste);
         liste^.Life := liste^.Life - 1;
         Affiche(liste);
         Actualise(liste^.next);
      end;
   end;
end;

procedure TSysteme.Erase(var liste : TPParticule);
var temp : TPParticule;
begin

end;

constructor TSysteme.create();
begin
   new(ListeParticule);
   ListeParticule := NIL;
end;

{*******************************************************************************
 *
 *                                  PLUIE
 *
 *******************************************************************************}

constructor TPluie.create(const P : TVecteur);
var i : integer;
begin
   new(ListeParticule);
   ListeParticule := NIL;

   for i := 1 to NB_PART_PLUIE do
      AjoutUneParticule(RandomIntervale(1)/500,   RandomIntervale(1)/500,   -random,
                        -random/50,   -random/50,   -random/50,
                        P.x+RandomIntervale(30),P.y+RandomIntervale(30),30,
                        random(100), SIMPLE, ListeParticule);
end;

procedure TPluie.Actualise(const P : TVecteur; var liste : TPParticule);
var temp : TPParticule;
begin
   if liste <> NIL then
   begin
      if (liste^.Life <= 0) then
      begin
         temp := liste;
         liste := liste^.Next;
         Dispose(temp);

         AjoutUneParticule(RandomIntervale(1)/500,   RandomIntervale(1)/500,   -random,
                           -random/50,   -random/50,   -random/50,
                           P.x+RandomIntervale(30),P.y+RandomIntervale(30),30,
                           random(100), SIMPLE, ListeParticule);

         Actualise(P, liste);
      end else
      begin
         Physique(liste);
         liste^.Life := liste^.Life - 1;
         Affiche(liste);
         Actualise(P, liste^.next);
      end;
   end;
end;



procedure Fumee();
var i : byte;
begin
   {for i := 1 to 10 do
    begin
    glpushmatrix();
    gltranslated(0,0,5);
    glcallList(TabFumee.elt[i]);
    glpopMatrix();
    end; }
end;

end.
