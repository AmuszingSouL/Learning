一.基本信息介绍

dcc_sys_log和dcc_ne_log两表皆无主键
统计信息都已收集
analyze table dcc_sys_log compute statistics for table for all indexes for all indexed columns;
analyze table dcc_ne_log compute statistics for table for all indexes  for all indexed columns;
两表的PEER_ID都为非空列
alter table DCC_SYS_LOG modify PEER_ID  not null;
alter table DCC_NE_LOG  modify peer_id  not null;
表索引情况如下：
create index IDX_DCC_SYS_LOG_PEER on DCC_SYS_LOG (PEER_ID);
create index IDX_DCC_NE_LOG_peer  on DCC_NE_LOG  (PEER_ID);
create index IDX_DCC_NE_LOG_time  on DCC_NE_LOG  (log_time);

SQL语句最终返回记录数特点：该复杂SQL返回记录不超过100条：
一般而言，peer_id为监控主机的标识，一般不超过100个，所以最终复杂SQL的查询结果一般不超过100个，如本案例监控的主机是41个，
最终复杂SQL的查询值就是为41条记录！

数据及记录分布情况
select count(*),
        count(peer_id),
        count(distinct(peer_id)),
        count(case
                when log_time between trunc(sysdate) and sysdate then
                 1
                else
                 null
              end) as current_day,
        count(log_time),
        count(distinct(log_time))
from dcc_ne_log;
 
  COUNT(*) COUNT(PEER_ID) COUNT(DISTINCT(PEER_ID)) CURRENT_DAY COUNT(LOG_TIME) COUNT(DISTINCT(LOG_TIME))
---------- -------------- ------------------------ ----------- --------------- -------------------------
     87154          87154                        7        9016           87154                       380
 
select count(*),
       count(peer_id),
       count(distinct(peer_id)),
       count(log_time),
       count(distinct(log_time))
from dcc_sys_log;
 
  COUNT(*) COUNT(PEER_ID) COUNT(DISTINCT(PEER_ID)) COUNT(LOG_TIME) COUNT(DISTINCT(LOG_TIME))
---------- -------------- ------------------------ --------------- -------------------------
   4899834        4899834                       41         4899834                     27943
   

 
 
 
 
二.逐步提升性能的如下4次改造

原始老脚本及老执行计划

