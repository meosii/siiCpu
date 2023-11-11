_start:
addi a0,a0,8
addi t0,t0,11
lui a1,1092
srl a1,a1,t0
csrrw a0,mstatus,a0
csrrw a1,mie,a1
addi a0,a0,0
addi a1,a1,0
addi t0,t0,0
