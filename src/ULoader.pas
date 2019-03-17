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
unit ULoader;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
   StdCtrls,
   UTypege,
   UMath,
   GLAUX,
   UTextures,
   opengl;


var
   InFile : text;
   buffer : string;
   TROUDUC : integer = -1;
   {Déclaration des procédures "OpenGL32.dll" utiles au texture car elle
    n'est pas dans le Unit OpenGL.pas}
   Procedure glBindTexture(target: GLEnum;
                           texture: GLuint);
   Stdcall; External 'OpenGL32.dll';
   // Procedure glGenTextures(n: GLsizei;
   //                         Textures: PGLuint);
   //                         Stdcall; External 'OpenGL32.dll';
   //Procedure glDeleteTextures(n: GLsizei;
   //                         textures: PGLuint);
   //                         Stdcall; External 'OpenGL32.dll';

   procedure loaderAse(NomDossier : string; NomFich : string; obj : pobjet; ModeNuit : boolean);
   procedure libererobjet(var Obj : TObjet);

implementation

{Procedure CreerTexture(TAB_CHEMIN_BITMAP : String; obj : pObjet);
 Var
 pTextures         :PTAUX_RGBImageRec;
 Msg_Erreur        :String;
 Begin
 glGenTextures( 1, @obj^.TextureQueue^.Id);
 If FileExists( TAB_CHEMIN_BITMAP ) Then
 Begin
 pTextures := auxDIBImageLoadA( PChar(TAB_CHEMIN_BITMAP) );
 If Assigned( pTextures ) Then
 Begin
 glBindTexture(GL_TEXTURE_2D, obj^.TextureQueue^.Id);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
 GL_LINEAR);
 //GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
 GL_LINEAR);
 //GL_NEAREST);
 glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
 glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB,
 pTextures^.SizeX, pTextures^.SizeY,
 0, GL_RGB, GL_UNSIGNED_BYTE,
 pTextures^.Data);
 End Else
 Begin
 Msg_Erreur := 'Erreur au chargement de la texture "' + TAB_CHEMIN_BITMAP + '"';
 MessageBox( 0, PChar(Msg_Erreur), 'Textures', MB_OK And MB_ICONWARNING );
 End;
 End Else
 Begin
 Msg_Erreur := 'Texture : "' + TAB_CHEMIN_BITMAP + '" n''a pas' + ' été trouvée';
 MessageBox( 0, PChar(Msg_Erreur), 'Textures', MB_OK And MB_ICONWARNING );
 End;
 End;}

procedure CreerTexture(const TAB_CHEMIN_BITMAP : String; obj : pObjet);
var MaTexture : gluint;
begin
   LoadTexture(TAB_CHEMIN_BITMAP, MaTexture, FALSE);
   obj^.TextureQueue^.Id := MaTexture;
end;

//------------------------------------------------------------------------------------------

function recherche(s2, s1: string) : boolean;
var
   i, j, taille1, taille2 : integer;
begin
   i := 1;
   j := 1;
   taille1 := length(s1);
   taille2 := length(s2);
   while (i<=taille1) and (j<=taille2) do begin
      j := 1;
      while (i+j-1<=taille1) and (j<=taille2) and (s1[i+j-1]=s2[j]) do begin
         j := j+1;
      end;
      i := i+1;
   end;
   result:= j>taille2
end;

//------------------------------------------------------------------------------------------

function convertfloat(buffer : string; nbr : integer) : GLFloat;
var retour : GLFloat;
i, j, lon, V : integer;
begin
   i := 1;
   j := 1;
   lon := length(buffer);
   while (i<=lon) and (buffer[i]<>'*') do
      inc(i);
   while nbr>0 do
   begin
      while (i<=lon) and (ord(buffer[i])<>$09) do
         inc(i);
      dec(nbr);
      inc(i);
   end;
   while (i+j<=lon) and (buffer[i+j]<>'.') do
      inc(j);
   inc(j);
   while (i+j<=lon) and (ord(buffer[i+j])>=ord('0')) and (ord(buffer[i+j])<=ord('9')) do
      inc(j);
   val(copy(buffer, i, j), retour, V);
   result := retour;
end;
//------------------------------------------------------------------------------------------