select distinct ne_state.peer_id peer_name,
                         to_char(ne_state.ne_state) peer_state,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (select distinct to_char(nvl(ne_active.active, 0))
                               from dcc_sys_log,
                                    (select peer_id,
                                            decode(action,
                                                   'active',
                                                   1,
                                                   'de-active',
                                                   0,
                                                   0) active,
                                            max(log_time)
                                       from dcc_sys_log
                                      where action = 'active'
                                         or action = 'de-active'
                                      group by (peer_id, action)) ne_active
                              where dcc_sys_log.peer_id = ne_active.peer_id(+)
                                and dcc_sys_log.peer_id = ne_state.peer_id)
                         end) peer_active,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (to_char(nvl((select count(*)
                                           from dcc_ne_log
                                          where dcc_ne_log.result <> 1
                                            and peer_id = ne_state.peer_id
                                            and log_time between
                                                trunc(sysdate) and sysdate
                                          group by (peer_id)),
                                         0)))
                         end) err_cnt,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (to_char(nvl((select count(*)
                                           from dcc_ne_log in_dnl
                                          where in_dnl.direction = 'recv'
                                            and in_dnl.peer_id =
                                                ne_state.peer_id
                                            and log_time between
                                                trunc(sysdate) and sysdate),
                                         0)))
                         end) recv_cnt,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (to_char(nvl((select sum(length)
                                           from dcc_ne_log in_dnl
                                          where in_dnl.direction = 'recv'
                                            and in_dnl.peer_id =
                                                ne_state.peer_id
                                            and log_time between
                                                trunc(sysdate) and sysdate),
                                         0)))
                         end) recv_byte,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (to_char(nvl((select count(*)
                                           from dcc_ne_log in_dnl
                                          where in_dnl.direction = 'send'
                                            and in_dnl.peer_id =
                                                ne_state.peer_id
                                            and log_time between
                                                trunc(sysdate) and sysdate),
                                         0)))
                         end) send_cnt,
                         (case
                           when ne_state.ne_state = 0 then
                            to_char(0)
                           else
                            (to_char(nvl((select sum(length)
                                           from dcc_ne_log in_dnl
                                          where in_dnl.direction = 'send'
                                            and in_dnl.peer_id =
                                                ne_state.peer_id
                                            and log_time between
                                                trunc(sysdate) and sysdate),
                                         0)))
                         end) send_byte
           from dcc_ne_log,
                (select distinct dsl1.peer_id peer_id,
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state
                   from dcc_sys_log dsl1,
                        (select distinct dnl.peer_id peer_id,
                                         decode(action,
                                                'disconnect',
                                                0,
                                                'connect',
                                                0,
                                                1) ne_state
                           from dcc_sys_log dsl, dcc_ne_log dnl
                          where dsl.peer_id = dnl.peer_id
                            and ((dsl.action = 'disconnect' and
                                dsl.cause = '关闭对端') or
                                (dsl.action = 'connect' and
                                dsl.cause = '连接主机失败'))
                            and dsl.log_time =
                                (select max(log_time)
                                   from dcc_sys_log
                                  where peer_id = dnl.peer_id
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+)) ne_state
          where ne_state.peer_id = dcc_ne_log.peer_id(+)

执行计划

 SELECT STATEMENT, GOAL = ALL_ROWS			120155	7	483		
 HASH UNIQUE			6001	119421	6448734		
  MERGE JOIN OUTER			4414	119421	6448734		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421	2866104		
   SORT JOIN			3818	2	60		
    VIEW	IDEPTEST		3817	2	60		
     SORT GROUP BY			3817	2	84		
      TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3816	30	1260		
       INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421			
 SORT GROUP BY NOSORT			302	1	31		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	1	31		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	33		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	540	17820		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	37		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	540	19980		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	33		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	503	16599		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	37		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	503	18611		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 HASH UNIQUE			120155	7	483		
  HASH JOIN RIGHT OUTER			52583	908514324	62687488356		
   VIEW	IDEPTEST		28574	10	240		
    HASH UNIQUE			28574	10	1160		
     HASH JOIN			28573	1561	181076		
      HASH JOIN			28486	3874	368030		
       VIEW	SYS	VW_SQ_1	14365	41	1353		
        HASH GROUP BY			14365	41	2624		
         TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14092	4895849	313334336		
       TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14107	2462339	152665018		
      INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
   HASH JOIN RIGHT OUTER			18969	908514324	40883144580		
    INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
    INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	5347	4896255	117510120		


----第1次改造---- 

动作：将NE_STATE单独成WITH子句，并用ROWNUM>=0来告知ORACLE中间记录数的情况
      不过我觉的有点奇怪，以前用ROWNUM是为了让视图不要拆开与其他表关联，做
      为一个整体，和今天的效果不一样，今天感觉是起到改变表驱动顺序的作用。
效果：改进了表驱动的顺序，WITH部分的视图结果集小，在前面驱动才是正确的，原先没有ROWNUM时变成在后面驱动。
      具体可以通过UE的比较工具来比较老脚本的执行计划可清晰看出，改变驱动顺序后速度从3000秒提升到50秒。
第1次改造后的SQL语句如下：
with ne_state as                                                                 
(  select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败'))                      
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+) and rownum>=0)                                                                                 
select distinct ne_state.peer_id peer_name,                                       
                         to_char(ne_state.ne_state) peer_state,                   
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (select distinct to_char(nvl(ne_active.active, 0))    
                               from dcc_sys_log,                                  
                                    (select peer_id,                              
                                            decode(action,                        
                                                   'active',                      
                                                   1,                             
                                                   'de-active',                   
                                                   0,                             
                                                   0) active,                     
                                            max(log_time)                         
                                       from dcc_sys_log                           
                                      where action = 'active'                     
                                         or action = 'de-active'                  
                                      group by (peer_id, action)) ne_active       
                              where dcc_sys_log.peer_id = ne_active.peer_id(+)    
                                and dcc_sys_log.peer_id = ne_state.peer_id)       
                         end) peer_active,                                        
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log                        
                                          where dcc_ne_log.result <> 1            
                                            and peer_id = ne_state.peer_id        
                                            and log_time between                  
                                                trunc(sysdate) and sysdate        
                                          group by (peer_id)),                    
                                         0)))                                     
                         end) err_cnt,                                            
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log in_dnl                 
                                          where in_dnl.direction = 'recv'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id                  
                                            and log_time between                  
                                                trunc(sysdate) and sysdate),      
                                         0)))                                     
                         end) recv_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log in_dnl                 
                                          where in_dnl.direction = 'recv'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id                  
                                            and log_time between                  
                                                trunc(sysdate) and sysdate),      
                                         0)))                                     
                         end) recv_byte,                                          
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log in_dnl                 
                                          where in_dnl.direction = 'send'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id                  
                                            and log_time between                  
                                                trunc(sysdate) and sysdate),      
                                         0)))                                     
                         end) send_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log in_dnl                 
                                          where in_dnl.direction = 'send'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id                  
                                            and log_time between                  
                                                trunc(sysdate) and sysdate),      
                                         0)))                                     
                         end) send_byte                                           
           from dcc_ne_log,ne_state                                               
          where ne_state.peer_id = dcc_ne_log.peer_id(+);                         
          
          
