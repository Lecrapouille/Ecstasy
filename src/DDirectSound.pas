unit DDirectSound;

interface

uses sysutils, DSound, DirectX, D3DTypes, Windows, Classes, Forms,
{$IFDEF VER90}
  Dialogs,
{$ENDIF}
  MMSystem;

type
  EDelphiDirectSoundError = class(Exception);
  EDirectSoundError = class(EDirectXError);

  TPositionEvent = procedure ( Sender: TObject; Index: Longint ) of object;

  TNotifyPositions = record
    Count: Integer;
    Notifies: Pointer;
    Events: Pointer;
  end;
  PNotifyPositions = ^TNotifyPositions;

  TDirectSound = class;
  TDirectSoundBuffer = class;
  TNotifyThread = class;

  {*  *}

  TDSDevice = class(TCollectionItem)
  private
    FGUIDPtr: PGUID;
    FGUID: TGUID;
    FDescription: String;
    FModule: String;

  public
    procedure SetGUID( Value: PGUID );

  public
    property Description: String read FDescription write FDescription;
    property GUIDPtr: PGUID read FGUIDPtr write FGUIDPtr;
    property Module: String read FModule write FModule;
  end;

  TDSDevices = class(TCollection)
  private
    function GetItem(Index: Integer): TDSDevice;
    procedure SetItem(Index: Integer; Value: TDSDevice);
  public
    constructor Create; virtual;

    function Add: TDSDevice;
    property Items[Index: Integer]: TDSDevice read GetItem write SetItem; default;
  end;

  {*  *}

  TDirectSound = class( TObject )
  private
    FInterface1: IDirectSound;
    FBuffers: TList;
    FPrimaryBuffer: TDirectSoundBuffer;
    FDeferred: Longint;

    function GetCaps: TDSCaps;
    function GetSpeakerConfig: DWord;
    procedure SetSpeakerConfig( Value: DWord );
    function GetDeferred: Boolean;
    procedure SetDeferred( Value: Boolean );
    function GetFormat: TWaveFormatEx;
    procedure SetFormat( const Value: TWaveFormatEx );

    // 3DListener methods
    function GetAllParameters: TDS3DListener;
    procedure SetAllParameters( Value: TDS3DListener );
    function GetPosition: TD3DVector;
    procedure SetPosition( Value: TD3DVector );
    function GetVelocity: TD3DVector;
    procedure SetVelocity( Value: TD3DVector );
    function GetDistanceFactor: TD3DValue;
    procedure SetDistanceFactor( Value: TD3DValue );
    function GetDopplerFactor: TD3DValue;
    procedure SetDopplerFactor( Value: TD3DValue );
    function GetRolloffFactor: TD3DValue;
    procedure SetRolloffFactor( Value: TD3DValue );
    function GetOrientationFront: TD3DVector;
    procedure SetOrientationFront( Value: TD3DVector );
    function GetOrientationTop: TD3DVector;
    procedure SetOrientationTop( Value: TD3DVector );

  public
    constructor Create( GUIDPtr: PGUID; PrimaryBufferFlags: Longint ); virtual;
    destructor Destroy; override ;
    procedure Notification(Obj: TObject; Operation: TOperation);

    procedure Compact;
    procedure SetCooperativeLevel( Window: HWND; Level: Longint );

    property Caps: TDSCaps read GetCaps;
    property Deferred: Boolean read GetDeferred write SetDeferred;
    property Format: TWaveFormatEx read GetFormat write SetFormat;
    property Interface1: IDirectSound read FInterface1;
    property PrimaryBuffer: TDirectSoundBuffer read FPrimaryBuffer;
    property SpeakerConfig: DWord read GetSpeakerConfig
      write SetSpeakerConfig;

    property AllParameters: TDS3DListener read GetAllParameters
      write SetAllParameters;
    property Position: TD3DVector read GetPosition write SetPosition;
    property Velocity: TD3DVector read GetVelocity write SetVelocity;
    property DistanceFactor: TD3DValue read GetDistanceFactor
      write SetDistanceFactor;
    property DopplerFactor: TD3DValue read GetDopplerFactor
      write SetDopplerFactor;
    property RolloffFactor: TD3DValue read GetRolloffFactor
      write SetRolloffFactor;
    property OrientationFront: TD3DVector read GetOrientationFront
      write SetOrientationFront;
    property OrientationTop: TD3DVector read GetOrientationTop
      write SetOrientationTop;
  end;


  TDirectSoundBuffer = class( TObject )
  private
    FInterface1: IDirectSoundBuffer;
    FDS3DBuffer: IDirectSound3DBuffer;
    FDS3DListener: IDirectSound3DListener;
    FDSNotify: IDirectSoundNotify;
    FKsPropertySet: IKsPropertySet;
    FOwner: TDirectSound;
    FThread: TNotifyThread;
    FOnPosition: TPositionEvent;

    procedure InitializeInterface;
    procedure DestroyInterface;
    function GetAppliance: Longint;

    // Interface1 methods
    function GetCaps: TDSBCaps;
    function GetFrequency: DWord;
    procedure SetFrequency( Value: DWord );
    function GetPan: Longint;
    procedure SetPan( Value: Longint );
    function GetPlayPosition: DWord;
    procedure SetPlayPosition( Value: DWord );
    function GetStatus: DWord;
    function GetVolume: Longint;
    procedure SetVolume( Value: Longint );
    function GetWritePosition: Longint;

    // 3DBuffer methods
    function GetAllParameters: TDS3DBuffer;
    procedure SetAllParameters( Value: TDS3DBuffer );
    function GetInsideConeAngle: DWord;
    procedure SetInsideConeAngle( Value: DWord );
    function GetOutsideConeAngle: DWord;
    procedure SetOutsideConeAngle( Value: DWord );
    function GetConeOrientation: TD3DVector;
    procedure SetConeOrientation( Value: TD3DVector );
    function GetConeOutsideVolume: Longint;
    procedure SetConeOutsideVolume( Value: Longint );
    function GetMaxDistance: TD3DValue;
    procedure SetMaxDistance( Value: TD3DValue );
    function GetMinDistance: TD3DValue;
    procedure SetMinDistance( Value: TD3DValue );
    function GetMode: DWord;
    procedure SetMode( Value: DWord );
    function GetPosition: TD3DVector;
    procedure SetPosition( Value: TD3DVector );
    function GetVelocity: TD3DVector;
    procedure SetVelocity( Value: TD3DVector );

  protected
    property Appliance: Longint read GetAppliance;

    procedure PositionNotify( Sender: TObject; Position: Longint );

  public
    //QQ


    constructor Create( Owner: TDirectSound; const Description: TDSBufferDesc );
      virtual;
    constructor CreateDuplicated( Original: TDirectSoundBuffer ); virtual;
    destructor Destroy; override ;

    procedure Lock( WriteCursor, WriteBytes: Longint;
        var Audio1Ptr: Pointer; var AudioBytes1: DWord;
        var Audio2Ptr: Pointer; var AudioBytes2: DWord;
        Flags: Longint );
    procedure Play( Flags: Longint );
    procedure Restore;
    procedure SetNotificationPositions( PositionCount: Integer; Positions: PLongint );
    procedure Stop;
    procedure Unlock( Audio1Ptr: Pointer; AudioBytes1: Longint;
        Audio2Ptr: Pointer; AudioBytes2: Longint );


    // basic properties
    property Caps: TDSBCaps read GetCaps;
    property DS3DBuffer: IDirectSound3DBuffer read FDS3DBuffer;
    property DS3DListener: IDirectSound3DListener read FDS3DListener;
    property DSNotify: IDirectSoundNotify read FDSNotify;
    property Frequency: DWord read GetFrequency write SetFrequency;
    property Interface1: IDirectSoundBuffer read FInterface1;
    property KsPropertySet: IKsPropertySet read FKsPropertySet;
    property Owner: TDirectSound read FOwner;
    property Pan: Longint read GetPan write SetPan;
    property PlayPosition: DWord read GetPlayPosition write SetPlayPosition;
    property Status: DWord read GetStatus;
    property Volume: Longint read GetVolume write SetVolume;
    property WritePosition: Longint read GetWritePosition;
    property OnPosition: TPositionEvent read FOnPosition write FOnPosition;

    // 3DBuffer properties
    property AllParameters: TDS3DBuffer read GetAllParameters
      write SetAllParameters;
    property ConeOrientation: TD3DVector read GetConeOrientation
      write SetConeOrientation;
    property ConeOutsideVolume: Longint read GetConeOutsideVolume
      write SetConeOutsideVolume;
    property InsideConeAngle: DWord read GetInsideConeAngle
      write SetInsideConeAngle;
    property MaxDistance: TD3DValue read GetMaxDistance write SetMaxDistance;
    property MinDistance: TD3DValue read GetMinDistance write SetMinDistance;
    property Mode: DWord read GetMode write SetMode;
    property OutsideConeAngle: DWord read GetOutsideConeAngle
      write SetOutsideConeAngle;
    property Position: TD3DVector read GetPosition
      write SetPosition;
    property Velocity: TD3DVector read GetVelocity
      write SetVelocity;
  end;


  {*  *}

  TDirectSoundCapture = class( TObject )
  private
    FInterface1: IDirectSoundCapture;
    FBuffers: TList;

    function GetCaps: TDSCCaps;

  public
    constructor Create( GUIDPtr: PGUID ); virtual;
    destructor Destroy; override ;
    procedure Notification(Obj: TObject; Operation: TOperation);

    property Caps: TDSCCaps read GetCaps;
    property Interface1: IDirectSoundCapture read FInterface1;
  end;


  TDirectSoundCaptureBuffer = class( TObject )
  private
    FInterface1: IDirectSoundCaptureBuffer;
    FDSNotify: IDirectSoundNotify;
    FOwner: TDirectSoundCapture;
    FThread: TNotifyThread;
    FOnPosition: TPositionEvent;

    function GetCaps: TDSCBCaps;
    function GetCapturePosition: DWord;
    function GetReadPosition: Longint;
    function GetFormat: TWaveFormatEx;
    function GetStatus: DWord;

  protected
    procedure PositionNotify( Sender: TObject; Position: Longint );

  public
    constructor Create( Owner: TDirectSoundCapture;
      const Description: TDSCBufferDesc ); virtual;
    destructor Destroy; override;

    procedure Lock( ReadCursor, ReadBytes: Longint;
        var Audio1Ptr: Pointer; var AudioBytes1: DWord;
        var Audio2Ptr: Pointer; var AudioBytes2: DWord;
        Flags: Longint );
    procedure Start( Flags: Longint );
    procedure SetNotificationPositions( PositionCount: Integer; Positions: PLongint );
    procedure Stop;
    procedure Unlock( Audio1Ptr: Pointer; AudioBytes1: Longint;
        Audio2Ptr: Pointer; AudioBytes2: Longint );

    property Caps: TDSCBCaps read GetCaps;
    property CapturePosition: DWord read GetCapturePosition;
    property DSNotify: IDirectSoundNotify read FDSNotify;
    property Format: TWaveFormatEx read GetFormat;
    property Interface1: IDirectSoundCaptureBuffer read FInterface1;
    property OnPosition: TPositionEvent read FOnPosition write FOnPosition;
    property Owner: TDirectSoundCapture read FOwner;
    property ReadPosition: Longint read GetReadPosition;
    property Status: DWord read GetStatus;
  end;


  TNotifyThread = class(TThread)
  private
    OwnerEvent: TPositionEvent;
    Owner: TObject;
    ReachedPosition: Longint;
    IDSN: IDirectSoundNotify;
    StopEvent: THandle;
    PositionNotifies: TNotifyPositions;

    procedure CallEvent;

  protected
    procedure Execute; override;

  public
    constructor Create( AOwner: TObject; Event: TPositionEvent;
      IDSNotify: IDirectSoundNotify; PositionCount: Integer;
      Positions: PLongint );
    destructor Destroy; override;
  end;


  procedure EnumerateDirectSound( List: TDSDevices );
  procedure EnumerateDirectSoundCapture( List: TDSDevices );


