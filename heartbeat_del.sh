#!/bin/bash
#Script to delete hosts which has lost its hearbeat from the cluster

user=occ
pass=\""Y@3NXx'"
AMBARI_SERVER_HOST=<ambari-hostname>
CLUSTER_NAME=<Cluster-name>

#Get the list of the unhealthy nodes in the ambari cluster.

echo "Gathering the list of the hosts which are unhealthy in $AMBARI_SERVER_HOST."
echo "Have a sip of your coffee until then!!"
yarn node -list -states lost | grep LOST | awk '{print $1}' | cut -d':' -f1 > del_list.txt
echo "Gathering task is completed."


#Delete all components in the hosts which have lost the heartbeat.

echo ""
echo "Deleting all the components under the unhealthy hosts."
echo "This may take some time to complete."
echo ""
for i in `cat del_list.txt`
do
	echo "$i `curl -u $user:$pass -H "X-Requested-By: ambari" -X DELETE  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts/$i/host_components`"
done
echo "All the components are deleted."
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
