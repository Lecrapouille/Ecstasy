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
unit UCirculation;

interface

uses UVoiture,
     UMath,
     UFrustum,
     Windows,
     UTypege,
     //Urepere,
     math;

{**************************  TPVoiture  ****************************************
 *
 * Defini les voitures neutres qui circulent dans la ville. Ils heritent
 * du type TDynamiqueVoiture, mais ils ont plus un pointeur sur la voiture
 * suivante pour reguler leur vitesse.
 *
 *******************************************************************************}
Type TPVoiture = ^TVoiture;
TVoiture = class(TDynamiqueVoiture)
public
   VitesseMaximale : real;   next : TPVoiture; {Pointeur sur la voiture suivante}
   Prec : TPVoiture; {Pointeur sur la voiture precedente}
private
   BlocX,BlocY : byte; {Les numeros du bloc auquel la voiture appartient}
   procedure Actualise(visible: boolean);
   constructor Create(const x,y : real; const LaRoute, LeSens, LaVoie, ident : byte);
   procedure ChgVitDirect(const i, j, QuelleRoute, QuelleVoie : byte;
                          const distance, Vit : real);
   procedure ChgVitIndirect(const i, j, QuelleRoute, QuelleVoie : byte;
                            const distance, Vit : real);
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
 *  function  SupprimeTete() : TPVoiture;
 *               La voiture TETE est supprimee, la suivante devient leader.
 *               La voiture TETE est ajoutee dans une autre file grace a la
 *               procedure AjoutEnQueue().
 *               La fct retourne la voiture supprimee.
 *
 *******************************************************************************}
TCirculation = class(Tobject)
   Tete : TPVoiture;
   Queue : TPVoiture;
   destructor  DestroyCirculation();
   procedure   Affiche(Tx, Ty : real);
   procedure   ActualiseIndirect(const i, j, QuelleRoute, QuelleVoie : byte);
   procedure   ActualiseDirect(const i, j, QuelleRoute, QuelleVoie : byte);
private
   function    SupprimeTete() : TPVoiture;
   constructor AjoutEnQueue(const voit : TPVoiture);
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

implementation
uses UAltitude, UCaractere, ULancement, UVille;

{*******************************************************************************
 *
 * Creation -- initialisation de la voiture
 *
 *******************************************************************************}
constructor TVoiture.Create(const x,y : real; const LaRoute, LeSens, LaVoie, ident : byte);
begin
   inherited Create(x,y,ident);
   BlocX := QuellePartition(Position.x,Position.y).x;
   BlocY := QuellePartition(Position.x,Position.y).y;
   Vitesse := Param.VitesseMax;

   if LeSens = SENS_DIRECT then
   begin
      VitesseMaximale := Param.VitesseMax;
      Vx := Vitesse;
      Vy := 0;
      Direction := 0;
   end else
   begin
      VitesseMaximale := Param.VitesseMax;
      Vx := -Vitesse;
      Vy := 0;
      Direction := PI;
   end;
end;

procedure TVoiture.Actualise(visible: boolean);
begin
  //if visible
  //then
  ActualiseDynamique()
  //else AucuneDynamique()
  ;
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
procedure TVoiture.ChgVitDirect(const i, j, QuelleRoute, QuelleVoie : byte;
                                const distance, Vit : real);
var
   Dist, W, A : real;
