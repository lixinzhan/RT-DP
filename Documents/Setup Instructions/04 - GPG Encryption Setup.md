<h3>Setup GPG Encryption</h3>

* In account lzhan:
    ```
    # gpg --generate-key                  # use default configuration: lzhan@rtdp.vnet OR
    gpg --batch --passphrase '' --quick-gen-key "User Name <Email>" default default 1y  # without passphrase
    gpg --list-keys                     # list public keys
    gpg --list-secret-keys              # list private key pairs
    gpg --armor --export --output gpg-lzhan.pub lzhan@rtdp.vnet    # export public key
    scp gpg-lzhan.pub rtdp@localhost:~
    ```
* In account rtdp:
    ```
    # gpg --generate-key                  # use default configuration: rtdp@rtdp.vnet
    gpg --batch --passphrase '' --quick-gen-key "User Name <Email>" default default 1y  # without passphrase
    gpg --list-keys                     # list public keys
    gpg --list-secret-keys              # list private key pairs
    gpg --armor --export --output gpg-rtdp.pub rtdp@rtdp.vnet    # export public key
    scp gpg-rtdp.pub lzhan@localhost:~
    ```
* In account lzhan:
    ```
    gpg --import gpg-rtdp.pub
    gpg --encrypt --recipient rtdp@rtdp.vnet script-auth.txt      # encrypt for user
    scp script-auth.txt.gpg rtdp@localhost:~
    ```

* In account rtdp:
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
  
