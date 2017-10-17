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
unit UJoueur;

interface

uses UVoiture,
     UTypege,
     ULancement,
     sysutils,
     USons,
     OpenGL,
     UVille,
     UAltitude,
     UCaractere,
     URepere,
     UTransparence,
     UTextures,
     UMath,
     math;

{***************************  TJOUEUR  *****************************************
 * procedure InitPosition(x,y : real; ident : integer; tab : TParam);
 *             Initialise la position du joueur :
 *             - (x,y) : sa position en X et Y.
 *             - ident : un numero d'indentification d'affichage de la voiture
 *             - tab   : les parametres de la voitures (raideur des ressorts,
 vitesse, position des roues ...)
 *
 * function Collision() : boolean;
 *             Retourne si une voiture est rentree dans un bloc d'immeuble.
 *
 * procedure Initialisation();
 *              Met TETE ET QUEUE a NIL .
 *
 ******************************************************************************}
Type TJoueur = class(TVoiture)
public
   Volant,TableauDeBord : Gluint;
   MarcheArriere : boolean;
   procedure   Actualise();  // main
   constructor Create(x,y : real; ident : integer);
   procedure AfficheTableauDeBord();
   procedure CollisionSurImmeubles();
   procedure CollisionSurVoitures();
   procedure afficheVoiture();
private
   procedure CreerTableauDeBord();
   procedure ActualiseCamera();
end;

var Joueur : TJoueur;

implementation
uses Ucirculation;

{*******************************************************************************}
constructor TJoueur.create(x,y : real; ident : integer);
begin
   inherited create(x,y,ident);
   MarcheArriere := FALSE;
   ColliImmeuble := FALSE;
   CreerTableauDeBord();
   Direction := 0;
   ActualiseCamera();
end;

{*******************************************************************************}
procedure TJoueur.CreerTableauDeBord();
begin
   {Tableau de bord}
   if (glIsList(TableauDeBord)=GL_TRUE) then glDeleteLists(TableauDeBord,1);
   TableauDeBord := glGenLists(1);
   glNewList(TableauDeBord,GL_COMPILE);

   glpushMatrix();
   OrthoMode(0,Params.Height,Params.Width,0);
   glcullface(GL_BACK);
   glEnable(GL_TEXTURE_2D);
   gltranslated(params.Width/2,Params.Height*(128/768),0);
   glscaled(params.Width/2,Params.Height*(128/768),0);
   glcolor3f(1,1,1);
   glBindTexture(GL_TEXTURE_2D, TableauDeBord_0);
   glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0); glVertex2f(-1.1, -1.1);
   glTexCoord2f(1.0, 0.0); glVertex2f( 1.1, -1.1);
   glTexCoord2f(1.0, 1.0); glVertex2f( 1.1,  1.1);
   glTexCoord2f(0.0, 1.0); glVertex2f(-1.1,  1.1);
   glEnd();
   glDisable(GL_TEXTURE_2D);
   glcullface(GL_FRONT);
   PerspectiveMode;
   glpopMatrix();

   glEndList();

   {Volant}
   if (glIsList(Volant)=GL_TRUE) then glDeleteLists(Volant,1);
   Volant := glGenLists(1);
   glNewList(Volant,GL_COMPILE);

   glpushMatrix();
   OrthoMode(0,Params.Height,Params.Width,0);
   glcullface(GL_BACK);
   gltranslated(225*Params.Width/1024,30*Params.Height/768,0);
   glscaled(250*Params.Width/1024,250*Params.Height/768,0);
   glRotated(RadToDeg(theta), 0.0, 0.0, 1.0 );
   glcallList(Volant_0);
   glcullface(GL_FRONT);
   PerspectiveMode;
   glpopMatrix();

   glEndList();
end;