procedure loadmateriauxlist (NomDossier : string; obj : pObjet; bool : boolean);
var i,j,long,k : integer;  chaine : string;
s1 : string;
begin
   obj^.TextureQueue := @obj^.TextureHead;
   while buffer[1]<>'}' do
   begin
      readln(Infile, buffer);
      if recherche('*MATERIAL_TRANSPARENCY ', buffer) then
      begin
         long := length(buffer);
         i := 0;
         chaine := '';
         while (long-i >= 1) and (buffer[long-i] <> ' ')  do
         begin
            if buffer[long-i] = '.' then buffer[long-i] := ',';
            chaine := buffer[long-i] + chaine;
            i := i+1;
         end;
         obj^.TextureQueue^.Transparency := MyStrToFloat(chaine);
      end else
         if (recherche('*BITMAP ', buffer))then
         begin
            s1 := '';
            j := 1;
            k := length(buffer);
            while (j<=k) and (buffer[j]<>'"') do
               inc(j);
            inc(j);
            while (j<=k) and (buffer[j]<>'"') do
            begin
               if buffer[j]='\' then
                  s1 := '';
               s1 := s1 + buffer[j];
               inc(j);
            end;
            s1 := NomDossier + '\textures\' + s1;

            //on change s1 pour devenir s1_nuit.bmp
            if bool then
            begin
               long := length(s1);
               delete(s1,long-3,4);
               s1 := s1 + '_nuit.bmp';
            end;

            CreerTexture(s1, obj);
         end else
            if recherche('*UVW_U_TILING ', buffer) then
            begin
               long := length(buffer);
               i := 0;
               chaine := '';
               while (long-i >= 1) and (buffer[long-i] <> ' ')  do
               begin
                  if buffer[long-i] = '.' then buffer[long-i] := ',';
                  chaine := buffer[long-i] + chaine;
                  i := i+1;
               end;
               obj^.TextureQueue^.Utiling := MyStrToFloat(chaine);
            end else
               if recherche('*UVW_V_TILING ', buffer) then
               begin
                  long := length(buffer);
                  i := 0;
                  chaine := '';
                  while (long-i >= 1) and (buffer[long-i] <> ' ')  do
                  begin
                     if buffer[long-i] = '.' then buffer[long-i] := ',';
                     chaine := buffer[long-i] + chaine;
                     i := i+1;
                  end;
                  obj^.TextureQueue^.Vtiling := MyStrToFloat(chaine);
                  obj^.TextureQueue^.Next := AllocMem(SizeOf(TTexture));
                  obj^.TextureQueue := obj^.TextureQueue^.Next;
               end;
   end;
end;

//------------------------------------------------------------------------------------------

function loadPvertex(nbr : integer; obj : pObjet) : PVertex;
var i : integer;
begin
   obj^.MeshQueue^.VertexQueue := @obj^.MeshQueue^.VertexHead;
   i := 0;
   while i<nbr do
   begin
      obj^.MeshQueue^.VertexQueue := obj^.MeshQueue^.VertexQueue^.Next;
      inc(i);
   end;
   result := obj^.MeshQueue^.VertexQueue;
end;

//------------------------------------------------------------------------------------------

function loadPTex(nbr : integer; obj : pObjet) : PVertex;
var i : integer;
begin
   obj^.MeshQueue^.CoordTextQueue := @obj^.MeshQueue^.CoordTextHead;
   i := 0;
   while i<nbr do
   begin
      obj^.MeshQueue^.CoordTextQueue := obj^.MeshQueue^.CoordTextQueue^.Next;
      inc(i);
   end;
   result := obj^.MeshQueue^.CoordTextQueue;
end;

//------------------------------------------------------------------------------------------

procedure loadvertex(obj : pObjet);
begin
   obj^.MeshQueue^.VertexQueue := @obj^.MeshQueue^.VertexHead;
   while not recherche('}', buffer) do
   begin
      readln(Infile, buffer);
      if (recherche('*MESH_VERTEX ', buffer))then
      begin
         obj^.MeshQueue^.VertexQueue^.x := convertfloat(buffer, 1);
         obj^.MeshQueue^.VertexQueue^.z := convertfloat(buffer, 2);
         obj^.MeshQueue^.VertexQueue^.y := convertfloat(buffer, 3);
         obj^.MeshQueue^.VertexQueue^.Next := AllocMem(SizeOf(TVertex));
         obj^.MeshQueue^.VertexQueue := obj^.MeshQueue^.VertexQueue^.Next;
      end;
   end;
   readln(Infile, buffer);
end;

//------------------------------------------------------------------------------------------

