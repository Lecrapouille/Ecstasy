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
unit UFrustum;

interface
uses
   OpenGL,
   UMath,
   Math;

type

   TFrustumSide = (fsRight, fsLeft, fsBottom, fsTop, fsBack, fsFront);
   TPlaneData = (pdA, pdB, pdC, pdD);
   TFrustumArray = array[TFrustumSide, TPlaneData] of Single;

   TFrustum = class(Tobject)
   private
      FFrustum : TFrustumArray;
      procedure NormalizePlane(var frustum: TFrustumArray; side: TFrustumSide);
   public
      procedure CalculateFrustum;
      function PointInFrustum(const x, y, z: Single): Boolean;
      function SphereInFrustum(const x, y, z, radius: Single): Boolean;
      function CubeInFrustum(const x, y, z, size: Single): Boolean;
      function BoxInFrustum(const pA: TVecteur; sizeX, sizeY, tx, ty: real): Boolean;
end;

var Myfrust : TFrustum;

implementation

procedure TFrustum.NormalizePlane(var frustum: TFrustumArray; side: TFrustumSide);
var
   recipMagnitude: Single;
begin
   recipMagnitude := 1 / sqrt(frustum[side][pdA]*frustum[side][pdA] +
                              frustum[side][pdB]*frustum[side][pdB] +
                              frustum[side][pdC]*frustum[side][pdC]);

   frustum[side][pdA] := frustum[side][pdA]*recipMagnitude;
   frustum[side][pdB] := frustum[side][pdB]*recipMagnitude;
   frustum[side][pdC] := frustum[side][pdC]*recipMagnitude;
   frustum[side][pdD] := frustum[side][pdD]*recipMagnitude;
end;


procedure TFrustum.CalculateFrustum;
var
   proj: array[0..15] of Single; // Matrice de projection
   modl: array[0..15] of Single; // Matrice Modelview
   clip: array[0..15] of Single; // Plans de clipping
