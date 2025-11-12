#Aplicar política de contraseña específica (PSO)

New-ADFineGrainedPasswordPolicy -Name "PSO-Admins" -Precedence 1 -MinPasswordLength 12 -LockoutThreshold 3 -ComplexityEnabled $true
Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-Admins" -Subjects "Informática-Admins"
