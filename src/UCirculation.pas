{*******************************************************************************
 *                            UCIRCULATION.PAS
 *
 * Author  : Quentin QUADRAT
 * Email   : quadra_q@epita.fr
 * Website : www.epita.fr\~epita.fr
 * Date    : 02 Juin 2003
 * Changes : 02 Juin 2003
 * Description :
 *
 *******************************************************************************}

unit UCirculation;

interface

uses UVoiture,
     UMath,
     UFrustum,
     Windows,
     UTypege,
     math;

{**************************  TPGoodies  ****************************************
 *
 * Les Goodies sont les voitures neutres qui circulent dans la ville. Ils heritent
 * du type TVoiture, mais ils ont plus un pointeur sur le goody suivant car ils
 * sont du type Pointeur sur un Goody.
 *
*******************************************************************************}
Type TPGoodies = ^TGoodies;
TGoodies = class(TVoiture)
  public
     VitesseVoulue : real;
     next : TPGoodies; {Pointeur sur la voiture suivante}
     Prec : TPGoodies; {Pointeur sur la voiture precedente}
  private
     BlocX,BlocY : byte; {Les numeros du bloc auquel la voiture appartient}
     Vx : real;   {Composant de la vitesse sur l'axe X}
     Vy : real;   {Composant de la vitesse sur l'axe Y}
     
     constructor Create(const x,y : real; const LaRoute, LeSens, LaVoie, ident : byte);
     procedure ChgVitDirect(const i,j,QuelleRoute,QuelleVoie : byte; const Pos : TVecteur; Vit : real);
     procedure ChgVitIndirect(const i,j,QuelleRoute,QuelleVoie : byte; const Pos : TVecteur; Vit : real);
end;


{************************  TCirculation  ***************************************
 *
 * Pour chaque route (numero 0 et numero 1), pour chaque voie (lente ou rapide)
 * et pour chaque sens du flot de circulation des voitures (sens direct ou indirect)
 * on cree une TFile de voitures (du genre file d'attente pour le cinema : premier
 * arrive, premier servis). La premiere voiture est la TETE (ou leader). La derniere
 * est la queue.
 *
 * Le leader (TETE) est attire par le carrefour (champ attractif) si le feu est
 * rouge on ajoute en plus du premier champ un champ repulsif (pour l'arreter).
 *
 * le predecesseur du leader est attire par le leader, de meme que pour le troisieme
 * avec le deuxieme ... On ajoute un champ repulsif pour les empecher de se rentrer
 * dedans.
 *
 * Lorsque que le leader est arrive au carrefour, on le supprime et on l'ajoute
 * dans la file de l'autre bloc.
 * Il se trouve maintenant en QUEUE (on passe de leader a looser !!!!).
 *
 *  Tete  : voiture leader
 *  Queue : voiture looser
 *
 *  procedure Initialisation();
 *               Initialise la file a vide en mettant TETE et QUEUE a NIL.
 *
 *  procedure AjoutEnQueue();
 *               Ajout une nouvelle voiture (ancienne TETE de file) dans la file
 *               de voiture en derniere position (en QUEUE).
 *
 *  function  SupprimeTete() : TPGoodies;
 *               La voiture TETE est supprimee, sa suivante devient leader
 *               La voiture TETE est ajoutee dans une autre file grace a la
 *               procedure precedente.
 *               La fct retourne la voiture a supprimer.
 *
 *******************************************************************************}
TCirculation = class(Tobject)
      Tete : TPGoodies;
      Queue : TPGoodies;
      destructor  DestroyCirculation();
      procedure   Affiche();
   private
      function    SupprimeTete() : TPGoodies;
      constructor AjoutEnQueue(const voit : TPGoodies);
      constructor ActuIndirect(const i,j,QuelleRoute,QuelleVoie : integer);
      procedure   ActuDirect(const i,j,QuelleRoute,QuelleVoie : integer);
      procedure   Initialisation();
end;

{*****************************  TabCirculation  ********************************
 *
 *   Tableau pour la circulation des voitures.
 *   Premiere case  :
 *        - numero de la route (0 ou 1).
 *   Deuxieme case  :
 *         - voie de gauche ou voie de droite,
 *   Troisieme case :
 *         - voie a vitesse lente, rapide.
 *
 ******************************************************************************}
TTabCirculation = array[ROUTE_0..ROUTE_1,SENS_DIRECT..SENS_INDIRECT,VOIE_LENTE..VOIE_RAPIDE] of TCirculation;

procedure InitCirculation();
procedure ActuCircuDirect();
procedure ActuCircuIndirect();

implementation
uses UAltitude, UCaractere, ULancement, UVille;

{*******************************************************************************
 *
 * Creation -- initialisation de la voiture
 *
 *******************************************************************************}
constructor TGoodies.Create(const x,y : real; const LaRoute, LeSens, LaVoie, ident : byte);
begin
   inherited Create(x,y,ident);
   BlocX := QuellePartition(Position.x,Position.y).x;
   BlocY := QuellePartition(Position.x,Position.y).y;
   Vitesse := Param.VitesseMax;
   
   if LeSens = SENS_DIRECT then
   begin
      VitesseVoulue := Param.VitesseMax;
      Vx := Vitesse;
      Vy := 0;
      Direction := 0;
   end else
   begin
      VitesseVoulue := Param.VitesseMax;
      Vx := -Vitesse;
      Vy := 0;
      Direction := PI;
   end;
end;

{*******************************************************************************
 *
 * Changement de vitesse d'une voiture sur les routes a sens direct
 *
 * Parametres :
 *     la voiture appartient : au bloc de la ville (i,j)
 *                           : sur quelle route et sur quelle voie (QuelleRoute, QuelleVoie)
 *     la position et la vitesse de la voiture precedente (Pos, Vit)
 *
 *******************************************************************************}
procedure TGoodies.ChgVitDirect(const i,j,QuelleRoute,QuelleVoie : byte; const Pos : TVecteur; Vit : real);
var Coef,Ax,Ay,Vxx,Vyy,Dist,W : real;
begin
      if QuelleRoute = ROUTE_1 then
      begin
          if Pos.y > Position.y then Dist := Pos.y-Position.y -3*LONG_VOIT
          else Dist := Pos.y + TAILLE_MAP_Y-Position.y - 3*LONG_VOIT;

          {Si la voiture est trop pres de la suivante elle prend la meme vitesse}
          if Dist > 0 then W := Vitesse+ACCELERATION else
          if Vit < Vitesse then W := Vit else W := Vitesse;

          {si lee feu est a l'orange ou au rouge, la voiture ralentit}
          if (Maville[i,(j+1) mod NB_BLOC_MAX_Y].EtatFeux = 2)
          then Vy := Min(VitesseVoulue,W)
          else Vy := Max(VITESSE_MINIMALE,Min(Min(VitesseVoulue,W),2*((j+1)*TAILLE_BLOC_Y-1.5*LONG_VOIT-Position.y)));

          Vx := 0;
          Vitesse := Vy;
          Direction := PI/2;

          {Calcul de la vitesse voulue}
          if QuelleVoie = VOIE_RAPIDE
          then VitesseVoulue := min(VITTESSE_VOIE_RAPIDE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_RAPIDE/4))
          else VitesseVoulue := min(VITTESSE_VOIE_LENTE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_LENTE/4));
          
      end else {ROUTE_0}
      begin
          if Pos.x > Position.x then Dist := Pos.x-Position.x -3*LONG_VOIT
          else Dist := Pos.x+TAILLE_MAP_X-Position.x -3*LONG_VOIT;

          if Dist > 0 then W := Vitesse+ACCELERATION else
          if Vit < Vitesse then W := Vit else W := Vitesse;

          if (Maville[(i+1) mod NB_BLOC_MAX_X,j].EtatFeux = 0)
          then Vx := Min(VitesseVoulue,W)
          else Vx := Max(VITESSE_MINIMALE,Min(Min(VitesseVoulue,W),2*((i+1)*TAILLE_BLOC_X-1.5*LONG_VOIT-Position.x)));

          Vy := 0;
          Vitesse := Vx;
          Direction := Arctan2(Vy,Vx);
          if QuelleVoie = VOIE_RAPIDE then VitesseVoulue := min(VITTESSE_VOIE_RAPIDE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_RAPIDE/4))
          else VitesseVoulue := min(VITTESSE_VOIE_LENTE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_LENTE/4));
      end;
