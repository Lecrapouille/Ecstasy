program Ecstasy;

uses
  Forms,
  UInterfa in 'UInterfa.pas' {Form1},
  ULancement in 'ULancement.pas',
  UCaractere in 'UCaractere.pas',
  UChargement in 'UChargement.pas',
  URepere in 'URepere.pas',
  UTypege in 'UTypege.pas',
  ULoader in 'ULoader.pas',
  UMath in 'UMath.pas',
  UTerrain in 'UTerrain.pas',
  UBoucledejeu in 'UBoucledejeu.pas',
  UClavierSouris in 'UClavierSouris.pas',
  UVille in 'UVille.pas',
  UFrustum in 'UFrustum.pas',
  UVoiture in 'UVoiture.pas',
  UTextures in 'UTextures.pas',
  USons in 'USons.pas',
  UParticules in 'UParticules.pas',
  UFeux in 'UFeux.pas',
  UJoueur in 'UJoueur.pas',
  UCirculation in 'UCirculation.pas',
  UBadies in 'UBadies.pas',
  UAltitude in 'UAltitude.pas',
  Unit2 in 'Unit2.pas' {SplashForm},
  UTransparence in 'UTransparence.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Ecstasy';
  SplashForm := TsplashForm.create(Application);

  SplashForm.Init();
  SplashForm.Show;   // affichage de la fiche
  SplashForm.Update; // force la fiche à se dessiner complètement
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
