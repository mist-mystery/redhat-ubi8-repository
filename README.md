# RedHat Universal Base Image Repository
このディレクトリに `cd` し、以下のコマンドを実行することでローカルに RedHat UBI 8 のリポジトリサーバを立ち上げることができる。
```sh
./container-start.sh
```

コンテナは host ネットワークで起動しているため、これによりホストの IP アドレスに接続することでリポジトリにアクセスできる。
リポジトリサーバには http アクセス可能で、ポートは32780となる。

別の RedHat UBI 8 コンテナからこのリポジトリにアクセスして `dnf install` するためには、/etc/yum.repo.d/ に以下のような設定を追加する。
baseurl の IP アドレスはテスト用なので、ここは適宜ホストの IP アドレスに変更する。  
ただし、そのままだとオリジナルのリポジトリと競合するので、オリジナルの優先順位を下げるなり disabled にするなり何らかの対処が必要。

```
[local-ubi-8-baseos-rpms]
name = Local Red Hat Universal Base Image 8 (RPMs) - BaseOS
baseurl = http://192.0.2.0:32780/repo/ubi-8-baseos-rpms
enabled = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
gpgcheck = 1
```

## 詳細
container-start.sh を実行することで、RedHat UBI 8 のイメージをベースとした Nginx サーバのイメージを作成し、コンテナを起動する。  
コンテナ起動時に `dnf reposync` を実行し、ubi-8-baseos-rpms, ubi-8-appstream-rpms, ubi-8-codeready-builder-rpms のリポジトリからすべてのパッケージをローカルに同期する。
Docker コンテナとホストの間は rpms ディレクトリを同期しており、パッケージはここに保存される。
次回以降の起動時には、ここに保存してあるパッケージを参照して、大本のリポジトリから差分だけ取得して更新する。


## 補足
やっていることは至極単純で、Web サーバにリポジトリを Bind mount して、外部から参照できるようにしているだけである。
コンテナ間で通信するには、普通はそのコンテナをリポジトリコンテナと同じネットワークに入れればよいのだが、これだと新規でイメージをビルドする場合に使えない。
そのためリポジトリコンテナはホストネットワークを使用して、ビルド中のコンテナからもホストのIPアドレスを参照することでリポジトリコンテナにアクセスできるようにしている。
