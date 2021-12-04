# "Advanced Topics in IP Networks" 
 M.Sc. course at the Reichman University <br/>
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
2. Run h1-h3 nodes with `xterm` command: <br/><br/>
   ```bash
   xterm h1 h2 h3
   ```
   Now, you will notice 3 new terminal windows, named h1 to h3. <br/><br/>
3. In the terminal window of h2, type: <br/><br/>
   ```bash
   ./start_h2_server.sh
   ```
   That will start the memcached server on h2 and add some entries. <br/><br/>
4. In the terminal window of h3, do the same thing: <br/><br/>
   ```bash
   ./start_h3_server.sh
   ```
   That will also start the memcached server on h3 and add some entries. <br/><br/>
5. In the terminal window of h1, type: <br/><br/>
   ```bash
   ./send_memcached_get.sh 10.0.0.1 key01
   ``` 
   And the result is expected to be the value of key01 in h3. <br/>
   Likewise, requests for other (existing) keys should yield the corresponding values from the corresponding server, based on the policy above. <br/>
   
## References
1. More info about Memcached: <br/>
   A. https://memcached.org/ <br/>
   B. http://www.deepness-lab.org/pubs/networking17_loadbalancing.pdf <br/>
2. Mininet: <br/>
   A. http://mininet.org/walkthrough/  <br/>
3. P4lang Tuturials: <br/>
   A. https://github.com/p4lang/tutorials/ <br/>
   B. http://conferences.sigcomm.org/sigcomm/2018/files/slides/hda/paper_2.2.pdf <br/>
   C. https://opennetworking.org/wp-content/uploads/2020/12/P4_tutorial_01_basics.gslide.pdf <br/>
   D. https://p4.org/p4-spec/docs/P4-16-v1.0.0-spec.pdf <br/>
   E. https://p4.org/p4-spec/docs/P4-16-v1.0.0-spec.html <br/>
