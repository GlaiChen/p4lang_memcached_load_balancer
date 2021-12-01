/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<8>  PROTOCOL_UDP = 0x11;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

// TODO: Add new headers here

header udp_t {
    bit<16> srcPort;	//Source Port;      0-65,535
    bit<16> dstPort;	//Destination Port; 0-65,535
    bit<16> len;	//Number of bytes comprising the UDP header and the UDP payload data
    bit<16> checksum;	//Verifying the integrity of the packet header and payload
}

header memcached_t {
    bit<96> cmd; 	//Unused bits in our assignment
    bit<32> preKey;	//The prefix of the key, could be "keyX"or any other char
    bit<8> key;		//The 5th and the only char we need to take care-of
    bit<8> endLine;	//The last byte
}
//Done Editing

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    // TODO: Add new headers here
    udp_t        udp;
    memcached_t  memcached;
    // Done Editing
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            PROTOCOL_UDP: parse_udp; 		//0x11 is 17, which is the protocol number for UDP, and without it the UDP won't be parsed
            default: accept;
        }
    }

    state parse_udp { 			//Parsing also layer 4
        packet.extract(hdr.udp);
        transition parse_memcached;
    }

    state parse_memcached { 		//Parsing also the UDP memcached
        packet.extract(hdr.memcached);
        transition accept;
    }
}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    action rewrite_ipv4_dst(ip4Addr_t dstAddr) {
        if (hdr.ipv4.protocol == PROTOCOL_UDP) { // Although the efficency it takes, I called that IF statement in order to enable the option for "pingall" command at the mininet
	    bit<32> original_dstAddr;
            // TODO: Complete here
            original_dstAddr = hdr.ipv4.dstAddr;
            hdr.ipv4.dstAddr = dstAddr;
            // TODO: Correct the UDP checksum. Use the following pseudo-code and adapt it to your implementation:
            hdr.udp.checksum = hdr.udp.checksum - (bit<16>)(dstAddr - original_dstAddr);
    	}
    }

// The next action is the same as the rewrite_ipv4_dst --> 
// The purpose is as written in 		       --> 
// "7.3 Correcting the source IP address in memcached responses" in the PDF assignment file
    action rewrite_ipv4_src(ip4Addr_t srcAddr) { 
	if (hdr.ipv4.protocol == PROTOCOL_UDP) {  // Although the efficency it takes, I called that IF statement in order to enable the option for "pingall" command at the mininet
           bit<32> original_srcAddr;
	   original_srcAddr = hdr.ipv4.srcAddr;
           hdr.ipv4.srcAddr = srcAddr;
           hdr.udp.checksum = hdr.udp.checksum - (bit<16>)(srcAddr - original_srcAddr);
        }
    }
           
    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    // TODO: Add new tables here
    // A new table for routing the UDP packets with the parsed key (odds/even/other)
    table memcached_exact {
        key = {
	    hdr.memcached.key: exact;
        }
        actions = { 
            rewrite_ipv4_dst;
	    drop;
        }
        size = 1024;
    }

    // A new table for correcting the source IP address in memcached responses    
    table correct_ipv4_src { 
        key = { }
        actions = {
            rewrite_ipv4_src;
        }
        size = 1024;
    }
    // A new table for sending the UDP packets to 10.0.1.1
    table correct_ipv4_dst {
        key = { }
        actions = {
            rewrite_ipv4_dst;
        }
        size = 1024;
    }
 
    apply {
        // TODO: Need to apply other flow tables
        if (hdr.ipv4.isValid() && hdr.memcached.isValid()) {
	    memcached_exact.apply();
        }
        if (hdr.ipv4.isValid() && standard_metadata.ingress_port != 1) {
            correct_ipv4_src.apply();
	    correct_ipv4_dst.apply();
	    
	}
	if (hdr.ipv4.isValid()) {
	     ipv4_lpm.apply();	
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
	// TODO: Need to emit other headers
        packet.emit(hdr.udp);
        packet.emit(hdr.memcached);
        // Done Editing
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
