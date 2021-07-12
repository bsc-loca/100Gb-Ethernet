
# script to build bare-metal application
# XSCT reference: http://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/obi1585821551850.html
# XSCT uses Xvfb and thus "ssh -X" should be used for remote run

#Set Vitis workspace
setws ./xsct_ws
#Checking available apps as templates
repo -apps
#Create application project (combined creation of platform, domain/bsp, project/app)
app create -name eth_test -hw ./project/ethernet_test_wrapper.xsa -proc microblaze_0 -arch 32 -os standalone -lang c++ -template {Empty Application (C++)}
# -os freertos10_xilinx                # tested option to create app under simple OS
# -lang c -template {lwIP Echo Server} # tested option to create simple lwIP-based app (further importsources command should be commented)

#Create platform and domain/bsp
# platform create -name eth_test_platform -hw ./project/ethernet_test_wrapper.xsa -proc microblaze_0 -arch 32 -os standalone
#Create project/app
# app create -name eth_test -platform eth_test_platform -lang c++ -template {Empty Application (C++)}

#Report created platform
platform list
platform active
platform report

#Report set OS
domain list
domain active
domain report

#config the BSP
bsp setlib -name lwip211
#additional lwip configurations taken from activated UDP/TCP Perf examples in Vitis GUI
#for all examples
#  (DHCP enabling causes lack of dhcp_fine_tmr() and dhcp_coarse_tmr() functions so far)
# bsp config lwip_dhcp true
# bsp config dhcp_does_arp_check true
# bsp config mem_size 524288
bsp config mem_size 63488
# bsp config memp_n_pbuf 1024
#  below pbuf_pool_size value causes dramatic overflow of available uBlaze memory
# bsp config pbuf_pool_size 16384
#for TCP client/server only
# bsp config memp_n_tcp_seg 1024
#  below memp_n_tcp_seg value is a trade-off between fit to DMA Tx Mem and satisfy as much as possible tcp_snd_buf
bsp config memp_n_tcp_seg 128
#for TCP client/server only
# bsp config tcp_snd_buf 65535
#for TCP client/server only
bsp config tcp_wnd 65535
#for TCP client/server and UDP server only
#  n_rx_descriptors value is not passed to the code and should be manually set as XLWIP_CONFIG_N_RX_DESC, limited by pbuf_pool_size
# bsp config n_rx_descriptors 512
#for TCP client/server and UDP client only
#  n_tx_descriptors value is not passed to the code and should be manually set as XLWIP_CONFIG_N_TX_DESC
# bsp config n_tx_descriptors 512

#enabling lwip debug messages
# bsp config icmp_debug  true # causes compile error in icmp.c:253: undefined reference to `lwip_strerr'
bsp config igmp_debug  true
# bsp config ip_debug    true
bsp config lwip_debug  true
bsp config netif_debug true
# bsp config pbuf_debug  true
bsp config sys_debug   true
# bsp config tcp_debug   true
# bsp config udp_debug   true

bsp config -append extra_compiler_flags "-std=gnu18 -DDEBUG \
                                         -I../../../../../../../../../src/cpp/syst_hw \
                                         -I../../../../../../../../../src/cpp/lwip_hw \
                                  -imacros ../../../../../../../../../src/cpp/lwip_hw/lwip_extra_defs.h -Werror=div-by-zero"
