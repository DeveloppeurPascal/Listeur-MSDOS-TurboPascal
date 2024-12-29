unit list_cmd;
{
Logiciel : LISTEUR.
Auteur : Pr‚martin Patrick.
Dates de modification : (2.0) 19/06/1991.
                              22/06/1991.
                              06/07/1991.
                              23/07/1991.
                              01/08/1991.
                              02/08/1991.
                        (2.1) 13/08/1991.
Langage: Turbo Pascal 6.0

**********************************************************************
          COMMANDES DE L'INTERFACE TURBO VISION
**********************************************************************
}

interface

const
     { Menu 'ð' : de 1000 … 1099 }
      cmHelp = 1000;

     { Menu 'File List' : de 1100 … 1199 }
      cmSelect = 1100;
      cmEraseList = 1101;
      cmChangeDir = 1102;
      hlChangeDir = cmChangeDir;
      cmDosShell = 1103;
      cmExit = 1104;

     { Menu 'Print List' : de 1200 … 1299 }
      cmPrint = 1200;

     { Menu 'Options' : de 1300 … 1399 }
      cmChangeDate = 1300;
      cmChangeTime = 1301;
      cmPrinter = 1302;
      cmMessages = 1303;
      cmOthers = 1304;
      cmSave_opt = 1305;
      cmLoad_opt = 1306;
      cmdefault_opt = 1307;

implementation

end. { Fin de l'unit‚ 'List_Cmd'. }