begin
   A := ACCELERATION;// * deltaTime;
   if QuelleRoute = ROUTE_1 then
   begin
      {Si la voiture est trop pres de la suivante elle prend la meme vitesse}
      Dist := Distance - ESPACE_SECURITE;
      if Dist > 0 then W := Vitesse + A else
         if Vit < Vitesse then W := Vit else W := Vitesse;
      Vy := Min(VitesseMaximale, W);

      {Si le feu est a l'orange ou au rouge, la voiture ralentit}
      if Maville[i, (j+1) mod NB_BLOC_MAX_Y].EtatFeux <> ETAT_FEUX_ROUGE_VERT then
      begin
         W := (j + 1) * TAILLE_BLOC_Y - 0.75*ESPACE_SECURITE + LONG_VOIT - Position.y; // abs
         Vy := Max(0, Min(Vy, 2 * W));
      end;

      Vx := 0;
      Vitesse := Vy;
      Direction := PI/2;
   end else {ROUTE_0}
   begin
      {Si la voiture est trop pres de la suivante elle prend la meme vitesse}
      Dist := Distance - ESPACE_SECURITE;
      if Dist > 0 then W := Vitesse + A else  // TODO: W := min(vitesseDesiree, V+A)
         if Vit < Vitesse then W := Vit else W := Vitesse;  // TODO: vitesseDesiree := W
      Vx := Min(VitesseMaximale, W);

      {Si le feu est a l'orange ou au rouge, la voiture ralentit}
      if Maville[(i+1) mod NB_BLOC_MAX_X, j].EtatFeux <> ETAT_FEUX_VERT_ROUGE then
      begin
         W := (i + 1) * TAILLE_BLOC_X - ESPACE_SECURITE + LONG_VOIT - Position.x; // FIXME
         Vx := Max(0, Min(Vx, 2 * W));
      end;

      Vitesse := Vx;
      Vy := 0;
      Direction := 0; {:= Arctan2(Vy,Vx); }
   end;

   {Calcul de la vitesse desiree}
   if QuelleVoie = VOIE_RAPIDE
   then VitesseMaximale := min(VITTESSE_VOIE_RAPIDE,max(VitesseMaximale + (random(round(A)+1)-A*5),3*VITTESSE_VOIE_RAPIDE/4))
   else VitesseMaximale := min(VITTESSE_VOIE_LENTE,max(VitesseMaximale + (random(round(A)+1)-A*5),3*VITTESSE_VOIE_LENTE/4));
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
procedure TVoiture.ChgVitIndirect(const i, j, QuelleRoute, QuelleVoie : byte;
                                  const distance, Vit : real);
var
   Dist, W, A : real;
begin
   A := ACCELERATION;// * deltaTime;
   if QuelleRoute = ROUTE_1 then
   begin
      {Si la voiture est trop pres de la suivante elle prend la meme vitesse}
      Dist := Distance - ESPACE_SECURITE;
      if Dist > 0 then W := Vitesse + A else
         if Vit < Vitesse then W := Vit else W := Vitesse;
      Vy := Min(VitesseMaximale, W);

      if Maville[i, j].EtatFeux <> 2 then
      begin
         W := abs(Position.y - j * TAILLE_BLOC_Y - ESPACE_CAREFOUR - 0.75*ESPACE_SECURITE + LONG_VOIT);
         Vy := Max(0, Min(Vy, 2 * W));
      end;

      Vitesse := Vy;
      Vy := -Vy;
      Vx := 0;
      Direction := 3*PI/2; {:= Arctan2(Vy, Vx);}
   end
   else {ROUTE_0}
   begin
      {Si la voiture est trop pres de la suivante elle prend la meme vitesse}
      Dist := Distance - ESPACE_SECURITE;
      if Dist > 0 then W := Vitesse + A else
         if Vit < Vitesse then W := Vit else W := Vitesse;
      Vx := Min(VitesseMaximale, W);

      {Si le feu est a l'orange ou au rouge, la voiture ralentit}
      if Maville[i, j].EtatFeux <> ETAT_FEUX_VERT_ROUGE then
      begin
         W := abs(Position.x - i * TAILLE_BLOC_X - ESPACE_CAREFOUR - ESPACE_SECURITE + LONG_VOIT);
         Vx := Max(0, Min(Vx, 2 * W));
      end;

      Vitesse := Vx;
      Vx := -Vx;
      Vy := 0;
      Direction := PI; {:= Arctan2(Vy, Vx);}
   end;
   
   {Calcul de la vitesse desiree}
   if QuelleVoie = VOIE_RAPIDE
   then VitesseMaximale := min(VITTESSE_VOIE_RAPIDE,max(VitesseMaximale + (random(round(A)+1)-A*5),3*VITTESSE_VOIE_RAPIDE/4))
   else VitesseMaximale := min(VITTESSE_VOIE_LENTE,max(VitesseMaximale + (random(round(A)+1)-A*5),3*VITTESSE_VOIE_LENTE/4));

end;

{*******************************************************************************
 *
 * Actualisation de la circulation sur les routes a sens direct
 *
 *******************************************************************************}
procedure TCirculation.ActualiseDirect(const i, j, QuelleRoute, QuelleVoie : byte);
var
   Voit,Temp,Voit1 : TPVoiture;
   ieme, jeme : integer;
   Posi : TVecteur;
   Couple : TCouple;
   circu : TCirculation;
   distance : real;
begin
   if QuelleRoute = ROUTE_1 then
   begin
      Voit := Tete;
      while (Voit <> NIL) do {A tester}
      begin
         {Si Voiture de tete}
         if Voit^.Prec = NIL then
         begin
            {Recherche la derniere voiture dans le bloc suivant. Ok si la voiture se trouve elle meme}
            jeme := (j+1) mod NB_BLOC_MAX_Y;
            while Maville[i, jeme].TabCirculation[ROUTE_1, SENS_DIRECT, QuelleVoie].Queue = NIL
            do begin
               jeme := (jeme + 1) mod NB_BLOC_MAX_Y;
            end;
            Temp := Maville[i, jeme].TabCirculation[ROUTE_1, SENS_DIRECT, QuelleVoie].Queue;

            distance := Temp^.Position.y - Voit^.Position.y;
            if Voit^.Position.y >= Temp^.Position.y
            then distance := distance + TAILLE_MAP_Y;  // FIXME +0 distance de securite
         end
         else {Toutes les autres voitures sauf celle de tete}
         begin
            Temp :=  Voit^.Prec;
            distance := Temp^.Position.y - Voit^.Position.y;  // FIXME +random comme distance de securite
         end;

         Voit^.ChgVitDirect(i, j, ROUTE_1, QuelleVoie, distance, Temp^.Vitesse);
         Voit^.Actualise(MaVille[i, j].Visible);

         {Si la voiture sort du bloc, elle appartient a l'autre bloc}
         Voit1 := Voit^.next;
         Couple := QuellePartition(Voit^.Position.x, Voit^.Position.y);
         if Voit^.BlocY <> Couple.y then
         begin
            Temp := Maville[Voit^.BlocX, Voit^.BlocY].TabCirculation[ROUTE_1, SENS_DIRECT, QuelleVoie].SupprimeTete();
            Temp^.BlocY := Couple.y;
            Maville[Couple.x, Couple.y].TabCirculation[ROUTE_1, SENS_DIRECT, QuelleVoie].AjoutEnQueue(Temp);
         end;
         Voit := Voit1;
      end;
   end else {ROUTE_0}
   begin
      Voit := Tete;
      while (Voit <> NIL) do
      begin
         {Si Voiture de tete}
         if Voit^.Prec = NIL then
         begin
            //DessinerRepere2(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z);

            {Recherche la derniere voiture dans le bloc suivant. Ok si la voiture se trouve elle meme}
            ieme := (i+1) mod NB_BLOC_MAX_X;
            while Maville[ieme, j].TabCirculation[ROUTE_0, SENS_DIRECT, QuelleVoie].Queue = NIL
            do begin
              ieme := (ieme + 1) mod NB_BLOC_MAX_X;
            end;
            Temp := Maville[ieme, j].TabCirculation[ROUTE_0, SENS_DIRECT, QuelleVoie].Queue;

            distance := Temp^.Position.x - Voit^.Position.x;
            if Voit^.Position.x >= Temp^.Position.x
            then distance := distance + TAILLE_MAP_X;  // FIXME +0 distance de securite

            {DessinerRepere(Temp^.Position.x, Temp^.Position.y, Temp^.Position.z);
            DessinerLigne2(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z,
                           Voit^.Position.x + distance, Voit^.Position.y, Voit^.Position.z);}
         end
         else {Toutes les autres voitures sauf celle de tete}
         begin
            Temp :=  Voit^.Prec;
            distance := Temp^.Position.x - Voit^.Position.x;  // FIXME +random comme distance de securite
            //DessinerLigne(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z, Voit^.Position.x + distance, Voit^.Position.y, Voit^.Position.z);
         end;

         Voit^.ChgVitDirect(i, j, ROUTE_0, QuelleVoie, distance, Temp^.Vitesse);
         Voit^.Actualise(MaVille[i,j].Visible);

         {Si la voiture sort du bloc, elle appartient a l'autre bloc}
         Voit1 := Voit^.next;
         Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
         if Voit^.BlocX <> Couple.x then
         begin
            Temp := Maville[Voit^.BlocX, Voit^.BlocY].TabCirculation[ROUTE_0, SENS_DIRECT, QuelleVoie].SupprimeTete();
            Temp^.BlocX := Couple.x;
            Maville[Couple.x, Couple.y].TabCirculation[ROUTE_0, SENS_DIRECT, QuelleVoie].AjoutEnQueue(Temp);
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
procedure TCirculation.ActualiseIndirect(const i, j, QuelleRoute, QuelleVoie : byte);
var
   Voit,Temp,Voit1 : TPVoiture;
   ieme,jeme : integer;
   distance: real;
   Couple : TCouple;
   circu : TCirculation;
begin
   if QuelleRoute = ROUTE_1 then
   begin
      Voit := Tete;
      while (Voit <> NIL) do
      begin
         {Si Voiture de tete}
         if Voit^.Prec = NIL then
         begin
            {Recherche la derniere voiture dans le bloc suivant. Ok si la voiture se trouve elle meme}
            jeme := j-1; if jeme < 0 then jeme := NB_BLOC_MAX_Y - 1;
            while Maville[i, jeme].TabCirculation[ROUTE_1, SENS_INDIRECT, QuelleVoie].Queue = NIL
            do begin
               jeme := jeme - 1;
               if jeme < 0 then jeme := NB_BLOC_MAX_Y - 1;
            end;
            Temp := Maville[i, jeme].TabCirculation[ROUTE_1, SENS_INDIRECT, QuelleVoie].Queue;

            if Temp^.Position.y >= Voit^.Position.y
            then distance := Temp^.Position.y - Voit^.Position.y + TAILLE_MAP_Y
            else distance := Voit^.Position.y - Temp^.Position.y;
         end
         else {Toutes les autres voitures sauf celle de tete}
         begin
            Temp :=  Voit^.Prec;
            distance := Voit^.Position.y - Temp^.Position.y;
         end;

         {Nouvelle vitesse}
         Voit^.ChgVitIndirect(i, j, ROUTE_1, QuelleVoie, distance, Temp^.Vitesse);
         Voit^.Actualise(MaVille[i, j].Visible);

         {Si la voiture sort du bloc, elle appartient a l'autre bloc}
         Voit1 := Voit^.next;
         Couple := QuellePartition(Voit^.Position.x, Voit^.Position.y);
         if Voit^.BlocY <> Couple.y then
         begin
            Temp := Maville[Voit^.BlocX, Voit^.BlocY].TabCirculation[ROUTE_1, SENS_INDIRECT, QuelleVoie].SupprimeTete();
            Temp^.BlocY := Couple.y;
            Maville[Couple.x, Couple.y].TabCirculation[ROUTE_1, SENS_INDIRECT, QuelleVoie].AjoutEnQueue(Temp);
         end;
         Voit := Voit1;
      end;
   end else  {ROUTE_0}
   begin
      Voit := Tete;
      while (Voit <> NIL) do
      begin
         {Si Voiture de tete}
         if Voit^.Prec = NIL then
         begin
            //DessinerRepere2(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z);

            {Recherche la derniere voiture dans le bloc suivant. Ok si la voiture se trouve elle meme}
            ieme := (i-1); if ieme < 0 then ieme := NB_BLOC_MAX_X - 1;
            while Maville[ieme,j].TabCirculation[ROUTE_0,SENS_INDIRECT,QuelleVoie].Queue = NIL
            do begin
               ieme := (ieme-1);
               if ieme < 0 then ieme := NB_BLOC_MAX_X - 1;
            end;
            Temp := Maville[ieme, j].TabCirculation[ROUTE_0, SENS_INDIRECT, QuelleVoie].Queue;

            if Temp^.Position.x >= Voit^.Position.x
            then distance := Temp^.Position.x - Voit^.Position.x + TAILLE_MAP_X
            else distance := Voit^.Position.x - Temp^.Position.x;

            {DessinerRepere(Temp^.Position.x, Temp^.Position.y, Temp^.Position.z);
            DessinerLigne2(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z,
                           Voit^.Position.x + distance, Voit^.Position.y, Voit^.Position.z);}
         end
         else {Toutes les autres voitures sauf celle de tete}
         begin
            Temp :=  Voit^.Prec;
            distance := Voit^.Position.x - Temp^.Position.x;
            {DessinerLigne(Voit^.Position.x, Voit^.Position.y, Voit^.Position.z,
                          Voit^.Position.x + distance, Voit^.Position.y, Voit^.Position.z);}
         end;

         {Nouvelle vitesse}
         Voit^.ChgVitIndirect(i, j, ROUTE_0, QuelleVoie, distance, Temp^.Vitesse);
         Voit^.Actualise(MaVille[i,j].Visible);

         {Si la voiture sort du bloc, elle appartient a un autre}
         Voit1 := Voit^.next;
         Couple := QuellePartition(Voit^.Position.x,Voit^.Position.y);
         if Voit^.BlocX <> Couple.x then
         begin
            Temp := Maville[Voit^.BlocX, Voit^.BlocY].TabCirculation[ROUTE_0, SENS_INDIRECT, QuelleVoie].SupprimeTete();
            Temp^.BlocX := Couple.x;
            Maville[Couple.x, Couple.y].TabCirculation[ROUTE_0, SENS_INDIRECT, QuelleVoie].AjoutEnQueue(Temp);
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
procedure TCirculation.Affiche(Tx, Ty : real);
var temp : TPVoiture;
begin
   temp := Tete;
   while temp <> NIL do
   begin
      if MyFrust.SphereInFrustum(Temp^.Position.x + Tx,
                                 Temp^.Position.y + Ty,
                                 Temp^.Position.z,LONG_VOIT div 2)
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
begin
   while Tete <> NIL do SupprimeTete().destroy;
   Tete := NIL;
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
constructor TCirculation.AjoutEnQueue(const Voit : TPVoiture);
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
function TCirculation.SupprimeTete() : TPVoiture;
var 
   temp : TPVoiture;
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
var
   i, j, k, l, m, nb : integer;
   Temp : TPVoiture;
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
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[3].x+LONG_ROUTE_X-60*nb,
                                     Maville[i,j].Carrefour.TabPos[3].y+7,
                                     ROUTE_0,SENS_DIRECT, VOIE_LENTE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_LENTE].AjoutEnQueue(Temp);

            //***
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[2].x+60*nb,
                                     Maville[i,j].Carrefour.TabPos[2].y-7,
                                     ROUTE_0,SENS_INDIRECT, VOIE_LENTE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_LENTE].AjoutEnQueue(Temp);
            //** ROUTE 1
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[2].x-7,
                                     Maville[i,j].Carrefour.TabPos[2].y+LONG_ROUTE_Y-60*nb,
                                     ROUTE_1,SENS_DIRECT, VOIE_LENTE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_LENTE].AjoutEnQueue(Temp);
            //***
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[1].x+7,
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
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[3].x+LONG_ROUTE_X-60*nb,
                                     Maville[i,j].Carrefour.TabPos[3].y+18,
                                     ROUTE_0, SENS_DIRECT, VOIE_RAPIDE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_DIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
            //***
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[2].x+60*nb,
                                     Maville[i,j].Carrefour.TabPos[2].y-18,
                                     ROUTE_0, SENS_INDIRECT, VOIE_RAPIDE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_0,SENS_INDIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
            //** ROUTE 1
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[2].x-18,
                                     Maville[i,j].Carrefour.TabPos[2].y+LONG_ROUTE_Y-60*nb,
                                     ROUTE_1, SENS_DIRECT, VOIE_RAPIDE,
                                     random(TabRepertVoit.long));
            Temp^.next := NIL;
            Temp^.Prec := NIL;
            MaVille[i,j].TabCirculation[ROUTE_1,SENS_DIRECT,VOIE_RAPIDE].AjoutEnQueue(Temp);
            //***
            new(Temp);
            Temp^ := TVoiture.Create(Maville[i,j].Carrefour.TabPos[1].x+18,
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

end.
