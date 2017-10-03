{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : https://github.com/Lecrapouille/Ecstasy
 * Date    : 02 Juin 2003
 * Changes : 03 Octobre 2017
 * License: GPL-3.0
 * Description : Creation de la ville, des routes, des feux tricolores
 * Remarque    : Voir le rapport soutenance 4 section 'Ville' pour comprendre
 *               la structure de la ville.
 *
 *******************************************************************************}

unit UVille;

interface

uses UTypege,
     UMath,
     Sysutils,
     UFrustum,
     UCirculation,
     Math,
     UTerrain,
     Opengl;

procedure CreationVille();
Procedure AfficheVille();
procedure InitParametreMaison();
procedure ActualiseLesFeux();
Procedure DestroyVille();

{*******************************************************************************
 *
 * Information sur les maisons :
 *     - Liste d'affichage OpenGL (pour le dessin)
 *     - Une des deux tailles de la maison  //****** A ARRANGER
 *
 *******************************************************************************}
Type TInfo = record
   Liste_Affichage : gluint;
   taille : integer;
end;

{*******************************************************************************
 *
 * Tableau contenant la duree des feux tricolores :
 *    0 : duree du feu vert,
 *    1 : duree du feu orange,
 *    2 : duree du feu rouge.
 *
 *******************************************************************************}
TDureeFeu = array[0..2] of integer;

{*******************************************************************************
 *
 *   Un feu tricolore est defini par :
 *        - Son etat :
 *                    0 : vert,
 *                    1 : orange,
 *                    2 : rouge.
 *        - La Duree du temps ecoule.
 *
 *******************************************************************************}
TFeuRouge = record
   Etat : byte;
   TempsEcoule : integer;
end;

{*******************************************************************************
 *
 *  Textures transparente pour simuler l'eclairage des feux tricolores.
 *
 *******************************************************************************}
TTabPart = array[0..11] of Gluint;

{*******************************************************************************
 *
 *  Chaque carrefour a 4 feux tricolores (feu rouge).
 *
 *******************************************************************************}
TTabFeu = array[0..3] of TFeuRouge;

{*******************************************************************************
 *
 * tableau qui contient les positions des 4 sommets d'une route //****** PAS TRES UTILE A CHANGER
 *
 *******************************************************************************}
TTabPos = array [0..3] of TVecteur;

{*******************************************************************************
 *
 *  Une route est defini par :
 *        - Son tableau qui contient les positions des 4 sommets // ****** PAS TRES UTILE A CHANGER
 *        - La pente de la route.
 *        - Son numero d'identification :
 *                                       0 : route N°0,
 *                                       1 : route N°1,
 *                                       2 : carrefour.
 *        - La procedure qui l'a creee
 *
 *******************************************************************************}
TRoute = class(Tobject)
public
   TabPos : TTabPos;
   Pente : real;
private
   constructor Create(A,B,C,D : Tvecteur; ident : integer);
end;

{*******************************************************************************
 *
 *  Une maison est defini par :
 *      - Sa taille (X et Y),
 *      - Sa position (X,Y,Z),
 *      - Sa liste d'affichage OpenGL pour le dessin,
 *      - Sa procedure qui l'a cree,
 *      - Sa procedure qui appelle la liste d'affichage
 *
 *******************************************************************************}
TMaison = class(Tobject)
private
   TailleX,TailleY : integer;
   Position : TVecteur;
   Liste_Affichage : gluint;
   constructor Create(posi : TVecteur; id : integer);
   procedure Affiche(id : byte);
end;

{*******************************************************************************
 *
 *  Un bloc est un ensemble de quatre rangees de maisons (en forme de rectangle)
 *  Remarque : voir le rapport de soutenance 4 section 'Ville' pour plus d'infos.
 *
 *******************************************************************************}
TBloc = class(Tobject)
public
   Route0,Route1,Carrefour : TRoute;
   TabCirculation : TTabCirculation;
   TimerFeux : integer;
   EtatFeux : integer;
   TypeDuBloc : byte;
   Terrain : array[0..NB_SUB,0..NB_SUB] of real;
private
   Decal_Texture_Eau : real; // pour l'eau
   Maison_Liste_Affichage,
   Route_Liste_Affichage : gluint;
   Haut : array [0..NB_MAISON_MAX_X] of TMaison;
   Bas  : array [0..NB_MAISON_MAX_X] of TMaison;
   Gauche : array [0..NB_MAISON_MAX_Y] of TMaison;
   Droit  : array [0..NB_MAISON_MAX_Y] of TMaison;
   LongHaut,LongBas,LongGauche,LongDroit : integer;
   procedure CreateRoute(A0,B0,C0,D0 : TVecteur; n0 : integer;
                         A1,B1,C1,D1 : TVecteur; n1 : integer;
                         A2,B2,C2,D2 : TVecteur; n2 : integer;
                         AffPont : boolean);
   constructor Creation(P : TVecteur; nh,nd,nb,ng,a,b,ran : integer);
   procedure Affiche(a,b : integer);
   procedure ActualiseFeu(i,j,id : integer);
