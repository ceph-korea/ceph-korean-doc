==============
 Architecture
==============

:term:`Ceph` **object, block, file 스토리지를 하나의 통합된 환경으로 제공하는** 유일한 시스템입니다.
Ceph 은 높은 신뢰성을 가지고, 관리하기 쉬우며, 무료로 제공됩니다. Ceph 의 힘으로 당신의 회사의 
IT 인프라스트럭쳐와 능력을 방대한 양의 데이터를 다루도록 바꿀 수 있습니다.  
Ceph 은 Client 가 페타바이트에서 엑사바이트까지의 데이터에 액세스 할 수 있도록 탁월한 확장성을 가지고 있습니다. 
:term:`Ceph Node` 는 상용 하드웨어와 똑똑한 Daemon 을 활용하고, :term:`Ceph Storage Cluster` 는 
동적으로 데이터를 복제하고 재분배를 수행하는 다수의 노드를 수용합니다.

.. image:: images/stack.png


The Ceph Storage Cluster
========================

Ceph 은 무한대로 확장 가능한 :term:`Ceph Storage Cluster` 를 제공합니다. 
Ceph 클러스터는 :abbr:`RADOS (신뢰성 있는 분산 오브젝트 저장소)` 를 기반으로 하고 있습니다.
`RADOS - A Scalable, Reliable Storage Service for Petabyte-scale
Storage Clusters`_ 를 참고하세요

Ceph Storage Cluster 는 다음의 두 Daemon 으로 이루어져 있습니다.:

- :term:`Ceph Monitor`
- :term:`Ceph OSD Daemon`

.. ditaa::  +---------------+ +---------------+
            |      OSDs     | |    Monitors   |
            +---------------+ +---------------+

Ceph Monitor 는 cluster map 의 master copy 를 유지합니다. Ceph monitor 클러스터는 
가용성에 따라 몇 개의 monitor daemon 이 죽더라도 높은 고가용성을 보장합니다. 
Storage cluster 의 Client 는 Ceph Monitor 로 부터 cluster map 의 복제본을 받아옵니다.

Ceph OSD Daemon 은 자신의 상태와 다른 OSD 의 상태를 체크하고, monitor 에게 알려줍니다.

Storage cluster 의 Client 들과 각각의 :term:`Ceph OSD Daemon` 은 
데이터 데이터 위치에 관한 정보를 효율적으로 계산하기 위해 
하나의 중앙화된 lookup table 대신, CRUSH 알고리즘을 사용합니다. 
Ceph 은 ``librados`` 를 통해 Ceph Storage Cluster 의 인터페이스와, ``librados`` 
을 통해 구현된 여러 서비스의 높은 수준의 인터페이스를 제공합니다. 


Storing Data
------------

Ceph Storage Cluster 는 :term:`Ceph Clients` 로 부터 데이터를 받습니다. 이 데이터는 
:term:`Ceph Block Device`, :term:`Ceph Object Storage` :term:`Ceph Filesystem` 혹은
``librados`` 로 당신이 커스텀한 구현체로부터 옵니다. --그리고 이러한 데이터들을 object 형태로 저장합니다. 
각각의 object 는 :term:`Object Storage Device` 에 저장되는 파일시스템의 파일과 일치합니다. 
Ceph OSD Daemon 은 하드웨어 디스크에서 읽기/쓰기 작업을 핸들링합니다. 

.. ditaa:: /-----\       +-----+       +-----+
           | obj |------>| {d} |------>| {s} |
           \-----/       +-----+       +-----+
   
            Object         File         Disk

Ceph OSD Daemon 들은 계층화된 디렉토리가 아닌 flat namespace 에 모든 데이터들을 저장합니다. 
하나의 object 는 name/value 쌍으로 이루어진 identifier, 바이너리 데이터, 그리고 메타데이터를 가집니다. 
이는 어떠한 :term:`Ceph Clients` 를 사용해도 마찬가지입니다. 
예를 들어, CephFS 는 file 소유주, 생성일, 마지막 수정 일자 등을 저장하기 위해 metadata 를 사용합니다. 


.. ditaa:: /------+------------------------------+----------------\
           | ID   | Binary Data                  | Metadata       |
           +------+------------------------------+----------------+
           | 1234 | 0101010101010100110101010010 | name1 = value1 | 
           |      | 0101100001010100110101010010 | name2 = value2 |
           |      | 0101100001010100110101010010 | nameN = valueN |
           \------+------------------------------+----------------/    

.. note:: object 의 ID 는 로컬 파일시스템에서 뿐만 아니라 전체 클러스터에서 단 하나입니다.


.. index:: architecture; high availability, scalability

Scalability and High Availability
---------------------------------

전통적인 아키텍처에서, client 들은 중앙화된 컴포넌트에게 (e.g., gateway, broker, API, facade, etc.) 
요청을 보내 왔습니다. 이는 복잡한 서브시스템에서 
single point of failure 라고 불리는 (i.e., 중앙화된 컴포넌트가 중단되면, 모든 시스템이 중단됨) 
단일 진입점으로 동작하며, 퍼포먼스와 확장성에 있어 제약으로 작용합니다. 

Ceph 은 client 들이 Ceph OSD Daemon 과 직접 통신하도록 중앙화된 gateway 를 없앴습니다. 
데이터의 안전성과 높은 가용성을 보장하기 위해 Ceph OSD Daemon 들은 다른 Ceph Node 들에 object replica 들을 만들고, 
Ceph 은 moniter 클러스터를 사용합니다. 또한 SPOF 를 없애기 위해, Ceph 은 CRUSH 라고 불리우는 알고리즘을 사용합니다.

.. index:: CRUSH; architecture

CRUSH Introduction
~~~~~~~~~~~~~~~~~~

Ceph Client 들과 Ceph OSD Daemon 들은 모두 object 의 위치를 효율적으로 계산하기 위해 
중앙화된 lookup table 대신 :abbr:`CRUSH (확장 가능한 해시 기반의 복제 제어)` 를 사용합니다. 
CRUSH 는 이전 접근 방식과 비교하여 더 효율적인 데이터 관리 메커니즘과, 
클러스터의 모든 client 들과 OSD Daemon 들에 작업을 분배하며 확장성을 제공해 줍니다. 
CRUSH 는 hyper-scale 스토리지에 더 적합한 기능적인 데이터 레플리케이션을 제공합니다. 
다음 섹션에서 CRUSH 가 어떻게 동작하는지 알아볼 수 있습니다. `CRUSH - Controlled, Scalable, Decentralized
Placement of Replicated Data`_.

.. index:: architecture; cluster map

Cluster Map
~~~~~~~~~~~

Ceph 은 cluster topology 를 가지고 있는 Ceph Client 들과 OSD Daemon 들에게 의존합니다. 
이 cluster topology 는 "Cluster Map" 이라고 불리며, 5가지의 Map 이 존재합니다.  

#. **The Monitor Map:** 은 클러스터 각각의 monitor 의 
   ``fsid``, position, name address 를 포함합니다. 또한 map 이 생성될때 변경되는
   epoch 의 최신 버전을 가지고 있습니다. monitor map 을 조회하려면, ``ceph mon dump`` 
   를 실행합니다.
   
#. **The OSD Map:** 은 클러스터 ``fsid``, map 이 생성되고 수정된 이력, pool 리스트, 
   replica 사이즈, PG 수, OSD 리스트와 상태 (e.g., ``up``, ``in``)를 포함합니다. 
   OSD map 을 조회하려면, ``ceph osd dump`` 를 실행합니다. 
   
#. **The PG Map:** 은 PG 버전, 타임스탬프, 마지막 OSD map 의 epoch, 전체 비율, 
   그리고 pool 의 place group 각각의 PG ID, `Up Set`, `Acting Set`, 상태 
   (e.g., ``active + clean``), 데이터 사용 분석 등 상세 정보를 포함합니다. 

#. **The CRUSH Map:** 은 저장 장치 리스트, failure domain 계층 구조 
   (e.g., device, host, rack, row, room, etc.), 그리고 데이터를 저장할 때 
   계층 구조를 탐색하기 위한 규칙을 포함합니다. CRUSH map 을 조회하려면, 
   ``ceph osd getcrushmap -o {filename}`` 을 실행하고, 
   ``crushtool -d {comp-crushmap-filename} -o {decomp-crushmap-filename}`` 
   을 실행하여 디컴파일합니다. 이후 ``cat`` 명령이나 텍스트 에디터를 사용하여 디컴파일된 
   map 을 조회할 수 있습니다.

#. **The MDS Map:** 은 MDS map 이 변경된 마지막 시간인 epoch 를 포함합니다.
   그리고 메타데이터를 저장하기 위한 pool, ``up`` 그리고 ``in`` 상태인 
   메타데이터 서버의 리스트를 포함합니다. MDS map 을 조회하려면, ``ceph fs dump`` 
   를 실행합니다.

각각의 맵은 운영 상태 변경에 대한 기록을 유지합니다. Ceph Monitor 는 cluster 멤버, 상태, 변경이력, 
전체 Ceph Storage Cluster 의 health 를 포함하는 cluster map 의 master copy 를 유지합니다. 

.. index:: high availability; monitor architecture

High Availability Monitors
~~~~~~~~~~~~~~~~~~~~~~~~~~

Ceph Client 들이 데이터를 읽거나 쓰려면, 가장 최신 버전의 cluster map 을 얻기 위해 
Ceph Monitor 와 통신해야 합니다. Ceph Storage Cluster 는 하나의 monitor 만으로 
동작할 수 있습니다; 하지만, 이는 SPOF (single point of failure) 를 유발시킵니다. 
(i.e., 만약 monitor 가 다운되면, Ceph Client 들은 데이터를 읽고 쓸 수 없습니다.)

신뢰성과 장애 복구를 위해서는, Ceph 은 monitor cluster 를 지원합니다. 
monitor 의 클러스터에서, 레이턴시나 기타 결함으로 인해 하나 이상의 monitor 가 클러스터의 현재 
상태보다 뒤떨어질 수 있습니다. 이런 이유에서 Ceph 은 클러스터 상태에 따라 다양한 monitor 인스턴스
간의 동의가 있어야 합니다. Ceph 은 항상 monitor 의 과반수 찬성을 통해 동작합니다. 
(e.g., 1, 2:3, 3:5, 4:6, etc.) 그리고 monitor 간의 클러스터 현재 상태에 대한 합의를 
구하기 위해 `Paxos`_ 알고리즘을 사용합니다. 

