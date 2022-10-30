#!/bin/bash

set -o errexit
set -o pipefail

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

save_cloud_init() {
    local username="$1"
    local ssh_public_key_path="$2"
    local source_cloud_init="$3"
    local scripts_dir_path="$4"
    local target_path="$5"

    local target_cloud_init="$target_path/$(basename $source_cloud_init)"

    echo "copying $source_cloud_init to $target_cloud_init to replace values"
    cp $source_cloud_init $target_cloud_init

    echo "Username: $username"
    echo "SSH Key path: $ssh_public_key_path"
    echo "Source cloud-init: $source_cloud_init"

    echo "replacing values in file"

    sed -i '' "s/{{user}}/$username/g" $target_cloud_init

    SSHPUBKEY=$(<$ssh_public_key_path)
    sed -i '' "s|{{sshPublicKey}}|$SSHPUBKEY|g" $target_cloud_init

    FILES="$scripts_dir_path/*"
    for f in $FILES; do
        echo "replacing $f file if found in cloud-init..."
        FILENAME=$(basename $f)
        BASE64CONTENT=$(base64 -i $f)
        sed -i '' "s|{{$FILENAME}}|$BASE64CONTENT|g" $target_cloud_init
    done

    if [ -n "$arm_template_path" ]; then
        echo "Generating ARM template."
        echo "ARM template path: $arm_template_path"
        save_arm_template $arm_template_path $target_cloud_init $target_path
    fi
}

save_dockerfile() {
    local dockerfile_path="$1"
    local scripts_dir_path="$2"
    local target_path="$3"

    local target_dockerfile_path="$target_path/$(basename $dockerfile_path)"

    echo "copying $dockerfile_path to $target_dockerfile_path."
    cp $dockerfile_path $target_dockerfile_path
    
    echo "copying $scripts_dir_path to $target_path/scripts"
    cp -R $scripts_dir_path $target_path/scripts
}

while getopts u:k:c:t:d:s:o: flag; do
    case "${flag}" in
    u) username=${OPTARG} ;;
    k) sshPublicKeyPath=${OPTARG} ;;
    c) source_cloud_init=${OPTARG} ;;
    t) arm_template_path=${OPTARG} ;;
    d) dockerfile_path=${OPTARG} ;;
    s) scripts_dir_path=${OPTARG} ;;
    o) target_path=${OPTARG} ;;
    esac
done

echo "Scripts directory path: $scripts_dir_path"
echo "Target path: $target_path"

mkdir -p $target_path

if [ -n "$source_cloud_init" ]; then
    echo "Generating cloud-init."
    save_cloud_init $username $sshPublicKeyPath $source_cloud_init $scripts_dir_path $target_path
fi

if [ -n "$dockerfile_path" ]; then
    echo "Generating Dockerfile."
    save_dockerfile $dockerfile_path $scripts_dir_path $target_path
fi

echo "done!"
