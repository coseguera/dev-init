#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

save_cloud_init() {
    local username="$1"
    local ssh_public_key_path="$2"
    local scripts_dir_path="$3"
    local source_cloud_init="$4"
    local target_cloud_init="$5"
    echo "copying $source_cloud_init to $target_cloud_init to replace values"
    cp $source_cloud_init $target_cloud_init

    echo "replacing values in file"

    sed -i '' "s/{{user}}/$username/g" $target_cloud_init

    SSHPUBKEY=$(<$ssh_public_key_path)
    sed -i '' "s|{{sshPublicKey}}|$SSHPUBKEY|g" $target_cloud_init

    FILES="$scripts_dir_path/*"
    for f in $FILES; do
        echo "replacing $f file if found in cloud-init..."
        FILENAME=$(basename $f)
        BASE64CONTENT=$(base64 $f)
        sed -i '' "s|{{$FILENAME}}|$BASE64CONTENT|g" $target_cloud_init
    done
}

save_arm_template() {
    local source_template_path="$1"
    local cloud_init_path="$2"
    local target_path="$3"
    
    local target_template_path="$target_path/$(basename $source_template_path)"

    echo "copying $source_template_path to $target_template_path to replace values"
    cp $source_template_path $target_template_path

    echo "placing the cloud init content in the target ARM template."
    awk 1 ORS='\\n' $cloud_init_path >$target_path/ONELINECLOUDINIT
    awk 'NR==FNR{rep=(NR>1?rep RS:"") $0; next} {gsub(/cloud-init-content/,rep)}1' $target_path/ONELINECLOUDINIT $target_template_path >$target_path/TMP
    mv $target_path/TMP $target_template_path
    rm $target_path/ONELINECLOUDINIT
}

while getopts u:k:f: flag; do
    case "${flag}" in
    u) username=${OPTARG} ;;
    k) sshPublicKeyPath=${OPTARG} ;;
    f) sourceCloudInit=${OPTARG} ;;
    esac
done
echo "Username: $username"
echo "SSH Key path: $sshPublicKeyPath"
echo "Source cloud-init: $sourceCloudInit"

BASEDIR=$(dirname "$0")
OUTDIR=$BASEDIR/out
CLOUDINIT=$OUTDIR/cloud-init.config
ARMTEMPLATE=$BASEDIR/templates/vm.template.json

mkdir -p $OUTDIR

save_cloud_init $username $sshPublicKeyPath $BASEDIR/scripts/ $sourceCloudInit $CLOUDINIT
save_arm_template $ARMTEMPLATE $CLOUDINIT $OUTDIR

echo "done!"
