


host machine

libvirt+ovs
xml-network (default)
vm  xml  intreface examples
   <interface type='network'>
      <mac address='52:54:00:e3:27:11'/>
      <source network='default' portgroup='trunkPortGroup'/>
      <model type='virtio'/>
      <boot order='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