monitor 설정에 대해 더 알아보려면, `Monitor Config Reference`_ 를 참고합니다. 

.. index:: architecture; high availability authentication

High Availability Authentication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ceph 은 사용자를 식별하고 man-in-middle-attack 을 방지하고 사용자와 daemon 을 인증하기 위해 
``cephx`` 인증 시스템을 제공합니다. 

.. note:: ``cephx`` 프로토콜은 통신 시 데이터 암호화 (e.g., SSL/TLS) 를 다루지 않습니다.

Cephx 인증을 위해 공유되는 secret key 를 사용합니다. 이는 즉 client 와 monitor 클러스터가 
client 의 secret key 복제본을 가지고 있음을 의미합니다. 이 인증 프로토콜은 양 당사자가 
key 를 공개하지 않고 key 사본을 증명할 수 있습니다. 이런 방법을 통해서, cluster 는 사용자가 
secret key 를 가지고 있는지 확인하고, 사용자는 cluster 가 secret key 사본을 가지고 있는지 
확인할 수 있습니다. 

Ceph 의 핵심적인 확장 기능은 중앙화된 인터페이스를 피하는 것인데, 이는 Ceph client 가 OSD 와 
직접적으로 상호작용 할 수 있어야 한다는 것을 의미합니다. 데이터를 지키기 위해, Ceph 은 ``cephx``
인증 시스템을 제공합니다. 이 시스템은 `Kerberos`_ 와 비슷하게 동작합니다. 

user/actor 는 Ceph client 를 호출하여 monitor 와 접촉합니다. Kerberos 와 다르게, 
각각의 monitor 는 유저와 key 를 인증할 수 있으므로, ``cephx`` 는 single point of failure 와 
보틀넥이 없습니다. monitor 는 Kerberos 와 비슷하게 Ceph service 를 사용할 수 있는 session key를 
담고 있는 인증 티켓 데이터를 리턴합니다. 이 session key 는 그 자체로 유저의 영구적인 secret 키로 암호화되어
있습니다. 따라서 해당 유저만 Ceph Monitor(들) 에게 요청을 보낼 수 있도록 합니다. 
client는 monitor 로 부터 필요한 서비스를 요청하기 위해 session key 를 사용하고, 
monitor 는 실제로 데이터를 처리하는 OSD에 대해 client 를 인증할 티켓을 제공합니다. 
Ceph Moniter 와 OSD 들은 secret 을 공유하기 때문에, client 는 monitor 로부터 제공받은 티켓을 
클러스터 내의 어떤 OSD 나 metadata 서버에서 사용할 수 있습니다. 
Kerberos 와 같이, ``cephx`` 티켓은 만료되기 때문에, 공격자는 비밀스럽게 얻은 session key 나 티켓을 
사용할 수 없습니다. 이러한 형태의 인증은 통신 매체에 접속한 공격자가 사용자의 session key가 만료되기 전에 
공개되지 않는 한 다른 사용자의 신분 아래에 위조 메시지를 만들거나 다른 사용자의 합법적 메시지를 변경할 수 없도록 합니다.

``cephx`` 를 사용하기 위해서, 관리자는 먼저 유저를 세팅해야 합니다. 아래의 다이어그램에서, 
``ceph.admin`` 유저가 username 과 secret key 를 생성하기 위해 커맨드 라인에서 
``ceph auth get-or-create-key`` 를 호출합니다. Ceph 의 ``auth`` 서브시스템은 
username 과 key 를 생성하고, monitor(들) 에 복제본을 저장합니다. 그리고 ``client.admin`` 
유저에게 리턴합니다. 이는 client 와 monitor 가 secret 키를 공유함을 의미합니다. 

.. note:: ``client.admin`` 유저는 사용자에게 안전하게 ID 와 key를 제공해야 합니다. 

.. ditaa:: +---------+     +---------+
           | Client  |     | Monitor |
           +---------+     +---------+
                |  request to   |
                | create a user |
                |-------------->|----------+ create user
                |               |          | and                 
                |<--------------|<---------+ store key
                | transmit key  |
                |               |


monitor 를 통해 인증하기 위해서, client 는 user name 을 monitor 에게 전달합니다. 그리고 
monitor 는 session key 를 생성하고 user name 과 연관된 secret key 로 암호화를 거칩니다. 
이후, 암호화된 티켓을 client 에게 돌려줍니다. client 는 공유된 secret key 를 가지고 
session key 를 만들어냅니다. session key 는 현재 세션에서 유저를 식별합니다. 
client 는 이후 session 키로 서명된 유저를 대신하여 티켓을 요청합니다. 
monitor 가 티켓을 만들고, 유저의 secret key 로 암호화한 후 다시 client 로 돌려줍니다. 
client 는 그 티켓을 복호화하고, OSD 와 metadata 서버들에게 요청할 서명으로 사용합니다. 

.. ditaa:: +---------+     +---------+
           | Client  |     | Monitor |
           +---------+     +---------+
                |  authenticate |
                |-------------->|----------+ generate and
                |               |          | encrypt                
                |<--------------|<---------+ session key
                | transmit      |
                | encrypted     |
                | session key   |
                |               |             
                |-----+ decrypt |
                |     | session | 
                |<----+ key     |              
                |               |
                |  req. ticket  |
                |-------------->|----------+ generate and
                |               |          | encrypt                
                |<--------------|<---------+ ticket
                | recv. ticket  |
                |               |             
                |-----+ decrypt |
                |     | ticket  | 
                |<----+         |              


``cephx`` 프로토콜은 client 와 machine, 그리고 Ceph 서버들 간에 지속적인 통신을 인증합니다. 
초기 인증 확인 이후, client 와 server 간에 전송되는 각 메시지는 monitor, OSD 및 metadata 
서버가 공유하는 secret 을 통해 확인할 수 있는 티켓을 사용합니다. 

.. ditaa:: +---------+     +---------+     +-------+     +-------+
           |  Client |     | Monitor |     |  MDS  |     |  OSD  |
           +---------+     +---------+     +-------+     +-------+
                |  request to   |              |             |
                | create a user |              |             |               
                |-------------->| mon and      |             |
                |<--------------| client share |             |
                |    receive    | a secret.    |             |
                | shared secret |              |             |
                |               |<------------>|             |
                |               |<-------------+------------>|
                |               | mon, mds,    |             |
                | authenticate  | and osd      |             |  
                |-------------->| share        |             |
                |<--------------| a secret     |             |
                |  session key  |              |             |
                |               |              |             |
                |  req. ticket  |              |             |
                |-------------->|              |             |
                |<--------------|              |             |
                | recv. ticket  |              |             |
                |               |              |             |
                |   make request (CephFS only) |             |
                |----------------------------->|             |
                |<-----------------------------|             |
                | receive response (CephFS only)             |
                |                                            |
                |                make request                |
                |------------------------------------------->|  
                |<-------------------------------------------|
                               receive response

이런 인증을 통해 제공되는 보호는 Ceph client 와 Ceph 서버 호스트 사이에 동작합니다. 
이 인증은 Ceph client 이상으로 확장되지 않습니다. 만약 유저가 원격 호스트를 통해 
Ceph client 로 엑세스 하는 경우, Ceph 인증은 사용자의 호스트와 client 호스트 간의 연결에는 
적용되지 않습니다. 

좀 더 자세한 인증 관련 설정 정보는, `Cephx Config Guide`_ 를 참고하고, user management 
에 관한 정보는 `User Management`_ 를 참고합니다. 

.. index:: architecture; smart daemons and scalability

Smart Daemons Enable Hyperscale
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

많은 클러스터 아키텍쳐에서, 클러스터 멤버십의 주요 목적은 중앙 집중적인 인터페이스가 어떤 노드에 
엑세스 할 수 있는지 아는 것입니다. 이런 중앙 집중적인 인터페이스는 페타바이트에서 엑사바이트까지의 
규모에서 **거대한** 병목 현상인 이중 배치를 통해 client 에게 서비스를 제공합니다. 

Ceph 은 이런 병목 지접을 없앴습니다.: Ceph 의 OSD Daemon 들과 Ceph Client 들은 모두 
클러스터에 대해 파악하고 있습니다. Ceph Client 처럼, 각각의 Ceph OSD Daemon 들은 클러스터 내의 
다른 Ceph OSD Daemon 들을 알고 있습니다. 이는 다른 OSD Daemon 들과 Monitor 들에게 직접 상호 작용이 
가능하게 합니다. 게다가, Ceph Client 가 OSD Daemon 들과 직접 통신이 가능하게 하기도 합니다. 

Ceph Client, Ceph Monitor, Ceph OSD Daemon 의 상호 작용 능력은 Ceph OSD Daemon 들이 
Ceph 노드의 CPU 와 RAM 을 효율화하여 중앙 집중식 서버를 갉아먹는 작업을 손쉽게 수행할 수 있게 합니다. 
이러한 컴퓨팅 성능을 활용할 수 있는 능력은 다음과 같은 몇 가지 주요 이점을 제공합니다. 

#. **OSD 와 Client 의 직접 상호작용:** 어떤 네트워크 장치든 동시에 연결할 수 있는 수의 제한이 존재 
   하기 때문에, 중앙화된 시스템은 거대한 스케일에서 물리적인 한계가 존재합니다. Ceph Client 들이 
   Ceph OSD Daemon 에게 직접적으로 통신할 수 있어 single point of failure 를 없앴기 때문에, 
   Ceph 은 성능과 전체 시스템의 용량을 동시에 확보할 수 있습니다. Ceph Client 들은 필요할 때 중앙화 
   된 서버 대신 특정 Ceph OSD Daemon 으로 세션을 유지할 수 있습니다.

