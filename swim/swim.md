{layout="01 Main Title - Consul"}

# From the first photocopy to modern failure detection in distributed systems

## Nic Jackson

<!--
From the first photocopy to modern failure detection in distributed systems


Distributed systems are not a new problem, for as long as there have been n+1 computers in a network, the problem of managing membership in a group and detecting failure has existed.  Many of the algorithms we use in today's systems to solve this problem are over 30 years old, and in this talk, we will look at how an algorithm for email replication by a photocopier company, has morphed into SWIM, used to manage group membership and failure detection in modern distributed systems.


Takeaways:

Introduction to Gossip and epidemic rumor spreading

Deep dive into SWIM which uses Gossip for failure detection in distributed systems

Investigation of Lifeguard which builds on SWIM adding many improvements
-->

---
{layout="14 Title at Top"}

## What do photocopies have to do with anything?

<!--
This a little misleading I have to admit, but it does relate to the a certain company who invented the photocopier.  Xerox, you might be aware that Xerox actually founded quite a bit of the tech which we use today, anyone use a mouse on a daily basis?
Basically in the 1980s Xerox was really interested in solving the future of business problems.  Email was one of these problems and they soon discovered that if you want reliability and the to be able to reach multiple users which are geo-distributed you needed more than one server.
So Xerox soon find out that it is not so easy replicating select information across a number of servers without sending a full replica. Multicast was an initial solution however this had problems with networking, especially on the slow an unreliable links of the day.  They tried using anti-entropy where a server would contact another server and sync it's data but again this was problematic.
-->

---
{layout="14 Title at Top"}

## Epidemic Algorithms for Replicated Database Maintenance

**IMAGE OF PAPER**

<!--
This led to a seminal paper Epidemic Algorithms for Replicated Database Maintenance. As the title suggests the motivation behind the paper was how to efficiently replicate the data in a database which is located at a number of sites.  The paper also states that the design of the algorithims must be efficient and that the must be able to scale gracefully.
-->

---
{layout="14 Title at Top"}

## The methods analysed

* Direct mail
* Anti-entropy
* Rumor mongering

<!--
There were three methods analysed in this paper
* direct mail where each new update is immediately mailed from the entry site to all other sites, this proved reasonably efficient but not completely reliable since sites did not necessarily know every other site.
* Anti-entropy, every site regularly chooses another site at random and by exchanging database contents it can reconcile the differences between the two. Anti-entropy was reliable but was slow and could not be used so frequently, this meant that data would propagate slowly.
* Rumor mongering, when a site receives a new update it treats it like a hot rumor, it picks another site at random and shares this rumor with it, once the site has tried to share a rumor with a number of sites which already have heard the rumor it assumes the data has been propagated and stops sending.
-->

---
{layout="14 Title at Top"}

## Legacy of epidemic propagation

* Worked well for 3 machines in 1989
* Still working for 55 machines in 2002
* Not beaten yet at 5000 machines in 2019

<!--
As it turns out the concept of Epidemic propagation of data in distributed systems was incredibly fast and efficient, to the extent that the original concept which was designed for a huge network of machines, say 3 or so, it scaled well the huge 55 machines which defined the test group for the Das Gupta Swim paper and with a little modification as proposed by the Lifeguard paper scales in excess of 5000 nodes.  It is this Swim protocol that we we are going to be concentrating on today however before we look at how swim works we need to understand Gossip.
-->

---
{layout="14 Title at Top"}

## What is Gossip?

<!--
The concept of gossip communication in computer science is based on real gossiping among humans.  Due to the fact that a biological virus can be spread in the same way as gossip spreads in human communities, this class of protocols is many times epidemic protocols instead of gossip protocols.
Let's see how this works.
-->

---
{layout="14 Title at Top"}

## How Gossip works

* All nodes in a cluster operate in synchronous rounds
* It is assumed that each node knows the other nodes

<!--
-->

---
{layout="14 Title at Top"}

## How Gossip works

**ROUND 1 IMAGE**

<!--
In order for an informed node to spread its message it picks another node at random, it then distributes the message to that node
-->

---
{layout="14 Title at Top"}

## How Gossip works

**ROUND 2 IMAGE**

<!--
In the next round we have two informed nodes, they both pick a node at random
-->

