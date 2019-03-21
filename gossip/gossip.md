{layout="01 Main Title - Consul"}

# What's new in Terraform 0.12

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
* Cornel Univerisity
* 2002

<!--
-->

---
# Problems with SWIM **TODO**

* Much of the process is based on a fail-stop process rather than byzantine failure
* This means that the process under suspicion might just be running slow or it might be suffering temporal failure
* It also means that the probing service could be spreading false rumors like the traitor in the byzantine generals problem, it might be the underlying problem

1
2
4
8

number of rounds = O(log n)
log(64) / log(2)
1.80617997398 /
0.301029995664