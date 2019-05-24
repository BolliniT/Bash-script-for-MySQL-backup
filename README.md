# Bash-script-for-MySQL-backup-to-versioning-backup-server
Bash-based mysqldump script who backup all databases to a .tar file.
Use standard Linux commands, gets the list of databases (can skip in a blacklisted file..) save them indipendently. 
Finally use tar to archive them in a single filename.
I use this along with software that performs versioning on the file name like TSM/IBM Spectrum Protect