implementation

var
  DirectSoundList: TList;
  DirectSoundCaptureList: TList;

  procedure DSCheck( Value: HRESULT ); forward;
  function DSEnumCallback( GUIDPtr: PGUID ; lpstrDescription: LPWSTR ;
      lpstrModule: LPWSTR ; lpContext: Pointer ): BOOL ; stdcall; forward;




{$IFDEF VER90}
procedure Assert(expr : Boolean ; const msg: string);
begin
     if Expr then ShowMessage(Msg);
end;
{$ENDIF}

{**********************************************************
    TDSDevice / TDSDevices Object
**********************************************************}

procedure TDSDevice.SetGUID( Value: PGUID );
begin
  if Value <> nil then
  begin
    FGUID := Value^;
    FGUIDPtr := @FGUID;
  end
  else
    FGUIDPtr := nil;
end;

constructor TDSDevices.Create;
begin
  inherited Create( TDSDevice );
end;

function TDSDevices.Add: TDSDevice;
begin
  Result := TDSDevice(inherited Add);
end;

function TDSDevices.GetItem(Index: Integer): TDSDevice;
begin
  Result := TDSDevice(inherited GetItem(Index));
end;

procedure TDSDevices.SetItem(Index: Integer; Value: TDSDevice);
begin
  inherited SetItem(Index, Value);
