@ECHO OFF
REM Credits: REDD
REM TARGET OS: Windows 10+
REM Version: 2.1 - Unified Windows Version

SETLOCAL ENABLEDELAYEDEXPANSION

REM SET YOUR EMAIL BELOW OR SET IT IN THE SCRIPT!

SET "EMAIL="

REM CONFIGURATION OPTIONS
SET "RECURSIVE_MODE=false"
SET "VERIFY_PCAP=false"
SET "SHOW_PROGRESS=true"

REM Parse command line arguments
SET "SHOW_HELP=false"
SET "ARGS_PROCESSED=false"

IF "%~1"=="" GOTO ARGS_DONE

:PARSE_ARGS
IF "%~1"=="" GOTO ARGS_DONE
IF /I "%~1"=="-r" SET "RECURSIVE_MODE=true" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="--recursive" SET "RECURSIVE_MODE=true" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="-v" SET "VERIFY_PCAP=true" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="--verify" SET "VERIFY_PCAP=true" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="-n" SET "VERIFY_PCAP=false" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="--no-verify" SET "VERIFY_PCAP=false" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="-s" SET "SHOW_PROGRESS=false" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="--silent" SET "SHOW_PROGRESS=false" & SHIFT & GOTO PARSE_ARGS
IF /I "%~1"=="-e" (
    IF NOT "%~2"=="" (
        SET "EMAIL=%~2"
        SHIFT
        SHIFT
        GOTO PARSE_ARGS
    )
)
IF /I "%~1"=="-h" SET "SHOW_HELP=true" & SHIFT & GOTO ARGS_DONE
IF /I "%~1"=="--help" SET "SHOW_HELP=true" & SHIFT & GOTO ARGS_DONE
SHIFT
GOTO PARSE_ARGS

:ARGS_DONE
SET "ARGS_PROCESSED=true"

IF "%SHOW_HELP%"=="true" GOTO SHOW_HELP
GOTO MENU

:SHOW_HELP
ECHO Usage: %~nx0 [OPTIONS]
ECHO.
ECHO Options:
ECHO   -h, --help         Show this help message
ECHO   -r, --recursive    Search for PCAP files in subdirectories
ECHO   -v, --verify       Verify files are valid PCAP files before upload
ECHO   -n, --no-verify    Skip PCAP file verification (default behavior)
ECHO   -s, --silent       Hide progress indicators
ECHO   -e EMAIL           Specify email address for results
ECHO.
ECHO Example: %~nx0 -r -e your@email.com
EXIT /B 0

:VARIABLES
SET "DIR=%~dp0"
PUSHD "%DIR%"
cd /D "%DIR%"
SET "SENT_DIR=%DIR%\sent"
IF NOT EXIST "%SENT_DIR%" mkdir %SENT_DIR%
SET "EMAIL_FILE=email.txt"
SET "LOG_FILE=%DIR%\upload_history.log"
GOTO CHECK_EMAIL_FILE

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
)>"%~n0.vbs"
CSCRIPT /nologo "%~n0.vbs"
EXIT /b

:CHECK_VALID_PCAP <FILEPATH>
SET "IS_VALID_PCAP=0"
SET "FILE_PATH=%~1"

REM Check file extension
IF /I "%~x1"==".pcap" SET "IS_VALID_PCAP=1"
IF /I "%~x1"==".pcapng" SET "IS_VALID_PCAP=1"

REM If we have the file command, we could add more sophisticated checks here
REM For now, we'll just trust the extension

ECHO %IS_VALID_PCAP%
EXIT /B

:CHECK_EMAIL_FILE
IF EXIST "%EMAIL_FILE%" (
    SET /P EMAIL=<email.txt
    GOTO CHECK_EMAIL
)

:FORCE_SET_EMAIL
SET /P "EMAIL=Enter the Email you want to use for Results: "
echo %EMAIL%> %EMAIL_FILE%
GOTO CHECK_EMAIL

:SET_EMAIL
IF NOT EXIST "%EMAIL_FILE%" (
    SET /P "EMAIL=Enter the Email you want to use for Results: "
    echo !EMAIL!> !EMAIL_FILE!
    GOTO CHECK_EMAIL
)

:CHECK_EMAIL
SET P_FILES=0
cd /D "%DIR%"