procedure loadTex(obj : pObjet);
begin
   obj^.MeshQueue^.CoordTextQueue := @obj^.MeshQueue^.CoordTextHead;
   while not recherche('}', buffer) do
   begin
      readln(Infile, buffer);
      if (recherche('*MESH_TVERT ', buffer))then
      begin
         obj^.MeshQueue^.CoordTextQueue^.x := convertfloat(buffer, 1);
         obj^.MeshQueue^.CoordTextQueue^.y := convertfloat(buffer, 2);
         obj^.MeshQueue^.CoordTextQueue^.z := convertfloat(buffer, 3);
         obj^.MeshQueue^.CoordTextQueue^.Next := AllocMem(SizeOf(TVertex));
         obj^.MeshQueue^.CoordTextQueue := obj^.MeshQueue^.CoordTextQueue^.Next;
      end;
   end;
   readln(Infile, buffer);
end;

//------------------------------------------------------------------------------------------
procedure loadface(obj : pobjet);
var
   i, j, valeur, V : integer;
   A,B,C : Tvecteur;
begin
   obj^.MeshQueue^.FaceQueue := @obj^.MeshQueue^.FaceHead;
   while not recherche('}', buffer) do
   begin
      readln(Infile, buffer);
      if (recherche('*MESH_FACE ', buffer))then
      begin
         i := 1;
         j := 1;
         while (buffer[i]<>'A') or (buffer[i+1]<>':') do
            inc(i);
         i := i+2;
         while buffer[i]=' ' do
            inc(i);
         while buffer[i+j]<>' ' do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.v[1] := loadPvertex(valeur, obj);

         j := 1;
         while (buffer[i]<>'B') and (buffer[i+1]<>':') do
            inc(i);
         i := i+2;
         while buffer[i]=' ' do
            inc(i);
         while buffer[i+j]<>' ' do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.v[2] := loadPvertex(valeur, obj);

         j := 1;
         while (buffer[i]<>'C') and (buffer[i+1]<>':') do
            inc(i);
         i := i+2;
         while buffer[i]=' ' do
            inc(i);
         while buffer[i+j]<>' ' do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.v[3] := loadPvertex(valeur, obj);

         A.x := obj^.MeshQueue^.FaceQueue^.v[1].x;
         A.y := obj^.MeshQueue^.FaceQueue^.v[1].y;
         A.z := obj^.MeshQueue^.FaceQueue^.v[1].z;

         B.x := obj^.MeshQueue^.FaceQueue^.v[2].x;
         B.y := obj^.MeshQueue^.FaceQueue^.v[2].y;
         B.z := obj^.MeshQueue^.FaceQueue^.v[2].z;

         C.x := obj^.MeshQueue^.FaceQueue^.v[3].x;
         C.y := obj^.MeshQueue^.FaceQueue^.v[3].y;
         C.z := obj^.MeshQueue^.FaceQueue^.v[3].z;

         obj^.MeshQueue^.FaceQueue^.Normale := CreerNormale(A,C,B);

         obj^.MeshQueue^.FaceQueue^.Next := AllocMem(SizeOf(TFace));
         obj^.MeshQueue^.FaceQueue := obj^.MeshQueue^.FaceQueue^.Next;
      end;
   end;
end;

//------------------------------------------------------------------------------------------

procedure loadTexFace(obj : pobjet);
var
   i, j, lon, valeur, V : integer;
