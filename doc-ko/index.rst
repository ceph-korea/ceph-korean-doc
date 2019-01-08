=========================================
 Ceph 에 오신 것을 환영합니다.
=========================================

Ceph 은 **object, block, file 스토리지를 하나의 통합된 환경으로 제공하는** 유일한 시스템입니다.

.. raw:: html

	<style type="text/css">div.body h3{margin:5px 0px 0px 0px;}</style>
	<table cellpadding="10"><colgroup><col width="33%"><col width="33%"><col width="33%"></colgroup><tbody valign="top"><tr><td><h3>Ceph Object Store</h3>

- RESTful Interface
- S3- and Swift-compliant APIs
- S3-style subdomains
- Unified S3/Swift namespace
- User management
- Usage tracking
- Striped objects
- Cloud solution integration
- Multi-site deployment
- Multi-site replication

.. raw:: html

	</td><td><h3>Ceph Block Device</h3>


- Thin-provisioned
- Images up to 16 exabytes
- Configurable striping
- In-memory caching
- Snapshots
- Copy-on-write cloning
- Kernel driver support
- KVM/libvirt support
- Back-end for cloud solutions
- Incremental backup
- Disaster recovery (multisite asynchronous replication)

.. raw:: html

	</td><td><h3>Ceph Filesystem</h3>

- POSIX-compliant semantics
- Separates metadata from data
- Dynamic rebalancing
- Subdirectory snapshots
- Configurable striping
- Kernel driver support
- FUSE support
- NFS/CIFS deployable
- Use with Hadoop (replace HDFS)

.. raw:: html

	</td></tr><tr><td>

더 많은 정보는 `Ceph Object Store`_ 를 참고하세요.

.. raw:: html

	</td><td>

더 많은 정보는 `Ceph Block Device`_ 를 참고하세요.

.. raw:: html

	</td><td>

더 많은 정보는 `Ceph Filesystem`_ 를 참고하세요.

.. raw::	html

	</td></tr></tbody></table>

Ceph 은 높은 신뢰성을 가지고, 관리하기 쉬우며, 무료로 제공됩니다. Ceph 의 힘으로 당신의 회사의 
IT 인프라스트럭쳐와 능력을 방대한 양의 데이터를 다루도록 바꿀 수 있습니다. 처음 시작해보려면, 
`Getting Started`_ 가이드를 참고하세요. Ceph 에 대한 더 많은 정보를 원한다면, `Architecture`_ 
섹션을 참고합니다.

.. _Ceph Object Store: radosgw
.. _Ceph Block Device: rbd
.. _Ceph Filesystem: cephfs
.. _Getting Started: start
.. _Architecture: architecture

.. toctree::
   :maxdepth: 3
   :hidden:

   start/intro
   start/index
   install/index
   start/kube-helm
   rados/index
   cephfs/index
   rbd/index
   radosgw/index
   mgr/index
   api/index
   architecture
   Development <dev/index>
   ceph-volume/index
   releases/index
   Glossary <glossary>
