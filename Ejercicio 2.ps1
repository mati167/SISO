<#
.Synopsis
    Este script busca errores en los logs de ejecución de los procesos batch e informa por mail al operador de turno
.DESCRIPTION
    Busca errores en los logs de ejecucion dentro del directior ingresado en [<path>] cada determinado tiempo ingresado en [<time>] sobre los archivos que fueron escritos luego de la ultima busqueda. de encontrarse errores se envian por mail al operador de turno segun los datos del archivo [<mailFile>]
    el cual debera tener un formato especifico:

    envia@ejemplo.com|smtp.ejemplo.com|password|port
    0000|1200     #horainicio|horafin 0000 = 00:00
    operario1@ejemplo.com
    1200|0000
    operario2@ejemplo.com

    se tiene en cuenta que hay un operario a cargo las 24 horas
    el timer se ingresa en milisegundos

.EXAMPLE
    "C:\Unlam\sistemas operativos\scripts\Ejercicio 2.ps1" -name ejercicio2 -ArgumentList 'c:\unlam\sistemas operativos',3000,'c:\unlam\sistemas operativos\mail.txt'
    ejemplo del error enviado 
    C:\Unlam\Sistemas Operativos\logs\4.log:1:2016-11-19 06:10:09-[ERROR |zxc]-{error2}
    archivo donde esta el error:linea:contenido de la linea
#>
    Param ( 
    [Parameter(Mandatory = $true, Position=1)]
    [string]$path,
    [Parameter(Mandatory = $true, Position=2)]
    [validatepattern ('[0-9]')]
    [int] $time,
    [Parameter(Mandatory = $true, Position=3)]
    [string] $mailFile)
    write-host $path
    $timer = New-Object Timers.timer
    $timer.Interval = $time
    $action = {$file = (Get-ChildItem -recurse -path $path -Filter "*.log" | where-object { $_.LastWriteTime -gt $(Get-Date).addMilliseconds(-$time) } | Select-String -pattern "ERROR") #|  group path | select name
    try{
    $email = Get-Content -path $mailFile -TotalCount 1
    $lista = @()
    $lista = $email.ToString().Split("|") | select -First 4
    [string]$SMTP = $lista[1]
    [string]$emailfrom = $lista[0]#Get-Content -Path $mailFile -delimiter " " -head 1
    $secpasswd =  ConvertTo-SecureString $lista[2] -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential($emailfrom, $secpasswd)
    [int]$PORT   = [System.decimal]::Parse($lista[3]) 
    [int]$cont = 1
    $esta = 0
    $fecha = (get-date)
    $datearray = @()
    $datearray =$fecha.ToShortTimeString().Split(":")
    $hora = [System.Decimal]::Parse($datearray[0])
    $hora = $hora*100
    $hora += [System.Decimal]::Parse($datearray[1])
    $test = (Get-Content -path $mailFile )[$cont]
    $lista = @()
    $lista = $test.ToString().Split("|") | select -First 2
    $inicio  = [System.Decimal]::Parse($lista[0])
    while ($esta -ne 1)
    {
        $test = (Get-Content -path $mailFile )[$cont]
        $lista = $test.ToString().Split("|") | select -First 2
        $horaFin = [System.Decimal]::Parse($lista[1])
        if ($hora -lt $horafin )
        {
         $esta = 1
        }
        elseif($cont -ne 1)
            {
            if($horaFin -eq $inicio)
                {
                    $esta=1
                    $test = (Get-Content -path $mailFile )[2]
                    $lista = $test.ToString().Split("|") | select -First 2
                }
            else
                { 
                    $cont = $cont+2
                }
            }
        else
            { 
                $cont = $cont+2
            }
    }
    $test = (Get-Content -path $mailFile )[$cont+1]
    [string]$emailto =  $test
     Send-MailMessage -to "$emailto" -from "$emailfrom" -Subject "ERROR" -Body "$file" -SmtpServer "$SMTP" -Credential $mycreds  -UseSsl -port $PORT
    Out-File -FilePath $path\error.log -InputObject "" 
    }
    catch{
    Out-File -FilePath $path\error.log -InputObject $file -Append -noclobber
    }
    }
    Register-ObjectEvent -InputObject $timer -EventName elapsed  –SourceIdentifier ejercicio2 -Action $action
    $timer.start()
#$mailFile = $mailFile   Unregister-Event ejercicio2 $timer.stop()
