drop table people purge;
drop table sex purge;

 

create table people (first_name varchar2(200),last_name varchar2(200),sex_id number);                    
create table sex (name varchar2(20), sex_id number);                                  
insert into people (first_name,last_name,sex_id) select object_name,object_type,1 from dba_objects;
insert into sex (name,sex_id) values ('男',1);                                        
insert into sex (name,sex_id) values ('女',2);                                        
insert into sex (name,sex_id) values ('不详',3);                                      
commit;                                                                               

create or replace function get_sex_name(p_id sex.sex_id%type) return sex.name%type is
v_name sex.name%type;
begin
select name
into v_name
from sex
where sex_id=p_id;
return v_name;
end;
/     

以下两种写法是等价的，都是为了查询people 表信息，同时通过sex 表，获取人员的性别 信息。                                                                         
select sex_id,                                                                 
first_name||' '||last_name full_name,                                          
get_sex_name(sex_id) gender                                                    
from people; 

                                                                  
select p.sex_id,                                                               
p.first_name||' '||p.last_name full_name,                                      
sex.name                                                                       
from people p, sex                                                             
where sex.sex_id=p.sex_id;       

但是通过autotrace 比较观察发现两种写法性能上存在巨大差异   
 
set autotrace traceonly  statistics                                        
   
select sex_id,                          
first_name||' '||last_name full_name,
get_sex_name(sex_id) gender          
from people;    

select p.sex_id,                                           
p.first_name||' '||p.last_name full_name,
sex.name                                 
from people p, sex                       
where sex.sex_id=p.sex_id;   






