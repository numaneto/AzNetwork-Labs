#!/bin/bash
# MultiHub and Spokes - Deployment Script 
# Writen by Numa Neto - numaneto@outlook.com 
# More information or comments on my GitHub profile - github.com/numaneto
#
# Variables :
location="eastus"
RG="RG-HUB-LAB77"
username="nva"
password="Nva@2k23nva@"
NvaName="NvaBgp"
asn_quagga="65020"
VNET_Spoke_Nprod='172.31.250.0/24'


# Clean All The Lab 
if [[ $1 == CLEAN ]]
    then 
    az group delete -n ${RG} --no-wait --yes
    exit
fi

echo "Starting the Lab Deployments"
az group create -n ${RG} --location ${location}

# Spokes Vnet's
az network vnet create --address-prefixes 172.31.250.0/24 --name SPOKE-nPROD --resource-group $RG --subnet-name Default --subnet-prefixes 172.31.250.0/25
az network vnet create --address-prefixes 172.31.251.0/24 --name SPOKE-PROD --resource-group $RG --subnet-name Default --subnet-prefixes 172.31.251.0/25

# Hub nPRD Vnet
az network vnet create --address-prefixes 172.31.252.0/24 --name HUB-nPROD --resource-group $RG --subnet-name AzureFirewallSubnet --subnet-prefixes 172.31.252.0/26
az network vnet subnet create --name AzureFirewallManagementSubnet --vnet-name HUB-nPROD --resource-group $RG --address-prefixes "172.31.252.64/26"
az network vnet subnet create --name TestSubenet --vnet-name HUB-nPROD --resource-group $RG --address-prefixes "172.31.252.128/27"

# Hub PRD Vnet
az network vnet create --address-prefixes 172.31.253.0/24 --name HUB-PROD --resource-group $RG --subnet-name AzureFirewallSubnet --subnet-prefixes 172.31.253.0/26
az network vnet subnet create --name AzureFirewallManagementSubnet --vnet-name HUB-PROD --resource-group $RG --address-prefixes "172.31.253.64/26"
az network vnet subnet create --name GatewaySubnet --vnet-name HUB-PROD --resource-group $RG --address-prefixes "172.31.253.128/27"
az network vnet subnet create --name RouteServerSubnet --vnet-name HUB-PROD --resource-group $RG --address-prefixes "172.31.253.160/27"
az network vnet subnet create --name NvaSubnet --vnet-name HUB-PROD --resource-group $RG --address-prefixes "172.31.253.192/27"

# Route Tables
az network route-table create -n rt-spoke-nprd -g $RG
az network route-table create -n rt-spoke-prd -g $RG
az network vnet subnet update -g $RG -n Default --vnet-name SPOKE-nPROD --route-table rt-spoke-nprd
az network vnet subnet update -g $RG -n Default --vnet-name SPOKE-PROD --route-table rt-spoke-prd

# Peerings
az network vnet peering create -g $RG -n HubPROD-to-HubNPROD --vnet-name HUB-PROD --remote-vnet HUB-nPROD --allow-vnet-access
az network vnet peering create -g $RG -n HubNPROD-to-HubPROD --vnet-name HUB-nPROD --remote-vnet HUB-PROD --allow-vnet-access
az network vnet peering create -g $RG -n SpokePROD-to-HUBPROD --vnet-name SPOKE-PROD --remote-vnet HUB-PROD --allow-vnet-access
az network vnet peering create -g $RG -n HubPROD-to-SpokePROD --vnet-name HUB-PROD --remote-vnet SPOKE-PROD --allow-vnet-access
az network vnet peering create -g $RG -n SpokeNPROD-to-HubNPROD --vnet-name SPOKE-nPROD --remote-vnet HUB-nPROD --allow-vnet-access
az network vnet peering create -g $RG -n HubNPROD-to-SpokeNPROD --vnet-name HUB-nPROD --remote-vnet SPOKE-nPROD --allow-vnet-access

# For Azure Firewall Provisioning - Install the CLI Extension:
# az extension add --name azure-firewall
# AZFW - PRD HUB
az network public-ip create --resource-group $RG --name azfw-mgmt-prd-ipp --sku Standard --allocation-method Static --output none
az network public-ip create --resource-group $RG --name azfw-snat-prd-ipp --sku Standard --allocation-method Static --output none
az network firewall policy create -g $RG -n PLCY-HUB-PRD --sku basic
az network firewall create -g $RG \
    -n AZFW-HUB-PRD \
    --sku AZFW_VNet --tier Basic \
    --vnet-name HUB-PROD \
    --firewall-policy PLCY-HUB-PRD \
    --conf-name azfw-prd-ipconfig \
    --m-conf-name azfw-prd-ManagementIpConfig \
    --m-public-ip azfw-mgmt-prd-ipp \
    --public-ip azfw-snat-prd-ipp

