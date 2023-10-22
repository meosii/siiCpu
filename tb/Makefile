CC = iverilog

rtl = ../rtl

IncludePath = -I${rtl}

OutputPath = ./bin

$(shell mkdir -p ${OutputPath})

all: alu arbiter bus pipeline_cpu gpr mem_ctrl spm ffacs

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

gpr:
	${CC} test_gpr.v ${IncludePath} -o ${OutputPath}/test_gpr
	${OutputPath}/test_gpr

mem_ctrl:
	${CC} test_mem_ctrl.v ${IncludePath} -o ${OutputPath}/test_mem_ctrl
	${OutputPath}/test_mem_ctrl

spm:
	${CC} test_spm.v ${IncludePath} -o ${OutputPath}/test_spm
	${OutputPath}/test_spm

ffacs:
	${CC} tb_ffacs.v ${IncludePath} -o ${OutputPath}/test_cpu_ffacs
	${OutputPath}/test_cpu_ffacs