end;


{**********************************************************
    TNotifyThread Object
**********************************************************}

constructor TNotifyThread.Create( AOwner: TObject;
  Event: TPositionEvent; IDSNotify: IDirectSoundNotify; PositionCount: Integer;
  Positions: PLongint );
var
  Cnt: Integer;
begin
  inherited Create(True);

  if (PositionCount+1 > MAXIMUM_WAIT_OBJECTS) then
    raise EDelphiDirectSoundError.Create('Notification positions exceed ' +
      'maximum of ' + IntToStr(MAXIMUM_WAIT_OBJECTS));

  // create event for stopping (auto reset)
  StopEvent := CreateEvent( nil, True, False, nil );

  Owner := AOwner;
  OwnerEvent := Event;
  IDSN := IDSNotify;

  with PositionNotifies do
  begin
    // create structure with positions and events
    Count := PositionCount;
    GetMem( Notifies, Count * sizeof(TDSBPositionNotify) );
    ZeroMemory( Notifies, Count * sizeof(TDSBPositionNotify) );
    GetMem( Events, (Count+1) * sizeof(THandle) );

    for Cnt := 0 to Count-1 do
      with PDSBPositionNotify(PChar(Notifies)
        + Cnt * sizeof(TDSBPositionNotify))^ do
      begin
        dwOffset := PLongint(PChar(Positions) + Cnt * sizeof(Longint))^;
        hEventNotify := CreateEvent( nil, False, False, nil );
        if hEventNotify = 0 then
          raise EDelphiDirectSoundError.Create('Error creating event');

        PHandle(PChar(Events) + Cnt * sizeof(THandle))^ := hEventNotify;
      end;
    // insert the stop event
    PHandle(PChar(Events) + Count * sizeof(THandle))^ := StopEvent;

    // insert notification into DirectSound
    DSCheck( IDSN.SetNotificationPositions( PositionCount,
      TDSBPositionNotify(Notifies^) ) );
  end;

  Resume;
