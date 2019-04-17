======================
 Ceph Storage Cluster
======================

:term:`Ceph Storage Cluster` 는 모든 Ceph 배포의 기본입니다. 
:abbr:`RADOS (신뢰할 수 있는 분산 오브젝트 스토리지)`를 바탕으로, Ceph Storage Cluster 
는 두가지 타입의 데몬으로 구성되어 있습니다. :term:`Ceph OSD Daemon` (OSD) 은 저장소 노드에 
데이터를 object 로 저장합니다; 그리고 :term:`Ceph Monitor` (MON) 는 cluster map 의 
master 복제본을 유지합니다. Ceph Storage Cluster 는 수천개의 스토리지 노드를 포함할 수 
있습니다. 최소한의 시스템은 하나의 Ceph Monitor 와 데이터 레플리케이션을 위한 두개의 Ceph OSD 
Daemon 들이 필요합니다. 

Ceph Filesystem, Ceph Object Storage 그리고 Ceph Block Device 는 Ceph Storage Cluster 
로부터 데이터를 읽거나 쓰게 됩니다.

.. raw:: html

	<style type="text/css">div.body h3{margin:5px 0px 0px 0px;}</style>
	<table cellpadding="10"><colgroup><col width="33%"><col width="33%"><col width="33%"></colgroup><tbody valign="top"><tr><td><h3>Config and Deploy</h3>

Ceph Storage Cluster 에는 꼭 필요한 설정이 존재합니다. 하지만, 대부분의 설정들은 
기본값을 가지고 있습니다. 일반적인 배포시에는 cluster 를 정의하고 monitor 를 부트스트래핑 
하기 위해서 배포 툴을 사용합니다. ``ceph-deploy`` 에 대한 자세한 정보는 `Deployment`_ 
섹션을 참고하세요.

.. toctree::
	:maxdepth: 2

	Configuration <configuration/index>
	Deployment <deployment/index>

.. raw:: html 

	</td><td><h3>Operations</h3>

Ceph Storage Cluster 를 배포하고 나면, 이제 여러분은 클러스터에 대한 작업들을 수행할 
수 있습니다.

.. toctree::
	:maxdepth: 2
	
	
	Operations <operations/index>

.. toctree::
	:maxdepth: 1

	Man Pages <man/index>


.. toctree:: 
	:hidden:
	
	troubleshooting/index

.. raw:: html 

	</td><td><h3>APIs</h3>

대부분의 Ceph 사용자들은 `Ceph Block Devices`_, `Ceph Object Storage`_ 혹은 `Ceph Filesystem`_ 
을 사용합니다. Ceph Storage Cluster 에 직접적으로 통신할 수 있는 어플리케이션을 여러분이 개발하는 것 또한 
가능합니다.

.. toctree::
	:maxdepth: 2

	APIs <api/index>
	
.. raw:: html

	</td></tr></tbody></table>

.. _Ceph Block Devices: ../rbd/
.. _Ceph Filesystem: ../cephfs/
.. _Ceph Object Storage: ../radosgw/
.. _Deployment: ../rados/deployment/
