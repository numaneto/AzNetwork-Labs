
## Two HUBS & Spokes With Azure Firewall + Azure Route Server + Nva with BGP
### Description:

*Disclaimer*: This lab is not a recommendation; it's an exercise.

The main goal of this test/lab is to practice with Azure Route Server and observe its versatility.

This topology consists of Spokes using Azure as the default gateway through Peerings and UDRs.

The Virtual Network Gateway will only advertise the IPv4 prefixes from PROD-HUB and PROD-Spokes.

The idea is to use an Azure Route Server and NVA to reflect routes from NPROD Spokes (located behind NPROD-HUB) to the Virtual Network Gateway and to on-premises if you have a VPN connection.

To achieve this, we need to configure the Azure Route Server in Branch to Branch mode, which will automatically set up iBGP between ARS and VNG.

Last but not least, we need to configure our NVA to inject NPROD Spokes Network into ARS, pointing this route to the Azure Firewall from NPROD HUB.

Don't worry - we have a shell script to handle all these tasks for us.

*Grab a coffee, mate! Let's route the cloud*.

### The Big Picture explained: 

##### Azure Resources:
    • 2x HUBS VNETS (PROD and nPROD) 
    • 2x Spokes VNETS (PROD and nPROD)
    • 2x Azure Firewalls (one of each HUB)
    • 1x Azure Route Server (HUB PROD) 
    • 1x Virtual Network Gateway
    • 1x Linux Virtual Machine with Quagga software for BGP Service
    
*On-premises Side is just for ilustrate*.

![Diagram](../Images/github-Multihub-and-SingleSpokes.png)


##### How to Deploy all this Resources ?

I wrote a shell script that will deploy all resources needed to build this topology. 

Check them here : [MHubs-Spokes-ARS-Injector-Deployment.sh](../shell/mhub-spk-ars-nvabgp.sh)

##### Basic Guidance to use this script: 
      1 - All this script run with Azure CLI and login process and setup of the right account must be done before the running. 
      2 - Using just ./script.sh - you will start the deployment in Azure. 
      3 - Using ./script.sh CLEAN - you will clean all resources with no confirmation needs. 
      4 - You must have the Azure Firewall extension for Azure CLI (az extension add --name azure-firewall).
      5 - Azure Route Server deployment can be take some minutes (kind of 30 mins). 
      6 - Virtual Network Gateway will be deployed with --no-wait options and this mean that the script will end, but for around 40 minutes
          VNG will stay in status "Updating". 
      7 - Delete the lab in the end of day is high recommended to save costs.
       
 ##### Resources created by this script: 
  
 ![ResourceDump](../Images/mhub-spks-ars-nvabgp-azfw-resourcesdump.png) 
 
 
 ##### Results / Learnings : 
After all the deployment end's - go to Virtual Network Gateway and watch BGP Peer's - What we must expect ? 

*Routes from nPRD Spoke with ASPath from our NVA (In this case i set to 65020);*

*This route must be pointed to the private IP of nPRD HUB Azure Firewall;* 

 ![ResourceDump](../Images/mhub-spks-vng-results.png)
 
 
 Yes! we have a route injector! 
 
 See you on the next ride. 
 
 
 
 