end;

{*******************************************************************************
 *
 *  Une ville est une matrice de blocs et de routes.
 *
 *******************************************************************************}
TVille = array [0..NB_BLOC_MAX_X,0..NB_BLOC_MAX_Y] of TBloc;

var
   MaVille : TVille;
   TabPart : TTabPart;
   ParamMaison : array [0..NB_TYPE_MAISON] of Tinfo;
   DureeFeu : TDureeFeu = (0,0,0);

implementation
uses UJoueur, ULancement, UAltitude;

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external 'opengl32.dll';

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure InitParametreMaison();
var i : integer;
begin
   for i := 0 to NB_TYPE_MAISON do
   begin
      ParamMaison[i].taille := 50;
      ParamMaison[i].Liste_Affichage := TabImeublesObjt[i].Liste;
   end;
end;

{************************** TMAISON *********************************************}

constructor TMaison.Create(posi : TVecteur; id : integer);
begin
   TailleX := ParamMaison[id].taille;
   TailleY := ParamMaison[id].taille;
   Position := posi;
   Liste_Affichage := ParamMaison[id].Liste_Affichage;
end;

procedure TMaison.Affiche(id : byte);
begin
   glpushMatrix();
   gltranslated(Position.x,Position.y,Position.z);
   glrotate(-90*id,0,0,1);
   //glscale(ECHELLE_IMMEUBLE,ECHELLE_IMMEUBLE,ECHELLE_IMMEUBLE);
   glCallList(Liste_Affichage);
   glPopMatrix();
end;

{************************** TBLOC *********************************************}
procedure TBloc.CreateRoute(A0,B0,C0,D0 : TVecteur; n0 : integer;
                            A1,B1,C1,D1 : TVecteur; n1 : integer;
                            A2,B2,C2,D2 : TVecteur; n2 : integer;
                            AffPont : boolean);
