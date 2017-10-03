{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : www.epita.fr\~epita.fr
 * Date    : 02 Juin 2003
 * Changes : 03 Octobre 2017
 * License: GPL-3.0
 * Description :
 *
 *******************************************************************************}
unit UInterfa;

interface

uses
   Windows,
   Messages,
   SysUtils,
   Classes,
   Graphics,
   Controls,
   Forms,
   Dialogs,
   UVoiture,
   ComCtrls,
   StdCtrls,
   ExtCtrls,
   jpeg,
   UBoucledeJeu,
   UTypege;

type
   TForm1 = class(TForm)
      Button1: TButton;
      Button2: TButton;
      Label12: TLabel;

      Timer1: TTimer;
      PageControl1: TPageControl;
      TabSheet1: TTabSheet;
      TabSheet3: TTabSheet;
      GroupBox4: TGroupBox;
      Label7: TLabel;
      Label10: TLabel;
      ComboBox1: TComboBox;
      ComboBox2: TComboBox;
      CheckBox1: TCheckBox;
      TabSheet4: TTabSheet;
      GroupBox3: TGroupBox;
      GroupBox8: TGroupBox;
      Label35: TLabel;
      CheckBox3: TCheckBox;
      GroupBox5: TGroupBox;
      TabSheet2: TTabSheet;
      TrackBar1: TTrackBar;
      Label8: TLabel;
      Edit10: TEdit;
      CheckBox2: TCheckBox;
      CheckBox4: TCheckBox;
      CheckBox5: TCheckBox;
      Label27: TLabel;
      TrackBar3: TTrackBar;
      Edit15: TEdit;
      CheckBox11: TCheckBox;
      CheckBox12: TCheckBox;
      GroupBox10: TGroupBox;
      CheckBox6: TCheckBox;
      ComboBox3: TComboBox;
      Image1: TImage;
      GroupBox7: TGroupBox;
      ScrollBar1: TScrollBar;
      Edit3: TEdit;
      Label1: TLabel;
      Label2: TLabel;
      Label3: TLabel;
      ScrollBar2: TScrollBar;
      Edit1: TEdit;
      Label5: TLabel;
      Label6: TLabel;
      procedure Button2Click(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure ComboBox1Change(Sender: TObject);
      procedure ComboBox2Change(Sender: TObject);
      procedure CheckBox1Click(Sender: TObject);
      procedure ComboBox3Change(Sender: TObject);
      procedure CheckBox2Click(Sender: TObject);
      procedure CheckBox3Click(Sender: TObject);
      procedure Edit13Change(Sender: TObject);
      procedure Button3Click(Sender: TObject);
      procedure Button5Click(Sender: TObject);
      procedure TrackBar1Change(Sender: TObject);
      procedure ScrollBar1Change(Sender: TObject);
      procedure CheckBox4Click(Sender: TObject);
      procedure CheckBox11Click(Sender: TObject);
      procedure CheckBox12Click(Sender: TObject);
      procedure ScrollBar2Change(Sender: TObject);
      procedure CheckBox6Click(Sender: TObject);
   public
      procedure ChargerVoiture();
   private
   end;

var
   Form1: TForm1;

implementation

uses Unit2;

{$R *.DFM}

procedure sauvegarder();
var
   OutFile : file;
begin
   AssignFile(OutFile, GetCurrentDir + '\data\Configuration\config.cfg');
   Reset(OutFile);
   blockWrite(OutFile, params, 1);
   CloseFile(OutFile);
end;

procedure TForm1.ChargerVoiture();
begin
   //
end;

procedure ChargerParametresVideos();
var InFile : file;
begin
   AssignFile(InFile, GetCurrentDir + '\data\Configuration\config.cfg');
   Reset(InFile);
   blockread(InFile, params, 1);
   CloseFile(InFile);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   SplashForm.close;
   SplashForm.Release;
   application.terminate;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   sauvegarder();
   Form1.FormStyle := fsNormal;
   // Joueur := TJoueur.Create(40,40,1);
   if (DISTANCE_CLIPPING <= ALTITUDE_MAX_CAMERA) then MessageBox(0, 'Erreur', 'DISTANCE_CLIPPING <= ALTITUDE_MAX_CAMERA', MB_OK And MB_ICONWARNING )
   else
      if (LONG_ROUTE_X mod 50 <> 0) OR (LONG_ROUTE_Y mod 50 <> 0) then
         MessageBox(0, 'LONG_ROUTE_X mod 5 <> 0', 'LONG_ROUTE_X mod 5 <> 0', MB_OK And MB_ICONWARNING )
      else

         WinMain( hInstance, hPrevInst, CmdLine, CmdShow, params )
end;

procedure TForm1.FormCreate(Sender: TObject);
var sr : TSearchRec; i : integer; F : TextFile; chaine : string;
begin
   Form1.FormStyle := fsStayOnTop;
   PageControl1.ActivePage := TabSheet1;
   {Chargement des voitures}
   TabRepertVoit.long := 0;
   FindFirst(GetCurrentDir+'\data\Voitures\*.*',faDirectory,sr);
   {Recherche des repertoires}
   while (FindNext(sr) = 0) AND ((sr.Attr AND faDirectory) = sr.Attr) AND
            (TabRepertVoit.long < MAX_VOITURES) do
   begin
      if  (FileExists(GetCurrentDir+'\data\Voitures\'+sr.Name+'\info.txt'))
          AND (FileExists(GetCurrentDir+'\data\Voitures\'+sr.Name+'\Carcasse.ASE'))
          AND (FileExists(GetCurrentDir+'\data\Voitures\'+sr.Name+'\Roue.ASE'))
          AND (FileExists(GetCurrentDir+'\data\Voitures\'+sr.Name+'\Photo.jpg'))
      then begin
         TabRepertVoit.long := TabRepertVoit.long+1;
         TabRepertVoit.elt[TabRepertVoit.long].Nom := sr.Name;
      end else
         if (sr.Name <> '..') then
            ShowMessage(sr.Name + ' ne sera pas prise dans le jeu : un fichier est manquant');
   end;
   FindClose(sr);


   {On ferme l'application s'il n'y a pas de voitures}
   if TabRepertVoit.long <= 0 then
   begin
      MessageBox(0, 'Il y a 0 voiture. Pas amusant pour jouer. Fermeture du programme',
                 'La prochaine fois tu mettras au moins une voiture',
                 MB_OK AND MB_ICONWARNING );
      Application.Terminate;
   end else
   begin
      {Chargement du Combobox}
      for i := 1 to TabRepertVoit.long do
      begin
         Combobox3.Items.Add(TabRepertVoit.elt[i].Nom);
         AssignFile(F, GetCurrentDir+'\data\Voitures\'+ TabRepertVoit.elt[i].Nom + '\info.txt');
         Reset(F);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Hauteur := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Avant := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Arriere := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Gauche := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Rayon := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].VitesseMax := 2*StrToFloat(chaine);

         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Masse_Roue := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Masse_Voit := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Reac_Sol := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Raideur := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Frot := StrToFloat(chaine);

         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].InertieRoulis := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].InertieTangage := StrToFloat(chaine);

         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Past := StrToFloat(chaine);
         Readln(F, chaine); Readln(F, chaine); TabRepertVoit.elt[i].Conducteur := StrToFloat(chaine);
         CloseFile(F);
      end;
      ComboBox3.ItemIndex := 0;
      NumeroIdentifVoit := ComboBox3.ItemIndex;
      Image1.Picture.LoadFromFile(GetCurrentDir+'\data\Voitures\'+ ComboBox3.Text + '\photo.jpg');

      //Parametre video
      ChargerParametresVideos();

      CheckBox6.Checked := Params.son;

      ScrollBar1.Position := Params.circu;
      case ScrollBar1.Position of
         0 : begin
                Edit3.Text := 'Aucune';
                NbVoitVoieLente := 0;
                NbVoitVoieRapide := 0;
             end;
         1 : begin
                Edit3.Text := 'Faible';
                NbVoitVoieLente := 2;
                NbVoitVoieRapide := 1;
             end;
         2 : begin
                Edit3.Text := 'Moyenne';
                NbVoitVoieLente := 3;
                NbVoitVoieRapide := 3;
             end;
         3 : begin
                Edit3.Text := 'Dense';
                NbVoitVoieLente := 5;
                NbVoitVoieRapide := 3;
             end;
         4 : begin
                Edit3.Text := 'Random';
                NbVoitVoieLente := random(5);
                NbVoitVoieRapide := random(5);
             end;
      end;

      ScrollBar2.Position := Params.ProportionTerrain;
      Edit1.Text := IntToStr(Params.ProportionTerrain);

      CheckBox11.Checked := Params.Nuit;
      if CheckBox11.Checked then CheckBox11.Caption := 'Nuit'
      else CheckBox11.Caption := 'Jour';

      CheckBox12.Checked := Params.Pluie;
      if CheckBox12.Checked then CheckBox12.Caption := 'Pluie activ�e'
      else CheckBox12.Caption := 'Pluie desactiv�e';

      CheckBox4.checked := Params.Soleil;
      CheckBox2.checked := Params.fog;


      ComboBox1.text := inttostr(params.Width)
         + ' x '
         + inttostr(params.Height);
      ComboBox2.text := inttostr(params.PixelDepth);
      CheckBox1.Checked := params.FullScreen;

      CheckBox2.Checked := params.fog;
      if CheckBox2.Checked then CheckBox2.Caption := 'Brume activ�e'
      else CheckBox2.Caption := 'Brume desactiv�e';

      ComboBox3Change(sender);

      if CheckBox3.Checked then Label35.Caption := 'activ�'
      else Label35.Caption := 'desactiv�';
      Edit10.Text := inttostr(params.Altitude);
      TrackBar1.Position := params.Altitude;
      RANDOM_TERRAIN := params.Altitude;
   end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
   case ComboBox1.ItemIndex of
      0 : begin params.Width := 640;
      params.Height := 480;
      params.police := 18;
          end;
      1 : begin params.Width := 800;
      params.Height := 600;
      params.police := 22;
          end;
      2 : begin params.Width := 1024;
      params.Height := 768;
      params.police := 26;
          end;
      3 : begin params.Width := 1280;
      params.Height := 1024;
      params.police := 32;
          end;
      4 : begin params.Width := 1600;
      params.Height := 1200;
      params.police := 38;
          end;
   end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
   case ComboBox2.ItemIndex of
      0 : params.PixelDepth := 8;
      1 : params.PixelDepth := 16;
      2 : params.PixelDepth := 24;
      3 : params.PixelDepth := 32;
   end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
   params.FullScreen := CheckBox1.Checked;
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin
   Image1.Picture.LoadFromFile(GetCurrentDir+'\data\Voitures\'+ComboBox3.Text + '\photo.jpg');
   NumeroIdentifVoit := ComboBox3.ItemIndex;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
   params.fog := CheckBox2.Checked;
   if CheckBox2.checked then CheckBox2.Caption := 'Brume activ�e' else
      CheckBox2.Caption := 'Brume desactiv�e'
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
   //param.Orage := CheckBox3.Checked;
   if CheckBox3.Checked then Label35.Caption := 'activ�'
   else Label35.Caption := 'desactiv�'
end;

procedure TForm1.Edit13Change(Sender: TObject);
begin
   //Joueur.Nom := StrToInt(Edit13.Text);
end;

procedure TForm1.Button3Click(Sender: TObject);
//var F : File;
begin
   { AssignFile(F,'data\Configuration\joueur.voit');
     Rewrite(F);
     blockwrite(F,Joueur,1);
     CloseFile(F);}
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
   ShowMessage('Teste si votre carte graphique g�re la lumi�re,le fog, le culling, le blending');
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
   Edit10.Text := IntToStr(TrackBar1.Position);
   Params.Altitude := TrackBar1.Position;
   RANDOM_TERRAIN := params.Altitude;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
   case ScrollBar1.Position of
      0 : begin
             Edit3.Text := 'Aucune';
             NbVoitVoieLente := 0;
             NbVoitVoieRapide := 0;
          end;
      1 : begin
             Edit3.Text := 'Faible';
             NbVoitVoieLente := 2;
             NbVoitVoieRapide := 1;
          end;
      2 : begin
             Edit3.Text := 'Moyenne';
             NbVoitVoieLente := 3;
             NbVoitVoieRapide := 3;
          end;
      3 : begin
             Edit3.Text := 'Dense';
             NbVoitVoieLente := 5;
             NbVoitVoieRapide := 3;
          end;
      4 : begin
             Edit3.Text := 'Random';
             NbVoitVoieLente := random(5);
             NbVoitVoieRapide := random(5);
          end;
   end;
   Params.circu := ScrollBar1.Position;
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin
   Params.Soleil := CheckBox4.checked;
   if CheckBox4.checked then CheckBox4.Caption := 'Lumi�re du soleil activ�e'
   else CheckBox4.Caption := 'Lumi�re du soleil desactiv�e';
end;

procedure TForm1.CheckBox11Click(Sender: TObject);
begin
   Params.Nuit := CheckBox11.Checked;
   if CheckBox11.Checked then CheckBox11.Caption := 'Nuit'
   else CheckBox11.Caption := 'Jour';
end;

procedure TForm1.CheckBox12Click(Sender: TObject);
begin
   Params.Pluie := CheckBox12.Checked;
   if CheckBox12.Checked then CheckBox12.Caption := 'Pluie activ�e'
   else CheckBox12.Caption := 'Pluie desactiv�e';
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
   Params.ProportionTerrain := ScrollBar2.Position;
   Edit1.Text := IntToStr(Params.ProportionTerrain);
end;

procedure TForm1.CheckBox6Click(Sender: TObject);
begin
   Params.son := CheckBox6.Checked;
end;

end.
