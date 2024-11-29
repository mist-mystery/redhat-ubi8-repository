#!/bin/sh
set -euC
cd "$(dirname "$0")"

# .env.local に定義した定数を読み込んでシェル変数に展開。xargs は "" を剥がす役割がある。
# shellcheck disable=SC2046 # クォートで囲むと複数行の値が展開されないため
export $(grep -v ^# .env.local | xargs)

if [ -n "${REPO_BASEURL-}" ]; then
  # 末尾の / を削除
  REPO_BASEURL=${REPO_BASEURL%*/}

  # REPO_BASEURL が定義されているなら、yum/dnf でローカルリポジトリを利用するように設定する。
  # 具体的には、/etc/yum.repos.d/ubi.repo の内容をコピーして、
  # baseurl をローカルリポジトリの URL に書き換えた repo ファイルを作成する。
  # 作成した repo ファイル内の書き換え対象以外のリポジトリは削除する。
  # repo ファイルの名前は、00_ で始まるようにして、他のリポジトリよりも先に読み込まれるようにする。
  sed -r ":a;N;\$!ba; \
    s#\[(ubi-8-baseos-rpms|ubi-8-appstream-rpms|ubi-8-codeready-builder-rpms)\]\n\
name = ([^\n]*)\nbaseurl = [^\n]*\
#\[local-\1\]\nname = Local \2\nbaseurl = ${REPO_BASEURL}/\1#g; \
    s#\[ubi[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*(\n|$)##g" \
    /etc/yum.repos.d/ubi.repo > /etc/yum.repos.d/00_${REPO_BASEURL##*/}.repo
fi
