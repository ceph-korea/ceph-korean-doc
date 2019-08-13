========================
Create a Ceph filesystem
========================

Creating pools
==============

A Ceph filesystem requires at least two RADOS pools, one for data and one for metadata.
When configuring these pools, you might consider:

- Using a higher replication level for the metadata pool, as any data loss in
  this pool can render the whole filesystem inaccessible.
- Using lower-latency storage such as SSDs for the metadata pool, as this will
  directly affect the observed latency of filesystem operations on clients.
- The data pool used to create the file system is the "default" data pool and
  the location for storing all inode backtrace information, used for hard link
  management and disaster recovery. For this reason, all inodes created in
  CephFS have at least one object in the default data pool. If erasure-coded
  pools are planned for the file system, it is usually better to use a
  replicated pool for the default data pool to improve small-object write and
  read performance for updating backtraces. Separately, another erasure-coded
  data pool can be added (see also :ref:`ecpool`) that can be used on an entire
  hierarchy of directories and files (see also :ref:`file-layouts`).

Refer to :doc:`/rados/operations/pools` to learn more about managing pools.  For
example, to create two pools with default settings for use with a filesystem, you
might run the following commands:

.. code:: bash

    $ ceph osd pool create cephfs_data <pg_num>
    $ ceph osd pool create cephfs_metadata <pg_num>

Generally, the metadata pool will have at most a few gigabytes of data. For
this reason, a smaller PG count is usually recommended. 64 or 128 is commonly
used in practice for large clusters.


Creating a filesystem
=====================

Once the pools are created, you may enable the filesystem using the ``fs new`` command:

.. code:: bash

    $ ceph fs new <fs_name> <metadata> <data>

For example:

.. code:: bash

    $ ceph fs new cephfs cephfs_metadata cephfs_data
    $ ceph fs ls
    name: cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]

Once a filesystem has been created, your MDS(s) will be able to enter
an *active* state.  For example, in a single MDS system:

.. code:: bash

    $ ceph mds stat
    cephfs-1/1/1 up {0=a=up:active}

Once the filesystem is created and the MDS is active, you are ready to mount
the filesystem.  If you have created more than one filesystem, you will
choose which to use when mounting.

	- `Mount CephFS`_
	- `Mount CephFS as FUSE`_

.. _Mount CephFS: ../../cephfs/kernel
.. _Mount CephFS as FUSE: ../../cephfs/fuse

If you have created more than one filesystem, and a client does not
specify a filesystem when mounting, you can control which filesystem
they will see by using the `ceph fs set-default` command.

Using Erasure Coded pools with CephFS
=====================================

You may use Erasure Coded pools as CephFS data pools as long as they have overwrites enabled, which is done as follows:

.. code:: bash

    ceph osd pool set my_ec_pool allow_ec_overwrites true
    
Note that EC overwrites are only supported when using OSDS with the BlueStore backend.

You may not use Erasure Coded pools as CephFS metadata pools, because CephFS metadata is stored using RADOS *OMAP* data structures, which EC pools cannot store.

