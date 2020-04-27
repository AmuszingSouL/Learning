# Oracle 常用set命令

为了留存历史执行sql  首先运行命令spool 将sql脚本输入到指定文本
注：默认路径为当前路径  退出命令行运行pwd查看目录

set echo off pagesize 0 heading off feedback off termout off
上述命令的解释:

首先指定文本输出地址文件
spool test.sql 

查询测试
select count(*) from user_tables;

将命令行结果导入指定文件  关闭文本
spool off



set timing on--------------------------------------------------设置显示“已用时间：XXXX”

set colsep '|';　　　　    //-域输出分隔符(可以具体设置分隔符号)

set time on-----------------------------------------------------设置显示当前时间

set echo on---------------------------------------------------设置运行命令是是否显示语句

set feedback on----------------------------------------------设置显示“已选择XX行”

set pagesize 10-----------------------------------------------设置每一页的行数

set feedback on----------------------------------------------设置显示“已选择XX行”

SET SERVEROUTPUT ON-------------------------------设置允许显示输出类似dbms_output

set linesize 80;       //输出一行字符个数，缺省为80

set numwidth 12;     //输出number类型域长度，缺省为1

set verify off        //可以关闭和打开提示确认信息old 1和new 1的显示.

SET AUTOTRACE OFF：不生成AUTOTRACE 报告，这是缺省模式
SET AUTOTRACE ON EXPLAIN：AUTOTRACE只显示优化器执行路径报告
SET AUTOTRACE ON STATISTICS：只显示执行统计信息
SET AUTOTRACE ON：包含执行计划和统计信息
SET AUTOTRACE TRACEONLY：同SET AUTOTRACE ON，但是不显示查询输出 

 SET TERMOUT OFF
显示脚本中的命令的执行结果，缺省为ON

11    SET NUMWIDTH 12
输出NUMBER类型域长度，缺省为10

column是sqlplus里最实用的一个命令，很多时候sql语句输出的列宽度不合适而影响查看，都需要用到这个命令来更改select语句中指定列的宽度和标题。大部分时候，我们可以简写column为col即可，主要有以下用法：
a)、修改列宽度
col c1 format a20 –将列c1(字符型)显示最大宽度调整为20个字符
col c1 format 9999999 –将列c1(number型)显示最大宽度调整为7个字符

b)、修改列标题
col c1 heading c2 –将c1的列名输出为c2

c)、设置列的对齐方式
SQL> col ename justify left/right/center;
SQL> select empno, ename, job from emp;
注意：对于number类型的数据默认为右对齐，其他默认为左对齐

d)、隐藏某列显示：col job noprint
SQL> col job noprint;
SQL> select empno, ename, job from emp;

e)、格式化number类型列的显示：column sal format $999,999.00
SQL> column sal format $999,999.00
SQL> select empno, ename, sal from emp;
e)、设置列值，若列植为空以text代替
SQL> col comm null text
SQL> select * from emp;

f)、显示列的当前属性
SQL> column ename;

g)、重置为默认值：
SQL> clear columns;

h)、一行只显示数字位的长度, 超过长度折行, 加word_wrapped后, 单词不会折行
column info format a40 word_wrapped

i)、cle[ar]: 清除掉所有的列格式

j)、设置列头
sql> column ename heading '姓名' format a15
