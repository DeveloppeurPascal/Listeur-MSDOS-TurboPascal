unit list_var;
{
Logiciel : LISTEUR.
Auteur : Pr‚martin Patrick.
Dates de modification: (2.0) 23/07/1991. 09/08/1991.
                       (2.1) 13/08/1991. 26/03/1992.
Langage: Turbo Pascal 6.0

**********************************************************************
          VARIABLES ET CONSTANTES GLOBALES
**********************************************************************
}
{ $define demo_vers} { Voir aussi dans: LISTEUR2.PAS }
                    {                  LIST_PRG.PAS }
                    {                  LIST_VAR.PAS }

interface

type
    t_pap_typ  = (continu, feuille);
    t_string3  = string [3];
    t_string80 = string [80];

Const
     c_aut_name : string [17] = 'Pr‚martin Patrick';
     c_dat_vers : string [10] = '03/26/1992';
{$ifdef demo_vers}
     c_num_vers : string [8]  = '2.1 d‚mo';
{$else}
     c_num_vers : string [3]  = '2.1';
{$endif}

     c_prog_name              = 'LISTEUR2.EXE';
     c_help_name              = 'LISTEUR2.HLP';
     c_cfg_name               = 'LISTEUR2.CFG';

     c_car_eol    : boolean    = false;
     c_ext_def    : t_string3  = '*  ';
     c_haut_pg    : integer    = 63;
     c_imp_nu_lig : boolean    = false;
     c_ms_dn_pg   : t_string80 = '$P.';
     c_ms_up_pg   : t_string80 = 'Listing de $F.';
     c_nb_col_lig : integer    = 80;
     c_nb_impri   : integer    = 1;
     c_nb_lig_pg  : integer    = 53;
     c_nom_fich   : string[13] = '\LISTEUR.DOC';
     c_num_pg     : integer    = 1;
     c_pap_typ    : t_pap_typ  = continu;
     c_pg_cont    : boolean    = true;

Var
     car_eol    : boolean;
     ext_def    : t_string3;
     haut_pg    : integer;
     imp_nu_lig : boolean;
     ms_dn_pg   : t_string80;
     ms_up_pg   : t_string80;
     nb_col_lig : integer;
     nb_impri   : integer;
     nb_lig_pg  : integer;
     nom_fich   : string;
     num_pg     : integer;
     page       : integer;
     pap_typ    : t_pap_typ;
     pg_cont    : boolean;

procedure init_variables;

implementation
uses
  u_mouse;

Procedure init_Variables;
Begin
     car_eol    := c_car_eol;
     ext_def    := c_ext_def;
     haut_pg    := c_haut_pg;
     imp_nu_lig := c_imp_nu_lig;
     ms_dn_pg   := c_ms_dn_pg;
     ms_up_pg   := c_ms_up_pg;
     nb_col_lig := c_nb_col_lig;
     nb_impri   := c_nb_impri;
     nb_lig_pg  := c_nb_lig_pg;
     nom_fich   := c_nom_fich;
     num_pg     := c_num_pg;
     page       := 0;
     pap_typ    := c_pap_typ;
     pg_cont    := c_pg_cont;
End; { init_variables }

begin
     init_variables;
     show_mouse;
end. { Fin de l'unit‚ 'List_Var'. }
