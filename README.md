# The Montgomery Multiplication Accelerator

This repository contains HDL sources, implementation projects, verifications utilities and result replication scripts used to generate FPGA hardware Montgomery Multiplication accelerators. The accelerator consists in a systolic design. Its Processing Elements are based on the use of DSP48E2 blocks. The hardware has been developped and explored using the Vivado 2022.1 toolchain. The design is packaged as an IP for ease of use and result replication.

![alt text](https://github.com/LOUISNOYEZ/FIOS_DSP_MM/blob/master/MM_demo_IP.png?raw=true)


Implementations have been performed using a Zynq Ultrascale+ FPGA (ZCU102 platform, part xczu9eg-ffvb1156-2-e) target. The hardware is designed to communicate with the System on Chip on the development board for Co-design applications.

The implementation and simulation project can be generated using the following command :

`vivado -mode batch -source TCL/FIOS_project_gen.tcl -tclargs ip`

The "ip" / "no_ip" tclargs option will generate the project using either the packaged IP files in the `IP` folder in which case the source cannot be modified on the fly or the files in the `SRC/RTL` folder, in which case modification of the RTL description can be performed directly in the project. This argument defaults to "ip" if tclargs isn't used.

# Verification

Verification utilities for the design are available in the `VERIFICATION` folder. Test vectors can be generated using the [sagemath toolchain](https://www.sagemath.org/) and the gen_test_vectors.sage script (see sage gen_test_vectors.sage -h for help). Test vectors stored in the TXT subfolder are imported to the simulation project of the design by default.

# Vitis Project

A Vitis Project can be automatically created once the `FIOS_project` has been created to directly test the functionnality of the accelerator on the development board in a codesign application using the following command :

`xsct TCL/vitis_FIOS_256_gen.tcl`

This command assumes `FIOS_project` has been used to generate a bitstream with the design configured with `WIDTH=256` and that an `.xsa` exported hardware file has been created.

# Implementation Results

Implementation results can be automatically generated once the project `FIOS_project` has been created using the `TCL/result_database_gen.tcl` script and the following command :

`vivado -mode batch -source TCL/result_database_gen.tcl`

This script will automatically validate the design and generate implementation results for a wide range of different parameters. It will store the implementation results, parameters and simulation results in a database. Although its use is not covered here, a [grafana](https://grafana.com/oss/grafana/) server has been used to vizualize the implementation results data in real-time.
Note that this script uses [sqlite3](https://www.sqlite.org/index.html) and the [tclsqlite](https://cyqlite.sourceforge.io/cgi-bin/sqlite/dir?ci=tip) library installed under `/usr/lib`.

Below is an excerpt of implementation results for WIDTHs ranging from 128 bits to 4096 bits.

| WIDTH | CREG 				 | CASC    			  | DSP REG LEVEL | CONFIGURATION  | Max Freq (MHz) | Resource (DSP/LUT/FF) | First/Next MM Latency (cc) | First MM time (u s)    | Throughput (10^6.MM/s)   |
|:-----:|:------------------:|:------------------:|:-------------:|:--------------:|:--------------:|:---------------------:|:--------------------------:|:----------------------:|:------------------------:|
| 128	| :x:				 | :x:				  |	1			  |	EXPANDED       | 433.3			| 8/597/1205			|		53/18				 |		0.1223			  |		24.07				 |
| 128	| :x:				 | :x:				  |	1			  |	FOLDED		   | 450			| 4/346/660				|		53/53				 |		0.1178			  |		8.491				 |
| 128	| :x:				 | :x:				  |	2			  |	EXPANDED	   | 600			| 8/604/1433			|		61/19				 |		0.1017			  |		31.58				 |
| 128	| :x:				 | :x:				  |	2			  |	FOLDED  	   | 600			| 4/362/757				|		61/61				 |		0.1017			  |		9.836				 |
| 128	| :x:				 | :x:				  |	3			  |	EXPANDED	   | 600			| 8/757/1451			|		76/20				 |		0.1267			  |		30					 |
| 128	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 600			| 3/343/614				|		76/76				 |		0.1267			  |		7.895				 |
| 128	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 433.3			| 8/597/905				|		60/18				 |		0.1385			  |		24.07				 |
| 128	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 450			| 4/346/483				|		60/60				 |		0.1333			  |		7.500				 |
| 128	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 8/867/1601			|		68/19				 |		0.1088			  |		32.89				 |
| 128	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 3/370/688				|		68/68				 |		0.1088			  |		9.191				 |
| 128	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 738			| 8/746/1633			|		83/20				 |		0.1125			  |		36.90				 |
| 128	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 3/342/646				|		83/83				 |		0.1125			  |		8.892				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 433.3			| 8/677/1031			|		53/18				 |		0.1223			  |		24.07				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 412.5			| 4/371/572				|		55/55				 |		0.1333			  |		7.500 				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 625			| 8/750/1523			|		61/19				 |		0.09760			  |		32.89				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 4/448/863				|		63/63				 |		0.1008			  |		9.921				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 738			| 8/818/1916			|		76/20				 |		0.1030			  |		36.90				 |
| 128	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 738			| 3/356/787				|		79/79				 |		0.1070			  |		9.342				 |
| 256	| :x:				 | :x:				  |	1			  |	EXPANDED	   | 425			| 16/1221/2337			|		109/34				 |		0.2565			  |		12.50				 |
| 256	| :x: 				 | :x:				  |	1			  |	FOLDED  	   | 450			| 7/581/1100			|		109/109				 |		0.2422			  |		4.128				 |
| 256	| :x: 				 | :x:				  |	2			  |	EXPANDED       | 562.5			| 16/1229/2833			|		125/35				 |		0.2222			  |		16.07				 |
| 256	| :x: 				 | :x:				  |	2			  |	FOLDED  	   | 562.5			| 6/509/1104			|		125/125				 |		0.2222			  |		4.500				 |
| 256	| :x: 			   	 | :x:				  |	3			  |	EXPANDED	   | 575			| 16/1533/3080			|		156/36				 |		0.2713			  |		15.97				 |
| 256	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 562.5			| 5/533/927				|		156/156				 |		0.2773			  |		3.606				 |
| 256	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 425			| 16/1221/1875			|		124/34				 |		0.2918			  |		12.50				 |
| 256	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 433.3			| 6/503/744				|		124/124				 |		0.2862			  |		3.495				 |
| 256	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 16/1759/3413			|		140/35				 |		0.2240			  |		17.86				 |
| 256	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 6/705/1309			|		140/140				 |		0.2240			  |		4.464				 |
| 256	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 738			| 16/1523/3288			|		171/36				 |		0.2317			  |		20.50				 |
| 256	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 5/538/1139			|		171/171				 |		0.2317			  |		4.316				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 412.5			| 16/1364/1870			|		109/34				 |		0.2642			  |		12.13				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 412.5			| 7/630/870				|		112/112				 |		0.2715			  |		3.683				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 625			| 16/1510/2915			|		125/35				 |		0.2000			  |		17.86				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 6/638/1261			|		128/128				 |		0.2048			  |		4.883				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 738			| 16/1643/3815			|		156/36				 |		0.2114			  |		20.50				 |
| 256	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 738			| 5/569/1315			|		160/160				 |		0.2168			  |		4.613				 |
| 512	| :x:				 | :x:				  |	1			  |	EXPANDED       | 433.3			| 31/2391/4534			|		214/64				 |		0.4938			  |		6.771				 |
| 512	| :x:				 | :x:				  |	1			  |	FOLDED		   | 425			| 13/1048/1974			|		214/214				 |		0.5035			  |		1.986				 |
| 512	| :x:				 | :x:				  |	2			  |	EXPANDED	   | 562.5			| 31/2401/5530			|		245/65				 |		0.4356			  |		8.654				 |
| 512	| :x:				 | :x:				  |	2			  |	FOLDED  	   | 600			| 11/899/2014			|		245/245				 |		0.4083			  |		2.449				 |
| 512	| :x:				 | :x:				  |	3			  |	EXPANDED	   | 562.5			| 31/2978/5877			|		306/66				 |		0.5440			  |		8.523				 |
| 512	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 575			| 9/928/1677			|		306/306				 |		0.5322			  |		1.879				 |
| 512	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 412.5			| 31/2392/3486			|		244/64				 |		0.5915			  |		6.445				 |
| 512	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 433.3			| 11/892/1351			|		244/244				 |		0.5631			  |		1.776				 |
| 512	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 31/3438/6606			|		275/65				 |		0.4400			  |		9.615				 |
| 512	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 10/1152/2202			|		275/275				 |		0.4400			  |		2.273				 |
| 512	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 712.5			| 31/2994/6185			|		336/66				 |		0.4716			  |		10.80				 |
| 512	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 8/819/1695			|		336/336				 |		0.4553			  |		2.196				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 412.5			| 31/2665/3511			|		214/64				 |		0.5188			  |		6.445				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 425			| 13/1148/1610			|		217/217				 |		0.5106			  |		1.959				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 625			| 31/2941/6014			|		245/65				 |		0.3920			  |		9.615				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 11/1096/2239			|		248/248				 |		0.3968			  |		2.520				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 700			| 31/3205/7327			|		306/66				 |		0.4371			  |		10.61				 |
| 512	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 738			| 9/996/2506			|		310/310				 |		0.4201			  |		2.381				 |
| 1024	| :x:				 | :x:				  |	1			  |	EXPANDED       | 425			| 61/4731/8912			|		424/124				 |		0.9976			  |		3.427				 |
| 1024	| :x:				 | :x:				  |	1			  |	FOLDED		   | 425			| 25/1985/3757			|		424/424				 |		0.9976			  |		1.002				 |
| 1024	| :x:				 | :x:				  |	2			  |	EXPANDED	   | 550			| 61/4743/10933			|		485/125				 |		0.8818			  |		4.400				 |
| 1024	| :x:				 | :x:				  |	2			  |	FOLDED  	   | 575			| 21/1722/3794			|		485/485				 |		0.8435			  |		1.186				 |
| 1024	| :x:				 | :x:				  |	3			  |	EXPANDED	   | 550			| 61/5924/10659			|		606/126				 |		1.102			  |		4.365				 |
| 1024	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 575			| 16/1635/2917			|		606/606				 |		1.054			  |		0.9488				 |
| 1024	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 412.5			| 61/4731/6876			|		484/124				 |		1.173			  |		3.327				 |
| 1024	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 412.5			| 21/1672/2449			|		484/484				 |		1.173			  |		0.8522				 |
| 1024	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 61/6786/11820			|		545/125				 |		0.8720			  |		5.000				 |
| 1024	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 18/2048/3834			|		545/545				 |		0.8720			  |		1.147				 |
| 1024	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 700			| 61/5843/12302			|		667/126				 |		0.9529			  |		5.556				 |
| 1024	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 15/1507/3075			|		667/667				 |		0.9038			  |		1.106				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 412.5			| 61/5258/6950			|		424/124				 |		1.028			  |		3.327				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 412.5			| 25/2194/3061			|		427/427				 |		1.035			  |		0.9660				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 625			| 61/5790/10596			|		485/125				 |		0.7760			  |		5.000				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 21/2046/4141			|		488/488				 |		0.7808			  |		1.281				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 712.5			| 61/6384/15071			|		606/126				 |		0.8505			  |		5.655				 |
| 1024	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 712.5			| 16/1716/4711			|		610/610				 |		0.8561			  |		1.168				 |
| 2048	| :x:				 | :x:				  |	1			  |	EXPANDED	   | 412.5			| 121/9411/17522		|		844/244				 |		2.046			  |		1.691				 |
| 2048	| :x:				 | :x:				  |	1			  |	FOLDED  	   | 412.5			| 49/3856/7241			|		844/844				 |		2.046			  |		0.4887				 |
| 2048	| :x: 				 | :x:				  |	2			  |	EXPANDED       | 550			| 121/9504/21729		|		966/245				 |		1.716			  |		2.245				 |
| 2048	| :x:				 | :x:				  |	2			  |	FOLDED  	   | 562.5			| 41/3255/7418			|		966/966				 |		1.717			  |		0.5823				 |
| 2048	| :x:				 | :x:				  |	3			  |	EXPANDED	   | 550			| 121/11636/20286		|		1206/246			 |		2.193			  |		2.236				 |
| 2048	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 562.5			| 31/3036/5564			|		1206/1206			 |		2.144			  |		0.4664				 |
| 2048	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 412.5			| 121/9411/13402		|		964/244				 |		2.337			  |		1.691				 |
| 2048	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 412.5			| 41/3232/4690			|		964/964				 |		2.337			  |		0.4279				 |
| 2048	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 121/13475/23205		|		1085/245			 |		1.736			  |		2.551				 |
| 2048	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 36/4055/7478			|		1085/1085			 |		1.736			  |		0.5760				 |
| 2048	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 700			| 121/11596/22995		|		1326/246			 |		1.894			  |		2.846				 |
| 2048	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 28/2748/5809			|		1326/1326			 |		1.797			  |		0.5567				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 400			| 121/10445/13290		|		844/244				 |		2.110			  |		1.639				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 400			| 49/4262/5514			|		847/847				 |		2.118			  |		0.4723				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 625			| 121/11492/19781		|		966/245				 |		1.546			  |		2.551				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 41/3948/7636			|		972/972				 |		1.552			  |		0.6430				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 700			| 121/12580/28044		|		1206/246			 |		1.723			  |		2.846				 |
| 2048	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 712.5			| 31/3272/8384			|		1304/1304			 |		1.830			  |		0.5464				 |
| 4096	| :x:				 | :x:				  |	1			  |	EXPANDED       | 400			| 242/18849/35004		|		1691/486			 |		4.228			  |		0.8230				 |
| 4096	| :x:				 | :x:				  |	1			  |	FOLDED		   | 412.5			| 98/7679/14249			|		1691/1691			 |		4.099			  |		0.2439				 |
| 4096	| :x:				 | :x:				  |	2			  |	EXPANDED	   | 550			| 242/18970/43515		|		1933/487			 |		3.515			  |		1.129				 |
| 4096	| :x:				 | :x:				  |	2			  |	FOLDED  	   | 550			| 82/6503/14786			|		1933/1933			 |		3.515			  |		0.2845				 |
| 4096	| :x:				 | :x:				  |	3			  |	EXPANDED	   | 525			| 242/23205/41039		|		2416/488			 |		4.602			  |		1.076				 |
| 4096	| :x:				 | :x:				  |	3			  |	FOLDED  	   | 562.5			| 62/6028/10958			|		2416/2416			 |		4.295			  |		0.2328				 |
| 4096	| :heavy_check_mark: | :x:				  |	1			  |	EXPANDED	   | 400			| 242/18849/26850		|		1932/486			 |		4.830			  |		0.8230				 |
| 4096	| :heavy_check_mark: | :x:				  |	1			  |	FOLDED  	   | 412.5			| 82/6430/9149			|		1932/1932			 |		4.684			  |		0.2135				 |
| 4096	| :heavy_check_mark: | :x:				  |	2			  |	EXPANDED       | 625			| 242/26996/44824		|		2174/487			 |		3.478			  |		1.283				 |
| 4096	| :heavy_check_mark: | :x:				  |	2			  |	FOLDED  	   | 625			| 70/7863/13884			|		2178/2178			 |		3.485			  |		0.2870				 |
| 4096	| :heavy_check_mark: | :x:				  |	3			  |	EXPANDED	   | 675			| 242/23219/41689		|		2657/488			 |		3.936			  |		1.3832				 |
| 4096	| :heavy_check_mark: | :x:				  |	3			  |	FOLDED  	   | 738			| 55/5346/11079			|		2662/2662			 |		3.607			  |		0.2772				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	EXPANDED       | 375			| 242/21138/27790		|		1692/486			 |		4.512			  |		0.7716				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	1			  |	FOLDED  	   | 400			| 98/8496/10874			|		1694/1694			 |		4.235			  |		0.2361				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	EXPANDED       | 500			| 242/23265/41335		|		2176/487			 |		4.352			  |		1.027				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	2			  |	FOLDED  	   | 625			| 82/7849/13774			|		2178/2178			 |		3.485			  |		0.2870				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	EXPANDED	   | 500			| 242/25351/53233		|		2658/488			 |		5.316			  |		1.025				 |
| 4096	| :heavy_check_mark: | :heavy_check_mark: |	3			  |	FOLDED  	   | 700			| 62/6604/15568			|		2660/2660			 |		3.800			  |		0.2632				 |
