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

procedure OrthoMode(left,top,right,bottom : integer);
procedure PerspectiveMode;



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

//----------------------------------------------------------------------------//
end.
