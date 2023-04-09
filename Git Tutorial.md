# Git Tutorial

Git : Source Code를 효율적으로 관리하기 위해 개발된 '분산형 버전 관리 시스템'

Git Repository : 파일이 변경 이력 별로 구분되어 저장되는 공간

- 원격 저장소 (Remote) : 여러 사람이 함께 공유하는 저장소

- 로컬 저장소 (Local) : 내 PC에 파일이 저장되는 개인 전용 저장

Git Commit : File 및 Folder의 추가/변경 사항을 저장소에 기록 (40자 제한)

-   line 1 : Commit 내의 변경 내용을 요약
    line 2 : (empty)
    line 3 : 변경한 이유

Git Work Tree & Index

    Work Tree : Git 폴더
    Index : Commit을 실행하기 전 저장소와 Work tree 사이에 존재하는 공

---

# Git Tutorial - Instructions

```shell
git init
git config --global user.name "your Git name"
git config --glboal user.email "your Git email"
```

#### git Status

Git의 현재 상태를 확인하는 명령어

```shell
git status
```

![](https://blog.kakaocdn.net/dn/cTNfr2/btqEYIs19Qx/sklViepURgWAeGqC5UcRw0/img.png)

아무것도 안하면, Untracked files라고 뜬다.

- Git이 현재 Directory를 관리하고 있지 않음을 의미한다.

#### git add

현재 변경사항 더하는 명령어

- Staging : Git에 반영할 (Commit) 내용들을 추가할 수 있다.

```shell
git add .
git add *
git add -A
git add --all
```

위 명령어들은 **모든 변경사항을 반영하겠다**는 의미로 사용된다.

보통 이런 경우에는 **.gitignore** 로 관리해야 불필요한 파일을 제외하고 commit할 수 있다.

```shell
git add notion
git commit -m "notion files"
```

특정 파일만 **git add** 하고 싶으면 위와 같이 하면 된다.

이런 식으로 특정 파일에 대해서만 다루는 편이 좋다.

#### git commit

add로 추가한 변경사항을 반영시키기

```shell
git commit -m "Comments"
```

#### git log

바로 전에 Commit한 내용을 확인할 수 있다.

```shell
git log
```

#### git reset

만약, Commit을 잘못했다면 다시 돌려놓을 수 있다.

```shell
git reset (commit 6자리) --hard
```

git commit을 하면서 얻은 commit 주소의 앞 6자리를 적으면 이전 상태로 되돌릴 수 있다.

해당 명령어는 Git log까지 완벽하게 삭제한다.

#### + git revert

git reset과 마찬가지로 이전 상태로 되돌릴 수 있는 명령어

대신 git log를 완벽하게 삭제하기 보단 Commit 주소를 덮어씌운다.

---

# Git Tutorial - 2 : Branch

#### Git Branch

혼자서 프로젝트를 작업하는 경우, 여러 버전을 만들어 놓거나 팀 단위로 작업 프로젝트를 공유하고 같이 작업할 수 있도록 해주는 것이 바로 Git Branch의 역할이다.

- 동일한 환경에서 테스트할 때도 아주 유용하다.

![](https://blog.kakaocdn.net/dn/VZxKR/btqE1rMmUKd/i8xd4YeV5iWQ1Bveykx2nK/img.png)

### Git Branch terms

#### Master Branch (현 Main)

저장소 생성 시 자동으로 생성되는 기본 브랜치



#### Integration Branch

언제든 배포 가능한 버전의 통합 브랜치로 버그가 없는 안정적인 상태를 유지해야한다.

일반적으로 Master Branch를 통합 브랜치로 사용한다.



#### Topic Branch

특정 주제나 작업에 대한 변경사항을 포함하는 브랜치

개발, 버그 수정 또는 특정 작업 등과 같은 주제에 따라 여러 브랜치로 설정해서 작업을 진행한다.





#### Checkout

다른 Branch로 전환하기 위한 명령어

```shell
git checkout main
```

#### Stash

파일의 변경 내용을 일시적으로 기록해두는 영역

![](https://blog.kakaocdn.net/dn/nbpox/btqE32YvtGl/MeIHnzh22Mzv3YLF2Bzkr1/img.png)

#### Merge

여러 개의 Branch를 하나로 모으는 작업

![](https://blog.kakaocdn.net/dn/cqG9Da/btqE3dzejyP/1OjbDuS9OBf0rODJfMZbgk/img.png)

#### Rebase

기존 Commit들을 새로운 기준점에 맞추기 위해 Commit을 재배치하는 작업

- Branch 병합 전에, 먼저  Branch를 최신 상태로 업데이트하기 위한 작업이다.

![](https://blog.kakaocdn.net/dn/o6e5u/btqE009lxt4/ok6gqiMUtNf4ikqrFyPT10/img.png)



---

```shell
git branch new
git checkout new

```


