第1次改造后的SQL执行计划如下：
SELECT STATEMENT, GOAL = ALL_ROWS			34310	7	336		
 HASH UNIQUE			6001	119421	6448734		
  MERGE JOIN OUTER			4414	119421	6448734		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421	2866104		
   SORT JOIN			3818	2	60		
    VIEW	IDEPTEST		3817	2	60		
     SORT GROUP BY			3817	2	84		
      TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3816	30	1260		
       INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421			
 SORT GROUP BY NOSORT			302	1	31		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	1	31		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	33		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	540	17820		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	37		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	540	19980		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	33		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	503	16599		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 SORT AGGREGATE				1	37		
  FILTER							
   TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	503	18611		
    INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
 HASH UNIQUE			34310	7	336		
  HASH JOIN OUTER			34309	1299	62352		
   VIEW	IDEPTEST		34222	7	189		
    HASH UNIQUE			34222	7	336		
     COUNT							
      FILTER							
       HASH JOIN RIGHT OUTER			33949	4896255	235020240		
        VIEW	IDEPTEST		28574	10	240		
         HASH UNIQUE			28574	10	1160		
          HASH JOIN			28573	1561	181076		
           HASH JOIN			28486	3874	368030		
            VIEW	SYS	VW_SQ_1	14365	41	1353		
             HASH GROUP BY			14365	41	2624		
              TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14092	4895849	313334336		
            TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14107	2462339	152665018		
           INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
        INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	5347	4896255	117510120		
   INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		




---第2次改造----

动作：构造dcc_ne_log_time的WITH子句.
效果：多次调用这个后，系统内部优化，产生自带临时表SYS_TEMP_0FD9D661A_2F9A0F1，
      多次调用SYS_TEMP_0FD9D661A_2F9A0F1而非调用dcc_ne_log是有差别的，调用SYS_TEMP_0FD9D661A_2F9A0F1
      极大的提升了性能，从50秒缩短为14秒！
