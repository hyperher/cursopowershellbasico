#Buscar usuarios inactivos
Search-ADAccount -UsersOnly -AccountInactive -TimeSpan (New-TimeSpan -Days 60)
