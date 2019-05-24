#!/bin/sh
export LANG=en_US
export LC_ALL=en_US
export LC_CTYPE=en_US
export DSM_DIR=/opt/tivoli/tsm/client/ba/bin
export PATH=$PATH:$DSM_DIR
export LD_LIBRARY_PATH=$PATH
export DSM_CONFIG=$DSM_DIR/dsm.opt
########### ERROR CODES ##############
## 143 - Unable to connect to MySQL ##
## 144 - dump error                 ##
## 146 - Error in sending to TSM    ##
######################################
DBS=$DSM_DIR/databases.txt
BLIST=$DSM_DIR/blacklisted.txt
LOGFILE=$DSM_DIR/bck-mysql.log
TBLBLACK="--exclude-tables=horde_sessionhandler"
EMAIL=your_email@corporate.org
ACC="-u root --password=yourpassword"
DESCR="Archive of (aaaa-mm-gg) $(date +%F)"
HST=$(gethostip `uname -n`)
OPT="--opt --compress" ## --skip-insecure-warning" ## --secure-auth"
DDIR=$DSM_DIR/backup-mysql
DDIR2=$DDIR/dumps
echo "---- Start Backups `date +%c`" > $LOGFILE
cd $DSM_DIR 1>/dev/null
if mysql -e 'show databases' $ACC >/dev/null 2>>$LOGFILE; then
  mysql -e 'show databases' $ACC | cut -d"|" -f1 > $DBS
  mkdir -p $DDIR
  mkdir -p $DDIR1
  mkdir -p $DDIR2
  echo "---- Begin MySQL dumps ---- `date +%c`" >> $LOGFILE
  while read _db; do
   if ! ( grep -qw $_db $BLIST ); then
   echo -n "$_db: " >>$LOGFILE
   mysqldump $ACC $OPT --databases $_db | bzip2 - > $DDIR2/$_db.bz2 2>>$LOGFILE
    if [ "`echo ${PIPESTATUS[@]} | tr [\ ] [+] | bc`" -gt "0" ]; then
          EXITCD=144
          echo -n " ERROR on dumping" >>$LOGFILE
    else
          echo -n " dump OK ($(ls -xsk $DDIR2/$_db.bz2 | cut -d" " -f1)Kb)" >>$LOGFILE
    fi
   echo "" >>$LOGFILE
   fi
  done < $DBS
    echo "---- Finished MySQL dumps ---- `date +%c`" >> $LOGFILE
    tar -cf mysql.tar backup-mysql --remove-files 2>>$LOGFILE
    echo "---- Finished TAR file ---- `date +%c`" >> $LOGFILE
    ##### SEND TO SPECTRUM PROTECT - MGMTCLASS DISTINCTION btwn Incr/Arch(on Thursday) #####
    echo "---- Backup to TSM ---- `date +%c`" >> $LOGFILE
    if [ "$(date +%u)" -eq "4" ]; then
      ./dsmc arch -sub=yes -desc="$DESCR" ./mysql.tar 2>> $LOGFILE
      if ! [ "$?" -eq "0" ]; then EXITCD=146; fi
    else
      ./dsmc incr -sub=yes ./mysql.tar 2>> $LOGFILE
      if ! [ "$?" -eq "0" ]; then EXITCD=146; fi
    fi
    echo "---- Fine salvataggi `date +%c`" >> $LOGFILE
else  
   mail -s "Prob. connecting mysql $HST" $EMAIL < $LOGFILE
   exit 143
fi
  
if [ "$EXITCD" = "144" ]; then
  grep -vw "OK" $LOGFILE | mail -s "Prob. dump mysql $HST" $EMAIL
  exit 144
fi
if [ "$EXITCD" = "146" ]; then
  grep -vw "OK" $LOGFILE | mail -s "Prob. SendTo TSM on $HST" $EMAIL
  exit 145
fi