end;

{*******************************************************************************
 *
 * Changement de vitesse d'une voiture sur les routes a sens indirect
 *
 * Parametres :
 *     la voiture appartient : au bloc de la ville (i,j)
 *                           : sur quelle route et sur quelle voie (QuelleRoute, QuelleVoie)
 *     la position et la vitesse de la voiture precedente (Pos, Vit)
 *
 *******************************************************************************}
procedure TGoodies.ChgVitIndirect(const i,j,QuelleRoute,QuelleVoie : byte; const Pos : TVecteur; Vit : real);
var Val,Dist,W : real;
begin
      if QuelleRoute = ROUTE_1 then
      begin
          if Pos.y < Position.y then Dist := Pos.y-Position.y + 3*LONG_VOIT
          else Dist := Pos.y - TAILLE_MAP_Y - Position.y + 3*LONG_VOIT;

          if Dist < 0 then W := -Vitesse-ACCELERATION else
          if Vit < Vitesse then W := -Vit else W := -Vitesse;

          if (Maville[i,j].EtatFeux = 2)
          then Vy := Max(-VitesseVoulue,W)
          else
          begin
              Val := j*TAILLE_BLOC_Y+ESPACE_CAREFOUR+1.5*LONG_VOIT-Position.y;
              if Val >= 0 then Val := Val - TAILLE_MAP_Y;
              Vy := Min(-VITESSE_MINIMALE,Max(Max(-VitesseVoulue,W),2*Val));
          end;

          Vx := 0;
          Vitesse := -Vy;
          Direction := 3*PI/2;
          if QuelleVoie = VOIE_RAPIDE then VitesseVoulue := min(VITTESSE_VOIE_RAPIDE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_RAPIDE/4))
          else VitesseVoulue := min(VITTESSE_VOIE_LENTE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_LENTE/4));
      end else {ROUTE_0}
      begin
          if Pos.x < Position.x then Dist := Pos.x-Position.x + 3*LONG_VOIT
          else Dist := Pos.x - TAILLE_MAP_X - Position.x + 3*LONG_VOIT;

          if Dist < 0 then W := -Vitesse-ACCELERATION else
          if Vit < Vitesse then W := -Vit else W := -Vitesse;

          if (Maville[i,j].EtatFeux = 0)
          then Vx := Max(-VitesseVoulue,W)
          else
          begin
              Val := i*TAILLE_BLOC_X+ESPACE_CAREFOUR+1.5*LONG_VOIT-Position.x;
              if Val >= 0 then Val := Val - TAILLE_MAP_X;
              Vx := Min(-VITESSE_MINIMALE,Max(Max(-VitesseVoulue,W),2*Val));
          end;

          Vy := 0;
          Vitesse := -Vx;
          Direction := PI;
          if QuelleVoie = VOIE_RAPIDE then VitesseVoulue := min(VITTESSE_VOIE_RAPIDE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_RAPIDE/4))
          else VitesseVoulue := min(VITTESSE_VOIE_LENTE,max(VitesseVoulue + (random(ACCELERATION+1)-ACCELERATION*5),3*VITTESSE_VOIE_LENTE/4));
      end;
