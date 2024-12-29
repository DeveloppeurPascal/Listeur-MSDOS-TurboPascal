unit list_lst;
{
Auteur: Pr‚martin Patrick.
Date: 02/08/1991. 26/03/1992.
Langage: Turbo Pascal 6.0

But: Gestion d'une liste de noms de fichiers … imprimer.
}
interface

type
    p_chaine = ^t_chaine;
    t_chaine = string[64];

function liste_nb_elem : integer;
function liste_premier : t_chaine;
function liste_suivant : t_chaine;
function liste_fin : boolean;
function liste_vide : boolean;

procedure liste_init;
function liste_insertion (chaine : t_chaine) : boolean;
procedure liste_effacer;

implementation

type
    p_liste = ^t_liste;
    t_liste = record
                    suivant : p_liste;
                    chaine : p_chaine;
    end;

var
   liste : p_liste;
   courant : p_liste;
   dernier : p_liste;
   nb_elem : integer;

function liste_nb_elem : integer;
begin
     liste_nb_elem := nb_elem;
end; { Liste_Nb_Elem }

function liste_premier : t_chaine;
begin
     if not (liste_vide)
     then
         begin
              courant := liste;
              if (courant^.chaine <> nil)
              then
                liste_premier := courant^.chaine^
              else
                liste_premier := '';
         end
     else
         liste_premier := '';
     {endif}
end; { Liste_Premier }

function liste_suivant : t_chaine;
begin
  if not (liste_fin)
  then
    begin
      courant := courant^.suivant;
      if (courant^.chaine <> nil)
      then
        liste_suivant := courant^.chaine^
      else
        liste_suivant := '';
    end
  else
    liste_suivant := '';
end; { Liste_Suivant }

function liste_fin : boolean;
begin
     liste_fin := (courant = dernier);
end; { Liste_Fin }

function liste_vide : boolean;
begin
     liste_vide := (nil = liste^.chaine);
end; { Liste_Vide }

procedure liste_init;
begin
     new (liste);
     liste^.suivant := nil;
     liste^.chaine := nil;
     courant := liste;
     dernier := liste;
     nb_elem := 0;
end; { Liste_Init }

function liste_insertion (chaine : t_chaine) : boolean;
var
   ch : p_chaine;
   elem : p_liste;
begin
     new (ch);
     if (ch <> nil)
     then
         begin
              ch^ := chaine;
              new (elem);
              if (elem <> nil)
              then
                  begin
                       elem^.suivant := nil;
                       elem^.chaine := nil;
                       inc (nb_elem);
                       dernier^.chaine := ch;
                       dernier^.suivant := elem;
                       dernier := elem;
                       liste_insertion := true;
                  end
              else
                  begin
                       dispose (ch);
                       liste_insertion := false;
                  end;
              {endif}
         end
     else
         liste_insertion := false;
     {endif}
end; { Liste_Insertion }

procedure liste_effacer;
var
   elem : p_liste;
begin
  courant := liste;
  while (courant <> nil) do
    begin
      if (courant^.chaine <> nil)
      then
        dispose (courant^.chaine);
      {endif}
      elem := courant^.suivant;
      dispose (courant);
      courant := elem;
    end;
  {endwhile}
  courant := nil;
  liste := nil;
  dernier := nil;
  nb_elem := 0;
end; { Liste_Effacer }

var
  oldexitproc : pointer;

procedure done; far;
begin
  liste_effacer;
  exitproc := oldexitproc;
end; { Done }

begin
  liste_init;
  oldexitproc := exitproc;
  exitproc := @done;
end. { Fin de l'unit‚ 'List_Lst'. }