第2次改造后SQL语句如下：
with ne_state as                                                                 
(select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败'))                      
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+) and rownum>=0),
dcc_ne_log_time as  (select * from dcc_ne_log where  log_time between   trunc(sysdate) and sysdate )                                                                                
select distinct ne_state.peer_id peer_name,                                       
                         to_char(ne_state.ne_state) peer_state,                   
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (select distinct to_char(nvl(ne_active.active, 0))    
                               from dcc_sys_log,                                  
                                    (select peer_id,                              
                                            decode(action,                        
                                                   'active',                      
                                                   1,                             
                                                   'de-active',                   
                                                   0,                             
                                                   0) active,                     
                                            max(log_time)                         
                                       from dcc_sys_log                           
                                      where action = 'active'                     
                                         or action = 'de-active'                  
                                      group by (peer_id, action)) ne_active       
                              where dcc_sys_log.peer_id = ne_active.peer_id(+)    
                                and dcc_sys_log.peer_id = ne_state.peer_id)       
                         end) peer_active,                                        
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time                        
                                          where dcc_ne_log_time.result <> 1            
                                            and peer_id = ne_state.peer_id              
                                          group by (peer_id)),                    
                                         0)))                                     
                         end) err_cnt,                                            
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'recv'   
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) recv_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'recv'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) recv_byte,                                          
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'send'    
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) send_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'send'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) send_byte                                           
           from dcc_ne_log_time,ne_state                                               
          where ne_state.peer_id = dcc_ne_log_time.peer_id(+); 
          
          
第2次改造后的SQL执行计划如下：
SELECT STATEMENT, GOAL = ALL_ROWS			34584	7	336		
 HASH UNIQUE			6001	119421	6448734		
  MERGE JOIN OUTER			4414	119421	6448734		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421	2866104		
   SORT JOIN			3818	2	60		
    VIEW	IDEPTEST		3817	2	60		
     SORT GROUP BY			3817	2	84		
      TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3816	30	1260		
       INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421			
 SORT GROUP BY NOSORT			58	7	238		
  VIEW	IDEPTEST		58	7302	248268		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	53		
  VIEW	IDEPTEST		58	7302	387006		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	57		
  VIEW	IDEPTEST		58	7302	416214		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	53		
  VIEW	IDEPTEST		58	7302	387006		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	57		
  VIEW	IDEPTEST		58	7302	416214		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		
 TEMP TABLE TRANSFORMATION							
  LOAD AS SELECT							
   COUNT							
    FILTER							
     FILTER							
      TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	7302	1891218		
       INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
  HASH UNIQUE			34282	7	336		
   HASH JOIN OUTER			34281	7	336		
    VIEW	IDEPTEST		34222	7	189		
     HASH UNIQUE			34222	7	336		
      COUNT							
       FILTER							
        HASH JOIN RIGHT OUTER			33949	4896255	235020240		
         VIEW	IDEPTEST		28574	10	240		
          HASH UNIQUE			28574	10	1160		
           HASH JOIN			28573	1561	181076		
            HASH JOIN			28486	3874	368030		
             VIEW	SYS	VW_SQ_1	14365	41	1353		
              HASH GROUP BY			14365	41	2624		
               TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14092	4895849	313334336		
             TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14107	2462339	152665018		
            INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
         INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	5347	4896255	117510120		
    VIEW	IDEPTEST		58	7302	153342		
     TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D661A_2F9A0F1	58	7302	1891218		




----第3次改进-----

动作：部分SQL进行等价改写
将 select distinct to_char(nvl(ne_active.active, 0))    
                               from dcc_sys_log,                                  
                                    (select peer_id,                              
                                            decode(action,                        
                                                   'active',                      
                                                   1,                             
                                                   'de-active',                   
                                                   0,                             
                                                   0) active,                     
                                            max(log_time)                         
                                       from dcc_sys_log                           
                                      where action = 'active'                     
                                         or action = 'de-active'                  
                                      group by (peer_id, action)) ne_active       
                              where dcc_sys_log.peer_id = ne_active.peer_id(+)    
                                and dcc_sys_log.peer_id = ne_state.peer_id
修改为：
NVL((select '1' from dcc_sys_log where peer_id = ne_state.peer_id and action = 'active' and rownum=1),'0')  

