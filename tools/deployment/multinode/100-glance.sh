#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Deploy command
GLANCE_BACKEND="radosgw" # NOTE(portdirect), this could be: radosgw, rbd, swift or pvc
helm install ./glance \
  --namespace=openstack \
  --name=glance \
  --set pod.replicas.api=2 \
  --set pod.replicas.registry=2 \
  --set storage=${GLANCE_BACKEND}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status glance
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack image list
openstack image show 'Cirros 0.3.5 64-bit'
helm test glance --timeout 900