#. **OSD Membership 과 상태**: Ceph OSD Daemon 은 클러스터에 조인하고 자신의 상태를 리포팅합니다. 
   Ceph OSD Daemon 은 실행 중이고 Ceph Client 의 요청을 서비스할 수 있느냐에 따라 ``up`` 이거나 ``down``
   상태일 수 있습니다. Ceph OSD Daemon 이 ``down`` 상태이고 ``in`` 이라면, 이는 Ceph Daemon 이 
   이상이 있음을 나타냅니다. Ceph OSD Daemon 이 실행 중이 아니라면, (e.g., Crash 상태) 
   Ceph OSD Daemon 은 자신의 상태가 ``down`` 임을 monitor에게 전달해주지 못합니다. 하지만, 
   OSD 들은 주기적으로 Ceph Monitor 에게 메시지를 보내며 (luminous 이전 버전에는 ``MPGStats``, 
   luminous 이후에는 ``MOSDBeacon`` 이라고 합니다.), Ceph Monitor 가 설정된 주기적 시간을 넘어 
   메시지를 받지 못한다면, OSD 를 down 상태로 표기합니다. 이러한 메커니즘은 안전하지만, 일반적으로, 
   Ceph OSD Daemon 은 자신의 이웃 OSD 가 down 상태이면 Monitor 에게 이런 상황을 리포팅합니다. 
   이는 Ceph Moniotor 가 굉장히 가벼운 프로세스를 가지는 것을 가능하게 합니다. 
   더 많은 정보는 `Monitoring OSDs`_ 와 `Heartbeats` 를 참고하세요.

#. **Data Scrubbing:** 데이터 일치성과 청결성을 유지하기 위한 목적으로, Ceph OSD Daemon 들은 
   placement group 안에 있는 오브젝트 메타데이터를 다른 OSD 에 저장되어 있는 placement group 
   레플리카들과 비교할 수 있습니다. Scrubbing (일반적으로 하루에 한번 수행됨) 은 버그나 파일시스템 에러를 
   감지합니다. 또한 Ceph OSD Daemon 은 object 에 있는 데이터를 bit 단위로 비교하는 
   더 고도의 scrubbing (deep scrub) 을 수행합니다. Deep scrubbing (일반적으로 일주일에 한번 수행됨)
   은 light scrub 으로는 드러나지 않는 드라이브의 bad sector 를 찾아낼 수 있습니다. 
   scrubbing 을 설정하는 자세한 방법은 `Data Scrubbing`_ 을 참고하세요.

#. **Replication:** Ceph Client 들과 마찬가지로, Ceph OSD Daemon 들은 CRUSH 알고리즘을 사용합니다. 
   하지만, Ceph OSD Daemon 은 object 의 레플리카가 어디에 저장되어야 하는지 계산하는데만 (그리고 rebalancing) 
   CRUSH 알고리즘을 사용합니다. 전형적인 쓰기 작업 시나리오에서, client 는 object 가 어디에 저장되어야 할 지 
   계산하기 위해 CRUSH 알고리즘을 사용하고, object 를 pool 과 placement group 에 매핑합니다. 그러고 나서 
   CRUSH map 을 확인하여 placement group 의 primary OSD 를 확인합니다. 
   
   client 는 primary OSD 안의 placement group 에 object 를 쓰게 됩니다. 그리고, 
   CRUSH map 사본이 있는 primary OSD 는 replication 목적을 위해 2차, 3차 OSD 를 
   식별하고, object 를 각 OSD 의 적절한 placement group 에 배치합니다. object 가 
   성공적으로 저장되었음을 확인하게 되면 client 에게 응답하게 됩니다. 

.. ditaa:: 
             +----------+
             |  Client  |
             |          |
             +----------+
                 *  ^
      Write (1)  |  |  Ack (6)
                 |  |
                 v  *
            +-------------+
            | Primary OSD |
            |             |
            +-------------+
              *  ^   ^  *
    Write (2) |  |   |  |  Write (3)
       +------+  |   |  +------+
       |  +------+   +------+  |
       |  | Ack (4)  Ack (5)|  | 
       v  *                 *  v
 +---------------+   +---------------+
 | Secondary OSD |   | Tertiary OSD  |
 |               |   |               |
 +---------------+   +---------------+

Ceph OSD Daemon 은 데이터 replication 을 수행하는 능력으로 
client 는 그 의무를 수행하게 하지 않으면서 높은 데이터 가용성과 
안정성을 보장합니다. 

Dynamic Cluster Management
--------------------------

`Scalability and High Availability`_ 섹션에서, scale up 하고 높은 가용성을 유지하기 위해
Ceph 이 CRUSH, cluster awareness 그리고 데몬들을 어떻게 사용하는 지 설명했습니다.
Ceph 디자인의 키는, 원자성, 자가 복구, 그리고 똑똑한 Ceph OSD Daemon 입니다. 
이제부터는 CRUSH 가 modern cloud storage 를 어떻게 데이터를 위치시키고, 클러스터를 rebalance 하고, 
실패에 대해 동적으로 회복하는지 더 깊게 살펴볼 것입니다.

.. index:: architecture; pools

About Pools
~~~~~~~~~~~

Ceph storage system 은 object 를 저장하기 위한 논리적인 파티션인 'Pool' 을 지원합니다.

Ceph Client 들은 Ceph Monitor 로부터 `Cluster Map`_ 을 받습니다. 
그리고 pool 에 object 를 쓰게 도비니다. pool 의 ``size`` 또는 replica 수, CRUSH 규칙 및
placement group 수에 따라 Ceph 이 데이터를 배치하는 방법이 결정됩니다.

.. ditaa:: 
            +--------+  Retrieves  +---------------+
            | Client |------------>|  Cluster Map  |
            +--------+             +---------------+
                 |
                 v      Writes
              /-----\
              | obj |
              \-----/
                 |      To
                 v
            +--------+           +---------------+
            |  Pool  |---------->|  CRUSH Rule   |
            +--------+  Selects  +---------------+
                 

Pool 에는 적어도 다음의 인자를 설정해 주어야 합니다.

- Object 에 대한 소유 / 접근 
- Placement Group 의 수
- 사용하기 위한 CRUSH Rule

자세한 정보는 `Set Pool Values`_ 를 참고합니다.


.. index: architecture; placement group mapping

Mapping PGs to OSDs
~~~~~~~~~~~~~~~~~~~

각각의 pool 에는 placement group 들이 존재합니다. CRUSH 는 PG 와 OSD 를 동적으로 매핑합니다.
Ceph Client 가 object 를 저장할 때, CRUSH 는 각 object 를 placement group 에 매핑합니다.

placement group 에 object 를 매핑하면, Ceph OSD Daemon 과 Ceph Client 간의 간접적인 계층이
생깁니다. Ceph Storage Cluster 는 object 를 저장하는 위치를 동적으로 확장하거나 축소하거나, 혹은 
rebalancing 할 수 있어야 합니다. 만약 Ceph Client 가 어떤 Ceph OSD Daemon 이 어떤 object 를
가지고 있는지 "알고" 있다면, Ceph Clinet 와 Ceph OSD Daemon 간에 밀접한 연결고리를 형성할 것입니다.
대신 CRUSH 알고리즘은 각각의 object 를 placement group 과 매핑한 다음, 각 placement group 을 
하나 혹은 그 이상의 Ceph OSD Daemon 과 매핑합니다. 이러한 간접적인 계층은 Ceph 이 새로운 
Ceph OSD Daemon 과 OSD Deivce 가 Online 상태가 될 때 동적으로 재배치 (rebalance) 할 수 있도록 
해줍니다. 아래의 다이어그램은 CRUSH map 이 어떻게 object 와 placement group, 그리고 placement 
group 과 OSD 를 연결하는지 나타냅니다.

.. ditaa:: 
           /-----\  /-----\  /-----\  /-----\  /-----\
           | obj |  | obj |  | obj |  | obj |  | obj |
           \-----/  \-----/  \-----/  \-----/  \-----/
              |        |        |        |        |
              +--------+--------+        +---+----+
              |                              |
              v                              v
   +-----------------------+      +-----------------------+
   |  Placement Group #1   |      |  Placement Group #2   |
   |                       |      |                       |
   +-----------------------+      +-----------------------+
               |                              |
               |      +-----------------------+---+
        +------+------+-------------+             |
        |             |             |             |
        v             v             v             v
   /----------\  /----------\  /----------\  /----------\ 
   |          |  |          |  |          |  |          |
   |  OSD #1  |  |  OSD #2  |  |  OSD #3  |  |  OSD #4  |
   |          |  |          |  |          |  |          |
   \----------/  \----------/  \----------/  \----------/  

cluster map 과 CRUSH 알고리즘의 복제본으로, client 는 특정한 object 를 읽거나 쓸 때 
어떤 OSD 를 사용해야 하는지 정확히 계산해 낼 수 있습니다.

.. index:: architecture; calculating PG IDs

Calculating PG IDs
~~~~~~~~~~~~~~~~~~

Ceph Client 가 Ceph Monitor 에 바인딩되면, `Cluster Map`_ 의 최신 복제본을 검색합니다.
Cluster map 을 통해 client 는 클러스터 내의 monitor, OSD, metadata server 의 모든 
것을 알 수 있습니다. **그러나, object 의 위치를 모두 알지는 못합니다.**

.. epigraph:: 

   Object 의 위치는 계산되어 알아냅니다.


client 가 주어야 할 입력은 object ID 와 pool 밖에 없습니다. 굉장히 간단합니다.:
Ceph 은 이름이 주어진 pool (e.g., "liverpool") 에 데이터를 저장합니다. 
client 가 이름이 주어진 object (e.g., "john", "paul", "george", etc.) 를 저장하길 
원할 때, object 이름, hash code, pool 내의 PG 갯수, 그리고 pool 이름으로 placement group 을
계산해냅니다. Ceph Client 는 PG ID 를 계산하기 위해서 다음의 절차를 거칩니다.

#. Client 가 pool 이름과 object ID 를 입력합니다. (e.g., pool = "liverpool", object-id = "john")
#. Ceph 이 object ID 와 hash 를 가져갑니다.
#. Ceph 이 PG ID 를 얻기 위해 PG 갯수로 hash 연산을 수행합니다. (e.g., ``58``)
#. Ceph 이 pool 이름을 지정한 pool ID 를 가져옵니다. (e.g., "liverpool" = ``4``)
#. Ceph 이 pool ID 를 PG ID 로 준비합니다.