end;


destructor TNotifyThread.Destroy;
var
  Cnt: Integer;
  ExitCode: DWord;
begin
  Terminate;
  SetEvent( StopEvent );

  // wait for thread to really end
  repeat
    Application.ProcessMessages;
    if not GetExitCodeThread( Handle, ExitCode ) then
      raise EDelphiDirectSoundError.Create('Error destroying thread');
  until (ExitCode <> STILL_ACTIVE);

  // deletes all events
  with PositionNotifies do
  begin
    if Notifies <> nil then
    begin
      for Cnt := 0 to Count-1 do
        with PDSBPositionNotify(PChar(Notifies) + Cnt *
          sizeof(TDSBPositionNotify))^ do
          if (hEventNotify <> 0) then
            CloseHandle( hEventNotify );

      FreeMem( Notifies );
    end;

    if Events <> nil then FreeMem( Events );
  end;

  CloseHandle( StopEvent );

  inherited Destroy;
end;

procedure TNotifyThread.Execute;
var
  N: Integer;
begin
  with PositionNotifies do
  while not Terminated do
  begin
       N := WaitForMultipleObjects(Count+1, PWOHandleArray(Events), False,
        INFINITE) - WAIT_OBJECT_0;

      if (N >= 0) and (N < Count) then
      begin
        // call object event
         ReachedPosition := N;
         Synchronize( CallEvent );
      end;
  end;
end;

procedure TNotifyThread.CallEvent;
begin
  OwnerEvent( Owner, ReachedPosition );
end;


{**********************************************************
    TDirectSound Object
**********************************************************}

constructor TDirectSound.Create( GUIDPtr: PGUID; PrimaryBufferFlags: Longint );
var
  ds: TDSBufferDesc;
begin
  inherited Create;

  { Initialize the DirectSound system }
  if not Assigned(DirectSoundCreate) then
    raise EDelphiDirectSoundError.Create('Couldn''t link to DSOUND.DLL. Check your DirectSound installation.')
  else
    DSCheck( DirectSoundCreate ( GUIDPtr, FInterface1, nil ) );

  FBuffers := TList.Create;
  FDeferred := DS3D_IMMEDIATE;

  // adds itself to the global list of DirectSounds
  DirectSoundList.Add( self );

  // create primary buffer
  ds.dwSize := sizeof(ds);
  ds.dwFlags := PrimaryBufferFlags or DSBCAPS_CTRL3D or DSBCAPS_PRIMARYBUFFER;
  ds.dwBufferBytes := 0;
  ds.dwReserved := 0;
  ds.lpwfxFormat := nil;
  FPrimaryBuffer := TDirectSoundBuffer.Create( self, ds );
end;

destructor TDirectSound.Destroy;
begin
  // delete buffers
  if FBuffers <> nil then
  begin
    while FBuffers.Count > 0 do
      TDirectSoundBuffer(FBuffers[0]).Free;
    FBuffers.Free;
  end;

  if FInterface1 <> nil then
    FInterface1 := nil ;

  DirectSoundList.Remove( self );

  inherited Destroy;
end;


function TDirectSound.GetCaps: TDSCaps;
begin
  Result.dwSize := sizeof( Result );
  DSCheck( FInterface1.GetCaps( Result ) );
end;


function TDirectSound.GetSpeakerConfig: DWord;
begin
  DSCheck( FInterface1.GetSpeakerConfig( Result ) );
end;


procedure TDirectSound.SetSpeakerConfig( Value: DWord );
begin
  DSCheck( FInterface1.SetSpeakerConfig( Value ) );
end;


function TDirectSound.GetDeferred: Boolean;
begin
  if FDeferred = DS3D_DEFERRED then Result := True
  else Result := False;
end;


procedure TDirectSound.SetDeferred( Value: Boolean );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  if (FDeferred = DS3D_DEFERRED) then
  begin
    if (Value = False) then
    begin
      FDeferred := DS3D_IMMEDIATE;
      DSCheck( PrimaryBuffer.DS3DListener.CommitDeferredSettings );
    end;
  end
  else
    if (Value = True) then FDeferred := DS3D_DEFERRED;
end;


function TDirectSound.GetFormat: TWaveFormatEx;
begin
  DSCheck( FPrimaryBuffer.Interface1.GetFormat( @Result, sizeof(Result), nil ) );
end;


procedure TDirectSound.SetFormat( const Value: TWaveFormatEx );
begin
  DSCheck( FPrimaryBuffer.Interface1.SetFormat( Value ) );
end;


function TDirectSound.GetAllParameters: TDS3DListener;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetAllParameters( Result ) );
end;


procedure TDirectSound.SetAllParameters( Value: TDS3DListener );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetAllParameters( Value, FDeferred ) );
end;


function TDirectSound.GetPosition: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetPosition( Result ) );
end;


procedure TDirectSound.SetPosition( Value: TD3DVector );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetPosition( Value.X, Value.Y, Value.Y,
    FDeferred ) );
end;


function TDirectSound.GetVelocity: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetVelocity( Result ) );
end;


