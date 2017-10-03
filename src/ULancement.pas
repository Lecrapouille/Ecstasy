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
unit ULancement;

interface

uses
   Windows,
   Messages,
   Opengl,
   URepere,
   Sysutils,
   UTypege,
   UTextures,
   math,
   UCaractere;

const
   WND_TITLE  = 'ECSTASY';
   CHGT_CIRC  = 'Chargement de la circulation ...';
   CHGT_VOIT  = 'Chargement des voitures ...';
   CHGT_VILLE = 'Chargement de la ville ...';
   CHGT_SON   = 'Chargement des sons ...';
   CHGT_TEXT  = 'Chargement des textures ...';

Type TProgressBar = object
   Position : real;
   NbObjet : integer;
   Pas : real;
   Etape : integer;
   procedure Affiche();
   procedure Ajoute();
end;

var
   h_Wnd  : HWND;                       // Global window handle
   h_DC   : HDC;                        // Global device context
   h_RC   : HGLRC;                      // OpenGL rendering context
   keys   : Array[0..255] of Boolean;   // Holds keystrokes
                                        //  FPSCount : Integer = 0;              // Counter for FPS

   FogCouleur_1 : Array[0..3] Of GLFloat;
   FogCouleur_2 : Array[0..3] Of GLFloat = (0,0,1,1);

   LightAmbient: array [0..3] of GLfloat =  (0.5, 0.5, 0.5, 1.0);
   LightDiffuse: array [0..3] of GLfloat =  (1.0, 1.0, 1.0, 1.0);
   LightPosition: array [0..3] of GLfloat = (4.0, 4.0, 4.0, 1.0);


   ProgressBar : TProgressBar;

   procedure loading(id : byte);
   function glCreateWnd(param : T_param) : Boolean;
   procedure glKillWnd(Width, Height : Integer; Fullscreen : Boolean);
   Procedure glBindTexture(target: GLEnum; texture: GLuint); Stdcall; External 'OpenGL32.dll';

implementation
uses USons;

procedure TProgressBar.Affiche();
begin
   glPushMatrix;
   glDisable(GL_TEXTURE_2D);
   OrthoMode(0,0,Params.Width,Params.Height);
   glBegin(GL_POLYGON);
   glcolor3f(1,0,0); glVertex2f(0,       Params.Height-40);
   glcolor3f(1,0,0); glVertex2f(Position,Params.Height-40);
   glcolor3f(1,1,0); glVertex2f(Position,Params.Height);

   glcolor3f(1,1,0); glVertex2f(0,       Params.Height);
   glEnd;
   PerspectiveMode;
   glEnable(GL_TEXTURE_2D);
   glPopMatrix;

   //SwapBuffers(h_DC);
end;


procedure TProgressBar.Ajoute();
begin
   Position := Position + pas;
   Affiche();
end;


