----看官们，看完这个试验，你就明白了

最佳字段顺序（结论：越往后的列访问CPU开销大）

验证脚本1 （先构造出表和数据）
SET SERVEROUTPUT ON
SET ECHO ON
---构造出有25个字段的表T
DROP TABLE t;
DECLARE
  l_sql VARCHAR2(32767);
BEGIN
  l_sql := 'CREATE TABLE t (';
  FOR i IN 1..25 
  LOOP
    l_sql := l_sql || 'n' || i || ' NUMBER,';
  END LOOP;
  l_sql := l_sql || 'pad VARCHAR2(1000)) PCTFREE 10';
  EXECUTE IMMEDIATE l_sql;
END;
/
----将记录还有这个表T中填充
DECLARE
  l_sql VARCHAR2(32767);
BEGIN
  l_sql := 'INSERT INTO t SELECT ';
  FOR i IN 1..25
  LOOP
    l_sql := l_sql || '0,';
  END LOOP;
  l_sql := l_sql || 'NULL FROM dual CONNECT BY level <= 10000';
  EXECUTE IMMEDIATE l_sql;
  COMMIT;
END;
/


--验证脚本2（一次访问该表各字段验证） 
execute dbms_stats.gather_table_stats(ownname=>user, tabname=>'t')
SELECT num_rows, blocks FROM user_tables WHERE table_name = 'T';
--以下动作观察执行速度，比较发现COUNT(*)最快，COUNT(最大列）最慢
DECLARE
  l_dummy PLS_INTEGER;
  l_start PLS_INTEGER;
  l_stop PLS_INTEGER;
  l_sql VARCHAR2(100);
BEGIN
  l_start := dbms_utility.get_time;
  FOR j IN 1..1000
  LOOP
    EXECUTE IMMEDIATE 'SELECT count(*) FROM t' INTO l_dummy;
  END LOOP;
  l_stop := dbms_utility.get_time;
  dbms_output.put_line((l_stop-l_start)/100);

  FOR i IN 1..25
  LOOP
    l_sql := 'SELECT count(n' || i || ') FROM t';
    l_start := dbms_utility.get_time;
    FOR j IN 1..1000
    LOOP
      EXECUTE IMMEDIATE l_sql INTO l_dummy;
    END LOOP;
    l_stop := dbms_utility.get_time;
    dbms_output.put_line((l_stop-l_start)/100);
  END LOOP;
END;
/

--结论：
--原来优化器是这么搞的：列的偏移量决定性能，列越靠后，访问的开销越大。由于count(*)的算法与列偏移量无关，所以count(*)最快。
--后面还有看图说话，看看结果输出的趋势图，就更了然了。