procedure TDirectSound.SetVelocity( Value: TD3DVector );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetVelocity( Value.X, Value.Y, Value.Z,
    FDeferred ) );
end;


function TDirectSound.GetDistanceFactor: TD3DValue;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetDistanceFactor( Result ) );
end;


procedure TDirectSound.SetDistanceFactor( Value: TD3DValue );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetDistanceFactor( Value, FDeferred ) );
end;


function TDirectSound.GetDopplerFactor: TD3DValue;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetDopplerFactor( Result ) );
end;


procedure TDirectSound.SetDopplerFactor( Value: TD3DValue );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetDopplerFactor( Value, FDeferred ) );
end;


function TDirectSound.GetRolloffFactor: TD3DValue;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetRolloffFactor( Result ) );
end;


procedure TDirectSound.SetRolloffFactor( Value: TD3DValue );
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.SetRolloffFactor( Value, FDeferred ) );
end;


function TDirectSound.GetOrientationFront: TD3DVector;
var
  lixo: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetOrientation( Result, lixo ) );
end;


procedure TDirectSound.SetOrientationFront( Value: TD3DVector );
var
  lixo: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  lixo := GetOrientationTop;
  DSCheck( FPrimaryBuffer.DS3DListener.SetOrientation( Value.X, Value.Y,
    Value.Z, lixo.X, lixo.Y, lixo.Z, FDeferred ) );
end;


function TDirectSound.GetOrientationTop: TD3DVector;
var
  lixo: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  DSCheck( FPrimaryBuffer.DS3DListener.GetOrientation( lixo, Result ) );
end;


procedure TDirectSound.SetOrientationTop( Value: TD3DVector );
var
  lixo: TD3DVector;
begin
  Assert(PrimaryBuffer.DS3DListener <> nil, 'DS3DListener interface is nil');
  lixo := GetOrientationFront;
  DSCheck( FPrimaryBuffer.DS3DListener.SetOrientation( lixo.X, lixo.Y, lixo.Z,
    Value.X, Value.Y, Value.Z, FDeferred ) );
end;


procedure TDirectSound.Notification(Obj: TObject; Operation: TOperation);
begin
  if (Operation = opRemove) then
  begin
    if (Obj is TDirectSoundBuffer) then
      FBuffers.Remove( Obj );
  end
  else
  begin
    if (Obj is TDirectSoundBuffer) and (FBuffers.IndexOf( Obj ) = -1) then
      FBuffers.Add( Obj );
  end;
end;


procedure TDirectSound.Compact;
begin
  DSCheck( FInterface1.Compact );
end;


procedure TDirectSound.SetCooperativeLevel( Window: HWND; Level: Longint );
begin
  DSCheck( FInterface1.SetCooperativeLevel( Window, Level ) );
end;


{**********************************************************
    TDirectSoundBuffer Object
**********************************************************}

constructor TDirectSoundBuffer.Create( Owner: TDirectSound;
  const Description: TDSBufferDesc );
begin
  inherited Create;

  FOwner := Owner;

  // create buffer interface
  DSCheck( FOwner.Interface1.CreateSoundBuffer( Description,
    FInterface1, nil ) );

  InitializeInterface;

  // add itself to DirectSound buffer list
  FOwner.Notification( self, opInsert );
end;


constructor TDirectSoundBuffer.CreateDuplicated( Original: TDirectSoundBuffer );
begin
  inherited Create;

  FOwner := Original.Owner;

  DSCheck( FOwner.Interface1.DuplicateSoundBuffer( Original.Interface1,
    FInterface1 ) );

  InitializeInterface;

  // add itself to DirectSound buffers list
  FOwner.Notification( self, opInsert );
end;


destructor TDirectSoundBuffer.Destroy;
begin
  if (FThread <> nil) then
  begin
    FThread.Free;
    FThread := nil;
  end;

  DestroyInterface;

  // remove from the DirectSound buffer list
  if (FOwner <> nil) then
    FOwner.Notification( self, opRemove );
  FOwner := nil;

  inherited Destroy ;
end;


procedure TDirectSoundBuffer.InitializeInterface;
begin
  { Get the IDirectSound3DBuffer interface }
  Interface1.QueryInterface( IID_IDirectSound3DBuffer, FDS3DBuffer );

  { Get the IDirectSound3DListener interface }
  Interface1.QueryInterface( IID_IDirectSound3DListener, FDS3DListener );

  { Get the IDirectSound3DListener interface }
  Interface1.QueryInterface( IID_IDirectSoundNotify, FDSNotify );

  { Get the IKsPropertySet interface }
  Interface1.QueryInterface( IID_IKsPropertySet, FKsPropertySet );
end;


procedure TDirectSoundBuffer.DestroyInterface;
begin
  if FDS3DBuffer <> nil then
    FDS3DBuffer := nil;

  if FDS3DListener <> nil then
    FDS3DListener := nil;

  if FDSNotify <> nil then
    FDSNotify := nil;

  if FKsPropertySet <> nil then
    FKsPropertySet := nil;

  if FInterface1 <> nil then
    FInterface1 := nil;
end;


