create or replace procedure proc_insert
as
begin
    for i in 1 .. 100000
    loop
     insert into t values (i);   
    end loop;
  commit;
end;
/

drop table t purge;
create table t ( x int );
set timing on
begin
    for i in 1 .. 100000
    loop
     insert into t values (i);   
    end loop;
  commit;
end;
/




--����д�����죺

drop table t purge;
create table t ( x int );
insert into t select rownum from dual connect by level<=100000;
commit;