object 위치를 계산하는 것은 chatty session 을 통해 object 위치를 쿼리하는 것보다 훨씬 빠릅니다.
:abbr:`CRUSH (Controlled Replication Under Scalable Hashing)` 알고리즘은 object 가 어디에 
`꼭` 저장되어야 하는지 client 가 계산할 수 있도록 하고, object 를 검색하기 위해서 primary OSD 와 
연결될 수 있도록 합니다.

.. index:: architecture; PG Peering

Peering and Sets
~~~~~~~~~~~~~~~~

이전 섹션에서, Ceph OSD Daemon 들이 각각의 상태를 체크하고, Ceph Monitor 에게 보고한다는 것을 
알았습니다. Ceph OSD Daemon 은 'peering' 이라는 것 또한 수행합니다. 이것은 Placement Group 
을 저장하는 모든 OSD 들이 그 PG 내의 object (그리고 Metadata) 의 모든 상태에 대해 합의하는 프로세스입니다.
실은, Ceph OSD Daemon 은 Ceph Monitor 에게 `Report Peering Failure`_ (Peering 실패 알림) 을 
수행합니다. Peering 문제는 종종 자신들끼리 해결이 되지만, 문제가 지속적일 경우, `Troubleshooting Peering Failure`_ 
섹션을 참고하세요.

.. Note:: Agreeing on the state does not mean that the PGs have the latest contents.

Ceph Stroage Cluster 는 적어도 object 의 두개의 복제본을 저장하도록 디자인되어 있습니다. (i.e., ``size = 2``)
이는 데이터 안전을 위한 최소한의 요구사항입니다. 높은 가용성을 위해서는, Ceph Storage Cluster 는 
두 개 이상의 object 복제본을 유지해야 합니다. (e.g., ``size = 3``, ``min size = 2``)
이렇게 함으로서 데이터의 안전성을 유지하면서 ``degraded`` 상태에서 계속 운영할 수 있습니다.

`Smart Daemons Enable Hyperscale`_ 섹션의 다이어그램에서, 우리는 Ceph OSD Daemon 의 이름을 
특정하게 이름짓기보다는, (e.g., ``osd.0``, ``osd.1``, etc.) *Primary* 나 *Secondary* 로 
불렀습니다. 컨벤션에 따라서, *Primary* 는 *Acting Set* 안의 첫번째 OSD 이며, 각각의 placement 
group 의 peering 과정을 조정하는 책임을 가지고 있습니다. 또한, *Primary* 로 동작하면서 
Client 가 처음 object 에 wirte 하는 **유일한** OSD 로 동작합니다.

placement group 에 대한 책임을 가지고 있는 OSD 들은 *Acting Set* 이라고 불립니다. 
*Acting Set* 은 현재 placement group 에 책임을 가지거나, 특정 epoch 에서 특정한 placement 
group 에 대해 책임을 가지는 OSD Daemon 들을 지칭합니다.

*Acting Set* 의 일부인 Ceph OSD Daemon 은 항상 ``up`` 상태를 유지하지는 않을 것입니다.
*Acting Set* 내의 OSD 일부가 ``up`` 상태일때, 이 OSD 는 *Up Set* 이라 부릅니다.
*Up Set* 은 Ceph 이 OSD 가 실패했을 때 PG 들을 다른 Ceph OSD 로 remap 할 수 있게 해주는 
중요한 요소입니다.

.. note:: *Acting Set* 인 ``osd.25``, ``osd.32`` 그리고 ``osd.61`` 에 대해서, 
   *Primary* OSD 인 ``osd.25`` 가 실패하면, 두번 째인 ``osd.32`` 가 *Prmiary* 가 되고,
   ``osd.25`` 는 *Up Set* 으로부터 제외됩니다.


.. index:: architecture; Rebalancing

Rebalancing
~~~~~~~~~~~

여러분이 Ceph 클러스터에 Ceph OSD Daemon 을 추가할 때, cluster map 은 새로운 OSD 에 대한
업데이트를 받습니다. `Calculating PG IDs`_ 섹션에서 보았듯이, 이는 cluster map 을 변경하는 
작업입니다. 동시에, 이 작업은 연산을 위한 입력을 변경하기 때문에 object placement 를 변경합니다. 
다음의 다이어그램은 rebalancing 절차를 나타내는데, 여기서 (대형 클러스터에서는 그리 영향을 받지 않습니다.)
일부 PG 들은 기존의 OSD (OSD 1, OSD 2) 새로운 OSD (OSD 3) 으로 이동하게 됩니다. 
이런 rebalancing 상황에서도, CRASH 알고리즘은 안정적으로 동작합니다. 
많은 수의 PG 들의 기존 설정이 유지되면서 각 OSD 의 용량이 증가하면서, rebalancing 이 완료된 후에는
큰 부하가 존재하지 않습니다.

.. ditaa:: 
           +--------+     +--------+
   Before  |  OSD 1 |     |  OSD 2 |
           +--------+     +--------+
           |  PG #1 |     | PG #6  |
           |  PG #2 |     | PG #7  |
           |  PG #3 |     | PG #8  |
           |  PG #4 |     | PG #9  |
           |  PG #5 |     | PG #10 |
           +--------+     +--------+

           +--------+     +--------+     +--------+
    After  |  OSD 1 |     |  OSD 2 |     |  OSD 3 |
           +--------+     +--------+     +--------+
           |  PG #1 |     | PG #7  |     |  PG #3 |
           |  PG #2 |     | PG #8  |     |  PG #6 |
           |  PG #4 |     | PG #10 |     |  PG #9 |
           |  PG #5 |     |        |     |        |
           |        |     |        |     |        |
           +--------+     +--------+     +--------+


.. index:: architecture; Data Scrubbing

Data Consistency
~~~~~~~~~~~~~~~~

데이터의 정합성을 유지하기 위한 목적으로, Ceph OSD 들은 placement group 의 object 에 대한 
scrub 을 수행합니다. scrub 은, 다른 OSD 에 저장되어 있는 PG 안의 object 와 비교 대상 OSD 
PG 의 object 를 비교하는 것입니다. Scrubbing (주로 하루에 한 합 수행) 은 OSD 버그와 
파일시스템의 에러를 발견할 수 있게 합니다. 또한 OSD 는 object 를 bit 단위로 비교하는 Deep 
Scrub 을 수행합니다. (주로 일주일에 한 번 수행) 이는 일반 scrub 으로는 찾을 수 없는 
디스크의 bad sector 를 찾을 수 있게 합니다. 

scrubbing 을 설정하기 위한 자세한 정보는 `Data Scrubbing`_ 을 참고하세요.





.. index:: erasure coding

Erasure Coding
--------------

erasure coded pool 은 각각의 object 를 ``K+M`` 청크로 저장합니다. ``K`` 는 데이터 청크이고, 
``M`` 은 코딩 청크라 불립니다. 이 pool 은 ``K+M`` 사이즈에 대해 설정을 가지며, 각 청크를 
acting set OSD 에 저장되도록 합니다. 청크의 구분은 object 의 attribute 로 저장됩니다. 

예를들어, erasure coded pool 이 다섯개의 OSD 들을 사용하도록 만들어 지면, (``K+M = 5``) 
두개가 없어져도 데이터를 보존합니다. (``M = 2``)

Reading and Writing Encoded Chunks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``ABCDEFGHI`` 라는 데이터를 가지고 있는 **NYAN** object 가 pool 에 쓰여질 때, erasure 
encoding 함수는 이 데이터를 세개의 청크 (``ABC``, ``DEF``, ``GHI``) 로 나눕니다. 
데이터의 길이가 ``K`` 의 배수가 아니면, 데이터는 ``K`` 의 배수가 되도록 채워집니다. 
이러한 함수는 두개의 코딩 청크를 (``YXY``, ``GQC``) 만듭니다. 각각의 청크는 acting set 
OSD 에 저장됩니다. 이 청크는 **NYAN** 이라는 같은 object 이름을 가지고 있지만, 다른 
OSD 에 저장됩니다. 청크가 만들어진 순서를 보존되어야 하며, 이 순서는 청크의 이름과 함께 
object 의 attribute (``shard_t``) 로 저장됩니다.

.. ditaa::
                            +-------------------+
                       name |       NYAN        |
                            +-------------------+
                    content |     ABCDEFGHI     |
                            +--------+----------+
                                     |
                                     |
                                     v
                              +------+------+
              +---------------+ encode(3,2) +-----------+
              |               +--+--+---+---+           |
              |                  |  |   |               |
              |          +-------+  |   +-----+         |
              |          |          |         |         |
           +--v---+   +--v---+   +--v---+  +--v---+  +--v---+
     name  | NYAN |   | NYAN |   | NYAN |  | NYAN |  | NYAN |
           +------+   +------+   +------+  +------+  +------+
    shard  |  1   |   |  2   |   |  3   |  |  4   |  |  5   |
           +------+   +------+   +------+  +------+  +------+
  content  | ABC  |   | DEF  |   | GHI  |  | YXY  |  | QGC  |
           +--+---+   +--+---+   +--+---+  +--+---+  +--+---+
              |          |          |         |         |
              |          |          v         |         |
              |          |       +--+---+     |         |
              |          |       | OSD1 |     |         |
              |          |       +------+     |         |
              |          |                    |         |
              |          |       +------+     |         |
              |          +------>| OSD2 |     |         |
              |                  +------+     |         |
              |                               |         |
              |                  +------+     |         |
              |                  | OSD3 |<----+         |
              |                  +------+               |
              |                                         |
              |                  +------+               |
              |                  | OSD4 |<--------------+
              |                  +------+
              |
              |                  +------+
              +----------------->| OSD5 |
                                 +------+


**NYAN** object 가 erasure coded pool 에서 읽혀질 때, decoding 함수는 세개의 청크를 
(``ABC`` 청크 1, ``GHI`` 청크 2, ``XYX`` 청크 4) 읽어들입니다. 그리고 나서 이 함수는 
이 청크들을 가지고 원본 데이터를 만들어냅니다. (``ABCDEFGHI``) decoding 함수는 청크 2 와 
청크 5가 없다는 것을 알고 있습니다. (이들은 'erasure' 라고 불립니다.) 아래 다이어그램에서 
**OSD4** 는 out 상태이기 떄문에 청크 5 는 읽지 못하며, **OSD2** 는 가장 느려 고려되지 않습니다.
이렇게 3개의 청크를 읽는 즉시 decoding 함수가 호출됩니다.

