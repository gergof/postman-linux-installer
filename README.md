# postman-linux-installer
Bash script to install and update postman on linux systems

### Usage

```
postman-install.sh [-l] [-g] [version]
  version: The version to install (ex: 10.24.3) or latest. Defaults to latest
  -l: Force local installation in the user HOME directory
  -g: Force global installation
  -u: Uninstall postman
```

The script defaults to global installation if running as root, and local installation otherwise.

### Example

Local installation with default latest version:

```bash
./postman-install.sh
```

Global installation with specific version:

```bash
sudo ./postman-install.sh 10.24.3
```

Forcing local installation even when running as root:

```bash
sudo ./postman-install.sh -l
```

### Installing the installer script

You can execute this script without installation:

```bash
bash <(curl -s https://raw.githubusercontent.com/gergof/postman-linux-installer/master/postman-install.sh)
```

To install the script:

```bash
curl -s https://raw.githubusercontent.com/gergof/postman-linux-installer/master/postman-install.sh -o postman-install.sh
chmod +x postman-install.sh
sudo mv postman-install.sh /usr/local/bin
```

### Uninstalling postman

You can uninstall postman by running the installer script with the `-u` flag:

```bash
sudo postman-install.sh -u
```
