program listeur_2;
{
Logiciel : LISTEUR.
Auteur: Patrick Pr‚martin.
Date: (2.0) 19/06/1991. 22/06/1991. 06/07/1991. 23/07/1991. 01/08/1991.
            02/08/1991. 05/08/1991. 06/08/1991. 07/08/1991. 09/08/1991.
      (2.1) 13/08/1991. 26/03/1992.
Langage: Turbo Pascal 6.0

But: Application permettant de faire des impressions de fichiers textes ASCII
     avec prise en compte de differents parametres.
}
{$X+}
{$M 32768,0,655350}
{ $define demo_vers} { Voir aussi dans: LISTEUR2.PAS }
                    {                  LIST_PRG.PAS }
                    {                  LIST_VAR.PAS }

{
*****************************************************************************
}
uses                    { Unites de Turbo Pascal. }
    dos,
                        { Unites de Turbo Vision. }
    app,
    dialogs, drivers,
    helpfile,
    memory, menus, msgbox,
    objects,
    stddlg,
    views,
                        { Unites utilisateur. }
    list_cmd,
    list_hlp,
    list_lst,
    list_opt,
    list_prg,
    list_var,
    olf_software,
    u_calendar,
    u_dialogs,
    u_horloge;

{
*****************************************************************************
}
type
    t_ptr_listeur_app = ^t_listeur_app;
    t_listeur_app = object (tapplication)
                           constructor init;
                           procedure handleevent (var Event : tevent); virtual;
                           procedure initstatusline; virtual;
                           procedure initmenubar; virtual;
                           procedure getevent (var event : tevent); virtual;
                           function  GetPalette: PPalette; virtual;
                           procedure outofmemory; virtual;
    end;
{
*****************************************************************************
}
constructor t_listeur_app.init;
begin
     TApplication.Init;
{ Pr‚paration des ‚ventuels flux. }
     RegisterObjects;
     RegisterViews;
     RegisterMenus;
     RegisterDialogs;
     RegisterApp;
     RegisterHelpFile;
     Register_Calendar;
     register_dialogs;
     register_horloge;
{$ifdef demo_vers}
     desktop^.helpctx := hc_listeur_demo;
{$else}
     desktop^.helpctx := hc_listeur;
{$endif}
end; { t_listeur_app.init }

{
*****************************************************************************
}
procedure t_listeur_app.initstatusline;
var
   r : trect;
begin
  getextent (r);
  r.a.y := r.b.y-1;
  statusline := new (pstatusline, init (r,
{$ifdef demo_vers}
    newstatusdef (hc_listeur_demo, hc_listeur_demo,
{$else}
    newstatusdef (hc_listeur, hc_listeur,
{$endif}
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey ('~F3~ Select a file', kbf3, cmselect,
      newstatuskey ('~F10~ Menu', kbf10, cmmenu,
      newstatuskey ('~Alt-X~ Exit Listeur', kbaltx, cmexit,
      nil)))),
    newstatusdef (hc_menu_info, hc_menu_info,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Help menu.', kbnokey, cmhelp,
      nil)),
    newstatusdef (hc_menu_file_list, hc_menu_file_list,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' File and list manager.', kbnokey, cmhelp,
      nil)),
    newstatusdef (hc_file_select, hc_file_select,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Select a file to print.', kbf3, cmselect,
      nil)),
    newstatusdef (hc_file_erase, hc_file_erase,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Delete the list of files to print.', kbnokey, cmeraselist,
      nil)),
    newstatusdef (hc_file_ch_dir, hc_file_ch_dir,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Choose a new default directory.', kbnokey, cmchangedir,
      nil)),
    newstatusdef (hc_file_dos_shell, hc_file_dos_shell,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Temporarely exit to DOS.', kbnokey, cmdosshell,
      nil)),
    newstatusdef (hc_file_exit, hc_file_exit,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Exit LISTEUR.', kbaltx, cmexit,
      nil)),
    newstatusdef (hc_impression, hc_impression,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Print files in the list.', kbnokey, cmprint,
      nil)),
    newstatusdef (hc_menu_options, hc_menu_options,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Computer and printer manager.', kbnokey, cmhelp,
      nil)),
    newstatusdef (hc_ch_date, hc_ch_date,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change the system date.', kbf4, cmchangedate,
      nil)),
    newstatusdef (hc_ch_heure, hc_ch_heure,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change the system time.', kbf5, cmchangetime,
      nil)),
    newstatusdef (hc_smenu_parameters, hc_smenu_parameters,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change Printer or LISTEUR parameters.', kbnokey, cmhelp,
      nil)),
    newstatusdef (hc_param_printer, hc_param_printer,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change printer parameters.', kbf6, cmprinter,
      nil)),
    newstatusdef (hc_param_msg, hc_param_msg,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change top and bottom messages.', kbf7, cmmessages,
      nil)),
    newstatusdef (hc_param_others, hc_param_others,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Change LISTEUR parameters.', kbf8, cmothers,
      nil)),
    newstatusdef (hc_load_opt, hc_load_opt,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Loading configuration file.', kbnokey, cmload_opt,
      nil)),
    newstatusdef (hc_save_opt, hc_save_opt,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Saving configuration file.', kbnokey, cmsave_opt,
      nil)),
    newstatusdef (hc_default_opt, hc_default_opt,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      newstatuskey (#219' Default configuration.', kbnokey, cmdefault_opt,
      nil)),
    newstatusdef (hcnocontext, hcnocontext,
      newstatuskey ('', kbnokey, cmquit,
      nil),
    newstatusdef (0, $ffff,
      newstatuskey ('~F1~ Help', kbf1, cmhelp,
      nil),
    nil)))))))))))))))))))))
  ));