//----------------------------------------------------------------------------//
procedure loading(id : byte);
//var Texture: GLuint;
begin
   glClearColor(0.0, 0.0, 0.0, 0.0);

   glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity;
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, Text_chgt);
   glPushMatrix;
   OrthoMode(0,0,Params.Width,Params.Height);
   glcolor3f(1,1,1);
   glBegin(GL_QUADS);
   glTexCoord2f(0.0,1.0);             glVertex2f(Params.Width/4,Params.Height/3);
   glTexCoord2f(1.0,1.0);             glVertex2f(Params.Width/4*3,Params.Height/3);
   glTexCoord2f(1.0,0.0);             glVertex2f(Params.Width/4*3,Params.Height/3*2);
   glTexCoord2f(0.0,0.0);             glVertex2f(Params.Width/4,Params.Height/3*2);
   glEnd;
   PerspectiveMode;
   glPopMatrix;
   glDisable(GL_TEXTURE_2D);

   case ProgressBar.Etape of
      0 : GlTexte(20,Params.Height-50,1,1,0,CHGT_TEXT);
      1 : GlTexte(20,Params.Height-50,1,1,0,CHGT_VOIT);
      2 : GlTexte(20,Params.Height-50,1,1,0,CHGT_VILLE);
      3 : GlTexte(20,Params.Height-50,1,1,0,CHGT_SON);
      4 : GlTexte(20,Params.Height-50,1,1,0,CHGT_CIRC);
   end;

   if id = 1 then ProgressBar.Ajoute()
   else ProgressBar.Affiche();

   SwapBuffers(h_DC);
   sleep(1);
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure InitialisationOpengl(Width: GLsizei; Height: GLsizei; params : T_Param);
var fWidth, fHeight  : GLfloat;
begin
   //glClearColor(1.0, 0.0, 1.0, 1.0);     // Black Background


   glClearDepth(1.0);                                   // Enables Clearing Of The Depth Buffer
   glDepthFunc(GL_LESS);                                        // The Type Of Depth Test To Do
   glShadeModel(GL_SMOOTH);                             // Enables Smooth Color Shading
   glBlendFunc(GL_SRC_ALPHA,GL_ONE);
   glEnable(GL_DEPTH_TEST);

   glcullface(GL_FRONT);
   glEnable(GL_CULL_FACE);

   if Params.fog then
   begin
      if Params.Nuit then
      begin
         FogCouleur_1[0] := 0.1;
         FogCouleur_1[1] := 0.1;
         FogCouleur_1[2] := 0.1;
         FogCouleur_1[3] := 1.0;

         glFogi( GL_FOG_START, 100);
      end else
      begin
         FogCouleur_1[0] := 0.5;
         FogCouleur_1[1] := 0.5;
         FogCouleur_1[2] := 0.6;
         FogCouleur_1[3] := 1.0;

         glFogi( GL_FOG_START, 300);
      end;
      glFogi( GL_FOG_END, DISTANCE_CLIPPING);
      glFogf( GL_FOG_MODE, GL_LINEAR);
      glFogf( GL_FOG_DENSITY, 0.95 );
      glEnable( GL_FOG );
   end;

   {Soleil}
   if Params.Soleil then
   begin
      glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmbient);
      glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDiffuse);
      glLightfv(GL_LIGHT0, GL_POSITION,@LightPosition);

      glEnable(GL_LIGHTING);
      glEnable(GL_LIGHT0);
   end;


   glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);    // Really Nice Perspective Calculations
   glMatrixMode(GL_PROJECTION);                         // Select The Projection Matrix
   glLoadIdentity();                                    // Reset The Projection Matrix                                                  // Reset The Projection Matrix

   fWidth := Width;
   fHeight := Height;
   //gluPerspective(45.0, fWidth/fHeight,0.1,1000000.0);        // Calculate The Aspect Ratio Of The Window
   gluPerspective(45.0, fWidth/fHeight,0.1,DISTANCE_CLIPPING);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

   glMatrixMode(GL_MODELVIEW);                          // Select The Modelview Matrix
end;
//----------------------------------------------------------------------------//


function IntToStr(Num : Integer) : String;
begin
   Str(Num, result);
end;
//----------------------------------------------------------------------------//
procedure BuildFont( police : integer);
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
   //'Courier New');

   SelectObject(h_DC, font);

   wglUseFontBitmaps(h_DC, 32, 96, base);
end;
//----------------------------------------------------------------------------//
//  Handle window resize                                                      //
//----------------------------------------------------------------------------//
procedure glResizeWnd(Width, Height : Integer);
begin
   if (Height = 0) then                // prevent divide by zero exception
      Height := 1;
   glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
   glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
   glLoadIdentity();                   // Reset View
   //gluPerspective(45.0, Width/Height, 1.0, 1000000.0);  // Do the perspective calculations. Last value = max clipping depth    QQ
   gluPerspective(45.0, Width/Height,1.0,DISTANCE_CLIPPING);
   glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
   glLoadIdentity();                   // Reset View
end;

