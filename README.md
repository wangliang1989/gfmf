# GFMF

GFMF 全称为 Green's Function Matched Filter。
GFMF 是一种匹配滤波（模板匹配）方法。
它相对于同类的其它方法的特点是采用的模板波形为依据波动方程合成的理论波形。
GFMF 被称为“格林函数的”是因为技术上是将理论格林函数和观测波形互相关，以减少互相关的次数，
节省结算时间。但是，其计算结果与使用理论波形等价。

GFMF 按照 GPL v3 协议发布，即你可以使用、修改和再发布。但修改后也需要开源（包括增量部分）。
详情请看[GPL v3 协议英文版](LICENSE)

目前本项目第一版已经完成，GFMF的核心代码已经在此处开源。但是，教程的撰写和公开尚在积进行过程中。
我最近很忙，我才把学位论文送审，敬请谅解。

# 安装方法

安装 gfmf 并不需要先安装 sac 和 fk。但使用的时候需要 sac、fk 和 Perl 的并行模块
[Parallel::ForkManager](https://metacpan.org/pod/Parallel::ForkManager)。

## 编译

可以使用 Gfortran 、 Intel Fortran 或 NAG Fortran 任一进行编译。

````bash
cd bin/
# 以下命令执行其一即可，注意不应有任何报错
make -f Makefile_gfortran # 使用 Gfortran 编译
make -f Makefile_ifor # 使用 Intel Fortran 编译
make -f Makefile_nag # 使用 NAG Fortran 编译
````

## 修改环境变量

将以下内容加入环境变量：

````bash
export GFMF=your_real_path
export PATH=$GFMF/bin:$PATH
# 不要忘记 source
````

# 文章下载与引用信息

下载论文及其 BibTex 和 Endnote 文件，请直接前往《地球物理学报》官网：
http://www.geophy.cn/CN/abstract/abstract15922.shtml

> 王亮, 梁春涛. 2021. 以虚拟地震的理论格林函数为模板搜寻小地震. 地球物理学报,64(7): 2374-2393, doi: 10.6038/cjg2021O0361

> WANG Liang, LIANG ChunTao. 2021. Detecting small earthquakes using the theoretical Green's function of virtual earthquakes as templates Chinese Journal of Geophysics(in Chinese), 64(7): 2374-2393, doi: 10.6038/cjg2021O0361

# 已引用本方法的论文

如果你在论文中引用了我的上述论文。你可以把你的研究工作告诉我。我会视情况，以适当的，
对大家都好的方式在此处列出。这样可以让别人知道你的研究工作，潜在地增加你的论文的引用量。