end;

{*******************************************************************************
 *
 * Actualisation de la circulation sur les routes a sens direct
 *
 *******************************************************************************}
procedure TCirculation.ActuDirect(const i,j,QuelleRoute,QuelleVoie : integer);
var Voit,Temp,Voit1,tuture : TPGoodies;
    ieme,jeme : integer;
    Posi : TVecteur;
    Couple : TCouple;
    circu : TCirculation;
begin
   if QuelleRoute = ROUTE_1 then
   begin
         Voit := Tete;
         while (Voit <> NIL) do
         begin
             {On trouve la precedente}
             if Voit^.Prec <> NIL then Voit^.ChgVitDirect(i,j,QuelleRoute,QuelleVoie, Voit^.Prec^.Position, Voit^.Prec^.Vitesse)
             else
             begin
                  {Recherche de la voiture dans le bloc suivant}
                  jeme := ((j+1) mod  NB_BLOC_MAX_Y);
                  while Maville[i,jeme].TabCirculation[ROUTE_1,SENS_DIRECT,QuelleVoie].Queue = NIL
                  do jeme := ((jeme+1) mod  NB_BLOC_MAX_Y);

                  Temp := Maville[i,jeme].TabCirculation[ROUTE_1,SENS_DIRECT,QuelleVoie].Queue;
                  Voit^.ChgVitDirect(i,j,QuelleRoute, QuelleVoie, Temp^.Position, Temp^.Vitesse);
             end;
             Voit^.Actualise();

             {si la voiture sort du bloc, elle appartient a un autre}
             Voit1 := Voit^.next;
             Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
             if (Voit^.BlocY <> Couple.y) AND (Voit^.BlocX = Couple.x) then
             begin
                   tuture := Maville[Voit^.BlocX,Voit^.BlocY].TabCirculation[ROUTE_1,SENS_DIRECT,QuelleVoie].SupprimeTete();
                   with Maville[Couple.x,Couple.y].TabCirculation[ROUTE_1,SENS_DIRECT,QuelleVoie] do
                   begin
                       tuture^.BlocX := Couple.x;
                       tuture^.BlocY := Couple.y;
                       AjoutEnQueue(tuture);
                   end;
             end;
             Voit := Voit1;
         end;
   end else {ROUTE_0}
   begin
         Voit := Tete;
         while (Voit <> NIL) do
         begin
             {On trouve la precedente}
             if Voit^.Prec <> NIL then Voit^.ChgVitDirect(i,j,QuelleRoute,QuelleVoie,Voit^.Prec^.Position, Voit^.Prec^.Vitesse)
             else
             begin
                  {Recherche de la voiture dans le bloc suivant}
                  ieme := ((i+1) mod  NB_BLOC_MAX_X);
                  while Maville[ieme,j].TabCirculation[ROUTE_0,SENS_DIRECT,QuelleVoie].Queue = NIL
                  do ieme := ((ieme+1) mod  NB_BLOC_MAX_X);

                  Temp := Maville[ieme,j].TabCirculation[ROUTE_0,SENS_DIRECT,QuelleVoie].Queue;
                  Voit^.ChgVitDirect(i,j,QuelleRoute,QuelleVoie,Temp^.Position, Temp^.Vitesse);
             end;
             Voit^.Actualise();

             {si la voiture sort du bloc, elle appartient a un autre}
             Voit1 := Voit^.next;
             Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
             if (Voit^.BlocX <> Couple.x) AND (Voit^.BlocY = Couple.y) then
             begin
                   tuture := Maville[Voit^.BlocX,Voit^.BlocY].TabCirculation[ROUTE_0,SENS_DIRECT,QuelleVoie].SupprimeTete();
                   with Maville[Couple.x,Couple.y].TabCirculation[ROUTE_0,SENS_DIRECT,QuelleVoie] do
                   begin
                       tuture^.BlocX := Couple.x;
                       tuture^.BlocY := Couple.y;
                       AjoutEnQueue(tuture);
                   end;
             end;
             Voit := Voit1;
         end;
   end;
