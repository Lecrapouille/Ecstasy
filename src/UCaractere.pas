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
unit UCaractere;

interface

USES
   opengl,
   Windows,
   SysUtils,
   URepere,
   Messages;

procedure glTexte(posx,posy, colorr,colorg,colorb : glfloat; texte : string);
procedure KillFont;
//procedure BuildFont( police : integer);

VAR
   base : Gluint;
   h_DC : HDC;

implementation
uses UTypege;

//----------------------------------------------------------------------------//
{procedure BuildFont( police : integer);
var font: HFONT;
begin
   base := glGenLists(96);
   font := CreateFont(-1* police,
                      0,
                      0,
                      0,
                      FW_BOLD,
                      0,
                      0,
                      0,
                      ANSI_CHARSET,
                      OUT_TT_PRECIS,
                      CLIP_DEFAULT_PRECIS,
                      ANTIALIASED_QUALITY,
                      FF_DONTCARE or DEFAULT_PITCH,
                      'Times New Roman');

   SelectObject(h_DC, font);
   wglUseFontBitmaps(h_DC, 32, 96, base);
end;}

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
