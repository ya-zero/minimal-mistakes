---
title: "openvswitch"
date: 2019-01-23 09:00:00 +0000
categories: 
  - ovs
tags:
  - ovs openvswitch libvirt 
---



host machine

libvirt+ovs
xml-network (default)
vm  xml  intreface examples
```xml
   <interface type='network'>
      <mac address='52:54:00:e3:27:11'/>
      <source network='default' portgroup='trunkPortGroup'/>
      <model type='virtio'/>
      <boot order='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
```

```
<network>
  <name>default</name>
  <uuid>5adf5e8e-bf47-441d-b76e-386f35cd6e23</uuid>
  <forward mode='bridge'/>
  <bridge name='ovs-br0'/>
  <virtualport type='openvswitch'/>
  <portgroup name='trunkPortGroup' default='yes'>
    <vlan trunk='yes'>
      <tag id='1069' nativeMode='untagged'/>
      <tag id='1070'/>
      <tag id='1071'/>
    </vlan>
  </portgroup>
</network>
```




commands 

```
show fdb:    ovs-appctl fdb/show ovs-br0
clear fdb: ovs-appctl fdb/stats-clear ovs-br0
show ovs setting: ovs-vsctl show
show port list: ovs-vsctl list port
show port ovs-br0: ovs-vsctl list-ports ovs-br0
```


ovs-vsctl set bridge <bridge> other-config:mac-table-size=<size>
  


ovs-ofctl show ovs-br0
```
OFPT_FEATURES_REPLY (xid=0x2): dpid:0000222370c69e43
n_tables:254, n_buffers:0
capabilities: FLOW_STATS TABLE_STATS PORT_STATS QUEUE_STATS ARP_MATCH_IP
actions: output enqueue set_vlan_vid set_vlan_pcp strip_vlan mod_dl_src mod_dl_dst mod_nw_src mod_nw_dst mod_nw_tos mod_tp_src mod_tp_dst
 9(ovs-vlan1070): addr:52:75:79:51:59:69
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 122(vnet1): addr:fe:54:00:38:ae:3e
     config:     0
     state:      0
     current:    10MB-FD COPPER
     speed: 10 Mbps now, 0 Mbps max
 123(vnet2): addr:fe:54:00:ca:04:dd
     config:     0
     state:      0
     current:    10MB-FD COPPER
     speed: 10 Mbps now, 0 Mbps max
 LOCAL(ovs-br0): addr:22:23:70:c6:9e:43
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
OFPT_GET_CONFIG_REPLY (xid=0x4): frags=normal miss_send_len=0
```

openvswitch сервисы :
```bash
openvswitch-switch.service                                                         loaded active exited    Open vSwitch
ovs-vswitchd.service                                                               loaded active running   Open vSwitch Forwarding Unit
ovsdb-server.service                                                               loaded active running   Open vSwitch Database Unit
```

start vm 
```
64 bytes from 10.193.17.25: icmp_seq=29 ttl=64 time=0.032 ms
64 bytes from 10.193.17.25: icmp_seq=37 ttl=64 time=0.292 ms
64 bytes from 10.193.17.25: icmp_seq=38 ttl=64 time=0.075 ms
64 bytes from 10.193.17.25: icmp_seq=39 ttl=64 time=0.050 ms
```

