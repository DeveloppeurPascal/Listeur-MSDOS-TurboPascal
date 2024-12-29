unit list_opt;
{
Auteur: Pr‚martin Patrick.
Date: (2.1) 13/08/1991.
Langage: Turbo Pascal 6.0

But: Gestion des entr‚es/sorties non faisables avec Turbo Vision.
}
interface

uses
        { Unit‚s standard. }
    crt,
    dos,
    printer,
        { Unit‚s personnelles. }
    list_var;

function exist (nom_fich : string) : boolean;
function Get_File_Name (path_name : pathstr) : PathStr;
function options_load_opt : boolean;
function options_save_opt : boolean;
function print (ch : string) : boolean;
function tst_touche_escape : boolean;

implementation
const
     touche_esc = #27;

type
    t_donnees = record
                      ch_1  : boolean;        { CaractŠre de fin de ligne ?        }
                      ch_2  : t_string3;      { Extension des fichiers par d‚faut. }
                      ch_3  : integer;        { Hauteur des pages.                 }
                      ch_4  : boolean;        { Impression des num‚ros de lignes ? }
                      ch_5  : t_string80;     { Message de bas de page.            }
                      ch_6  : t_string80;     { Message de d‚but de page.          }
                      ch_7  : integer;        { Nombre de colonnes par ligne.      }
                      ch_8  : integer;        { Nombre d'‚xemplaires.              }
                      ch_9  : integer;        { Nombre de lignes par page.         }
                      ch_10 : integer;        { Num‚ro de la premiŠre page.        }
                      ch_11 : t_pap_typ;      { Type de papier.                    }
                      ch_12 : boolean;        { Impression en continu ?            }
    end;
{
*****************************************************************************
}
function exist (nom_fich : string) : boolean;
var
   fich : file;
begin
     assign (fich, nom_fich);
     {$i-}
     reset (fich);
     close (fich);
     {$i+}
     exist := (ioresult = 0);
end; { exist }
{
*****************************************************************************
}
function Get_File_Name (path_name : pathstr) : PathStr;
var
   EXEName : PathStr;
   Dir : DirStr;
   Name : NameStr;
   Ext : ExtStr;
begin
     if Lo (DosVersion) >= 3
     then
         EXEName := ParamStr(0)
     else
         EXEName := FSearch(c_prog_name, GetEnv('PATH'));
     {endif}
     FSplit (EXEName, Dir, Name, Ext);
     if Dir[Length(Dir)] = '\'
     then
         Dec(Dir[0]);
     {endif}
     Get_File_Name := FSearch(path_name, Dir)
end; { Get_File_Name }
{
*****************************************************************************
}
function options_load_opt : boolean;
var
   fich : file of t_donnees;
   d : t_donnees;
   nom_fich : string;
begin
     nom_fich := get_file_name (c_cfg_name);
     if exist (nom_fich) and (nom_fich <> '')
     then
         begin
              assign (fich, nom_fich);
              reset (fich);
              if (ioresult = 0)
              then
                  begin
                       read (fich, d);
                       close (fich);
                       with d do
                            begin
                                 car_eol := ch_1;
                                 ext_def := ch_2;
                                 haut_pg := ch_3;
                                 imp_nu_lig := ch_4;
                                 ms_dn_pg := ch_5;
                                 ms_up_pg := ch_6;
                                 nb_col_lig := ch_7;
                                 nb_impri := ch_8;
                                 nb_lig_pg := ch_9;
                                 num_pg := ch_10;
                                 pap_typ := ch_11;
                                 pg_cont := ch_12;
                            end;
                       {endwith}
                       options_load_opt := true;
                  end
              else
                  options_load_opt := false;
              {endif}
         end
     else
         options_load_opt := false;
     {endif}
end; { options_load_opt }
{
*****************************************************************************
}
function options_save_opt : boolean;
var
   d : t_donnees;
   fich : file of t_donnees;
begin
     with d do
          begin
               ch_1 := car_eol;
               ch_2 := ext_def;
               ch_3 := haut_pg;
               ch_4 := imp_nu_lig;
               ch_5 := ms_dn_pg;
               ch_6 := ms_up_pg;
               ch_7 := nb_col_lig;
               ch_8 := nb_impri;
               ch_9 := nb_lig_pg;
               ch_10 := num_pg;
               ch_11 := pap_typ;
               ch_12 := pg_cont;
          end;
     {endwith}
     assign (fich, c_cfg_name);
     {$i-}
     rewrite (fich);
     {$i+}
     if (ioresult = 0)
     then
         begin
              {$i-}
              write (fich, d);
              {$i+}
              close (fich);
              options_save_opt := (ioresult = 0);
         end
     else
         options_save_opt := false;
     {endif}
end; { options_save_opt }
{
*****************************************************************************
}
function print (ch : string) : boolean;
begin
     {$i-}
     writeln (lst, ch);
     {$i+}
     print := (ioresult <> 0);
end; { Print }
{
*****************************************************************************
}
function tst_touche_escape : boolean;
begin
     if keypressed
     then
         tst_touche_escape := (readkey = touche_esc)
     else
         tst_touche_escape := false;
     {endif}
end; { Tst_Touche_Escape }

begin
  if (options_load_opt)
  then
    writeln ('Retrieve old options...');
end. { Fin de l'unit‚ 'List_Opt'. }
