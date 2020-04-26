--来来来，做一个试验，看看SQL写法中，表的连接顺序是否很重要
drop table tab_big;
drop table tab_small;
create table tab_big  as select * from dba_objects where rownum<=30000;
create table tab_small  as select * from dba_objects where rownum<=10;
set autotrace traceonly
set linesize 1000
set timing on 
select count(*) from tab_big,tab_small   ;  
select count(*) from tab_small,tab_big   ;

---奇怪，以上实验发现性能是一样的，咋回事呢，看来真是谣言啊，这真是恶意传谣吗？

---NONONO,其实任何谣言，都是有一定的影子的。大家看看俺下面的语句，比较一下性能。
select /*+rule*/ count(*) from tab_big,tab_small ;  
select /*+rule*/ count(*) from tab_small,tab_big ;

--看明白了，显然上一条性能好于下一条，谣言也不是真的无中生有！


结论：原来表连接顺序的说法早就过时了，那是基于规则的时代，现在我们是基于代价的。


