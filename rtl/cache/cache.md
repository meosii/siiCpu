# Cache 的设计

## 介绍

Cache 是用来提高数据访问速度的一种高速存储器，它利用了数据的局部性原理，将主存中经常访问的数据或指令复制到 cache 中，从而减少对主存的访问次数和时间。因为 cache 容量小，只能存储主存中的一小部分数据，对 cpu 来说，提供的读写地址为主存地址，那么就需要记录此时 cache 中的数据是对应主存中的哪一个地址，如果完整的存储每一个数据的地址，当对 cache 进行查找时，需要遍历每一个数据的地址，显然会花费很多时间，那么对于主存中的一个数据，就限制其只能在 cache 中的某块空间内，此时查找是否有这个地址数据，只需要访问该块空间，判断其地址，减少了很多时间，那么如何分配空间呢？

注意主存往 cache 中替换值时，我们将多个 word 一起替换，提高效率，那么替换的是相邻的哪几个 word，利用地址中的某几位确定，一般满足边界对齐。假设一个数据只能存放在 cache 中的某几个位置，我们也通过选取地址中的某几位来限制其只能访问的 cache 空间，那么地址剩下的位就拿来作为标记，存在一个寄存器中用来比较 cpu 地址与 cache 中地址是否一致。

| Tag | Index | Offset |
|-----|-------|--------|

在此我们采用组相连映射（set associative mapping），假设一次替换 n words = 4 * n bytes，那么 offset 则需要 $clog2(4 * n) 位，在此称这一批数据为一个 data block；假设一个数据在 cache 中只能存放在 m 个 data block，将这 m 个位置定义为一个 cache set，那么通过 cache 容量除以 m 除以 data block 就可以将 cache 分为 (cache size / block size / associativity) 个 line，那么 index 就可以取 $clog2(cache size / block size / associativity) 位，剩下的所有位都给 tag。

假设，我们将 cache 分为了 4 ways，每一 way 有 16 lines，每一 line 存放 4 words，一个 word 有 8 bits，那么先通过 index 选取访问的 line，接着判断 4 way 对应的 line 中的 tag 是否与地址中的 tag 一致即可，这样将原本需要访问 16 * 4 个 tag 直接减少到访问 4 个 tag，使得查找更加容易。

## 设计规范

在此我们设计一个两路组相联 cache，并使用以下规范:

- cache 的容量为 1024 Bytes = 1 KB
- 主存的容量为 2^32 Bytes = 4 GB
- cache 是四路组相联，即每个 cache 包含 4 个 cacheWay
- 每个 cacheWay 中包含 16 条 cacheLine，一条 cacheLine 中含有 16 Bytes 数据
- 每条 cacheLine 的数据部分可以存放 16 Bytes = 4 words

注: cacheLine 是 cache 中的一个存储单元，其中的数据部分称为 data block。每个 cacheLine 都有一个标记 tag，用于标识该 cacheLine 所对应的主存地址。

为了设计四路组相联 cache，我们需要确定如何将主存地址映射到 cache。为此，我们在主内存地址中使用三个字段：标记（Tag）、索引（Index）和偏移量（Offset）。

首先通过 index 表明选定了哪几个 cacheLine，接着判断这些 cacheLine （即一个 cacheSet）中对应的 tag 是否有与地址中的 tag 一致，若存在一致，表明 hit，选出该 cacheLine 中的数据，通过 offset 选择被选中的数据，如果没有 hit 通过一定的替换策略，将主存中的该地址数据发送到 cache，再去访问该地址对应值。

通过 cache 容量，组相联路数，一条 cacheline 的容量 block size，我们可以计算出每个字段的位数:

- Offset bits = log2(block size) = log2(16 Bytes) = 4 bits
- Index bits = log2(cache size / block size / associativity) = log2(1024 / 16 / 4) = 4 bits
- Tag bits = address bits - offset bits - index bits = 32 - 4 - 4 = 24 bits

例如，假设主内存地址是 0x12345678。然后，我们可以提取 tag、index 和 offset 字段:

| Tag (24 bits) | Index (4 bits) | Offset (4 bits) |
|---------------|----------------|-----------------|
| 0x123456     | 0x7            | 0x8             |

在 cache 中，主要由 tag_ram 和 data_ram 两部分组成，其中 tag_ram 用来存储数据地址的一部分位（其余位通过 data 存储的位置就可以得到）和 value（记录该位置是否有主存数据写入过）；而 data_ram 就是用来存放数据。


如下所示:

- TAG RAM:

