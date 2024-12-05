<h3>Setup GPG Encryption</h3>

* In account lzhan:
    ```
    # gpg --generate-key                  # use default configuration: lzhan@rtdrs.vnet OR
    gpg --batch --passphrase '' --quick-gen-key "User Name <Email>" default default 1y  # without passphrase
    gpg --list-keys                     # list public keys
    gpg --list-secret-keys              # list private key pairs
    gpg --armor --export --output gpg-lzhan.pub lzhan@rtdrs.vnet    # export public key
    scp gpg-lzhan.pub rtdrs@localhost:~
    ```
* In account rtdrs:
    ```
    # gpg --generate-key                  # use default configuration: rtdrs@rtdrs.vnet
    gpg --batch --passphrase '' --quick-gen-key "User Name <Email>" default default 1y  # without passphrase
    gpg --list-keys                     # list public keys
    gpg --list-secret-keys              # list private key pairs
    gpg --armor --export --output gpg-rtdrs.pub rtdrs@rtdrs.vnet    # export public key
    scp gpg-rtdrs.pub lzhan@localhost:~
    ```
* In account lzhan:
    ```
    gpg --import gpg-rtdrs.pub
    gpg --encrypt --recipient rtdrs@rtdrs.vnet script-auth.txt      # encrypt for user
    scp script-auth.txt.gpg rtdrs@localhost:~
    ```

* In account rtdrs:
    ```
    gpg --import gpg-lzhan.pub
    chmod 400 script-auth.txt.gpg
    gpg --quiet --decrypt --passphrase <PASSPHRASE> script-auth.txt.gpg    # or
    gpg -q -d --passphrase <PASSPHRASE> script-auth.txt.gpg
    gpg -q -d --passphrase <PASSPHRASE> script-auth.txt.gpg | grep ARIA | awk '{print $2}' # user
    gpg -q -d --passphrase <PASSPHRASE> script-auth.txt.gpg | grep ARIA | awk '{print $3}' # pass
    ```
* To delete keys:
  ```
  gpg --list-secret-keys
  gpg --delete-secret-key <SECKEY-UID>
  gpg --list-keys
  gpg --delete-key <PUBKEY_UID>
  ```

* Format of script-auth.txt:

  ```
  AURA:  user  pass
  ARIA:  user  pass
  GPG:  passphrase  pass
  ```
  
