# 🛠️ Ceph Korean Documentation
> Korean translation of [ceph Documentation](http://docs.ceph.com/docs/luminous/#), With [Korea Ceph User Group - Facebook](https://www.facebook.com/groups/620899444961207)

![start!](https://user-images.githubusercontent.com/16697306/50839583-f30fb280-13a3-11e9-9e08-00fea29dba95.png)
> [이곳](http://13.124.133.86/) 에서 임시로 서빙중인 문서를 열람하실 수 있습니

## 소개
Ceph Documentation 을 기존 레이아웃 그대로 사용하면서 번역하며 작업할 수 있도록 커스텀된 레포지토리입니다.

[mimic](https://github.com/ceph/ceph/tree/mimic) 기준으로 구성했으며, Stable Release 때마다 diff 를 추적하여 업데이트할 예정입니다.

ceph/doc 디렉토리를 doc-ko 디렉토리로 대체하여 ceph 레포지토리에 가이드 하는 데로 빌드합니다. 다음 레포지토리 ([drunkard/ceph-Chinese-doc](https://github.com/drunkard/ceph-Chinese-doc)) 에서 영감을 받아 제작하였습니다.

## 번역 가이드
1. Ceph 을 구성하는 요소들 (OSD, Monitor, MDS, object, placement group...) 은 한글로 번역하지 않고 그대로 씁니다.
> ex) Ceph Client 가 Ceph Monitor 에 바인딩되면, Cluster Map 의 최신 복제본을 검색합니다.
2. 상위 제목 및 부제목들은 원문 그대로 사용합니다.
> 고유 링크를 가지고 있으며, 하나라도 다른 형태로 번역되면, 올바르게 접근이 불가능합니다.
3. 하나의 문서 파일 당 PR 하나로 번역합니다. 또한, 번역이 완료되면 모든 커밋을 하나로 묶어 Rebase Merge 합니다.

## 문서 빌드 & 번역하기 
기본적으로 Ceph 레포지토리의 [공식 가이드](https://github.com/ceph/ceph#building-the-documentation) 를 따릅니다. 

1. 프로젝트를 포크합니다.

2. 포크한 프로젝트를 클론받고, Submodule Ceph 을 업데이트 합니다.
```bash
git clone https://github.com/{user}/ceph-korean-doc.git
cd ceph-korean-doc
git submodule update --init
cd ceph
git checkout mimic
git pull
cd ..
```

3. 디펜던시를 설치합니다.
```bash
sudo apt-get install `cat ceph/doc_deps.dep.txt`
```
> Ubuntu 환경의 경우, `doc_deps.deb.txt` 파일로 디펜던시를 설치하여 빌드할 수 있지만, 다른 환경의 경우에는 테스트해보지 못했습니다. 혹시 성공하였다면 언제든지 PR 보내주세요~

4. 문서를 번역합니다.

> doc-ko/ 가 주 프로젝트 경로입니다.

5. 문서를 빌드합니다.
```
./build.sh
Top Level States:  ['RecoveryMachine']
Processing /home/sungjunyoung/Naver/sources/ceph-korean-doc/ceph/src/pybind/rados
Building wheels for collected packages: rados
  Running setup.py bdist_wheel for rados ... 
...
```

6. serve.sh 를 실행하여 `localhost:8080` 에서 확인합니다.
```
./serve.sh
Serving doc at port: http://localhost:8080
```

## PR 올리기
번역 후 commit 하기 전, `./clean.sh` 를 실행하여 submodule 을 원상복구 해줍니다. diff 에 ceph/ 하위 디렉토리가 잡히지 않도록 하여 푸시하고, ceph-korea/master 브랜치로 PR 을 올립니다.
