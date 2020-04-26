begin
select count(*) into v_cnt from t1 ;
if v_cnt>0 
then  …A逻辑….
else 
then  …B逻辑…..
End;

我来翻译一下这段需求：
      获取t1 表的记录数，判断是否大于0，如果大于0走A逻辑，否则就走B逻辑。
       因此代码就如上所示来实现了。真正的需求是这样吗？
      其实应该是这样的：只要T1表有记录就走A逻辑，否则走B逻辑。
两者有区别吗？其实区别还是很大的，前者可是强调获取记录数，我们是不是一定要遍历整个表得出一个记录数才知道是否大于0？

真正需求的理解可以让我们这样实现，只要从T1表中成功获取到第一条记录，就可以停止检索了，表示该表有记录了，难道事实不是这样？

因此原先的SQL1 从Select count(*) from t1; 被改造为：
Select count(*) from t1 where rownum=1; 

begin
select count(*) into v_cnt from t1 where rownum=1;
if v_cnt=1 
then  …A逻辑….
else 
then  …B逻辑…..
End;
