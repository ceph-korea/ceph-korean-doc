==============================
 Ceph 에 오신 것을 환영합니다!
==============================

Ceph 은 오브젝트, 블록, 파일 스토리지를 단일 시스템**에서 제공하는 유일한 솔루션입니다.

.. raw:: html

	<style type="text/css">div.body h3{margin:5px 0px 0px 0px;}</style>
	<table cellpadding="10"><colgroup><col width="33%"><col width="33%"><col width="33%"></colgroup><tbody valign="top"><tr><td><h3>Ceph Object Store</h3>

- RESTful 인터페이스
- S3 및 Swift 와 호환되는 API 제공
- S3 스타일의 subdomains   
- 통합된 S3/Swift 네임스페이스
- 유저 관리
- 사용량 추적
- 스트라이핑된 오브젝트
- 클라우드 솔루션과의 통합
- Multi-site 배포
- Multi-site 레플리케이션

.. raw:: html

	</td><td><h3>Ceph Block Device</h3>


- Thin-provisioning
- 최대 16 엑사바이트의 이미지
- 설정 가능한 스트라이핑
- In-memory 캐싱
- 스냅샷 제공
- Copy-on-write 클론
- 커널 드라이버 제공
- KVM/libvirt 지원
- 클라우드 솔루션의 백엔드
- 증분 백업
- 재해 복구 (multisite 비동기 레플리케이션)

.. raw:: html

	</td><td><h3>Ceph Filesystem</h3>

- POSIX 호환
- 데이터와 분리된 메타데이터
- 동적 리밸런싱
- 서브디렉토리 스냅샷
- 설정 가능한 스트라이핑
- 커널 드라이버 제공
- FUSE 제공
- NFS/CIFS 배포 가능
- Hadoop 과 함께 사용 (HDFS 대체)

.. raw:: html

	</td></tr><tr><td>

더 자세한 정보는 `Ceph Object Store`_ 를 참고하세요.

.. raw:: html

	</td><td>

더 자세한 정보는 `Ceph Block Device`_ 를 참고하세요.

.. raw:: html

	</td><td>

더 자세한 정보는 `Ceph Filesystem`_ 를 참고하세요

.. raw::	html

	</td></tr></tbody></table>

Ceph 은 높은 신뢰성을 가지고, 관리하기 쉬우며, 무료로 제공됩니다. 
Ceph 의 힘으로 당신의 회사의 IT 인프라스트럭쳐와 능력을 방대한 양의 데이터를 다루도록 바꿀 수 있습니다. 
처음 시작해보려면, `시작하기`_ 가이드를 참고하세요. Ceph 에 대한 더 많은 정보를 원한다면, 
`아키텍처`_ 섹션을 참고하세요.

.. _Ceph Object Store: radosgw
.. _Ceph Block Device: rbd
.. _Ceph Filesystem: cephfs
.. _시작하기: start
.. _아키텍처: architecture

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
   mgr/dashboard
   api/index
   architecture
   Developer Guide <dev/developer_guide/index>
   dev/internals
   governance
   ceph-volume/index
   releases/index
   Glossary <glossary>
