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
unit UTypege;

interface

uses
   opengl,
   windows,
   UMath;

{********** Ville.pas ******}
CONST
   // Frames Per Seconds
   FPS_TIMER = 1;                     // Timer to calculate FPS
   IFPS_INTERVAL = 1000;
   FPS_INTERVAL = 1.0 * IFPS_INTERVAL; // Calculate FPS every 1000 ms
   FPS_DESIRES = 120; // Bloque le jeu a 120 FPS
   MS_PAR_IMAGE = 1.0 / FPS_DESIRES;

   INFINI = 1000000;

   // VILLE
   EST_UN_TERRAIN = 1;
   EST_UN_BLOC = 0;

   NB_TYPE_MAISON = 11;
   LONG_PLUS_GRAND_IMMEUBLE = 50;

   NB_BLOC_MAX_X = 6;
   NB_BLOC_MAX_Y = 6;

   LONG_TROTTOIR = 15;
   ESPACE_CAREFOUR = 100;
   LONG_ROUTE_X_DESIREE = 7*LONG_PLUS_GRAND_IMMEUBLE; // doit etre modulo 50
   LONG_ROUTE_Y_DESIREE = 7*LONG_PLUS_GRAND_IMMEUBLE;

   LONG_ROUTE_X = LONG_ROUTE_X_DESIREE + 2 * LONG_TROTTOIR;
   LONG_ROUTE_Y = LONG_ROUTE_Y_DESIREE + 2 * LONG_TROTTOIR;
   NB_MAISON_MAX_X = LONG_ROUTE_X DIV LONG_PLUS_GRAND_IMMEUBLE;
   NB_MAISON_MAX_Y = LONG_ROUTE_Y DIV LONG_PLUS_GRAND_IMMEUBLE;

   TAILLE_BLOC_X = LONG_ROUTE_X+ESPACE_CAREFOUR;
   TAILLE_BLOC_Y = LONG_ROUTE_Y+ESPACE_CAREFOUR;

   TAILLE_MAP_X = NB_BLOC_MAX_X*TAILLE_BLOC_X;
   TAILLE_MAP_Y = NB_BLOC_MAX_Y*TAILLE_BLOC_Y;

   RANGEE_DU_FLEUVE = 4;
   PROFONDEUR_FLEUVE = -30;

   // AFFICHAGE
   NB_QUARTIER_A_AFFICHER = 5; // Affiche NxN blocs de ville
   DISTANCE_CLIPPING = NB_QUARTIER_A_AFFICHER * LONG_ROUTE_X_DESIREE;          // OpenGL

   // PARTICULE
   ACTUALISE_LES_FEUX = 0;
   DESSINE_LES_FEUX = 1;
   MAX_PARTICULE_TEXTURE = 20;

   // FEUX TRICOLORES
   HAUTEUR_FEU_TRICOLORE = 23.5;
   TPS_FEU_VERT = 6000; // duree fu feu vert en millisecondes
   TPS_FEU_ORANGE = 2000;
   TPS_FEU_ROUGE = 6000;
   TPS_CYCLE = TPS_FEU_VERT + 2 * TPS_FEU_ORANGE + TPS_FEU_ROUGE;
   ETAT_FEUX_VERT_ROUGE = 0; {1er feu: vert -- 3eme feu: rouge}
   ETAT_FEUX_ORANGE_ROUGE = 1; {1er feu: orange -- 3eme feu: rouge}
   ETAT_FEUX_ROUGE_VERT = 2; {1er feu: rouge -- 3eme feu: vert}
   ETAT_FEUX_ROUGE_ORANGE = 3; {1er  feu: rouge -- 3eme feu: orange}

   // SOURIS
   MOUSE_SPEED = 0.5;         // Vitesse de la souris

   // VOITURE
   MAX_VOITURES = 30;         // Nombre maximum de dossiers voitures dans le repertoire 'Data/Voitures'
   VITESSE_MINIMALE = 0.0001; // Voiture a l'arret (probleme de / par 0)
   LONG_VOIT = 12;            // Longueur d'une voiture (ne pas changer)
   GRAVITE = 40;              // Ne pas changer
   ACCELERATION = 5;          // pour les goodies
   VITTESSE_VOIE_RAPIDE = 220;
   VITTESSE_VOIE_LENTE =  150;
   ESPACE_SECURITE = 3 * LONG_VOIT;

   // CAMERA
   ALTITUDE_MAX_CAMERA = 200; // Vue aeriene
   NB_VUE_CAMERA = 3;         // Nombre de vue differentes pour la camera

   //TTablCirculation
   SENS_DIRECT   = 0;   // voitures roulant a gauche
   SENS_INDIRECT = 1; // voitures roulant a droite
   VOIE_RAPIDE   = 1;   // Comme sur l'autoroute !!
   VOIE_LENTE    = 0;    // Comme sur l'autoroute !!
   ROUTE_0       = 0;       //
   ROUTE_1       = 1;       //
   LECARREFOUR   = 2;     //
   MAISONS       = 3;
   {********** Ville.pas ******}

   //T_Modele = (TMonster,TaudiRS,TAudiTTSE,TZafira,TCamion);

