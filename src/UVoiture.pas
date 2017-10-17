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
unit UVoiture;

interface

uses UMath,
     math,
     Opengl,
     UTypege,
     Ufrustum,
     UCaractere,
     Sysutils,
     UTextures,
     URepere;

var
  FeuArriere: Gluint;

procedure ChargementFeuArriere();

{*******************************************************************************}
Type TVoiture = class(TObject)
public
   Freine : boolean;
   Theta        : real;                  // Angle du volant pour faire tourner les 2 roues de devant
   Position     : Tvecteur;              // Position de la carcasse (X,Y,Z)
   OldPosition  : Tvecteur;              // Ancienne position de la carcasse
   Vitesse      : real;                  // vitesse
   Param        : TParamVoiture;         // Parametres (Raideurs des ressorts ... )
   Tangage      : real;                  // Tangage de la voiture
   OldTangage  : real;
   Roulis       : real;                  // Roulis
   Direction    : real;                  // Mvt horizontale de la voiture
   RoueAG    : real;            // Altitude roue avant Gauche
   RoueDG  : real;            // Altitude roue arriere Gauche
   RoueAD    : real;            // Altitude roue avant
   RoueDD  : real;            // Altitude roue arriere

   OldRoulis   : real;
   OldRoueAG    : real; // Ancienne altitude de la roue avant Gauche
   OldRoueDG  : real; // Ancienne altitude de la roue arriere Gauche
   OldRoueAD    : real; // Ancienne altitude de la roue avant Droite
   OldRoueDD  : real; // Ancienne altitude de la roue arriere Droite
   id              : byte; // Numero d'indetification
   RoueRot         : real; // Rotation de la roue


   constructor Create(x,y : real; ident : integer);
   procedure Actualise();
   procedure ActualiseDynamique();
   procedure Affiche();
   function  ReactionSolRoueAD() : real;
   function  ReactionSolRoueAG() : real;
   function  ReactionSolRoueDG() : real;
   function  ReactionSolRoueDD() : real;
end;

var CosDirection,SinDirection : real;

implementation
uses UJoueur, UAltitude, UVille;


{*******************************************************************************
 *
 *  A MODIFIER ***********
 *
 *******************************************************************************}
procedure TVoiture.Actualise();
//var nbframes : integer;
begin
   OldTheta := Theta;
   if Vitesse = 0 then Vitesse := VITESSE_MINIMALE;
   ActualiseDynamique();
end;

{*******************************************************************************
 *
 *   Initialisation -- creation de la voiture
 *
 *******************************************************************************}
constructor TVoiture.Create(x,y : real; ident : integer);
begin
   Position.x := x;
   Position.y := y;
   Position.z := Altitude(x,y);
   OldPosition := Position;
   id := ident;
   Param := TabRepertVoit.elt[ident+1];//tab;
   theta := 0;
   Vitesse := VITESSE_MINIMALE;
   RoueRot := 0.0;
   Freine := False;

   with Param do
   begin
      OldPosition.z := Altitude(x,y)+Rayon;
      Position.z := OldPosition.z;

      OldRoueAG   := 0;
      RoueAG      := OldRoueAG;

      OldRoueAD   := 0;
      RoueAD      := OldRoueAD;

      OldRoueDG   := 0;
      RoueDG      := OldRoueDG;

      OldRoueDD   := 0;
      RoueDD      := OldRoueDD;

      OldRoulis := 0;
      Roulis    := OldRoulis;

      OldTangage := 0;
      Tangage    := OldTangage;
   end;
end;

{*******************************************************************************
 *
 *  Affichage de la voiture (roue + carcasse)
 *
 *******************************************************************************}
