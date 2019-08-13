===================
 CephFS Quick Start
===================

To use the :term:`CephFS` Quick Start guide, you must have executed the
procedures in the `Storage Cluster Quick Start`_ guide first. Execute this quick
start on the Admin Host.

Prerequisites
=============

#. Verify that you have an appropriate version of the Linux kernel. 
   See `OS Recommendations`_ for details. ::
   
	lsb_release -a
	uname -r

#. On the admin node, use ``ceph-deploy`` to install Ceph on your 
   ``ceph-client`` node. ::

	ceph-deploy install ceph-client


#. Ensure that the :term:`Ceph Storage Cluster` is running and in an ``active +
   clean``  state. Also, ensure that you have at least one :term:`Ceph Metadata
   Server` running. :: 

	ceph -s [-m {monitor-ip-address}] [-k {path/to/ceph.client.admin.keyring}]


Create a Filesystem
===================

You have already created an MDS (`Storage Cluster Quick Start`_) but it will not
become active until you create some pools and a filesystem.  See :doc:`/cephfs/createfs`.

::

    ceph osd pool create cephfs_data <pg_num>
    ceph osd pool create cephfs_metadata <pg_num>
    ceph fs new <fs_name> cephfs_metadata cephfs_data


Create a Secret File
====================

The Ceph Storage Cluster runs with authentication turned on by default. 
You should have a file containing the secret key (i.e., not the keyring 
itself). To obtain the secret key for a particular user, perform the 
following procedure: 

#. Identify a key for a user within a keyring file. For example:: 

	cat ceph.client.admin.keyring

#. Copy the key of the user who will be using the mounted CephFS filesystem.
   It should look something like this:: 
	
	[client.admin]
	   key = AQCj2YpRiAe6CxAA7/ETt7Hcl9IyxyYciVs47w==

#. Open a text editor. 

#. Paste the key into an empty file. It should look something like this::

	AQCj2YpRiAe6CxAA7/ETt7Hcl9IyxyYciVs47w==

#. Save the file with the user ``name`` as an attribute 
   (e.g., ``admin.secret``).

#. Ensure the file permissions are appropriate for the user, but not
   visible to other users. 


Kernel Driver
=============

Mount CephFS as a kernel driver. ::

	sudo mkdir /mnt/mycephfs
	sudo mount -t ceph {ip-address-of-monitor}:6789:/ /mnt/mycephfs

The Ceph Storage Cluster uses authentication by default. Specify a user ``name``
and the ``secretfile`` you created  in the `Create a Secret File`_ section. For
example::

	sudo mount -t ceph 192.168.0.1:6789:/ /mnt/mycephfs -o name=admin,secretfile=admin.secret


.. note:: Mount the CephFS filesystem on the admin node,
   not the server node. See `FAQ`_ for details.


Filesystem in User Space (FUSE)
===============================

Mount CephFS as a Filesystem in User Space (FUSE). ::

	sudo mkdir ~/mycephfs
	sudo ceph-fuse -m {ip-address-of-monitor}:6789 ~/mycephfs

The Ceph Storage Cluster uses authentication by default. Specify a keyring if it
is not in the default location (i.e., ``/etc/ceph``)::

	sudo ceph-fuse -k ./ceph.client.admin.keyring -m 192.168.0.1:6789 ~/mycephfs


Additional Information
======================

See `CephFS`_ for additional information. CephFS is not quite as stable
as the Ceph Block Device and Ceph Object Storage. See `Troubleshooting`_
if you encounter trouble. 

.. _Storage Cluster Quick Start: ../quick-ceph-deploy
.. _CephFS: ../../cephfs/
.. _FAQ: http://wiki.ceph.com/How_Can_I_Give_Ceph_a_Try
.. _Troubleshooting: ../../cephfs/troubleshooting
.. _OS Recommendations: ../os-recommendations
