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