var dx,dy : real;
begin
   if (glIsList(Route_Liste_Affichage)) then glDeleteLists(Route_Liste_Affichage,1);
   Route_Liste_Affichage := glGenLists(1);
   glNewList(Route_Liste_Affichage,GL_COMPILE);
   Route0 := TRoute.Create(A0,B0,C0,D0,n0);
   Route1 := TRoute.Create(A1,B1,C1,D1,n1);
   Carrefour := TRoute.Create(A2,B2,C2,D2,n2);




   dx := (LONG_ROUTE_X+ESPACE_CAREFOUR)/2;
   dy := (LONG_ROUTE_Y+ESPACE_CAREFOUR)/2;

   //** Anass
   //Troioire0 := TRoute.Create(...
   // ...
   //Troioire4 := TRoute.Create(...

   {Feux tricolores}
   glpushmatrix();
   gltranslated(Carrefour.TabPos[3].x,Carrefour.TabPos[3].y,Carrefour.TabPos[3].z);
   glscale(1.5,1.5,1.5);
   glcalllist(feurouge_liste.liste);
   glpopmatrix();

   glpushmatrix();
   gltranslated(Carrefour.TabPos[2].x,Carrefour.TabPos[2].y,Carrefour.TabPos[2].z);
   glrotated(90,0,0,1);
   glscale(1.5,1.5,1.5);
   glcalllist(feurouge_liste.liste);
   glpopmatrix();

   glpushmatrix();
   gltranslated(Carrefour.TabPos[1].x,Carrefour.TabPos[1].y,Carrefour.TabPos[1].z);
   glrotated(180,0,0,1);
   glscale(1.5,1.5,1.5);
   glcalllist(feurouge_liste.liste);
   glpopmatrix();

   glpushmatrix();
   gltranslated(Carrefour.TabPos[0].x,Carrefour.TabPos[0].y,Carrefour.TabPos[0].z);
   glrotated(-90,0,0,1);
   glscale(1.5,1.5,1.5);
   glcalllist(feurouge_liste.liste);
   glpopmatrix();

   if (AffPont) then
   begin
      glPushMatrix();
      gltranslated(Carrefour.TabPos[1].x+ESPACE_CAREFOUR/2,Carrefour.TabPos[1].y+LONG_ROUTE_Y/2,-17.5);
      glrotated(90,0,0,1);
      glscale(LONG_ROUTE_Y/82,ESPACE_CAREFOUR/17,2);
      glcallList(pont_liste.liste);
      glpopMatrix();

      //texture sol boueux
      GlPushMatrix();
      Gltranslated(Carrefour.TabPos[2].x+LONG_ROUTE_X/2,Carrefour.TabPos[2].y+LONG_ROUTE_Y/2,-30);
      GlEnable(GL_TEXTURE_2D);
      Glcolor3f(1,1,1);
      GlBindTexture(GL_TEXTURE_2D, Text_sol);
      GlBegin(gl_triangles);
      glTexCoord2f(10.0, 10.0); glVertex3f(-dx,-dy,1);
      glTexCoord2f(10.0, 0.0); glVertex3f(-dx,dy,1);
      glTexCoord2f(0.0, 0.0); glVertex3f(dx,dy,1);

      glTexCoord2f(0.0, 0.0); glVertex3f(dx,dy,1);
      glTexCoord2f(0.0, 10.0); glVertex3f(dx,-dy,1);
      glTexCoord2f(10.0, 10.0); glVertex3f(-dx,-dy,1);
      GlEnd();
      glDisable(GL_TEXTURE_2D);
      GlPopMatrix();

      //berges numero 1
      GlPushMatrix();
      Gltranslated(Carrefour.TabPos[2].x+LONG_ROUTE_X/2,Carrefour.TabPos[2].y+LONG_ROUTE_Y,-15);
      GlEnable(GL_TEXTURE_2D);
      Glcolor3f(1,1,1);
      GlBindTexture(GL_TEXTURE_2D, Text_berges);
      GlBegin(gl_triangles);
      glTexCoord2f(10.0, 1.0); glVertex3f(-dx,0,-15);
      glTexCoord2f(10.0, 0.0);  glVertex3f(-dx,0,15);
      glTexCoord2f(0.0, 0.0);   glVertex3f(dx,0,15);

      glTexCoord2f(0.0, 0.0);   glVertex3f(dx,0,15);
      glTexCoord2f(0.0, 1.0);  glVertex3f(dx,0,-15);
      glTexCoord2f(10.0, 1.0); glVertex3f(-dx,0,-15);
      GlEnd();
      glDisable(GL_TEXTURE_2D);
      GlPopMatrix();

      //berges numero 2
      GlPushMatrix();
      Gltranslated(Carrefour.TabPos[2].x+LONG_ROUTE_X/2,Carrefour.TabPos[2].y,-15);
      Glrotated(180,1,0,0);
      GlEnable(GL_TEXTURE_2D);
      Glcolor3f(1,1,1);
      GlBindTexture(GL_TEXTURE_2D, Text_berges);
      GlBegin(gl_triangles);
      glTexCoord2f(10.0, 1.0); glVertex3f(-dx,0,-15);
      glTexCoord2f(10.0, 0.0);  glVertex3f(-dx,0,15);
      glTexCoord2f(0.0, 0.0);   glVertex3f(dx,0,15);

      glTexCoord2f(0.0, 0.0);   glVertex3f(dx,0,15);
      glTexCoord2f(0.0, 1.0);  glVertex3f(dx,0,-15);
      glTexCoord2f(10.0, 1.0); glVertex3f(-dx,0,-15);
      GlEnd();
      glDisable(GL_TEXTURE_2D);
      GlPopMatrix();

   end;
   glEndList();
end;

{***********  CONSTRUCTION DES BLOCS DE VILLE **********************************
 * nh <=> Nombre de batiment du cote haut d'un bloc
 * nb <=> Nombre de batiment du cote bas d'un bloc
 * nd <=> Nombre de batiment du cote droit d'un bloc
 * ng <=> Nombre de batiment du cote gauche d'un bloc
 * le repere est :
 *
 *                  (Oz) (couleur bleu)
 *                   \
 *                    \
 *                     \ O      GAUCHE
 *                      \+----------------------> (Oy) (couleur vert)
 *                       |
 *                     H |             B
 *                     A |         +   A
 *                     U |             S
 *                     T |
 *                       |  DROIT
 *                       |
 *                     (Ox) (couleur rouge)
 *
 *  On rajoute des blocs de maisons dans les deux sens jusqu'a nh,nb,ng,nd
 *  Remarque : Pour afficher le repere --> glCallList(LeRepere).
 *
 *  Un bloc de la ville est consititue de la sorte :
 *
 *                   +----+--------------------+
 *                   |0  1|0    route 1       1|
 *                   |3  2|3                  2|
 *                   +----+--------------------+
 *                   |0r1 |                    |
 *                   | o  |                    |
 *                   | u  |   Le bloc de       |
 *                   | t  |     maisons        |
 *                   | e  |                    |
 *                   | 0  |                    |
 *                   |3  2|                    |
 *                   +----+--------------------+
 *
 * *****************************************************************************}
function TireUnImmeuble(taille : integer) : integer;
//var i : integer;
begin
   //i := NB_TYPE_MAISON;
   //while (i >= 0) AND (taille <= ParamMaison[0,i].taille) do i := i-1;
   //result := random(i+1)
   result := random(NB_TYPE_MAISON+1);
