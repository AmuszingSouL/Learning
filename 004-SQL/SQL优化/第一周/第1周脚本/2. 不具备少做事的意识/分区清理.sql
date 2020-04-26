--范围分区示例
drop table range_part_tab purge;
--注意，此分区为范围分区
create table range_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
           partition by range (deal_date)
           (
           partition p1 values less than (TO_DATE('2012-02-01', 'YYYY-MM-DD')),
           partition p2 values less than (TO_DATE('2012-03-01', 'YYYY-MM-DD')),
           partition p3 values less than (TO_DATE('2012-04-01', 'YYYY-MM-DD')),
           partition p4 values less than (TO_DATE('2012-05-01', 'YYYY-MM-DD')),
           partition p5 values less than (TO_DATE('2012-06-01', 'YYYY-MM-DD')),
           partition p6 values less than (TO_DATE('2012-07-01', 'YYYY-MM-DD')),
           partition p7 values less than (TO_DATE('2012-08-01', 'YYYY-MM-DD')),
           partition p8 values less than (TO_DATE('2012-09-01', 'YYYY-MM-DD')),
           partition p9 values less than (TO_DATE('2012-10-01', 'YYYY-MM-DD')),
           partition p10 values less than (TO_DATE('2012-11-01', 'YYYY-MM-DD')),
           partition p11 values less than (TO_DATE('2012-12-01', 'YYYY-MM-DD')),
           partition p12 values less than (TO_DATE('2013-01-01', 'YYYY-MM-DD')),
           partition p_max values less than (maxvalue)
           )
           ;

--以下是插入2012年一整年日期随机数和表示福建地区号含义（591到599）的随机数记录，共有10万条，如下：
insert into range_part_tab (id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-700,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;

--分区原理分析之普通表插入
drop table norm_tab purge;
create table norm_tab (id number,deal_date date,area_code number,contents varchar2(4000));
insert into norm_tab(id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-700,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;




--分区清除的方便例子
delete from norm_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');
--为了后续章节试验的方便，本处暂且将删除的记录回退。
rollback;
select * from range_part_tab partition(p9);
alter table range_part_tab truncate partition p9;

set linesize 1000
set autotrace on 

select count(*) from normal_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');

select count(*) from range_part_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');

















分区交换的神奇例子
drop table mid_table purge;
create table mid_table (id number ,deal_date date,area_code number,contents varchar2(4000));
select count(*) from range_part_tab partition(p8);
---当然，除了上述用partition(p8)的指定分区名查询外，也可以采用分区条件代入查询：
select count(*) from range_part_tab where deal_date>=TO_DATE('2012-08-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-08-31', 'YYYY-MM-DD');
--以下命令就是经典的分区交换：
alter table range_part_tab exchange partition p8 with table mid_table;
--查询发现分区8数据不见了。
select count(*) from range_part_tab partition(p8);
---而普通表记录由刚才的0条变为8628条了，果然实现了交换。
select count(*) from mid_table ;
 
