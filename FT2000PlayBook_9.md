# FT2000/4 & Kylin V10 Desktop 玩耍记录(9) —— 折腾网卡

修改MAC地址的四种方法介绍
天王 2013-06-13 10:10:50 4637 收藏 2
分类专栏： linux
Linux 修改MAC地址的四种方法介绍
转自
http://www.zdh1909.com/html/Cisco/18632.html

方
法一：
1.关闭网卡设备 ifconfig eth0 down 2.修改 MAC地址  ifconfig eth0 hw ether MAC地址 3.重启网卡 ifconfig eth0 up 

方法二：
以上方法一修改后linux重启后MAC又恢复为原来的，为了下次启动时修改后的MAC仍有效，我们可以修改文件file:/etc/rc.d /rc.sysinit(RedFlag Linux为这个文件，其他版本的linux应该不同)的内容，在该文件末尾加以下内容： ifconfig eth0 down
ifconfig eth0 hw ether MAC地址
ifconfig eth0 up （此方法每次启动时都要寻找新硬件-网卡，不好用）   

方法三：
很简单的，只是在./etc/sysconfig/network-scripts/ifcfg-eth0中加入下面一句话： MACADDR=00:AA:BB:CC:DD:EE 并注释掉#HWADDR=语句 

方法四：
暂时： Linux下的MAC地址更改
首先用命令关闭网卡设备。
/sbin/ifconfig eth0 down
然后就可以修改MAC地址了。
/sbin/ifconfig eth0 hw ether xxxxxxxxxxx
（其中xx是您要修改的地址）
最后重新启用网卡
/sbin/ifconfig eth0 up 网卡的MAC地址更改就完成了 