REM Find PCAP files based on recursive mode
IF "%RECURSIVE_MODE%"=="true" (
    ECHO Searching for PCAP files in %DIR% and subdirectories...
    FOR /R "%DIR%" %%a in (*.pcap) DO SET /a P_FILES+=1
) ELSE (
    FOR %%a in ("%DIR%*.pcap") DO SET /a P_FILES+=1
)

SET EMAIL_PASS=0
CALL :CHECK_VALID_EMAIL "%EMAIL%"
IF "%ERRORLEVEL%" EQU "0" SET EMAIL_PASS=1

:SEND
ECHO Email: %EMAIL%
ECHO.
IF "%EMAIL_PASS%" NEQ "0" ( 
    IF "%P_FILES%" == "0" (
        ECHO NO PCAP FILES FOUND^^!
    ) ELSE (
        ECHO Found %P_FILES% PCAP files to process.
        
        REM Process files based on recursive mode
        IF "%RECURSIVE_MODE%"=="true" (
            FOR /R "%DIR%" %%i in (*.pcap) DO (
                ECHO Processing: %%i
                
                IF "%VERIFY_PCAP%"=="true" (
                    CALL :CHECK_VALID_PCAP "%%i"
                    IF "!ERRORLEVEL!" NEQ "1" (
                        ECHO Warning: %%i does not appear to be a valid PCAP file. Skipping.
                        GOTO :SKIP_FILE
                    )
                )
                
                ECHO Uploading: %%i
                
                IF "%SHOW_PROGRESS%"=="true" (
                    CURL -# -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
                ) ELSE (
                    CURL -s -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
                )
                
                REM Create target directory structure
                SET "REL_PATH=%%~pi"
                SET "REL_PATH=!REL_PATH:%DIR%=!"
                IF NOT "!REL_PATH!"=="" (
                    IF NOT EXIST "%SENT_DIR%\!REL_PATH!" MKDIR "%SENT_DIR%\!REL_PATH!"
                    MOVE /Y "%%i" "%SENT_DIR%\!REL_PATH!%%~nxi" >NUL
                ) ELSE (
                    MOVE /Y "%%i" "%SENT_DIR%\%%~nxi" >NUL
                )
                
                REM Log the upload
                ECHO %DATE% %TIME% - Uploaded: %%i - Email: %EMAIL% >> "%LOG_FILE%"
                
                ECHO Done processing: %%i
                ECHO ---------------------------------
                
                :SKIP_FILE
            )
        ) ELSE (
            FOR %%i in ("%DIR%*.pcap") DO (
                ECHO Processing: %%i
                
                IF "%VERIFY_PCAP%"=="true" (
                    CALL :CHECK_VALID_PCAP "%%i"
                    IF "!ERRORLEVEL!" NEQ "1" (
                        ECHO Warning: %%i does not appear to be a valid PCAP file. Skipping.
                        GOTO :SKIP_FILE2
                    )
                )
                
                ECHO Uploading: %%i
                
                IF "%SHOW_PROGRESS%"=="true" (
                    CURL -# -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
                ) ELSE (
                    CURL -s -X POST -F "email=%EMAIL%" -F "file=@%%i" https://api.onlinehashcrack.com
                )
                
                MOVE /Y "%%i" "%SENT_DIR%\%%~ni.pcap" >NUL
                
                REM Log the upload
                ECHO %DATE% %TIME% - Uploaded: %%i - Email: %EMAIL% >> "%LOG_FILE%"
                
                ECHO Done processing: %%i
                ECHO ---------------------------------
                
                :SKIP_FILE2
            )
        )
        ECHO All PCAP files have been processed.
    )
) ELSE (
    ECHO %EMAIL% is NOT a Valid Email^^! Please try another Email.
    GOTO FORCE_SET_EMAIL
)
ECHO.
ECHO.
ECHO DONE^^!^^!
DEL /F "%~n0.vbs" >NUL
PAUSE & EXIT

:MENU
CLS
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
ECHO                 ( Version 2.1 - WIN  )
ECHO.
IF "%RECURSIVE_MODE%"=="true" ECHO RECURSIVE MODE: ENABLED
IF "%VERIFY_PCAP%"=="true" ECHO PCAP VERIFICATION: ENABLED
ECHO.
ECHO.
GOTO VARIABLES