function TDirectSoundBuffer.GetAppliance: Longint;
begin
  if FOwner.Deferred then Result := DS3D_DEFERRED
  else Result := DS3D_IMMEDIATE;
end;


function TDirectSoundBuffer.GetCaps: TDSBCaps;
begin
  Result.dwSize := sizeof( Result );
  DSCheck( FInterface1.GetCaps( Result ) );
end;


function TDirectSoundBuffer.GetFrequency: DWord;
begin
  DSCheck( FInterface1.GetFrequency( Result ) );
end;


procedure TDirectSoundBuffer.SetFrequency( Value: DWord );
begin
  DSCheck( FInterface1.SetFrequency( Value ) );
end;


function TDirectSoundBuffer.GetPan: Longint;
begin
  DSCheck( FInterface1.GetPan( Result ) );
end;


procedure TDirectSoundBuffer.SetPan( Value: Longint );
begin
  DSCheck( FInterface1.SetPan( Value ) );
end;


function TDirectSoundBuffer.GetPlayPosition: DWord;
var
  lixo: DWord;
begin
  DSCheck( FInterface1.GetCurrentPosition( @Result, @lixo ) );
end;


procedure TDirectSoundBuffer.SetPlayPosition( Value: DWord );
begin
  DSCheck( FInterface1.SetCurrentPosition( Value ) );
end;


function TDirectSoundBuffer.GetStatus: DWord;
begin
  DSCheck( FInterface1.GetStatus( Result ) );
end;


function TDirectSoundBuffer.GetVolume: Longint;
begin
  DSCheck( FInterface1.GetVolume( Result ) );
end;


procedure TDirectSoundBuffer.SetVolume( Value: Longint );
begin
  DSCheck( FInterface1.SetVolume( Value ) );
end;


function TDirectSoundBuffer.GetWritePosition: Longint;
var
  lixo: Longint;
begin
  DSCheck( FInterface1.GetCurrentPosition( @lixo, @Result ) );
end;


function TDirectSoundBuffer.GetAllParameters: TDS3DBuffer;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  Result.dwSize := sizeof( Result );
  DSCheck( FDS3DBuffer.GetAllParameters( Result ) );
end;


procedure TDirectSoundBuffer.SetAllParameters( Value: TDS3DBuffer );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetAllParameters( Value, Appliance ) );
end;


function TDirectSoundBuffer.GetInsideConeAngle: DWord;
var
  lixo: DWord;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetConeAngles( Result, lixo ) );
end;


procedure TDirectSoundBuffer.SetInsideConeAngle( Value: DWord );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetConeAngles( Value, GetOutsideConeAngle, Appliance ) );
end;


function TDirectSoundBuffer.GetOutsideConeAngle: DWord;
var
  lixo: DWord;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetConeAngles( lixo, Result ) );
end;


procedure TDirectSoundBuffer.SetOutsideConeAngle( Value: DWord );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetConeAngles( GetOutsideConeAngle, Value, Appliance ) );
end;


function TDirectSoundBuffer.GetConeOrientation: TD3DVector;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetConeOrientation( Result ) );
end;


procedure TDirectSoundBuffer.SetConeOrientation( Value: TD3DVector );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetConeOrientation( Value.X, Value.Y, Value.Z,
    Appliance ) );
end;


function TDirectSoundBuffer.GetConeOutsideVolume: Longint;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetConeOutsideVolume( Result ) );
end;


procedure TDirectSoundBuffer.SetConeOutsideVolume( Value: Longint );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetConeOutsideVolume( Value, Appliance ) );
end;


function TDirectSoundBuffer.GetMaxDistance: TD3DValue;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetMaxDistance( Result ) );
end;


procedure TDirectSoundBuffer.SetMaxDistance( Value: TD3DValue );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetMaxDistance( Value, Appliance ) );
end;


function TDirectSoundBuffer.GetMinDistance: TD3DValue;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetMinDistance( Result ) );
end;


procedure TDirectSoundBuffer.SetMinDistance( Value: TD3DValue );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetMinDistance( Value, Appliance ) );
end;


function TDirectSoundBuffer.GetMode: DWord;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetMode( Result ) );
end;


procedure TDirectSoundBuffer.SetMode( Value: DWord );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetMode( Value, Appliance ) );
end;


function TDirectSoundBuffer.GetPosition: TD3DVector;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetPosition( Result ) );
end;


procedure TDirectSoundBuffer.SetPosition( Value: TD3DVector );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetPosition( Value.X, Value.Y, Value.Z, Appliance ) );
end;


function TDirectSoundBuffer.GetVelocity: TD3DVector;
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.GetVelocity( Result ) );
end;


procedure TDirectSoundBuffer.SetVelocity( Value: TD3DVector );
begin
  Assert(FDS3DBuffer <> nil, 'DS3DBuffer interface is nil');
  DSCheck( FDS3DBuffer.SetVelocity( Value.X, Value.Y, Value.Z, Appliance ) );
end;


procedure TDirectSoundBuffer.Lock( WriteCursor, WriteBytes: Longint;
  var Audio1Ptr: Pointer; var AudioBytes1: DWord;
  var Audio2Ptr: Pointer; var AudioBytes2: DWord;
  Flags: Longint );
