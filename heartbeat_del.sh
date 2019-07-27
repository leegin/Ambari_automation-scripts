#!/bin/bash
#Author: Leegin Bernads T.S
#Script to delete hosts which has lost its hearbeat from the cluster

user=<USER>
pass=<PASSWORD>
AMBARI_SERVER_HOST=<ambari-hostname>
CLUSTER_NAME=<cluster>

ip_traslate()
{
if [[ $i =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
	j=`host $i | awk '{print $5}' | cut -d'.' -f1,2,3,4`
else
	j=$i
fi
}

spin()
{
  spinner="/|\\-/|\\-"
  while :
  do
    for i in `seq 0 7`
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 1
    done
  done
}

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

#Start the Spinner
spin &

#Make a note of its Process ID (PID)
SPIN_PID=$!

#Kill the spinner on any signal, including our own exit.
trap "kill -9 $SPIN_PID" `seq 0 15`

for i in `cat del_list.txt`
do
	ip_traslate
	echo "$j `curl -s -u $user:$pass -H "X-Requested-By: ambari" -X DELETE  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts/$j/host_components`" >> heartbeat.log
done
echo "All the components are deleted."
echo ""

#kill the spinner now
kill -9 $SPIN_PID

#Delete the node once the components are stopped.

echo "Proceeding with deleteing the hosts from the clusters."
echo "Again this may take sometime."
echo ""

#Start the Spinner
spin &

#Make a note of its Process ID (PID)
SPIN_PID=$!

#Kill the spinner on any signal, including our own exit.
trap "kill -9 $SPIN_PID" `seq 0 15`

for i in `cat del_list.txt`
do
	ip_traslate
	echo "$j `curl -s -u $user:$pass -H "X-Requested-By: ambari" -X DELETE  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts/$j`" >> heartbeat.log
done
echo "Deleted all the unhealthy hosts successfully!!"

#kill the spinner now
kill -9 $SPIN_PID
