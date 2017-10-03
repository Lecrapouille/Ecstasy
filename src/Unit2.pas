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
unit Unit2;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   ExtCtrls;

type
   TSplashForm = class(TForm)
      Image1: TImage;
   private
      { Déclarations privées }
   public
      { Déclarations publiques }
      procedure Init();
   end;

var
   SplashForm: TSplashForm;

implementation

{$R *.DFM}


procedure TSplashForm.Init();
var Screen : TScreen;
begin
   SplashForm.Top := 0;
   SplashForm.Left := 0;
   SplashForm.Width := Screen.Width;
   SplashForm.Height := Screen.Height;

   Image1.Top := 0;
   Image1.Left := 0;
   Image1.Width := Screen.Width;
   Image1.Height := Screen.Height;
end;

end.
