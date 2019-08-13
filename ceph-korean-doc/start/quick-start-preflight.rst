=====================
 Preflight Checklist
=====================

The ``ceph-deploy`` tool operates out of a directory on an admin
:term:`node`.  Any host with network connectivity and a modern python
environment and ssh (such as Linux) should work.

In the descriptions below, :term:`Node` refers to a single machine.

.. include:: quick-common.rst


Ceph-deploy Setup
=================

Add Ceph repositories to the ``ceph-deploy`` admin node. Then, install
``ceph-deploy``.

Debian/Ubuntu
-------------

For Debian and Ubuntu distributions, perform the following steps:

#. Add the release key::

	wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

#. Add the Ceph packages to your repository. Use the command below and
   replace ``{ceph-stable-release}`` with a stable Ceph release (e.g.,
   ``luminous``.)  For example::

	echo deb https://download.ceph.com/debian-{ceph-stable-release}/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

#. Update your repository and install ``ceph-deploy``::

	sudo apt update
	sudo apt install ceph-deploy

.. note:: You can also use the EU mirror eu.ceph.com for downloading your packages by replacing ``https://ceph.com/`` by ``http://eu.ceph.com/``


RHEL/CentOS
-----------

For CentOS 7, perform the following steps:

#. On Red Hat Enterprise Linux 7, register the target machine with
   ``subscription-manager``, verify your subscriptions, and enable the
   "Extras" repository for package dependencies. For example::

        sudo subscription-manager repos --enable=rhel-7-server-extras-rpms

#. Install and enable the Extra Packages for Enterprise Linux (EPEL)
   repository::

        sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

   Please see the `EPEL wiki`_ page for more information.

#. Add the Ceph repository to your yum configuration file at ``/etc/yum.repos.d/ceph.repo`` with the following command. Replace  ``{ceph-stable-release}`` with a stable Ceph release (e.g.,
   ``luminous``.)  For example::

     cat << EOM > /etc/yum.repos.d/ceph.repo
     [ceph-noarch]
     name=Ceph noarch packages
     baseurl=https://download.ceph.com/rpm-{ceph-stable-release}/el7/noarch
     enabled=1
     gpgcheck=1
     type=rpm-md
     gpgkey=https://download.ceph.com/keys/release.asc
     EOM

#. Update your repository and install ``ceph-deploy``::

	sudo yum update
	sudo yum install ceph-deploy

.. note:: You can also use the EU mirror eu.ceph.com for downloading your packages by replacing ``https://ceph.com/`` by ``http://eu.ceph.com/``


openSUSE
--------

The Ceph project does not currently publish release RPMs for openSUSE, but 
a stable version of Ceph is included in the default update repository, so
installing it is just a matter of::

	sudo zypper install ceph
	sudo zypper install ceph-deploy

If the distro version is out-of-date, open a bug at
https://bugzilla.opensuse.org/index.cgi and possibly try your luck with one of
the following repositories:

#. Hammer::

        https://software.opensuse.org/download.html?project=filesystems%3Aceph%3Ahammer&package=ceph

#. Jewel::

        https://software.opensuse.org/download.html?project=filesystems%3Aceph%3Ajewel&package=ceph


Ceph Node Setup
===============

The admin node must have password-less SSH access to Ceph nodes.
When ceph-deploy logs in to a Ceph node as a user, that particular
user must have passwordless ``sudo`` privileges.


Install NTP
-----------

We recommend installing NTP on Ceph nodes (especially on Ceph Monitor nodes) to
prevent issues arising from clock drift. See `Clock`_ for details.

On CentOS / RHEL, execute::

	sudo yum install ntp ntpdate ntp-doc

On Debian / Ubuntu, execute::

	sudo apt install ntp

Ensure that you enable the NTP service. Ensure that each Ceph Node uses the
same NTP time server. See `NTP`_ for details.


Install SSH Server
------------------

For **ALL** Ceph Nodes perform the following steps:

#. Install an SSH server (if necessary) on each Ceph Node::

	sudo apt install openssh-server

   or::

	sudo yum install openssh-server


