# 001-mysql-无法insert into汉字

解决方案：暂时的解决方案是重新建立数据库  全部选择uft8

show variables like 'character%'; 查看字符集操作