procedure TVoiture.Affiche();
begin
   glPushMatrix();
   gltranslated(Position.x, Position.y, Position.z + Param.Hauteur);
   glRotated(RadToDeg(Direction), 0.0, 0.0, 1.0 );
   glrotated(RadToDeg(-Tangage),0,1,0);
   glrotated(RadToDeg(-Roulis),1,0,0);

   {Carcasse}
   glCallList(TabRepertVoit.elt[id].GLCarcasse.liste);

   {Roue avant gauche}
   glpushMatrix();
   gltranslated(Param.Avant, Param.Gauche, RoueAG - Param.Hauteur);
   glRotated(RadToDeg(theta), 0.0, 0.0, 1.0 );
   glrotated(RoueRot,0,1,0);
   glrotated(180,0,0,1);
   glCallList(TabRepertVoit.elt[id].GLRoue.liste);
   glPopMatrix();

   {Roue arriere gauche}
   glpushMatrix();
   gltranslated(-Param.Arriere, Param.Gauche, RoueDG - Param.Hauteur);
   glrotated(RoueRot,0,1,0);
   glrotated(180,0,0,1);
   glCallList(TabRepertVoit.elt[id].GLRoue.liste);
   glPopMatrix();

   {Roue avant droite}
   glpushMatrix();
   gltranslated(Param.Avant, -Param.Gauche, RoueAD - Param.Hauteur);
   glRotated(RadToDeg(theta), 0.0, 0.0, 1.0 );
   glrotated(RoueRot,0,1,0);
   glCallList(TabRepertVoit.elt[id].GLRoue.liste);
   glPopMatrix();

   {Roue arriere droite}
   glpushMatrix();
   gltranslated(-Param.Arriere, -Param.Gauche, RoueDD - Param.Hauteur);
   glrotated(RoueRot,0,1,0);
   glCallList(TabRepertVoit.elt[id].GLRoue.liste);
   glPopMatrix();

   if Params.LumieresActivees then
   begin
      if Params.glLumiere then glDisable(GL_LIGHTING);
      {Feu arriere gauche}
      glpushMatrix();
      gltranslated(-Param.Arriere-2, Param.Gauche-0.5, RoueDG+1);
      if Params.Nuit then glCallList(FeuArriere);
      if Freine then glCallList(FeuArriere);
      glPopMatrix();

      {Feu arriere droite}
      glpushMatrix();
      gltranslated(-Param.Arriere-2, -Param.Gauche+0.5, RoueDD+1);
      if Params.Nuit then glCallList(FeuArriere);
      if Freine then glCallList(FeuArriere);
      glPopMatrix();
      if Params.glLumiere then glEnable(GL_LIGHTING);
   end;

   glPopMatrix();
end;

{*******************************************************************************
 *
 *   Actualisation de la dynamique
 *
 *******************************************************************************}
procedure TVoiture.ActualiseDynamique({nbpas : integer});
var PPAS, Tang, AD, AG, DD, DG, roul,
Carcasse, NextPositionX, NextPositionY : real; i : integer;
F1,F2,F3 : real;
begin
   {pseudo-timer pour lisser les trajectoires}
   for i := 1 to 10 do
   begin
      with Param do
      begin

         RoueRot := RoueRot+(PAST*Vitesse*2)/Param.Rayon;

         {dynamique}
         F1 := (RAIDEUR*(RoueAD+RoueAG+RoueDG+RoueAD))/Masse_Voit;
         F2 := (Avant*Avant*RAIDEUR*(RoueAD+RoueAG-RoueDG-RoueAD))/InertieTangage ;
         F3 := (Gauche*Gauche*RAIDEUR*(RoueAD-RoueAG-RoueDG+RoueAD))/InertieRoulis;

         CosDirection := cos(Direction);
         SinDirection := sin(Direction);

         PPAS := PAST*PAST;


         Carcasse  := 2*(1-FROT*PAST)*Position.z-(1-2*FROT*PAST)*
            OldPosition.z+PPAS*(-2*GRAVITE+F1);


         AD := 2*(1-FROT*PAST)*RoueAD-(1-2*FROT*PAST)*OldRoueAD+PPAS
            *((ReactionSolRoueAD-Raideur*RoueAD)/MASSE_ROUE-F1-F2-F3);

         AG := 2*(1-FROT*PAST)*RoueAG-(1-2*FROT*PAST)*OldRoueAG+PPAS
            *((ReactionSolRoueAG-Raideur*RoueAG)/MASSE_ROUE-F1-F2+F3);

         DG := 2*(1-FROT*PAST)*RoueDG-(1-2*FROT*PAST)*OldRoueDG+PPAS
            *((ReactionSolRoueDG-Raideur*RoueDG)/MASSE_ROUE-F1+F2+F3);


         DD := 2*(1-FROT*PAST)*RoueDD-(1-2*FROT*PAST)*OldRoueDD+PPAS
            *((ReactionSolRoueDD-Raideur*RoueDD)/MASSE_ROUE-F1+F2-F3);

         Tang := 2*(1-FROT*PAST)*Tangage-(1-2*FROT*PAST)*OldTangage
            + (PPAS*F2)/Avant;

         Roul := 2*(1-FROT*PAST)*Roulis-(1-2*FROT*PAST)*OldRoulis
            + (PPAS*F3)/GAuche;

         Direction := Direction+Vitesse/15000*theta;

         NextPositionX := 2*(1-PAST)*Position.x - (1-2*PAST)*OldPosition.x+PPAS*(Vitesse*500*cos(Direction))/(2*MASSE_ROUE+MASSE_VOIT);
         NextPositionY := 2*(1-PAST)*Position.y - (1-2*PAST)*OldPosition.y+PPAS*(Vitesse*500*sin(Direction))/(2*MASSE_ROUE+MASSE_VOIT);

         {Position modulo taille carte}
         if NextPositionX >= TAILLE_MAP_X then
         begin
            NextPositionX := NextPositionX - TAILLE_MAP_X;
            Position.x := Position.x - TAILLE_MAP_X;
         end;
         if NextPositionY >= TAILLE_MAP_Y then
         begin
            NextPositionY := NextPositionY - TAILLE_MAP_Y;
            Position.y := Position.y - TAILLE_MAP_Y;
         end;
         if NextPositionX <= 0 then
         begin
            NextPositionX := NextPositionX + TAILLE_MAP_X;
            Position.x := Position.x + TAILLE_MAP_X;
         end;
         if NextPositionY <= 0 then
         begin
            NextPositionY := NextPositionY + TAILLE_MAP_Y;
            Position.y := Position.y + TAILLE_MAP_Y;
         end;

         {}
         OldRoueAD   := RoueAD;   RoueAD   := AD;
         OldRoueAG   := RoueAG;   RoueAG   := AG;
         OldRoueDD   := RoueDD;   RoueDD   := DD;
         OldRoueDG   := RoueDG;   RoueDG   := DG;

         OldTangage := Tangage; Tangage := Tang;
         OldRoulis  := Roulis;  Roulis  := Roul;

         OldPosition := Position;
         Position.x := NextPositionX;
         Position.y := NextPositionY;
         Position.z := Carcasse;
      end;
   end;