效果：改写的写法dcc_sys_log表的扫描1次数，而未改写时是扫描dcc_sys_log表2次
      性能提升，执行速度由15秒变为10秒
第3次改造后的SQL语句如下：
with ne_state as                                                                 
(select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败'))                      
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+) and rownum>=0),
dcc_ne_log_time as  (select * from dcc_ne_log where  log_time between   trunc(sysdate) and sysdate )                                                                                
select distinct ne_state.peer_id peer_name,                                       
                         to_char(ne_state.ne_state) peer_state,                   
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                         NVL((select '1' from dcc_sys_log where peer_id = ne_state.peer_id and action = 'active' and rownum=1),'0')      
                         end) peer_active,                                        
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time                        
                                          where dcc_ne_log_time.result <> 1            
                                            and peer_id = ne_state.peer_id              
                                          group by (peer_id)),                    
                                         0)))                                     
                         end) err_cnt,                                            
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'recv'   
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) recv_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'recv'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) recv_byte,                                          
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select count(*)                         
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'send'      
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) send_cnt,                                           
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                            (to_char(nvl((select sum(length)                      
                                           from dcc_ne_log_time in_dnl                 
                                          where in_dnl.direction = 'send'         
                                            and in_dnl.peer_id =                  
                                                ne_state.peer_id),      
                                         0)))                                     
                         end) send_byte                                           
           from dcc_ne_log_time,ne_state                                               
          where ne_state.peer_id = dcc_ne_log_time.peer_id(+); 


第3次改造后的SQL执行计划如下：
SELECT STATEMENT, GOAL = ALL_ROWS			34584	7	336		
 COUNT STOPKEY							
  TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3816	1	35		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421			
 SORT GROUP BY NOSORT			58	7	238		
  VIEW	IDEPTEST		58	7302	248268		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	44		
  VIEW	IDEPTEST		58	7302	321288		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	57		
  VIEW	IDEPTEST		58	7302	416214		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	44		
  VIEW	IDEPTEST		58	7302	321288		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		
 SORT AGGREGATE				1	57		
  VIEW	IDEPTEST		58	7302	416214		
   TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		
 TEMP TABLE TRANSFORMATION							
  LOAD AS SELECT							
   FILTER							
    TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	302	7302	1891218		
     INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	21	7302			
  HASH UNIQUE			34282	7	336		
   HASH JOIN OUTER			34281	7	336		
    VIEW	IDEPTEST		34222	7	189		
     HASH UNIQUE			34222	7	336		
      COUNT							
       FILTER							
        HASH JOIN RIGHT OUTER			33949	4896255	235020240		
         VIEW	IDEPTEST		28574	10	240		
          HASH UNIQUE			28574	10	1160		
           HASH JOIN			28573	1561	181076		
            HASH JOIN			28486	3874	368030		
             VIEW	SYS	VW_SQ_1	14365	41	1353		
              HASH GROUP BY			14365	41	2624		
               TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14092	4895849	313334336		
             TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14107	2462339	152665018		
            INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
         INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	5347	4896255	117510120		
    VIEW	IDEPTEST		58	7302	153342		
     TABLE ACCESS FULL	SYS	SYS_TEMP_0FD9D662A_2F9A0F1	58	7302	1891218		



---第4次改造----
动作：将所有标量子查询改造为单独一个表关联写法
效果：将标量子查询的多次扫描，降低为将表扫描次仅1次，执行时间从10秒缩短为7秒


with ne_state as                                                                 
(select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败'))                      
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+) and rownum>=0),
dcc_ne_log_time as (select peer_id
                          ,COUNT(CASE WHEN RESULT <> 1 THEN 1 END) err_cnt
                          ,COUNT(CASE WHEN direction = 'recv' THEN 1 END) recv_cnt
                          ,SUM(CASE WHEN direction = 'recv' THEN length END) recv_byte
                          ,COUNT(CASE WHEN direction = 'send' THEN 1 END) send_cnt
                          ,SUM(CASE WHEN direction = 'send' THEN length END) send_byte
                     from dcc_ne_log 
                     where log_time >=trunc(sysdate) ---- between trunc(sysdate) and sysdate 
                     GROUP BY peer_id)                                                                    
