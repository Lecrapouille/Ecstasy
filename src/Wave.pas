unit Wave;

interface

uses Windows, Classes, MMSystem, Sysutils;

type
  EWaveError = Exception;

  procedure WaveLoadFile( FileName: String; var Size: Longint;
    var wfxInfoPtr: PWaveFormatEx; var Data: Pointer );
  procedure GetStreamWaveInfo( Stream: THandleStream; var Size: Longint;
    var Offset: Longint; var wfxInfo: TWaveFormatEx);
  procedure GetMemoryWaveInfo( Buffer: Pointer; BufferSize: Longint;
    var Size: Longint; var Data: Pointer; var wfxInfo: TWaveFormatEx);


implementation

procedure Init( mmIO: hmmIO; var Size: Longint;
  var Offset: Longint; var wfxInfo: TWaveFormatEx); forward;

function mmioFourCC( Chr1: Char; Chr2: Char; Chr3: Char; Chr4: Char ): DWord;
begin
  Result := Integer(Chr1) + (Integer(Chr2) shl 8) + (Integer(Chr3) shl 16)
    + (Integer(Chr4) shl 24);
end;


// Given a stream pointing to a wave file returns:
// Size of the wave
// Offset of the wave start
// Wave info
procedure GetStreamWaveInfo( Stream: THandleStream; var Size: Longint;
  var Offset: Longint; var wfxInfo: TWaveFormatEx);
var
  info: TMMIOINFO;
  mmIO: hmmIO;
begin
  ZeroMemory( @info, sizeof(info) );

  with info do
  begin
    pchBuffer := nil;
    fccIOProc := FOURCC_DOS;
    adwInfo[0] := Stream.Handle;
  end;

  // Initialization...
  mmIO := mmioOpen( nil,  @info, MMIO_READ );
  try
    Init( mmIO, Size, Offset, wfxInfo );
  finally
    // close file
    if (mmIO <> 0) then	mmioClose( mmIO, MMIO_FHOPEN);
  end;
end;


// Given a pointer to a wave file returns:
// Size of the wave
// Pointer to the wave start
// Wave info
procedure GetMemoryWaveInfo( Buffer: Pointer; BufferSize: Longint;
  var Size: Longint; var Data: Pointer; var wfxInfo: TWaveFormatEx);
var
  info: TMMIOINFO;
  mmIO: hmmIO;
begin
  ZeroMemory( @info, sizeof(info) );

  with info do
  begin
    pchBuffer := Buffer;
    fccIOProc := FOURCC_MEM;
    cchBuffer := BufferSize;
  end;

  // Initialization...
  mmIO := mmioOpen( nil,  @info, MMIO_READ );
  try
    Init( mmIO, Size, Longint(Data), wfxInfo );
  finally
    // close file
    if (mmIO <> 0) then	mmioClose( mmIO, 0);
  end;
end;


procedure Init( mmIO: hmmIO; var Size: Longint;
  var Offset: Longint; var wfxInfo: TWaveFormatEx);
var
  ckRIFF, ckIn: TMMCKInfo;
  mmIOInfo: TMMIOInfo;
  ck: TMMCKInfo;
	WaveFormat: TPCMWAVEFORMAT;  // Temp PCM structure to load in.
	ExtraAlloc: Word;               // Extra bytes for waveformatex
begin
  try
    if (mmIO = 0) then
      raise EWaveError.Create( 'Couldn''t open wave file ' );

    if (mmioDescend(mmIO, @ckRIFF, nil, 0) <> 0) then
      raise EWaveError.Create( 'Invalid multimedia file!' );

    if (ckRIFF.ckid <> FOURCC_RIFF)
    or (ckRIFF.fccType <> mmioFOURCC('W', 'A', 'V', 'E')) then
      raise EWaveError.Create( 'Not a wave file!' );

    // Search the input file for for the 'fmt ' chunk.     */
    ck.ckid := mmioFOURCC('f', 'm', 't', ' ');
    if (mmioDescend(mmIO, @ck, @ckRIFF, MMIO_FINDCHUNK) <> 0) then
      raise EWaveError.Create( 'Couldn''t find ''fmt'' chunk!' );

    // Expect the 'fmt' chunk to be at least as large as <PCMWAVEFORMAT>;
    // if there are extra parameters at the end, we'll ignore them */
    if (ck.cksize < 16) then
      raise EWaveError.Create( 'Abnormal ''fmt'' size!' );

    // Read the 'fmt ' chunk into <pcmWaveFormat>.*/
    if (mmioRead(mmIO, PChar(@WaveFormat), sizeof(TPCMWaveFormat)) <>
      sizeof(TPCMWaveFormat)) then
      raise EWaveError.Create( 'Error reading ''fmt'' chunk!' );

    // Ok, allocate the waveformatex, but if its not pcm
    // format, read the next word, and thats how many extra
    // bytes to allocate.
    if (WaveFormat.wf.wFormatTag = WAVE_FORMAT_PCM) then
      ExtraAlloc := 0
    else
      // Read in length of extra bytes.
      if (mmioRead(mmIO, @ExtraAlloc, sizeof(ExtraAlloc)) <>
        sizeof(ExtraAlloc)) then
        raise EWaveError.Create( 'Error reading ''waveformatex'' length!' );

    // Copy the bytes from the pcm structure to the waveformatex structure
    CopyMemory( @wfxInfo, @WaveFormat, sizeof(TPCMWaveFormat) );
    wfxInfo.cbSize := sizeof(TPCMWaveFormat);

    // Ascend the input file out of the 'fmt ' chunk. */
    if (mmioAscend(mmIO, @ck, 0) <> 0) then
      raise EWaveError.Create( 'Error ascending from ''fmt'' chunk!' );

    // Do a nice little seek...
    if (mmioSeek(mmIO, ckRIFF.dwDataOffset
    + sizeof(FOURCC), SEEK_SET) = -1) then
      raise EWaveError.Create( 'Error seeking data!' );

    //      Search the input file for for the 'data' chunk.
    ckIn.ckid := mmioFOURCC('d', 'a', 't', 'a');
    mmioDescend(mmIO, @ckIn, @ckRIFF, MMIO_FINDCHUNK);

  	if (mmioGetInfo(mmIO, @mmioInfo, 0) <> 0) then
      raise EWaveError.Create('Error getting info!');

    Size := ckIn.cksize;
    Offset := mmioInfo.lDiskOffset;
    if (Offset = 0) then
      Offset := Longint(mmioInfo.pchNext);

  except
    on Exception do
      begin
        if mmIO <> 0 then mmioClose(mmIO, 0);
        raise;
      end;
  end;
end;


procedure WaveLoadFile( FileName: String; var Size: Longint;
  var wfxInfoPtr: PWaveFormatEx; var Data: Pointer );
var
  fs: TFileStream;
  Offset: Longint;
begin
  fs := TFileStream.Create( FileName, fmOpenRead );
  try
    GetMem(wfxInfoPtr, sizeof(TWaveFormatEx));
    GetStreamWaveInfo( fs, Size, Offset, wfxInfoPtr^ );

    GetMem( Data, Size );
    fs.Position := Offset;
    fs.Read( Data^, Size );
  finally
    fs.Free;
  end;
end;

end.
