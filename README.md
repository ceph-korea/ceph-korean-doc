# Ceph Korean Documentation
> Korean translation of [ceph Documentation](http://docs.ceph.com/docs/luminous/#), With [Korea Ceph User Group - Facebook](https://www.facebook.com/groups/620899444961207)

## 소개
Ceph Documentation 을 기존 레이아웃 그대로 사용하면서 번역하며 작업할 수 있도록 커스텀된 레포지토리입니다.

현재 (19.01.08) Stable 최신 버전인 [v13.2.4](https://github.com/ceph/ceph/tree/v13.2.4) 기준으로 구성했으며, Stable Release 때마다 diff 를 추적하여 업데이트할 예정입니다.

ceph/doc 디렉토리를 doc-ko 디렉토리로 대체하여 ceph 레포지토리에 가이드 하는 데로 빌드합니다. 다음 레포지토리 ([drunkard/ceph-Chinese-doc](https://github.com/drunkard/ceph-Chinese-doc)) 에서 영감을 받아 제작하였습니다.

## 문서 빌드 & 번역하기 
기본적으로 Ceph 레포지토리의 [공식 가이드](https://github.com/ceph/ceph#building-the-documentation) 를 따릅니다. 

1. 프로젝트를 클론받고, Submodule Ceph 을 업데이트 합니다.
```bash
git clone https://github.com/ceph-korea/ceph-korean-doc.git
cd ceph-korean-doc
git submodule update --init
cd ceph
git checkout v13.2.4
```

2. 디펜던시를 설치합니다.
```bash
sudo apt-get install `cat ceph/doc_deps.dep.txt`
```
> Ubuntu 환경의 경우, `doc_deps.deb.txt` 파일로 디펜던시를 설치하여 빌드할 수 있지만, 다른 환경의 경우에는 테스트해보지 못했습니다. 혹시 성공하였다면 언제든지 PR 보내주세요~

3. 문서를 번역합니다.

> doc-ko/ 가 주 프로젝트 경로입니다. 번역할 브랜치를 생성 후 번역을 시작합니다.

4. 문서를 빌드합니다.
```
./build.sh
Top Level States:  ['RecoveryMachine']
Processing /home/sungjunyoung/Naver/sources/ceph-korean-doc/ceph/src/pybind/rados
Building wheels for collected packages: rados
  Running setup.py bdist_wheel for rados ... 
...
```

5. serve.sh 를 실행하여 `localhost:8080` 에서 확인합니다.
```
./serve.sh
Serving doc at port: http://localhost:8080
```

## PR 올리기
번역 후 commit 하기 전, `./clean.sh` 를 실행하여 submodule 을 원상복구 해줍니다. diff 에 ceph/ 하위 디렉토리가 잡히지 않도록 하여 푸시합니다.