begin
  DSCheck( FInterface1.Lock( WriteCursor, WriteBytes, Audio1Ptr, AudioBytes1,
    Audio2Ptr, AudioBytes2, Flags ) );
end;


procedure TDirectSoundBuffer.Play( Flags: Longint );
begin
  DSCheck( FInterface1.Play( 0, 0, Flags ) );
end;


procedure TDirectSoundBuffer.Restore;
begin
  DSCheck( FInterface1.Restore );
end;


procedure TDirectSoundBuffer.Stop;
begin
  DSCheck( FInterface1.Stop );
end;


procedure TDirectSoundBuffer.Unlock( Audio1Ptr: Pointer; AudioBytes1: Longint;
  Audio2Ptr: Pointer; AudioBytes2: Longint );
begin
  DSCheck( FInterface1.Unlock( Audio1Ptr, AudioBytes1,
    Audio2Ptr, AudioBytes2 ) );
end;


procedure TDirectSoundBuffer.SetNotificationPositions( PositionCount: Integer;
  Positions: PLongint );
begin
  Assert(FDSNotify <> nil, 'DirectSoundNotify interface is nil');
  if (FThread <> nil) then
  begin
    FThread.Free;
    FThread := nil;
  end;

  FThread := TNotifyThread.Create( self, PositionNotify, FDSNotify,
    PositionCount, Positions );
end;


procedure TDirectSoundBuffer.PositionNotify( Sender: TObject; Position: Longint );
begin
  if Assigned(FOnPosition) then
    FOnPosition( Sender, Position );
end;



{**********************************************************
    TDirectSoundCapture Object
**********************************************************}

