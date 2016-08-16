unit DirectX;

interface

uses sysutils, Windows, Classes;

type
  EDirectXError = class(Exception)
  private
    FErrorCode: HRESULT;
  public
    constructor Create( const Msg: String; const ErrorCode: HRESULT ); virtual;
    property ErrorCode: HRESULT read FErrorCode;
  end;

  REFGUID  = PGUID;

implementation

constructor EDirectXError.Create( const Msg: String; const ErrorCode: HRESULT );
begin
  inherited Create( Msg );
  FErrorCode := ErrorCode;
end;



end.

