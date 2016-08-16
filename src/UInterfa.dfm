object Form1: TForm1
  Left = 649
  Top = 452
  Anchors = [akRight, akBottom]
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Ecstasy launcher'
  ClientHeight = 461
  ClientWidth = 462
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000010000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000055555555885555500000
    0008888000055555555888885550000008888888880555555587778888500000
    8887777888555555558788778880000887777777785555555587788088000088
    7777777785555555558877885500008777777777855555555588777885000887
    77000778555555555588877885000877000000055DDDD5555588877788000870
    00000000D888DDD55558887788000000000000088888888DD558888778800000
    00000000777788888D55887788000000000000077777777888D5577800000000
    000000F777777777788D55550000000000000000F77777777788D55500000000
    000008880F777777777888880000000000888888800F77777777888000000000
    888887778880777777777770000000088877777777880F777777778000000088
    7777777777880777777778800000008777777777777880777777888000000887
    77777777766788777778888000000877777777776EE678777788778800000777
    77777776E00E677778877788000000777777777600006E788877777880000000
    7777776E0006E0088777777880000000000777EE00EE00000777777788000000
    0060000E6E000000000777777880000006E66000000000000000007777000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    0000FE1E0000F8000000F0000000E0000000C000000180000001800000010000
    0001038000010FE000019FC00000FFE00001FFC00003FF800007FF800007FC00
    0007F000000FE000000FC000000F8000000F8000000F0000000F000000070000
    000780000003C0000003F0006001F800F800F023FE01F87FFFC3FFFFFFFF}
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label12: TLabel
    Left = 16
    Top = 168
    Width = 65
    Height = 13
    Caption = 'Mode de jeu :'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = 14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Button1: TButton
    Left = 276
    Top = 415
    Width = 89
    Height = 43
    Anchors = []
    Caption = '&Lancer'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 370
    Top = 415
    Width = 89
    Height = 43
    Anchors = []
    Caption = '&Quitter'
    TabOrder = 1
    OnClick = Button2Click
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 457
    Height = 409
    ActivePage = TabSheet3
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = '&Configuration du joueur'
      object Image1: TImage
        Left = 8
        Top = 32
        Width = 433
        Height = 345
        Stretch = True
      end
      object ComboBox3: TComboBox
        Left = 8
        Top = 8
        Width = 433
        Height = 21
        DragMode = dmAutomatic
        ItemHeight = 13
        TabOrder = 0
        Text = 'ComboBox3'
        OnChange = ComboBox3Change
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Paramétrages du jeu'
      ImageIndex = 2
      object GroupBox4: TGroupBox
        Left = 8
        Top = 8
        Width = 185
        Height = 137
        Caption = 'Affichage '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Label7: TLabel
          Left = 8
          Top = 16
          Width = 69
          Height = 13
          Caption = 'Résolution :'
        end
        object Label10: TLabel
          Left = 8
          Top = 64
          Width = 58
          Height = 13
          Caption = 'Couleurs :'
        end
        object ComboBox1: TComboBox
          Left = 16
          Top = 32
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          Text = '640 x 480'
          OnChange = ComboBox1Change
          Items.Strings = (
            '640 x 480'
            '800 x 600'
            '1024 x 768'
            '1280 x 1024'
            '1600 x 1200')
        end
        object ComboBox2: TComboBox
          Left = 16
          Top = 80
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 1
          Text = '16'
          OnChange = ComboBox2Change
          Items.Strings = (
            '8'
            '16'
            '24'
            '32')
        end
        object CheckBox1: TCheckBox
          Left = 8
          Top = 112
          Width = 97
          Height = 17
          Caption = 'Plein Ecran'
          TabOrder = 2
          OnClick = CheckBox1Click
        end
      end
      object GroupBox3: TGroupBox
        Left = 200
        Top = 224
        Width = 249
        Height = 105
        Caption = 'Lumières'
        Enabled = False
        TabOrder = 1
        object Label3: TLabel
          Left = 8
          Top = 80
          Width = 154
          Height = 13
          Caption = 'énorment la vitesse du jeu.'
        end
        object Label5: TLabel
          Left = 8
          Top = 64
          Width = 203
          Height = 13
          Caption = 'Attention : les lumières ralentissent '
        end
        object CheckBox4: TCheckBox
          Left = 8
          Top = 40
          Width = 169
          Height = 17
          Caption = 'Lumière du soleil activée'
          TabOrder = 0
          OnClick = CheckBox4Click
        end
        object CheckBox5: TCheckBox
          Left = 8
          Top = 16
          Width = 169
          Height = 17
          Caption = 'Phares du joueur activés'
          TabOrder = 1
        end
      end
      object GroupBox8: TGroupBox
        Left = 200
        Top = 8
        Width = 241
        Height = 113
        Caption = 'Atmosphère  '
        TabOrder = 2
        object Label35: TLabel
          Left = 64
          Top = 17
          Width = 36
          Height = 13
          Caption = 'activé'
        end
        object CheckBox3: TCheckBox
          Left = 8
          Top = 16
          Width = 57
          Height = 17
          Caption = 'Orage'
          TabOrder = 0
          OnClick = CheckBox3Click
        end
        object CheckBox2: TCheckBox
          Left = 8
          Top = 64
          Width = 129
          Height = 17
          Caption = 'Brume activée'
          TabOrder = 1
          OnClick = CheckBox2Click
        end
        object CheckBox11: TCheckBox
          Left = 8
          Top = 88
          Width = 97
          Height = 17
          Caption = 'CheckBox11'
          TabOrder = 2
          OnClick = CheckBox11Click
        end
        object CheckBox12: TCheckBox
          Left = 8
          Top = 40
          Width = 129
          Height = 17
          Caption = 'CheckBox12'
          TabOrder = 3
          OnClick = CheckBox12Click
        end
      end
      object GroupBox5: TGroupBox
        Left = 8
        Top = 152
        Width = 185
        Height = 225
        Caption = 'Ville '
        TabOrder = 3
        object Label8: TLabel
          Left = 7
          Top = 16
          Width = 123
          Height = 13
          Caption = 'Pente max des routes'
        end
        object Label27: TLabel
          Left = 7
          Top = 72
          Width = 141
          Height = 13
          Caption = 'Altitude max des collines'
        end
        object Label6: TLabel
          Left = 8
          Top = 128
          Width = 137
          Height = 13
          Caption = 'Pourcentage de terrains'
        end
        object TrackBar1: TTrackBar
          Left = 8
          Top = 32
          Width = 129
          Height = 33
          Max = 100
          Orientation = trHorizontal
          Frequency = 5
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 0
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = TrackBar1Change
        end
        object Edit10: TEdit
          Left = 136
          Top = 32
          Width = 41
          Height = 21
          ReadOnly = True
          TabOrder = 1
          Text = '0'
        end
        object TrackBar3: TTrackBar
          Left = 8
          Top = 88
          Width = 129
          Height = 33
          Max = 150
          Orientation = trHorizontal
          Frequency = 10
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 2
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = TrackBar1Change
        end
        object Edit15: TEdit
          Left = 136
          Top = 88
          Width = 41
          Height = 21
          ReadOnly = True
          TabOrder = 3
          Text = '100'
        end
        object ScrollBar2: TScrollBar
          Left = 16
          Top = 152
          Width = 113
          Height = 16
          PageSize = 0
          SmallChange = 10
          TabOrder = 4
          OnChange = ScrollBar2Change
        end
        object Edit1: TEdit
          Left = 136
          Top = 144
          Width = 41
          Height = 21
          TabOrder = 5
          Text = '0'
        end
      end
      object GroupBox10: TGroupBox
        Left = 200
        Top = 336
        Width = 249
        Height = 41
        Caption = 'Sons'
        TabOrder = 4
        object CheckBox6: TCheckBox
          Left = 8
          Top = 16
          Width = 97
          Height = 17
          Caption = 'activés'
          TabOrder = 0
          OnClick = CheckBox6Click
        end
      end
      object GroupBox7: TGroupBox
        Left = 200
        Top = 128
        Width = 249
        Height = 89
        Caption = 'Densité de la circulation '
        TabOrder = 5
        object Label1: TLabel
          Left = 8
          Top = 48
          Width = 202
          Height = 13
          Caption = 'Plus la circulation est dense plus la'
        end
        object Label2: TLabel
          Left = 8
          Top = 64
          Width = 234
          Height = 13
          Caption = 'puissance de la machine doit être élevée'
        end
        object ScrollBar1: TScrollBar
          Left = 8
          Top = 24
          Width = 121
          Height = 16
          Max = 4
          PageSize = 0
          TabOrder = 0
          OnChange = ScrollBar1Change
        end
        object Edit3: TEdit
          Left = 136
          Top = 24
          Width = 97
          Height = 21
          ReadOnly = True
          TabOrder = 1
          Text = 'Edit3'
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&Auteurs'
      ImageIndex = 3
    end
    object TabSheet2: TTabSheet
      Caption = '&Credits'
      ImageIndex = 4
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    Left = 32
    Top = 424
  end
end