#. Ensure the SSH server is running on **ALL** Ceph Nodes.


Create a Ceph Deploy User
-------------------------

The ``ceph-deploy`` utility must login to a Ceph node as a user
that has passwordless ``sudo`` privileges, because it needs to install
software and configuration files without prompting for passwords.

Recent versions of ``ceph-deploy`` support a ``--username`` option so you can
specify any user that has password-less ``sudo`` (including ``root``, although
this is **NOT** recommended). To use ``ceph-deploy --username {username}``, the
user you specify must have password-less SSH access to the Ceph node, as
``ceph-deploy`` will not prompt you for a password.

We recommend creating a specific user for ``ceph-deploy`` on **ALL** Ceph nodes
in the cluster. Please do **NOT** use "ceph" as the user name. A uniform user
name across the cluster may improve ease of use (not required), but you should
avoid obvious user names, because hackers typically use them with brute force
hacks (e.g., ``root``,  ``admin``, ``{productname}``). The following procedure,
substituting  ``{username}`` for the user name you define, describes how to
create a user with passwordless ``sudo``.

.. note:: Starting with the :ref:`Infernalis release <infernalis-release-notes>`, the "ceph" user name is reserved
   for the Ceph daemons. If the "ceph" user already exists on the Ceph nodes,
   removing the user must be done before attempting an upgrade.

#. Create a new user on each Ceph Node. ::

	ssh user@ceph-server
	sudo useradd -d /home/{username} -m {username}
	sudo passwd {username}

#. For the new user you added to each Ceph node, ensure that the user has
   ``sudo`` privileges. ::

	echo "{username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/{username}
	sudo chmod 0440 /etc/sudoers.d/{username}


Enable Password-less SSH
------------------------

Since ``ceph-deploy`` will not prompt for a password, you must generate
SSH keys on the admin node and distribute the public key to each Ceph
node. ``ceph-deploy`` will attempt to generate the SSH keys for initial
monitors.

#. Generate the SSH keys, but do not use ``sudo`` or the
   ``root`` user. Leave the passphrase empty::

	ssh-keygen

	Generating public/private key pair.
	Enter file in which to save the key (/ceph-admin/.ssh/id_rsa):
	Enter passphrase (empty for no passphrase):
	Enter same passphrase again:
	Your identification has been saved in /ceph-admin/.ssh/id_rsa.
	Your public key has been saved in /ceph-admin/.ssh/id_rsa.pub.

#. Copy the key to each Ceph Node, replacing ``{username}`` with the user name
   you created with `Create a Ceph Deploy User`_. ::

	ssh-copy-id {username}@node1
	ssh-copy-id {username}@node2
	ssh-copy-id {username}@node3

#. (Recommended) Modify the ``~/.ssh/config`` file of your ``ceph-deploy``
   admin node so that ``ceph-deploy`` can log in to Ceph nodes as the user you
   created without requiring you to specify ``--username {username}`` each
   time you execute ``ceph-deploy``. This has the added benefit of streamlining
   ``ssh`` and ``scp`` usage. Replace ``{username}`` with the user name you
   created::

	Host node1
	   Hostname node1
	   User {username}
	Host node2
	   Hostname node2
	   User {username}
	Host node3
	   Hostname node3
	   User {username}


Enable Networking On Bootup
---------------------------

Ceph OSDs peer with each other and report to Ceph Monitors over the network.
If networking is ``off`` by default, the Ceph cluster cannot come online
during bootup until you enable networking.

The default configuration on some distributions (e.g., CentOS) has the
networking interface(s) off by default. Ensure that, during boot up, your
network interface(s) turn(s) on so that your Ceph daemons can communicate over
the network. For example, on Red Hat and CentOS, navigate to
``/etc/sysconfig/network-scripts`` and ensure that the  ``ifcfg-{iface}`` file
has ``ONBOOT`` set to ``yes``.


Ensure Connectivity
-------------------

Ensure connectivity using ``ping`` with short hostnames (``hostname -s``).
Address hostname resolution issues as necessary.