| way | 0 | 1 | 2 | 3 |
|-----|---------|---------|---------|---------|
| Block 0   | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· |
| Block 1   | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· |
| ···  | ··· | ··· | ··· | ··· |
| Block 7   | V:1 T:0x123456 | V:1 T:0x120000 | V:1 T:0x123000 | V:1 T:0x123400 |
| ···   | ··· | ··· | ··· | ··· |
| Block 15   | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· | V: ··· T:  ··· |

- DATA RAM:
  
| way | 0 | 1 | 2 | 3 |
|-----|---------|---------|---------|---------|
| Block 0   | 16 Bytes | 16 Bytes | 16 Bytes | 16 Bytes |
| Block 1   | 16 Bytes | 16 Bytes | 16 Bytes | 16 Bytes |
| ···  | ··· | ··· | ··· | ··· |
| Block 7   | 16 Bytes | 16 Bytes | 16 Bytes | 16 Bytes |
| ···  | ··· | ··· | ··· | ··· |
| Block 15   | 16 Bytes | 16 Bytes | 16 Bytes | 16 Bytes |

当我们要检查示例地址 0x12345678 是否 cache 命中，直接比较所有 tag 是不现实的，我们已经将一个地址存放在其指定位置，也就是 index 确定的 line，在一条 line 中有 4 ways 都允许存放该地址的数据，只需要比较这 4 个 tag 即可判断 cache 中是否已经存在该地址数据。

我们执行以下步骤。

- 从地址中提取 index 字段: index = 0x7

- 在 cache 表中查找对应的行: Block 7 = { V:1 T:0x123456 | V:1 T:0x120000 | V:1 T:0x123000 | V:1 T:0x123400 }

- 将地址中的 tag 字段与该行中的每一项进行比较:tag = 0x123456 在 way0 中 hit

- 如果有匹配并且有效字段为 1，那么 cache 命中，我们返回该块的 0x8 Bytes的数据

- 如果没有匹配或者有效字段为 0，那么 cache 未命中，我们从主内存中获取 0x123456 中的 index行数据存储如 cache，在继续执行 store 与 load。
  
## 设计方法

在此，我们将数据主要分为 5 个模块，分别为：cache_decoder，tag_ram，reg1，replace_data_ctrl，data_ram。其中 cache_decoder 用来将 cpu 上的地址翻译为 tag，index，offset 三部分；tag_ram 用来存放数据的地址以及是否有效，在其内部嵌入一个 LRU 的替换模块（因为 tag_ram 中存储了 value 值，若 value 值为 0 直接成为替换 line，并且该模块直接生成的 hit_en 为记录前几次的访问提供了方便）；reg1 用来寄存信号以实现流水线；replace_data_ctrl 用来在替换时给主存发送读信号和读地址以及将读到的数据输入给 data_ram；最后 data_ram 用来存放数据（如果当被替换掉的数据为 dirty，还需要外接写缓存，发出缓存的地址数据）。

