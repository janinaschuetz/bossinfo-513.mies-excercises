
$ForNAVDLL = ".\Translations\ForNav.Cmdlet.dll"
$TranslationEXCELFile = ".\Translations\Translation.xlsx"
$TranslationEXCELFileBAK = ".\Translations\TranslationBAK.xlsx"
$SourceENU = ".\Translations\Translation-en-US.xlf"
$BaseXLFFile = ".\Translations\Elfo AG.g.xlf"
$DirXLFFile  = ".\Translations\"
$DirXLFFileFilter =  $DirXLFFile + '*.xlf'

Import-Module $ForNAVDLL
$read = Read-Host "Excel überschreiben (J)"
if ($read -eq 'J')
{
  # Overwrite Excel from XLF Files
  Copy-Item -Path $TranslationEXCELFile  -Destination $TranslationEXCELFileBAK -Force
  Invoke-ExportTranslationFromXlfToExcel -FromXlf $DirXLFFileFilter -ToExcel $TranslationEXCELFile  
  . $TranslationEXCELFile 
}


# Genarate Translation Files from EXCEL
Invoke-ImportTranslationFromExcelToXlf -FromExcel $TranslationEXCELFile -FromXlf $BaseXLFFile -ToXlf $DirXLFFile

Copy-Item -Path $SourceENU -Destination $BaseXLFFile -Force