{*******************************************************************************}
procedure TJoueur.AfficheTableauDeBord();
begin
   glCallList(TableauDeBord);
   glpushMatrix();
   OrthoMode(0,Params.Height,Params.Width,0);
   glcullface(GL_BACK);
   gltranslated(225*Params.Width/1024,30*Params.Height/768,0);
   glscaled(250*Params.Width/1024,250*Params.Height/768,0);
   glRotated(RadToDeg(theta), 0.0, 0.0, 1.0 );
   glcallList(Volant_0);
   glcullface(GL_FRONT);
   PerspectiveMode;
   glpopMatrix();

   GLDisable(GL_DEPTH_TEST);
   GLTexte(250*Params.Width/1024,640*Params.Height/768,1,0,0,Inttostr(Trunc(Vitesse/2)));
   if MarcheArriere then GLTexte(200*Params.Width/1024,640*Params.Height/768,1,0,0,'R');
   if Freine then GLTexte(200*Params.Width/1024 + Params.Police,640*Params.Height/768,1,0,0,'B');
   GLEnable(GL_DEPTH_TEST);
end;

{*******************************************************************************}
procedure TJoueur.Actualise();
//var nbframes : integer;
begin
   //nbframes:= Round(FPSCount * 1000/FPS_INTERVAL);
   {Correcteur de trajectoire}
   if Theta > 0.02 then Theta := Theta - 0.01
   else if Theta < -0.02 then Theta := Theta + 0.01
   else Theta := 0;

   CollisionSurVoitures();
   CollisionSurImmeubles();
   ActualiseDynamique({max(round(1 / (Param.PAST*nbframes)),1)});
   ActualiseCamera();

   FaitDuBruit();
end;


{*******************************************************************************
 *
 *  Actualisation de la camera lorsque le joueur change de position
 *
 *******************************************************************************}
procedure TJoueur.ActualiseCamera();
begin
   case Camera.id of
      0 : begin
             Camera.Position.x := Position.x - (cos(thetaCamera)*vitesse*cos(Direction)-sin(thetaCamera)*vitesse*sin(Direction))/vitesse*DistanceCamera ;
             Camera.Position.y := Position.y - (sin(thetaCamera)*vitesse*cos(Direction)+cos(thetaCamera)*vitesse*sin(Direction))/vitesse*DistanceCamera ;
             Camera.Position.z := Position.z+7;

             Camera.Target.x := Position.x + (cos(thetaCamera)*vitesse*cos(Direction)-sin(thetaCamera)*vitesse*sin(Direction))/vitesse*100;
             Camera.Target.y := Position.y + (sin(thetaCamera)*vitesse*cos(Direction)+cos(thetaCamera)*vitesse*sin(Direction))/vitesse*100;
             Camera.Target.z := Position.z+7;

             Camera.Orientation.x := 0;
             Camera.Orientation.y := 0;
             Camera.Orientation.z := 1;

          end;
      1 : begin
             Camera.Position := Position;
             Camera.Position.z := Position.z+Param.Conducteur;

             Camera.Target.x := Camera.Position.x + cos(Direction);
             Camera.Target.y := Camera.Position.y + sin(Direction);
             Camera.Target.z := Camera.Position.z;

             Camera.Orientation.x := 0;
             Camera.Orientation.y := 0;
             Camera.Orientation.z := 1;
          end;
      2 : begin
             Camera.Position := Position;
             Camera.Position.z := Position.z+Param.Conducteur;

             Camera.Target.x := Camera.Position.x + cos(Direction);
             Camera.Target.y := Camera.Position.y + sin(Direction);
             Camera.Target.z := Camera.Position.z;

             Camera.Orientation.x := 0;
             Camera.Orientation.y := 0;
             Camera.Orientation.z := 1;
          end;
      3 : begin
             Camera.Position := Position;
             Camera.Position.z := ALTITUDE_MAX_CAMERA;

             Camera.Target := Position;
             Camera.Target.z := ALTITUDE_MAX_CAMERA-1;

             Camera.Orientation.x := 0;
             Camera.Orientation.y := 1;
             Camera.Orientation.z := 0;
          end;
   end;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure TJoueur.afficheVoiture();
