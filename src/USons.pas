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
unit USons;

interface
uses
   Windows,
   sysutils,
   MMsystem,
   DDirectSound,
   DSound,
   ULancement,
   UTypege,
   Wave;

const
   NBSOUND = 8;

   ONCE = 0;
   LOOP = 1;

   BOOM_0= 0;
   PLOUF = 2;
   CIRCU = 3;
   PNEU  = 4;
   BOOM_1= 5;
   MOTEUR_IDLE=6;
   MOTEUR_LENT=7;
   MOTEUR_MOY=8;
   MOTEUR_RAPIDE=1;

var
   // variable pour le son.
   DS: TDirectSound;
   DSB : array [0..NBSOUND] of  TDirectSoundBuffer; //sons

   procedure InitSound(var DSB : array of  TDirectSoundBuffer);
   procedure PlaySound(i: integer; id : byte);
   procedure StopAllSounds();
   procedure StopSound(i : integer);
   procedure JouerEnBoucle();
   procedure FaitDuBruit();


implementation
uses UAltitude, UJoueur;

//------------------------- DIRECT SOUND -----------------------------------------------//

function NewDirectSoundBuffer( FileName: String;
                               var pwfx: PWAVEFORMATEX ): TDirectSoundBuffer;
var
   bd, bd2: Pointer;
   dsbd: TDSBufferDesc;
   Len, Len2: DWord;
   pbData: Pointer;
   cbSize: Longint;
begin
   {Creation d'un buffer de sons}
   WaveLoadFile( Filename, cbSize, pwfx, pbData );
   try
      try
         ZeroMemory( @dsbd, sizeof(dsbd) );
         dsbd.dwSize := sizeof(TDSBUFFERDESC);
         dsbd.dwFlags := DSBCAPS_STATIC;
         dsbd.dwBufferBytes := cbSize;
         dsbd.lpwfxFormat := pwfx;

         Result := TDirectSoundBuffer.Create( DS, dsbd );

         Result.Lock( 0, cbSize, bd, Len, bd2, Len2, 0 );
         try
            CopyMemory( bd, pbData, cbSize );
         finally
            Result.Unlock( bd, cbSize, nil, 0 );
         end;
      except
         on EDirectSoundError do
         begin
            FreeMem( pwfx );
            Result.Free;
            raise;
         end;
      end;
   finally
      FreeMem( pbData );
   end;
end;

//----------------------------------------------------------------------------//
procedure InitSound(var DSB : array of  TDirectSoundBuffer);
var
   cnt : integer;
   pwfx: array [0..NBSOUND] of PWAVEFORMATEX;
begin
   if params.son then
   begin
      ProgressBar.Etape := 3; loading(0);
      DS := TDirectSound.Create( nil, 0 );
      DS.SetCooperativeLevel( h_wnd, DSSCL_NORMAL);
      for Cnt := 0 to NBSOUND do
      begin
         DSB[Cnt] := NewDirectSoundBuffer('Data/Sons/Son' + inttostr(Cnt) + '.wav',
                                          pwfx[Cnt]);
      end;
      loading(1);
   end;
end;

procedure PlaySound(i : integer; id : Byte);
begin
   if params.son then DSB[i].play(id);
end;

procedure StopAllSounds();
var i: integer;
begin
   if params.son then
   begin
      for i := 0 to NBSOUND do DSB[i].Stop;
      DS.Free;
   end;
end;

procedure StopSound(i : integer);
begin
   if params.son then DSB[i].Stop;
end;

procedure JouerEnBoucle();
begin
   if params.son then
   begin
      Playsound(CIRCU,LOOP);
   end;
end;

procedure FaitDuBruit();
var VM : real;
begin
   if params.son then
   begin
      if (Joueur.Position.z > -22) AND (Joueur.Position.z < -20) then PlaySound(PLOUF,ONCE);
      if (ColliImmeuble) AND (not OldColliImmeuble) then PlaySound(BOOM_0,ONCE);
      if (ColliVoiture)  AND (not OldColliVoiture) then PlaySound(BOOM_1,ONCE);

      if (abs(OldTheta - Joueur.Theta) >= 0.3) AND (Joueur.Vitesse >= 200) then PlaySound(PNEU,LOOP)
      else StopSound(PNEU);


      VM := trunc(Joueur.Param.VitesseMax / (3*2));
      if (Joueur.Vitesse >= -11) AND (Joueur.Vitesse <= 11) then
      begin
         StopSound(MOTEUR_LENT);
         StopSound(MOTEUR_MOY);
         StopSound(MOTEUR_RAPIDE);
         Playsound(MOTEUR_IDLE,LOOP);
      end
      else if (Joueur.Vitesse > VM-11) AND (Joueur.Vitesse <= 2*VM-11) then
      begin
         StopSound(MOTEUR_IDLE);
         StopSound(MOTEUR_MOY);
         StopSound(MOTEUR_RAPIDE);
         Playsound(MOTEUR_LENT,LOOP);
      end
      else if (Joueur.Vitesse > 2*VM-11) AND (Joueur.Vitesse <= 3*VM-11) then
      begin
         StopSound(MOTEUR_IDLE);
         StopSound(MOTEUR_LENT);
         StopSound(MOTEUR_RAPIDE);
         Playsound(MOTEUR_MOY,LOOP);
      end
      else if (Joueur.Vitesse > 3*VM-11) then
      begin
         StopSound(MOTEUR_IDLE);
         StopSound(MOTEUR_LENT);
         StopSound(MOTEUR_MOY);
         Playsound(MOTEUR_RAPIDE,LOOP);
      end
      else //marche arriere
      begin
         StopSound(MOTEUR_IDLE);
         StopSound(MOTEUR_MOY);
         StopSound(MOTEUR_RAPIDE);
         Playsound(MOTEUR_LENT,LOOP);
      end;
   end;
end;

end.
