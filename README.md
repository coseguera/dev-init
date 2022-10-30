# dev-init
Create development virtual machines easily

## Usage

### To generate a cloud-init
```
./init.sh -u <username> -k <path-to-ssh-public-key> -f <path-to-cloud-init> -s <path-to-scripts-directory> -o <path-to-output-directory>
```

### To generate an ARM template with a cloud-init set
```
./init.sh -u <username> -k <path-to-ssh-public-key> -f <path-to-cloud-init> -t <path-to-arm-template> -s <path-to-scripts-directory> -o <path-to-output-directory>
```

For example:
```
./init.sh -u myuser -k ~/.ssh/id_rsa.pub -c cloud-init/empty/cloud-init.config -t templates/vm.template.json -s ./scripts -o ./out
```

### To deploy the Azure VM using the ARM template
Fill out these variables:
```
vmadmin=""
rg=""
location=""
pubkey=`cat ~/.ssh/id_rsa.pub`
template="vm.template.json"
ipaddr=`curl ifconfig.me`
```

Create the resource group and deploy the VM:
```
az group create -g $rg -l $location
az deployment group create -g $rg -n mydeploy -f ./out/$template --parameters vmNamePrefix=$rg vmAdmin=$vmadmin userPublicIp=$ipaddr vmSshPublicKey=$pubkey
```

### Connect to the Azure VM after deployment
Using SSH:
```
ssh myuser@myvmname.mylocation.cloudapp.azure.com
```

For example:
```
ssh myuser@myvmname.mylocation.cloudapp.azure.com
```