begin
   {On réénitialise la matrice modélisation-visualisation}
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity;
   if (Camera.id = 1) OR (Camera.id = 2) then
   begin
      glrotated(RadToDeg(-Joueur.Tangage),1,0,0);
      glrotated(RadToDeg(-Joueur.Roulis), 0,0,1);
   end;
   GluLookAt(Camera.Position.x,    Camera.Position.y,     Camera.Position.z,
             Camera.Target.x,      Camera.Target.y,       Camera.Target.z,
             Camera.Orientation.x, Camera.Orientation.y,  Camera.Orientation.z);

   if (Camera.id = 1) then
   begin
      if Params.fog then glDisable(GL_FOG);
      if Params.glLumiere then glDisable(GL_LIGHTING);
      Joueur.AfficheTableauDeBord();
      if Params.glLumiere then glEnable(GL_LIGHTING);
      if Params.fog then glEnable(GL_FOG);
   end;

   if (Camera.id <> 1) AND (Camera.id <> 2) then Affiche();
   Freine := false;

   if Params.fog then
   begin
      if (Camera.position.z < -19) then glFogfv(GL_FOG_COLOR, @FogCouleur_2)
      else glFogfv( GL_FOG_COLOR, @FogCouleur_1);
   end;
end;

procedure TJoueur.CollisionSurVoitures();
var couple : Tcouple; Voit : TPGoodies;
begin
   couple := QuellePartition(Position.x,Position.y);
   ColliVoiture := FALSE;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;
   //*****

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;

   Voit := MaVille[couple.x,couple.y].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].Tete;
   while (Voit <> NIL) do
   begin
      if Distance(Joueur.Position,Voit^.Position) <= Param.Avant
      then ColliVoiture := TRUE;

      if ColliVoiture AND (not OldColliVoiture) then
      begin
         Voit^.Vitesse := VITESSE_MINIMALE;
      end;
      voit := Voit^.next;
   end;
end;

procedure TJoueur.CollisionSurImmeubles();
var resultat_0,resultat_1,
resultat_2,resultat_3 : TTriplet;
P : TVecteur2D;

begin
   ColliImmeuble := FALSE;

   P.x := Position.x + Param.Avant*CosDirection + Param.Gauche*sinDirection;
   P.y := Position.y + Param.Avant*sinDirection - Param.Gauche*CosDirection;
   ModuloCarte(P);
   resultat_0 := QuelleRoute(P.x,P.y);


   P.x := Position.x + Param.Avant*CosDirection - Param.Gauche*sinDirection;
   P.y := Position.y + Param.Avant*sinDirection + Param.Gauche*CosDirection;
   ModuloCarte(P);
   resultat_1 := QuelleRoute(P.x,P.y);

   P.x := Position.x - Param.Arriere*CosDirection - Param.Gauche*sinDirection;
   P.y := Position.y - Param.Arriere*sinDirection + Param.Gauche*CosDirection;
   ModuloCarte(P);
   resultat_2 := QuelleRoute(P.x,P.y);

   P.x := Position.x - Param.Arriere*CosDirection + Param.Gauche*sinDirection;
   P.y := Position.y - Param.Arriere*sinDirection - Param.Gauche*CosDirection ;
   ModuloCarte(P);
   resultat_3 := QuelleRoute(P.x,P.y);

   if ((resultat_0.z = MAISONS) AND (MaVille[Resultat_0.x,Resultat_0.y].TypeDuBloc = EST_UN_BLOC) AND (Resultat_0.y <> RANGEE_DU_FLEUVE))
      OR ((resultat_1.z = MAISONS) AND (MaVille[Resultat_1.x,Resultat_1.y].TypeDuBloc = EST_UN_BLOC) AND (Resultat_1.y <> RANGEE_DU_FLEUVE))
      OR ((resultat_2.z = MAISONS) AND (MaVille[Resultat_2.x,Resultat_2.y].TypeDuBloc = EST_UN_BLOC) AND (Resultat_2.y <> RANGEE_DU_FLEUVE))
      OR ((resultat_3.z = MAISONS) AND (MaVille[Resultat_3.x,Resultat_3.y].TypeDuBloc = EST_UN_BLOC) AND (Resultat_3.y <> RANGEE_DU_FLEUVE))
   then ColliImmeuble := TRUE;
   if ColliImmeuble AND (not OldColliImmeuble) then
   begin
      Vitesse := VITESSE_MINIMALE;
      //Position := OldPosition;
   end;
   //OldColliImmeuble := ColliImmeuble;
end;

end.
