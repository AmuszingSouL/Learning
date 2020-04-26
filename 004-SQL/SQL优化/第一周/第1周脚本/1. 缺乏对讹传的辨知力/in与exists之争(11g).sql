11g执行一下
select * from v$version;

drop table emp purge;
drop table dept purge;
create table emp as select * from scott.emp;
create table dept as select * from scott.dept;
set timing on 
set linesize 1000

set autotrace traceonly explain
select * from dept where deptno NOT IN ( select deptno from emp ) ;
select * from dept where not exists ( select deptno from emp where emp.deptno=dept.deptno) ;

select * from dept where deptno NOT IN ( select deptno from emp where deptno is not null) and deptno is not null;

--结论：11g与空值有关，都可以用到anti的半连接算法，执行计划一样，性能一样


 
