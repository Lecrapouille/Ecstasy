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
unit Uintro;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, MPlayer, StdCtrls, interfa;

type
   TForm2 = class(TForm)
      MediaPlayer1: TMediaPlayer;
      Panel1: TPanel;
      procedure FormCreate(Sender: TObject);
      procedure FormKeyDown(Sender: TObject; var Key: Word;
                            Shift: TShiftState);
   private
      { Déclarations privées }
   public
      { Déclarations publiques }
   end;

var
   Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
   Form2.Top := 0;
   Form2.left := 0;
   Form2.ClientHeight := screen.Height;
   Form2.ClientWidth := screen.Width;
   Panel1.Width := 320; panel1.Height := 240;
   Form2.Panel1.Top :=   (Form2.ClientHeight - Panel1.height) div 2;
   Form2.Panel1.Left :=   (Form2.ClientWidth - panel1.width) div 2;

   form2.mediaplayer1.filename := Getcurrentdir+'\Data\intro\intro.mpg';
   form2.mediaplayer1.Open;
   form2.mediaplayer1.Display := form2.panel1;
   form2.mediaplayer1.play;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word;
                             Shift: TShiftState);
begin
   if key = vk_escape then
   begin
      form2.mediaplayer1.stop;
      form2.mediaplayer1.Close;
      form2.hide;
      Application.CreateForm(TForm1, Form1);
      form1.show;
   end;
end;

end.
