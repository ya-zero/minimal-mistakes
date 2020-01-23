
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
show ovs setting: ovs-vsctl show
show port list: ovs-vsctl list port
show port ovs-br0: ovs-vsctl list-ports ovs-br0
```