begin
   glGetFloatv(GL_PROJECTION_MATRIX, @proj[0]);
   glGetFloatv(GL_MODELVIEW_MATRIX, @modl[0]);

   clip[ 0] := modl[ 0]*proj[ 0] + modl[ 1]*proj[ 4] + modl[ 2]*proj[ 8] + modl[ 3]*proj[12];
   clip[ 1] := modl[ 0]*proj[ 1] + modl[ 1]*proj[ 5] + modl[ 2]*proj[ 9] + modl[ 3]*proj[13];
   clip[ 2] := modl[ 0]*proj[ 2] + modl[ 1]*proj[ 6] + modl[ 2]*proj[10] + modl[ 3]*proj[14];
   clip[ 3] := modl[ 0]*proj[ 3] + modl[ 1]*proj[ 7] + modl[ 2]*proj[11] + modl[ 3]*proj[15];

   clip[ 4] := modl[ 4]*proj[ 0] + modl[ 5]*proj[ 4] + modl[ 6]*proj[ 8] + modl[ 7]*proj[12];
   clip[ 5] := modl[ 4]*proj[ 1] + modl[ 5]*proj[ 5] + modl[ 6]*proj[ 9] + modl[ 7]*proj[13];
   clip[ 6] := modl[ 4]*proj[ 2] + modl[ 5]*proj[ 6] + modl[ 6]*proj[10] + modl[ 7]*proj[14];
   clip[ 7] := modl[ 4]*proj[ 3] + modl[ 5]*proj[ 7] + modl[ 6]*proj[11] + modl[ 7]*proj[15];

   clip[ 8] := modl[ 8]*proj[ 0] + modl[ 9]*proj[ 4] + modl[10]*proj[ 8] + modl[11]*proj[12];
   clip[ 9] := modl[ 8]*proj[ 1] + modl[ 9]*proj[ 5] + modl[10]*proj[ 9] + modl[11]*proj[13];
   clip[10] := modl[ 8]*proj[ 2] + modl[ 9]*proj[ 6] + modl[10]*proj[10] + modl[11]*proj[14];
   clip[11] := modl[ 8]*proj[ 3] + modl[ 9]*proj[ 7] + modl[10]*proj[11] + modl[11]*proj[15];

   clip[12] := modl[12]*proj[ 0] + modl[13]*proj[ 4] + modl[14]*proj[ 8] + modl[15]*proj[12];
   clip[13] := modl[12]*proj[ 1] + modl[13]*proj[ 5] + modl[14]*proj[ 9] + modl[15]*proj[13];
   clip[14] := modl[12]*proj[ 2] + modl[13]*proj[ 6] + modl[14]*proj[10] + modl[15]*proj[14];
   clip[15] := modl[12]*proj[ 3] + modl[13]*proj[ 7] + modl[14]*proj[11] + modl[15]*proj[15];

   // Plan de clipping droit :
   fFrustum[fsRIGHT][pdA] := clip[ 3] - clip[ 0];
   fFrustum[fsRIGHT][pdB] := clip[ 7] - clip[ 4];
   fFrustum[fsRIGHT][pdC] := clip[11] - clip[ 8];
   fFrustum[fsRIGHT][pdD] := clip[15] - clip[12];
   NormalizePlane(fFrustum, fsRIGHT);

   // Plan de clipping gauche :
   fFrustum[fsLEFT][pdA] := clip[ 3] + clip[ 0];
   fFrustum[fsLEFT][pdB] := clip[ 7] + clip[ 4];
   fFrustum[fsLEFT][pdC] := clip[11] + clip[ 8];
   fFrustum[fsLEFT][pdD] := clip[15] + clip[12];
   NormalizePlane(fFrustum, fsLEFT);

   // Plan de clipping bas :
   fFrustum[fsBOTTOM][pdA] := clip[ 3] + clip[ 1];
   fFrustum[fsBOTTOM][pdB] := clip[ 7] + clip[ 5];
   fFrustum[fsBOTTOM][pdC] := clip[11] + clip[ 9];
   fFrustum[fsBOTTOM][pdD] := clip[15] + clip[13];
   NormalizePlane(fFrustum, fsBOTTOM);

   // Plan de clipping haut :
   fFrustum[fsTOP][pdA] := clip[ 3] - clip[ 1];
   fFrustum[fsTOP][pdB] := clip[ 7] - clip[ 5];
   fFrustum[fsTOP][pdC] := clip[11] - clip[ 9];
   fFrustum[fsTOP][pdD] := clip[15] - clip[13];
   NormalizePlane(fFrustum, fsTOP);

   // Plan de clipping lointain :
   fFrustum[fsBACK][pdA] := clip[ 3] - clip[ 2];
   fFrustum[fsBACK][pdB] := clip[ 7] - clip[ 6];
   fFrustum[fsBACK][pdC] := clip[11] - clip[10];
   fFrustum[fsBACK][pdD] := clip[15] - clip[14];
   NormalizePlane(fFrustum, fsBACK);

   // Plan de clipping proche :
   fFrustum[fsFRONT][pdA] := clip[ 3] + clip[ 2];
   fFrustum[fsFRONT][pdB] := clip[ 7] + clip[ 6];
   fFrustum[fsFRONT][pdC] := clip[11] + clip[10];
   fFrustum[fsFRONT][pdD] := clip[15] + clip[14];
   NormalizePlane(fFrustum, fsFRONT);

end;


function TFrustum.PointInFrustum(const x, y, z: Single): Boolean;
var
   i: TFrustumSide;
begin
   for i := Low(TFrustumSide) to High(TFrustumSide) do
   begin
      {Distance au plan}
      if (fFrustum[i][pdA]*x + fFrustum[i][pdB]*y + fFrustum[i][pdC]*z + fFrustum[i][pdD] < 0) then
      begin
         // Le point est derrière un des plans de clipping, donc il n'est pas dans le frustum.
         Result := False;
         Exit;
      end;
   end;

   // Le point est dans le frustum.
   Result := True;
