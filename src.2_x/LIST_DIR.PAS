unit list_dir;
{
Logiciel : LISTEUR.
Auteur : Pr‚martin Patrick.
Dates de modification : (2.0) 23/07/1991.
Langage: Turbo Pascal 6.0

*******************************************************************************
          GESTION DES OPTIONS DANS LES MESSAGES DE HAUT ET DE BAS DE PAGE.
*******************************************************************************
}
interface

uses
    list_var;

function gestion_directives (chaine : string) : string;

implementation

uses
    dos;

procedure option_dollar (var chaine : string; i : integer);
begin
     insert ('$', chaine, i);
end; { option_dollar }

Procedure Option_D (Var Chaine : String; I : Integer);
Var
   chaine_d,
   chaine2 : string;
   aa : word;
   mm,
   jj : byte;
Begin
     asm
        push ax
        push cx
        push dx
        mov ah, 2ah
        int 21h
        mov aa, cx
        mov mm, dh
        mov jj, dl
        pop dx
        pop cx
        pop ax
     end;
     Str (Jj, Chaine_D);
     Str (Mm, Chaine2);
     Chaine_D := Concat (Chaine_D, '/', Chaine2);
     Str (Aa, Chaine2);
     Chaine_D := Concat (Chaine_D, '/', Chaine2);
     Insert (Chaine_D, Chaine, I);
End; { option_d }

Procedure Option_E (Var Chaine : String; I : Integer);
var
   d : dirstr;
   n : namestr;
   e : extstr;
Begin
     fsplit (nom_fich, d, n, e);
     Insert (Copy (e, 2, 3), Chaine, I);
End; { option_e }

Procedure Option_F (Var Chaine : String; I : Integer);
var
   d : dirstr;
   n : namestr;
   e : extstr;
Begin
     fsplit (nom_fich, d, n, e);
     Insert (concat (n, e), Chaine, I)
End; { option_f }

Procedure Option_N (Var Chaine : String; I : Integer);
var
   d : dirstr;
   n : namestr;
   e : extstr;
Begin
     fsplit (nom_fich, d, n, e);
     Insert (n, Chaine, I)
End; { option_n }

Procedure Option_P (Var Chaine : String; I : Integer);
Var
   Chaine2 : String;
Begin
     Str (Page, Chaine2);
     Insert (Chaine2, Chaine, I)
End; { option_p }

Procedure Option_T (Var Chaine : String; I : Integer);
Var
   chaine_t,
   chaine2 : string;
   hh,
   mm,
   sec : byte;
Begin
     asm
        push ax
        push cx
        push dx
        mov ah, 2ch
        int 21h
        mov hh, ch
        mov mm, cl
        mov sec, dh
        pop dx
        pop cx
        pop ax
     end;
     Str (Hh, Chaine_T);
     Str (Mm, Chaine2);
     Chaine_T := Concat (Chaine_T, ':', Chaine2);
     Str (Sec, Chaine2);
     Chaine_T := Concat (Chaine_T, ':', Chaine2);
     Insert (Chaine_T, Chaine, I)
End; { option_t }

Function Gestion_Directives (Chaine : String) : String;
Var
   I : Integer;
   Option : Char;
Begin
     I := Pos ('$', Chaine);
     If ((I <> 0) And (I <> Length (Chaine)))
     Then
         Begin
              Option := Chaine [Succ (I)];
              Delete (Chaine, I, 2);
              Case (Upcase (Option)) Of
                   '$' : option_dollar (chaine, i); { affichage d'un $ }
                   'D' : Option_D (Chaine, I); { date courante }
                   'E' : Option_E (Chaine, I); { extension du fichier }
                   'F' : Option_F (Chaine, I); { nom complet du fichier }
                   'N' : Option_N (Chaine, I); { nom du fichier }
                   'P' : Option_P (Chaine, I); { num‚ro de page }
                   'T' : Option_T (Chaine, I); { heure courante }
              End;
              Gestion_Directives := concat (copy (chaine, 1, i),
Gestion_Directives (copy (chaine, succ (i), (length (chaine) - i))));
         End
     Else
         Gestion_Directives := Chaine;
     {endif}
End; { gestion_directives }

end. { Fin de l'unit‚ 'List_Dir'. }
