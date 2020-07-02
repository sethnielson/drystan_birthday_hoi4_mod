
Name "DrystanBirthdayMod"

OutFile "DrystanBirthdayMod.exe"

;---- Variables ---

Var  Hoi4BaseDir 
Var  Hoi4ModDir

;---------------

Unicode true

RequestExecutionLevel user

InstallDir '$DOCUMENTS\Paradox Interactive\Hearts of Iron IV\mod\'

Page directory
Page instfiles

Section "" ;No components page, name is not important

  StrCpy $Hoi4BaseDir "$DOCUMENTS\Paradox Interactive\Hearts of Iron IV"
  StrCpy $Hoi4ModDir "$Hoi4BaseDir\mod"


;--- Check if HOI4 user dir is present. Cancel if not found ---
  IfFileExists $Hoi4BaseDir hoi4_exists hoi4_not_installed

;--- Hoi4 Exists. Check if Mod dir exists... if not, create it  
hoi4_exists:
  IfFileExists $Hoi4ModDir hoi4_moddir_exists hoi4_moddir_not_found
  
hoi4_moddir_not_found:
  CreateDirectory $Hoi4ModDir

;--- Mod dir exists. Now check installation path. Confirm overwrite if it exists  
hoi4_moddir_exists:
  IfFileExists $INSTDIR\drystan_birthday_hoi4_mod already_installed start_install
  
already_installed:
  MessageBox MB_YESNO "Mod destintaion path already exists. Overwrite?" IDYES overwrite IDNO cancel
overwrite:
  RMDir /r $INSTDIR\drystan_birthday_hoi4_mod


;--- We have hoi4, a mod dir, and a package. Now install the mod file into hoi4
start_install:

;--- Download from Github
  ExecWait 'powershell -Command "Invoke-WebRequest https://github.com/sethnielson/drystan_birthday_hoi4_mod/archive/master.zip -OutFile $PROFILE\Downloads\drystan_birthday_hoi4_mod.zip"'

;--- Unzip packgae  
  ExecWait 'powershell -Command "Expand-Archive $PROFILE\Downloads\drystan_birthday_hoi4_mod.zip -DestinationPath $INSTDIR"'

;--- Renmae to get rid of master  
  Rename $INSTDIR\drystan_birthday_hoi4_mod-master $INSTDIR\drystan_birthday_hoi4_mod

;--- Check if a drystan_birthday.mod file exists in HOI4 If so, confirm overwrite  
  IfFileExists $Hoi4ModDir\drystan_birthday.mod mod_file_already_installed mod_file_not_installed
  
mod_file_already_installed:
  MessageBox MB_YESNO "Drystan Birthday mod file already present. Overwrite?" IDYES delete_modfile IDNO cancel
  
delete_modfile:
  Delete $Hoi4ModDir\drystan_birthday.mod

;--- Mod file does not exist (or has been deleted)  
mod_file_not_installed:
  
  ; read the mod file and re-write path
  ClearErrors
  FileOpen $0 $INSTDIR\drystan_birthday_hoi4_mod\drystan_birthday.mod r
  IfErrors file_open_failed
  FileOpen $1 $Hoi4ModDir\drystan_birthday.mod w
  IfErrors file_open_failed
  
file_read_loop:
  FileRead $0 $2
;-- Unfortunately, the only way to know we're finished is errors
  IfErrors read_done
  
;--- copy enough bytes to see if the string starts with path
  StrCpy $3 $2 4 
  StrCmp $3 "path" path_write line_write
  
path_write:
  StrCpy $4 'path="$INSTDIR\drystan_birthday_hoi4_mod\drystan_birthday"'
  StrLen $5 $4
  IntOp $6 0 + 0
string_write_loop:
;-- If the index is the strlen, we're done
  IntCmp $6 $5 file_read_loop
;-- write one char from the path to $7 starting at off set  $6
  StrCpy $7 $4 1 $6
;-- Increase index by 1
  IntOp $6 $6 + 1
  StrCmp $7 "\" slash_write char_write
slash_write:
  FileWrite $1 "/"
  goto string_write_loop
char_write:
  FileWrite $1 $7 
  goto string_write_loop

line_write:
  FileWrite $1 $2
  goto file_read_loop
  
read_done:
  FileClose $0
  FileClose $1

  
complete:
  MessageBox MB_OK "Installation completed successfully"
  goto exit

hoi4_not_installed:
  MessageBox MB_OK "Hearts of Iron IV not found. Check installation."
  goto exit
  
file_open_failed:
  MessageBox MB_OK "File Open Failed. Installation Failed."
  goto exit
  
cancel:
  MessageBox MB_OK "Installation cancelled"
  goto exit
  
exit:
  
SectionEnd ; end the section