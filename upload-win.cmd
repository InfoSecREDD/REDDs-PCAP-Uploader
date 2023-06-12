@ECHO OFF
REM Credits: REDD
REM TARGET OS: Windows 10+

SETLOCAL ENABLEDELAYEDEXPANSION

REM SET YOUR EMAIL BELOW OR SET IT IN THE SCRIPT!

SET "EMAIL="




GOTO MENU
PUSHD "%DIR%"
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
cd /D "%DIR%"
for %%a in ("%DIR%*.pcap") do SET /a P_FILES+=1
SET EMAIL_PASS=0
Call :CHECK_VALID_EMAIL %EMAIL%
IF "%ERRORLEVEL%" EQU "0" SET EMAIL_PASS=1
:SEND
ECHO Email: %EMAIL%
ECHO.
IF "%EMAIL_PASS%" NEQ "0" ( 
	IF "%P_FILES%" == "0" (
		ECHO NO PCAP FILES FOUND^^!
	) ELSE (
		FOR %%i in ("%DIR%*.pcap") do ( 
			CURL -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
			MOVE /Y "%%i" "%SENT_DIR%\%%~ni.pcap" >NUL
		)
	)
) ELSE (
    ECHO %EMAIL% is NOT a Valid Email^^! Please try another Email.
	GOTO FORCE_SET_EMAIL
)
ECHO.
ECHO.
ECHO DONE^^!^^!
DEL /F "%DIR%%~n0.vbs" >NUL
PAUSE & EXIT
:CHECK_VALID_EMAIL <EMAIL>
(
ECHO If IsValidEmail("%~1"^) = True Then
ECHO    Wscript.Quit(0^)
ECHO Else
ECHO    Wscript.Quit(1^)
ECHO End If
ECHO Function IsValidEmail(strEAddress^)
ECHO    Dim objRegExpr
ECHO    Set objRegExpr = New RegExp
ECHO    objRegExpr.Pattern = "^[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]@[\w-\.]*[a-zA-Z0-9]\.[a-zA-Z]{2,7}$"
ECHO    objRegExpr.Global = True
ECHO    objRegExpr.IgnoreCase = False
ECHO    IsValidEmail = objRegExpr.Test(strEAddress^)
ECHO    Set objRegExpr = Nothing
ECHO End Function
)>"%DIR%%~n0.vbs"
attrib +s +h "%DIR%%~n0.vbs"
CSCRIPT /nologo "%DIR%%~n0.vbs"
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
ECHO                 ( Version 1.3 - WIN  )
ECHO.
ECHO.
ECHO.
GOTO VARIABLES
