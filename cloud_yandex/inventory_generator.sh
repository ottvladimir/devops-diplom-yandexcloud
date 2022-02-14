#!/bin/bash

set -e

printf "[all]\n"

for num in $(seq 1 $(terraform output -json instance_group_public_ips | jq length))
do
printf "node-$num   ansible_host="
terraform output -json instance_group_public_ips | jq -j ".[$num-1]"
printf "   ip="
terraform output -json instance_group_private_ips | jq -j ".[$num-1]"
printf "   etcd_member_name=etcd$num\n"
done

printf "\n[all:vars]\n"
printf "ansible_user=ubuntu\n"
printf "supplementary_addresses_in_ssl_keys='"
terraform output -json instance_group_public_ips | jq -cj
printf "'\n\n"

cat << EOF
[kube_control_plane]
node-1
node-2
node-3
[etcd]
node-1
node-2
node-3

[kube_node]
node-2
node-3

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
EOF
