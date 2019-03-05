[all:vars]
load_balancer_dns=${load_balancer_dns}

[kube-master]
${master_inventories}

[kube-master:vars]
krddevdays_group=master
