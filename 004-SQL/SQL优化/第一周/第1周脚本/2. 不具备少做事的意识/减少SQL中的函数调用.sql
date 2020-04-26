
---更细致的研究：

drop table t1 purge; 
drop table t2 purge; 
create table t1 as select * from dba_objects; 
create table t2 as select * from dba_objects; 
update t2 set object_id=rownum;
commit;

create or replace function f_deal1(p_name in varchar2) 
 return  varchar2 deterministic
 is
v_name varchar2(200);
begin
  -- select substr(upper(p_name),1,4)   into v_name from dual;
   v_name:=substr(upper(p_name),1,4);
   return v_name;
end;
/

create or replace function f_deal2(p_name in varchar2) 
 return  varchar2 deterministic
 is
v_name varchar2(200);
begin
  select substr(upper(p_name),1,4)   into v_name from dual;
  --  v_name:=substr(upper(p_name),1,4);
   return v_name;
end;
/


set autotrace traceonly statistics
set linesize 1000

       
select  * from t1 where f_deal1(object_name)='FILE';
select  * from t1 where f_deal2(object_name)='FILE' ;    

CREATE INDEX IDX_OBJECT_NAME ON T1(f_deal2(object_name));      
      
select  * from t1 where f_deal2(object_name)='FILE' ;      

select  f_deal1(object_name) from t1  ; 
select  f_deal2(object_name) from t1  ;




select f_deal2(t1.object_name)
  from t1, t2
 where t1.object_id = t2.object_id
   and t2.object_type LIKE '%PART%';


select *
  from t2, (select f_deal2(t1.object_name), object_ID from t1) t
 where t2.object_id = t.object_id
   and t2.object_type LIKE '%PART%';
   

select name from (select rownum rn ,f_deal2(t1.object_name) name from t1) where rn>=10 and rn<=12;   
select name from (select rownum rn ,f_deal2(t1.object_name) name from t1 where rownum<=12) where rn>=10 ;


select name from (select rownum rn ,f_deal2(t1.object_name) name from t1) where rn<=12;
select f_deal2(t1.object_name) name from t1 where rownum<=12;

select f_deal2(t1.object_name) name from t1 where object_id=9999999999999;
select * from t1 where f_deal2(t1.object_name)='AAAA'
select * from t1 where f_deal1(t1.object_name)='AAAA'


----------------------------------------------------------------------------------------------------------------------------------------------






