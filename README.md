# Network Configuration Scheduler

This project aims to provide an easy way for non-technical personell in organisations wielding multiple client VLANs (zones) to be able to change which zone the clients on a switch, or several switches grouped by room, connects to.

The original use case is in-house class rooms, or course rooms if you will, rigged with thin-clients connecting to terminal servers based on DHCP configuration and VLAN-based separation of subnets for security. Changing the VLAN on the switch will connect these thin-clients to a different subnet, resulting in new configuration settings delivered over DHCP.

The project will aim at generalizing the back-end for other use cases as well and focus on the configuration of switchports. Other projects will build out UI's for touch-panels for one-touch configuration, self-service systems for booking the rooms with scheduled zone configuration, or even web pages for help desks for easy remote configuration of ports.