select distinct ne_state.peer_id peer_name,                                       
                         to_char(ne_state.ne_state) peer_state,                   
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                         NVL((select '1' from dcc_sys_log where peer_id = ne_state.peer_id and action = 'active' and rownum=1),'0')  
                         end) peer_active,   
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.ERR_CNT,0)) ERR_CNT, ---注意NVL改造
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.recv_cnt,0)) recv_cnt, 
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.recv_byte,0)) recv_byte,
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.send_cnt,0)) send_cnt, 
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.send_byte,0)) send_byte                                      
           from ne_state ,dcc_ne_log_time dnlt  
           where    ne_state.peer_id=dnlt.peer_id(+)

                                                    
第4次改造后的SQL执行计划
SELECT STATEMENT, GOAL = ALL_ROWS			34231	7	791		
 COUNT STOPKEY							
  TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3816	1	35		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	596	119421			
 HASH UNIQUE			34231	7	791		
  HASH JOIN OUTER			34230	7	791		
   VIEW	IDEPTEST		34222	7	189		
    HASH UNIQUE			34222	7	336		
     COUNT							
      FILTER							
       HASH JOIN RIGHT OUTER			33949	4896255	235020240		
        VIEW	IDEPTEST		28574	10	240		
         HASH UNIQUE			28574	10	1160		
          HASH JOIN			28573	1561	181076		
           HASH JOIN			28486	3874	368030		
            VIEW	SYS	VW_SQ_1	14365	41	1353		
             HASH GROUP BY			14365	41	2624		
              TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14092	4895849	313334336		
            TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14107	2462339	152665018		
           INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	86	85428	1793988		
        INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	5347	4896255	117510120		
   VIEW	IDEPTEST		8	7	602		
    HASH GROUP BY			8	7	280		
     TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	7	108	4320		
      INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	2	108			








---第5次改造

 如下部分（即我改造后语句的第一个WITH的地方），觉的非常怪异
        外面用 action和cause，里面在查最大时间用的是log_type = '对端交互'
        根据我的经验常识来看，需求应该是log_type = '对端交互'同时作用于内外，即找出log_type = '对端交互'的最近一条记录，
        然后看它的action和cause是否满足要求，难道不是这样吗，这样才顺畅嘛。
