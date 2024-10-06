# Monitoring Demo

I have extended the exercise by providing diagnostic settings to my NICs and bastion host. Flow logs with traffic analytics are enabled for the NSGs.

A test connection monitor has been created to test if the backend pool has access to the public internet via http.

An interesting opportunity in a real project would be to create a negative monitor to check that private VMs cannot access the public internet.

Private IP addresses can be configured as well as destination to support targets other than VMs within Azure.