---
{layout="14 Title at Top"}

## How Gossip works

**ROUND 3 IMAGE**

<!--
In the next round we have 4 informed nodes, they all pick a node at random, at the end of this round we can see that now all the nodes are informed of the message.
-->

---
{layout="14 Title at Top"}

## How Gossip works

* Number of rounds required to spread a rumor = O(log n)
<!--
We can now state that the number of rounds required to spread a rumor is O(log n)
-->

---
{layout="14 Title at Top"}

## How Gossip works

* log(8) / log(2)  = 3
* 1.80617997398 / 0.301029995664 = 3

<!--
Mathematically that is log(8) or the logarithm for the number of nodes divided by the logarithm base which is 2 because we are reducing the number of uniformed nodes by half in each round.  So with constant probability the best we can do is to spread our rumor between 8 nodes in 3 rounds.  In reality we are not going to achieve constant probability but even if we end up with extra rounds epidemic rumor spreading is terrifically efficient.
-->

---
{layout="14 Title at Top"}

# DEMO

Rules:
1 When you receive the rumor you are going to tell 1 person at random near by that rumor (behind, in front, left, right)
1 Once you have passed the rumor repeat step 1
1 If the person you tell the rumor to has already heard it stop and raise your hand

<!--
Let's try a little experiment, and we are not going to use code, let's see how fast we can spread an epidemic rumor using you the audience.
This is not going to be truly random as it is not going to be possible for you to choose anyone in the audience at random, you are restricted by your locality.
To speed things up I am going to head to different points in the room and seed the rumor
Ok, that might not have been a true example of the protocol but I think we can see just how fast we have been able to spread the rumor, now we understand gossip let's see how it is used in SWIM protocol for managing group membership in a cluster of computers
-->

---
{layout="14 Title at Top"}

# SWIM - Scalable Weakly Consistent Infection-style Process Group Membership

<!--
-->

---
{layout="14 Title at Top"}

## SWIM - Scalable Weakly Consistent Infection-style Process Group Membership

* Abhinandas Das, Idranil Gupta, Ashish Motivala
* Cornel University
* 2002

<!--
This paper came out in 2002 from research at Cornell University, the concept was that a methods was needed to maintain a member list of distributed applications in order for them to communicate.
-->

---
{layout="14 Title at Top"}

## Why was SWIM needed?

* network load which grows quaderatically with group size
* compromised response times
* false positive frequency with relation to detecting process crashes

<!--
The need for such a protocol was based on the facts that traditional heart-beating protocols fail either because of the network load which grows quaderatically with group size, response times which are compromised, or false positive frequency with relation to detecting process crashes.
-->

---
{layout="14 Title at Top"}

## Why was SWIM needed?

* network load which grows quaderatically with group size
* compromised response times
* **false positive frequency with relation to detecting *process crashes***

<!--
I would like you to take special note of the following point, specifically, the phrase process crashes, we are going to come back to that
-->

---
{layout="14 Title at Top"}

## Problems with traditional heart-beating

* Sending all heart beats to a central server can cause overload
* Sending heartbeats to all members either through Gossip or Multicast leads to high network load, this grows quadratically with group size O(n<sup>2</sup>) e.g. 4,9,16,25,36

<!--
When the authors of the SWIM paper first looked at failure detection they looked at two traditional methods of heartbeating.
The first was where all the nodes send a heartbeat to a central server, this suffered from the problem that with a large number of nodes the hearbeats could cause the central server to overload then therefore the failure detection to be unreliable.  The other process was to use a multi-cast approach by either sending a multi-case network message or by distributing hearbeats via Gossip.  In both of these instances the drawback was increased network load.  The growth of this is quaderatic, or when you double your input your output will be four times as large.
-->

---
{layout="14 Title at Top"}

## Properties of SWIM

* Constant load per message group
* Process failure detected in constant time
* Infection-style (Gossip) process for membership updates

<!--

-->

---
{layout="14 Title at Top"}

## Failure detection with SWIM

* Distributed failure detection
* No single point of failure
* Every node probes another node at random
* With constant probability, every node is probed
* Once failure is confirmed nodes gossip this failure

<!--
SWIM takes a different approach for faiure detection, a single node
-->

---
{layout="14 Title at Top"}

## Failure detection with SWIM