type Tposition = record
   x,y,z : glfloat;
end;

TCamera = record
   Position : TVecteur;
   Target : TVecteur;
   Orientation : TVecteur;
   theta,norme,vx,vy : real;
   id : byte;
end;

T_param = record
   son : boolean;
   Police : integer;
   FullScreen : Boolean;
   Width  : Integer;
   Height : Integer;
   PixelDepth : Integer;
   fog : boolean;
   glLumiere : boolean;
   Nuit : boolean;
   Pluie : boolean;
   Altitude : integer;
   circu : byte;
   ProportionTerrain : integer; // Proportion nb de terrains par rapport aux immeubles
   CarrefourAmericain : boolean; // Style americain ou Europen (= feux apres ou avant le carrefour)
   LumieresActivees: boolean;
end;
//////////////////////////////////
pVertex = ^TVertex;
TVertex = record
   x, y, z : glFloat;
   Next : pVertex;
end;

pFace = ^TFace;
TFace = record
   v : array[1..3] of pVertex;
   TextCoord : array[1..3] of pVertex;
   Normale  : TVecteur;

   //D : GLFloat;
   Next : pFace;
end;

pTexture = ^TTexture;
TTexture = record
   Transparency : real;
   Utiling,Vtiling : real;
   Id : GLuint;
   Next : pTexture;
end;

pMesh = ^TMesh;
TMesh = record
   VertexHead : TVertex;
   VertexQueue : pVertex;
   FaceHead : TFace;
   FaceQueue : pFace;
   CoordTextHead : TVertex;
   CoordTextQueue : pVertex;
   Texture : pTexture;
   Next : pMesh;
end;

pObjet = ^TObjet;
TObjet = record
   MeshHead : TMesh;
   MeshQueue : pMesh;
   TextureHead : TTexture;
   TextureQueue : pTexture;
   Liste : GLUint;
end;


TCouple = record  //Pour des triplets de donnees
   x,y : integer;
end;

TTriplet = record  //Pour des triplets de donnees
   x,y,z : integer;
end;

TTabImeublesObjt = array[0..NB_TYPE_MAISON] of Tobjet;

TParamVoit = object
   VitesseMax : real;
   Avant   : real;
   Arriere : real;
   Gauche  : real;
   Hauteur : real;
   Rayon   : real;
   Masse_Roue : real;
   Masse_Voit : real;
   Reac_Sol : real;
   Raideur : real;
   Frot    : real;
   InertieRoulis : real;
   InertieTangage : real;
   Past    : real;
   Conducteur : real;
   Nom : string;
end;

TParamVoiture = object(TParamVoit)
   GLRoue,
   GLCarcasse : TObjet;
end;

TTabRepertoires = record
   long : integer;
   elt : array [0..MAX_VOITURES] of TParamVoiture;
end;


var
   {Souris--Clavier}
   XMouse : integer = 0;
   YMouse : integer = 0;
   keys : array [0..255] of boolean;
   keysold : array [0..255] of boolean;

   {Liste d'affichage OpenGL}
   Ville_liste, sky, LeRepere, Terrain : GLUint;
   feurouge_liste,pont_liste : TObjet;
   TabRepertVoit : TTabRepertoires;
   TabImeublesObjt  : TTabImeublesObjt;
   Text_berges,
   Text_pont,
   Text_route,
   Text_carrefour,
   Text_eau,
   Text_sol,
   Text_chgt,
   Text_part,
   Text_terrain : gluint;

   TableauDeBord_0,
   Volant_0 : gluint;

   {Camera}
   Camera : Tcamera;
   phiCamera : real = -0.4;
   ThetaCamera : real = -0.06;
   DistanceCamera : real = 30;

   {FPS}
   FPSCount : integer = 0;
   deltaTime  : glFloat = 0;
   LastUpdate : glFloat = 0;
   ElapsedTime : DWord;  // millisecondes

   {Parametres videos}
   params : T_param;

   Random_Terrain : integer;
   NumeroIdentifVoit : integer;

   Duree_feu_vert,
   Duree_feu_rouge,
   Duree_feu_orange,
   Duree_cycle : DWord;
   TimerFeux : DWord;

   Volant : gluint;

   NbVoitVoieRapide : byte;
   NbVoitVoieLente : byte;


   ColliImmeuble, OldColliImmeuble,
   ColliVoiture,  OldColliVoiture  : boolean;
   OldTheta : real;

implementation

end.