.. ditaa::
	                         +-------------------+
	                    name |       NYAN        |
	                         +-------------------+
	                 content |     ABCDEFGHI     |
	                         +---------+---------+
	                                   ^
	                                   |
	                                   |
	                           +-------+-------+
	                           |  decode(3,2)  |
	            +------------->+  erasures 2,5 +<-+
	            |              |               |  |
	            |              +-------+-------+  |
	            |                      ^          |
	            |                      |          | 
	            |                      |          |
	         +--+---+   +------+   +---+--+   +---+--+
	   name  | NYAN |   | NYAN |   | NYAN |   | NYAN |
	         +------+   +------+   +------+   +------+
	  shard  |  1   |   |  2   |   |  3   |   |  4   |
	         +------+   +------+   +------+   +------+
	content  | ABC  |   | DEF  |   | GHI  |   | YXY  |
	         +--+---+   +--+---+   +--+---+   +--+---+
	            ^          .          ^          ^
	            |    TOO   .          |          |
	            |    SLOW  .       +--+---+      |
	            |          ^       | OSD1 |      |
	            |          |       +------+      |
	            |          |                     |
	            |          |       +------+      |
	            |          +-------| OSD2 |      |
	            |                  +------+      |
	            |                                |
	            |                  +------+      |
	            |                  | OSD3 |------+
	            |                  +------+
	            |
	            |                  +------+
	            |                  | OSD4 | OUT
	            |                  +------+
	            |
	            |                  +------+
	            +------------------| OSD5 |
	                               +------+


Interrupted Full Writes
~~~~~~~~~~~~~~~~~~~~~~~

erasure coded pool 에서, up set 안의 primary OSD 는 모든 쓰기 오퍼레이션을 받습니다. 
이 primary OSD 는 데이터를 ``K+M`` 청크로 인코딩하여 다른 OSD 들에게 보내고, placement 
group 의 버전을 유지해야 할 책임을 가지고 있습니다.

아래의 다이어그램에서, erasure coded 된 PG 는 세 개의 OSD 로 지원하는 ``K = 2 + M = 1``
청크로 만들어집니다. placement group 의 acting set 은 **OSD 1**, **OSD 2** 그리고 
**OSD 3** 으로 만들어집니다. object 는 encode 되어 OSD 에 저장됩니다: 청크 ``D1v1`` 는
(i.e. Data chunk number 1, version 1) **OSD 1** 로, ``D1v1`` 은 **OSD 2**, 그리고 
``C1v1`` (i.e. Coding chunk number 1, version 1) 은 **OSD 3** 으로 저장됩니다. 
각각의 OSD 의 placement group 로그들은 같습니다. (i.e. ``1,1`` epoch 1, version 1)


.. ditaa::
     Primary OSD
    
   +-------------+
   |    OSD 1    |             +-------------+
   |         log |  Write Full |             |
   |  +----+     |<------------+ Ceph Client |
   |  |D1v1| 1,1 |      v1     |             |
   |  +----+     |             +-------------+
   +------+------+
          |
          |
          |          +-------------+
          |          |    OSD 2    |
          |          |         log |
          +--------->+  +----+     |
          |          |  |D2v1| 1,1 |
          |          |  +----+     |
          |          +-------------+
          |
          |          +-------------+
          |          |    OSD 3    |
          |          |         log |
          +--------->|  +----+     |
                     |  |C1v1| 1,1 |
                     |  +----+     |
                     +-------------+

아래 다이어그램에서 **OSD 1** 은 primary 이며, client로부터 **WRITE FULL** 을 수신합니다. 
이는 payload 가 object 의 일부를 덮어쓰는 대신 완전히 대체한다는 의미입니다. ojbect 버전 2 (v2) 
가 version 1 (v1) 을 덮어쓰기 위해 생성됩니다. **OSD 1** 은 payload 를 세개의 청크로 나눕니다: 
``D1v2`` (i.e. Data chunk number 1 version 2) 는 **OSD 1** 에, ``D2v2`` 는 **OSD 2**, 
``C1v2`` (i.e. Coding chunk nuber 1 version 2) 는 **OSD 3** 으로 위치합니다. 각각의 청크는
write operation 을 처리하고 PG 로그의 권한이 있는 버전을 유지하면서 각각의 OSD 에 보내어 집니다. 
OSD 가 청크를 write 하라는 메시지를 받으면, 이 변경사항을 반영하기 위해 PG 로그에도 새 항목이 생성됩니다.
에를들어, **OSD 3** 이 ``C1v2`` 를 저장하는 즉시, ``1,2`` ( i.e. epoch 1, version 2 ) 항목을 
로그에 추가합니다. OSD 는 비동기적으로 동작하기 때문에, 몇몇 청크 ( ``D2v2`` ) 들은 다른 청크가 
( ``C1v1``, ``D1v1`` ) 이미 disk 에 저장되었어도 아직 이동중일 수 있습니다.  

.. ditaa::

     Primary OSD
    
   +-------------+
   |    OSD 1    |
   |         log |
   |  +----+     |             +-------------+
   |  |D1v2| 1,2 |  Write Full |             |
   |  +----+     +<------------+ Ceph Client |
   |             |      v2     |             |
   |  +----+     |             +-------------+
   |  |D1v1| 1,1 |           
   |  +----+     |           
   +------+------+           
          |                  
          |                  
          |           +------+------+
          |           |    OSD 2    |
          |  +------+ |         log |
          +->| D2v2 | |  +----+     |
          |  +------+ |  |D2v1| 1,1 |
          |           |  +----+     |
          |           +-------------+
          |
          |           +-------------+
          |           |    OSD 3    |
          |           |         log |
          |           |  +----+     |
          |           |  |C1v2| 1,2 |
          +---------->+  +----+     |
                      |             |
                      |  +----+     |
                      |  |C1v1| 1,1 |
                      |  +----+     |
                      +-------------+


모든 것이 잘 된다면, 청크들은 acting set 인 각각의 OSD 에 잘 저장되고, 로그 ``last_compleate`` 
포인터는 ``1,1`` 에서 ``1.2`` 로 이동합니다.

.. ditaa::

     Primary OSD
    
   +-------------+
   |    OSD 1    |
   |         log |
   |  +----+     |             +-------------+
   |  |D1v2| 1,2 |  Write Full |             |
   |  +----+     +<------------+ Ceph Client |
   |             |      v2     |             |
   |  +----+     |             +-------------+
   |  |D1v1| 1,1 |           
   |  +----+     |           
   +------+------+           
          |                  
          |           +-------------+
          |           |    OSD 2    |
          |           |         log |
          |           |  +----+     |
          |           |  |D2v2| 1,2 |
          +---------->+  +----+     |
          |           |             |
          |           |  +----+     |
          |           |  |D2v1| 1,1 |
          |           |  +----+     |
          |           +-------------+
          |                  
          |           +-------------+
          |           |    OSD 3    |
          |           |         log |
          |           |  +----+     |
          |           |  |C1v2| 1,2 |
          +---------->+  +----+     |
                      |             |
                      |  +----+     |
                      |  |C1v1| 1,1 |
                      |  +----+     |
                      +-------------+


마지막으로, object 의 이전 버전의 청크를 저장하는 데 사용된 파일이 제거됩니다: 
**OSD 1** 의 ``D1v1``, **OSD 2** 의 ``D2v1``, 그리고 **OSD 3** 의 ``D2v1``

.. ditaa::
     Primary OSD
    
   +-------------+
   |    OSD 1    |
   |         log |
   |  +----+     |
   |  |D1v2| 1,2 |
   |  +----+     |
   +------+------+
          |
          |
          |          +-------------+
          |          |    OSD 2    |
          |          |         log |
          +--------->+  +----+     |
          |          |  |D2v2| 1,2 |
          |          |  +----+     |
          |          +-------------+
          |
          |          +-------------+
          |          |    OSD 3    |
          |          |         log |
          +--------->|  +----+     |
                     |  |C1v2| 1,2 |
                     |  +----+     |
                     +-------------+

어떠한 사고가 일어났다고 가정해 봅시다. 만약 ``D2v2`` 가 아직 이동 중일 때, 
**OSD 1** 이 down 상태가 된다면, object version 2 는 일부만 쓰여졌을 것입니다.: 
**OSD 3** 는 복구하기 어려운 상태의 청크를 가지게 됩니다. 두개의 청크 
(``D1v2``, ``D2v2``) 를 잃게 만들고, erasure coding parameter 인 ``K = 2``, 
``M = 1`` 은 세개로 복구하려면 적어도 두개의 청크가 필요합니다. **OSD 4** 는 
새로운 primary OSD 가 되고, ``last_complete`` log entry 를 찾습니다. 
(i.e., 이 entry 의 이전 오브젝트들은 모두 acting set OSD 에 사용 가능한 상태로 
알려져 있습니다.) 다이어그램에서 ``1,1`` 을 나타내며, 새로운 신뢰할 수 있는 log 의 
head 가 됩니다.

.. ditaa::
   +-------------+
   |    OSD 1    |
   |   (down)    |
   | c333        |
   +------+------+
          |                  
          |           +-------------+
          |           |    OSD 2    |
          |           |         log |
          |           |  +----+     |
          +---------->+  |D2v1| 1,1 |
          |           |  +----+     |
          |           |             |
          |           +-------------+
          |                  
          |           +-------------+
          |           |    OSD 3    |
          |           |         log |
          |           |  +----+     |
          |           |  |C1v2| 1,2 |
          +---------->+  +----+     |
                      |             |
                      |  +----+     |
                      |  |C1v1| 1,1 |
                      |  +----+     |
                      +-------------+
     Primary OSD
   +-------------+
   |    OSD 4    |
   |         log |
   |             |
   |         1,1 |
   |             |
   +------+------+
          