**IMAGE PROBE - Ping Ack**

<!--
Each node chooses another node at random and pings it, in the instance that the node is heathy then it expects to receive an Ack back
-->

---
{layout="14 Title at Top"}

## Failure detection with SWIM

**IMAGE PROBE - Buddy**

<!--
If no ACK is returned within the timeout then the probing node, selects a number of other nodes and asks them to probe the same node and send the Acks back to it.  The reason the acks are not sent directly back to the probing node is to cater for the fact that the network link between the probing node and the probed might not be stable and the Ack might just have got lost. In the instance that no probe is returned then the probed node will gossip that the has been a failure.
-->

---
{layout="14 Title at Top"}

## Failure detection with SWIM

**IMAGE PROBE - Gossip overload**

<!--
One of the problems with this approach is that it is likely that another node will choose to probe the same faulty node and when failure is detected it will also start to Gossip about this failure which can cause an increase in network traffic.
-->

---
{layout="14 Title at Top"}

## Gray failures

* Much of the process is based on a fail-stop process rather than byzantine failure
* This means that the process under suspicion might just be running slow or it might be suffering temporal failure
* It also means that the probing service could be spreading false rumors like the traitor in the byzantine generals problem, it might be the underlying problem
 
<!--
Another problem with the basic SWIM process is basic SWIM protocol assumes that failure can only take the form of fail-stop for the probed service, what if it is actually the probe which has a problem and is not the probed.
-->

---
{layout="14 Title at Top"}

## Byzantine failure

* Could be a flakey node
* Temporary network problem

<!--
Byzantine failure is not a fail-stop situation
-->

---
{layout="14 Title at Top"}

## Byzantine failure

**BYZANTINE GENERALS IMAGE**

* Two armies A-B
* Need to decide to attack or retreat
* If they both agree on an approach they win
* If they disagree then they loose

<!--
The term comes from the byzantine generals problem called the two generals problem, two generals in the field are fighting a common enemy.  They need to decide whether to attack or to retrieat.  If they both decide to attack then their cumalitve force will overcome the enemy and they will win.  Should they decide the enemy is stronger then both of them and decide to retreat then they live to fight another day.  The problem comes with if they disagree, if one general decides to attack and the other decides to retreat then one of the armies will be wiped out.
-->

---
{layout="14 Title at Top"}

## Gray Failure: The Achilles' Heel of Cloud-Scale Systems

* Paper from Microsoft research
* "the major availability breakdowns and performance anomalies we see in cloud environments tend to be caused by subtle underlyint faults, i.e. gray failures rather than fail-stop failure"

<!--
As it turns out Gray Failure in cloud based systems is not so uncommon, in a paper by microsoft research they state that "the major availability breakdowns and performance anomalies we see in cloud environments tend to be caused by subtle underlyint faults, i.e. gray failures rather than fail-stop failure".
-->

---
{layout="14 Title at Top"}

## Gray Failure: The Achilles' Heel of Cloud-Scale Systems

* Performance degredation
* Random packet loss
* Flaky I/O
* Memory pressure
* Non-fatal exceptions

<!--
The paper states that many of the causes of gray failure are...
-->

---
{layout="14 Title at Top"}

## Gray Failure: Byzantine fault tollerance

**BFT diagram**

<!--
One of the discussed approaches to managing this failure is to apply Byzantine fault tollerance. Moving back to our two generals problem the solution was that each of the liutenants would check the double check the order with the other liutenants.  In this instance should one of the lieutenants be a traitor or should the general themself be a traitor then they would still be able to come to consensus.
-->

---
{layout="14 Title at Top"}

## Gray Failure: Byzantine fault tollerance

* Complex to implement
* High network overhead
* Not proven in production

<!--
Unfortunately BFT is not the solution to our problem the paper goes on to state that BZT is...
-->

---
{layout="14 Title at Top"}

## Gray Failure: SWIM, suspicion

**SUSPICION DIAGRAM**

<!--
The SWIM paper goes on to describe an approach to handle a situation where it may not be the probed node which is faulty but the probing node.  This mechanisim is called suspicion.  Rather than immediately mark a node as failed, instead the probing node gossips that a node is suspected to have failed. Any node can refute this suspicion and because the suspicion is Gossiped even the node under question will eventually receive this message and can refute the allogation.
-->

