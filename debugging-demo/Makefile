# source verilog files
SYNTH_SOURCES=march.v
TOP_SYNTH_MODULE=march

# testbench files
TESTBENCH=$(SYNTH_SOURCES)
TOP_TESTBENCH_MODULE=test_march

# zip file that gets uploaded to Canvas
ZIP_SOURCES=march.v
ZIP_FILE=march.zip

# implementation files
IMPL_SOURCES=$(SYNTH_SOURCES)
TOP_IMPL_MODULE=march
CONSTRAINTS=lab1.xdc 
BITSTREAM_FILENAME=march.bit

include ../common/make/vivado.mk