[![p9VmdaV.md.png](https://s1.ax1x.com/2023/04/22/p9VmdaV.md.png)](https://imgse.com/i/p9VmdaV)

在此设计了三级流水线的 cache，第一级给出地址数据等信号，利用组合电路得到 hit_en 信号，未 hit 时发送给主存的地址信号；第二阶段得到主存中的数据，将其余所需数据均打一拍使其保持在同一时钟周期；第三阶段采样主存中的数据（或 cache 中被打一拍的数据）得到 load 信号，或将 store 数据存入 data_ram。

### 1. cache_decoder

通过组合电路得到 tag，index，offset：
``` verilog
assign tag    = cachein_addr[31 : 8];
assign index  = cachein_addr[7 : 4];
assign offset = cachein_addr[3 : 0];
```

### 2. tag_ram

[![p9VmIRe.md.png](https://s1.ax1x.com/2023/04/22/p9VmIRe.md.png)](https://imgse.com/i/p9VmIRe)

记录 tag 的目的主要是判断当前访问的地址在 cache 中是否存在，如果存在输出 hit_en 对应位的高电平，只需要通过组合电路将译码器得到的 tag 与 index 中对应的 tag 是否一致即可：

``` verilog
always @(*) begin
    if ((way0_tag_ram[index] == tag) && (way0_value[index] == 1)) begin
        hit_en[0] <= 1;
    end else begin
        hit_en[0] <= 0;
    end
    if ((way1_tag_ram[index] == tag) && (way1_value[index] == 1)) begin
        hit_en[1] <= 1;
    end else begin
        hit_en[1] <= 0;
    end
    if ((way2_tag_ram[index] == tag) && (way2_value[index] == 1)) begin
        hit_en[2] <= 1;
    end else begin
        hit_en[2] <= 0;
    end
    if ((way3_tag_ram[index] == tag) && (way3_value[index] == 1)) begin
        hit_en[3] <= 1;
    end else begin
        hit_en[3] <= 0;
    end
end
```

而 tag_ram 中的内容，需要将当前访问地址的 tag 寄存入存储器，而寄存的哪一行哪一列需要 index 和 way 共同确定，index 是直接输入的地址，而 way 如果 hit 中了，直接选择这一 way，如果没有 hit 中，需要采用某种替换策略选择 4 way 中的 1 way 进行替换，替换策略下一部分介绍，假设已经得到这些输入，tag 值的存入如下所示：

注：通过时序电路对当前 tag 进行寄存，即第一周期给出 tag，hit_en 信号，第二个周期将需要替换的 tag 存入 tag_ram。

``` verilog
integer j;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j = 0; j < `LINE_NUM; j = j + 1) begin
            way0_value[j] <= 0;
            way1_value[j] <= 0;
            way2_value[j] <= 0;
            way3_value[j] <= 0;
            way0_tag_ram[j] <= 0;
            way1_tag_ram[j] <= 0;
            way2_tag_ram[j] <= 0;
            way3_tag_ram[j] <= 0;
        end
    end else if (read_main_memory_en == 1) begin
        case (replaced_way)
            `REPLACE_WAY0: begin
                way0_tag_ram[index] <= tag;
                way0_value[index]   <= 1;
            end
            `REPLACE_WAY1: begin
                way1_tag_ram[index] <= tag;
                way1_value[index]   <= 1;
            end
            `REPLACE_WAY2: begin
                way2_tag_ram[index] <= tag;
                way2_value[index]   <= 1;
            end
            `REPLACE_WAY3: begin
                way3_tag_ram[index] <= tag;
                way3_value[index]   <= 1;
            end
            // replaced_way = NO_REPLACE_WAY, do nothing
        endcase
    end
end
```
接下来介绍替换策略：

因为 cache 的容量有限，当 CPU 需要访问的地址在 Cache 中不存在时，需要从将内存中该地址的数据写入 Cache ，此时就要替换掉 Cache 中的一条 cacheline。那么选取哪一条 cacheline，就需要采用一定的替换策略。Cache 替换策略的目标是尽可能地保留最有可能被再次访问的数据，从而提高 Cache 的命中率。常见的有以下几种：

- FIFO（First In First Out）：按照数据进入 Cache 的先后顺序进行替换，最先进入的数据最先被替换。这种策略简单易实现，但是可能会替换掉经常被访问的数据。
- LRU（Least Recently Used）：按照数据在 Cache 中被访问的时间进行替换，最近最少被访问的数据最先被替换。这种策略可以较好地反映数据的访问频率，但是需要记录每个数据的访问时间，增加了硬件开销。
- LFU（Least Frequently Used）：按照数据在 Cache 中被访问的次数进行替换，最少被访问的数据最先被替换。这种策略可以较好地反映数据的访问频率，但是需要记录每个数据的访问次数，增加了硬件开销。
- Random：随机选择一条 cacheline 进行替换。这种策略简单易实现，但是可能会替换掉经常被访问的数据。
- NRU（Not Recently Used）：将 Cache 中的数据分为两类，一类是最近被访问过的（R 位为 1），另一类是最近没有被访问过的（R 位为 0）。优先替换掉 R 位为 0 的数据，如果都为 1，则随机选择一条进行替换。这种策略可以减少对经常被访问的数据的影响，但是需要定期清零 R 位。

在此我们采用伪最近最少替换法（LRU）。

[![p9Vnkd0.png](https://s1.ax1x.com/2023/04/22/p9Vnkd0.png)](https://imgse.com/i/p9Vnkd0)

因为一个地址的值只能放在其对应 index 的 cacheline 中，在此我们有 4 ways，也就是只能替换 4 ways 中的一条 cacheline，首先将 4-way 进行分组，way0，way1 为上组，way2，way3 为下组，利用 age[0] 记录当前一次访问是上组还是下组，若为上组，则将 age[0] 置为 1（1表示下组未被访问，0表示上组未被访问）；接着 age[1] 记录 way0 还是 way1 被访问，age[2] 记录 way2 还是 way3 被访问。当下一次访问，则将当前值覆盖。

注：age 值不仅与当前输入有关，还与前一状态的值有关，因此采用时序电路。利用二维数组，表明有 16（`LINE_NUM） 行的 3 位 age。

``` verilog
// Record the least recently used
// The reset value of the asynchronous reset should be kept low to avoid latching
reg [2:0] age [`LINE_NUM - 1 : 0];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (k = 0; k < `LINE_NUM; k = k + 1) begin
            age[k] <= 3'b0;
        end
    end else begin
        if (hit_en[0]) begin            // way0 hit
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b1;
        end else if (hit_en[1]) begin   // way1 hit
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b0;
        end else if (hit_en[2]) begin   // way2 hit
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b1;
        end else if (hit_en[3]) begin   // way3 hit
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b0;
        // no hit
        end else if (way0_replace_en) begin // way0 replace
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b1;
        end else if (way1_replace_en) begin // way1 replace
            age[index][0] <= 1'b1; 
            age[index][1] <= 1'b0;
        end else if (way2_replace_en) begin // way2 replace
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b1;
        end else if (way3_replace_en) begin // way3 replace
            age[index][0] <= 1'b0; 
            age[index][2] <= 1'b0;
        end
    end
end
```

[![p9Cnm7Q.png](https://s1.ax1x.com/2023/04/16/p9Cnm7Q.png)](https://imgse.com/i/p9Cnm7Q)

如图所示，如果有 4 ways，那么我们可利用 1 + 2 位 age 将 way 不断 2 分，当上组被访问，则将 age 记为 1，因此这三位可以记录当前以及前几次的访问，依次判断 age[0] -> age[1]/[2]，如果 age[0] = 1，选取 age[2]，如果 age[2] = 1，选取 way3，此时就将 way3 作为近期最少被访问的 way，而要替换的就是 way3 的 index 的 cacheline，并将 tag 记为内存的 tag，dirty 记为 0。即，通过 age 判断接下来会被替换的 way，注意如果 value 为 0 直接替换这一 way。

``` verilog
always @(*) begin
    way0_replace_en = 0;
    way1_replace_en = 0;
    way2_replace_en = 0;
    way3_replace_en = 0;
    if (hit_en == 4'b0000 && (cache_en == 1)) begin
        if (way0_value[index] == 0) begin
            way0_replace_en = 1;
            way1_replace_en = 0;
            way2_replace_en = 0;
            way3_replace_en = 0;
        end else if (way1_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 1;
            way2_replace_en = 0;
            way3_replace_en = 0;
        end else if (way2_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 0;
            way2_replace_en = 1;
            way3_replace_en = 0;
        end else if (way3_value[index] == 0) begin
            way0_replace_en = 0;
            way1_replace_en = 0;
            way2_replace_en = 0;
            way3_replace_en = 1;
        end else begin
            if (age[index][0] == 0) begin
                if (age[index][1] == 0) begin
                    way0_replace_en = 1;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    way0_replace_en = 0;
                    way1_replace_en = 1;
                    way2_replace_en = 0;
                    way3_replace_en = 0;
                end
            end else begin
                if (age[index][2] == 0) begin
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 1;
                    way3_replace_en = 0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    way0_replace_en = 0;
                    way1_replace_en = 0;
                    way2_replace_en = 0;
                    way3_replace_en = 1;
                end
            end
        end
    end else begin
        way0_replace_en = 0;
        way1_replace_en = 0;
        way2_replace_en = 0;
        way3_replace_en = 0;
    end
end
```

被替换的 way 不仅要告知 data_ram 进行数据替换，还应告知 tag_ram 将当前 way 的 tag 写入 tag_ram。因此利用一个多比特信号来记录当前是否有 way 被替换，以及该 way 是哪一个。

``` verilog
assign replaced_way =   (way0_replace_en)? `REPLACE_WAY0 :
                        (way1_replace_en)? `REPLACE_WAY1 :
                        (way2_replace_en)? `REPLACE_WAY2 :
                        (way3_replace_en)? `REPLACE_WAY3 : `NO_REPLACE_WAY;
```

### 3. replace_data_ctrl
[![p9VnMLR.png](https://s1.ax1x.com/2023/04/22/p9VnMLR.png)](https://imgse.com/i/p9VnMLR)

该模块用来在需要替换时从主存得到数据，即通过给定的 hit_en 与 读地址，从内存获得数据，再将这些数据发送给 data_ram，利用组合电路即可得到：

``` verilog
assign data_from_main_memory = rdata_from_main_memory;

always @(*) begin
    if ((hit_en == 0) && (cache_en == 1)) begin
        read_main_memory_en = 1;
        addr_to_main_memory = cachein_addr;
    end else begin
        read_main_memory_en = 0;
        addr_to_main_memory = 0;
    end
end
```

### 4. reg1

由于 data_from_main_memory 需要等待一个时钟周期，而 store_data 与 cachein_addr 等信号在前一周期就已经给出，要保证同一时刻将数据写入 data_ram 或读出 load_data，需要将所有信号打一拍与主存的数据保持一致，在此加入寄存器堆：

[![p9VnyY8.png](https://s1.ax1x.com/2023/04/22/p9VnyY8.png)](https://imgse.com/i/p9VnyY8)

``` verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_r1                   <= 0;
        tag_r1                  <= 0;
        index_r1                <= 0;
        offset_r1               <= 0;
        store_data_r1           <= 0;
        hit_en_r1               <= 0;
        way0_replace_en_r1      <= 0;
        way1_replace_en_r1      <= 0;
        way2_replace_en_r1      <= 0;
        way3_replace_en_r1      <= 0;
    end else begin
        wr_r1                   <= wr;
        tag_r1                  <= tag;
        index_r1                <= index;
        offset_r1               <= offset;
        store_data_r1           <= store_data;
        hit_en_r1               <= hit_en;
        way0_replace_en_r1      <= way0_replace_en;
        way1_replace_en_r1      <= way1_replace_en;
        way2_replace_en_r1      <= way2_replace_en;
        way3_replace_en_r1      <= way3_replace_en;
    end
end
```

### 5. data_ram

准备好了所有地址控制信号后，最后需要做的就是在 load 时，将数据 load 给 cpu，在 store 时，将数据写入 data_ram，而发生替换时，如果被替换的行与主存不一致，应将被替换的行写回主存，在此利用 write_buffer 暂存写回主存的数据。所需端口如下：

[![p9VumAP.png](https://s1.ax1x.com/2023/04/22/p9VumAP.png)](https://imgse.com/i/p9VumAP)

#### 1. 数据写入 data_ram

在 cache 中，不仅 store 操作会将数据写入 data_ram，当发生 no hit 时，需要去主存取数据进行替换，也需要对 data_ram 进行数据的写入。当由于 store 操作对 data_ram 进行写入时，需要将该数据标注为 dirty，当数据被主存数据替换时，将其标注为 no_dirty，用来保持 cache 的一致性。

``` verilog
integer i;
// write in cache(data ram)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < `LINE_NUM; i = i + 1) begin
            way0_data_ram[i]    <= 0;
            way1_data_ram[i]    <= 0;
            way2_data_ram[i]    <= 0;
            way3_data_ram[i]    <= 0;
            way0_dirty[i]       <= `NON_DIRTY;
            way1_dirty[i]       <= `NON_DIRTY;
            way2_dirty[i]       <= `NON_DIRTY;
            way3_dirty[i]       <= `NON_DIRTY;
        end
    end else if (wr_r1 == `WRITE) begin
    // 1. STORE
        if (hit_en_r1[0] == 1) begin
        // 1.1 way0 is hit
            case (offset_r1[3:2])          // which word will be write
                `OFFSET_WORD0:  way0_data_ram[index_r1][31  : 0 ] <= store_data_r1;
                `OFFSET_WORD1:  way0_data_ram[index_r1][63  : 32] <= store_data_r1;
                `OFFSET_WORD2:  way0_data_ram[index_r1][95  : 64] <= store_data_r1;
                `OFFSET_WORD3:  way0_data_ram[index_r1][127 : 96] <= store_data_r1;
            endcase
            way0_dirty[index_r1] <= `DIRTY;
        end else if (hit_en_r1[1] == 1) begin
        // 1.2 way1 is hit
            ···
        end else if (hit_en_r1[2] == 1) begin
        // 1.3 way2 is hit
            ···
        end else if (hit_en_r1[3] == 1) begin
        // 1.4 way3 is hit
            ···
        end else begin 
        // 1.5 no way is hit (hit_en_r1 = 4'b0000) 
            // First judge the current line, then judge which way on this line can be replaced, 
            // and then replace the data of this cacheline with the combined value of store_data and main_data.
            // 1.5.1 way0 could be replaced
            if (way0_replace_en_r1 == 1) begin
                case (offset_r1[3:2])
                    `OFFSET_WORD0:  way0_data_ram[index_r1] <= {data_from_main_memory[127:32], store_data_r1};
                    `OFFSET_WORD1:  way0_data_ram[index_r1] <= {data_from_main_memory[127:64], store_data_r1, data_from_main_memory[31:0]};
                    `OFFSET_WORD2:  way0_data_ram[index_r1] <= {data_from_main_memory[127:96], store_data_r1, data_from_main_memory[63:0]};
                    `OFFSET_WORD3:  way0_data_ram[index_r1] <= {store_data_r1, data_from_main_memory[95:0]};
                endcase
                way0_dirty[index_r1]   <= `NON_DIRTY;
            // 1.5.2 way1 could be replaced
            end else if (way1_replace_en_r1 == 1) begin
                ···
            // 1.5.3 way2 could be replaced
            end else if (way2_replace_en_r1 == 1) begin
                ···
            // 1.5.4 way3 could be replaced
            end else if (way3_replace_en_r1 == 1) begin
                ···
            end
        end
    end else begin
    // 2. LOAD
        if (hit_en_r1 == 4'b0000) begin
        // When loading, if the cache is not hit, we also need to write data to the cache.
        // At this time, the data being written is the main_data.
            if (way0_replace_en_r1 == 1) begin
                way0_data_ram[index_r1]    <= data_from_main_memory;
                way0_dirty[index_r1]       <= `NON_DIRTY;
            end else if (way1_replace_en_r1 == 1) begin
                ···
            end else if (way2_replace_en_r1 == 1) begin
                ···
            end else if (way3_replace_en_r1 == 1) begin
                ···
            end
        end
    end
end
```
#### 2. 数据读出 data_ram

除了 load 操作会读取数据，write_buffer 也需要读取数据，先判断 load_data 信号，如果内存中有所访问的数据，将 data_ram 中的数据直接读出，如果没有将 data_from_main_memory 数据读出：

``` verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_data <= 0;
    end else if (wr_r1 == `READ) begin // LOAD
        if (hit_en_r1[0] == 1) begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= way0_data_ram[index_r1][31  : 0 ];
                `OFFSET_WORD1:  load_data <= way0_data_ram[index_r1][63  : 32];
                `OFFSET_WORD2:  load_data <= way0_data_ram[index_r1][95  : 64];
                `OFFSET_WORD3:  load_data <= way0_data_ram[index_r1][127 : 96];
            endcase
        end else if (hit_en_r1[1] == 1) begin
            ···
        end else if (hit_en_r1[2] == 1) begin
            ···
        end else if (hit_en_r1[3] == 1) begin
            ···
        end else begin
            case (offset_r1[3:2])
                `OFFSET_WORD0:  load_data <= data_from_main_memory[31  : 0 ];
                `OFFSET_WORD1:  load_data <= data_from_main_memory[63  : 32];
                `OFFSET_WORD2:  load_data <= data_from_main_memory[95  : 64];
                `OFFSET_WORD3:  load_data <= data_from_main_memory[127 : 96];
            endcase
        end
    end else begin // STORE
        load_data <= 0;
    end
end
```

对于写缓存，需要判断当前被替换的 cacheline 中的数据是否有被更改，如果更改了，为了保持 cache 一致性，需要将该数据写回给主存，在此我们加入一个写缓存模块，先将要写回主存的数据写入 write_buffer，后续再将数据写入主存，可以减小 cache 写操作的时间，提高处理器性能。

注：需要考虑此处的数据是否需要打一拍？不需要，将被替换的数据输出，一定是提前于数据写入和 load 出的，不然被替换的数据已经被 main_data 覆盖，就不是原本 cache 中被更改的数据，因此不需要寄存器打一拍，但这些数据是在 data_ram 模块中的，将写回操作放在 data_ram 的模块可以减少数据线的连接。

``` verilog
// dirty: cache data -> write buffer
// here, we use hit_en rather than hit_en_r1
// the second clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_buffer_en      <= 0;
        addr_to_write_buffer <= 0;
        data_to_write_buffer <= 0;
    end else if (hit_en == 4'b0000) begin
    // no way is hit
        write_buffer_en      <= 1;
        addr_to_write_buffer <= cachein_addr;
        // write cache_data to write_buffer
        if ((way0_replace_en == 1) && (way0_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way0_data_ram[index];
        end else if ((way1_replace_en == 1) && (way1_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way1_data_ram[index];
        end else if ((way2_replace_en == 1) && (way2_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way2_data_ram[index];
        end else if ((way3_replace_en == 1) && (way3_dirty[index] == `DIRTY)) begin
            data_to_write_buffer <= way3_data_ram[index];
        end
    end else begin
    // cache hit
        write_buffer_en         <= 0;
        addr_to_write_buffer    <= 0;
        data_to_write_buffer    <= 0;
    end
end
```

以上方法实际上是采用了 cache 的 Write Back 和 Write Allocate 写策略，cache 写策略是指当处理器要修改 cache 中的数据时，如何同步更新主存储器中的对应数据。

当地址在 cache 中存在，即 hit:

- Write Through：这种策略是指每次处理器修改 cache 中的数据时，都会同时修改主存储器中的数据，保证两者的一致性。这样做的优点是简单且可靠，缺点是增加了写入操作的开销和延迟。

- Write Back：这种策略是指每次处理器修改 cache 中的数据时，只会标记该数据为脏数据（dirty），而不会立即修改主存储器中的数据。只有当该数据被替换出 cache 时，才会将其写回主存储器。这样做的优点是减少了写入操作的次数和延迟，缺点是可能导致 cache 和主存储器中的数据不一致。

当地址在 cache 中不存在，即 no hit:

- No Write Allocate：这种策略是指当处理器要修改 cache 中不存在的数据时，不会将该数据从主存储器加载到 cache 中，而是直接修改主存储器中的数据。这样做的优点是避免了不必要的数据加载，缺点是可能降低了 cache 的命中率和利用率。

- Write Allocate：这种策略是指当处理器要修改 cache 中不存在的数据时，会将该数据从主存储器加载到 cache 中，再将要 store 的数据写入 cache。这样做的优点是提高了 cache 的命中率和利用率，缺点是增加了数据加载和写入的开销和延迟。

在此，我们利用 Write Back 和 Write Allocate 配合使用：

[![p9PhsPK.png](https://s1.ax1x.com/2023/04/18/p9PhsPK.png)](https://imgse.com/i/p9PhsPK)

## 测试
如果能将写入 cache 的数据正确读出，说明 cache 设计的正确。

首先在 tb 模块模拟一个主存：

``` verilog
reg [`CACHELINE_WIDTH - 1 : 0] small_main_memory [255 : 0]; // 256 cachelines = 4 caches

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 255; i = i + 1) begin
            small_main_memory[i] <= i*(2 << 95) + i*(2 << 63) + i*(2 << 31) + i; 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rdata_from_main_memory <= 0;
    end else if (read_main_memory_en == 1) begin
        rdata_from_main_memory <= small_main_memory[addr_to_main_memory[31:4]];
    end else begin
        rdata_from_main_memory <= 0;
    end
end
```

利用 task 给出读写信号、地址以及写数据，task 如下：

``` verilog
task test_cache_top(
    input test_wr,
    input [`TAG_WIDTH - 1 : 0]       test_cachein_addr_tag,
    input [`INDEX_WIDTH  - 1 : 0]    test_cachein_addr_index,
    input [`OFFSET_WIDTH - 1 : 0]    test_cachein_addr_offset,
    input [`WORD_WIDTH - 1 : 0]      test_store_data
);
begin
    @(posedge clk)
    #1
    begin
        wr                      = test_wr;
        cachein_addr            = {test_cachein_addr_tag, test_cachein_addr_index, test_cachein_addr_offset};
        store_data              = test_store_data;
    end
end
endtask
```

接着开始执行 load 与 store 操作：

1. load: no hit
   
此时 cache 为空，会去主存取数据，value 为 0，因此按照 way0 -> way1 -> way2 -> way3的顺序写入值：

``` verilog
// load: Initialize the data ram and tag ram
    #1 begin
        // way0
            for (i = 1; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd0, i, 4'd0, 32'b0);
            end
        // way1
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd1, i, 4'd0, 32'b0);
            end
        // way2
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd2, i, 4'd0, 32'b0);
            end
        // way3
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd3, i, 4'd0, 32'b0);
            end
    end
```

结果如下：

[![p9VQ8nH.png](https://s1.ax1x.com/2023/04/22/p9VQ8nH.png)](https://imgse.com/i/p9VQ8nH)

在此 cache 为三级流水线：
- 在第一个时钟周期，给出读写、地址与写数据信号，通过 decoder 得到 tag、index、offset，再由 tag_ram 判断当前 index 行中 4 ways 的 tag 是否存在与输入 tag 一致，若一致表明 hit，若不一致，需要去下一级缓存取数据，在此定义下一级缓存为 main_memory，只需要给出地址与读使能即可，假设在此读操作需要下一个时钟沿取出，还需要考虑将取出的数据存放在 data_ram 的哪一 way，在 tag_ram 中加入一个 LRU 模块，通过记录最近最少被访问的各行的 way，由当前访问行和该行最近最少访问的 way，得到需要替换的 way。
- 此时在第二个时钟上升沿，如果进行 load 操作，而又发生了 no hit，此时取的数据从 main_memory 读出，因此在第三个时钟上升沿将 main_memory 中的数据存入 data_ram 的 Index 行的替换 way。
- 第三个时钟上升沿，采样第二个时钟周期的 main_data 和 index_r1 将数据存入 data_ram，同时 load 出 load_data。

2. load: hit

此时，执行一模一样的操作，因为所有这些地址已经从主存写入，不需要访问主存即可得到 load_data：

``` verilog
// load: Given the same address, 
    // judge whether data_ram is written correctly by load_data.
    #1 begin
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd0, i, 4'd0, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd1, i, 4'd0, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd2, i, 4'd0, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd3, i, 4'd0, 32'b0);
            end
    end
```
结果如下：

[![p9Vlpbd.png](https://s1.ax1x.com/2023/04/22/p9Vlpbd.png)](https://imgse.com/i/p9Vlpbd)

对应上图的初始 load 操作，此时 load 同一地址，可以发现此时可以被 hit，同时不需要去 main_memory 中取数据，在第一个时钟周期给出地址，第二个时钟周期给出 index 等信号，第三个时钟上升沿采样第二时钟的读地址，load 出 load_data，并且与之前一致。

3. store: hit
   
仍然访问相同的地址，此时读入数据，注意写入的数据是一个 word：

``` verilog
// store: hit
    // Firstly, we store the existing address data in data_ram
    // Change the word3 here: 32'h11111111, 32'h22222222
    #1 begin
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd0, i, {2'd3,2'b00}, (i*(2 << 27) + i*(2 << 23) + i*(2 << 19) + i*(2 << 15) + i*(2 << 11) + i*(2 << 7) + i*(2 << 3) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd1, i, {2'd3,2'b00}, (i*(2 << 27) + i*(2 << 23) + i*(2 << 19) + i*(2 << 15) + i*(2 << 11) + i*(2 << 7) + i*(2 << 3) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd2, i, {2'd3,2'b00}, (i*(2 << 27) + i*(2 << 23) + i*(2 << 19) + i*(2 << 15) + i*(2 << 11) + i*(2 << 7) + i*(2 << 3) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd3, i, {2'd3,2'b00}, (i*(2 << 27) + i*(2 << 23) + i*(2 << 19) + i*(2 << 15) + i*(2 << 11) + i*(2 << 7) + i*(2 << 3) + i));
            end
    end
```

结果如下：

[![p9VlVxS.png](https://s1.ax1x.com/2023/04/22/p9VlVxS.png)](https://imgse.com/i/p9VlVxS)

此时进行 store 的写操作，对上述已经写入 data_ram 的地址进行 store，如图，在第一周期给出 cachein_addr 与 store_addr，因为对于 store 来说如果未被 hit，那么需要先由 main_memory 替换得到数据，再将 store_data 存入对应的 word 位（store 操作一次访问一个字），因此尽管第一周期给出了 store_data，也要等待第二周期的 main_data，在三个时钟沿再采样写地址与写数据，即第三个时钟周期才将数据存入 data_ram。

4. load: hit

接着，将上述 store 的数据取出：

``` verilog
// load: Given the same address, 
    // jugde whether data_ram is written correctly by store_data.
    #1 begin
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd0, i, {2'd3,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd1, i, {2'd3,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd2, i, {2'd3,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd3, i, {2'd3,2'b00}, 32'b0);
            end
    end
```

结果如下：

[![p9Vlnbj.png](https://s1.ax1x.com/2023/04/22/p9Vlnbj.png)](https://imgse.com/i/p9Vlnbj)

此时进行 load 操作，将之前 store 的值取出，如图，第一周期给出地址读信号，第二个周期将地址读信号寄存，第三个时钟沿读出信号，与写入的信号一致。

5. store: no hit

 对没有写入 cache 的地址进行数据写入：

 ``` verilog
// store: no hit
    // word2 32'h01010101 32'h02020202
    #1 begin
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd10, i, {2'd2,2'b00}, (i*(2 << 23) + + i*(2 << 15) + + i*(2 << 7) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd11, i, {2'd2,2'b00}, (i*(2 << 23) + + i*(2 << 15) + + i*(2 << 7) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd12, i, {2'd2,2'b00}, (i*(2 << 23) + + i*(2 << 15) + + i*(2 << 7) + i));
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`WRITE, 24'd13, i, {2'd2,2'b00}, (i*(2 << 23) + + i*(2 << 15) + + i*(2 << 7) + i));
            end
    end
 ```

 结果如下：

[![p9VlBPx.png](https://s1.ax1x.com/2023/04/22/p9VlBPx.png)](https://imgse.com/i/p9VlBPx)

接着进行 no hit 的 store 操作，需要去 main_memory 取数据，如图，第一个时钟沿给出地址信号、写信号与发送给 main_memory 的地址，第二个时钟沿 main_memory 采集到地址信号，则第二个时钟周期得到 main_data，第三个时钟沿采样，将数据写入 data_ram。

6. load: hit

将上述 store 的数据读出：

``` verilog
// load: hit
    // jugde whether data_ram is written correctly by store_data.
    #1 begin
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd10, i, {2'd2,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd11, i, {2'd2,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd12, i, {2'd2,2'b00}, 32'b0);
            end
            for (i = 0; i <= 15; i = i + 1) begin
                test_cache_top(`READ, 24'd13, i, {2'd2,2'b00}, 32'b0);
            end
    end
```

结果如下：

[![p9VlRZd.png](https://s1.ax1x.com/2023/04/22/p9VlRZd.png)](https://imgse.com/i/p9VlRZd)

最后将上述 store 的数据 load 出，如图分为三个周期完成，第一周期给出地址和读信号，第二周期将地址信号打一拍，由于 hit 中，第三个时钟沿将 data_ram 中的数据读出，与写入的一致，说明正确完成了 store 和 load 操作。

