{*******************************************************************************
 *                            UBADIES.PAS
 *
 * Author  : Quentin QUADRAT
 * Email   : quadra_q@epita.fr
 * Website : www.epita.fr\~epita.fr
 * Date    : 02 Juin 2003
 * Changes : 02 Juin 2003
 * Description :
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