end;


function TFrustum.SphereInFrustum(const x, y, z, radius: Single): Boolean;
var
   distance: Single;
   i: TFrustumSide;
begin
   for i := Low(TFrustumSide) to High(TFrustumSide) do
   begin
      distance := fFrustum[i][pdA]*x + fFrustum[i][pdB]*y + fFrustum[i][pdC]*z + fFrustum[i][pdD];
      if distance < -radius then
      begin
         // Distance supérieure au rayon de la sphère donc celle-ci est en dehors du frustum.
         Result := False;
         Exit;
      end
      else if distance < radius then
      begin
         // La sphère intersecte le frustum.
         Result := True;
         Exit;
      end
   end;

   // La sphère est a l'interieur du frustum.
   Result := True;
end;


function TFrustum.CubeInFrustum(const x, y, z, size: Single): Boolean;
var
   i: TFrustumSide;
begin
   // Bon OK cet algo n'est pas parfait car dans de rares cas un cube en dehors du frustum est vu comme
   // dedans, mais par contre (et heureusement) le contraire ne se produit pas...

   Result := False;

   for i := Low(TFrustumSide) to High(TFrustumSide) do
   begin
      if (fFrustum[i][pdA]*(x - size) + fFrustum[i][pdB]*(y - size) + fFrustum[i][pdC]*(z - size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x + size) + fFrustum[i][pdB]*(y - size) + fFrustum[i][pdC]*(z - size) + fFrustum[i][pdD] > 0)  then
         continue;
      if (fFrustum[i][pdA]*(x - size) + fFrustum[i][pdB]*(y + size) + fFrustum[i][pdC]*(z - size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x + size) + fFrustum[i][pdB]*(y + size) + fFrustum[i][pdC]*(z - size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x - size) + fFrustum[i][pdB]*(y - size) + fFrustum[i][pdC]*(z + size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x + size) + fFrustum[i][pdB]*(y - size) + fFrustum[i][pdC]*(z + size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x - size) + fFrustum[i][pdB]*(y + size) + fFrustum[i][pdC]*(z + size) + fFrustum[i][pdD] > 0) then
         continue;
      if (fFrustum[i][pdA]*(x + size) + fFrustum[i][pdB]*(y + size) + fFrustum[i][pdC]*(z + size) + fFrustum[i][pdD] > 0) then
         continue;

      // Le cube n'est pas dans le frustum.
      Exit;
   end;

   // Le cube est dans le frustum.
   Result := True;
end;

// http://www.lighthouse3d.com/opengl/viewfrustum/
function TFrustum.BoxInFrustum(const pA: TVecteur; sizeX, sizeY, tx, ty: real): Boolean;
var
   x, y, z : real;
   i: TFrustumSide;
begin
   Result := True; // Inside

   for i := Low(TFrustumSide) to High(TFrustumSide) do
   begin
      {positive vertex}
      x := pA.x + tx; if (fFrustum[i][pdA] > 0) then x := x + sizeX;
      y := pA.y + ty; if (fFrustum[i][pdB] > 0) then y := y + sizeY;
      z := pA.z;
      if (fFrustum[i][pdA]*x + fFrustum[i][pdB]*y + fFrustum[i][pdC]*z + fFrustum[i][pdD] < 0) then
      begin
         Result := False;
         Exit;
      end;

      {Negative vertex}
      {x := pA.x + tx; if (fFrustum[i][pdA] < 0) then x := x + sizeX;
      y := pA.y + ty; if (fFrustum[i][pdB] < 0) then y := y + sizeY;
      y := pA.z;
      if (fFrustum[i][pdA]*x + fFrustum[i][pdB]*y + fFrustum[i][pdC]*z + fFrustum[i][pdD] < 0) then
      begin
         Result := True; // Intersect
      end;}
   end;
end;

end.
