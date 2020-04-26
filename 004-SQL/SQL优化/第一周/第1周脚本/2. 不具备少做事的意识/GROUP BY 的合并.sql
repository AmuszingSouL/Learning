select decode(so.sFileName, 'SNP_20', 'SNP', 'HNIC_2', 'HNIC', 'IBRC_2', 'IBRC', 'IISMP_', 'IISMP', 'NIC_20', 'NIC', 'NIG_20', 'NIG', 'IIC_20', 'IIC', 'HIIC_2', 'HIIC', 'CA.D.A', 'CA.D.ATSR', 'ULH_20', 'ULH', 'IBRST_', 'IBRST', so.sFileName) 业务名称,
       so.sFileCount 合并前文件个数,
       so.sRecordNum 合并前总记录数,
       ta.tFileCount 合并后文件个数,
       ta.tRecordNum 合并后总记录数,
       NVL(so1.sFileCount, 0) 合并前当天文件个数,
       NVL(so1.sRecordNum, 0) 合并前当天文件总记录数,
       NVL(so2.sFileCount, 0) 合并前昨天文件个数,
       NVL(so2.sRecordNum, 0) 合并前昨天文件总记录数
from (select substr(a.file_name, 1, 6) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id 
                  and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')) a
      group by substr(a.file_name, 1, 6)
      order by substr(a.file_name, 1, 6)) so
LEFT JOIN 
      (select substr(a.file_name, 1, 6) sfileName,
              count(*) sFileCount,
              sum(sRecordNum) sRecordNum
       from (select distinct bsf.file_name,
                    bsf.record_num sRecordNum,
                    bsf.create_time
             from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
             where bsf.file_id = ipar.bus_file_id
                   and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                   AND FILE_NAME LIKE '%20100805%') a
       group by substr(a.file_name, 1, 6)
       order by substr(a.file_name, 1, 6)) so1
ON (so.sFileName = so1.sFileName)
LEFT JOIN 
       (select substr(a.file_name, 1, 6) sfileName,
               count(*) sFileCount,
               sum(sRecordNum) sRecordNum
        from (select distinct bsf.file_name,
                     bsf.record_num sRecordNum,
                     bsf.create_time
              from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
              where bsf.file_id = ipar.bus_file_id
                    and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                    AND FILE_NAME not LIKE '%20100805%') a
        group by substr(a.file_name, 1, 6)
        order by substr(a.file_name, 1, 6)) so2
ON (so.sFileName = so2.sFileName)
LEFT JOIN 
        (select substr(a.file_name, 1, 6) tFileName,
                count(*) tFileCount,
                sum(record_num) tRecordNum
         from (select distinct ipsf.file_name, 
                      ipsf.record_num
               from idep_plugin_send_filelist ipsf
               where trunc(ipsf.create_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                     and remark = '处理成功') a
         group by substr(a.file_name, 1, 6)
         order by substr(a.file_name, 1, 6)) ta
         ON (so.sFileName = ta.tFileName)
         where so.sFileName not like 'MVI%'
union
select so.sFileName,
       so.sFileCount,
       (so.sRecordNum - (so.sFileCount * 2)) sRecordNum,
       ta.tFileCount,
       ta.tRecordNum,
       NVL(so1.sFileCount, 0),
       (nvl(so1.sRecordNum, 0) - (nvl(so1.sFileCount, 0) * 2)),
       NVL(so2.sFileCount, 0),
       (nvl(so2.sRecordNum, 0) - (nvl(so2.sFileCount, 0) * 2))
from (select substr(a.file_name, 1, 3) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id
                  and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')) a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) so
LEFT JOIN 
     (select substr(a.file_name, 1, 3) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id
                  and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                  AND FILE_NAME LIKE 'MVI100805%') a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) so1
ON (so.sFileName = so1.sFileName)
LEFT JOIN 
     (select substr(a.file_name, 1, 3) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id
                  and trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                  AND FILE_NAME not LIKE 'MVI100805%') a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) so2
ON (so.sFileName = so2.sFileName)
LEFT JOIN 
     (select substr(a.file_name, 1, 3) tFileName,
             count(*) tFileCount,
             sum(record_num) tRecordNum
      from (select distinct ipsf.file_name, 
                   ipsf.record_num
            from idep_plugin_send_filelist ipsf
            where trunc(ipsf.create_time) = to_date('2010-08-05', 'yyyy-mm-dd')
                  and remark = '处理成功') a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) ta