# bsp regenerate
#Report created BSP
bsp listparams -proc
bsp getos
bsp listparams -os
bsp getdrivers
bsp getlibs
bsp listparams -lib lwip211
# result of above command before bsp config of lwip (default values) and with description, grabbed from .log Vitis file:
# ================================================================================                                                  
# PARAMETER                       VALUE      DESCRIPTION
# ================================================================================
# api_mode                        RAW_API    Mode of operation for lwIP ("RAW API"/"SOCKET API")
# arp_options                     true       ARP Options
#   arp_queueing                  1          If enabled outgoing packets are queued during hardware address resolution
#   arp_table_size                10         Number of active hardware address IP address pairs cached
# debug_options                   true       Turn on lwIP Debug?
#   icmp_debug                    false      Debug ICMP protocol
#   igmp_debug                    false      Debug IGMP protocol
#   ip_debug                      false      Debug IP layer
#   lwip_debug                    false      Turn on lwIP Debug?
#   netif_debug                   false      Debug network interface layer
#   pbuf_debug                    false      Debug pbuf layer
#   sys_debug                     false      Debug sys arch layer
#   tcp_debug                     false      Debug TCP layer
#   udp_debug                     false      Debug UDP layer
# dhcp_options                    true       Is DHCP required?
#   lwip_dhcp                     false      Is DHCP required?
#   dhcp_does_arp_check           false      ARP check on offered addresses?
# icmp_options                    true       ICMP Options
#   icmp_ttl                      255        ICMP TTL value
# igmp_options                    false      IGMP Options
# lwip_ip_options                 true       IP Options
#   ip_default_ttl                255        Global default TTL used by transport layers
#   ip_forward                    0          Enable forwarding IP packets across network interfaces
#   ip_frag                       1          Fragment outgoing IP packets if their size exceeds MTU
#   ip_frag_max_mtu               1500       Assumed max MTU on any interface for IP frag buffer
#   ip_options                    0          1 = IP options are allowed (but not parsed). 0 = packets with IP options are dropped.
#   ip_reass_max_pbufs            128        Reassembly PBUF Queue Length
#   ip_reassembly                 1          Reassemble incoming fragmented IP packets
# ipv6_enable                     false      IPv6 enable value
#   ipv6_options                  true       IPv6 Options
# lwip_memory_options                        Options controlling lwIP memory usage
#   mem_size                      131072     Size of the heap memory (bytes)
#   memp_n_pbuf                   16         Number of memp struct pbufs. Set this high if application sends lot of data out of ROM
#   memp_n_sys_timeout            8          Number of simultaneously active timeouts
#   memp_n_tcp_pcb                32         Number of active TCP PCBs. One per active TCP connection
#   memp_n_tcp_pcb_listen         8          Number of listening TCP connections
#   memp_n_tcp_seg                256        Number of simultaneously queued TCP segments
#   memp_n_udp_pcb                4          Number of active UDP PCBs. One per active UDP connection
#   memp_num_api_msg              16         Number of api msg structures (socket mode only)
#   memp_num_netbuf               8          Number of struct netbufs (socket mode only)
#   memp_num_netconn              16         Number of struct netconns (socket mode only)
#   memp_num_tcpip_msg            64         Number of tcpip msg structures (socket mode only)
# lwip_tcp_keepalive              false      Enable keepalive processing with default interval
# mbox_options                    true       Mbox Options
#   default_tcp_recvmbox_size     200        Size of TCP receive mbox queue
#   default_udp_recvmbox_size     100        Size of UDP receive mbox queue
#   lwip_tcpip_core_locking_input false      TCPIP input core locking
#   tcpip_mbox_size               200        Size of TCPIP mbox queue
# temac_adapter_options           true       Settings for xps-ll-temac/Axi-Ethernet/Gem lwIP adapter
#   emac_number                   0          Zynq Ethernet Interface number
#   n_rx_coalesce                 1          Setting for RX Interrupt coalescing.Applicable only for Axi-Ethernet/xps-ll-temac
#   n_rx_descriptors              64         Number of RX Buffer Descriptors to be used in SDMA mode
#   n_tx_coalesce                 1          Setting for TX Interrupt coalescing. Applicable only for Axi-Ethernet/xps-ll-temac
#   n_tx_descriptors              64         Number of TX Buffer Descriptors to be used in SDMA mode
#   phy_link_speed                CONFIG_LINKSPEED_AUTODETECT  link speed as negotiated by the PHY
#                                                               "CONFIG_LINKSPEED10":          "10 Mbps"
#                                                               "CONFIG_LINKSPEED100":         "100 Mbps"
#                                                               "CONFIG_LINKSPEED1000":        "1000 Mbps"
#                                                               "CONFIG_LINKSPEED_AUTODETECT": "Autodetect"
#   tcp_ip_rx_checksum_offload    false      Offload TCP and IP Receive checksum calculation (hardware support required).Applicable only for Axi-Ethernet
#   tcp_ip_tx_checksum_offload    false      Offload TCP and IP Transmit checksum calculation (hardware support required).Applicable only for Axi-Ethernet
#   tcp_rx_checksum_offload       false      Offload TCP Receive checksum calculation (hardware support required).Applicable only for Axi-Ethernet/xps-ll-temac
#   tcp_tx_checksum_offload       false      Offload TCP Transmit checksum calculation (hardware support required).Applicable only for Axi-Ethernet/xps-ll-temac
#   temac_use_jumbo_frames        false      use jumbo frames
# no_sys_no_timers                true       Drops support for sys_timeout when NO_SYS==1
# pbuf_options                    true       Pbuf Options
#   pbuf_link_hlen                16         Number of bytes that should be allocated for a link level header
#   pbuf_pool_bufsize             1700       Size of each pbuf in pbuf pool
#   pbuf_pool_size                256        Number of buffers in pbuf pool
# socket_mode_thread_prio         2          Priority of threads in socket mode
# stats_options                   true       Turn on lwIP statistics?
#   lwip_stats                    false      Turn on lwIP statistics?
# tcp_options                     true       Is TCP required ?
#   lwip_tcp                      true       Is TCP required ?
#   tcp_maxrtx                    12         TCP Maximum retransmission value
#   tcp_mss                       1460       TCP Maximum segment size (bytes)
#   tcp_queue_ooseq               1          Should TCP queue segments arriving out of order. Set to 0 if your device is low on memory
#   tcp_snd_buf                   8192       TCP sender buffer space (bytes)
#   tcp_synmaxrtx                 4          TCP Maximum SYN retransmission value
#   tcp_ttl                       255        TCP TTL value
#   tcp_wnd                       2048       TCP Window (bytes)
# udp_options                     true       Is UDP required ?
#   lwip_udp                      true       Is UDP required ?
#   udp_ttl                       255        UDP TTL value
# use_axieth_on_zynq              1          Option if set to 1 ensures axiethernet adapter being used in Zynq. Valid only for Zynq
# use_emaclite_on_zynq            1          Option if set to 1 ensures emaclite adapter being used in Zynq. Valid only for Zynq

