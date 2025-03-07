<h3>Setup MS SQL Server Command-line Tools</h3>

* **RHEL9**
```
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/mssql-release.repo
sudo dnf remove mssql-tools unixODBC-utf16 unixODBC-utf16-devel   ## remove any prev version
sudo dnf install -y mssql-tools18 unixODBC-devel
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

* **Ubuntu**
```
# Import public repo GPG keys
OSVER=`cat /etc/os-release | grep VERSION_ID | awk -F\" '{print $1}'`
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/${OSVER}/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt update
sudo apt install mssql-tools18 unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```


* **sqlcmd usage**

```
sqlcmd 
-S DBSERVER  or  -S  DBSERVER\DBINSTANCE
-d DBNAME 
-U USERNAME 
-P PASSWORD
-C                      # trust server certificate [*]
-i sqlscript.sql 
-o output.csv 
-W                      # remove trailing spaces
-s ","                  # set column seperator to ","
-h-1                    # remove column name headers from the result
-w 999                  # set the row width to 999 chars
-?                      # show syntax help summary
```

_Note: In case of "," in a column, use QUOTENAME(ColumnName, '"') in SQL script to wrap the output with double quote._

----------------------------------------------------

<h3>Scripts For Information Retrieving</h3>

**Bash Script `query_aria.sh` Works as Below:**

1. Set environment variables including DB server, instances, DB, user, and GPG encrypted pass.

0. Performs DB Queries
    * TreatmentDeliveredLast7Days.sql
    * TreatmentScheduledNext7Days.sql
    * CTSimLast15Days.sql