begin
   obj^.MeshQueue^.FaceQueue := @obj^.MeshQueue^.FaceHead;
   while not recherche('}', buffer) do
   begin
      readln(Infile, buffer);
      if (recherche('*MESH_TFACE ', buffer))then
      begin
         i := 1;
         j := 1;
         lon := length(buffer);
         while (i<=lon) and (buffer[i]<>'*') do
            inc(i);
         while (i<=lon) and (buffer[i]<>#09) do
            inc(i);
         inc(i);
         while (i+j<=lon) and (ord(buffer[i+j])>=ord('0')) and (ord(buffer[i+j])<=ord('9')) do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.TextCoord[1] := loadPTex(valeur, obj);

         i := i+j+1;
         j := 1;
         while (i+j<=lon) and (ord(buffer[i+j])>=ord('0')) and (ord(buffer[i+j])<=ord('9')) do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.TextCoord[2] := loadPTex(valeur, obj);

         i := i+j+1;
         j := 1;
         while (i+j<=lon) and (ord(buffer[i+j])>=ord('0')) and (ord(buffer[i+j])<=ord('9')) do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.MeshQueue^.FaceQueue^.TextCoord[3] := loadPTex(valeur, obj);

         obj^.MeshQueue^.FaceQueue := obj^.MeshQueue^.FaceQueue^.Next;
      end;
   end;
end;


//------------------------------------------------------------------------------------------

procedure loadCamera();
var i,long : integer; chaine : string;
begin

   //recherche position de la camera
   while not(recherche('*TM_POS',buffer)) do readln(Infile, buffer);
   if (recherche('*TM_POS',buffer)) then
   begin

      //Camera.position.z
      long := length(buffer);
      i := 0;
      chaine := '';
      while (long-i>=1) and (ord(buffer[long-i])<>$09)  do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Position.z :=  MyStrToFloat(chaine);

      //Camera.position.y
      long := length(buffer);
      i := i+1;
      chaine := '';
      while (long-i>=1) and (ord(buffer[long-i]) <> $09) do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Position.y := MyStrToFloat(chaine);

      //Camera.position.x
      long := length(buffer);
      i := i+1;
      chaine := '';
      while (long-i>=1) and (buffer[long-i] <> ' ') do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Position.x := MyStrToFloat(chaine);
   end;


   //recherche position de la camera.target
   readln(Infile, buffer);
   while not(recherche('*TM_POS',buffer)) do readln(Infile, buffer);
   if (recherche('*TM_POS',buffer)) then
   begin

      //Camera.position.z
      long := length(buffer);
      i := 0;
      chaine := '';
      while (long-i>=1) and (ord(buffer[long-i])<>$09)  do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Target.z :=  MyStrToFloat(chaine);

      //Camera.position.y
      long := length(buffer);
      i := i+1;
      chaine := '';
      while (long-i>=1) and (ord(buffer[long-i]) <> $09) do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Target.y := MyStrToFloat(chaine);

      //Camera.position.x
      long := length(buffer);
      i := i+1;
      chaine := '';
      while (long-i>=1) and (buffer[long-i] <> ' ') do
      begin
         if buffer[long-i] = '.' then buffer[long-i] := ',';
         chaine := buffer[long-i] + chaine;
         i := i+1;
      end;
      Camera.Target.x := MyStrToFloat(chaine);
   end;

end;


//------------------------------------------------------------------------------------------

procedure loadMesh (obj : pobjet);
var
   i, j, valeur, lon, V : integer;
begin
   obj^.MeshQueue := @Obj^.MeshHead;
   while not EOF(InFile) do
   begin
      readln(Infile, buffer);

      //camera
      if (recherche('*CAMERAOBJECT {', buffer)) then loadCamera();

      if (recherche('*MESH_VERTEX_LIST {', buffer))then loadvertex(obj);
      if (recherche('*MESH_FACE_LIST {', buffer))then
      begin
         loadface(obj);
         //loadnormal(obj);
      end;
      if (recherche('*MESH_TVERTLIST {', buffer))then loadTex(obj);
      if (recherche('*MESH_TFACELIST {', buffer))then loadTexFace(obj);
      if (recherche('*MATERIAL_REF ', buffer))then
      begin
         i := 1;
         j := 1;
         lon := length(buffer);
         while (i<=lon) and ((ord(buffer[i])<ord('0')) or (ord(buffer[i])>ord('9'))) do
            inc(i);
         while (i+j<=lon) and (ord(buffer[i+j])>=ord('0')) and (ord(buffer[i+j])<=ord('9')) do
            inc(j);
         val(copy(buffer, i, j), valeur, V);
         obj^.TextureQueue := @obj^.TextureHead;
         while valeur>0 do
         begin
            obj^.TextureQueue := obj^.TextureQueue^.Next;
            dec(valeur);
         end;
         obj^.MeshQueue^.Texture := obj^.TextureQueue;
      end;
      if recherche('*MESH {',buffer) then
      begin
         obj^.MeshQueue^.Next := AllocMem(SizeOf(TMesh));
         obj^.MeshQueue := obj^.MeshQueue^.Next;
      end;
   end;
end;

//------------------------------------------------------------------------------------------

procedure loaderAse(NomDossier : string; NomFich : string; obj : pobjet; ModeNuit : boolean);
var NomComplet: String;
begin
   NomComplet := NomDossier + '\' + NomFich;
   if not(FileExists(NomComplet)) then
      ShowMessage(NomComplet + ' n''existe pas')
   else
   begin
      AssignFile(InFile, NomComplet);
      Reset(InFile);
      while not EOF(InFile) do
      begin
         readln(Infile, buffer);

         if (recherche('*MATERIAL_LIST {', buffer)) then loadmateriauxlist(NomDossier,obj,ModeNuit);
         if (recherche('*MESH {', buffer))then loadmesh(obj);
      end;
      CloseFile(InFile);

      obj.Liste := glGenLists(1);
      glNewList(obj.liste,GL_COMPILE);

      glpushmatrix;
      glrotated(90,1,0,0);
      glcolor3f(1,1,1);
      glEnable(GL_TEXTURE_2D);
      Obj.MeshQueue := @Obj.MeshHead;
      while Obj.MeshQueue<>NIL do
      begin
         Obj^.MeshQueue^.FaceQueue := @Obj^.MeshQueue^.FaceHead;
         glBindTexture( GL_TEXTURE_2D, Obj^.MeshQueue^.Texture^.Id );
         glBegin(GL_TRIANGLES);
         while Obj^.MeshQueue^.FaceQueue^.Next<>NIL do
         begin
            glnormal(obj^.MeshQueue^.FaceQueue^.Normale.x,
                     obj^.MeshQueue^.FaceQueue^.Normale.y,
                     obj^.MeshQueue^.FaceQueue^.Normale.z);

            glTexCoord3f(Obj^.MeshQueue^.FaceQueue^.TextCoord[1].x*Obj^.MeshQueue^.Texture^.Utiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[1].y*Obj^.MeshQueue^.Texture^.Vtiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[1].z);
            glVertex3f(Obj^.MeshQueue^.FaceQueue^.v[1].x,
                       Obj^.MeshQueue^.FaceQueue^.v[1].y,
                       Obj^.MeshQueue^.FaceQueue^.v[1].z );
            glTexCoord3f(Obj^.MeshQueue^.FaceQueue^.TextCoord[2].x*Obj^.MeshQueue^.Texture^.Utiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[2].y*Obj^.MeshQueue^.Texture^.Vtiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[2].z);
            glVertex3f(Obj^.MeshQueue^.FaceQueue^.v[2].x,
                       Obj^.MeshQueue^.FaceQueue^.v[2].y,
                       Obj^.MeshQueue^.FaceQueue^.v[2].z );
            glTexCoord3f(Obj^.MeshQueue^.FaceQueue^.TextCoord[3].x*Obj^.MeshQueue^.Texture^.Utiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[3].y*Obj^.MeshQueue^.Texture^.Vtiling,
                         Obj^.MeshQueue^.FaceQueue^.TextCoord[3].z);
            glVertex3f(Obj^.MeshQueue^.FaceQueue^.v[3].x,
                       Obj^.MeshQueue^.FaceQueue^.v[3].y,
                       Obj^.MeshQueue^.FaceQueue^.v[3].z );

            Obj^.MeshQueue^.FaceQueue := Obj^.MeshQueue^.FaceQueue^.Next;
         end;
         glEnd();
         Obj^.MeshQueue := Obj^.MeshQueue^.Next;
      end;
      glDisable(GL_TEXTURE_2D);
      glpopmatrix;
      glEndList;
   end;
   libererobjet(Obj^);
end;

procedure libererobjet(var Obj : TObjet);
var Texture : pTexture;
Mesh : pMesh;
Vertex :pVertex;
Face : pFace;
begin
   // liberer les textures
   obj.TextureQueue := obj.TextureHead.Next;
   while obj.TextureQueue<>NIL do
   begin
      Texture := obj.TextureQueue;
      obj.TextureQueue := obj.TextureQueue.Next;
      freemem(Texture);
   end;
   // liberer les mesh
   obj.MeshQueue := obj.MeshHead.Next;
   while obj.MeshQueue<>NIL do
   begin
      // liberer les vertexs
      obj.MeshQueue.VertexQueue := obj.MeshQueue.VertexHead.Next;
      while obj.MeshQueue.VertexQueue<>NIL do
      begin
         Vertex := obj.MeshQueue.VertexQueue;
         obj.MeshQueue.VertexQueue := obj.MeshQueue.VertexQueue.Next;
         freemem(Vertex);
      end;
      // liberer les faces
      obj.MeshQueue.FaceQueue := obj.MeshQueue.FaceHead.Next;
      while obj.MeshQueue.FaceQueue<>NIL do
      begin
         Face := obj.MeshQueue.FaceQueue;
         obj.MeshQueue.FaceQueue := obj.MeshQueue.FaceQueue.Next;
         freemem(Face);
      end;
      // liberer les vertexs
      obj.MeshQueue.CoordTextQueue := obj.MeshQueue.CoordTextHead.Next;
      while obj.MeshQueue.CoordTextQueue<>NIL do
      begin
         Vertex := obj.MeshQueue.CoordTextQueue;
         obj.MeshQueue.CoordTextQueue := obj.MeshQueue.CoordTextQueue.Next;
         freemem(Vertex);
      end;
      Mesh := obj.MeshQueue;
      obj.MeshQueue := obj.MeshQueue.Next;
      freemem(Mesh);
   end;
   // liberer les textures
   // liberer les textures
   // liberer les textures
end;

end.