end;

{*******************************************************************************}
constructor TBloc.Creation(P : TVecteur; nh,nd,nb,ng,a,b,ran : integer);
var i,nume : integer; Long : integer;
pos : TVecteur;
begin
   Decal_Texture_Eau := 0;
   LongHaut := nh;
   LongBas := nb;
   LongGauche := ng;
   LongDroit := nd;

   if (glIsList(Maison_Liste_Affichage)) then glDeleteLists(Maison_Liste_Affichage,1);
   Maison_Liste_Affichage := glGenLists(1);
   glNewList(Maison_Liste_Affichage,GL_COMPILE);
   if b <> RANGEE_DU_FLEUVE then
      if ran < Params.ProportionTerrain then    // Terrain aleatoire
      begin
         NouveauTerrain(a,b);
         TypeDuBloc := EST_UN_TERRAIN;
      end else
      begin
         TypeDuBloc := EST_UN_BLOC;
         {GAUCHE-HAUT vers DROIT-HAUT}
         i := 0; Long := 0;
         Pos := P;
         while Long < LongHaut do
         begin
            if LongHaut-Long >= LONG_PLUS_GRAND_IMMEUBLE then nume := TireUnImmeuble(LONG_PLUS_GRAND_IMMEUBLE+1)
            else nume := TireUnImmeuble(LongHaut-Long);
            Pos.x := pos.x+0.5*ParamMaison[nume].taille;
            pos.y := P.y+0.5*ParamMaison[nume].taille;
            pos.z := Min(Altitude(Pos.x-0.5*ParamMaison[nume].taille,Pos.y-LONG_PLUS_GRAND_IMMEUBLE),
                         Altitude(Pos.x+0.5*ParamMaison[nume].taille,Pos.y-LONG_PLUS_GRAND_IMMEUBLE));

            Haut[i] := TMaison.Create(pos,nume);
            Haut[i].Affiche(0);
            Pos.x := pos.x+0.5*ParamMaison[nume].taille;
            Long := Long+ParamMaison[nume].taille;
            i := i+1;
         end;
         LongHaut := i-1;

         {GAUCHE-HAUT vers GAUCHE-BAS}
         Gauche[0] := Haut[0];
         Pos.x := P.x;
         Pos.y := 0.5*Gauche[0].TailleY+Gauche[0].Position.y;
         Pos.z := P.z;
         Long := Gauche[0].TailleY;
         i := 1;

         while Long < LongGauche do
         begin
            if LongGauche-Long >= LONG_PLUS_GRAND_IMMEUBLE then nume := TireUnImmeuble(LONG_PLUS_GRAND_IMMEUBLE+1)
            else nume := TireUnImmeuble(LongGauche-Long);
            Pos.y := Pos.y+0.5*ParamMaison[nume].taille;
            pos.x := P.x+0.5*ParamMaison[nume].taille;
            pos.z := Min(Altitude(Pos.x-LONG_PLUS_GRAND_IMMEUBLE,Pos.y-0.5*ParamMaison[nume].taille),
                         Altitude(Pos.x-LONG_PLUS_GRAND_IMMEUBLE,Pos.y+0.5*ParamMaison[nume].taille));

            Gauche[i] := TMaison.Create(pos,nume);
            Gauche[i].Affiche(1);
            Pos.y := pos.y+0.5*ParamMaison[nume].taille;
            Long := Long+ParamMaison[nume].taille;
            i := i+1;
         end;
         LongGauche := i-1;

         {GAUCHE-BAS vers DROIT-BAS}
         Bas[0] := Gauche[LongGauche];
         Pos.x := Bas[0].Position.x+0.5*Bas[0].TailleX;
         Pos.y := Bas[0].Position.y;

         i := 1; Long := Bas[0].TailleX;
         while Long < LongBas do
         begin
            if LongBas-Long >= LONG_PLUS_GRAND_IMMEUBLE then nume := TireUnImmeuble(LONG_PLUS_GRAND_IMMEUBLE+1)
            else nume := TireUnImmeuble(LongBas-Long);
            Pos.x := pos.x+0.5*ParamMaison[nume].taille;
            pos.y := 0.5*Bas[0].TailleY+Bas[0].Position.y-0.5*ParamMaison[nume].taille;
            pos.z := Min(Altitude(Pos.x-0.5*ParamMaison[nume].taille,Pos.y+LONG_PLUS_GRAND_IMMEUBLE),
                         Altitude(Pos.x+0.5*ParamMaison[nume].taille,Pos.y+LONG_PLUS_GRAND_IMMEUBLE));

            Bas[i] := TMaison.Create(pos,nume);
            Bas[i].Affiche(2);
            Pos.x := pos.x+0.5*ParamMaison[nume].taille;
            Long := Long+ParamMaison[nume].taille;
            i := i+1;
         end;
         LongBas := i-1;

         {DROIT-HAUT vers DROIT-BAS}
         Droit[0] := Haut[LongHaut];
         Pos.x := Droit[0].Position.x;
         Pos.y := Droit[0].Position.y+0.5*Droit[0].TailleY;

         i := 1; Long := Droit[0].TailleY+Bas[LongBas].TailleY;
         while Long < LongDroit do
         begin
            if LongDroit-Long >= LONG_PLUS_GRAND_IMMEUBLE then nume := TireUnImmeuble(LONG_PLUS_GRAND_IMMEUBLE+1)
            else nume := TireUnImmeuble(LongDroit-Long);
            pos.x := 0.5*Droit[0].TailleX+Droit[0].Position.x-0.5*ParamMaison[nume].taille;
            Pos.y := Pos.y+0.5*ParamMaison[nume].taille;
            pos.z := Min(Altitude(Pos.x+LONG_PLUS_GRAND_IMMEUBLE,Pos.y-0.5*ParamMaison[nume].taille),
                         Altitude(Pos.x+LONG_PLUS_GRAND_IMMEUBLE,Pos.y+0.5*ParamMaison[nume].taille));

            Droit[i] := TMaison.Create(pos,nume);
            Droit[i].Affiche(3);
            Pos.y := pos.y+0.5*ParamMaison[nume].taille;
            Long := Long+ParamMaison[nume].taille;
            i := i+1;
         end;
         LongDroit := i-1;
      end;
   glEndList();