#Report created project
sysproj list
sysproj report eth_test_system

#Report created app
app list
app report eth_test
#config the app
importsources -name eth_test -path ./src/cpp/ 
app config -name eth_test -set build-config release
set lwip_xil_path "./xsct_ws/ethernet_test_wrapper/microblaze_0/standalone_domain/bsp/microblaze_0/libsrc/lwip211_v1_2/src/contrib/ports/xilinx/"
app config -name eth_test -add compiler-misc "-std=c++17 -fpermissive -Wall -Og \
                                              -DXLWIP_CONFIG_INCLUDE_AXI_ETHERNET_DMA \
                                              -I../../../project \
                                              -I../../../src/cpp/syst_hw \
                                              -I../../../src/cpp/lwip_hw \
                                              -I../../../${lwip_xil_path}/netif"
# by default:_STACK_SIZE=0x400, _HEAP_SIZE=0x800
app config -name eth_test -add linker-misc {-Wl,--defsym,_HEAP_SIZE=0x80000}
# app config -name eth_test -add libraries xil   # (-l for lib of drivers for components from the platform (XSA), linked automatically (-L,-l))
# app config -name eth_test -add libraries lwip4 # (-l for lwIP lib, linked automatically (-L,-l))
#report app configs
app config -name eth_test
app config -name eth_test -get build-config
app config -name eth_test -get compiler-misc
app config -name eth_test -get compiler-optimization
app config -name eth_test -get define-compiler-symbols
app config -name eth_test -get include-path
app config -name eth_test -get libraries
app config -name eth_test -get library-search-path
app config -name eth_test -get linker-misc
app config -name eth_test -get linker-script
app config -name eth_test -get undef-compiler-symbols

#Build the app in 2-pass way
app clean all
app build all

#All listed above LwIP lib parameters are collected as defines in auto-generated header lwipopts.h,
#but there are no means to set TCP_OVERSIZE=1 what is required by LWIP_NETIF_TX_SINGLE_PBUF=1
#(set in lwip_extra_defs.h to exclude TCP packet cutting among few memory allocations for DMA+100GbEth cores proper functioning).
#This leads the first build to error: "LWIP_NETIF_TX_SINGLE_PBUF needs TCP_OVERSIZE enabled to create single-pbuf TCP packets"
#because of auto-generated during it lwipopts.h with TCP_OVERSIZE=0. The snippet below fixes this and runs the build once again.
put ""
put "The build has finished with known error, fixing it in auto-generated lwipopts.h and running the build once again..."
put ""
app clean all
set file_orig  [open ${lwip_xil_path}/include/lwipopts.h       r]
set file_fixed [open ${lwip_xil_path}/include/lwipopts_fixed.h w]
while {[gets $file_orig line] >= 0} {
    set line [string map {"#define TCP_OVERSIZE 0" "#define TCP_OVERSIZE 1 //required by LWIP_NETIF_TX_SINGLE_PBUF=1" } $line]
    puts $file_fixed $line
}
close $file_orig
close $file_fixed
file rename -force ${lwip_xil_path}/include/lwipopts_fixed.h ${lwip_xil_path}/include/lwipopts.h

#As we anyway do 2-pass compilation, replacing the type of dummy Eth core present in the design with one we are going to mimic for LwIP
set file_orig  [open ${lwip_xil_path}/netif/xtopology_g.c       r]
set file_fixed [open ${lwip_xil_path}/netif/xtopology_g_fixed.c w]
while {[gets $file_orig line] >= 0} {
    set line [string map {"xemac_type_xps_emaclite," "xemac_type_axi_ethernet, //Eth core type which we mimic" } $line]
    puts $file_fixed $line
}
close $file_orig
close $file_fixed
file rename -force ${lwip_xil_path}/netif/xtopology_g_fixed.c ${lwip_xil_path}/netif/xtopology_g.c

#Copying LwIP-level driver for Eth core we mimic in order to compile it
file copy ${lwip_xil_path}/netif/xaxiemacif.c ./xsct_ws/eth_test/src/lwip_hw/

app build all

exit