end; { T_Listeur_App.InitStatusLine }
{
*****************************************************************************
}
procedure t_listeur_app.initmenubar;
var
   r : trect;
begin
  getextent (r);
  r.b.y := r.a.y+1;
  menubar := new (pmenubar, init (r,
    newmenu (
      newsubmenu ('~'#240'~', hc_menu_info,
        newmenu (
          newitem ('~A~bout Listeur', 'F1', kbF1, cmhelp, hc_menu_info,
        nil)),
      newsubmenu ('~F~ile list', hc_menu_file_list,
        newmenu (
          newitem ('~S~elect a file ...', 'F3', kbF3, cmselect, hc_file_select,
          newitem ('~E~rase list ...', '', kbNoKey, cmEraseList, hc_file_erase,
          newitem ('~C~hange Dir ...', '', kbNoKey, cmChangeDir, hc_file_ch_dir,
          newline (
          newitem ('~D~os shell', '', kbNoKey, cmDosShell, hc_file_dos_shell,
          newitem ('E~x~it', 'Alt-X', kbAltX, cmexit, hc_file_exit,
        nil))))))),
      newitem ('~P~rint List', 'F2', kbF2, cmPrint, hc_impression,
      newsubmenu ('~O~ptions', hc_menu_options,
        newmenu (
          newitem ('Change ~D~ate ...', 'F4', kbF4, cmChangeDate, hc_ch_date,
          newitem ('Change ~T~ime ...', 'F5', kbF5, cmChangeTime, hc_ch_heure,
          newsubmenu ('~P~arameters', hc_smenu_parameters,
            newmenu (
              newitem ('~P~rinter ...', 'F6', kbF6, cmPrinter, hc_param_printer,
              newitem ('~M~essages ...', 'F7', kbF7, cmMessages, hc_param_msg,
              newline (
              newitem ('~O~thers ...', 'F8', kbF8, cmOthers, hc_param_others,
            nil))))),
            newline (
            newitem ('~S~ave options ...', '', kbnokey, cmSave_opt, hc_save_opt,
            newitem ('~R~etrieve options ...', '', kbnokey, cmload_opt, hc_load_opt,
            newitem ('D~e~fault options ...', '', kbnokey, cmdefault_opt, hc_default_opt,
        nil)))))))),
    nil))))
  )));
