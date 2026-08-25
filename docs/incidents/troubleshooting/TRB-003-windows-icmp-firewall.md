================================================================================
TRB-003 — WINDOWS ICMP CONNECTIVITY FAILURE
================================================================================

SYMPTOM
-------

DC01 and WIN01 could communicate with MINT01 and the libvirt gateway,
but could not ping each other.


ENVIRONMENT
-----------

DC01
    192.168.100.20

WIN01
    192.168.100.30

Network
    engineering-lab
    192.168.100.0/24


INITIAL HYPOTHESIS
------------------

Possible Windows firewall or network connectivity problem.


INVESTIGATION
-------------

Both machines:

    - had correct IP addresses
    - had correct subnet mask
    - had correct gateway
    - could reach the libvirt gateway
    - could reach MINT01
    - could not reach the other Windows machine

Both Windows machines reported the network profile as:

    Public

Windows Firewall was enabled.


ROOT CAUSE
----------

Windows Firewall was blocking ICMP Echo Requests on the Windows
network profile.


FIX
---

Allowed ICMP ping / Echo Request through Windows Firewall
on DC01 and WIN01.


VERIFICATION
------------

DC01 → WIN01
    4/4 packets received

WIN01 → DC01
    4/4 packets received

0% packet loss.


LESSON LEARNED
--------------

Successful communication with one VM does not necessarily prove
that communication with another VM is permitted.

Network connectivity and host firewall policy are separate layers.

Windows Firewall can allow or block traffic even when:

    IP addressing is correct
    routing is correct
    the VM network is functioning
