# "Advanced Topics in IP Networks" 
 M.Sc. course at the Reichman University <br/>
 Lecturers and advisors of the cours: <br/>
 Prof. Bremler-Barr Anat <br/>
 Dr. Harchol Yotam <br/>
# p4lang_memcached_load_balancer

## Introduction 
In this assignment, I had to develop a P4 application – a memcached load balancer. <br/>
I was supposed to use the Mininet virtual network to simulate a network that contains two memcached servers and a client host. <br/> 
The network is presented in the following figure: 
<br/><br/>
<img src="/topology.jpg"><br/>

## The Goal
Performing load balancing between the two memcached servers. <br/>
The client h1 (10.0.1.1) sends memcached UDP requests to its default gateway s1 (10.0.0.1). <br/> 
The switch flow table should contain rules that direct the memcached requests to one of the memcached servers h2, h3 (10.0.2.2, 10.0.3.3), each one contains a different set of keys and values. <br/>
In this assignment I had to write a P4 code to direct the incoming memcached requests packets to one of the servers based on the requested key in the UDP packet. <br/>
Specifically, I had to apply the following load balancing policy:  <br/>
Given a key (that we define to always be of length 5 bytes), check the last character of the key. <br/>
If it is an even digit, send the request to h2. If it is an odd digit, send it to h3. If it is not a digit, send it to h2. <br/>
So, for example, a request from h1 to 10.0.0.1, with the key “key01” will go to h3, while requests with the keys “key02” or “other” will go to h2. <br/>
We assume that all the requests have keys of length of exactly 5 bytes and we should not expect or handle other types of requests. <br/>
<br/>
## Installing p4c compiler
p4c is a reference compiler for the P4 programming language. 
It supports both P4-14 and P4-16. My project is in the P4-16 language. <br/>
Please follow the instructions at the `p4lang/p4c` repository at the followd link: <br/>
https://github.com/p4lang/p4c

## Running the project
1. In your shell, go to the directory `/home/p4/tutorials/exercises/memcached`, and then run: <br/><br/>
   ```bash
   make
   ``` 
   That `make` script should start the mininet environment and open the mininet shell. <br/><br/>
   <img src="/examples/mininet.png"><br/><br/>
2. Run h1-h3 nodes with `xterm` command: <br/><br/>
   ```bash
   xterm h1 h2 h3
   ```
   Now, you will notice 3 new terminal windows, named h1 to h3. <br/><br/>
   <img src="/examples/nodes.png"><br/><br/>
3. In the terminal window of h2, type: <br/><br/>
   ```bash
   ./start_h2_server.sh
   ```
   That will start the memcached server on h2 and add some entries. <br/><br/>
   <img src="/examples/node_h2.png"><br/><br/>
4. In the terminal window of h3, do the same thing: <br/><br/>
   ```bash
   ./start_h3_server.sh
   ```
   That will also start the memcached server on h3 and add some entries. <br/><br/>
5. Before we start sending the UDP packets, open a new terminal window and open `wireshark` <br/><br/>
      ```bash
   sudo wireshark
   ```
6. After the `wireshark` window will open, start capturing packets from s1-eth1, and a new window will open <br/><br/>
   <img src="/examples/capture_s1.png"><br/><br/>
7. Now, in the terminal window of h1, type: <br/><br/>
   ```bash
   ./send_memcached_get.sh 10.0.0.1 key01
   ``` 
   And the result is expected to be the value of key01 in h3. <br/><br/>
   <img src="/examples/send_key01.png"><br/><br/>
8. If you go back to the `wireshark` s1-eth1 sniffing window, you will notice the packets you've just sent in the window of h1:  <br/><br/>
   <img src="/examples/send_key01_wireshark.png"><br/><br/>
9. Now stop capturing s1-eth1, and start capturing s1-eth3. <br/>
   Repeat step 7, with any odd key you like "xxxx1-xxxx9" and now you should see the packets in s1-eth3 as well:  <br/><br/>
   <img src="/examples/send_key01_wireshark_eth3.png"><br/><br/>
10. Likewise, requests for other (existing) keys should yield the corresponding values from the corresponding server, based on the policy above. <br/>
    Repeat steps 7 && 9 with new terms:
    - Start capturing s1-eth2 <br/>
    - Send even keys (xxxx0-xxxx8) / other keys which aren't odd keys. <br/>
    You should see in your `wireshark` sniffing window the following results: <br/><br/>
    <img src="/examples/send_key02_other_wireshark_eth2.png"><br/><br/>
11. In order to stop the Mininet, follow the following steps:
   ```bash
   make stop
   make clean
   ``` 
   For your convinience, I have created simple bash script to run those 2 commands together: <br/>
   ```bash
   ./juststopit.sh
   ```
   If you would like to `make` again after ``make stop && make clean`` , you can just ran another simple bash script I have created for you: <br/>
   ```bash
   ./makeagain.sh
   ```
   
## References
1. More info about Memcached: <br/>
   A. https://memcached.org/ <br/>
   B. http://www.deepness-lab.org/pubs/networking17_loadbalancing.pdf <br/>
2. Mininet: <br/>
   A. http://mininet.org/walkthrough/  <br/>
3. P4lang: <br/>
   A. https://github.com/p4lang/tutorials/ <br/>
   B. http://conferences.sigcomm.org/sigcomm/2018/files/slides/hda/paper_2.2.pdf <br/>
   C. https://opennetworking.org/wp-content/uploads/2020/12/P4_tutorial_01_basics.gslide.pdf <br/>
   D. https://p4.org/p4-spec/docs/P4-16-v1.0.0-spec.pdf <br/>
   E. https://p4.org/p4-spec/docs/P4-16-v1.0.0-spec.html <br/>
