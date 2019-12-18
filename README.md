# 🛠️ Ceph Korean Documentation
> Korean translation of [ceph Documentation](http://docs.ceph.com/docs/nautilus/#), With [Korea Ceph User Group - Facebook](https://www.facebook.com/groups/620899444961207)

![image](https://user-images.githubusercontent.com/16697306/62953575-bd92e200-be28-11e9-9594-66267b69f37f.png)
> [이곳](http://211.110.139.241/) 에서 임시로 서빙중인 문서를 열람하실 수 있습니다. 

## 소개
Ceph Documentation 을 기존 레이아웃 그대로 사용하면서 번역하며 작업할 수 있도록 커스텀된 레포지토리입니다.

ceph/doc 디렉토리를 ceph-korean-doc 디렉토리로 대체하여 ceph 레포지토리에 가이드 하는 데로 빌드합니다. 다음 레포지토리 ([drunkard/ceph-Chinese-doc](https://github.com/drunkard/ceph-Chinese-doc)) 에서 영감을 받아 제작하였습니다.

## 번역 가이드
[Wiki](https://github.com/ceph-korea/ceph-korean-doc/wiki) 페이지를 참고해 주세요.

## 문서 빌드 & 번역하기 
기본적으로 Ceph 레포지토리의 [공식 가이드](https://github.com/ceph/ceph#building-the-documentation) 를 따릅니다. 

1. 프로젝트를 포크합니다.

2. 포크한 프로젝트를 클론받고, Submodule Ceph 을 업데이트 합니다.
```bash
git clone https://github.com/{user}/ceph-korean-doc.git
cd ceph-korean-doc
git submodule update --init
```

3. 디펜던시를 설치합니다.
```bash
sudo apt-get install `cat ceph/doc_deps.dep.txt`
```
> Ubuntu 환경의 경우, `doc_deps.deb.txt` 파일로 디펜던시를 설치하여 빌드할 수 있지만, 다른 환경의 경우에는 테스트해보지 못했습니다. 혹시 성공하였다면 언제든지 PR 보내주세요~

4. 문서를 번역합니다.

> `ceph-korean-directory/` 가 주 프로젝트 경로입니다.

5. 문서를 빌드합니다.
```
$ make build
Top Level States:  ['RecoveryMachine']
Processing /home/sungjunyoung/Naver/sources/ceph-korean-doc/ceph/src/pybind/rados
Building wheels for collected packages: rados
  Running setup.py bdist_wheel for rados ... 
...
```

6. `make serve` 를 실행하여 `localhost:8080` 에서 확인합니다.
```
$ make serve
Serving doc at port: http://localhost:8080
```

## PR 올리기
하나의 문서를 모두 번역 완료하였다면, 꼭 `completed` 파일에 `ceph-korean-doc` 의 상대경로로 문서의 경로를 작성해 주세요. (추후 diff 추적을 위함입니다.)

## Diff 체크
upstream 에 계속해서 업데이트가 일어나 이미 번역된 문서가 변경되었을 때, diff 체크를 수행하여 해당 부분의 번역을 따라갑니다.

```bash
$ make diff
# 특정 브랜치를 기준으로 추적하려면 다음과 같이 실행합니다.
$ make diff BRANCH=nautilus
./hack/clean.sh
No local changes to save
./hack/diff.sh
Cloning into 'ceph.new'...
remote: Enumerating objects: 172, done.
remote: Counting objects: 100% (172/172), done.
remote: Compressing objects: 100% (166/166), done.
remote: Total 646362 (delta 8), reused 155 (delta 6), pack-reused 646190
Receiving objects: 100% (646362/646362), 298.11 MiB | 8.60 MiB/s, done.
Resolving deltas: 100% (513639/513639), done.

Diff file generated, check /tmp/ceph-korean-doc.diff
```

이후에 `/tmp/ceph-korean-doc.diff` 경로에 생성된 diff 파일을 체크합니다.