ON (so.sFileName = ta.tFileName)
WHERE so.sFileName = 'MVI' ---这里有错吧，感觉应该是 WHERE so.sFileName  like  'MVI%'，确实没错，因为这里是截取过的了




注意点：

1.将trunc(ipar.relation_time) = to_date('2010-08-05', 'yyyy-mm-dd') 等等类似之处改写为如下，要避免对列进行运算，这样会
导致用不上索引，除非是建立了函数索引。
ipsf.create_time >= to_date('2010-08-05', 'yyyy-mm-dd') and ipsf.create_time < to_date('2010-08-05', 'yyyy-mm-dd')+1

2. 确保IDEP_PLUGIN_AUTO_RELATION的relation_time有索引
   确保idep_plugin_send_filelist的create_time列有索引

3.可通过CASE WHEN 语句进一步减少表扫描次数，如（count(CASE WHEN FILE_NAME LIKE '%20100805%' THEN 1 END) sFileCount1），
类似如上的修改，可以等价改写，将本应用的表扫描从8次减少为4次。

代码改写如下：
select decode(so.sFileName, 'SNP_20', 'SNP', 'HNIC_2', 'HNIC', 'IBRC_2', 'IBRC', 'IISMP_', 'IISMP', 'NIC_20', 'NIC', 'NIG_20', 'NIG', 'IIC_20', 'IIC', 'HIIC_2', 'HIIC', 'CA.D.A', 'CA.D.ATSR', 'ULH_20', 'ULH', 'IBRST_', 'IBRST', so.sFileName) 业务名称,
       so.sFileCount 合并前文件个数,
       so.sRecordNum 合并前总记录数,
       ta.tFileCount 合并后文件个数,
       ta.tRecordNum 合并后总记录数,
       NVL(so.sFileCount1, 0) 合并前当天文件个数,
       NVL(so.sRecordNum1, 0) 合并前当天文件总记录数,
       NVL(so.sFileCount2, 0) 合并前昨天文件个数,
       NVL(so.sRecordNum2, 0) 合并前昨天文件总记录数
from (select substr(a.file_name, 1, 6) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum,
             count(CASE WHEN FILE_NAME LIKE '%20100805%' THEN 1 END) sFileCount1,
             sum(CASE WHEN FILE_NAME LIKE '%20100805%' THEN sRecordNum END) sRecordNum1,
             count(CASE WHEN FILE_NAME NOT LIKE '%20100805%' THEN 1 END) sFileCount2,
             sum(CASE WHEN FILE_NAME NOT LIKE '%20100805%' THEN sRecordNum END) sRecordNum2
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id 
                  and ipar.relation_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                  and ipar.relation_time < to_date('2010-08-05', 'yyyy-mm-dd')+1) a
      group by substr(a.file_name, 1, 6)
      order by substr(a.file_name, 1, 6)) so
LEFT JOIN 
        (select substr(a.file_name, 1, 6) tFileName,
                count(*) tFileCount,
                sum(record_num) tRecordNum
         from (select distinct ipsf.file_name, 
                      ipsf.record_num
               from idep_plugin_send_filelist ipsf
               where ipsf.create_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                     and ipsf.create_time < to_date('2010-08-05', 'yyyy-mm-dd')+1
                     and remark = '处理成功') a
         group by substr(a.file_name, 1, 6)
         order by substr(a.file_name, 1, 6)) ta
         ON (so.sFileName = ta.tFileName)
         where so.sFileName not like 'MVI%'
union

select so.sFileName,
       so.sFileCount,
       (so.sRecordNum - (so.sFileCount * 2)) sRecordNum,
       ta.tFileCount,
       ta.tRecordNum,
       NVL(so.sFileCount1, 0),
       (nvl(so.sRecordNum1, 0) - (nvl(so.sFileCount1, 0) * 2)),
       NVL(so.sFileCount2, 0),
       (nvl(so.sRecordNum2, 0) - (nvl(so.sFileCount2, 0) * 2))
from (select substr(a.file_name, 1, 3) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum,
             count(CASE WHEN FILE_NAME LIKE  'MVI100805%' THEN 1 END) sFileCount1,
             sum(CASE WHEN FILE_NAME LIKE  'MVI100805%' THEN sRecordNum END) sRecordNum1,
             count(CASE WHEN FILE_NAME NOT LIKE  'MVI100805%' THEN 1 END) sFileCount2,
             sum(CASE WHEN FILE_NAME NOT LIKE  'MVI100805%' THEN sRecordNum END) sRecordNum2
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id
                   and ipar.relation_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                   and ipar.relation_time < to_date('2010-08-05', 'yyyy-mm-dd')+1) a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) so
