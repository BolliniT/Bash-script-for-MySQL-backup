# Bash-script-for-MySQL-backup
Bash based mysqldump script who backup all databases to a .tar file.
Use standard Linux commands, get the list of databases, then use mysqldump to save indipendently. 
Finally use tar to archive them in a single filename.
I use this along with software that performs versioning on the file name (aka TSM/IBM Spectrum Protect)
