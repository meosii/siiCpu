CC = iverilog

rtl = ../rtl

IncludePath = -I${rtl}

OutputPath = ./bin

$(shell mkdir -p ${OutputPath})

all: alu arbiter bus pipeline_cpu cpu_top decoder gpr if_stage mem_ctrl memory spm 

run: all

clean:
	rm ${OutputPath} -rf
	rm *.vcd -f

alu: 
	${CC} test_alu.v ${IncludePath} -o ${OutputPath}/test_alu
	${OutputPath}/test_alu

arbiter:
	${CC} test_arbiter.v ${IncludePath} -o ${OutputPath}/test_arbiter
	${OutputPath}/test_arbiter

bus:
	${CC} test_bus.v ${IncludePath} -o ${OutputPath}/test_bus
	${OutputPath}/test_bus

pipeline_cpu:
	${CC} test_pipeline_cpu_top.v ${IncludePath} -o ${OutputPath}/test_pipeline_cpu_top
	${OutputPath}/test_pipeline_cpu_top

cpu_top:
	${CC} test_cpu_top.v ${IncludePath} -o ${OutputPath}/test_cpu_top
	${OutputPath}/test_cpu_top

decoder:
	${CC} test_decoder.v ${IncludePath} -o ${OutputPath}/test_decoder
	${OutputPath}/test_decoder

gpr:
	${CC} test_gpr.v ${IncludePath} -o ${OutputPath}/test_gpr
	${OutputPath}/test_gpr
	
if_stage:
	${CC} test_if_stage.v ${IncludePath} -o ${OutputPath}/test_if_stage
	${OutputPath}/test_if_stage

mem_ctrl:
	${CC} test_mem_ctrl.v ${IncludePath} -o ${OutputPath}/test_mem_ctrl
	${OutputPath}/test_mem_ctrl

memory:
	${CC} test_memory.v ${IncludePath} -o ${OutputPath}/test_memory
	${OutputPath}/test_memory

spm:
	${CC} test_spm.v ${IncludePath} -o ${OutputPath}/test_spm
	${OutputPath}/test_spm