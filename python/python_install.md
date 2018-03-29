# linux python3.0 install

* wget https://www.python.org/ftp/python/3.5.5/Python-3.5.5.tgz
* tar -zxvf Python-3.5.5.tgz;cd Python-3.5.5
* ./configure --prefix=/usr/local/python3
  //缺少依赖就一个个安装，由于装过其他环境，故不用装其他依赖

* make && make install
* ln -s /usr/local/python3.5/bin/python3 /usr/bin/python3


python shell命令补全:
* pip3 install ipython
* ? source bin/activate 进入虚拟环境

