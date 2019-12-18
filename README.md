![Ceph Version](https://img.shields.io/badge/ceph%20version-nautilus%20(bff2ab99c62ed4aa28c5cd5c177b65abd8c992e3)-red)

# 🛠️ Ceph Korean Documentation
> Korean translation of [ceph Documentation](http://docs.ceph.com/docs/nautilus/#), With [Korea Ceph User Group - Facebook](https://www.facebook.com/groups/620899444961207)

![image](https://user-images.githubusercontent.com/16697306/62953575-bd92e200-be28-11e9-9594-66267b69f37f.png)
> [이곳](http://211.110.139.241/) 에서 임시로 서빙중인 문서를 열람하실 수 있습니다. 

## 소개
Ceph Documentation 을 기존 레이아웃 그대로 사용하면서 번역하며 작업할 수 있도록 커스텀된 레포지토리입니다.

ceph/doc 디렉토리를 ceph-korean-doc 디렉토리로 대체하여 ceph 레포지토리에 가이드 하는 데로 빌드합니다. 다음 레포지토리 ([drunkard/ceph-Chinese-doc](https://github.com/drunkard/ceph-Chinese-doc)) 에서 영감을 받아 제작하였습니다.

## 번역 가이드
> `ceph-korean-directory/` 가 주 한글 문서 경로입니다.

Ceph Korean Documentation 은 가능한 일관된 번역 품질을 유지하고자 노력하고 있습니다. Ceph 의 고유 단어 및 일부 기술 용어들은 더 나은 이해를 위해 되도록 원문을 사용합니다. 

원문에 대한 번역은 아래를 참고해 주세요.
- 색인: [`./trans/index.csv`](https://github.com/ceph-korea/ceph-korean-doc/blob/master/trans/index.csv)
- 단어: [`./trans/word.csv`](https://github.com/ceph-korea/ceph-korean-doc/blob/master/trans/word.csv)

`make querytrans` 명령을 사용하여 원문 단어들에 대한 한글 번역을 조회할 수 있습니다. 
```
$ make querytrans WORD="client"
./hack/querytrans.sh

Results:
./trans/word.csv: Client -> 클라이언트
```

만약 `make querytrans` 를 통해 쿼리했을 때 단어가 조회되지 않으면, `./trans/*.csv` 파일을 수정하여 단어를 추가해 주세요.

## 문서 빌드 및 로컬 서빙
기본적으로 Ceph 레포지토리의 [공식 가이드](https://github.com/ceph/ceph#building-the-documentation) 를 따릅니다. 

프로젝트를 클론받고, 아래와 같이 submodule update 를 실행합니다. 
```bash
git clone https://github.com/ceph-korea/ceph-korean-doc.git
cd ceph-korean-doc
git submodule update --init
```

### Docker
1. 문서 빌드
```
make build_docker
```

2. 로컬 서빙 및 확인
```
make serve_docker
```

### Ubuntu
1. 디펜던시 설치
```bash
sudo apt-get install `cat ceph/doc_deps.dep.txt`
```

2. 문서 빌드
```
$ make build
Top Level States:  ['RecoveryMachine']
Processing /home/sungjunyoung/Naver/sources/ceph-korean-doc/ceph/src/pybind/rados
Building wheels for collected packages: rados
  Running setup.py bdist_wheel for rados ... 
...
```

3. 로컬 서빙 및 확인
```
$ make serve
Serving doc at port: http://localhost:8080
```

## PR 가이드
하나의 문서를 모두 번역 완료하였다면, 꼭 `./completed` 파일에 `ceph-korean-doc` 의 상대경로로 문서의 경로를 작성해 주세요. (추후 diff 추적을 위함입니다.)

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