#!/bin/bash
#Script to delete the unhealthy nodes from ambar clusters.

user=<USER>
pass=<PASSWORD>
AMBARI_SERVER_HOST=<ambari-hostname>
CLUSTER_NAME=<Cluster-name>

#Get the list of the unhealthy nodes in the ambari cluster.
echo "Gathering the list of the hosts which are unhealthy in $AMBARI_SERVER_HOST."
echo "Have a sip of your coffee until then!!"
yarn node -list -states unhealthy | grep UNHEALTHY | awk '{print $1}' | cut -d':' -f1 > del_list.txt
echo "Gathering task is completed."

#stop all the components in the unhealthy hosts.

echo ""
echo "Stopping all the components under the unhealthy hosts."
echo "This may take some time to complete."
echo ""
for i in `cat del_list.txt`
do
	echo "$i `curl -XPUT -u $user:$pass --header "X-Requested-By: ambari" http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts/$i/host_components -d '{"RequestInfo":{"context":"Stop All Host Components","operation_level":{"level":"HOST","cluster_name":"$CLUSTER_NAME","host_names":"$i"},"query":"HostRoles/component_name.in(METRICS_MONITOR,NODEMANAGER)"},"Body":{"HostRoles":{"state":"INSTALLED"}}}'`"
done
echo "All the components are stopped."
echo ""


#Delete the node once the components are stopped.

echo "Proceeding with deleteing the hosts from the clusters."
echo "Again this may take sometime."
echo ""
for i in `cat del_list.txt`
do
	echo "$i `curl -u $user:$pass -H "X-Requested-By: ambari" -X DELETE  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts/$i`"
done
echo "Deleted all the unhealthy hosts successfully!!"