select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败'))                      
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+)    and rownum>=0
                  
     如果我猜测的是对的，代码就应该改写为如下(增加and log_type = '对端交互' ）：
     把数据限于log_type = '对端交互'的那些。如果有哪个peer_id不存在 log_type = '对端交互'，
     那么这个peer_id不在新写法中出现。之前的旧写法包括所有。
     
     select distinct dsl1.peer_id peer_id,                                          
                                 nvl(ne_disconnect_info.ne_state, 1) ne_state     
                   from dcc_sys_log dsl1,                                         
                        (select distinct dnl.peer_id peer_id,                     
                                         decode(action,                           
                                                'disconnect',                     
                                                0,                                
                                                'connect',                        
                                                0,                                
                                                1) ne_state                       
                           from dcc_sys_log dsl, dcc_ne_log dnl                   
                          where dsl.peer_id = dnl.peer_id                         
                            and ((dsl.action = 'disconnect' and                   
                                dsl.cause = '关闭对端') or                        
                                (dsl.action = 'connect' and                       
                                dsl.cause = '连接主机失败')) 
                            and log_type = '对端交互'                     
                            and dsl.log_time =                                    
                                (select max(log_time)                             
                                   from dcc_sys_log                               
                                  where peer_id = dnl.peer_id                     
                                    and log_type = '对端交互')) ne_disconnect_info
                  where dsl1.peer_id = ne_disconnect_info.peer_id(+)    and rownum>=0
     
     以下改写可以完善取最大日期的记录的方法,可进一步减少扫描次数
     

     
SELECT a.peer_id,
CASE WHEN dnl.peer_id IS NOT NULL AND str IN ('disconnect关闭对端','connect连接主机失败') THEN '0' ELSE '1' END ne_state
FROM (SELECT peer_id,MIN(action||cause) KEEP(DENSE_RANK LAST ORDER BY log_time) str 
      FROM dcc_sys_log dsl
      WHERE log_type = '对端交互'
      GROUP BY peer_id
) a,(SELECT DISTINCT peer_id FROM dcc_ne_log) dnl 
WHERE a.peer_id = dnl.peer_id(+)

   
    经过5次改造后，最终完善优化版代码如下：

with ne_state as                                                                 
(SELECT a.peer_id,
CASE WHEN dnl.peer_id IS NOT NULL AND str IN ('disconnect关闭对端','connect连接主机失败') THEN '0' ELSE '1' END ne_state
FROM (SELECT peer_id,MIN(action||cause) KEEP(DENSE_RANK LAST ORDER BY log_time) str 
      FROM dcc_sys_log dsl
      WHERE log_type = '对端交互'
      GROUP BY peer_id
) a,(SELECT DISTINCT peer_id FROM dcc_ne_log) dnl 
WHERE a.peer_id = dnl.peer_id(+)),
dcc_ne_log_time as (select peer_id
                          ,COUNT(CASE WHEN RESULT <> 1 THEN 1 END) err_cnt
                          ,COUNT(CASE WHEN direction = 'recv' THEN 1 END) recv_cnt
                          ,SUM(CASE WHEN direction = 'recv' THEN length END) recv_byte
                          ,COUNT(CASE WHEN direction = 'send' THEN 1 END) send_cnt
                          ,SUM(CASE WHEN direction = 'send' THEN length END) send_byte
                     from dcc_ne_log 
                     where log_time >=trunc(sysdate) ---- between trunc(sysdate) and sysdate 
                     GROUP BY peer_id)                                                                    
select distinct ne_state.peer_id peer_name,                                       
                         to_char(ne_state.ne_state) peer_state,                   
                         (case                                                    
                           when ne_state.ne_state = 0 then                        
                            to_char(0)                                            
                           else                                                   
                         NVL((select '1' from dcc_sys_log where peer_id = ne_state.peer_id and action = 'active' and rownum=1),'0')  
                         end) peer_active,   
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.ERR_CNT,0)) ERR_CNT, ---注意NVL改造
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.recv_cnt,0)) recv_cnt, 
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.recv_byte,0)) recv_byte,
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.send_cnt,0)) send_cnt, 
                         decode(ne_state.ne_state,0,'0',nvl(dnlt.send_byte,0)) send_byte                                      
           from ne_state ,dcc_ne_log_time dnlt  
           where    ne_state.peer_id=dnlt.peer_id(+)
     
     
执行计划：           
SELECT STATEMENT, GOAL = ALL_ROWS			14880	71	19667		
 COUNT STOPKEY							
  TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_SYS_LOG	3235	1	35		
   INDEX RANGE SCAN	IDEPTEST	IDX_DCC_SYS_LOG_PEER	505	100809			
 HASH UNIQUE			14880	71	19667		
  HASH JOIN OUTER			14878	19100	5290700		
   HASH JOIN RIGHT OUTER			14657	49	12446		
    VIEW	IDEPTEST		65	10	880		
     HASH GROUP BY			65	10	430		
      TABLE ACCESS BY INDEX ROWID	IDEPTEST	DCC_NE_LOG	64	1388	59684		
       INDEX RANGE SCAN	IDEPTEST	IDX_DCC_NE_LOG_TIME	7	1388			
    VIEW	IDEPTEST		14592	49	8134		
     SORT GROUP BY			14592	49	3479		
      TABLE ACCESS FULL	IDEPTEST	DCC_SYS_LOG	14316	4939225	350684975		
   INDEX FAST FULL SCAN	IDEPTEST	IDX_DCC_NE_LOG_PEER	220	176424	4057752		
