============================
 Installation (ceph-deploy)
============================

.. raw:: html

	<style type="text/css">div.body h3{margin:5px 0px 0px 0px;}</style>
	<table cellpadding="10"><colgroup><col width="33%"><col width="33%"><col width="33%"></colgroup><tbody valign="top"><tr><td><h3>Step 1: Preflight</h3>

:term:`Ceph Client` 와 :term:`Ceph Node` 는 Ceph Storage Cluster 를 구성하기 
전에 몇 가지 기본적인 구성 작업이 필요합니다. Ceph community 에 참여하여 도움을 구할 수 
있습니다.

.. toctree::

   Preflight <quick-start-preflight>

.. raw:: html 

	</td><td><h3>Step 2: Storage Cluster</h3>

일단 여러분이 배포 전 체크리스트를 확인하였다면, 이제 Ceph Storage Cluster 배포를 시작하실 
수 있습니다.

.. toctree::

	Storage Cluster Quick Start <quick-ceph-deploy>


.. raw:: html 

	</td><td><h3>Step 3: Ceph Client(s)</h3>

대부분의 Ceph 유저들은 Ceph Storage Cluster 에 직접 object 를 저장하지 않습니다. 
유저들은 대부분 Ceph Block Device, Ceph Filesystem, Ceph Object Storage 중 
하나를 사용합니다.	

.. toctree::
	
   Block Device Quick Start <quick-rbd>
   Filesystem Quick Start <quick-cephfs>
   Object Storage Quick Start <quick-rgw>

.. raw:: html

	</td></tr></tbody></table>


