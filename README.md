The "heartbeat_del.sh" script will find all the hosts that has lost its heartbeat in the ambari cluster and delete them.

The "unhealthyhost_del.sh" script will find all the unhealthy nodes in the ambari cluster, stop all the components under them and finally delete them.

All you need to provide is the ambari cluster credentials, the cluster name and the ambari server hostname. Also make sure you add the name of the components to be deleted in stop/delete part of the scripts. I used the script only to stop/delete 2 components. You may include more as per your need.
