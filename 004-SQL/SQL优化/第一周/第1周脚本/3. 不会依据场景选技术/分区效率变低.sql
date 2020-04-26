drop table part_tab purge;
create table part_tab (id int,col2 int,col3 int)
        partition by range (id)
        (
        partition p1 values less than (10000),
        partition p2 values less than (20000),
        partition p3 values less than (30000),
        partition p4 values less than (40000),
        partition p5 values less than (50000),
        partition p6 values less than (60000),
        partition p7 values less than (70000),
        partition p8 values less than (80000),
        partition p9 values less than (90000),
        partition p10 values less than (100000),
        partition p11 values less than (maxvalue)
        )
        ;
insert into part_tab select rownum,rownum+1,rownum+2 from dual connect by rownum <=110000;
commit;
create  index idx_par_tab_col2 on part_tab(col2) local;
create  index idx_par_tab_col3 on part_tab(col3) ;

drop table norm_tab purge;
create table norm_tab  (id int,col2 int,col3 int);
insert into norm_tab select rownum,rownum+1,rownum+2 from dual connect by rownum <=110000;
commit;
create  index idx_nor_tab_col2 on norm_tab(col2) ;
create  index idx_nor_tab_col3 on norm_tab(col3) ;

set autotrace traceonly statistics
set linesize 1000
set timing on 
select * from part_tab where col2=8 ;
select * from norm_tab where col2=8 ;

select * from part_tab where col2=8 and id=2;
select * from norm_tab where col2=8 and id=2;

--查看索引高度等信息
select index_name,
          blevel,
          leaf_blocks,
          num_rows,
          distinct_keys,
          clustering_factor
     from user_ind_statistics
    where table_name in( 'NORM_TAB');
    
select index_name,
          blevel,
          leaf_blocks,
          num_rows,
          distinct_keys,
          clustering_factor FROM USER_IND_PARTITIONS where index_name like 'IDX_PAR_TAB%';


select * from part_tab where col3=8 ;
