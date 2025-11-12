$var = [int](read-host -prompt "¿Cual es el primer número?")
 
While ($var -le 10){
 
If (($var % 2) -ne 0) {"$var es impar} else {"$var es par"}
 
$var++
}
