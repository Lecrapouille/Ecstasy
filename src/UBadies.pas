{*******************************************************************************
 *                            Ecstasy
 *
 * Author  : Quentin QUADRAT
 * Email   : lecrapouille@gmail.com
 * Website : www.epita.fr\~epita.fr
 * Date    : 02 Juin 2003
 * Changes : 03 Octobre 2017
 * License : GPL-3.0
 *
 *******************************************************************************}
unit UBadies;

interface

uses UVoiture;

{**************************  TBadies  ******************************************
 *
 * Les Badies sont les voitures de police qui circulent dans la ville. Ils heritent
 * du type TGoodies, mais ils circulent differement : ils poursuivent le joueur.
 *
 *******************************************************************************}
{Type TPBadies = ^TBadies;
 TBadies = class(TGoodies)
 private
 procedure Circule();
 end; }


implementation

{procedure TBadies.Circule();
 begin
 ChampAttractif(Joueur.Position);
 ChampRepulsif(Joueur.Position);
 Actualise();
 end; }

end.
