unit list_prg;
{
Logiciel : LISTEUR.
Auteur : Pr‚martin Patrick.
Dates de modification: (2.0) 23/07/1991. 02/08/1991. 09/08/1991.
                       (2.1) 13/08/1991. 26/03/1992.
Langage: Turbo Pascal 6.0

*******************************************************************************
          CONTROLE DE L'IMPRESSION
*******************************************************************************
}
{ $define demo_vers} { Voir aussi dans LISTEUR2.PAS }
                    {                 LIST_PRG.PAS }
                    {                 LIST_VAR.PAS }

interface

uses
        { Unit‚s utilisateur: }
    list_dir,
    list_lst,
    list_opt,
    list_var,
        { Unit‚s Turbo Vision: }
    msgbox,
    views,
        { Unit‚s standard: }
    crt;

procedure impression;
procedure pause;

implementation

const
     carac_enter = #13;
     carac_ff    = #12;
     carac_lf    = #10;
     touche_esc  = #27;

var
   arret_impression : boolean;

function non_pos_left (carac : char; ch : string) : integer;
var
   i : integer;
begin
     i := 1;
     while ((i < length (ch)) and (ch [i] = carac)) do
           inc (i);
     {endwhile}
     non_pos_left := i;
end; { non_pos_left }

function non_pos_right (carac : char; ch : string) : integer;
var
   i : integer;
begin
     i := length (ch);
     while ((i > 0) and (ch [i] = carac)) do
           dec (i);
     {endwhile}
     non_pos_right := i;
end; { non_pos_right }

Procedure Travail_En_Cours;
Begin
     textcolor (lightgray);
     textbackground (black);
     gotoxy (1, 25);
     write ('Please wait, I''m printing '+nom_fich+'...');
{$ifdef demo_vers}
     write (' Demo version.');
{$endif}
     clreol;
End; { travail_en_cours }

Procedure Page_Suivante;
Begin
     if (pap_typ = feuille)
     then
       begin
         if (cmcancel = messagebox ('Insert a new page.', nil, mfokcancel))
         then
             arret_impression := (cmyes = messagebox ('Do you want to stop printing ?', nil, mfyesbutton + mfnobutton +
mfconfirmation))
         {endif}
       end
     else
         arret_impression := tst_touche_escape;
     {endif}
End; { page_suivante }

Procedure Print_Center (Chaine : String);
Var I, J : Integer;
Begin
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
      I := (Nb_Col_Lig - Length (chaine)) Div 2;
      For J := 1 To I Do
        insert (' ', chaine, 1)
      {endfor};
      arret_impression := arret_impression or print (Chaine)
    End
  {endif}
End; { print_center }

procedure Traitement_Ligne (var Chaine : String; var num_ligne : integer);
Var
   chaine2 : string;
   i : integer;
Begin
{ Mise du num‚ro de la ligne. }
  If (Imp_Nu_Lig)
  Then
    Begin
      Inc (Num_Ligne);
      Str (Num_Ligne, Chaine2);
      Chaine := Concat (Chaine2, ' ', Chaine)
    End
  {endif};
{ Mise du caractŠre de fin de ligne. }
  If (Car_EOL)
  Then
    Chaine := Concat (Chaine, 'œ')
  {endif};
{ Suppression des caractŠres Carac_Lf, Carac_Enter et Carac_Ff. }
  i := pos (carac_ff, chaine);
  while (i > 0) do
        begin
             delete (chaine, i, 1);
             i := pos (carac_ff, chaine);
        end;
  {endwhile}
  i := pos (carac_lf, chaine);
  while (i > 0) do
        begin
             delete (chaine, i, 1);
             i := pos (carac_lf, chaine);
        end;
  {endwhile}
  i := pos (carac_enter, chaine);
  while (i > 0) do
        begin
             delete (chaine, i, 1);
             i := pos (carac_enter, chaine);
        end;
  {endwhile}
End; { traitement_ligne }

Procedure Impression;
Var
   I,
   j,
   Num_Ligne_Fic,
   Ligne_Impri,
   Ligne        : Integer;
   Fichier      : Text;
   Chaine       : String;
   Fin_Ligne    : Boolean;
{$ifdef demo_vers}
   stoppe_impri : boolean;
   deb_fi_pg : integer;
{$endif}
Begin
  Arret_Impression := False;
  j := 1;
  while not ((j > nb_impri) or (arret_impression)) do
        begin
             Page := Num_Pg;
             nom_fich := liste_premier;
             Repeat
{$ifdef demo_vers}
                   stoppe_impri := false;
                   deb_fi_pg := page;
{$endif}
                   If (Exist (Nom_Fich))
                   Then
                       Begin
                            Travail_En_Cours;
                            Ligne_Impri := Succ ((c_Haut_Pg - Nb_Lig_Pg) Div 2);
                            Assign (Fichier, Nom_Fich);
                            Reset (Fichier);
                            If Not Pg_Cont
                            Then
                                Page := Num_pg;
                            {endif}
                            Num_Ligne_Fic := 0;
                            Fin_Ligne := True;
{$ifdef demo_vers}
                            while not (arret_impression or stoppe_impri or ((eof (fichier)) and (fin_ligne))) do
{$else}
                            While Not (Arret_Impression Or ((Eof (Fichier)) And (Fin_Ligne))) Do
{$endif}
                                  Begin
                                       page_suivante;
                                       Print_Center (ms_up_pg);
                                       arret_impression := arret_impression or print ('');
                                       Ligne := 0;
                                       While Not (Eof(Fichier) Or (Ligne >= nb_lig_pg - 2)) Do
                                             Begin
                                                  Inc (Ligne);
                                                  If (Fin_Ligne)
                                                  Then
                                                      Begin
                                                           Readln (Fichier, Chaine);
                                                           Traitement_Ligne (Chaine, Num_Ligne_Fic);
                                                      End
                                                  Else
                                                      Delete (Chaine, 1, nb_col_lig);
                                                  {endif}
                                                  arret_impression := arret_impression or print (Copy (Chaine, 1, nb_col_lig));
                                                  Fin_Ligne := (nb_col_lig >= Length (Chaine));
                                             End;
                                       {endwhile}
                                       For I := Ligne To pred (nb_lig_pg) Do
                                           arret_impression := arret_impression or print ('');
                                       {endfor}
                                       If (Ligne < nb_lig_pg)
                                       Then
                                           Print_Center (ms_dn_pg);
                                       {endif}
                                       Inc (Page);
                                       arret_impression := arret_impression or print (carac_ff);
{$ifdef demo_vers}
                                       stoppe_impri := (page = deb_fi_pg +2);
{$endif}
                                  End;
                            {endwhile}
                            Close (Fichier);
                       End;
                   {endif}
                   Nom_Fich := liste_suivant;
             until (arret_impression or (nom_fich = ''));
             inc (j);
        end;
  {endwhile}
End; { impression }

procedure pause;
var
   carac : char;
begin
     while keypressed do
           carac := readkey;
     {endwhile}
     carac := readkey;
     while keypressed do
           carac := readkey;
     {endwhile}
end; { pause }

End. { Fin de l'unit‚ 'List_Prg'. }