.. note:: Hostnames should resolve to a network IP address, not to the
   loopback IP address (e.g., hostnames should resolve to an IP address other
   than ``127.0.0.1``). If you use your admin node as a Ceph node, you
   should also ensure that it resolves to its hostname and IP address
   (i.e., not its loopback IP address).


Open Required Ports
-------------------

Ceph Monitors communicate using port ``6789`` by default. Ceph OSDs communicate
in a port range of ``6800:7300`` by default. See the `Network Configuration
Reference`_ for details. Ceph OSDs can use multiple network connections to
communicate with clients, monitors, other OSDs for replication, and other OSDs
for heartbeats.

On some distributions (e.g., RHEL), the default firewall configuration is fairly
strict. You may need to adjust your firewall settings allow inbound requests so
that clients in your network can communicate with daemons on your Ceph nodes.

For ``firewalld`` on RHEL 7, add the ``ceph-mon`` service for Ceph Monitor
nodes and the ``ceph`` service for Ceph OSDs and MDSs to the public zone and
ensure that you make the settings permanent so that they are enabled on reboot.

For example, on monitors::

	sudo firewall-cmd --zone=public --add-service=ceph-mon --permanent

and on OSDs and MDSs::

	sudo firewall-cmd --zone=public --add-service=ceph --permanent

Once you have finished configuring firewalld with the ``--permanent`` flag, you can make the changes live immediately without rebooting::

	sudo firewall-cmd --reload

For ``iptables``, add port ``6789`` for Ceph Monitors and ports ``6800:7300``
for Ceph OSDs. For example::

	sudo iptables -A INPUT -i {iface} -p tcp -s {ip-address}/{netmask} --dport 6789 -j ACCEPT

Once you have finished configuring ``iptables``, ensure that you make the
changes persistent on each node so that they will be in effect when your nodes
reboot. For example::

	/sbin/service iptables save

TTY
---

On CentOS and RHEL, you may receive an error while trying to execute
``ceph-deploy`` commands. If ``requiretty`` is set by default on your Ceph
nodes, disable it by executing ``sudo visudo`` and locate the ``Defaults
requiretty`` setting. Change it to ``Defaults:ceph !requiretty`` or comment it
out to ensure that ``ceph-deploy`` can connect using the user you created with
`Create a Ceph Deploy User`_.

.. note:: If editing, ``/etc/sudoers``, ensure that you use
   ``sudo visudo`` rather than a text editor.


SELinux
-------

On CentOS and RHEL, SELinux is set to ``Enforcing`` by default. To streamline your
installation, we recommend setting SELinux to ``Permissive`` or disabling it
entirely and ensuring that your installation and cluster are working properly
before hardening your configuration. To set SELinux to ``Permissive``, execute the
following::

	sudo setenforce 0

To configure SELinux persistently (recommended if SELinux is an issue), modify
the configuration file at  ``/etc/selinux/config``.


Priorities/Preferences
----------------------

Ensure that your package manager has priority/preferences packages installed and
enabled. On CentOS, you may need to install EPEL. On RHEL, you may need to
enable optional repositories. ::

	sudo yum install yum-plugin-priorities

For example, on RHEL 7 server, execute the following to install
``yum-plugin-priorities`` and enable the  ``rhel-7-server-optional-rpms``
repository::

	sudo yum install yum-plugin-priorities --enablerepo=rhel-7-server-optional-rpms


Summary
=======

This completes the Quick Start Preflight. Proceed to the `Storage Cluster
Quick Start`_.

.. _Storage Cluster Quick Start: ../quick-ceph-deploy
.. _OS Recommendations: ../os-recommendations
.. _Network Configuration Reference: ../../rados/configuration/network-config-ref
.. _Clock: ../../rados/configuration/mon-config-ref#clock
.. _NTP: http://www.ntp.org/
.. _Infernalis release: ../../release-notes/#v9-1-0-infernalis-release-candidate
.. _EPEL wiki: https://fedoraproject.org/wiki/EPEL
