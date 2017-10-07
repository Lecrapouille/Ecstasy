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
unit URepere;

interface
USES
   OpenGL;

var
   LeRepere : GLUint;

procedure OrthoMode(left,top,right,bottom : integer);
procedure PerspectiveMode;
procedure CreerRepere();
procedure DessinerRepere(x,y,z: real);


implementation
//----------------------------------------------------------------------------//


procedure OrthoMode(left,top,right,bottom : integer);
begin
   glMatrixMode(GL_PROJECTION);
   // Push on a new matrix so that we can just pop it off to go back to perspective mode
   glPushMatrix();
   // Reset the current matrix to our identify matrix
   glLoadIdentity();
   //Pass in our 2D ortho screen coordinates.like so (left, right, bottom, top).  The last
   // 2 parameters are the near and far planes.
   glOrtho( left, right, bottom, top, 0, 1 );
   // Switch to model view so that we can render the scope image
   glMatrixMode(GL_MODELVIEW);
   // Initialize the current model view matrix with the identity matrix
   glLoadIdentity();
end;
//----------------------------------------------------------------------------//

procedure PerspectiveMode;
begin
   // Enter into our projection matrix mode
   glMatrixMode( GL_PROJECTION );
   // Pop off the last matrix pushed on when in projection mode (Get rid of ortho mode)
   glPopMatrix();
   // Go back to our model view matrix like normal
   glMatrixMode( GL_MODELVIEW );
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure CreerRepere();
begin
   leRepere := glGenLists(1);
   glNewList(leRepere,GL_COMPILE);
   glLineWidth(4.0);
   glBegin(GL_LINES);
   glcolor3f(1,0,0);
   glVertex3f(0,0,0);
   glVertex3f(20,0,0);

   glcolor3f(0,1,0);
   glVertex3f(0,0,0);
   glVertex3f(0,20,0);

   glcolor3f(0,0,1);
   glVertex3f(0,0,0);
   glVertex3f(0,0,20);
   glEnd();
   glEndList();
end;

{*******************************************************************************
 *
 *
 *
 *******************************************************************************}
procedure DessinerRepere(x,y,z: real);
begin
   glDisable(GL_DEPTH_TEST);
   GlPushMatrix();
   gltranslated(x, y, z);
   glcallList(leRepere);
   GlPopMatrix();
   glEnable(GL_DEPTH_TEST);
end;

//----------------------------------------------------------------------------//
end.