end;


{*******************************************************************************}
procedure TBloc.Affiche(a,b : integer);
var dx,dy : real;
begin
   if MyFrust.RectangleInFrustum(Maville[a,b].Carrefour.TabPos[0],
                                 Maville[a,b].Route1.TabPos[1],
                                 Maville[a,b].Route0.TabPos[3])
   then
   begin
      glCallList(Route_Liste_Affichage);
      if b <> RANGEE_DU_FLEUVE then glCallList(Maison_Liste_Affichage)
      else
      begin
         Decal_Texture_Eau := Decal_Texture_Eau + 0.01;
         dx := (LONG_ROUTE_X+ESPACE_CAREFOUR)/2;
         dy := (LONG_ROUTE_Y+ESPACE_CAREFOUR)/2;

         //texture eau
         glDisable(GL_CULL_FACE);
         GlPushMatrix();
         Gltranslated(Carrefour.TabPos[2].x+LONG_ROUTE_X/2,Carrefour.TabPos[2].y+LONG_ROUTE_Y/2,-18);
         GlEnable(GL_TEXTURE_2D);
         Glcolor3f(1,1,1);
         GlBindTexture(GL_TEXTURE_2D, Text_eau);
         GlBegin(gl_triangles);
         glTexCoord2f(1.0+Decal_Texture_Eau,  1.0+Decal_Texture_Eau); glVertex3f(-dx,-dy,1);
         glTexCoord2f(1.0+Decal_Texture_Eau,  0.0);                   glVertex3f(-dx,dy,1);
         glTexCoord2f(0.0,                    0.0);                   glVertex3f(dx,dy,1);

         glTexCoord2f(0.0,                    0.0);                   glVertex3f(dx,dy,1);
         glTexCoord2f(0.0,                    1.0+Decal_Texture_Eau); glVertex3f(dx,-dy,1);
         glTexCoord2f(1.0+Decal_Texture_Eau,  1.0+Decal_Texture_Eau); glVertex3f(-dx,-dy,1);
         GlEnd();
         GlPopMatrix();
         glEnable(GL_CULL_FACE);
      end;

      TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].Affiche();
      TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].Affiche();
      TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].Affiche();
      TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].Affiche();

      TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].Affiche();
      TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].Affiche();
      TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE].Affiche();
      TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].Affiche();
   end;
end;

