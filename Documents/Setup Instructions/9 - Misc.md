* CSV Processing
    1. SQLite can be used for csv processing, e.g.

        ```
        sqlite3 :memory: -cmd '.import -csv taxi.csv taxi' \
        'SELECT passenger_count, COUNT(*), AVG(total_amount) FROM taxi GROUP BY passenger_count'
        ```

    2. [duckdb](https://github.com/duckdb/duckdb): an analytical query focused tool with some flexibility

        ```
        duckdb -c "SELECT * FROM 'data_source.csv.gz'"
        duckdb.query("select * from read_csv('test.csv', AUTO_DETECT=TRUE)")
        ```

    3. [csvkit](https://github.com/wireservice/csvkit): a suite of python based command-line tools.
 
* Extracting Column from CSV as string list

    ```
    awk -F, '$18 !~ /1/' output.csv | awk -F, '{printf("\"%s\", ",$2);}' | head -c -2
    ```
    
* JSON processing

  ```
  sudo apt install jq
  cat file.json | jq '.'    # display in json format
  cat file.json | jq '.key'    # returns all properties/values with 'key'
  ```

* Allow sudo execute a command, /usr/sbin/ip, without password

    ```
    # use command below to edit the /etc/sudoer.
    # remember to open another window with 'sudo -i' runnning first, in case a misconfiguration locking sudo out.
    sudo visudo
    ```

    Add the line below to /etc/sudoer

    ```
    username    ALL=(ALL) NOPASSWD:/usr/sbin/ip
    ```
    