//----------------------------------------------------------------------------//
//  Determines the application’s response to the messages received            //
//----------------------------------------------------------------------------//
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
   case (Msg) of
      WM_CREATE:
         begin
            // Insert stuff you want executed when the program starts
         end;
      WM_CLOSE:
         begin
            PostQuitMessage(0);
            Result := 0
         end;
      WM_KEYDOWN:       // Set the pressed key (wparam) to equal true so we can check if its pressed
         begin
            keys[wParam] := True;
            Result := 0;
         end;
      WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
         begin
            keys[wParam] := False;
            Result := 0;
         end;
      WM_SIZE:          // Resize the window with the new width and height
         begin
            glResizeWnd(LOWORD(lParam),HIWORD(lParam));
            Result := 0;
         end;
      WM_MOUSEMOVE:
         begin
            XMouse := LOWORD(lParam);
            YMouse := HIWORD(lParam);
            Result := 0;
         end;
      WM_TIMER :                     // Add code here for all timers to be used.
         begin
            if wParam = FPS_TIMER then
            begin
               FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // calculate to get per Second incase intercal is less or greater than 1 second
               SetWindowText(h_Wnd, PChar(WND_TITLE + '   [' + intToStr(FPSCount) + ' FPS]'));

               LesFPS := FPSCount;
               FPSCount := 0;
               Result := 0;
            end;
         end;
   else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
   end;
end;


//----------------------------------------------------------------------------//
//  Properly destroys the window created at startup (no memory leaks)         //
//----------------------------------------------------------------------------//
procedure glKillWnd(Width, Height : Integer;Fullscreen : Boolean);
begin

   if Fullscreen then             // Change back to non fullscreen
   begin
      ChangeDisplaySettings(devmode(nil^), 0);
      ShowCursor(true);
   end;

   // Makes current rendering context not current, and releases the device
   // context that is used by the rendering context.
   if (not wglMakeCurrent(h_DC, 0)) then
      MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

   // Attempts to delete the rendering context
   if (not wglDeleteContext(h_RC)) then
   begin
      MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
      h_RC := 0;
   end;

   // Attemps to release the device context
   if ((h_DC = 1) and (ReleaseDC(h_Wnd, h_DC) <> 0)) then
   begin
      MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
      h_DC := 0;
   end;

   // Attempts to destroy the window
   if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then
   begin
      MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
      h_Wnd := 0;
   end;

   // Attempts to unregister the window class
   if (not UnRegisterClass('OpenGL', hInstance)) then
   begin
      MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
      hInstance := 0;
   end;
end;


//----------------------------------------------------------------------------//
//  Creates the window and attaches a OpenGL rendering context to it          //
//----------------------------------------------------------------------------//