# Set Default GW in Spoke route table with Azure Firwall Private IP
az network route-table route create \
  --resource-group $RG \
  --name DG-AzFW \
  --route-table-name rt-spoke-prd \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $(az network firewall ip-config list -g $RG --firewall-name AZFW-HUB-PRD --query [].privateIpAddress -o tsv)

#AZFW - nPRD HUB
az network public-ip create --resource-group $RG --name azfw-mgmt-nprd-ipp --sku Standard --allocation-method Static --output none
az network public-ip create --resource-group $RG --name azfw-snat-nprd-ipp --sku Standard --allocation-method Static --output none
az network firewall policy create -g $RG -n PLCY-HUB-nPRD --sku basic
az network firewall create -g $RG \
    -n AZFW-HUB-nPRD \
    --sku AZFW_VNet --tier Basic \
    --vnet-name HUB-nPROD \
    --firewall-policy PLCY-HUB-nPRD \
    --conf-name azfw-nprd-ipconfig \
    --m-conf-name azfw-nprd-ManagementIpConfig \
    --m-public-ip azfw-mgmt-nprd-ipp \
    --public-ip  azfw-snat-nprd-ipp

# Set Default GW in Spoke route table with Azure Firwall Private IP
az network route-table route create \
  --resource-group $RG \
  --name DG-AzFW \
  --route-table-name rt-spoke-nprd \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $(az network firewall ip-config list -g $RG --firewall-name AZFW-HUB-nPRD --query [].privateIpAddress -o tsv)

AZFW_Hub_nPROD_pvt_IP=$(az network firewall ip-config list -g $RG --firewall-name AZFW-HUB-nPRD --query [].privateIpAddress -o tsv)

# Create LinuxVM for Route Injector
az network nic create --resource-group $RG --vnet HUB-PROD --subnet NvaSubnet --name $NvaName-Nic --ip-forwarding true -o none
az vm create --resource-group $RG --location $location --name $NvaName --size Standard_B1s --nics $NvaName-Nic  --image UbuntuLTS --admin-username $username --admin-password $password -o none

# Provisioning Route Server
az network public-ip create --resource-group $RG --name ars-ipp --sku Standard --allocation-method Static --output none
az network routeserver create --resource-group $RG \
    --name ARS-HUB-PROD \
    --hosted-subnet $(az network vnet subnet show --resource-group $RG --vnet-name HUB-PROD --name RouteServerSubnet --query id --out tsv) \
    --public-ip-address ars-ipp \
    -o none

# Variables to BGP stuff
#bgpRouterId=$(az network nic show --name $NvaName-Nic --resource-group $RG --query ipConfigurations[0].privateIpAddress -o tsv) - Need to Fix this query. 
bgpRouterId=172.31.253.196
routeserver_IP1=$(az network routeserver list --resource-group $RG --query '{IPs:[0].virtualRouterIps[0]}' -o tsv)
routeserver_IP2=$(az network routeserver list --resource-group $RG --query '{IPs:[0].virtualRouterIps[1]}' -o tsv)

# Installing and Set BGP on Ubuntu VM
scripturi="https://raw.githubusercontent.com/numaneto/AzNetwork-Labs/main/shell/ubnt-quagga.sh"
az vm extension set --resource-group $RG --vm-name $NvaName  --name customScript --publisher Microsoft.Azure.Extensions \
--protected-settings "{\"fileUris\": [\"$scripturi\"],\"commandToExecute\": \"./ubnt-quagga.sh $asn_quagga $bgpRouterId $VNET_Spoke_Nprod $routeserver_IP1 $routeserver_IP2 $AZFW_Hub_nPROD_pvt_IP\"}" \
--no-wait

# Peering between ARS / NVA Injector
az network routeserver peering create --resource-group $RG --routeserver ARS-HUB-PROD --name $NvaName --peer-asn $asn_quagga --peer-ip $bgpRouterId
# Enable Branch to Branch on ARS 
az network routeserver update --name ARS-HUB-PROD --resource-group $RG --allow-b2b-traffic yes 

# VNG 
az network public-ip create --resource-group $RG --name HUB-VNG-IPP --sku Standard --allocation-method Static --output none
az network public-ip create --resource-group $RG --name SEC-HUB-VNG-IPP --sku Standard --allocation-method Static --output none
az network vnet-gateway create -g $RG -n HUB-VNG --public-ip-addresses HUB-VNG-IPP SEC-HUB-VNG-IPP --vnet HUB-PROD --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait



echo "Done."
exit 