**OSD 3** 에서 찾을 수 있는 log entry 1,2 는 **OSD 4** 에 의해 제공되는 새로운 신뢰할 수 있
는 log 와는 다릅니다.: 이것은 버려지고, ``C1v2`` 청크를 포함하는 파일은 삭제되었습니다.
``D1v1`` 청크는 scrubbing 과정에서 erasure coding library 의 ``decode`` 함수로 
새롭게 구축됩니다. 그리고 새로운 primary 인 **OSD 4** 에 저장됩니다.



.. ditaa::
     Primary OSD
    
   +-------------+
   |    OSD 4    |
   |         log |
   |  +----+     |
   |  |D1v1| 1,1 |
   |  +----+     |
   +------+------+
          ^
          |
          |          +-------------+
          |          |    OSD 2    |
          |          |         log |
          +----------+  +----+     |
          |          |  |D2v1| 1,1 |
          |          |  +----+     |
          |          +-------------+
          |
          |          +-------------+
          |          |    OSD 3    |
          |          |         log |
          +----------|  +----+     |
                     |  |C1v1| 1,1 |
                     |  +----+     |
                     +-------------+

   +-------------+
   |    OSD 1    |
   |   (down)    |
   | c333        |
   +-------------+

더 알아보시려면, `Erasure Code Notes`_ 섹션을 참고하세요



Cache Tiering
-------------
에
cache tier 는 backing storage tier 에 저장된 일부 데이터로 client에 더 나은 I/O 퍼포먼스를 
제공합니다. Cache tiering 에 사용되는 장비는 빠르고 비싼 스토리지 디바이스로 구축되어야 합니다. 
(e.g., SSD) 더불어, erasure coded backing pool 등에 사용되는 장비는 느리고 싼 스토리지 
디바이스로 구성합니다. Ceph objecter 는 object 가 어디로 배치되어야 하는지 관리하고, tiering 
agent 는 object 가 cache 에서 backing storage 로 언제 flush 되어야 하는지를 결정합니다. 
그래서, cache tier 와 backing storage tier 는 Ceph Clinet 들에게 전혀 영향을 미치지 않습니다. 


.. ditaa:: 
           +-------------+
           | Ceph Client |
           +------+------+
                  ^
     Tiering is   |  
    Transparent   |              Faster I/O
        to Ceph   |           +---------------+
     Client Ops   |           |               |   
                  |    +----->+   Cache Tier  |
                  |    |      |               |
                  |    |      +-----+---+-----+
                  |    |            |   ^ 
                  v    v            |   |   Active Data in Cache Tier
           +------+----+--+         |   |
           |   Objecter   |         |   |
           +-----------+--+         |   |
                       ^            |   |   Inactive Data in Storage Tier
                       |            v   |
                       |      +-----+---+-----+
                       |      |               |
                       +----->|  Storage Tier |
                              |               |
                              +---------------+
                                 Slower I/O

더 많은 정보는, `Cache Tiering`_ 을 참고하세요.


.. index:: Extensibility, Ceph Classes

Extending Ceph
--------------

여러분은 'Ceph Classes' 라고 불리우는 shared object class 들을 만들어 Ceph 을 확장할 수 
있습니다. Ceph 은 동적으로 ``osd class dir`` 디렉토리에 젖아된 ``.so`` class 를 로드합니다. 
(i.e., 기본 값은 ``$libdir/rados-classes``) class 를 여러분이 구현하면, 여러분은 
Ceph Object Store 내의 네이티브 함수를 호출할 수 있는 능력을 가진 새로운 object method 들을 
만들거나, 라이브러리를 통해 통합하거나, 자신만의 class 함수를 만들 수 있습니다.

데이터 쓰기 시점에, Ceph Classes 는 네이티브 함수 혹은 클래스 함수들을 호출하고, inbound 데이터
에 대해 일련의 작업을 수행한 후 Ceph 이 원자적으로 적용하는 쓰기 트랜젝션을 생성할 수 있습니다.

데이터 읽기 시점에서는, Ceph Classes 는 또한 네이티브 함수 또는 클래스 함수를 호출하고, 
outbound 데이터에 대해 일련의 작업을 수행한 후에 client 에게 데이터를 전달할 수 있습니다.

.. topic:: Ceph Class Example

   특정 사이즈나 비율의 사진을 제공하는 컨텐츠 관리 시스템에서 Ceph class 는 inbound bitmap 
   이미지를 얻어와서, 특정한 비율의 사이즈로 자르거나, 리사이징하고, copyright 혹은 
   water마크를 추가해서 지적 재산권을 보호합니다.; 그리고는 object store 에 결과 
   이미지를 저장합니다. 


일반적인 구현에 대해서는, ``src/objclass/objclass.h``, ``src/fooclass.cc`` 그리고 
``src/barclass`` 를 참고하세요.


Summary
-------

Ceph Storage Cluster 는 굉장히 동적입니다. -- 마치 살아있는 유기체와 같습니다. 
따라서, 많은 스토리지들은 전형적인 서버의 CPU 와 RAM 에 최적화되지 못합니다. 하지만, Ceph 은 
가능합니다. heartbeat, perring, rebalancing, 실패 복구 등 작업에 대해, Ceph 의 offload 
들은 client 로부터 동작합니다. (중앙화된 게이트웨이로부터 오는 작업은 Ceph 의 아키텍처에 
포함되어 있지 않습니다.) 그리고 이러한 작업을 수행하기 위해서 OSD 의 컴퓨팅 파워를 사용합니다. 
`Hardware Recommendations`_ 와 `Network Config Reference`_ 에서, Ceph 이 
컴퓨팅 리소스를 어떻게 활용하는지 이해하기 위한 앞서 말한 컨셉을 조회하실 수 있습니다.

.. index:: Ceph Protocol, librados

Ceph Protocol
=============

Ceph Client 들은 Ceph Storage Cluster 와 상호작용 하기 위해 네이티브 프로토콜을 사용합니다. 
Ceph 은 사용자 정의 Ceph Client 를 여러분이 만들 수 있도록 이러한 기능을 ``librados`` 
라이브러리로 패키징 하였습니다.

.. ditaa::  
            +---------------------------------+
            |  Ceph Storage Cluster Protocol  |
            |           (librados)            |
            +---------------------------------+
            +---------------+ +---------------+
            |      OSDs     | |    Monitors   |
            +---------------+ +---------------+


Native Protocol and ``librados``
--------------------------------

모던 어플리케이션은 비동기적인 통신기능을 갖춘 간단한 object storage 인터페이스가 필요합니다. 
Ceph storage Cluster 는 이를 지원합니다. 이 인터페이스는 Ceph Cluster 를 통해
직접적이고 병렬적인해 접근을 제공합니다.

- Pool 관련 작업
- Snapshot 과 Copy-on-write Cloning
- Object 에 대한 읽기/쓰기 작업
  - 생성 및 삭제
  - 오브젝트 전체 혹은 Byte 단위
  - 추가 혹은 자르기
- XATTR 에 대한 Create/Set/Get/Remove 지원
- Key/Value 쌍에 대한 Create/Set/Get/Remove 지원
- Compount operation 과 dual-ack semantics
- Object Classes


.. index:: architecture; watch/notify

Object Watch/Notify
-------------------

client 는 object 를 지속적으로 확인하고 primary OSD 에 세션을 유지합니다. 
client 는 알림 메시지와 결과를 모든 watcher 들에게 보낼 수 있고, watcher 들이 알림을 받았을 때 
또한 알림을 받을 수 있습니다. 이는 client 를 어떠한 object 에 대한 동기화/통신 채널로 만들어 줍니다.


.. ditaa:: +----------+     +----------+     +----------+     +---------------+
           | Client 1 |     | Client 2 |     | Client 3 |     | OSD:Object ID |
           +----------+     +----------+     +----------+     +---------------+
                 |                |                |                  |
                 |                |                |                  |
                 |                |  Watch Object  |                  |               
                 |--------------------------------------------------->|
                 |                |                |                  |
                 |<---------------------------------------------------|
                 |                |   Ack/Commit   |                  |
                 |                |                |                  |
                 |                |  Watch Object  |                  |
                 |                |---------------------------------->|
                 |                |                |                  |
                 |                |<----------------------------------|
                 |                |   Ack/Commit   |                  |
                 |                |                |   Watch Object   |
                 |                |                |----------------->|
                 |                |                |                  |
                 |                |                |<-----------------|
                 |                |                |    Ack/Commit    |
                 |                |     Notify     |                  |               
                 |--------------------------------------------------->|
                 |                |                |                  |
                 |<---------------------------------------------------|
                 |                |     Notify     |                  |
                 |                |                |                  |
                 |                |<----------------------------------|
                 |                |     Notify     |                  |
                 |                |                |<-----------------|
                 |                |                |      Notify      |
                 |                |       Ack      |                  |               
                 |----------------+---------------------------------->|
                 |                |                |                  |
                 |                |       Ack      |                  |
                 |                +---------------------------------->|
                 |                |                |                  |
                 |                |                |        Ack       |
                 |                |                |----------------->|
                 |                |                |                  | 
                 |<---------------+----------------+------------------|
                 |                     Complete

.. index:: architecture; Striping

Data Striping
-------------

저장 장치는 throughout 한계를 가지고 있으며, 이는 퍼포먼스와 확장성에 영향을 미칩니다. 
따라서 저장 시스템은 throughout 과 퍼포먼스를 증가시키기 위해 종종 `striping`_ 을 지원합니다. 
-- 여러 장치에 순차적인 조각을 저장하는 것-- 가장 잘 알려진 데이터 striping 은 `RAID`_ 입니다. 
RAID 타입 중 Ceph 과 가장 유사한 것은 `RAID 0`_ 혹은 'striped volume' 입니다. 
Ceph 의 striping 은 RAID 0 striping 의 throughout 을 제공하고, n-way RAID 의 
미러링과 빠른 복구를 지원합니다.

Ceph 은 세가지 타입의 client 를 지원합니다.: Ceph Block Device, Ceph Filesystem, Ceph 
Object Storage. Ceph Client 는 자신의 데이터를 사용자에게 제공하는 표현 형식 (block device image, 
RESTful object, CephFS filesystem 디렉토리) 에서 Ceph Storage Cluster 를 위한 object 로 
변환합합니다.

