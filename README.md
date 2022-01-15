This is the repository for the labs in [CIS 571: Computer Organization & Design](http://cis.upenn.edu/~cis571/).

# Running the testbench on your local machine

It is possible to run the various test cases on your local machine using a Verilog simulator called [Icarus Verilog](http://iverilog.icarus.com) or `iverilog`. `iverilog` can generate a trace of your design in a `.vcd` file that you can then view in another program called [GTKWave](http://gtkwave.sourceforge.net). By running on your _local_ machine, you get potentially faster performance, and avoid network lag and connectivity issues to the biglab machines.

Some caveats:

* There are errors and warnings from `make synth` or `make impl` that **will only be shown by Vivado**. `make check` may find many of these but there are still reasons to run things on biglab occasionally. 
* Icarus Verilog sometimes stumbles on Verilog code that Vivado is perfectly happy with. So you may need to make small edits to your code to satisfy the other compiler. Please post on piazza with problems/workarounds you discover to help others navigate this process.
* It is possible to install the Vivado compiler locally on a Linux or Windows machine. However it is quite heavyweight, requiring about ~30GB of hard drive space, and the scripts we have for Vivado can only be run on Linux. In contrast, `iverilog` and `gtkwave` combined take about 90MB.

### Generating VCD Files

[VCD files](https://en.wikipedia.org/wiki/Value_change_dump) are a recording of the behavior of all of the wires in your design over time. These recordings are enabled by default for Labs 1 & 2, and disabled by default for the later labs to speed up simulation. When you run `make test` you may notice that a `.vcd` file generated. The exact name of this file varies by lab. You can view a `.vcd` file using the GtkWave program (see below) to see exactly what every wire in your design is doing.

You can also toggle recordings by making a small edit to your lab's `testbench_*.v` file. Find this code near the top:
```
`define GENERATE_VCD 0
```
and change the `0` to `1`, or vice-versa, to enable or disable recordings, respectively.

### Linux

Instructions for Ubuntu:

```
sudo apt-get install iverilog gtkwave
cd path-to-your-501-git-repo/whichever-lab-you're-working-on
# edit your testbench file generate a VCD file
TEST_CASE=test_alu make test
```

You can then run `gtkwave SOMETHING.vcd &` to view the execution of `test_alu`.

### Mac OSX

Instructions for the [homebrew package manager](https://brew.sh):

```
brew install icarus-verilog
brew cask install gtkwave
cd path-to-your-501-git-repo/whichever-lab-you're-working-on
# edit your testbench file generate a VCD file
TEST_CASE=test_alu make test
```

You can then launch `gtkwave`, and open the `.vcd` file with `File`=>`New Window`. On Joe's Mac, he can't launch `gtkwave` from the Terminal for some reason but can do so via Spotlight or by navigating to the `/Applications` folder. Running `open SOMETHING.vcd` also opens gtkwave automatically, as does double-clicking the `.vcd` file in Finder.

### Windows

Install the Windows version of Icarus Verilog from [here](http://bleyer.org/icarus/). Use the `iverilog-v11-20190809-x64_setup` version in particular. During installation, there are two important steps:

1) Choose the **Full installation** option, which installs GTKWave and other code that `iverilog` needs.
![icarus-full-installation](https://github.com/upenn-acg/cis501/raw/master/images/icarus-full-installation.png)

2) Have your `PATH` updated to include the `iverilog.exe` and `gtkwave.exe` executables.
![icarus-path](https://github.com/upenn-acg/cis501/raw/master/images/icarus-path.png)

Then, you can open up the Windows command prompt or PowerShell (we recommend the latter) and run:
```
cd path-to-your-501-git-repo\whichever-lab-you're-working-on
# edit your testbench file generate a VCD file
test.cmd test_alu
```
This runs the `test_alu` test case and produces a `.vcd` file. You can substitute other test cases as well. 

You can then open the `.vcd` file in GTKWave to view the signals in your design throughout the entire execution. To launch GTKWave, in our test installation nothing was added to the Start Menu, so there are two options:
* navigate to the Icarus Verilog installation directory that you chose (`C:\iverilog` by default) and then to `gtkwave\bin\gtkwave.exe`. You can open a new `.vcd` file via `File => Open New Window` or `File => Open New Tab`.
* in PowerShell, run `Start-Process -NoNewWindow gtkwave.exe SOMETHING.vcd`. Just running `gtkwave.exe` runs it in the foreground which blocks the PowerShell session.


### Generate .vcd file on biglab, run GTKWave locally

An alternative workflow is to install only GTKWave on your local computer (see instructions from [the GTKWave website](http://gtkwave.sourceforge.net)), and use Vivado (on biglab) to generate the `.vcd` files that GTKWave can visualize for you. You can also use `iverilog` on biglab instead, as it tends to be much faster than Vivado (especially on small tests). You can run the tests via `iverilog` via `make iv-test`.

Once you edit your testbench to generate `.vcd` files (see above), whenever you run `make test` (or `make iv-test`) a `.vcd` file will be generated. Note that these files can be quite large -- `wireframe.vcd` from Lab 5 is about 1GB in size. We recommend compressing these `.vcd` files with `gzip` or `zip`, or transferring them via `scp -C` which transparently compresses files before sending (and decompresses them on the receiving end as well). Compression reduces their size by about 6x.


# Description of files in common/ directory

#### common/make/vivado.mk
The Makefile that does all the real work. Each lab's Makefile (e.g., `lab1/Makefile`) defines variables that are used by `vivado.mk` to run synthesis, implementation, simulation, etc as needed for that lab. Not all labs support all possible targets. E.g., some labs are synthesis- and simulation-only because they don't connect to any ZedBoard I/O pins. Other labs do use these pins to interact with the outside world and thus support implementation.

#### common/pennsim/PennSim.jar
A copy of the PennSim simulator for CIS 240. Used to assemble LC4 code into a .hex file representation that can be loaded into a Verilog memory.

#### common/sdcard-boot/zynq_fsbl_0.elf
The "first-stage boot loader" for the ZedBoard. This executable will program the FPGA on power-up via a bitstream stored on an SD Card. Useful for programming the FPGA without direct access to Vivado. Note that the ZedBoard's jumpers must be set appropriately:
* MIO 6: set to GND
* MIO 5: set to 3V3
* MIO 4: set to 3V3
* MIO 3: set to GND
* MIO 2: set to GND
* VADJ Select (J18): Set to 1V8
* JP6: shorted
* JP2: shorted
* All other jumpers should be left unshorted.

#### Tcl scripts
`common/tcl/build.tcl` Tcl script for Vivado batch mode to perform synthesis, and optionally implementation, for a lab.

`common/tcl/debug.tcl` Tcl script for Vivado GUI mode to launch the Vivado debugger on the testbench for a lab.

`common/tcl/program.tcl` Tcl script for Vivado batch mode to program an FPGA attached to the local computer.

#### common/xdc/zedboard_master.xdc
The master list of the physical pins on the ZedBoard, along with their functionalities and required voltages. Used as a reference to create constraint files for each lab. 