end; { T_Listeur_App.InitMenuBar }
{
*****************************************************************************
}
function t_listeur_app.GetPalette: PPalette;
const
     CNewColor = CColor + CHelpColor;
     CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
     CNewMonochrome = CMonochrome + CHelpMonochrome;
     P : array [apColor..apMonochrome] of string [Length (CNewColor)] =
         (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
     GetPalette := @P [AppPalette];
end; { t_listeur_app.getpalette }
{
*****************************************************************************
}
procedure T_Listeur_App.HandleEvent (var event : tevent);

  procedure selector;
  var
     nom_fich : pathstr;

    function File_select (chemin : PathStr) : pathstr;
    var
       select : PFileDialog;
       file_name : pathstr;
    begin
         select := New (PFileDialog, Init (chemin, 'Select file to print', '~N~ame', fdOpenButton, 100));
         select^.HelpCtx := hc_file_selector;
         if (ValidView (select) <> nil)
         then
             begin
                  if (Desktop^.ExecView (select) <> cmCancel)
                  then
                      begin
                           select^.GetFileName (File_Name);
                           file_select := file_name;
                      end
                  else
                      file_select := '';
                  {endif}
                  Dispose (select, Done);
             end
         else
             file_select := '';
         {endif}
    end; { file_select }
  
  begin
       nom_fich := file_select ('*.'+ext_def);
       if (nom_fich <> '')
       then
           if not liste_insertion (nom_fich)
           then
               outofmemory;
           {endif}
       {endif}
  end; { selector }

  procedure erase_list;
  begin
       if (messagebox ('Do you really want to delete the list of file ?', nil, mfconfirmation + mfyesbutton +
          mfnobutton) = cmyes)
       then
           begin
                liste_effacer;
                liste_init;
           end
       {endif}
  end; { select }

  procedure Change_Dir;
  var
     Direct : PChDirDialog;
  begin
       Direct := New (PChDirDialog, Init (cdNormal, 101));
       Direct^.HelpCtx := hc_ch_direct;
       if ValidView (Direct) <> nil
       then
           begin
                DeskTop^.ExecView (Direct);
                Dispose (Direct, Done);
           end;
       {endif}
  end; { change_dir }

  procedure change_date;
  var
     calendrier : P_Calendar_Window;
  begin
       calendrier := New (P_Calendar_Window, Init);
       calendrier^.HelpCtx := hc_calendrier;
       if (validview (calendrier) <> nil)
       then
           begin
                desktop^.execview (calendrier);
                dispose (calendrier, done);
           end;
       {endif}
  end; { change_date }

  procedure change_time;
  var
     horloge : p_horloge_window;
  begin
       horloge := new (p_horloge_window, init);
       horloge^.helpctx := hc_horloge;
       if (validview (horloge) <> nil)
       then
           begin
                desktop^.execview (horloge);
                dispose (horloge, done);
           end;
       {endif}
  end; { change_time }

  procedure Dos_Shell;
  var
     path_2 : string;
  begin
       getdir (0, path_2);
       DoneSysError;
       DoneEvents;
       DoneVideo;
       DoneMemory;
       SetMemTop (HeapPtr);
       printstr ('Type EXIT to return to Listeur '+c_num_vers+'...');
{$ifdef demo_vers}
       printstr ('Demo version...');
{$endif}
       SwapVectors;
       Exec (GetEnv ('COMSPEC'), '');
       SwapVectors;
       SetMemTop (HeapEnd);
       InitMemory;
       InitVideo;
       InitEvents;
       InitSysError;
       chdir (path_2);
       Redraw;
  end; { dos_shell }

  procedure print_list;
  begin
       if liste_vide
       then
           messagebox ('There are no file in the list. I can''t print now.', nil, mferror + mfcancelbutton)
       else
           if (cmyes = messagebox ('Do you want to print the file list now ?', nil, mfConfirmation + mfYesButton + mfNoButton))
           then
               impression;
           {endif}
       {endif}
       redraw;
  end; { print_list }

  procedure param_printer;
  type
      t_boite = record
                      champ_1 : longint;
                      champ_2 : longint;
                      champ_3 : longint;
                      champ_4 : longint;
                      champ_5 : longint;
                      bouton_1 : word;
                      bouton_2 : word;
      end;
  var
     boite : pdialog;
     boite_data : t_boite;
     ligne : p_input_number;
     bouton : pradiobuttons;
     r : trect;
  begin
       r.assign (23, 2, 57, 23);
       boite := new (pdialog, init (r, 'Printer parameters'));
       with boite^ do
            begin
                 options := options or ofcentered;
                 helpctx := hc_param_printer;
                 r.assign (27, 1, 32, 2);
                 ligne := new (p_input_number, init (r, 10, 999));
                 ligne^.helpctx := hc_input_number;
                 insert (ligne);
                 r.assign (1, 1, 26, 2);
                 insert (new (plabel, init (r, '~P~aper length', ligne)));
                 r.assign (27, 3, 32, 4);
                 ligne := new (p_input_number, init (r, 4, 983));
                 ligne^.helpctx := hc_input_number;
                 insert (ligne);
                 r.assign (1, 3, 26, 4);
                 insert (new (plabel, init (r, '~N~umber of line per page', ligne)));
                 r.assign (27, 5, 32, 6);
                 ligne := new (p_input_number, init (r, 1, 132));
                 ligne^.helpctx := hc_input_number;
                 insert (ligne);
                 r.assign (1, 5, 26, 6);
                 insert (new (plabel, init (r, '~L~ine length', ligne)));
                 r.assign (25, 7, 32, 8);
                 ligne := new (p_input_number, init (r, 0, 32767));
                 ligne^.helpctx := hc_input_number;
                 insert (ligne);
                 r.assign (1, 7, 24, 8);
                 insert (new (plabel, init (r, '~F~irst page number', ligne)));
                 r.assign (27, 9, 32, 10);
                 ligne := new (p_input_number, init (r, 1, 999));
                 ligne^.helpctx := hc_input_number;
                 insert (ligne);
                 r.assign (1, 9, 26, 10);
                 insert (new (plabel, init (r, '~E~xemplar number', ligne)));
                 r.assign (3, 12, 18, 14);
                 bouton := new (pradiobuttons, init (r,
                        newsitem ('Friction',
                        newsitem ('Traction',
                        nil))
                 ));
                 bouton^.helpctx := hc_radio_buttons;
                 insert (bouton);
                 r.assign (1, 11, 12, 12);
                 insert (new (plabel, init (r, 'Paper ~t~ype', bouton)));
                 r.assign (3, 16, 12, 18);
                 bouton := new (pradiobuttons, init (r,
                        newsitem ('On',
                        newsitem ('Off',
                        nil))
                 ));
                 bouton^.helpctx := hc_radio_buttons;
                 insert (bouton);
                 r.assign (1, 15, 21, 16);
                 insert (new (plabel, init (r, 'Continue n~u~meration', bouton)));
                 r.assign (size.x-20, size.y-3, size.x-14, size.y-1);
                 insert (new (pbutton, init (r, '~O~K', cmOk, bfdefault)));
                 r.assign (size.x-13, size.y-3, size.x-3, size.y-1);
                 insert (new (pbutton, init (r, '~C~ancel', cmcancel, bfnormal)));
            end;
       {endwith}
       with boite_data do
            begin
                 champ_1 := haut_pg;
                 champ_2 := nb_lig_pg;
                 champ_3 := nb_col_lig;
                 champ_4 := num_pg;
                 champ_5 := nb_impri;
                 case pap_typ of
                      feuille : bouton_1 := 0;
                      continu : bouton_1 := 1;
                 end;
                 case pg_cont of
                      true : bouton_2 := 0;
                      false : bouton_2 := 1;
                 end;
            end;
       {endwith}
       if (validview (boite) <> nil)
       then
           begin
                boite^.setdata (boite_data);
                if (desktop^.execview (boite) <> cmcancel)
                then
                    begin
                         boite^.getdata (boite_data);
                         with boite_data do
                              begin
                                   haut_pg := champ_1;
                                   nb_lig_pg := champ_2;
                                   if (nb_lig_pg > haut_pg-6)
                                   then
                                       nb_lig_pg := haut_pg - 6;
                                   {endif}
                                   nb_col_lig := champ_3;
                                   num_pg := champ_4;
                                   nb_impri := champ_5;
                                   case bouton_1 of
                                        0 : pap_typ := feuille;
                                        1 : pap_typ := continu;
                                   end;
                                   pg_cont := (bouton_2 = 0);
                              end;
                         {endwith}
                    end;
                {endif}
                dispose (boite);
           end;
       {endif}
  end; { param_printer }

  procedure param_messages;
  type
      t_boite = record
                      ch_top : t_string80;
                      ch_bottom : t_string80;
      end;
  var
     boite : pdialog;
     boite_data : t_boite;
     ligne : pinputline;
     r : trect;
  begin           
       with boite_data do
            begin
                 ch_top := ms_up_pg;
                 ch_bottom := ms_dn_pg;
            end;
       {endif}
       r.assign (9, 6, 71, 16);
       boite := new (pdialog, init (r, 'Top and bottom messages'));
       with boite^ do
            begin
                 options := options or ofcentered;
                 helpctx := hc_param_msg;
                 r.assign (2, 2, size.x-2, 3);
                 ligne := new (pinputline, init (r, 80));
                 ligne^.helpctx := hc_input_line;
                 insert (ligne);
                 r.assign (2, 1, size.x-2, 2);
                 insert (new (plabel, init (r, '~T~op message:', ligne)));
                 r.assign (2, 5, size.x-2, 6);
                 ligne := new (pinputline, init (r, 80));
                 ligne^.helpctx := hc_input_line;
                 insert (ligne);
                 r.assign (2, 4, size.x-2, 5);
                 insert (new (plabel, init (r, '~B~ottom message:', ligne)));
                 r.assign (size.x-20, size.y-3, size.x-14, size.y-1);
                 insert (new (pbutton, init (r, '~O~K', cmOk, bfdefault)));
                 r.assign (size.x-13, size.y-3, size.x-3, size.y-1);
                 insert (new (pbutton, init (r, '~C~ancel', cmcancel, bfnormal)));
            end;
       {endwith}
       if (validview (boite) <> nil)
       then
           begin
                boite^.setdata (boite_data);
                if (desktop^.execview (boite) <> cmcancel)
                then
                    begin
                         boite^.getdata (boite_data);
                         ms_up_pg := boite_data.ch_top;
                         ms_dn_pg := boite_data.ch_bottom;
                    end;
                {endif}
                dispose (boite, done);
           end;
       {endif}  
  end; { param_messages }

  procedure param_others;
  type
      t_boite = record
                      check : word;
                      extension : string;
      end;
  var
     boite : pdialog;
     opt : pcheckboxes;
     ligne : pinputline;
     r : trect;
     boite_data : t_boite;
  begin
       with boite_data do
            begin
                 check := 0;
                 if (car_eol)
                 then
                     check := check or 1
                 else
                     if (imp_nu_lig)
                     then
                         check := check or 2;
                     {endif}
                 {endif}
                 extension := ext_def;
            end;
       {endif}
       R.assign (20, 6, 60, 18);
       boite := new (pdialog, init (r, 'Other parameters'));
       with boite^ do
            begin
                 helpctx := hc_param_others;
                 options := options or ofcentered;
                 r.assign (3, 2, size.x-3, 4);
                 opt := new (pcheckboxes, init (r,
                     newsitem ('Print end of line character',
                     newsitem ('Print line number',
                     nil))
                 ));
                 opt^.helpctx := hc_check_boxes;
                 insert (opt);
                 r.assign (2, 1, size.x-3, 2);
                 insert (new (plabel, init (r, 'O~p~tions:', opt)));
                 r.assign (29, 5, 34, 6);
                 ligne := new (pinputline, init (r, 3));
                 ligne^.helpctx := hc_input_line;
                 insert (ligne);
                 r.assign (2, 5, 28, 6);
                 insert (new (plabel, init (r, '~D~efault file extension', ligne)));
                 r.assign (size.x-20, size.y-3, size.x-14, size.y-1);
                 insert (new (pbutton, init (r, '~O~K', cmOk, bfdefault)));
                 r.assign (size.x-13, size.y-3, size.x-3, size.y-1);
                 insert (new (pbutton, init (r, '~C~ancel', cmcancel, bfnormal)));
            end;
       {endwith}
       if (validview (boite) <> nil)
       then
           begin
                boite^.setdata (boite_data);
                if (desktop^.execview (boite) <> cmcancel)
                then
                    begin
                         boite^.getdata (boite_data);
                         car_eol := (boite_data.check and 1 <> 0);
                         imp_nu_lig := (boite_data.check and 2 <> 0);
                         ext_def := boite_data.extension;
                    end;
                {endif}
                dispose (boite, done);
           end;
       {endif}
  end; { param_others }

  procedure save_options;
  begin
       if (cmyes = messagebox ('Do you want to save Listeur configuration ?',nil,mfconfirmation+mfyesbutton+mfnobutton))
       then
           if not options_save_opt
           then
               messagebox ('Writing error. I cannot make the config file.', nil, mferror + mfcancelbutton);
           {endif}
       {endif}
  end; { Save_Options }

  procedure load_options;
  begin
       if (cmyes = messagebox ('Do you want to retrieve Listeur configuration ?',nil,mfconfirmation+mfyesbutton+mfnobutton))
       then
           if not options_load_opt
           then
               messagebox ('Reading error. I cannot retrieve the config file.', nil, mferror + mfcancelbutton);
           {endif}
       {endif}
  end; { Load_Options }

  procedure default_options;
  begin
       if (cmyes = messagebox ('Do you want to use the default configuration ?',nil,mfconfirmation+mfyesbutton+mfnobutton))
       then
           init_variables;
       {endif}
  end; { Default_Options }

begin
     TApplication.HandleEvent (Event);
     case Event.What of
          evCommand: begin
                          case Event.Command of
                               cmChangeDir : Change_Dir;
                               cmChangeTime : Change_Time;
                               cmChangeDate : Change_Date;
                               cmdefault_opt : default_options;
                               cmDosShell : Dos_Shell;
                               cmEraseList : Erase_List;
                               cmExit : endmodal (cmQuit);
                               cmLoad_opt : load_options;
                               cmMessages : Param_Messages;
                               cmOthers : Param_Others;
                               cmPrint : Print_List;
                               cmPrinter : Param_Printer;
                               cmSave_Opt : save_options;
                               cmSelect : Selector;
                          else
                              exit;
                          end;
                          ClearEvent (Event);
          end;
     end;
end; { T_Listeur_App.HandleEvent }
{
*****************************************************************************
}
procedure T_Listeur_App.GetEvent (var Event: TEvent);
var
   W        : PWindow;
   HFile    : PHelpFile;
   HelpStrm : PDosStream;

const
     HelpInUse : Boolean = False;

begin
     TApplication.GetEvent (Event);
     case Event.What of
          evCommand : if (Event.Command = cmHelp) and not HelpInUse
                      then
                          begin
                               HelpInUse := True;
                               HelpStrm := New (PDosStream, Init (Get_File_Name (c_help_name), stOpenRead));
                               HFile := New (PHelpFile, Init (HelpStrm));
                               if (HelpStrm^.Status <> stOk)
                               then
                                   MessageBox ('Ouverture de fichier d''aide impossible.', nil, mfError + mfOkButton)
                               else
                                   begin
                                        W := New (PHelpWindow, Init (HFile, GetHelpCtx));
                                        if ValidView (W) <> nil
                                        then
                                            begin
                                                 ExecView (W);
                                                 Dispose (W, Done);
                                            end;
                                        {endif}
                                   end;
                               {endif}
                               ClearEvent (Event);
                               HelpInUse := False;
                          end;
                      {endif}
          evMouseDown : if Event.Buttons <> 1
                        then
                            Event.What := evNothing;
                        {endif}
     end;
end; { T_Listeur_App.GetEvent }
{
*****************************************************************************
}
procedure T_Listeur_app.OutOfMemory;
begin
     MessageBox('M‚moire insuffisante pour achever l''op‚ration.', nil, mfError + mfOkButton);
end; { T_Listeur_App.OutOfMemory }
{
*****************************************************************************
}
var
   listeur_app : t_listeur_app;
   path_depart : pathstr;
{
*****************************************************************************
}
begin
     getdir (0, path_depart);
{$ifdef demo_vers}
     init_olf_message (mess_demo);
     init_licence ('DEMOLIS2');
{$else}
     init_olf_message (mess_shareware);
     init_licence ('LIS2');
{$endif}
     init_olf_software ('Listeur '+c_num_vers, '(c) Premartin Patrick '+c_dat_vers);
     liste_init;
     listeur_app.init;
     listeur_app.run;
     listeur_app.done;
     liste_effacer;
     writeln ('Thanks for using Listeur ', c_num_vers);
     chdir (path_depart);
end. { Listeur2 }