{************************ FEU TRICOLORE ****************************************}
procedure TBloc.ActualiseFeu(i,j, id : integer);
begin
   //Actualisation
   if id = ACTUALISE_LES_FEUX then
   begin
      TimerFeux := (TimerFeux + 1);
      if TimerFeux > Duree_cycle then
      begin
         TimerFeux := 1;
         LesFPS1 := LesFPS;
      end;

      if TimerFeux < Duree_feu_vert then EtatFeux := 0
      else if TimerFeux < Duree_feu_rouge then EtatFeux := 1
      else if TimerFeux < (Duree_feu_vert+Duree_feu_rouge) then EtatFeux := 2
      else EtatFeux := 3;
   end;

   //Affichage des feux
   if id = DESSINE_LES_FEUX then
   begin
      glPushMatrix();
      glDepthMask(GL_FALSE);
      glDisable(GL_CULL_FACE);
      Gltranslated(i*TAILLE_BLOC_X,j*TAILLE_BLOC_Y,Maville[i,j].Carrefour.TabPos[0].z);


      case EtatFeux of
         0 : begin
                glcallList(TabPart[0]);
                glcallList(TabPart[3]);
                glcallList(TabPart[11]);
                glcallList(TabPart[8]);
             end;
         1 : begin
                glcallList(TabPart[1]);
                glcallList(TabPart[4]);
                glcallList(TabPart[8]);
                glcallList(TabPart[11]);
             end;
         2 : begin
                glcallList(TabPart[6]);
                glcallList(TabPart[2]);
                glcallList(TabPart[9]);
                glcallList(TabPart[5]);
             end;
         3 : begin
                glcallList(TabPart[2]);
                glcallList(TabPart[5]);
                glcallList(TabPart[7]);
                glcallList(TabPart[10]);
             end;
      end;
      glDepthMask(GL_TRUE);
      glEnable(GL_CULL_FACE);
      GLPopMatrix();
   end;
end;


{************************** TROUTE *********************************************}
constructor TRoute.Create(A,B,C,D : Tvecteur; ident : integer);
var n : TVecteur;
begin
   TabPos[0] := A;  TabPos[1] := B; TabPos[2] := C; TabPos[3] := D;
   case ident of
      ROUTE_0 :
         begin
            Pente := (TabPos[3].z - TabPos[0].z) / (TabPos[3].x - TabPos[0].x);

            glEnable(GL_TEXTURE_2D);
            glcolor3f(1,1,1);
            glBindTexture(GL_TEXTURE_2D, Text_route);

            n := CreerNormale(A,C,B);
            glnormal(n.x,n.y,n.z);
            glbegin(GL_TRIANGLES);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glTexCoord2f(2.0, 0.0); glVertex3f(B.x,B.y,B.z);
            glTexCoord2f(2.0, 10.0); glVertex3f(C.x,C.y,C.z);

            glTexCoord2f(2.0, 10.0); glVertex3f(C.x,C.y,C.z);
            glTexCoord2f(0.0, 10.0); glVertex3f(D.x,D.y,D.z);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glend;
            glDisable(GL_TEXTURE_2D);
         end;
      ROUTE_1 :
         begin
            Pente := (TabPos[1].z - TabPos[0].z) / (TabPos[1].y - TabPos[0].y);

            glEnable(GL_TEXTURE_2D);
            glcolor3f(1,1,1);
            glBindTexture(GL_TEXTURE_2D, Text_route);

            n := CreerNormale(A,C,B);
            glnormal(n.x,n.y,n.z);
            glbegin(GL_TRIANGLES);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glTexCoord2f(0.0, 10.0); glVertex3f(B.x,B.y,B.z);
            glTexCoord2f(2.0, 10.0); glVertex3f(C.x,C.y,C.z);

            glTexCoord2f(2.0, 10.0); glVertex3f(C.x,C.y,C.z);
            glTexCoord2f(2.0, 0.0); glVertex3f(D.x,D.y,D.z);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glend;
            glDisable(GL_TEXTURE_2D);
         end;
      LECARREFOUR :
         begin
            Pente := 0;

            glEnable(GL_TEXTURE_2D);
            glcolor3f(1,1,1);
            glBindTexture(GL_TEXTURE_2D, Text_route);

            n := CreerNormale(A,C,B);
            glnormal(n.x,n.y,n.z);
            glbegin(GL_TRIANGLES);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glTexCoord2f(0.0, 2.0); glVertex3f(B.x,B.y,B.z);
            glTexCoord2f(2.0, 2.0); glVertex3f(C.x,C.y,C.z);

            glTexCoord2f(2.0, 2.0); glVertex3f(C.x,C.y,C.z);
            glTexCoord2f(2.0, 0.0); glVertex3f(D.x,D.y,D.z);
            glTexCoord2f(0.0, 0.0); glVertex3f(A.x,A.y,A.z);
            glend;
            glDisable(GL_TEXTURE_2D);
         end;
   end;
end;

