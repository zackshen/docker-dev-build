#在boot2docker上开发环境的构建
##缘由
最近公司的电脑的风扇总是停转，运行一段时间之后过热当机了，辛亏virtualbox比较健壮，这么折腾也没有丢数据，重启机子之后ssh登陆，svn看了下文件
修改状态，尚且还在，趁热打铁立马提交一把。机子今天送修去了。总是将开发代码保存在虚拟机里也不是太好，总有一天虚拟机也有挂掉的时候，那时我哭都来不及了。
虽然virtualbox提供了文件夹共享机制，但是总感觉虚拟机万一坏了，重新build很麻烦，要装操作系统，安一堆的包，各种配置，太麻烦了。而且不够轻量，
docker的话同时开几个container应该没什么问题，倒不如用Dockerfile来写个构建开发环境的脚本,之后就一劳永逸了。

##boot2docker
###docker和boot2docker的区别
docker是我们所知的`大鲸鱼`，`集装箱搬运工`, 而boot2docker是适用于windows和osx平台的，因为目前docker只能运行在有linux内核的操作系统之下，所以boot2docker就是对docker的一层封装，说的简单点他的构成就是virtualbox，boot2docker.iso（docker的宿主操作系统，十分的精简，大概23MB）里面带个docker。

###boot2docker的获取和安装
[Windows](https://docs.docker.com/installation/windows/)
[Mac OSX](https://docs.docker.com/installation/mac/)

###使用boot2docker的困难之处
先讲一下自己工作环境的操作系统是windows7 ， 开始假象将源代码保存在D:\sources, 在boot2docker中启动container
映射本地的目录到container得volume，想法是好的，但是实施起来碰到了困难。官方提供了几个方案，比如开一个文件共享的container然后smaba共享出去， 太麻烦了。之后找到一篇说如何做目录映射的[文章](https://medium.com/boot2docker-lightweight-linux-for-docker/boot2docker-together-with-virtualbox-guest-additions-da1e3ab2465c), 太赞了，博主还给出了build好的boot2docker镜像。这个解决方案就像是我要的。不过发现新版的boot2docker上已经集成了默认的目录映射，参见[boot2docker doc](https://github.com/boot2docker/boot2docker)。 如果你想自定义boot2docker.iso的话，可以参照上面一篇文章。
	
	host(local volume) => boot2docker(vm's volume) => docker container(volume)

boot2docker默认提供如下目录映射

	1. Users share at /Users
	2. /Users share at /Users
	3. c/Users share at /c/Users
	4. /c/Users share at /c/Users
	5. c:/Users share at /c/Users
	
### Nice!!!
为什么要将代码保存在本地，而不是在boot2docker中check一份出来，然后start container的时候目录映射过去，一个原因是不受开发环境影响，保护代码。另外一个是boot2docker启动的虚拟机是存在于内存中的，一重启东西就没了，所以这个要千万注意的。


##行动起来
* 下载二进制包, 安装
[Windows](https://docs.docker.com/installation/windows/)
[Mac OSX](https://docs.docker.com/installation/mac/)
* 初始化一个boot2docker虚拟机

		boot2docker init
	这时你可以打开virtualbox的管理界面，可以看到一个名为boot2docker-vm的虚拟机，这个就是刚才生成的
	
* 启动虚拟机

		boot2docker up
		
* 登录到boot2docker虚拟机

		boot2docker ssh

* 看一下当前有木有容器在

		docker ps -a
		
* 运行一个容器看看

		docker run -i -t docker.cn/docker/ubuntu:latest /bin/bash
	完了就会进入docker container的shell， 要退出但是不关闭容器，执行ctrl+p，ctrl+q, 退出后想在进入
	执行docker attach $(containerId)
	
* 做一下目录映射看看, 在boot2docker中的`home`目录新建文件夹projects

		docker run -i -v /home/docker/projects/:/data/projects -t docker.cn/docker/ubuntu:latest /bin/bash
		
	在container里添加一个文件到/data/projects/, 在刚才新建的projects目录下就会看到
	
* windows下boot2docker会自动映射C:/Users到/c/Users/，所以启动container的时候就可以映射/c/Users/xxx/yyy到container的目录

		docker run -i -v /c/Users/$(userName))/projects/prj1:/data/prj1 -t docker.cn/docker/ubuntu:latest /bin/bash
		

##Dockerfile
### to be continue...




