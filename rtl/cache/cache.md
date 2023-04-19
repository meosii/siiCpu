# Cache 的设计
在此我们设计一个两路组相联 cache，并使用以下规范示例:

- cache 的容量为 1024 Bytes = 1 KB
- 主存的容量为 2^32 Bytes = 4 GB
- cache 是四路组相联，即每个 cache 包含 4 个 cacheWay
- 每个 cacheWay 中包含 16 条 cacheLine，一条 cacheLine 中的数据含有 16 Bytes
- 每条 cacheLine 的数据部分可以存放 16 / 4 = 4 个字

注: cacheLine 是 cache 中的一个存储单元，其中的数据部分称为 data block。每个 cacheLine 都有一个标记 tag，用于标识该 cacheLine 所对应的主存地址。

为了设计四路组相联 cache，我们需要确定如何将主存地址映射到 cache。为此，我们在主内存地址中使用三个字段:标记（Tag）、索引（Index）和偏移量（Offset）。

首先通过 index 表明选定了哪几个 cacheLine，接着判断这些 cacheLine （即一个 cacheSet）中对应的 tag 是否有与地址中的 tag 一致，若存在一致，表明 hit，选出该 cacheLine 中的数据，通过 offset 选择被选中的数据。

为了计算每个字段的位数，我们使用以下公式:

- Offset bits = log2(block size) = log2(16 Bytes) = 4 bits
- Index bits = log2(cache size / block size / associativity) = log2(1024 / 16 / 4) = 4 bits
- Tag bits = address bits - offset bits - index bits = 32 - 4 - 4 = 24 bits

因此，主存地址可以划分为如下3个字段。

| Tag (24 bits) | Index (4 bits) | Offset (4 bits) |
|---------------|----------------|-----------------|

例如，假设主内存地址是 0x12345678。然后，我们可以提取 tag、index 和 offset 字段:

| Tag (24 bits) | Index (4 bits) | Offset (4 bits) |
|---------------|----------------|-----------------|
| 0x123456     | 0x7            | 0x8             |

为了从 cache 中存储和检索数据，我们使用一个 cache 表，每个数据集对应一列，每个数据块对应一行。表中的每个条目都包含两个字段: valid 和 tag。valid 字段表示块中是否包含有效数据。tag 字段表示主内存中的哪个块与 cache 中的该块对应。

例如，假设我们的 cache 表如下所示:

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

要检查示例地址 0x12345678 是否 cache 命中，我们执行以下步骤。

- 从地址中提取 index 字段: index = 0x7

- 在 cache 表中查找对应的行: Block 7 = { V:1 T:0x123456 | V:1 T:0x120000 | V:1 T:0x123000 | V:1 T:0x123400 }

- 将地址中的 tag 字段与该行中的每一项进行比较:tag = 0x123456 在 way0 中 hit

- 如果有匹配并且有效字段为 1，那么 cache 命中，我们返回该块的 0x8 Bytes的数据

- 如果没有匹配或者有效字段为 0，那么 cache 未命中，我们从主内存中获取 0x123456 中的 index行数据存储如 cache，在继续执行 store 与 load。
  
## cache 的替换策略

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
// age 的分配如下
reg [2:0] age [15 : 0];
always @(*) begin
    if (hit_en[0]) begin            // way0 hit
        age[index][0] = 1'b1; 
        age[index][1] = 1'b1;
    end else if (hit_en[1]) begin   // way1 hit
        age[index][0] = 1'b1; 
        age[index][1] = 1'b0;
    end else if (hit_en[2]) begin   // way2 hit
        age[index][0] = 1'b0; 
        age[index][2] = 1'b1;
    end else if (hit_en[3]) begin   // way3 hit
        age[index][0] = 1'b0; 
        age[index][2] = 1'b0;
    end else begin
        age[index] = age[index];
    end
end
```

[![p9Cnm7Q.png](https://s1.ax1x.com/2023/04/16/p9Cnm7Q.png)](https://imgse.com/i/p9Cnm7Q)

如图所示，如果有 4 ways，那么我们可利用 1 + 2 位 age 将 way 不断 2 分，当上组被访问，则将 age 记为 1，因此这三位可以记录当前以及前几次的访问，依次判断 age[0] -> age[1]/[2]，如果 age[0] = 1，选取 age[2]，如果 age[2] = 1，选取 way3，此时就将 way3 作为近期最少被访问的 way，而要替换的就是 way3 的 index 的 cacheline，并将 tag 记为内存的 tag，dirty 记为 0。

``` verilog
// 通过 age 得到的 replaced way 如下
// 在此，我们有 16 条 line，每一条都依据各自 age 得到其 replaced way
genvar i;
generate
for (i = 0; i < 15; i= i + 1) 
    begin: replace
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                line_replace_way[i] <= `REPLACE_WAY0;
            end else if (age[i][0] == 0) begin
                if (age[i][1] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY0;
                end else begin  // age[i][1] == 1 or age[i][1] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY1;
                end
            end else begin      // age[i][0] == 1
                if (age[i][2] == 0) begin
                    line_replace_way[i] <= `REPLACE_WAY2;
                end else begin  // age[i][2] == 1 or age[i][2] == 1'bx
                    line_replace_way[i] <= `REPLACE_WAY3;
                end
            end
        end
    end
endgenerate 
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


 