{************************** MAIN *********************************************}
procedure CreationVille();
var  P : TVecteur; i,j : integer;
AffPont : boolean; // Affiche le pont
A0,B0,C0,D0 : Tvecteur;
A1,B1,C1,D1 : Tvecteur;
TabCarrefour : array[0..NB_BLOC_MAX_X,0..NB_BLOC_MAX_Y,0..3] of TVecteur;
begin
   {On se donne une altitude aleatoire pour chaque bloc de la ville. Les 4 sommets
    du carrefour de chaque bloc ont la meme altitude.}
   for i := 0 to NB_BLOC_MAX_X do
   begin
      for j := 0 to NB_BLOC_MAX_Y do
      begin
         A0.x := i*TAILLE_BLOC_X; A0.y := j*TAILLE_BLOC_Y;
         if (j = RANGEE_DU_FLEUVE) OR (j = RANGEE_DU_FLEUVE+1) then A0.z := 0 else A0.z := random*Random_Terrain;
         B0.x := A0.x; B0.y := A0.y+ESPACE_CAREFOUR; B0.z := A0.z;
         C0.x := A0.x+ESPACE_CAREFOUR; C0.y := B0.y; C0.z := A0.z;
         D0.x := C0.x; D0.y := A0.y; D0.z := A0.z;
         TabCarrefour[i,j,0] := A0;
         TabCarrefour[i,j,1] := B0;
         TabCarrefour[i,j,2] := C0;
         TabCarrefour[i,j,3] := D0;

      end;
   end;

   {Construction des routes : on relie une route a deux carrefours.
    Attention : on utilise N-1 blocs et non N blocs, car les 2 carrefours n'ap-
    -partiennent pas au meme bloc.}
   for i := 0 to NB_BLOC_MAX_X-1 do
   begin
      for j := 0 to NB_BLOC_MAX_Y-1 do
      begin
         {Premiere Route}
         A0.x := i*TAILLE_BLOC_X+ESPACE_CAREFOUR; A0.y := j*TAILLE_BLOC_Y; A0.z := TabCarrefour[i mod NB_BLOC_MAX_X,j mod NB_BLOC_MAX_Y,0].z;
         B0.x := A0.x; B0.y := A0.y+ESPACE_CAREFOUR; B0.z := A0.z;
         C0.x := A0.x+TAILLE_BLOC_X-ESPACE_CAREFOUR; C0.y := B0.y; C0.z := TabCarrefour[(i+1) mod NB_BLOC_MAX_X ,j mod NB_BLOC_MAX_Y,0].z;
         D0.x := C0.x; D0.y := A0.y; D0.z := C0.z;

         {Deuxieme Route}
         A1.x := i*TAILLE_BLOC_X; A1.y := j*TAILLE_BLOC_Y+ESPACE_CAREFOUR; A1.z := TabCarrefour[i mod NB_BLOC_MAX_X,j mod NB_BLOC_MAX_Y,0].z;
         B1.x := A1.x; B1.y := A1.y+TAILLE_BLOC_Y-ESPACE_CAREFOUR; B1.z := TabCarrefour[i mod NB_BLOC_MAX_X,(j+1) mod NB_BLOC_MAX_Y,0].z;
         C1.x := A1.x+ESPACE_CAREFOUR; C1.y := B1.y; C1.z := B1.z;
         D1.x := C1.x; D1.y := A1.y; D1.z := A1.z;

         {Si j = 4 alors AffPont est a TRUE sinon AffPont est a FALSE.
          AffPont == Affiche Pont}
         AffPont := (j = RANGEE_DU_FLEUVE);
         MaVille[i,j] := TBloc.Create;
         MaVille[i,j].CreateRoute(A0,B0,C0,D0,0,
                                  A1,B1,C1,D1,1,
                                  TabCarrefour[i,j,0],TabCarrefour[i,j,1],TabCarrefour[i,j,2],TabCarrefour[i,j,3],2,
                                  AffPont);
      end;
   end;

   {Construction du bloc de batimments}
   for i := 0 to NB_BLOC_MAX_X-1 do
   begin
      for j := 0 to NB_BLOC_MAX_Y-1 do
      begin
         //Position des blocs
         P.x := ESPACE_CAREFOUR+i*TAILLE_BLOC_X;
         P.y := ESPACE_CAREFOUR+j*TAILLE_BLOC_Y;
         P.z := 0;

         MaVille[i,j].Creation(P,TAILLE_BLOC_X-ESPACE_CAREFOUR-2,
                               TAILLE_BLOC_Y-ESPACE_CAREFOUR-1,
                               TAILLE_BLOC_X-ESPACE_CAREFOUR-2,
                               TAILLE_BLOC_Y-ESPACE_CAREFOUR-1,
                               i,j,random(100)+1);
      end;
   end;
end;


Procedure DestroyVille();
var i,j : integer;
begin
   for i := 0 to NB_BLOC_MAX_X-1 do
   begin
      for j := 0 to NB_BLOC_MAX_Y-1 do
      begin
         //circulation
         MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].DestroyCirculation();

         MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].DestroyCirculation();
         MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE].DestroyCirculation();

         MaVille[i,j].Destroy;
      end;
   end;
end;

{*******************************************************************************}
procedure ActualiseLesFeux();
var i,j : integer;
begin
   for i := 0 to (NB_BLOC_MAX_X-1) do
   begin
      for j := 0 to (NB_BLOC_MAX_Y-1) do
      begin
         MaVille[i,j].ActualiseFeu(i,j,ACTUALISE_LES_FEUX);
      end;
   end;
