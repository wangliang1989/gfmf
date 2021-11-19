# GFMF

GFMF 全称为 Green's Function Matched Filter。
GFMF 是一种匹配滤波（模板匹配）方法。
它相对于同类的其它方法的特点是采用的模板波形为依据波动方程合成的理论波形。
GFMF 被称为“格林函数的”是因为技术上是将理论格林函数和观测波形互相关，以减少互相关的次数，
节省结算时间。但是，其计算结果与使用理论波形等价。

GFMF 按照 GPL v3 协议发布，即你可以使用、修改和再发布。但修改后也需要开源（包括增量部分）。
详情请看[GPL v3 协议英文版](LICENSE)

**目前，本程序尚不能称为一个应用软件。教程的撰写和公开尚在进行过程中。
你若很了解匹配滤波方法，且对 Perl 语言很熟练了，你可以尝试使用本程序。**

## 版本与下载

我平时是向 dev 分支推送更新。dev 分支有问题的可能性比较大，而且有些修改我可能会改回去。
master 分支则只包含我**自认为**无误的修改。
你在 [release](https://github.com/wangliang1989/gfmf/releases)
页面下载的则是带版本号的版本。

## 安装

安装 gfmf 并不需要先安装 sac 和 fk。但使用的时候需要 sac、fk 和 Perl 的并行模块
[Parallel::ForkManager](https://metacpan.org/pod/Parallel::ForkManager)。

### 编译
可以使用 Gfortran 、 Intel Fortran 或 NAG Fortran 任一进行编译。
````bash
cd bin/
# 以下命令执行其一即可，注意不应有任何报错
make -f Makefile_gfortran # 使用 Gfortran 编译
make -f Makefile_ifor # 使用 Intel Fortran 编译
make -f Makefile_nag # 使用 NAG Fortran 编译
````

### 修改环境变量
将以下内容加入环境变量：
````bash
export GFMF=你自己的真实路径
export PATH=$GFMF/bin:$PATH
# 不要忘记 source
````

## 下一步

1. 使用[GFMF_tiny](https://github.com/wangliang1989/GFMF_tiny)验证安装。
2. 其它进一步的学习待续

## 文章下载与引用信息

下载论文及其 BibTex 和 Endnote 文件，请直接前往《地球物理学报》官网：
http://www.geophy.cn/CN/abstract/abstract15922.shtml

> 王亮, 梁春涛. 2021. 以虚拟地震的理论格林函数为模板搜寻小地震. 地球物理学报,64(7): 2374-2393, doi: 10.6038/cjg2021O0361

> WANG Liang, LIANG ChunTao. 2021. Detecting small earthquakes using the theoretical Green's function of virtual earthquakes as templates Chinese Journal of Geophysics(in Chinese), 64(7): 2374-2393, doi: 10.6038/cjg2021O0361

## 已引用本方法的论文

如果你在论文中引用了我的上述论文。无论你的文章的主题为何，你都可以把你的已正式刊出的论文发给我。
我会在此处列出。这样可以让别人知道你的研究工作，潜在地增加你的论文的引用量。
