{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : https://github.com/Lecrapouille/Ecstasy
 * Date    : 02 Juin 2003
 * Changes : 03 Octobre 2017
 * License : GPL-3.0
 *
 *******************************************************************************}
unit UBoucledejeu;

interface
USES
   Windows,
   SysUtils,
   Messages,
   Opengl,
   UTypege,
   UMath,
   URepere,
   ULoader,
   UCaractere,
   UChargement,
   UClavierSouris,
   UCirculation,
   UJoueur,
   UTerrain,
   UFrustum,
   UVille,
   math,
   USons,
   DDirectSound,
   UParticules,
   UAltitude,
   ULancement,
   UTransparence;

var
   finished : Boolean;

   function WinMain(hInstance : HINST; hPrevInstance : HINST;
                    lpCmdLine : PChar; nCmdShow : Integer;
                    param : T_param) : Integer; stdcall;

implementation
uses Forms,UInterfa;

procedure Meteo();
begin
   if not(params.fog) then
   begin
      if Params.Nuit then glClearColor(0.0,0.0,0.0,1)
      else glClearColor(0.5,0.5,0.6,1)
   end
   else if Camera.position.z < -19 then
   begin
      glFogfv( GL_FOG_COLOR, @FogCouleur_2);
      glDisable(GL_CULL_FACE);
      glClearColor(FogCouleur_2[0], FogCouleur_2[1], FogCouleur_2[2], FogCouleur_2[3]);
   end else
   begin
      glFogfv( GL_FOG_COLOR, @FogCouleur_1);
      glClearColor(FogCouleur_1[0], FogCouleur_1[1], FogCouleur_1[2], FogCouleur_1[3]);
   end;
   Systeme.Actualise(Systeme.ListeParticule);
   if Params.Pluie then Pluie.Actualise(Joueur.Position, Pluie.ListeParticule);
end;

procedure BoucleDeJeu(Time: glFloat);
var
   Poll : glFloat;
begin
   Poll := Time - LastUpdate;
   if Poll > MS_PAR_IMAGE then
   begin
      {Vidage du contenu situé à l'écran et fog}
      glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);

      ActualiseVille();

      {Definition des actions}
      UtilisationDuClavier({Joueur,Camera,}Keys, finished);
      BougeSouris(XMouse, YMouse);
      Joueur.Actualise();

      Joueur.afficheVoiture();
      Myfrust.CalculateFrustum;

      Meteo();
      AfficheVille();

      {OpenGL}
      SwapBuffers(h_DC);

      {FPS mis a jour dans ULancement.pas}
      Inc(FPSCount);

      deltaTime := Poll;
      LastUpdate := Time;
   end;
end;

{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer;
                 param : T_param) : Integer; stdcall;
var
   msg : TMsg;
   i : integer;
   DemoStart, LastTime : DWord;  // millisecondes
begin
   {Attention ne rien mettre avant 'if not glCreateWnd(param) then ...'}
   // Perform application initialization:
   if not glCreateWnd(param) then
   begin
      Result := 0;
      Exit;
   end;

   {Initialisation}
   finished := false;
   chargement(Keys);

   DemoStart := GetTickCount();
   ElapsedTime := 0;
   LastUpdate := 0;

   {Boucle principale du jeu}
   while not finished do
   begin
      if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Check if there is a message for this window
      begin
         if (msg.message = WM_QUIT) then     // If WM_QUIT message received then we are done
            finished := True
         else
         begin                               // Else translate and dispatch the message to this window
            TranslateMessage(msg);
            DispatchMessage(msg);
         end;
      end else
      begin
         {Calcul du pas en temps}
         LastTime := ElapsedTime;
         ElapsedTime := GetTickCount() - DemoStart;
         ElapsedTime := (LastTime + ElapsedTime) DIV 2;
         BoucleDeJeu(ElapsedTime / 1000.0); // millisecondes --> secondes
      end;
   end;
   finished := False;

   Myfrust.Destroy();
   Joueur.Destroy();
   DestroyVille();

   //liberer memoire liste d'affichage
   glDeleteLists(feurouge_liste.liste,1);
   glDeleteLists(pont_liste.liste,1);
   glDeleteLists(Lerepere,1);
   glDeleteLists(Ville_liste,1);
   glDeleteLists(Terrain,1);

   //liste d'affichage des voitures
   for i := 1 to TabRepertVoit.long do
   begin
      glDeleteLists(TabRepertVoit.elt[i-1].GLRoue.liste,1);
      glDeleteLists(TabRepertVoit.elt[i-1].GLCarcasse.liste,1);
   end;

   //liste d'affichage des immeubles
   for i := 0 to NB_TYPE_MAISON do glDeleteLists(TabImeublesObjt[i].Liste,1);

   //Particules
   for i := 0 to 11 do glDeleteLists(TabPart[i],1);

   LibererMasque();
   KillFont();

   // Arret du son
   StopAllSounds();

   Form1.FormStyle := fsStayOnTop;
   // PostQuitMessage(0);
   glKillWnd(param.Width, param.Height, param.FullScreen);
   Result := msg.wParam;
end;

end.
