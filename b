#!/usr/bin/env python
# _*_ coding: utf-8 _*_

#####
## ファイルバックアップ取得コマンド
## 作成日：2017/05/24
## 概要：
##   引数で指定したファイル、フォルダをOLDフォルダにバックアップします。
##   ファイルまたはフォルダは元名称.日付＋数字4桁にリネームして保存します。
## 更新履歴：
##   2017/05/24 初版作成
##   2018/01/20 シンボリックリンク判定追加、ロジック簡素化
#####


import os
import sys
import shutil
from datetime import datetime


OLDDIRNAME = "OLD"
DEBUGFLAG = False

argvs = sys.argv
argc = len(argvs)


## デバッグ用
def printDebug(message):
    if(DEBUGFLAG):
        print ("DEBUG : " + message)


if __name__ == '__main__':
    # pythonの対応バージョンチェック
    if sys.version_info[0] != 2 and sys.version_info[0] != 3 :
        print("Error: unsupported version. %s" % sys.version_info )

    # 引数チェックによるエラー判定
    if (argc == 1) :
        print("Usage: # %s filename" % argvs[0])
        quit()

    # 引数毎に処理を実施
    for i in range(1,argc):
        srcdir = ""
        srcname = ""
        olddir = ""
        destname=""
        prefix = datetime.now().strftime('%Y%m%d')

        if i > 0 :

            # 絶対パスに変換
            srcname=os.path.abspath(argvs[i])
            # ディレクトリ名の取得
            if( os.path.isdir(srcname) and srcname.endswith("/") ):
                srcname = os.path.dirname(srcname)
            srcdir = os.path.dirname(srcname)
            printDebug("srcname : " + srcname)
            printDebug("srcdir : " + srcname)

            # ディレクトリの存在確認
            if ( srcdir == "" or os.path.isdir(srcdir) == False):
                print (" %d : [ %s  => NG! directory not found. ]" % (i, srcdir))
                continue
            printDebug("srcdir is exist.")

            # シンボリックリンクに対する処理確認）
            if ( os.path.islink(srcname) == True):
                while True:
                    print (" %d : [ %s is symbolic link. ] " % (i, srcname))
                    print (" %d : [ %s -> %s ] " % (i, srcname, os.path.realpath(srcname)))
                    print ("\t 0 : do not backup(skip)" )
                    print ("\t 1 : backup %s " % srcname )
                    print ("\t 2 : backup %s " %  os.path.realpath(srcname) )

                    try:
                        if sys.version_info[0] == 2 :
                            res = raw_input("\t Please Enter Number : ")
                        elif sys.version_info[0] == 3 :
                            res = input("\t Please Enter Number : ")
                    except (KeyboardInterrupt, EOFError)  :
                        print("")
                        exit()

                    if res == "0" :
                        break
                    elif res == "1" :
                        break
                    elif res == "2" :
                        srcname = os.path.realpath(srcname)
                        break

                if res == "0" :
                    continue

            # コピー元の存在確認（破損シンボリックリンクはOKとする）
            if ( os.path.lexists(srcname) == False):
                print (" %d : [ %s  => NG! file or directory not found. ]" % (i, srcname))
                continue
            printDebug("srcname is exist.")


            # OLDディレクトリが無ければ作成する
            olddir = os.path.join(srcdir, str(OLDDIRNAME) )
            if ( os.path.isdir(olddir) == False ):
                os.makedirs(olddir)
                printDebug("command success : mkdir " + olddir)

            # OLDディレクトリ内にバックアップする
            if ( os.path.isdir( srcname ) ):
                for j in range(1,9999):
                    # バックアップ先ディレクトリ名の設定
                    destname = os.path.join( olddir, \
                      (os.path.basename(srcname)  \
                      + "." + datetime.now().strftime('%Y%m%d') + "{0:02d}".format(j)))
                    # コピーして結果を表示
                    if ( os.path.exists( destname ) == False ):
                        shutil.copytree( srcname, destname,symlinks=True)
                        print(" %d : [ %s  => %s ]" % (i, srcname, destname))
                        printDebug("destname : "+ destname)
                        break
            elif ( os.path.isfile( srcname )):
                for j in range(1,9999):
                    # バックアップ左記ファイル名の設定
                    destname = os.path.join( olddir, \
                      (os.path.basename(srcname) \
                      + "." + datetime.now().strftime('%Y%m%d') +"{0:02d}".format(j)))
                    # コピーして結果を表示
                    if ( os.path.exists( destname ) == False ):
                        shutil.copy2( srcname, destname)
                        print (" %d : [ %s  => %s ]" % (i, srcname, destname))
                        printDebug("destname : "+ destname)
                        break