.. tip:: Ceph Storage Cluster 에 저장되는 object 들은 stripe 되지 않습니다. 
   Ceph Object Storage, Ceph Block Device, 그리고 Ceph Filesystem 은 그들의 데이터를 
   다수의 Ceph Storage Cluster object 로 stripe 합니다. ``librados`` 를 이용해 Ceph 
   Storage Cluster 에 직접 Write 하는 Ceph Client 들은 이러한 이점을 얻기 위해서 수동으로 
   striping 을 수행해야 합니다.


가장 간단한 Ceph striping 포맷은 object 하나에 하나의 scripe 를 포함합니다. Ceph Client 들은 
object 가 최대 가용량이 될때까지 Stripe unit 을 Write 합니다. 그리고 나서, 추가적인 stripe 에 
대해서는 추가적인 object 를 생성합니다. 가장 단순한 형태의 striping 은 작은 block device 이미지나 
Swift object, CephFS 파일들에 대해서는 효과적일 수 있습니다. 그러나, 이러한 간단한 형태는 
placement group 을 통해 데이터를 분산하는 Ceph 의 능력을 최대한으로 활용하지 못합니다. 동시에 
그리 많은 퍼포먼스 향상을 주지 못합니다. 다음의 다이어그램은 가장 간단한 형태의 striping 을 나타냅니다.

.. ditaa::              
                        +---------------+
                        |  Client Data  |
                        |     Format    |
                        | cCCC          |
                        +---------------+
                                |
                       +--------+-------+
                       |                |
                       v                v
                 /-----------\    /-----------\
                 | Begin cCCC|    | Begin cCCC|
                 | Object  0 |    | Object  1 |
                 +-----------+    +-----------+
                 |  stripe   |    |  stripe   |
                 |  unit 1   |    |  unit 5   |
                 +-----------+    +-----------+
                 |  stripe   |    |  stripe   |
                 |  unit 2   |    |  unit 6   |
                 +-----------+    +-----------+
                 |  stripe   |    |  stripe   |
                 |  unit 3   |    |  unit 7   |
                 +-----------+    +-----------+
                 |  stripe   |    |  stripe   |
                 |  unit 4   |    |  unit 8   |
                 +-----------+    +-----------+
                 | End cCCC  |    | End cCCC  |
                 | Object 0  |    | Object 1  |
                 \-----------/    \-----------/
   
큰 이미지, 거대한 S3 혹은 Swift object (e.g., video), 또는 큰 CephFS 디렉토리를 예상한다면, 
Client 데이터를 object set 내의 여러 object 에 striping 함으로서 상당한 읽기/쓰기 성능의 향상 
을 할 수 있습니다. Client 가 stripe unit 을 해당 object 에 병렬로 쓸 때, 상당한 Write 성능이 
발생합니다. obejct 들이 각기 다른 placement group 에 매핑되어 있고, 나아가 각기 다른 OSD 에 매핑 
되어 있기 때문에, 각각의 병렬적인 Write 는 최대의 속도로 일어납니다. 하나의 디스크에 대한 쓰기는 
head 의 움직임 (e.g. 6ms per seek) 과 단일 장치의 bandwidth (e.g. 100MB/s) 때문에 제한됩니다. 
Ceph 은 드라이브당 seek 수를 줄이고 여러 드라이브의 throughput 을 합할 수 있어 더 빠른 Write (혹은 
Read) 속도를 수행합니다.

.. note:: Striping 은 object 레플리카와는 독립적입니다. CRUSH 를 통해 OSD 로 레플리케이션 되기 
   때문에, stripe 들은 자동으로 레플리케이션 됩니다.

아래 다이어그램에서, client 데이터는 첫번째 stripe unit 이 ``object 0`` 안의 
``stripe unit 0`` 이고, 네번째 stripe unit 이 ``object 3`` 안의 ``stripe unit 3`` 
인 object set (다이어그램에서 ``object set 1``) 내에 stripe 됩니다. 
네번째 stripe 를 write 하고, client 는 object set 이 가득 찻는지 결정합니다. 만약 
object set 이 가득 차지 않았다면, client 는 다시 첫번째 object 부터 stripe 를 write 하기 
시작합니다. (다이어그램에서 ``object 0``) object set 이 가득 차면, client 는 새로운 object 
set 을 만듭니다. (다이어그램에서 ``object set 2``) 그리고는 새로운 object set 의 첫번째 
object (``object 4``) 안의 첫번째 stripe (``stripe unit 16``) 에 write 를 시작합니다.

.. ditaa::                 
                          +---------------+
                          |  Client Data  |
                          |     Format    |
                          | cCCC          |
                          +---------------+
                                  |
       +-----------------+--------+--------+-----------------+
       |                 |                 |                 |     +--\
       v                 v                 v                 v        |
 /-----------\     /-----------\     /-----------\     /-----------\  |   
 | Begin cCCC|     | Begin cCCC|     | Begin cCCC|     | Begin cCCC|  |
 | Object 0  |     | Object  1 |     | Object  2 |     | Object  3 |  |
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  |
 |  unit 0   |     |  unit 1   |     |  unit 2   |     |  unit 3   |  |
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  +-\ 
 |  unit 4   |     |  unit 5   |     |  unit 6   |     |  unit 7   |    | Object
 +-----------+     +-----------+     +-----------+     +-----------+    +- Set 
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |    |   1
 |  unit 8   |     |  unit 9   |     |  unit 10  |     |  unit 11  |  +-/
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  |
 |  unit 12  |     |  unit 13  |     |  unit 14  |     |  unit 15  |  |
 +-----------+     +-----------+     +-----------+     +-----------+  |
 | End cCCC  |     | End cCCC  |     | End cCCC  |     | End cCCC  |  |
 | Object 0  |     | Object 1  |     | Object 2  |     | Object 3  |  |  
 \-----------/     \-----------/     \-----------/     \-----------/  |
                                                                      |
                                                                   +--/
  
                                                                   +--\
                                                                      |
 /-----------\     /-----------\     /-----------\     /-----------\  |   
 | Begin cCCC|     | Begin cCCC|     | Begin cCCC|     | Begin cCCC|  |
 | Object  4 |     | Object  5 |     | Object  6 |     | Object  7 |  |  
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  |
 |  unit 16  |     |  unit 17  |     |  unit 18  |     |  unit 19  |  |
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  +-\ 
 |  unit 20  |     |  unit 21  |     |  unit 22  |     |  unit 23  |    | Object
 +-----------+     +-----------+     +-----------+     +-----------+    +- Set
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |    |   2 
 |  unit 24  |     |  unit 25  |     |  unit 26  |     |  unit 27  |  +-/
 +-----------+     +-----------+     +-----------+     +-----------+  |
 |  stripe   |     |  stripe   |     |  stripe   |     |  stripe   |  |
 |  unit 28  |     |  unit 29  |     |  unit 30  |     |  unit 31  |  |
 +-----------+     +-----------+     +-----------+     +-----------+  |
 | End cCCC  |     | End cCCC  |     | End cCCC  |     | End cCCC  |  |
 | Object 4  |     | Object 5  |     | Object 6  |     | Object 7  |  |  
 \-----------/     \-----------/     \-----------/     \-----------/  |
                                                                      |
                                                                   +--/

다음 세 개의 중요한 변수가 Ceph 이 데이터를 어떻게 stripe 하는지 결정합니다.

- **Object size:** Ceph Storage cluster 의 Object 들은 설정 가능한 크기 
  (e.g., 2MB, 4MB, etc.) 의 최대치가 존재합니다. object 의 크기는 많은 stripe unit 
  을 수용할 수 있을만큼 커야 하며, stripe unit 의 배수가 되어야 합니다.

- **Stripe Width:** Stripe 들은 설정 가능한 unit 사이즈를 가집니다. (e.g., 64kb) 
  Ceph Client 는 마지막 stripe unit 을 제외하고 나머지를 동일한 사이즈의 stripe unit 
  으로 쪼개고, 이를 object 에 write 합니다. stripe width 는, object 가 많은 stripe 
  unit 을 포함할 수 있도록 Object 크기의 약수가 되어야 합니다.

- **Stripe Count:** Ceph Client 는 object 에 stripe count 로 결정되어지는 
  stirpe unit 들의 집합을 write 합니다. 이런 object 들을 object set 이라고 
  부릅니다. Ceph Client 는 object set 내의 마지막 object 에 write 하고 나면 
  다음 object set 의 첫번째 object 로 돌아갑니다.

.. important:: production 레벨로 클러스터를 배포하기 전에, 여러분의 striping 설정의 
   성능을 테스트해야 합니다. 여러분은 data 가 stripe 되어지고 object 에 쓰여진 이후로 
   부터는 절대 striping 변수를 변경할 수 없습니다.

일단 Ceph Client 가 데이터를 stripe unit 들로 stripe 하고, object 로 매핑하고 나면, 
저장장치에 파일로써 저장되기 전 Ceph 의 CRUSH 알고리즘이 object 들을 placement group 
으로 매핑하고 placement groupe 들은 Ceph OSD Daemon 에 매핑되게 됩니다.

.. note:: client 는 하나의 pool 에 데이터를 쓰기 때문에, 모든 데이터는 같은 pool 에 있는 
   placement group 의 object 에 stripe 됩니다. 따라서 이들은 모두 같은 CRUSH map 을 
   사용하며 같은 접근 권한을 가집니다.

.. index:: architecture; Ceph Clients

Ceph Clients
============

Ceph Client 들은 여러 서비스 인터페이스를 포함합니다.

- **Block Devices:** :term:`Ceph Block Device` (a.k.a., RBD) 는 사이즈 변경이 
  가능한 thin-provisioning 방식의 block device 를 제공합니다. snapshot 과 clone 
  또한 지원합니다. Ceph 높은 성능을 위해 클러스터 전역으로 block device 를 stripe 합니다. 
  Ceph 은 가상화된 시스템의 kernel object overhead 를 방지하면서 ``librbd`` 를 직접 
  사용하는 kernel object (KO) 와 QEMU hypervisor 를 지원합니다.

- **Object Storage:** :term:`Ceph Object Storage` (a.k.a., RGW) 는 Amazon S3 와 
  Openstack Swift 와 호환 가능한 RESTful API 를 제공합니다.