end;

{*******************************************************************************
 *
 *  Retourne la reaction du sol sur la roue avant
 *
 *******************************************************************************}
function TVoiture.ReactionSolRoueAD() : real;
var resultat : real;
begin
   with Param do
   begin
      resultat := Altitude(Position.x + Param.Avant*CosDirection + Param.Gauche*sinDirection,
                           Position.y + Param.Avant*sinDirection - Param.Gauche*CosDirection) -
         (RoueAD + Position.z + Avant * Tangage + Gauche*Roulis - Rayon);

      {Debug: dessine l'endroit ou est la roue}
      {dessinerRepere(Position.x + Param.Avant*CosDirection + Param.Gauche*sinDirection,
                     Position.y + Param.Avant*sinDirection - Param.Gauche*CosDirection,
                     Position.z);}

      if (resultat)>0 then result := resultat*REAC_SOL
      else result := 0;
   end;
end;


function TVoiture.ReactionSolRoueAG() : real;
var resultat : real;
begin
   with Param do
   begin
      resultat := Altitude(Position.x + Param.Avant*CosDirection - Param.Gauche*sinDirection,
                           Position.y + Param.Avant*sinDirection + Param.Gauche*CosDirection) -
         (RoueAG + Position.z + Avant * Tangage - Gauche*Roulis - Rayon);

      {Debug: dessine l'endroit ou est la roue}
      {dessinerRepere(Position.x + Param.Avant*CosDirection - Param.Gauche*sinDirection,
                     Position.y + Param.Avant*sinDirection + Param.Gauche*CosDirection,
                     Position.z);}

      if (resultat)>0 then result := resultat*REAC_SOL
      else result := 0;
   end;
end;

{*******************************************************************************
 *
 *  Retourne la reaction du sol sur la roue arriere
 *
 *******************************************************************************}
function TVoiture.ReactionSolRoueDG() : real;
var resultat : real;
begin
   with Param do
   begin
      resultat := Altitude(Position.x - Param.Arriere*CosDirection - Param.Gauche*sinDirection,
                           Position.y - Param.Arriere*sinDirection + Param.Gauche*CosDirection) -
         (RoueDG + Position.z - Arriere * Tangage - Gauche*Roulis - Rayon);

      {Debug: dessine l'endroit ou est la roue}
      {dessinerRepere(Position.x - Param.Arriere*CosDirection - Param.Gauche*sinDirection,
                     Position.y - Param.Arriere*sinDirection + Param.Gauche*CosDirection,
                     Position.z);}

      if (resultat)>0 then result := resultat*REAC_SOL
      else result := 0;
   end;
end;


function TVoiture.ReactionSolRoueDD() : real;
var resultat : real;
begin
   with Param do
   begin
      resultat := Altitude(Position.x - Param.Arriere*CosDirection + Param.Gauche*sinDirection,
                           Position.y - Param.Arriere*sinDirection - Param.Gauche*CosDirection) -
         (RoueDD + Position.z - Arriere * Tangage + Gauche*Roulis - Rayon);

      {Debug: dessine l'endroit ou est la roue}
      {dessinerRepere(Position.x - Param.Arriere*CosDirection + Param.Gauche*sinDirection,
                     Position.y - Param.Arriere*sinDirection - Param.Gauche*CosDirection,
                     Position.z);}

      if (resultat)>0 then result := resultat*REAC_SOL
      else result := 0;
   end;
end;

procedure ChargementFeuArriere();
var TabTexture : TTabTexture;
begin
   TabTexture.long := 0;
   TextureBlending('data\textures\particule.bmp',TabTexture,0,0,0,8,1,0,0);
   if (glIsList(FeuArriere)=GL_TRUE) then glDeleteLists(FeuArriere,1);
   FeuArriere := glGenLists(1);
   glNewList(FeuArriere,GL_COMPILE);
   glpushMatrix();
   glscalef(0.5,0.5,0.5);
   glrotated(90,0,1,0);
   glcallList(TabTexture.elt[0]);
   glPopMatrix();
   GlEndList();
end;

end.
