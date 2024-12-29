Program Listeur;             { version 1.6 du 07/05/1991 }

{
Ce programme permet d'imprimer n'importe quel fichier texte dans le format
voulu. Il suffit de donner les differents paramŠtres concernant le papier,
puis de lancer l'impression.

Auteur: Pr‚martin Patrick
PremiŠre version dat‚e du 28 d‚cembre 1990.
}

{
*******************************************************************************
          DECLARATIONS DIVERSES.
*******************************************************************************
}
Uses olf_software,
     U_Fenetre,
     U_Aff_Chaine,
     U_Sgf,
     U_Ger_Chaine,
     U_Code_Clavier,
     U_Util,
     U_Curseur,
     U_Sai_Donnee,
     U_Position,
     U_Time,
     U_Date,
     Printer,
     Dos,
     Crt;

Const Num_Version   : String [3]  = '1.6';
      Date_Version  : String [10] = '07-05-1991';
      Num_Param     : Byte        = 0;
      Param_Used    : Boolean     = False;
      Hauteur_Page                = 63;
      C_Nb_Ligne_Page             = 53;
      C_Nb_Col_Ligne              = 80;
      C_Txt_Haut_Page             = 'Listing de $F';
      C_Txt_Bas_Page              = 'Page $P';
      C_Nb_Options                = 16;