LEFT JOIN 
     (select substr(a.file_name, 1, 3) tFileName,
             count(*) tFileCount,
             sum(record_num) tRecordNum
      from (select distinct ipsf.file_name, 
                   ipsf.record_num
            from idep_plugin_send_filelist ipsf
            where ipsf.create_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                  and ipsf.create_time < to_date('2010-08-05', 'yyyy-mm-dd')+1
                  and remark = '处理成功') a
      group by substr(a.file_name, 1, 3)
      order by substr(a.file_name, 1, 3)) ta
ON (so.sFileName = ta.tFileName)
WHERE so.sFileName = 'MVI'



最终版
select decode(so.sFileName, 'SNP_20', 'SNP', 'HNIC_2', 'HNIC', 'IBRC_2', 'IBRC', 'IISMP_', 'IISMP', 'NIC_20', 'NIC', 'NIG_20', 'NIG', 'IIC_20', 'IIC', 'HIIC_2', 'HIIC', 'CA.D.A', 'CA.D.ATSR', 'ULH_20', 'ULH', 'IBRST_', 'IBRST', so.sFileName) 业务名称,
       so.sFileCount 合并前文件个数,
       case when so.sfilename like 'MVI%' then (so.sRecordNum - (so.sFileCount * 2)) else so.sRecordNum end 合并前总记录数,
       ta.tFileCount 合并后文件个数,
       ta.tRecordNum 合并后总记录数,
       NVL(so.sFileCount1, 0) 合并前当天文件个数,
       case when so.sfilename like 'MVI%' 
       then  (nvl(so.sRecordNum1, 0) - (nvl(so.sFileCount1, 0) * 2))  
       else NVL(so.sRecordNum1, 0) end  合并前当天文件总记录数,
       NVL(so.sFileCount2, 0) 合并前昨天文件个数,
       case when so.sfilename like 'MVI%' 
       then  (nvl(so.sRecordNum2, 0) - (nvl(so.sFileCount2, 0) * 2))  
       else NVL(so.sRecordNum2, 0) end 合并前昨天文件总记录数
from (select substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END) sfileName,
             count(*) sFileCount,
             sum(sRecordNum) sRecordNum,
             count(CASE WHEN (FILE_NAME LIKE '%20100805%'  AND FILE_NAME not like 'MVI%') OR (FILE_NAME LIKE  'MVI100805%'  AND FILE_NAME like 'MVI%') THEN 1 END) sFileCount1,
             sum  (CASE WHEN (FILE_NAME LIKE '%20100805%'  AND FILE_NAME not like 'MVI%') OR (FILE_NAME LIKE  'MVI100805%'  AND FILE_NAME like 'MVI%') THEN sRecordNum END) sRecordNum1,
             count(CASE WHEN (FILE_NAME NOT LIKE '%20100805%' AND FILE_NAME not like 'MVI%') OR (FILE_NAME NOT LIKE  'MVI100805%' AND FILE_NAME like 'MVI%') THEN 1 END) sFileCount2,
             sum  (CASE WHEN (FILE_NAME NOT LIKE '%20100805%' AND FILE_NAME not like 'MVI%') OR (FILE_NAME NOT LIKE  'MVI100805%' AND FILE_NAME like 'MVI%') THEN sRecordNum END) sRecordNum2
      from (select distinct bsf.file_name,
                   bsf.record_num sRecordNum,
                   bsf.create_time
            from BUSINESS_SEND_FILELIST bsf, IDEP_PLUGIN_AUTO_RELATION ipar
            where bsf.file_id = ipar.bus_file_id 
                  and ipar.relation_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                  and ipar.relation_time < to_date('2010-08-05', 'yyyy-mm-dd')+1) a
      group by substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END)
      order by substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END)) so
LEFT JOIN 
        (select substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END) tFileName,
                count(*) tFileCount,
                sum(record_num) tRecordNum
         from (select distinct ipsf.file_name, 
                      ipsf.record_num
               from idep_plugin_send_filelist ipsf
               where ipsf.create_time >= to_date('2010-08-05', 'yyyy-mm-dd')
                     and ipsf.create_time < to_date('2010-08-05', 'yyyy-mm-dd')+1
                     and remark = '处理成功') a
         group by substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END)
         order by substr(a.file_name, 1, CASE WHEN a.file_name like 'MVI%' THEN 3 ELSE 6 END)) ta
         ON (so.sFileName = ta.tFileName)
