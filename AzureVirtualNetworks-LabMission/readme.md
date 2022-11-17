Welcome to Azure Virtual Network Lab Mission. 

The proposal of this lab is : 

Using our discussion to provision a enviroment, to practice and memorize all elements and concepts. 

1 - Create two VNET's with no overlaping, ok ?

2 - Create at least two subnets in each VNET.

3 - Create one Virtual machine per subnet.

4 - Each Virtual machine can receive a different IP Configuration in their NICs, for example: 

    VM1 / VNET1 / Subnet1 / IPConfig1 - Dynamic Internal IP, with no Public IP. 
    
    VM2 / VNET1 / Subnet2 / IPConfig1 - Static  Internal IP, with Public IP. 
    
    VM3 / VNET2 / Subnet1 / IPConfig1 - Static  Internal IP, with no Public IP. 
    
    VM4 / VNET2 / Subnet2 / IPConfig1 - Dynamic Internal IP, with Public IP. 
    

5 - Create two NSGs:
   
    1 - LabNSG1
    2 - LabNSG2 
    
6 - Apply both NSGs under the subnet scopes, as follow:
    
    1 - LabNSG1 - Apply at Subnets from VNET1. 
    2 - LabNSG2 - Apply at Subnets from VNET2. 
    
7 - Let's insert some rules in this lab:
    
    1 - VM1 does not like to receive RDP (TCP 3389) connections from VM2, VM3, but ok from VM4. 
    2 - VM2 does not like to receive RDP (TCP 3389) connections from any VMS, but from Public IP address from your home ( YES, your home =) ) , is ok. 
      PS : If you are looking for your Public IP adress, get in touch with this sites : 
           https://ifconfig.me/
           If you are in a shell box ( like a Azure Cloud Shell), may you can use that line:
           # curl ifconfig.me 
    3 - VM3 would like to accept connections (All Protocols)  from All VMS. 
    4 - VM4 would like to receive connections (All protocols) from VM2 and from Public IP address from your home (yeap, your home again =) ). 
    
 8 - What's Hub and Spoke topology?
 
     Please, read that : [Hub and Spoke - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
     
   After the reading, share your thoughts in our next conversation. 