Var Date_X,                  { Coordonn‚es d'affichage de l'heure et de la }
    Date_Y,                  { date.                                       }
    Heure_X,
    Heure_Y,
    Page,                    { Variables concernant l'impression. }
    Nb_Ligne_Page,
    Nb_Col_Ligne,
    Num_Page       : Integer;
    Haut_Page,               { Message de haut de page. }
    Bas_Page,                { Message de bas de page. }
    Nom_Fich       : String; { Nom du fichier en cours d'impression. }
    Impr_Num_Lig,            { Imprime-t-on les numeros de ligne ? }
    Arret_Impression,        { Arrete-t-on l'impression en cours ? }
    Page_Continue,           { La num‚rotation des pages doit-elle recommencer …
                               chaque fichier ? }
    Carac_End_Of_Line,       { Doit-on mettre un caractŠre pour marquer la fin
                               d'une ligne ? }
    T_Papier       : Boolean;{ Utilise-t-on du papier en continu (ou en feuille
                               … feuille) ? }
    Fich_Type      : Searchrec;

{
*******************************************************************************
          GESTION DES OPTIONS DANS LES MESSAGES DE HAUT ET DE BAS DE PAGE.
*******************************************************************************
}
Procedure Option_D (Var Chaine : String; I : Integer);
{ Mise en place de la date dans Chaine … la position I. }
Var Jj, Mm, Aa,
    Jj2         : Word;
    Chaine_D,
    Chaine2     : String;
Begin { option_d }
  Getdate (Aa, Mm, Jj, Jj2);
  Str (Jj, Chaine_D);
  Str (Mm, Chaine2);
  Chaine_D := Concat (Chaine_D, '/', Chaine2);
  Str (Aa, Chaine2);
  Chaine_D := Concat (Chaine_D, '/', Chaine2);
  Insert (Chaine_D, Chaine, I)
End; { option_d }

Procedure Option_E (Var Chaine : String; I : Integer);
{ Mise en place de l'extension du fichier imprim‚ dans Chaine … la position I. }
Begin { option_e }
  Insert (Copy (Get_Extension (Nom_Fich), 2, 3), Chaine, I)
End; { option_e }

Procedure Option_F (Var Chaine : String; I : Integer);
{ Mise en place du nom du fichier (extension inclue) dans Chaine en position I. }
Var Chaine2 : String;
Begin { option_f }
  Chaine2 := Get_Nom_Fichier (Nom_Fich);
  Insert (Chaine2, Chaine, I)
End; { option_f }

Procedure Option_N (Var Chaine : String; I : Integer);
{ Mise en place du nom du fichier (sans extension) en position I de Chaine. }
Var Chaine2 : String;
Begin { option_n }
  Chaine2 := Get_Nom_Fichier (Nom_Fich);
  Insert (Copy (Chaine2, 1, Pred (Pos ('.', Chaine2))), Chaine, I)
End; { option_n }

Procedure Option_P (Var Chaine : String; I : Integer);
{ Mise en place du num‚ro de la page en cours d'impression en position I de
Chaine. }
Var Chaine2 : String;
Begin { option_p }
  Str (Page, Chaine2);
  Insert (Chaine2, Chaine, I)
End; { option_p }

Procedure Option_T (Var Chaine : String; I : Integer);
{ Mise en place de l'heure en position I de Chaine. }
Var Hh, Mm, Ss,
    Ss2         : Word;
    Chaine_T,
    Chaine2     : String;
Begin { option_t }
  Gettime (Hh, Mm, Ss, Ss2);
  Str (Hh, Chaine_T);
  Str (Mm, Chaine2);
  Chaine_T := Concat (Chaine_T, ':', Chaine2);
  Str (Ss, Chaine2);
  Chaine_T := Concat (Chaine_T, ':', Chaine2);
  Insert (Chaine_T, Chaine, I)
End; { option_t }

Function Gestion_Directives (Chaine : String) : String;
Var I      : Integer;
    Option : Char;
Begin { gestion_directives }
  I := Pos ('$', Chaine);
  If ((I <> 0) And (I <> Length (Chaine)))
  Then
    Begin
      Option := Chaine [Succ (I)];
      Delete (Chaine, I, 2);
      Case (Upcase (Option)) Of
        'D' : Option_D (Chaine, I);
        'E' : Option_E (Chaine, I);
        'F' : Option_F (Chaine, I);
        'N' : Option_N (Chaine, I);
        'P' : Option_P (Chaine, I);
        'T' : Option_T (Chaine, I)
      End;
      Gestion_Directives := Gestion_Directives (Chaine)
    End
  Else
    Gestion_Directives := Chaine
  {endif}
End; { gestion_directives }

{
*******************************************************************************
          GESTION DES FICHIERS ET DES JOKERS * ET ?
*******************************************************************************
}
Function Fichier_Premier (Path : String) : String;
{ Utilisation de l'unit‚ DOS pour trouver le premier fichier correspondant au
masque pass‚. }
Var Chaine : String;
    Bug    : Boolean;
Begin { fichier_premier }
  If ((Non_Pos_Left (' ', Path) > 0) And (Length (Path) > 0))
  Then
    Begin
      Chaine := Get_Chemin_Fichier (Path);
      Bug := Change_Dir (Chaine);
      Findfirst (Path, Anyfile, Fich_Type);
      If (Fich_Type.Name = '')
      Then
        Fichier_Premier := '\NONAME.TXT'
      Else
        Fichier_Premier := Set_Maj_Chaine (Concat (Chaine, Fich_Type.Name))
      {endif}
    End
  Else
    Fichier_Premier := '\NONAME.TXT'
  {endif}
End; { fichier_premier }

Function Fichier_Suivant (Path : String) : String;
{ Utilisation de l'unit‚ DOS pour trouver le N-iŠme fichier correspondant au
masque pass‚. }
Begin { fichier_suivant }
  Findnext (Fich_Type);
  If ((Fich_Type.Name <> '') And (Fich_Type.Name <> Get_Nom_Fichier (Nom_Fich)))
  Then
    Fichier_Suivant := Set_Maj_Chaine (Fich_Type.Name)
  Else
    If ((Paramcount > 0) And Not Param_Used)
    Then
      If (Paramcount > Num_Param)
      Then
        Begin
          Inc (Num_Param);
          Fichier_Suivant := Fichier_Premier (Paramstr (Num_Param))
        End
      Else
        Begin
          Param_Used := True;
          Fichier_Suivant := '\NONAME.TXT'
        End
      {endif}
    Else
      Begin
        Param_Used := True;
        Fichier_Suivant := '\NONAME.TXT'
      End
    {endif}
  {endif}
End; { fichier_suivant }

Procedure Ask_Nom_Fichier (Var Nom_Fich : String);
{ Demande … l'utilisateur d'entrer un nom de fichier (ou un nom g‚n‚rique). }
Var Nom : String;
Begin { ask_nom_fichier }
  Type_Cadre := 1;
  Window_Cadre_Bis (2, 10, 79, 11, Blue, White);
  Window_Titre ('Nom du fichier … imprimer', White, Red);
  Textcolor (White);
  Textbackground (Black);
  Repeat
    Clrscr;
    Writeln ('Ancien nom: ',Nom_Fich);
    Curseur_Pave;
    Write ('Nouveau nom: ');
    Saisie_Texte (Concat ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
'XXXXXXXXXXXXXX') { 64X }, Nom);
    Curseur_Off;
    Nom := Fichier_Premier (Set_Maj_Chaine (Nom))
  Until ((Exist (Nom)) Or (Get_Nom_Fichier (Nom) = 'NONAME.TXT'));
  If (Get_Nom_Fichier (Nom) <> 'NONAME.TXT')
  Then
    Begin
      Param_Used := True;
      Num_Param := Succ (Paramcount);
      Nom_Fich := Nom
    End
  {endif};
  Clear_Window
End; { ask_nom_fichier }

{
*******************************************************************************
          INITIALISATION DES VARIABLES D'ENVIRONNEMENT
*******************************************************************************
}
Procedure Variables_Defaut;
Begin { variables_defaut }
  If ((Paramcount > Num_Param) And Not Param_Used)
  Then
    Begin
      Inc (Num_Param);
      Nom_Fich := Fichier_Premier (Paramstr (Num_Param))
    End
  Else
    Begin
      Param_Used := True;
      Nom_Fich := '\NONAME.TXT'
    End
  {endif};
  Nb_Ligne_Page     := C_Nb_Ligne_Page;
  Nb_Col_Ligne      := C_Nb_Col_Ligne;
  Num_Page          := 1;
  Haut_Page         := C_Txt_Haut_Page;
  Bas_Page          := C_Txt_Bas_Page;
  Carac_End_Of_Line := False;
  Impr_Num_Lig      := False;
  T_Papier          := False;
  Arret_Impression  := False;
  Page_Continue     := False
End; { variables_defaut }

{
*******************************************************************************
          AFFICHAGE DE L'ECRAN DE PRESENTATION
*******************************************************************************
}
Procedure Presentation;
Var Chaine : String;
Begin { presentation }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 14, White, Black);
  Window_Titre ('Listeur', Blue, Lightgray);
  Textcolor (Lightgray);
  Textbackground (Red);
  Clrscr;
  Affic_Center_Ln ('de Pr‚martin Patrick.');
  Affic_Center_Ln (Concat ('Version ', Num_Version, ' dat‚e du ', Date_Version, '.'));
  Writeln;
  Writeln;
  Write   ('   Ce programme permet d''imprimer des fichiers textes avec le format de papier');
  Write   ('que vous aurez choisi. Configurez votre imprimante, puis utilisez ce programme');
  Write   ('Choisissez le nom du fichier … imprimer (vous pouvez utiliser les masques * et');
  Writeln ('?), puis prenez l''option "Impression" qui d‚clenchera l''imprimante...');
  Writeln;
  Writeln ('   Appuyez sur F1 dans le menu pour l''ecran d''aide.');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { presentation }

{
*******************************************************************************
          AFFICHAGE DE L'ECRAN D'AIDE
*******************************************************************************
}
Procedure Ecran_Aide;

  Procedure Aide_1;
  Begin { aide_1 }
    Affic_Center_Ln ('Ecran d''aide 1.');
    Writeln;
    Writeln ('Messages de haut et de bas de page:');
    Writeln ('   - ''$D'' ou ''$d'' est remplac‚ par la date JJ/MM/AA');
    Writeln ('   - ''$E'' ou ''$e'' est remplac‚ par l''extension du fichier imprim‚');
    Writeln ('   - ''$F'' ou ''$f'' est remplac‚ par Nom.Extension du fichier imprim‚');
    Writeln ('   - ''$N'' ou ''$n'' est remplac‚ par le nom du fichier imprim‚');
    Writeln ('   - ''$P'' ou ''$p'' est remplac‚ par le num‚ro de la page imprim‚e');
    Writeln ('   - ''$T'' ou ''$t'' est remplac‚ par l''heure courante HH:MM:SS');
    Writeln;
    Writeln ('Pendant l''impression:');
    Writeln ('   - appuyez sur <ESC> pour faire une pause. Vous quitterez cette pause en');
    Writeln ('     appuyant sur <SPACE> (le programme imprimera alors la suite), ou sur');
    Writeln ('     <ESC> pour abandonner l''impression.');
    Writeln;
    Writeln ('Pendant le menu:');
    Writeln ('   - appuyez sur F1 pour voir cet ecran,');
    Writeln ('   - d‚placez le cadre de selection avec les touches fl‚ch‚es.')
  End; { aide_1 }

  Procedure Aide_2;
  Begin { aide_2 }
    Affic_Center_Ln ('Ecran d''aide 2.');
    Writeln;
    Writeln ('Pendant la saisie d''un nombre:');
    Writeln ('   - ''+'' incr‚mente le nombre,');
    Writeln ('   - ''-'' d‚cr‚mente le nombre,');
    Writeln ('   - les flŠches haut et bas augmentent ou diminuent le nombre de 5.');
    Writeln;
    Writeln ('Pour me contacter, ‚crivez …:');
    Writeln ('          PREMARTIN PATRICK');
    writeln ('          LOT. LE SOULEIADO');
    writeln ('            13790 ROUSSET');
    Writeln ('               FRANCE')
  End; { aide_2 }

Begin { ecran_aide }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 23, White, Black);
  Window_Titre ('Listeur', Blue, Lightgray);
  Textcolor (Lightgray);
  Textbackground (Red);
  Clrscr;
  Affic_Center_Ln ('Pr‚martin Patrick.');
  Aide_1;
  Writeln;
  Attente_Appuit_Touche;
  Clrscr;
  Affic_Center_Ln ('Pr‚martin Patrick.');
  Aide_2;
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { ecran_aide }

{
*******************************************************************************
          DEMANDE A L'UTILISATEUR D'ENTRER UNE CHAINE
*******************************************************************************
}
Function Ask_Message (Titre, Message : String) : String;
Var Chaine : String;
Begin { ask_message }
  Type_Cadre := 5;
  Window_Cadre_Bis (1, 2, 80, 6, Blue, White);
  Window_Titre (Titre, White, Red);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Writeln ('Ancienne valeur:');
  Affic_Center_Ln (Message);
  Curseur_Pave;
  Writeln ('Nouvelle valeur:');
  Saisie_Texte (Concat ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' { 80X } ), Chaine);
  Curseur_Off;
  If ((Chaine <> '') And (Non_Pos_Left (' ', Chaine) <> 0))
  Then
    Ask_Message := Chaine
  Else
    Ask_Message := Message
  {endif};
  Clear_Window
End; { ask_message }

{
*******************************************************************************
          CONTROLE DE L'IMPRESSION
*******************************************************************************
}
Procedure Travail_En_Cours;
Begin { travail_en_cours }
  Message_Alerte (Concat ('Travail en cours sur: ', Get_Nom_Fichier (Nom_Fich)), False)
End; { travail_en_cours }

Procedure Page_Suivante;
Var Carac : Char;
Begin { page_suivante }
  Writeln (Lst, Carac_Ff);
  If (T_Papier)
  Then
    Begin
      Clear_Window;
      Message_Alerte ('Inserez une nouvelle feuille...', True)
    End
  Else
    If (Keypressed)
    Then
      Begin
        Carac := Readkey;
        If (Carac = Touche_Escape)
        Then
          Begin
            Clear_Window;
            Message_Alerte ('Appuyez sur une touche pour continuer l''impression...', False);
            Vide_Tampon_Clavier;
            Repeat
              Carac := Readkey;
              Arret_Impression := (Carac = Touche_Escape)
            Until ((Carac = ' ') Or (Carac = Touche_Escape))
          End
        {endif}
      End
    {endif}
  {endif};
  Travail_En_Cours
End; { page_suivante }

Procedure Print_Center (Var Chaine : String);
Var Long_Chaine, I, J : Integer;
Begin { print_center }
  If (Chaine <> '')
  Then
    Begin
      Chaine := Gestion_Directives (Chaine);
{ suppression des espaces … gauche }
      I := Non_Pos_Left (' ', Chaine);
      If (I > 0)
      Then
        Delete (Chaine, 1, Pred (I))
      {endif};
{ suppression des espaces … droite }
      I := Non_Pos_Right (' ', Chaine);
      If (I > 0)
      Then
        Chaine := Copy (Chaine, 1, I)
      {endif};
{ centrage de la chaine puis impression }
      Long_Chaine := Length (Chaine);
      I := (Nb_Col_Ligne - Long_Chaine) Div 2;
      For J := 1 To I Do
        Write (Lst, ' ')
      {endfor};
      Writeln (Lst, Chaine)
    End
  {endif}
End; { print_center }

Function Traitement_Ligne (Chaine : String; Num_Ligne : Integer): String;
Var Chaine2 : String;
Begin { traitement_ligne }
{ Mise du num‚ro de la ligne. }
  If (Impr_Num_Lig)
  Then
    Begin
      Inc (Num_Ligne);
      Str (Num_Ligne, Chaine2);
      Chaine := Concat (Chaine2, ' ', Chaine)
    End
  {endif};
{ Mise du caractŠre de fin de ligne. }
  If (Carac_End_Of_Line)
  Then
    Chaine := Concat (Chaine, 'œ')
  {endif};
{ Fin du traitement de la chaine avant son impression. }
  Traitement_Ligne := Chaine
End; { traitement_ligne }

{
Impression du fichier.
}
Procedure Impression;
Var I,
    Num_Ligne_Fic,
    Ligne_Impri,
    Ligne        : Integer;
    Fichier      : Text;
    Chaine       : String;
    Fin_Ligne    : Boolean;
Begin { impression }
  Arret_Impression := False;
  Page := Num_Page;
  Repeat
    If (Exist (Nom_Fich))
    Then
      Begin
        Travail_En_Cours;
        Ligne_Impri := Succ ((Hauteur_Page - Nb_Ligne_Page) Div 2);
        Assign (Fichier, Nom_Fich);
        Reset (Fichier);
        If Not Page_Continue
        Then
          Page := Num_Page
        {endif};
        Num_Ligne_Fic := 0;
        Fin_Ligne := True;
        Page_Suivante;
        While Not (Arret_Impression Or ((Eof (Fichier)) And (Fin_Ligne))) Do
          Begin
{
Haut de la page.
}
            Print_Center (Haut_Page);
            Writeln (Lst);
{
Partie de l'utilisation de l'imprimante.
}
            Ligne := 0;
            While Not (Eof(Fichier) Or (Ligne >= Nb_Ligne_Page - 2)) Do
              Begin
                Inc (Ligne);
{
Lecture du morceau … imprimer, et gestion des options.
}
                If (Fin_Ligne)
                Then
                  Begin
                    Readln (Fichier, Chaine);
                    Chaine := Traitement_Ligne (Chaine, Num_Ligne_Fic)
                  End
                Else
                  Delete (Chaine, 1, Nb_Col_Ligne)
                {endif};
{
Impression de la ligne courante.
}
                Writeln (Lst, Copy (Chaine, 1, Nb_Col_Ligne));
{
A-t-on ecrit la ligne en entier ?
}
                Fin_Ligne := (Nb_Col_Ligne >= Length (Chaine))
              End
            {endwhile};
{
Bas des pages.
}
            For I := Ligne To Nb_Ligne_Page - 1 Do
              Writeln (Lst)
            {endfor};
            If (Ligne < Nb_Ligne_Page)
            Then
              Print_Center (Bas_Page)
            {endif};
            Inc (Page);
            Page_Suivante
          End
        {endwhile};
        Clear_Window;
        Close (Fichier)
      End
    {endif};
{
Gestion d'une s‚rie de paramŠtres d'entr‚e pass‚s par le DOS, ou du nom simple
d'un fichier tap‚ par l'utilisateur. (ainsi que de la possibilit‚ d'utiliser
les jokers du DOS: * et ?)
}
    Nom_Fich := Fichier_Suivant (Nom_Fich)
  Until ((Get_Nom_Fichier (Nom_Fich) = 'NONAME.TXT') Or Arret_Impression);
  Writeln (Lst, Carac_Ff)
End; { impression }

{
*******************************************************************************
          GESTION DE LA DATE
*******************************************************************************
}
Procedure Affiche_Date (X, Y : Integer);
Begin { affiche_date }
  Textcolor (Lightgray);
  Textbackground (Black);
  Curseur_Locate (X, Y);
  Write ('Date: ', Get_Date_Chaine)
End; { affiche_date }

Procedure Saisie_Date;
Var New_Date : String;
    Jj,
    Mm,
    Aa : Integer;
Begin { saisie_date }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 3, Blue, White);
  Window_Titre ('Saisie de la date: JJ/MM/AAAA', White, Red);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Writeln ('Date courante: ', Get_Date_Chaine);
  Curseur_Pave;
  Write ('Nouvelle date: ');
  Saisie_Texte ('XXXXXXXXXX' { 10X }, New_Date);
  Curseur_Off;
  If (Length (New_Date) = 10)
  Then
    Begin
      Jj := (Ord (New_Date [1]) - Ord ('0')) * 10 + (Ord (New_Date [2]) - Ord ('0'));
      Mm := (Ord (New_Date [4]) - Ord ('0')) * 10 + (Ord (New_Date [5]) - Ord ('0'));
      Aa := (Ord (New_Date [7]) - Ord ('0')) * 1000 + (Ord (New_Date [8]) -
Ord ('0')) * 100 + (Ord (New_Date [9]) - Ord ('0')) * 10 + (Ord (New_Date [10])
- Ord ('0'));
      Set_Date (Jj, Mm, Aa)
    End
  {endif}
End; { saisie_date }

{
*******************************************************************************
          GESTION DE L'HEURE
*******************************************************************************
}
Procedure Affiche_Heure (X, Y : Integer);
Begin { affiche_heure }
  Textcolor (Lightgray);
  Textbackground (Black);
  Curseur_Locate (X, Y);
  Write ('Heure: ', Get_Time_Chaine)
End; { affiche_heure }

Procedure Saisie_Heure;
Var New_Heure : String;
    Hh,
    Mm,
    Ss : Integer;
Begin { saisie_heure }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 3, Blue, White);
  Window_Titre ('Saisie de l''heure: HH:MM:SS', White, Red);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Writeln ('Heure courante: ', Get_Time_Chaine);
  Curseur_Pave;
  Write ('Nouvelle heure: ');
  Saisie_Texte ('XXXXXXXX' { 8X }, New_Heure);
  Curseur_Off;
  If (Length (New_Heure) = 8)
  Then
    Begin
      Hh := (Ord (New_Heure [1]) - Ord ('0')) * 10 + (Ord (New_Heure [2]) - Ord ('0'));
      Mm := (Ord (New_Heure [4]) - Ord ('0')) * 10 + (Ord (New_Heure [5]) - Ord ('0'));
      Ss := (Ord (New_Heure [7]) - Ord ('0')) * 10 + (Ord (New_Heure [8]) - Ord ('0'));
      Set_Time (Hh, Mm, Ss, 0)
    End
  {endif}
End; { saisie_heure }

{
*******************************************************************************
          GESTION DU MENU PRINCIPAL
*******************************************************************************
}
Procedure Encadre_Option (Num_Option : Byte);
{ Met un cadre autour d'une option choisie. }
Var A, B, C, D : Integer;
Begin { encadre_option }
  A := ((Num_Option - 1) Mod 2) * 40 + 1;
  B := ((Num_Option - 1) Div 2) * 2  + 1;
  C := A + 39;
  D := B + 2;
  Type_Cadre := 2;
  Dessin_Cadre_Form_Fond (A, B, C, D, White, Lightgray)
End; { encadre_option }

Procedure Decadre_Option (Num_Option : Byte);
{ Enleve le cadre qui est autour d'une option choisie. }
Var A, B, C, D : Integer;
Begin { decadre_option }
  A := ((Num_Option - 1) Mod 2) * 40 + 1;
  B := ((Num_Option - 1) Div 2) * 2  + 1;
  C := A + 39;
  D := B + 2;
  Type_Cadre := 8;
  Dessin_Cadre_Form (A, B, C, D, Black)
End; { decadre_option }

Procedure Affiche_Ecran_Menu (Num_Option : Byte);
{ Affichage de l'‚cran du menu. }
Var I : Byte;
Begin { affiche_ecran_menu }
  Textcolor (Lightgray);
  Textbackground (Black);
  Window (1, 1, 80, 25);
  Clrscr;
  For I := 1 To C_Nb_Options Do
    Begin
      Gotoxy (((I-1) Mod 2)*40+2, ((I-1) Div 2)*2+2);
      Case (I) Of
        1  : Write ('Informations sur: "Listeur"');
        2  : Write ('Choix des valeurs d''origine');
        3  : Write ('Impression du fichier');
        4  : Write ('Quitter ''LISTEUR''');
        5  : If (T_Papier)
             Then
               Write ('Papier: feuille … feuille')
             Else
               Write ('Papier: continu (listing)')
             {endif};
        6  : Write ('Fichier … imprimer: ', Get_Nom_Fichier (Nom_Fich));
        7  : Write ('Haut de page: ''', Copy (Haut_Page, 1, 22), '''');
        8  : Write ('Bas de page:  ''', Copy (Bas_Page,  1, 22), '''');
        9  : Write ('Num‚ro de la premiŠre page: ', Num_Page);
        10 : If (Page_Continue)
             Then
               Write ('Num‚rotation continue: ON')
             Else
               Write ('Num‚rotation continue: OFF')
             {endif};
        11 : Write ('Nombre de lignes par page: ', Nb_Ligne_Page);
        12 : Write ('Nombre de caractŠres par ligne: ', Nb_Col_Ligne);
        13 : If (Impr_Num_Lig)
             Then
               Write ('Mise des num‚ros de ligne: ON')
             Else
               Write ('Mise des num‚ros de ligne: OFF')
             {endif};
        14 : If (Carac_End_Of_Line)
             Then
               Write ('CaractŠre ''œ'' de fin de ligne: ON')
             Else
               Write ('CaractŠre ''œ'' de fin de ligne: OFF')
             {endif};
        15 : Begin
               Date_X := Curseur_X;
               Date_Y := Curseur_Y;
               Affiche_Date (Date_X, Date_Y)
             End;
        16 : Begin
               Heure_X := Curseur_X;
               Heure_Y := Curseur_Y;
               Affiche_Heure (Heure_X, Heure_Y)
             End
      End
    End
  {endfor};
  Encadre_Option (Num_Option)
End; { affiche_ecran_menu }

Procedure Choix_Deplacement (Var Num_Option : Byte);
{ D‚placements avec les fleches, ou choix d'une option (ou des ‚crans d'aide). }
Var Old_Num_Option : Byte;
Begin { choix_deplacement }
  Old_Num_Option := Num_Option;
  Case (Readkey) Of
    Touche_F1     : Begin
                      Ecran_Aide;
                      Affiche_Ecran_Menu (Num_Option)
                    End;
    Touche_Haut   : If (Num_Option < 3)
                    Then
                      Num_Option := Num_Option + C_Nb_Options - 2
                    Else
                      Num_Option := Num_Option - 2
                    {endif};
    Touche_Bas    : If (Num_Option > C_Nb_Options - 2)
                    Then
                      Num_Option := Num_Option - C_Nb_Options + 2
                    Else
                      Num_Option := Num_Option + 2
                    {endif};
    Touche_Gauche,
    Touche_Droite : If ((Num_Option Mod 2) = 0)
                    Then
                      Dec (Num_Option)
                    Else
                      Inc (Num_Option)
                    {endif}
  Else
    Write (Carac_Bell)
  End;
  If (Num_Option <> Old_Num_Option)
  Then
    Begin
      Decadre_Option (Old_Num_Option);
      Encadre_Option (Num_Option)
    End
  {endif}
End; { choix_deplacement }

Procedure Choix_Option (Num_Option : Byte);
{ Gestion des choix possibles dans le menu, et actions en rapport avec le choix
execut‚. }
Begin { choix_option }
  Clrscr;
  Case (Num_Option) Of
    1  : Presentation;
    2  : Variables_Defaut;
    3  : Impression;
{   4  : Arret du programme par retour sans modifications. }
    5  : T_Papier := Not T_Papier;
    6  : Ask_Nom_Fichier (Nom_Fich);
    7  : Haut_Page := Ask_Message ('Message de haut de page.', Haut_Page);
    8  : Bas_Page := Ask_Message ('Message de bas de page.', Bas_Page);
    9  : Num_Page := Changer_Valeur ('Num‚ro de la premiŠre page', 0, 999, Num_Page);
    10 : Page_Continue := Not Page_Continue;
    11 : Nb_Ligne_Page := Changer_Valeur ('Nombre de lignes par page', 5, Hauteur_Page, Nb_Ligne_Page);
    12 : Nb_Col_Ligne := Changer_Valeur ('Nombre de caractŠres par ligne', 1, 160, Nb_Col_Ligne);
    13 : Impr_Num_Lig := Not Impr_Num_Lig;
    14 : Carac_End_Of_Line := Not Carac_End_Of_Line;
    15 : Saisie_Date;
    16 : Saisie_Heure
  End;
  Affiche_Ecran_Menu (Num_Option)
End; { choix_option }

Procedure Traitement_Menu;
{ Gestion du menu, des d‚placements et des autres options. }
Var Num_Option : Byte;
    Carac      : Char;
Begin { traitement_menu }
  Num_Option := 1;
  Affiche_Ecran_Menu (Num_Option);
  Vide_Tampon_Clavier;
  Repeat
    Affiche_Date (Date_X, Date_Y);
    Affiche_Heure (Heure_X, Heure_Y);
    Carac := Readkey;
    Case (Carac) Of
      Carac_Nul     : Choix_Deplacement (Num_Option);
      Touche_Return : Choix_Option (Num_Option);
    Else
      Write (Carac_Bell)
    End
  Until ((Num_Option = 4) And (Carac = Touche_Return))
End; { traitement_menu }

{
*******************************************************************************
          CORPS DU PROGRAMME
*******************************************************************************
}
Begin { listeur }
  init_olf_message (mess_shareware);
  init_licence ('LIST');
  init_olf_software ('Listeur (v'+num_version+')', #155' Patrick Pr‚martin '+date_version);
  Curseur_Off;
  Reset_Screen;
  Variables_Defaut;
  Presentation;
  Traitement_Menu;
  Reset_Screen;
  Curseur_On;
  writeln ('Thanks for using LISTEUR...');
  writeln ('Don''t forget this program is SHAREWARE, read LISTEUR.DOC.');
  writeln;
End. { listeur }
