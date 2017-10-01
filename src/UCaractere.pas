unit UCaractere;

interface

USES
opengl,
Windows,
SysUtils,
URepere,
Messages;

procedure glTexte(posx,posy, colorr,colorg,colorb : glfloat; texte : string);

VAR
base : Gluint;
h_DC : HDC;

implementation
uses UTypege;

//----------------------------------------------------------------------------//
procedure KillFont;
begin
  glDeleteLists(base, 96);
end;

//----------------------------------------------------------------------------//
procedure glPrint(text : pchar);
begin
  if (text = '') then Exit;
  glPushMatrix;
    glListBase(base - 32);
    glCallLists(length(text), GL_UNSIGNED_BYTE, text);
  glPopMatrix;
end;

procedure glTexte(posx,posy, colorr,colorg,colorb : glfloat; texte : string);
begin
    glPushMatrix;
      OrthoMode(0,0,Params.Width,Params.Height);//1600,1200);
      glColor3f(colorr, colorg, colorb);
      glRasterpos2f(posx,posy);
      glPrint(@texte[1]);
      PerspectiveMode;
    glPopMatrix;
end;


end.
