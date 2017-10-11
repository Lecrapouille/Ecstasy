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
unit UChargement;

interface
USES
   SysUtils,
   UVille,
   ULoader,
   UTextures,
   UJoueur,
   USons,
   UFeux,
   UTypege,
   UParticules,
   UFrustum,
   UCirculation,
   Windows,
   URepere,
   UTransparence,
   OpenGL;

procedure Chargement(var Keys : array of boolean);

implementation
uses UCaractere, ULancement;

//----------------------------------------------------------------------------//
procedure ChargementDesTexture();
begin
   ProgressBar.Etape := 0; Loading(0);
   LoadTexture(GetCurrentDir + '\data\textures\particule.bmp', Text_part, FALSE);
   LoadTexture(GetCurrentDir + '\data\textures\road.jpg', Text_route, FALSE);
   LoadTexture(GetCurrentDir + '\data\textures\cross.jpg', Text_carrefour, FALSE);
   LoadTexture(GetCurrentDir + '\data\textures\eau.bmp', Text_eau, FALSE);
   LoadTexture(GetCurrentDir + '\data\textures\sol.bmp', Text_sol, FALSE);
   LoadTexture(GetCurrentDir + '\data\textures\pont.bmp', Text_berges, FALSE);

   LoadTexture(GetCurrentDir + '\data\textures\TableauDeBord.bmp', TableauDeBord_0, FALSE);
   Volant_0 := CreerMasque(GetCurrentDir + '\data\textures\volant0_masque.bmp',
                           GetCurrentDir + '\data\textures\volant0_dessin.bmp');
   Loading(1);
end;

procedure ChargementDesVoitures();
var i : integer;
begin
   ProgressBar.Etape := 1; Loading(0);
   for i := 1 to TabRepertVoit.long do
   begin
      loaderAse(GetCurrentDir+'\data\Voitures\'+ TabRepertVoit.elt[i].Nom + '\Carcasse.ASE', @TabRepertVoit.elt[i-1].GLCarcasse, FALSE);
      loaderAse(GetCurrentDir+'\data\Voitures\'+ TabRepertVoit.elt[i].Nom + '\Roue.ASE', @TabRepertVoit.elt[i-1].GLRoue, FALSE);
   end;
   Loading(1);
end;

procedure ChargementDesImmeubles();
var i : integer;
begin
   ProgressBar.Etape := 2; Loading(0);
   loaderAse(GetCurrentDir + '\data\Immeubles\FeuRouge.ASE', @feurouge_liste, FALSE);
   loaderAse(GetCurrentDir + '\data\Immeubles\Pont.ASE', @pont_liste, FALSE);

   for i := 0 to NB_TYPE_MAISON do
   begin
      loaderAse(GetCurrentDir + '\data\Immeubles\Immeuble_'+IntToStr(i)+'.ASE', @TabImeublesObjt[i], Params.Nuit);
   end;
   Loading(1);
end;
//----------------------------------------------------------------------------//

procedure Chargement(var Keys : array of boolean);
var i : integer;
begin
   randomize;
   Camera.id := 0;

   {initialisation de la progress bar}
   ProgressBar.Position := 0.1;
   ProgressBar.Pas := Params.Width/5  ;  {il y a 5 Etapes}
   LoadTexture(GetCurrentDir + '\data\textures\chargement.bmp', Text_chgt, FALSE);

   CreerRepere();
   ChargementDesTexture();
   ChargementDesVoitures();

   ChargementDesImmeubles();
   InitParametreMaison();
   CreationVille();
   DisplayListFeuxTricolores();

   {Attention l' initialisation des voitures ou joueur toujours apres la ville}
   Joueur := TJoueur.Create(40,40,NumeroIdentifVoit);

   {initialise le son}
   InitSound(DSB);
   JouerEnBoucle();

   {frustum}
   Myfrust := TFrustum.Create();

   {Moteur de particules}
   Systeme := TSysteme.Create();
   if Params.Pluie then Pluie := TPluie.create(Joueur.Position);

   {init touches}
   for i := 0 to 255 do Keys[i] := false;

   {circulation}
   InitCirculation();
   loading(1);
end;
//----------------------------------------------------------------------------//

end.
