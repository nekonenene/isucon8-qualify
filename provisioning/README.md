# 改変版 Torb Ansible

Ansibleの実行時間を短くするために、  
`webapp1.yml` は Go, Ruby, PHP, Node.js の参照実装のみをインストールしています。（私の好みですみません……）

また、デフォルトで起動する参照実装は  
本番では Perl でしたが Go にしてあります。

参照実装の切り替え方法は **[予選マニュアル](https://gist.github.com/rkmathi/1d08e17671d3952e8d2e873e686b7ea6#%E5%8F%82%E7%85%A7%E5%AE%9F%E8%A3%85%E3%81%AE%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88%E6%96%B9%E6%B3%95)** を見てください。


## Required

* CentOS 7 系のリモートサーバー ( [ConoHa](https://www.conoha.jp/conoha/login) のメモリ1GBプランを使用すると、本番に近いです )
* Ansible ( 2.6.4 で検証 )


## webapp, bench をデプロイ

### 1. development の書き換え

```sh
[webapp1]
# 競技用webappをデプロイするサーバ(1)
```

となっている箇所のコメントアウトされている部分を、  
`root@123.45.67.89` など、Ansible を流す先のホスト名にします。

### 2. Ansible playbook の実行

```sh
ansible-playbook -i development webapp1_with_bench.yml
```

これで `webapp1_with_bench.yml` が対象サーバーに流し込まれ、  
Webアプリ「Torb」が起動し始めます。


## ベンチマークを実行するには

ベンチアプリケーション自体は `/home/isucon/torb/bench/bin/bench` に展開されています。

それをいい感じに走らせてくれるスクリプトを `/home/isucon/torb/bench/tools` 下に置いておきましたので、  
ベンチを走らせる際は、リモート環境にて以下のコマンドを実行してください。

```sh
bash /home/isucon/torb/bench/tools/do_bench.sh
```

<br><br>

**以下、もとのREADME**

- - -

# torb provisioning

## ポータル、ベンチマーカ、競技用webappの初期デプロイをする君

### プロビジョニング手順

```sh
$ go get -v github.com/constabulary/gb/... # 初回のみ必要

$ cd /path/to/torb/provisioning
$ vim development
#=> プロビジョニングしたいホストの部分のコメントアウトを外しておく。

$ vim roles/prepare_bench/files/torb.bench.service
#=> -portal http://127.0.0.1 となっているがコレだとbenchからみたportalが127.0.0.1に
#=> なってしまうので、もしもportalを他のIPに撒いているならそれに書き換える。

$ ansible-playbook -i development site.yml
```

### メモ

- コメントアウトを外しているホストが、プロビジョニング対象になる。
    - デフォルトでは全部コメントアウトされているので、ansible-playbookを実行しても何も起きない。
- それぞれのロール(portal_web, bench, webapp1, webapp2, webapp3)は、 `ロール名.yml` ファイルにそのロールで実行されるタスク一覧が書いてある。
    - ためしにあるタスクだけを実行したかったら、 `ロール名.yml` に書いてあるタスクをコメントアウトすることも可。
- それぞれのタスクが具体的に何をやっているのかは、 `タスク名/tasks/main.yml` に書いてある。

---

## portalをデプロイ・kill -HUPする君

```sh
$ cd /path/to/torb/provisioning

# ステージング環境
$ vim development
#=> [portal_web]のブロックで指定されているホストのコメントアウトを外す
$ time ansible-playbook -i development portal_deploy_and_sighup.yml

# 本番環境
$ vim production
#=> [portal_web]のブロックで指定されているホストのコメントアウトを外す
$ time ansible-playbook -i production portal_deploy_and_sighup.yml
```

---

## benchのバイナリをデプロイする君

```sh
# /path/to/torb/bench/bin.Linux.x86_64/bench にLinux用のbenchのバイナリを置いておく

$ cd /path/to/torb/provisioning

# ステージング環境
$ vim development
#=> [bench]のブロックで指定されているホストのコメントアウトを外す
$ time ansible-playbook -i development deploy_bench_binary.yml

# 本番環境
$ vim production
#=> [bench]のブロックで指定されているホストのコメントアウトを外す
$ time ansible-playbook -i production deploy_bench_binary.yml
```
