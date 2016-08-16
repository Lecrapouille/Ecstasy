unit UClavierSouris;

interface

uses Windows,
     UTypege,
     UJoueur,
     math,
     OpenGl;

procedure UtilisationDuClavier(var Keys : array of boolean; var finished : boolean);
procedure BougeSouris(XMouse, YMouse : integer);

implementation

procedure BougeSouris(XMouse, YMouse : integer);
var mps : TPoint; px, py : integer;
begin
  px := params.Width div 2;
  py := params.Height div 2;
  GetCursorPos(mps);
  SetCursorPos(px,py);
  Joueur.Theta := Min(Max(Joueur.Theta-((mps.x-px)/100*MOUSE_SPEED),-0.75),0.75);
end;

procedure UtilisationDuClavier(var Keys : array of boolean; var finished : boolean);
var i : integer;
begin
   if (keys[VK_ESCAPE]) then finished := True else
   if (keys[VK_TAB]) and (not keysold[VK_TAB]) AND (abs(Joueur.Vitesse) <= 11) then
   begin
       Joueur.MarcheArriere := not(Joueur.MarcheArriere);
       thetaCamera := trunc(thetaCamera+DegToRad(180)) mod 360;
   end;
   if (keys[VK_F1]) and (not keysold[VK_F1]) then Camera.id := (Camera.id+1) mod (NB_VUE_CAMERA+1)
   else
   begin
       {deplacement du joueur}
       if keys[VK_RIGHT] then Joueur.Theta := Max(Joueur.Theta-0.06,-0.75);
       if keys[VK_LEFT]  then Joueur.Theta := Min(Joueur.Theta+0.06,0.75);
       if keys[VK_UP]    then
       begin
          if Joueur.MarcheArriere then Joueur.vitesse := Max(Joueur.vitesse-2.5,-60)
          else Joueur.vitesse := Min(Joueur.vitesse+10,Joueur.Param.VitesseMax)
       end;
       if keys[VK_DOWN]  then
       begin
         if Joueur.MarcheArriere then Joueur.vitesse := Min(Joueur.vitesse+2.5,VITESSE_MINIMALE)
         else Joueur.vitesse := Max(Joueur.vitesse-10,VITESSE_MINIMALE);
       end;

       {Decalage de la camera}
       if keys[VK_NUMPAD8] then DistanceCamera := DistanceCamera + 1
       else if keys[VK_NUMPAD2] then DistanceCamera := DistanceCamera - 1
       else if keys[VK_NUMPAD4] then thetaCamera := thetaCamera - 0.03
       else if keys[VK_NUMPAD6] then thetaCamera := thetaCamera + 0.03;
   end;

   if Joueur.vitesse = 0 then Joueur.vitesse := VITESSE_MINIMALE;
   for i:=0 to 255 do
   Keysold[i]:=Keys[i];
   OldColliImmeuble := ColliImmeuble;
   OldColliVoiture  := ColliVoiture;
end;

end.