---
{layout="14 Title at Top"}

## SWIM at scale

* SWIM only tested on 55 nodes
* When the probing node raises a suspicion message and is running slow it might not get the refutation message

<!--
In the original paper SWIM was only tested on 55 nodes, at the time this was a large number of computers for the Computer science department to get its hands on. When Consul implemented SWIM our users were running thousands of nodes, our users reported that when a number of nodes were running slow there could be a high degree of flapping in the system
-->

---
{layout="14 Title at Top"}

## Lifeguard - beyond SWIM

* Dynamic fault detector timeouts - "Self Awareness"
* Dynamic suspicion timeouts - "Dogpile"
* Refutation timeouts - "Buddy System"

<!--
HashiCorp research looked at this problem and published a paper suggesting 3 modifications to the SWIM protocol.  These are...
-->

---
{layout="14 Title at Top"}

## Lifeguard - Dynamic fault detection

* When no Acks are received from probes, assume fault is probing node
* Timeouts relaxed
  * Probe interval modified
  * Probe timeout modified
* Implement NACKs when asking other nodes to confirm failure

<!--
The first part of the lifeguard implementation concerns dynamic fault detection.  This allows the probing node to assume that it might be at fault and can modifiy its behaviour accordingly. When a node sends out probes and does not receive a response for more than one probe two, failure cases could be present.  The first is that the system or the network could be experiencing widespread problems, the second and more probable is that the node itself is experiencing transient problems.  When this situation occurs the intervals for probing are modified to slow things down, the timeout for expecting probe responses is also incrased.
-->

---
{layout="14 Title at Top"}

## Lifeguard - Dynamic fault detection

**IMAGE SHOWING NACKS**

<!--
In addition to this NACKs are implemented, if A requests that B and C probe D because it has not received an Ack from its own probe then previously B and C would only send a response when the Ack had been received from D.  Lifeguard implements the concept of a NACK, when B and C do not receive an Ack they now send a NACK back to A.  Should A neither receive an Ack or a Nack before the timeout period expires then it can safely assume that the issue is with itself and not with D.
-->

---
{layout="14 Title at Top"}

## Lifeguard - Dynamic suspicion timeouts

* When suspicion messages are received from other nodes regarding a node we already suspect, reduce suspicion timeout

<!--
Assuming D is actually faulty then other nodes will also start to choose it in a round and eventually A will start to receive their suspicion messages.  Everytime a message is received we reduce the suspicion timeout as the likely hood increases that D is in fact broken.
-->

---
{layout="14 Title at Top"}

## Lifeguard - Dynamic suspicion timeouts

**TIMEOUT REDUCTION CHART**

<!--
The reduction is based on a logarithmic scale, the first reduction is the longest and it decreses with smaller ammounts with every recorded suspicion
-->


---
{layout="14 Title at Top"}

## Lifeguard - More timely refutation

<!--
Need some text here
-->

---
{layout="14 Title at Top"}

## Lifeguard - Results

* 7% increse in latency under normal conditions
* 12% increase in messages
* 8% total reduction in network traffic due to piggy backed messages
* 98% reduction in false positives

<!--
The results from the paper have been incredibly positive, a combination of all three of the additions have resulted in a 98% reduction in false positives and an 8% reduction in total network traffic.  This does come at some cost as the latency to detect a failure has also increased by 7% but we feel this has been worth it.  We actually implemented the findings into Consul over 12 months ago so anyone using a Consul version greater than 0.7 will already be taking advantage of this.  In addition to this the paper has been presented succesfully by Jon Currie our Research Director at ... last summer and is currently in the final stages of Academic review.
-->

---
{layout="14 Title at Top"}

## Lifeguard - References

<!--
If you would like to dig in a little deeper and read some of the papers from which I based this talk you can find the references above.  Some of this can make pretty heavy reading but I strongly encourage you to percevier.
-->


---
{layout="14 Title at Top"}

## Lifeguard - Summary

<!--
Distributed systems are growing in their popularity and the number of nodes which we have in our clusters is also increasing.  I personally find it facinating to dig into the protocols and algorithims which are powering our systems.  I also find it incredibly interesting that a simple protocol designed by a photocopier company for email replication still holds and powers many of our distributed systems 30 years later.
-->
