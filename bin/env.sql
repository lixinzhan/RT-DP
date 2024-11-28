# Environment variables for sQL queries
#

source ./env.common

#
# DB query required information
#
AUTHFILE="${RTDRPATH}/Keys/script-auth.txt.gpg"
DBSYSTEM=ARIA
DBSVR=dc3-pr-aria
DBINS=MSSQLSERVER
DBUSR=$(gpg -q -d ${AUTHFILE} | grep ${DBSYSTEM} | awk '{print $2}')
DBPWD=$(gpg -q -d ${AUTHFILE} | grep ${DBSYSTEM} | awk '{print $3}')
DB=VARIAN
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

###############################################
# function to run SQL scripts
###############################################

function sql_exec {
	# $1 - sql script
	local scriptfile=$1
	local outputfile=$(basename $1)
	mkdir -p ${SQLOUTPATH}
	local outputfile="${SQLOUTPATH}/${outputfile%.*}.csv"

	echo
	#echo $scriptfile
	#echo $outputfile
	echo "Querying with script: $1 ..."
        $SQLCMD -S $DBSVR -d $DB -U $DBUSR -P $DBPWD -C -i $scriptfile -o $outputfile -W -s ","
	if grep -q "Sqlcmd: Error:" $outputfile; then
		echo "Sqlcmd Error!!"
	else
		echo "Results saved in $outputfile"
	fi
	echo "Done with query $1"
	sleep 3
}

