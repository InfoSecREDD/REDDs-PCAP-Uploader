@ECHO OFF
REM Credits: REDD
REM TARGET OS: Windows 10+

SETLOCAL ENABLEDELAYEDEXPANSION

REM SET YOUR EMAIL BELOW OR SET IT IN THE SCRIPT!

SET "EMAIL="




GOTO MENU
:VARIABLES
SET "DIR=%~dp0"
SET "SENT_DIR=%DIR%\sent"
IF NOT EXIST "%SENT_DIR%" mkdir %SENT_DIR%
SET "EMAIL_FILE=email.txt"
:CHECK_EMAIL_FILE
IF EXIST "%EMAIL_FILE%" (
	SET /P EMAIL=<email.txt
	GOTO CHECK_EMAIL
)
:FORCE_SET_EMAIL
SET /P "EMAIL=Enter the Email you want to use for Results: "
echo %EMAIL% > %EMAIL_FILE%
GOTO CHECK_EMAIL
:SET_EMAIL
IF NOT EXIST "%EMAIL_FILE%" (
	SET /P "EMAIL=Enter the Email you want to use for Results: "
	echo !EMAIL! > !EMAIL_FILE!
	GOTO CHECK_EMAIL
)
:CHECK_EMAIL
SET P_FILES=0
FOR %%x in (*.pcap) do SET /a P_FILES+=1
Call :CHECK_VALID_EMAIL %EMAIL%
:SEND
ECHO Email: %EMAIL% (email.txt)
ECHO.
IF "%ERRORLEVEL%" EQU "0" ( 
	IF "%P_FILES%" == "0" (
		ECHO NO PCAP FILES FOUND^^!
	) ELSE (
		FOR %%i in (*.pcap) do ( 
			echo EMAIL: %EMAIL%
			echo FILE: %%i
			CURL -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
			MOVE /Y "%%i" "%SENT_DIR%\%%~ni.pcap"
		)
	)
) ELSE (
    ECHO %EMAIL% is NOT a Valid Email^^! Please try another Email.
	GOTO FORCE_SET_EMAIL
)
ECHO.
ECHO.
ECHO DONE^^!^^!
PAUSE & EXIT
:CHECK_VALID_EMAIL <EMAIL>
(
echo If IsValidEmail("%~1"^) = True Then
echo    Wscript.Quit(0^)
echo Else
echo    Wscript.Quit(1^)
echo End If
echo Function IsValidEmail(strEAddress^)
echo    Dim objRegExpr
echo    Set objRegExpr = New RegExp
echo    objRegExpr.Pattern = "^[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]@[\w-\.]*[a-zA-Z0-9]\.[a-zA-Z]{2,7}$"
echo    objRegExpr.Global = True
echo    objRegExpr.IgnoreCase = False
echo    IsValidEmail = objRegExpr.Test(strEAddress^)
echo    Set objRegExpr = Nothing
echo End Function
)>"%tmp%\%~n0.vbs"
CSCRIPT /nologo "%tmp%\%~n0.vbs"
EXIT /b
:MENU
ECHO.
ECHO.
ECHO   :::::::::  :::::::::: :::::::::  :::::::::  ::: ::::::::  
ECHO   :+:    :+: :+:        :+:    :+: :+:    :+: :+ :+:    :+: 
ECHO   +:+    +:+ +:+        +:+    +:+ +:+    +:+    +:+        
ECHO   +#++:++#:  +#++:++#   +#+    +:+ +#+    +:+    +#++:++#++ 
ECHO   +#+    +#+ +#+        +#+    +#+ +#+    +#+           +#+ 
ECHO   #+#    #+# #+#        #+#    #+# #+#    #+#    #+#    #+# 
ECHO   ###    ### ########## #########  #########      ########      
ECHO                REDD's PCAP OHC UPLOADER
ECHO                    ( Version 1.1 )
ECHO.
ECHO.
ECHO.
GOTO VARIABLES
