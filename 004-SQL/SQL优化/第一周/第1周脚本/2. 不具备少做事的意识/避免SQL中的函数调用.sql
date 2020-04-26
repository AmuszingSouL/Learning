drop table people purge;
drop table sex purge;

 

create table people (first_name varchar2(200),last_name varchar2(200),sex_id number);                    
create table sex (name varchar2(20), sex_id number);                                  
insert into people (first_name,last_name,sex_id) select object_name,object_type,1 from dba_objects;
insert into sex (name,sex_id) values ('��',1);                                        
insert into sex (name,sex_id) values ('Ů',2);                                        
insert into sex (name,sex_id) values ('����',3);                                      
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

��������д���ǵȼ۵ģ�����Ϊ�˲�ѯpeople ����Ϣ��ͬʱͨ��sex ����ȡ��Ա���Ա� ��Ϣ��                                                                         
select sex_id,                                                                 
first_name||' '||last_name full_name,                                          
get_sex_name(sex_id) gender                                                    
from people; 

                                                                  
select p.sex_id,                                                               
p.first_name||' '||p.last_name full_name,                                      
sex.name                                                                       
from people p, sex                                                             
where sex.sex_id=p.sex_id;       

����ͨ��autotrace �ȽϹ۲췢������д�������ϴ��ھ޴����   
 
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






