cd C:/UDK/UDK-2012-05/UDKGame/Content/Arena
set /p msg=Enter a message to describe what you are committing:
git add .
git commit -m "%msg%"
git push origin master
pause