- **Filesystem**: :term:`Ceph Filesystem` (CephFS) 는 ``mount`` 혹은 user space 
  filesystem (FUSE) 으로 사용 가능한 POSIX 를 준수하는 파일시스템 서비스를 제공합니다.

Ceph 은 확장성과 고가용성을 위해 OSD, MDS, Monitor 등 추가적인 인스턴스를 실행합니다. 
다음 다이어그램은 Ceph 의 high-level 아키텍처를 묘사하고 있습니다.

.. ditaa::
            +--------------+  +----------------+  +-------------+
            | Block Device |  | Object Storage |  |   CephFS    |
            +--------------+  +----------------+  +-------------+            

            +--------------+  +----------------+  +-------------+
            |    librbd    |  |     librgw     |  |  libcephfs  |
            +--------------+  +----------------+  +-------------+

            +---------------------------------------------------+
            |      Ceph Storage Cluster Protocol (librados)     |
            +---------------------------------------------------+

            +---------------+ +---------------+ +---------------+
            |      OSDs     | |      MDSs     | |    Monitors   |
            +---------------+ +---------------+ +---------------+


.. index:: architecture; Ceph Object Storage

Ceph Object Storage
-------------------

Ceph Object Storage daemon 인 ``radosgw`` 는, object 와 metadata 를 저장하기 위한 
RESTful_ HTTP API 를 제공하는 FastCGI 서비스 입니다. radosgw 는 Ceph Storage Cluster 
최상위 계층에서 자신만의 data foramat 과 함께 자신만의 유저 데이터베이스, 인증, 접근 관리를 
유지합니다. RADOS Gateway 는 Openstack Swift 혹은 Amazon S3 와 호환 가능한 통합된 
namespace 를 가집니다. 예를 들어, 여러분은 S3 API 를 이용해 data 를 write 하고, 다른 
어플리케이션에서 Swift API 로 데이터를 읽을 수 있습니다.

.. topic:: S3/Swift Objects 과 Store Cluster Objects 의 비교

   Ceph 의 object Storage 는 저장하는 데이터를 부르기 위해서 *object* 라는 용어를 사용합니다. 
   S3 와 Swift object 는 Ceph 이 Ceph Storage Cluster 에 write 하는 object 와는 같지 
   않습니다. Ceph Object Storage object 들은 Ceph Storage Cluster object 들과 매핑됩니다. 
   S3 와 Swift object 들은 이와 1:1 로 대응되지는 않습니다. S3 나 Swift object 를 여러 Ceph 
   Object 로 매핑하는 것이 가능하니다.

See `Ceph Object Storage`_ for details.


.. index:: Ceph Block Device; block device; RBD; Rados Block Device

Ceph Block Device
-----------------

Ceph Block Device 는 block device image 를 Ceph Storage Cluster 내의 여러 object 로 
stripe 합니다. 이 각각의 object 들은 placement group 에 매핑되어 있고, 분산되어 있으며, 
이러한 placement group 들은 또한 클러스터의 ``ceph-osd`` 데몬으로 분리되어 흩뿌려져 있습니다.

.. important:: Striping 은 RBD block device 들이 단일 서버가 할 수 있는 것보다 더 나은 
   성능을 제공할 수 있습니다.

Thin-provisioning 된 Snapshot 이 가능한 Ceph Block Device 들은 가상화와 클라우드 컴퓨팅 
을 위한 매력적인 옵션입니다. 가상머신 시나리오에서, 사람들은 일반적으로 호스트머신이 ``librbd`` 를 
사용하여 block device 서비스를 게스트에게 제공할 수 있는 환경의 QEMU/KVM 에 Ceph 
Block Device 를 ``rbd`` 네트워크 스토리지 드라이버와 함께 배포합니다. 또한 많은 클라우드 컴퓨팅 
스택들이 hypervisor 와 통합하기 위해 ``libvirt`` 를 사용합니다. 여러분은 Openstack 이나 
CloudStack 등의 솔루션을 지원하기 위해 QEMU, ``libvirt`` 와 함께 thin-provisioning 된 
Ceph Block Device 를 사용할 수 있습니다.

현재 다른 hypervisor 들에게는 ``librbd`` 를 지원하지 않기 때문에, 여러분은 클라이언트들에게 
block device 를 제공하기 위해서 Ceph Block Device kernel object를 사용할 수도 있습니다. 
Xen 같은 다른 가상화 기술 또한 Ceph Block Device kernel object 에 접근할 수 있으며, 
``rbd`` 커맨드라인 툴을 이용하면 됩니다.

.. index:: CephFS; Ceph Filesystem; libcephfs; MDS; metadata server; ceph-mds

.. _arch-cephfs:

Ceph Filesystem
---------------

Ceph Filesystem (CephFS) 은 object 를 기반으로 하는 Ceph Storage Cluster 의 
가장 상위 레이어의 서비스로서 POSIX 를 준수하는 파일시스템을 제공합니다. CephFS 파일들은 
Ceph Storage Cluster 의 object 들과 매핑되어입니다. Ceph Client 들은 CephFS 
파일시스템을 kernel object 혹은 Filesystem in User Space (FUSE) 로 마운트합니다.

.. ditaa::
            +-----------------------+  +------------------------+
            | CephFS Kernel Object  |  |      CephFS FUSE       |
            +-----------------------+  +------------------------+            

            +---------------------------------------------------+
            |            CephFS Library (libcephfs)             |
            +---------------------------------------------------+

            +---------------------------------------------------+
            |      Ceph Storage Cluster Protocol (librados)     |
            +---------------------------------------------------+

            +---------------+ +---------------+ +---------------+
            |      OSDs     | |      MDSs     | |    Monitors   |
            +---------------+ +---------------+ +---------------+

Ceph Filesystem 서비스는 Ceph Metadata Server (MDS) 를 포함합니다. MDS 의 목적은 
모든 파일시스템의 메타데이터 (directory, file ownership, access mode, 등등) 을 
고 가용성의 Ceph Metadata Server 에 저장하는 것입니다. MSD (``ceph-mds`` 라 불립니다.) 
의 존재 이유는, ``ls``나 ``cd`` 같은 단순한 파일시스템 명령들이 Ceph OSD Daemon 들에게 
불필요한 부하를 줄 수 있기 때문입니다. 따라서 메타데이터를 데이터와 분리하는 것은 Ceph Storage 
Cluster 에 부하 없이 높은 성능의 서비스를 제공할 수 있다는 것을 의미합니다.

CephFS 는 메타데이터는 MDS 에 저장하고, 파일의 데이터들은 하나나 그 이상의 Ceph Storage 
Cluster object 에 저장함으로서 데이터로부터 메타데이터를 분리하였습니다. Ceph 파일시스템은 
POSIX 호환을 목표로 합니다. ``ceph-mds`` 는 단일 프로세스로 동작하거나, 고가용성과 확장성을 
위해 여러 물리 머신에 배포될 수 있습니다.

- **High Availability**: 사용하지 않고 있는 여분의 ``ceph-mds`` 인스턴스는 `standby` 
  상태로 존재할 수 있습니다. `standby` 상태는 `active` 상태의 ``ceph-mds`` 가 다운되었을 
  때, 그 역할을 받아 수행합니다. 이 작업은 journal 을 포함한 모든 데이터가 RADOS 에 저장되어 
  있기 때문에 간단합니다. 이러한 작업은 ``ceph-mon`` 에 의해 자동으로 이루어집니다.

- **Scalability**: 여러 ``ceph-mds`` 인스턴스는 `active` 상태로 존재할 수 있으며, 이들은 
  디렉토리 트리를 모든 `active` 서버에 효율적으로 분산하면서 서브트리로 쪼갤 수 있습니다. 
  (단일 busy 디렉토리를 샤딩하는 것 또한 가능합니다.) 

`standby` 와 `active` 등의 조합도 가능합니다. 예를 들어, 확장성을 위해 3개의 `active` ``ceph-mds``
 fmf enrh, 고가용성을 위해 하나의 `standby` 인스턴스를 둡니다.




.. _RADOS - A Scalable, Reliable Storage Service for Petabyte-scale Storage Clusters: https://ceph.com/wp-content/uploads/2016/08/weil-rados-pdsw07.pdf
.. _Paxos: https://en.wikipedia.org/wiki/Paxos_(computer_science)
.. _Monitor Config Reference: ../rados/configuration/mon-config-ref
.. _Monitoring OSDs and PGs: ../rados/operations/monitoring-osd-pg
.. _Heartbeats: ../rados/configuration/mon-osd-interaction
.. _Monitoring OSDs: ../rados/operations/monitoring-osd-pg/#monitoring-osds
.. _CRUSH - Controlled, Scalable, Decentralized Placement of Replicated Data: https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf
.. _Data Scrubbing: ../rados/configuration/osd-config-ref#scrubbing
.. _Report Peering Failure: ../rados/configuration/mon-osd-interaction#osds-report-peering-failure
.. _Troubleshooting Peering Failure: ../rados/troubleshooting/troubleshooting-pg#placement-group-down-peering-failure
.. _Ceph Authentication and Authorization: ../rados/operations/auth-intro/
.. _Hardware Recommendations: ../start/hardware-recommendations
.. _Network Config Reference: ../rados/configuration/network-config-ref
.. _Data Scrubbing: ../rados/configuration/osd-config-ref#scrubbing
.. _striping: https://en.wikipedia.org/wiki/Data_striping
.. _RAID: https://en.wikipedia.org/wiki/RAID
.. _RAID 0: https://en.wikipedia.org/wiki/RAID_0#RAID_0
.. _Ceph Object Storage: ../radosgw/
.. _RESTful: https://en.wikipedia.org/wiki/RESTful
.. _Erasure Code Notes: https://github.com/ceph/ceph/blob/40059e12af88267d0da67d8fd8d9cd81244d8f93/doc/dev/osd_internals/erasure_coding/developer_notes.rst
.. _Cache Tiering: ../rados/operations/cache-tiering
.. _Set Pool Values: ../rados/operations/pools#set-pool-values
.. _Kerberos: https://en.wikipedia.org/wiki/Kerberos_(protocol)
.. _Cephx Config Guide: ../rados/configuration/auth-config-ref
.. _User Management: ../rados/operations/user-management
