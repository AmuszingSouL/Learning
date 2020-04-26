--��Χ����ʾ��
drop table range_part_tab purge;
--ע�⣬�˷���Ϊ��Χ����
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

--�����ǲ���2012��һ��������������ͱ�ʾ���������ź��壨591��599�����������¼������10���������£�
insert into range_part_tab (id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;

--����ԭ�����֮��ͨ�����
drop table norm_tab purge;
create table norm_tab (id number,deal_date date,area_code number,contents varchar2(4000));
insert into norm_tab(id,deal_date,area_code,contents)
      select rownum,
             to_date( to_char(sysdate-365,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;


 
--�۲췶Χ������ķ���������������������
set linesize 1000
set autotrace traceonly
set timing on
select *
      from range_part_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD');

--�Ƚ���ͬ��䣬��ͨ���޷��õ�DEAL_DATE�������з������������
select *
      from norm_tab
     where deal_date >= TO_DATE('2012-09-04', 'YYYY-MM-DD')
       and deal_date <= TO_DATE('2012-09-07', 'YYYY-MM-DD');
	   

--����ԭ�����֮��ͨ����������ڶη����ϵĲ���
SET LINESIZE 666
set pagesize 5000
column segment_name format a20
column partition_name format a20
column segment_type format a20
select segment_name,
       partition_name,
       segment_type,
       bytes / 1024 / 1024 "�ֽ���(M)",
       tablespace_name
  from user_segments
 where segment_name IN('RANGE_PART_TAB','NORM_TAB');	   
