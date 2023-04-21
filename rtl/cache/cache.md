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

[![p9EvT7n.png](https://s1.ax1x.com/2023/04/21/p9EvT7n.png)](https://imgse.com/i/p9EvT7n)

在此设计了三级流水线的 cache，第一级给出地址数据等信号，利用组合电路得到 hit_en 信号，未 hit 时发送给主存的地址信号；第二阶段得到主存中的数据，将其余所需数据均打一拍使其保持在同一时钟周期；第三阶段采样主存中的数据（或 cache 中被打一拍的数据）得到 load 信号，或将 store 数据存入 data_ram。

### 1. cache_decoder

通过组合电路得到 tag，index，offset：
``` verilog
assign tag    = cachein_addr[31 : 8];
assign index  = cachein_addr[7 : 4];
assign offset = cachein_addr[3 : 0];
```

### 2. tag_ram

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

注：tag 值最好寄存一拍再写入，

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
    end else if (read_main_memory_en_r1 == 1) begin
        case (replaced_way_r1)
            `REPLACE_WAY0: begin
                way0_tag_ram[main_memory_index_r1] <= main_memory_tag_r1;
                way0_value[main_memory_index_r1]   <= 1;
            end
            `REPLACE_WAY1: begin
                way1_tag_ram[main_memory_index_r1] <= main_memory_tag_r1;
                way1_value[main_memory_index_r1]   <= 1;
            end
            `REPLACE_WAY2: begin
                way2_tag_ram[main_memory_index_r1] <= main_memory_tag_r1;
                way2_value[main_memory_index_r1]   <= 1;
            end
            `REPLACE_WAY3: begin
                way3_tag_ram[main_memory_index_r1] <= main_memory_tag_r1;
                way3_value[main_memory_index_r1]   <= 1;
            end
            // replaced_way = NO_REPLACE_WAY, do nothing
        endcase
    end
end
```

[![p9Evs0A.png](https://s1.ax1x.com/2023/04/21/p9Evs0A.png)](https://imgse.com/i/p9Evs0A)

### 替换策略

Cache 是 CPU 和内存之间的一种高速缓存，它可以提高 CPU 的访问速度，降低内存的访问压力。但是，Cache 的容量有限，当 CPU 需要访问的地址在 Cache 中不存在时，需要从将内存中该地址的数据写入 Cache ，此时就要替换掉 Cache 中的一条 cacheline。那么选取哪一条 cacheline，就需要采用一定的替换策略。

Cache 替换策略的目标是尽可能地保留最有可能被再次访问的数据，从而提高 Cache 的命中率。常见的有以下几种：

- FIFO（First In First Out）：按照数据进入 Cache 的先后顺序进行替换，最先进入的数据最先被替换。这种策略简单易实现，但是可能会替换掉经常被访问的数据。
- LRU（Least Recently Used）：按照数据在 Cache 中被访问的时间进行替换，最近最少被访问的数据最先被替换。这种策略可以较好地反映数据的访问频率，但是需要记录每个数据的访问时间，增加了硬件开销。
- LFU（Least Frequently Used）：按照数据在 Cache 中被访问的次数进行替换，最少被访问的数据最先被替换。这种策略可以较好地反映数据的访问频率，但是需要记录每个数据的访问次数，增加了硬件开销。
- Random：随机选择一条 cacheline 进行替换。这种策略简单易实现，但是可能会替换掉经常被访问的数据。
- NRU（Not Recently Used）：将 Cache 中的数据分为两类，一类是最近被访问过的（R 位为 1），另一类是最近没有被访问过的（R 位为 0）。优先替换掉 R 位为 0 的数据，如果都为 1，则随机选择一条进行替换。这种策略可以减少对经常被访问的数据的影响，但是需要定期清零 R 位。


在此我们采用伪最近最少替换法（LRU）。

因为一个地址的值只能放在其对应 index 的 cacheline 中，在此我们有 4 ways，也就是只能替换 4 ways 中的一条 cacheline，首先将 4-way 进行分组，way0，way1 为上组，way2，way3 为下组，利用 age[0] 记录当前一次访问是上组还是下组，若为上组，则将 age[0] 置为 1（1表示下组未被访问，0表示上组未被访问）；接着 age[1] 记录 way0 还是 way1 被访问，age[2] 记录 way2 还是 way3 被访问。当下一次访问，则将当前值覆盖。

``` verilog

```

[![p9Cnm7Q.png](https://s1.ax1x.com/2023/04/16/p9Cnm7Q.png)](https://imgse.com/i/p9Cnm7Q)

如图所示，如果有 4 ways，那么我们可利用 1 + 2 位 age 将 way 不断 2 分，当上组被访问，则将 age 记为 1，因此这三位可以记录当前以及前几次的访问，依次判断 age[0] -> age[1]/[2]，如果 age[0] = 1，选取 age[2]，如果 age[2] = 1，选取 way3，此时就将 way3 作为近期最少被访问的 way，而要替换的就是 way3 的 index 的 cacheline，并将 tag 记为内存的 tag，dirty 记为 0。

``` verilog

```

### cache 的写入
cache 的写入策略是指当处理器要修改 cache 中的数据时，如何同步更新主存储器中的对应数据。常见的写入策略有以下四种：

当地址在 cache 中存在，即 hit:

- Write Through：这种策略是指每次处理器修改 cache 中的数据时，都会同时修改主存储器中的数据，保证两者的一致性。这样做的优点是简单且可靠，缺点是增加了写入操作的开销和延迟。

- Write Back：这种策略是指每次处理器修改 cache 中的数据时，只会标记该数据为脏数据（dirty），而不会立即修改主存储器中的数据。只有当该数据被替换出 cache 时，才会将其写回主存储器。这样做的优点是减少了写入操作的次数和延迟，缺点是可能导致 cache 和主存储器中的数据不一致。

当地址在 cache 中不存在，即 no hit:

- No Write Allocate：这种策略是指当处理器要修改 cache 中不存在的数据时，不会将该数据从主存储器加载到 cache 中，而是直接修改主存储器中的数据。这样做的优点是避免了不必要的数据加载，缺点是可能降低了 cache 的命中率和利用率。

- Write Allocate：这种策略是指当处理器要修改 cache 中不存在的数据时，会将该数据从主存储器加载到 cache 中，再将要 store 的数据写入 cache。这样做的优点是提高了 cache 的命中率和利用率，缺点是增加了数据加载和写入的开销和延迟。

在此，我们利用 Write Back 和 Write Allocate 配合使用：

[![p9PhsPK.png](https://s1.ax1x.com/2023/04/18/p9PhsPK.png)](https://imgse.com/i/p9PhsPK)


 