end;

{*******************************************************************************
 *
 *  Actualisation de la circulation sur les routes a sens indirect
 *
 *******************************************************************************}
constructor TCirculation.ActuIndirect(const i,j,QuelleRoute,QuelleVoie : integer);
var Voit,Temp,Voit1,tuture : TPGoodies;
    ieme,jeme : integer;
    Posi : TVecteur;
    Couple : TCouple;
    circu : TCirculation;
begin
   if QuelleRoute = ROUTE_1 then
   begin
         Voit := Tete;
         while (Voit <> NIL) do
         begin
             {On trouve la precedente}
             if Voit^.Prec <> NIL then Voit^.ChgVitIndirect(i,j,QuelleRoute,QuelleVoie,Voit^.Prec^.Position, Voit^.Prec^.Vitesse)
             else
             begin
                  {Recherche de la voiture dans le bloc suivant}
                  jeme := (j-1);
                  if jeme < 0 then jeme := jeme + NB_BLOC_MAX_Y;
                  while Maville[i,jeme].TabCirculation[ROUTE_1,SENS_INDIRECT,QuelleVoie].Queue = NIL
                  do begin
                     jeme := (jeme-1);
                     if jeme < 0 then jeme := jeme + NB_BLOC_MAX_Y;
                  end;

                  Temp := Maville[i,jeme].TabCirculation[ROUTE_1,SENS_INDIRECT,QuelleVoie].Queue;
                  Voit^.ChgVitIndirect(i,j,QuelleRoute,QuelleVoie,Temp^.Position, Temp^.Vitesse);
             end;
             Voit^.Actualise();

             {si la voiture sort du bloc, elle appartient a un autre}
             Voit1 := Voit^.next;
             Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
             if (Voit^.BlocY <> Couple.y) AND (Voit^.BlocX = Couple.x) then
             begin
                   tuture := Maville[Voit^.BlocX,Voit^.BlocY].TabCirculation[ROUTE_1,SENS_INDIRECT,QuelleVoie].SupprimeTete();
                   with Maville[Couple.x,Couple.y].TabCirculation[ROUTE_1,SENS_INDIRECT,QuelleVoie] do
                   begin
                       tuture^.BlocX := Couple.x;
                       tuture^.BlocY := Couple.y;
                       AjoutEnQueue(tuture);
                   end;
             end;
             Voit := Voit1;
         end;
   end else
   begin
      Voit := Tete;
         while (Voit <> NIL) do
         begin
             {On trouve la precedente}
             if Voit^.Prec <> NIL then Voit^.ChgVitIndirect(i,j,QuelleRoute,QuelleVoie,Voit^.Prec^.Position, Voit^.Prec^.Vitesse)
             else
             begin
                  {Recherche de la voiture dans le bloc suivant}
                  ieme := (i-1);
                  if ieme < 0 then ieme := ieme + NB_BLOC_MAX_X;
                  while Maville[ieme,j].TabCirculation[ROUTE_0,SENS_INDIRECT,QuelleVoie].Queue = NIL
                  do begin
                     ieme := (ieme-1);
                     if ieme < 0 then ieme := ieme + NB_BLOC_MAX_X;
                  end;

                  Temp := Maville[ieme,j].TabCirculation[ROUTE_0,SENS_INDIRECT,QuelleVoie].Queue;
                  Voit^.ChgVitIndirect(i,j, QuelleRoute,QuelleVoie,Temp^.Position, Temp^.Vitesse);
             end;
             Voit^.Actualise();

             {{si la voiture sort du bloc, elle appartient a un autre}
             Voit1 := Voit^.next;
             Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
             if (Voit^.BlocX <> Couple.x) AND (Voit^.BlocY = Couple.y) then
             begin
                   tuture := Maville[Voit^.BlocX,Voit^.BlocY].TabCirculation[ROUTE_0,SENS_INDIRECT,QuelleVoie].SupprimeTete();
                   with Maville[Couple.x,Couple.y].TabCirculation[ROUTE_0,SENS_INDIRECT,QuelleVoie] do
                   begin
                       tuture^.BlocX := Couple.x;
                       tuture^.BlocY := Couple.y;
                       AjoutEnQueue(tuture);
                   end;
             end;
             Voit := Voit1;
         end;
   end;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure TCirculation.Initialisation();
begin
  Queue := NIL;
  Tete  := NIL;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure TCirculation.Affiche();
var temp : TPgoodies; Triplet : TTriplet; P : TVecteur;
begin
    temp := Tete;
    while temp <> NIL do
    begin
      if MyFrust.SphereInFrustum(Temp^.Position.x,Temp^.Position.y,Temp^.Position.z,LONG_VOIT div 2)
      then Temp^.Affiche();
      Temp := Temp^.next;
    end;
end;

{*******************************************************************************
 *
 *  Liberation de la memoire
 *
 *******************************************************************************}
destructor TCirculation.DestroyCirculation();
var T : TPgoodies;
begin
   {while Tete <> NIL do
   begin
      T := Tete;
      T^.Destroy;
      Tete := Tete^.next;
   end;}
   while Tete <> NIL do SupprimeTete().destroy;
   Tete := NIL;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
constructor TCirculation.AjoutEnQueue(const Voit : TPGoodies);
begin
  if (tete = NIL) then
  begin
    Queue := Voit;
    tete := Voit;
  end else
  begin
     Queue^.next := Voit;
     Voit^.Prec := Queue;
     Queue := Voit;
  end;
  Queue^.next := NIL;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
function TCirculation.SupprimeTete() : TPGoodies;
var temp : TPGoodies;
begin
  if Tete <> NIL then
  begin
      if Tete^.Next <> NIL then
      begin
          Temp := Tete;
          Tete := Tete^.Next;
          Tete^.Prec := NIL;
      end else
      begin
        Temp := Tete;
        Tete := NIL;
        Queue := NIL;
      end;
      result := Temp;
  end else result := NIL;
end;

{*******************************************************************************
 *
 *  Initialise la circulation
 *
 *******************************************************************************}
procedure InitCirculation();
var i,j,k,l,m,nb : integer;
    Temp : TPGoodies;
begin
    ProgressBar.Etape := 4; Loading(0);
    for i := 0 to NB_BLOC_MAX_X-1 do //ieme ligne de la ville
    begin
        for j := 0 to NB_BLOC_MAX_Y-1 do  //jeme colonne de la ville
        begin
            //** ROUTE 0  SENS DIRECT
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].Initialisation();
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].Initialisation();

            //** ROUTE 0  SENS INDIRECT
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].Initialisation();
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].Initialisation();

            //** ROUTE 1 SENS DIRECT
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].Initialisation();
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].Initialisation();

            MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE].Initialisation();
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE] := TCirculation.Create;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].Initialisation();

            //VOIE LENTE
            for nb := 1 to NbVoitVoieLente do
            begin
            //** ROUTE 0
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[3].x+LONG_ROUTE_X-60*nb,
                                         Maville[i,j].Carrefour.TabPos[3].y+7,
                                         ROUTE_0,SENS_DIRECT, VOIE_LENTE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].AjoutEnQueue(Temp);

                //***
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[2].x+60*nb,
                                         Maville[i,j].Carrefour.TabPos[2].y-7,
                                         ROUTE_0,SENS_INDIRECT, VOIE_LENTE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].AjoutEnQueue(Temp);
            //** ROUTE 1
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[2].x-7,
                                         Maville[i,j].Carrefour.TabPos[2].y+LONG_ROUTE_Y-60*nb,
                                         ROUTE_1,SENS_DIRECT, VOIE_LENTE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].AjoutEnQueue(Temp);
                //***
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[1].x+7,
                                         Maville[i,j].Carrefour.TabPos[1].y+60*nb,
                                         ROUTE_1,SENS_INDIRECT, VOIE_LENTE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE].AjoutEnQueue(Temp);
            end;


          //VOIE RAPIDE
          for nb := 1 to NbVoitVoieRapide do  // nombre de voitures
            begin
            //** ROUTE 0
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[3].x+LONG_ROUTE_X-60*nb,
                                         Maville[i,j].Carrefour.TabPos[3].y+18,
                                         ROUTE_0, SENS_DIRECT, VOIE_RAPIDE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
                //***
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[2].x+60*nb,
                                         Maville[i,j].Carrefour.TabPos[2].y-18,
                                         ROUTE_0, SENS_INDIRECT, VOIE_RAPIDE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
            //** ROUTE 1
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[2].x-18,
                                         Maville[i,j].Carrefour.TabPos[2].y+LONG_ROUTE_Y-60*nb,
                                         ROUTE_1, SENS_DIRECT, VOIE_RAPIDE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
                //***
                new(Temp);
                Temp^ := TGoodies.Create(Maville[i,j].Carrefour.TabPos[1].x+18,
                                         Maville[i,j].Carrefour.TabPos[1].y+60*nb,
                                         ROUTE_1, SENS_INDIRECT, VOIE_RAPIDE,
                                         random(TabRepertVoit.long));
                Temp^.next := NIL;
                Temp^.Prec := NIL;
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
            end;
        end;
    end;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure ActuCircuDirect();
var i,j : integer;
begin
   for i := NB_BLOC_MAX_X-1 downto 0 do
   begin
        for j := 0 to NB_BLOC_MAX_Y-1 do
        begin
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].ActuDirect(i,j,ROUTE_0,VOIE_LENTE);
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].ActuDirect(i,j,ROUTE_1,VOIE_LENTE);
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].ActuDirect(i,j,ROUTE_0,VOIE_RAPIDE);
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].ActuDirect(i,j,ROUTE_1,VOIE_RAPIDE);
        end;
  end;
end;


{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure ActuCircuIndirect();
var i,j : integer;
begin
   for i := 0 to NB_BLOC_MAX_X-1 do
   begin
        for j := 0 to NB_BLOC_MAX_Y-1 do
        begin
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].ActuIndirect(i,j,ROUTE_0,VOIE_LENTE);
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_LENTE].ActuIndirect(i,j,ROUTE_1,VOIE_LENTE);
                MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].ActuIndirect(i,j,ROUTE_0,VOIE_RAPIDE);
                MaVille[i,j].TabCirculation[ROUTE_1,SENS_INDIRECT,VOIE_RAPIDE].ActuIndirect(i,j,ROUTE_1,VOIE_RAPIDE);
        end;
  end;
end;

end.