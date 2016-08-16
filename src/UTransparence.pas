unit UTransparence;

interface
uses OpenGL, Glaux, Sysutils, Windows, Utextures, UTypege;

function CreerMasque(CheminMasque,CheminImage : string) : GLUint;

implementation

Procedure glBindTexture(target: GLEnum;
                           texture: GLuint);
                           Stdcall; External 'OpenGL32.dll';
Procedure glGenTextures(n: GLsizei;
                           Textures: PGLuint);
                           Stdcall; External 'OpenGL32.dll';


{-------------------------------------------------------------------------------
 -
 -  Elemination des parties noires d'un objet
 -  Retourne la liste d'affichage nouvellement creee
 -
 -------------------------------------------------------------------------------}
function CreerMasque(CheminMasque,CheminImage : string) : GLUint;
var NouvelleListe, Masque,Image : GLUint; pTextures : PTAUX_RGBImageRec;
begin

    {Creation d'une texture masque}
    glGenTextures( 1, @Masque);
    If FileExists(CheminMasque) then
    begin
       pTextures := auxDIBImageLoadA(PChar(CheminMasque));
       If Assigned(pTextures) then
       begin
         glBindTexture(GL_TEXTURE_2D, Masque);
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
         glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
         glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, pTextures^.SizeX, pTextures^.SizeY,
                       0, GL_RGB, GL_UNSIGNED_BYTE, pTextures^.Data);
       end;
    end;

    {Creation d'une texture image}
    glGenTextures( 1, @Image);
    If FileExists(CheminImage) then
    begin
       pTextures := auxDIBImageLoadA(PChar(CheminImage));
       If Assigned(pTextures) then
       begin
         glBindTexture(GL_TEXTURE_2D, Image);
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
         glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
         glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, pTextures^.SizeX, pTextures^.SizeY,
                       0, GL_RGB, GL_UNSIGNED_BYTE, pTextures^.Data);
       end;
    end;

  if (glIsList(NouvelleListe)) then glDeleteLists(NouvelleListe,1);
  NouvelleListe := glGenLists(1);
  glNewList(NouvelleListe,GL_COMPILE);

  glDisable(GL_CULL_FACE);
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);

  glpushMatrix();
    glBlendFunc(GL_DST_COLOR,GL_ZERO);
    glBindTexture(GL_TEXTURE_2D, Masque);
    glcolor3f(1,1,1);
    glBegin(GL_QUADS);
      glTexCoord2f(0.0, 0.0); glVertex2f(-1.1, -1.1);
      glTexCoord2f(1.0, 0.0); glVertex2f( 1.1, -1.1);
      glTexCoord2f(1.0, 1.0); glVertex2f( 1.1,  1.1);
      glTexCoord2f(0.0, 1.0); glVertex2f(-1.1,  1.1);
    glEnd();
   glpopMatrix();

   glpushMatrix();
    glBlendFunc(GL_ONE, GL_ONE);
    glBindTexture(GL_TEXTURE_2D, Image);
    glcolor3f(1,1,1);
    glBegin(GL_QUADS);
      glTexCoord2f(0.0, 0.0); glVertex2f(-1.1, -1.1);
      glTexCoord2f(1.0, 0.0); glVertex2f( 1.1, -1.1);
      glTexCoord2f(1.0, 1.0); glVertex2f( 1.1,  1.1);
      glTexCoord2f(0.0, 1.0); glVertex2f(-1.1,  1.1);
    glEnd();
   glpopMatrix();

  glEnable(GL_DEPTH_TEST);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glEnable(GL_CULL_FACE);

  glEndList();
  result := NouvelleListe;
end;

end.
