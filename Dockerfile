FROM docker.cn/docker/ubuntu:14.04.1
MAINTAINER zack.shen@netis.com.cn

RUN echo "deb http://mirrors.163.com/ubuntu/ trusty main restricted universe " > /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe " >> /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe " >> /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe " >> /etc/apt/sources.list
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe " >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe " >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe " >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe " >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe " >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe " >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y build-essential autotools-dev automake man pkg-config libevent-dev libncurses-dev libssl-dev libcurl4-openssl-dev curl wget
RUN apt-get install -y libclang-dev
RUN apt-get install -y python-dev libsnappy-dev libzmq-dev
RUN apt-get install -y silversearcher-ag unzip
RUN apt-get install -y python-pip
RUN apt-get install -y git-core
RUN apt-get install -y subversion
RUN apt-get install -y nginx
RUN apt-get install -y mongodb
RUN apt-get install -y memcached
RUN apt-get install -y openssh-server
RUN apt-get install -y zsh
RUN apt-get install -y tmux

# Vim
RUN mkdir -p /opt/downloads && cd /opt/downloads
RUN curl -L https://github.com/zackshen/vim/archive/master.zip > /opt/downloads/vim.zip
RUN unzip vim.zip && cp vim-7-4-589.zip /opt/downloads && cd /opt/downloads && unzip vim-7-4-589.zip && cd vim-7-4-589
RUN ./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --enable-cscope --enable-luainterp --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu/
RUN make & make install
RUN cp -r /opt/downloads/vim/ ~/.vim && sh ~/.vim/install.sh

# Python Env Setup
ADD ./requirements /opt/
RUN pip install -i http://pypi.douban.com/simple/ -U pip
RUN pip install -i http://pypi.douban.com/simple/ -r /opt/requirements --trusted-host pypi.douban.com

# Mongodb
RUN echo "export LC_ALL=C" >> ~/.zshrc
RUN mkdir -p /data/db

# Config Zsh
RUN echo "/bin/zsh" | tee -a /etc/shells
RUN chsh -s /bin/zsh
# RUN curl -L http://install.ohmyz.sh | sh

# Config sshd
RUN mkdir /var/run/sshd
RUN echo 'root:rootroot' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22 80 27017 
ENTRYPOINT service memcached start && service mongodb start && service nginx start && /usr/sbin/sshd -D
#CMD ["/usr/sbin/sshd", "-D"]