end;


Procedure AfficheVille();
var i,j,ii,jj,iii,jjj : integer; Couple : TCouple;
begin
   //******METTRE FRUSTUM SUR LE PLAN PAS UN CUBE
   Couple := QuellePartition(Joueur.Position.x,Joueur.Position.y);
   for i := 0 to 2 do
   begin
      for j := 0 to 2 do
      begin
         ii := (Couple.x-1+i);
         jj := (Couple.y-1+j);

         if (ii < 0) then
         begin
            if (jj < 0) then
            begin  //QQ
               iii := ii + NB_BLOC_MAX_X;
               jjj := jj + NB_BLOC_MAX_Y;
               glpushmatrix();
               gltranslated(-TAILLE_MAP_X,-TAILLE_MAP_Y,0);
               Maville[iii,jjj].Affiche(iii,jjj);
               Maville[iii,jjj].ActualiseFeu(iii,jjj,DESSINE_LES_FEUX);
               glpopMatrix();
            end else
               if (jj < NB_BLOC_MAX_Y) then
               begin  //QQ
                  iii := ii + NB_BLOC_MAX_X;
                  glpushmatrix();
                  gltranslated(-TAILLE_MAP_X,0,0);
                  Maville[iii,jj].Affiche(iii,jj);
                  Maville[iii,jj].ActualiseFeu(iii,jj,DESSINE_LES_FEUX);
                  glpopMatrix();
               end else
                  if (jj >= NB_BLOC_MAX_Y) then
                  begin  //QQ
                     iii := ii + NB_BLOC_MAX_X;
                     jjj := jj - NB_BLOC_MAX_Y;
                     glpushmatrix();
                     gltranslated(-TAILLE_MAP_X,TAILLE_MAP_Y,0);
                     Maville[iii,jjj].Affiche(iii,jjj);
                     Maville[iii,jjj].ActualiseFeu(iii,jjj,DESSINE_LES_FEUX);
                     glpopMatrix();
                  end;
         end else
            if (ii < NB_BLOC_MAX_X) then
            begin
               if (jj < 0) then
               begin  //QQ
                  jjj := jj+ NB_BLOC_MAX_Y;
                  glpushmatrix();
                  gltranslated(0,-TAILLE_MAP_Y,0);
                  Maville[ii,jjj].Affiche(ii,jjj);
                  Maville[ii,jjj].ActualiseFeu(ii,jjj,DESSINE_LES_FEUX);
                  glpopMatrix();
               end else
                  if (jj < NB_BLOC_MAX_Y) then
                  begin
                     Maville[ii,jj].Affiche(ii,jj);
                     Maville[ii,jj].ActualiseFeu(ii,jj,1);
                  end else
                     if (jj >= NB_BLOC_MAX_Y) then
                     begin
                        jjj := jj-NB_BLOC_MAX_Y;
                        glpushmatrix();
                        gltranslated(0,TAILLE_MAP_Y,0);
                        Maville[ii,jjj].Affiche(ii,jjj);
                        Maville[ii,jjj].ActualiseFeu(ii,jjj,DESSINE_LES_FEUX);
                        glpopMatrix();
                     end;
            end else
               if (ii >= NB_BLOC_MAX_X) then
               begin
                  if (jj < 0) then
                  begin //QQ
                     iii := ii - NB_BLOC_MAX_X;
                     jjj := jj + NB_BLOC_MAX_Y;
                     glpushmatrix();
                     gltranslated(TAILLE_MAP_X,-TAILLE_MAP_Y,0);
                     Maville[iii,jjj].Affiche(iii,jjj);
                     Maville[iii,jjj].ActualiseFeu(iii,jjj,DESSINE_LES_FEUX);
                     glpopMatrix();
                  end else
                     if (jj < NB_BLOC_MAX_Y) then
                     begin
                        iii := ii-NB_BLOC_MAX_X;
                        glpushmatrix();
                        gltranslated(TAILLE_MAP_X,0,0);
                        Maville[iii,jj].Affiche(iii,jj);
                        Maville[iii,jj].ActualiseFeu(iii,jj,DESSINE_LES_FEUX);
                        glpopMatrix();
                     end else
                        if (jj >= NB_BLOC_MAX_Y) then
                        begin
                           iii := ii-NB_BLOC_MAX_X;
                           jjj := jj-NB_BLOC_MAX_Y;
                           glpushmatrix();
                           GLtranslated(TAILLE_MAP_X,TAILLE_MAP_Y,0);
                           Maville[iii,jjj].Affiche(iii,jjj);
                           Maville[iii,jjj].ActualiseFeu(iii,jjj,DESSINE_LES_FEUX);
                           glpopMatrix();
                        end;
               end;
      end;
   end;
end;

end.
