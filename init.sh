#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

while getopts u:k:f: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        k) sshPublicKeyPath=${OPTARG};;
        f) sourceCloudInit=${OPTARG};;
    esac
done
echo "Username: $username"
echo "SSH Key path: $sshPublicKeyPath"
echo "Source cloud-init: $sourceCloudInit"

BASEDIR=$(dirname "$0")
OUTDIR=$BASEDIR/out
CLOUDINIT=$OUTDIR/cloud-init.config

mkdir -p $OUTDIR

echo "copying cloud-init.yaml to $CLOUDINIT to replace values"
cp $sourceCloudInit $CLOUDINIT

echo "replacing values in cloud-init.config"

sed -i '' "s/{{user}}/$username/g" $CLOUDINIT

SSHPUBKEY=$(<$sshPublicKeyPath)
sed -i '' "s|{{sshPublicKey}}|$SSHPUBKEY|g" $CLOUDINIT

FILES="$BASEDIR/scripts/*"
for f in $FILES
do
    echo "replacing $f file if found in cloud-init..."
    FILENAME=$(basename $f)
    BASE64CONTENT=$(base64 $f)
    sed -i '' "s|{{$FILENAME}}|$BASE64CONTENT|g" $CLOUDINIT
done

echo "done!"