constructor TDirectSoundCapture.Create( GUIDPtr: PGUID );
begin
  inherited Create;

  if @DirectSoundCaptureCreate = nil then
    raise EDelphiDirectSoundError.Create('DirectSoundCaptureCreate function not '
      + 'available in DLL.' + #13 + 'You need a higher version.')
  else
    DSCheck( DirectSoundCaptureCreate( GUIDPtr, FInterface1, nil ) );

  FBuffers := TList.Create;

  // adds itself to the global list of DirectSoundCaptures
  DirectSoundCaptureList.Add( self );
end;

destructor TDirectSoundCapture.Destroy ;
begin
  // delete buffers
  if FBuffers <> nil then
  begin
    while FBuffers.Count > 0 do
      TDirectSoundCaptureBuffer(FBuffers[0]).Free;
    FBuffers.Free;
  end;

  if FInterface1 <> nil then
    FInterface1 := nil ;

  DirectSoundCaptureList.Remove( self );

  inherited Destroy;
end;


function TDirectSoundCapture.GetCaps: TDSCCaps;
begin
  Result.dwSize := sizeof( Result );
  DSCheck( FInterface1.GetCaps( Result ) );
end;


procedure TDirectSoundCapture.Notification(Obj: TObject; Operation: TOperation);
begin
  if (Operation = opRemove) then
  begin
    if (Obj is TDirectSoundCaptureBuffer) then
      FBuffers.Remove( Obj );
  end
  else
  begin
    if (Obj is TDirectSoundCaptureBuffer)
    and (FBuffers.IndexOf( Obj ) = -1) then
      FBuffers.Add( Obj );
  end;
end;


{**********************************************************
    TDirectSoundCaptureBuffer Object
**********************************************************}

constructor TDirectSoundCaptureBuffer.Create( Owner: TDirectSoundCapture;
  const Description: TDSCBufferDesc );
begin
  inherited Create;

  FOwner := Owner;

  // create buffer interface
  DSCheck( FOwner.Interface1.CreateCaptureBuffer( Description,
    FInterface1, nil ) );

  { Get the IDirectSoundNotify interface }
  Interface1.QueryInterface( IID_IDirectSoundNotify, FDSNotify );

  // add itself to DirectSoundCapture buffer list
  FOwner.Notification( self, opInsert );
end;


destructor TDirectSoundCaptureBuffer.Destroy;
begin
  if (FThread <> nil) then
    FThread.Free;

  if Assigned(FDSNotify) then
    FDSNotify := nil;

  if Assigned(FInterface1) then
    FInterface1 := nil;

  // remove from the DirectSound buffer list
  if (FOwner <> nil) then
    FOwner.Notification( self, opRemove );
  FOwner := nil;

  inherited Destroy ;
end;


function TDirectSoundCaptureBuffer.GetCaps: TDSCBCaps;
begin
  Result.dwSize := sizeof( Result );
  DSCheck( FInterface1.GetCaps( Result ) );
end;


function TDirectSoundCaptureBuffer.GetFormat: TWaveFormatEx;
begin
  DSCheck( FInterface1.GetFormat( @Result, sizeof(Result), nil ) );
end;


function TDirectSoundCaptureBuffer.GetCapturePosition: DWord;
var
  lixo: DWord;
begin
  DSCheck( FInterface1.GetCurrentPosition( @Result, @lixo ) );
end;


function TDirectSoundCaptureBuffer.GetStatus: DWord;
begin
  DSCheck( FInterface1.GetStatus( Result ) );
end;


function TDirectSoundCaptureBuffer.GetReadPosition: Longint;
var
  lixo: Longint;
begin
  DSCheck( FInterface1.GetCurrentPosition( @lixo, @Result ) );
end;


procedure TDirectSoundCaptureBuffer.Lock( ReadCursor, ReadBytes: Longint;
  var Audio1Ptr: Pointer; var AudioBytes1: DWord;
  var Audio2Ptr: Pointer; var AudioBytes2: DWord;
  Flags: Longint );
begin
  DSCheck( FInterface1.Lock( ReadCursor, ReadBytes, Audio1Ptr, AudioBytes1,
    Audio2Ptr, AudioBytes2, Flags ) );
end;


procedure TDirectSoundCaptureBuffer.Start( Flags: Longint );
begin
  DSCheck( FInterface1.Start( Flags ) );
end;


procedure TDirectSoundCaptureBuffer.Stop;
begin
  DSCheck( FInterface1.Stop );
end;


procedure TDirectSoundCaptureBuffer.Unlock( Audio1Ptr: Pointer; AudioBytes1: Longint;
  Audio2Ptr: Pointer; AudioBytes2: Longint );
begin
  DSCheck( FInterface1.Unlock( Audio1Ptr, AudioBytes1,
    Audio2Ptr, AudioBytes2 ) );
end;


procedure TDirectSoundCaptureBuffer.SetNotificationPositions(
  PositionCount: Integer; Positions: PLongint );
begin
  Assert(FDSNotify <> nil, 'DirectSoundNotify interface is nil');
  if (FThread <> nil) then
  begin
    FThread.Free;
    FThread := nil;
  end;

  FThread := TNotifyThread.Create( self, PositionNotify, FDSNotify,
    PositionCount, Positions );
end;


procedure TDirectSoundCaptureBuffer.PositionNotify( Sender: TObject;
  Position: Longint );
begin
  if Assigned(FOnPosition) then
    FOnPosition( Sender, Position );
end;



{**********************************************************
    Miscellanious
**********************************************************}

procedure EnumerateDirectSound( List: TDSDevices );
begin
  DSCheck( DirectSoundEnumerate( DSEnumCallback, Pointer(List) ) );
end;


procedure EnumerateDirectSoundCapture( List: TDSDevices );
begin
  Assert(@DirectSoundCaptureEnumerate <> nil,
    'DirectSoundCaptureEnumerate function not available in DLL.'
    + #13 + 'You need a higher version.');
  DSCheck( DirectSoundCaptureEnumerate( DSEnumCallback, Pointer(List) ) );
end;


function DSEnumCallback( GUIDPtr: PGUID ; lpstrDescription: LPWSTR ;
  lpstrModule: LPWSTR ; lpContext: Pointer ): BOOL ; stdcall;
var
  d: TDSDevice;
begin
  // add device to the list
  d := TDSDevices(lpContext).Add;
  d.SetGUID( GUIDPtr );
  d.Description := lpstrDescription;
  d.Module := lpstrModule;

  // Next please
  Result := True;
end;




procedure DSCheck( Value: HRESULT ); { Check the result of a COM operation }
var
  S: String ;
begin
  if Value <> DS_OK then
  begin
    Case Value of
      DSERR_ALLOCATED: S:='The call failed because resources (such as a priority level) were already being used by another caller.';
      DSERR_CONTROLUNAVAIL: S:='The control (vol,pan,etc.) requested by the caller is not available.';
      DSERR_INVALIDPARAM: S:='An invalid parameter was passed to the returning function.';
      DSERR_INVALIDCALL: S:='This call is not valid for the current state of this object';
      DSERR_GENERIC: S:='An undetermined error occured inside the DSound subsystem';
      DSERR_PRIOLEVELNEEDED: S:='The caller does not have the priority level required for the function to succeed.';
      DSERR_OUTOFMEMORY: S:='The DSound subsystem couldn''t allocate sufficient memory to complete the caller''s request.';
      DSERR_BADFORMAT: S:='The specified WAVE format is not supported';
      DSERR_UNSUPPORTED: S:='The function called is not supported at this time';
      DSERR_NODRIVER: S:='No sound driver is available for use';
      DSERR_ALREADYINITIALIZED: S:='This object is already initialized';
      DSERR_NOAGGREGATION: S:='This object does not support aggregation';
      DSERR_BUFFERLOST: S:='The buffer memory has been lost, and must be Restored.';
      DSERR_OTHERAPPHASPRIO: S:='Another app has a higher priority level, preventing this call from succeeding.';
      DSERR_UNINITIALIZED: S:='The Initialize() member on the Direct Sound Object has not been called or called successfully before calls to other members.';
      Else S:='Unrecognized error value.';
    end;

    S:= Format ( 'DirectSound call failed: %x', [ Value ] )  + #13 + S;
    raise EDirectSoundError.Create( S, Value );
  end;
end ;


initialization
begin
  DirectSoundList := TList.Create;
  DirectSoundCaptureList := TList.Create;
end;


finalization
begin
  DirectSoundCaptureList.Free;
  DirectSoundList.Free;
end;

end.

