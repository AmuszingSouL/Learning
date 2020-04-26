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
             to_date( to_char(sysdate-700,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
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
             to_date( to_char(sysdate-700,'J')+TRUNC(DBMS_RANDOM.VALUE(0,365)),'J'),
             ceil(dbms_random.value(590,599)),
             rpad('*',400,'*')
        from dual
      connect by rownum <= 100000;
commit;




--��������ķ�������
delete from norm_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');
--Ϊ�˺����½�����ķ��㣬�������ҽ�ɾ���ļ�¼���ˡ�
rollback;
select * from range_part_tab partition(p9);
alter table range_part_tab truncate partition p9;

set linesize 1000
set autotrace on 

select count(*) from normal_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');

select count(*) from range_part_tab where deal_date>=TO_DATE('2012-09-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-09-30', 'YYYY-MM-DD');

















������������������
drop table mid_table purge;
create table mid_table (id number ,deal_date date,area_code number,contents varchar2(4000));
select count(*) from range_part_tab partition(p8);
---��Ȼ������������partition(p8)��ָ����������ѯ�⣬Ҳ���Բ��÷������������ѯ��
select count(*) from range_part_tab where deal_date>=TO_DATE('2012-08-01', 'YYYY-MM-DD')  and deal_date <= TO_DATE('2012-08-31', 'YYYY-MM-DD');
--����������Ǿ���ķ���������
alter table range_part_tab exchange partition p8 with table mid_table;
--��ѯ���ַ���8���ݲ����ˡ�
select count(*) from range_part_tab partition(p8);
---����ͨ���¼�ɸղŵ�0����Ϊ8628���ˣ���Ȼʵ���˽�����
select count(*) from mid_table ;
 