function glCreateWnd(param : T_param) : Boolean;
var
   wndClass : TWndClass;         // Window class
   dwStyle : DWORD;              // Window styles
   dwExStyle : DWORD;            // Extended window styles
   dmScreenSettings : DEVMODE;   // Screen settings (fullscreen, etc...)
   PixelFormat : GLuint;         // Settings for the OpenGL rendering
   h_Instance : HINST;           // Current instance
   pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
   h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
   ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

   with wndClass do                    // Set up the window class
   begin
      style         := CS_HREDRAW or    // Redraws entire window if length changes
         CS_VREDRAW or    // Redraws entire window if height changes
         CS_OWNDC;        // Unique device context for the window
      lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
      hInstance     := h_Instance;
      hCursor       := LoadCursor(0, IDC_ARROW);
      lpszClassName := 'OpenGL';
   end;

   if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
   begin
      MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit
   end;

   // Change to fullscreen if so desired
   if param.Fullscreen then
   begin
      ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
      with dmScreenSettings do begin              // Set parameters for the screen setting
         dmSize       := SizeOf(dmScreenSettings);
         dmPelsWidth  := param.Width;                    // Window width
         dmPelsHeight := param.Height;                   // Window height
         dmBitsPerPel := param.PixelDepth;               // Window color depth
         dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
      end;

      // Try to change screen mode to fullscreen
      if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
      begin
         MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
         param.Fullscreen := False;
      end;
   end;

   // If we are still in fullscreen then
   if (param.Fullscreen) then
   begin
      dwStyle := WS_POPUP or                // Creates a popup window
         WS_CLIPCHILDREN            // Doesn't draw within child windows
         or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
      dwExStyle := WS_EX_APPWINDOW;         // Top level window
      ShowCursor(False);                    // Turn of the cursor (gets in the way)
   end
   else
   begin
      dwStyle := WS_OVERLAPPEDWINDOW or     // Creates an overlapping window
         WS_CLIPCHILDREN or         // Doesn't draw within child windows
         WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
      dwExStyle := WS_EX_APPWINDOW or       // Top level window
         WS_EX_WINDOWEDGE;        // Border with a raised edge
   end;

   // Attempt to create the actual window
   h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                           'OpenGL',       // Class name
                           WND_TITLE,      // Window title (caption)
                           dwStyle,        // Window styles
                           0, 0,           // Window position
                           param.Width, param.Height,  // Size of window
                           0,              // No parent window
                           0,              // No menu
                           h_Instance,     // Instance
                           nil);           // Pass nothing to WM_CREATE
   if h_Wnd = 0 then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);                // Undo all the settings we've changed
      MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Try to get a device context
   h_DC := GetDC(h_Wnd);
   if (h_DC = 0) then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);
      MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Settings for the OpenGL window
   with pfd do
   begin
      nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
      nVersion        := 1;                    // The version of this data structure
      dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
         or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
         or PFD_DOUBLEBUFFER;  // Supports double buffering
      iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
      cColorBits      := param.PixelDepth;           // OpenGL color depth
      cRedBits        := 0;                    // Number of red bitplanes
      cRedShift       := 0;                    // Shift count for red bitplanes
      cGreenBits      := 0;                    // Number of green bitplanes
      cGreenShift     := 0;                    // Shift count for green bitplanes
      cBlueBits       := 0;                    // Number of blue bitplanes
      cBlueShift      := 0;                    // Shift count for blue bitplanes
      cAlphaBits      := 0;                    // Not supported
      cAlphaShift     := 0;                    // Not supported
      cAccumBits      := 0;                    // No accumulation buffer
      cAccumRedBits   := 0;                    // Number of red bits in a-buffer
      cAccumGreenBits := 0;                    // Number of green bits in a-buffer
      cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
      cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
      cDepthBits      := 16;                   // Specifies the depth of the depth buffer
      cStencilBits    := 0;                    // Turn off stencil buffer
      cAuxBuffers     := 0;                    // Not supported
      iLayerType      := PFD_MAIN_PLANE;       // Ignored
      bReserved       := 0;                    // Number of overlay and underlay planes
      dwLayerMask     := 0;                    // Ignored
      dwVisibleMask   := 0;                    // Transparent color of underlay plane
      dwDamageMask    := 0;                     // Ignored
   end;

   // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
   PixelFormat := ChoosePixelFormat(h_DC, @pfd);
   if (PixelFormat = 0) then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);
      MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Sets the specified device context's pixel format to the format specified by the PixelFormat.
   if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);
      MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Create a OpenGL rendering context
   h_RC := wglCreateContext(h_DC);
   if (h_RC = 0) then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);
      MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Makes the specified OpenGL rendering context the calling thread's current rendering context
   if (not wglMakeCurrent(h_DC, h_RC)) then
   begin
      glKillWnd(param.Width, param.Height, param.Fullscreen);
      MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
      Result := False;
      Exit;
   end;

   // Initializes the timer used to calculate the FPS
   SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

   // Settings to ensure that the window is the topmost window
   ShowWindow(h_Wnd, SW_SHOW);
   SetForegroundWindow(h_Wnd);
   SetFocus(h_Wnd);

   // Ensure the OpenGL window is resized properly
   InitialisationOpengl(param.Width, param.Height, params);
   glResizeWnd(param.Width, param.Height);

   {Liste d'affichage des fontes}
   BuildFont(param.police);

   Result := True;
end;
//----------------------------------------------------------------------------//

end.
