---
title: "openvswitch"
date: 2019-01-23 09:00:00 +0000
categories: 
  - ovs
tags:
  - ovs openvswitch libvirt 
---


avoznyy
az123q


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

запуск vm с ovs
```
ovs-vsctl  set port  ovs-br0 tag=1069 trunks=1070,1071 vlan_mode=native-untagged
ovs-vsctl add-port   ovs-br0 ovs-vlan1070 tag=1070 -- set Interface ovs-vlan1070 type=internal
ovs-vsctl add-port ovs-br0 ovs-vlan1069 tag=1069 -- set Interface ovs-vlan1069 type=internal
ip add add 10.193.17.133/24 dev ovs-vlan1069
```



работа с базой 
ovsdb-client list-dbs
ovsdb-client list-tables
ovsdb-client dump Open_vSwitch


```
ovsdb-client dump Open_vSwitch
AutoAttach table
_uuid mappings system_description system_name
----- -------- ------------------ -----------

Bridge table
_uuid                                auto_attach controller datapath_id        datapath_type datapath_version external_ids fail_mode flood_vlans flow_tables ipfix mcast_snooping_enable mirrors name      netflow other_config ports                                                                                                              protocols rstp_enable rstp_status sflow status stp_enable
------------------------------------ ----------- ---------- ------------------ ------------- ---------------- ------------ --------- ----------- ----------- ----- --------------------- ------- --------- ------- ------------ ------------------------------------------------------------------------------------------------------------------ --------- ----------- ----------- ----- ------ ----------
3ff5aab7-40ee-46ca-a3c4-ecfceb3b954a []          []         "0000b6aaf53fca46" ""            "<unknown>"      {}           []        []          {}          []    false                 []      "ovs-br0" []      {}           [3ba4b00c-8bf8-4ec0-aacb-3b7e4f19e8a6, 43b0332d-974b-43e7-bdf4-86768fb64338, 6bb50d19-da94-4cb2-8db3-7e9522a87a2e] []        false       {}          []    {}     false

Controller table
_uuid connection_mode controller_burst_limit controller_rate_limit enable_async_messages external_ids inactivity_probe is_connected local_gateway local_ip local_netmask max_backoff other_config role status target
----- --------------- ---------------------- --------------------- --------------------- ------------ ---------------- ------------ ------------- -------- ------------- ----------- ------------ ---- ------ ------

Flow_Sample_Collector_Set table
_uuid bridge external_ids id ipfix
----- ------ ------------ -- -----

Flow_Table table
_uuid external_ids flow_limit groups name overflow_policy prefixes
----- ------------ ---------- ------ ---- --------------- --------

IPFIX table
_uuid cache_active_timeout cache_max_flows external_ids obs_domain_id obs_point_id other_config sampling targets
----- -------------------- --------------- ------------ ------------- ------------ ------------ -------- -------

Interface table
_uuid                                admin_state bfd bfd_status cfm_fault cfm_fault_status cfm_flap_count cfm_health cfm_mpid cfm_remote_mpids cfm_remote_opstate duplex error external_ids                                                                                                                                           ifindex ingress_policing_burst ingress_policing_rate lacp_current link_resets link_speed link_state lldp mac mac_in_use          mtu  mtu_request name           ofport ofport_request options other_config statistics                                                                                                                                                                             status                                                       type
------------------------------------ ----------- --- ---------- --------- ---------------- -------------- ---------- -------- ---------------- ------------------ ------ ----- ------------------------------------------------------------------------------------------------------------------------------------------------------ ------- ---------------------- --------------------- ------------ ----------- ---------- ---------- ---- --- ------------------- ---- ----------- -------------- ------ -------------- ------- ------------ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ------------------------------------------------------------ --------
cc3de0ee-f4d9-4ed0-b84f-d24fec263502 up          {}  {}         []        []               []             []         []       []               []                 []     []    {}                                                                                                                                                     14      0                      0                     []           1           []         up         {}   []  "b6:aa:f5:3f:ca:46" 1500 []          "ovs-br0"      65534  []             {}      {}           {collisions=0, rx_bytes=364307, rx_crc_err=0, rx_dropped=0, rx_errors=0, rx_frame_err=0, rx_over_err=0, rx_packets=2391, tx_bytes=1787354, tx_dropped=0, tx_errors=0, tx_packets=4418} {driver_name=openvswitch}                                    internal
406bed5b-b128-4db0-837a-2f1179b90e29 up          {}  {}         []        []               []             []         []       []               []                 []     []    {}                                                                                                                                                     15      0                      0                     []           1           []         up         {}   []  "4a:b3:24:88:b7:03" 1500 []          "ovs-vlan1070" 1      []             {}      {}           {collisions=0, rx_bytes=94117, rx_crc_err=0, rx_dropped=0, rx_errors=0, rx_frame_err=0, rx_over_err=0, rx_packets=944, tx_bytes=165573, tx_dropped=0, tx_errors=0, tx_packets=801}     {driver_name=openvswitch}                                    internal
7fd6b539-cae8-4fb6-91bd-f5026ea81018 up          {}  {}         []        []               []             []         []       []               []                 full   []    {attached-mac="52:54:00:38:ae:3e", iface-id="23000b4d-2013-4410-9f54-ebf8f116ea21", iface-status=active, vm-id="ae05a060-e8ca-4346-b24c-51e38eb6a4ab"} 16      0                      0                     []           1           10000000   up         {}   []  "fe:54:00:38:ae:3e" 1500 []          "vnet0"        2      []             {}      {}           {collisions=0, rx_bytes=233612, rx_crc_err=0, rx_dropped=0, rx_errors=0, rx_frame_err=0, rx_over_err=0, rx_packets=1596, tx_bytes=1559354, tx_dropped=0, tx_errors=0, tx_packets=2294} {driver_name=tun, driver_version="1.6", firmware_version=""} ""

Manager table
_uuid connection_mode external_ids inactivity_probe is_connected max_backoff other_config status target
----- --------------- ------------ ---------------- ------------ ----------- ------------ ------ ------

Mirror table
_uuid external_ids name output_port output_vlan select_all select_dst_port select_src_port select_vlan snaplen statistics
----- ------------ ---- ----------- ----------- ---------- --------------- --------------- ----------- ------- ----------

NetFlow table
_uuid active_timeout add_id_to_interface engine_id engine_type external_ids targets
----- -------------- ------------------- --------- ----------- ------------ -------

Open_vSwitch table
_uuid                                bridges                                cur_cfg datapath_types   db_version external_ids                                                                                             iface_types                                                   manager_options next_cfg other_config ovs_version ssl statistics system_type system_version
------------------------------------ -------------------------------------- ------- ---------------- ---------- -------------------------------------------------------------------------------------------------------- ------------------------------------------------------------- --------------- -------- ------------ ----------- --- ---------- ----------- --------------
3c85774b-2a98-4cc9-96d2-63fc684c535a [3ff5aab7-40ee-46ca-a3c4-ecfceb3b954a] 4       [netdev, system] "7.15.1"   {hostname="d01oscsn03", rundir="/var/run/openvswitch", system-id="dabf613c-095c-497c-9e21-0d91a1252c9b"} [geneve, gre, internal, lisp, patch, stt, system, tap, vxlan] []              4        {}           "2.9.2"     []  {}         ubuntu      "18.04"

Port table
_uuid                                bond_active_slave bond_downdelay bond_fake_iface bond_mode bond_updelay cvlans external_ids fake_bridge interfaces                             lacp mac name           other_config protected qos rstp_statistics rstp_status statistics status tag  trunks       vlan_mode
------------------------------------ ----------------- -------------- --------------- --------- ------------ ------ ------------ ----------- -------------------------------------- ---- --- -------------- ------------ --------- --- --------------- ----------- ---------- ------ ---- ------------ ---------------
43b0332d-974b-43e7-bdf4-86768fb64338 []                0              false           []        0            []     {}           false       [cc3de0ee-f4d9-4ed0-b84f-d24fec263502] []   []  "ovs-br0"      {}           false     []  {}              {}          {}         {}     1069 [1070, 1071] native-untagged
6bb50d19-da94-4cb2-8db3-7e9522a87a2e []                0              false           []        0            []     {}           false       [406bed5b-b128-4db0-837a-2f1179b90e29] []   []  "ovs-vlan1070" {}           false     []  {}              {}          {}         {}     1070 []           []
3ba4b00c-8bf8-4ec0-aacb-3b7e4f19e8a6 []                0              false           []        0            []     {}           false       [7fd6b539-cae8-4fb6-91bd-f5026ea81018] []   []  "vnet0"        {}           false     []  {}              {}          {}         {}     1069 []           native-untagged

QoS table
_uuid external_ids other_config queues type
----- ------------ ------------ ------ ----

Queue table
_uuid dscp external_ids other_config
----- ---- ------------ ------------

SSL table
_uuid bootstrap_ca_cert ca_cert certificate external_ids private_key
----- ----------------- ------- ----------- ------------ -----------

sFlow table
_uuid agent external_ids header polling sampling targets
----- ----- ------------ ------ ------- -------- -------
```
