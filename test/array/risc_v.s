addi sp,sp,100
addi sp,sp,-96
sw s0,92(sp)
addi s0,sp,96
sw zero,-20(s0)
jal x0,116            
lw a5,-20(s0)
slli a4,a5,2
lw a5,-20(s0)
slli a5,a5,2
addi a3,s0,-16
add a5,a3,a5
sw a4,-80(a5)
lw a5,-20(s0)
slli a5,a5,2
addi a4,s0,-16
add a5,a4,a5
lw a5,-80(a5)
lw a4,-24(s0)
add a5,a4,a5
sw a5,-24(s0)
lw a4,-28(s0)
lw a5,-24(s0)
add a4,a4,a5
lw a5,-20(s0)
slli a5,a5,2
addi a3,s0,-16
add a5,a3,a5
lw a5,-80(a5)
add a5,a4,a5
sw a5,-28(s0)
lw a5,-20(s0)
addi a5,a5,1
sw a5,-20(s0)
lw a4,-20(s0)     
addi a5,x0,9
bge a5,a4,-120
lw a4,-96(s0)
addi a5,x0,9
blt a5,a4,20
lw a5,-96(s0)
addi a5,a5,99
sw a5,-32(s0)
jal x0, 12
addi a5,x0,4
sw a5,-32(s0)
lw a4,-92(s0)        
addi a5,x0,10
beq a4,a5,212
lw a5,-92(s0)
addi a4,x0,111
sra a5,a4,a5
sw a5,-36(s0)
jal x0, 12         
addi a5,x0,4            
sw a5,-36(s0)        
lw a4,-88(s0)     
addi a5,x0,10
bge a5,a4,16
addi a5,x0,4
sw a5,-40(s0)
jal x0, 16    
lw a5,-88(s0)       
xori a5,a5,222
sw a5,-40(s0)       
lw a4,-84(s0)          
addi a5,x0,12
bne a4,a5,20
lw a5,-84(s0)
andi a5,a5,333
sw a5,-44(s0)
jal x0,12  
addi a5,x0,4               
sw a5,-44(s0)     
lw a4,-80(s0)         
addi a5,x0,16       
bne a4,a5,20
lw a5,-80(s0)
ori a5,a5,444
sw a5,-44(s0)
jal x0,12
addi a5,x0,4       
sw a5,-44(s0)        
lw a4,-76(s0)
addi a5,x0,-11
blt a4,a5,16
addi a5,x0,555
sw a5,-48(s0)
jal x0,12     
addi a5,x0,4
sw a5,-48(s0)      
lw a4,-72(s0)
addi a5,x0,23
bge a5,a4,16
addi a5,x0,666
sw a5,-52(s0)
jal x0,12        
addi a5,x0,4
sw a5,-52(s0) 
lw a4,-24(s0)
addi a5,x0,180
bne a4,a5,16
addi a5,x0,999
sw a5,-56(s0)
jal x0,12      
addi a5,x0,4
sw a5,-56(s0)       
addi a5,x0,0
addi a0,a5,0
lw s0,92(sp)
addi sp,sp,96
ret                      