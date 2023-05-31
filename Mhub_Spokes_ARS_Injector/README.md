
## Two HUBS & Spokes With Azure Firewall + Azure Route Server + Nva with BGP
### Description:

First: This lab is not a recomendation, it's an exercise. 

The main goal of this test/lab is practice with Azure Route Server and watch how that can be versatile. 

This topology consists in Spokes using Azure as default gateway by Peerings and UDRs. 

Virtual Network Gateway will advertise just the ipv4 prefixe's from PROD-HUB and PROD-Spokes. 

The ideia is using a Azure Route Server and NVA to reflect routes from NPROD Spokes (Behind to NPROD-HUB) to Virtual Network Gateway and to onpremises, if you have some VPN Connection. 

To do that, we need to set Azure Route Server in Branch to Branch mode (It's will configure iBGP between ARS and VNG automatically) 

and last, but not less, setting up our NVA to inject NPROD Spokes Network to ARS, poiting this route to the Azure Firewall from NPROD HUB. 

Well, we will need to use routemap in BGP options to change the nexthop optiosn for this advertised routes. 

Don't  worry - we have some shell script to do all this stuff for us. 

*grab a coffee mate! And let's routing the cloud.*

#### The Big Picture explained: 

##### Azure Resources:
    • 2x HUBS VNETS (PROD and nPROD) 
    • 2x Spokes VNETS (PROD and nPROD)
    • 2x Azure Firewalls (one of each HUB)
    • 1x Azure Route Server (HUB PROD) 
    • 1x Virtual Network Gateway
    • 1x Linux Virtual Machine with Quagga software for BGP Service
    
Onpremises Side is just for ilustrate

![Diagram](../Images/github-Multihub-and-SingleSpokes.png)


##### How to Deploy all this Resources ?

I wrote a shell script that will deploy all resources needed to build this topology. 

Check them here : [MHubs-Spokes-ARS-Injector-Deployment.sh](../shell/mhub-spk-ars-nvabgp.sh)











