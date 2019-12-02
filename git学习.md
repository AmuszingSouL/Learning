# Git简介  

创始人 linus两周时间用C语言开发的分布式版本控制软件

# 集中式VS分布式  

## 集中式

工作模式：

    1. 版本库是集中存放在中央服务器  
    2. 先从中央服务器取得最新的版本  
    3. 然后开始工作  
    4. 将最新的代码推送至服务器  
   
   弊端：
   1. 必须联网才能工作(受网速影响很大)   
   2. 集中式版本控制系统的中央服务器要是出了问题，所有人都没法干活了

## 分布式  

工作模式：
    1. 分布式版本控制系统根本没有“中央服务器”  
    2. 每个人的电脑上都是一个完整的版本库  
    3. 不需要联网  
    4. 多人协作，相互推送改动文件即可  

    优点：

    1. 分布式版本控制系统的安全性要高很多，即使中央服务器出了问题也可以从其他人那拷贝一份  
    2. 强大的分支管理系统  
    3. 也可以有一个中央服务器，方便大家相互交换数据，即使没有也不影响开发，只是相互交换不方便而已

## 其他版本控制软件 
### 免费的版本控制软件   
CVS作为最早的开源而且免费的集中式版本控制系统，由于CVS自身设计的问题，会造成提交文件不完整，版本库莫名其妙损坏的情况。同样是开源而且免费的SVN修正了CVS的一些稳定性问题，是目前用得最多的集中式版本库控制系统（之前学习java也是用的svn）。  

IBM的ClearCase（以前是Rational公司的，被IBM收购了），特点是安装比Windows还大，运行比蜗牛还慢，能用ClearCase的一般是世界500强，他们有个共同的特点是财大气粗，或者人傻钱多。  
微软自己也有一个集中式版本控制系统叫VSS，集成在Visual Studio中。由于其反人类的设计，连微软自己都不好意思用了。

分布式版本控制系统除了Git以及促使Git诞生的BitKeeper外，还有类似Git的Mercurial和Bazaar等。这些分布式版本控制系统各有特点，但最快、最简单也最流行的依然是Git！

# 安装git  

linux / Mac os/ Windows 安装都挺方便
安装完成之后：  

git config --global user.name "Your Name"  
git config --global user.email "email@example.com"  
Git是分布式版本控制系统，所以，每个机器都必须自报家门：你的名字和Email地址


# 创建版本库  
什么是版本库呢？版本库又名仓库，英文名repository，你可以简单理解成一个目录，这个目录里面的所有文件都可以被Git管理起来，每个文件的修改、删除，Git都能跟踪，以便任何时刻都可以追踪历史，或者在将来某个时刻可以“还原”。

新建或者找到指定的文件目录（Windows文件目录不要含中文)
git init  
Initialized empty Git repository in /Users/xxxx/Desktop/Learning/.git/
ls -ah命令就可以看见.git的目录  

# 把文件添加到版本库  
所有的版本控制系统，其实只能跟踪文本文件的改动，比如TXT文件，网页，所有的程序代码等等，Git也不例外。版本控制系统可以告诉你每次的改动，比如在第5行加了一个单词“Linux”，在第8行删了一个单词“Windows”。而图片、视频这些二进制文件，虽然也能由版本控制系统管理，但没法跟踪文件的变化，只能把二进制文件每次改动串起来，也就是只知道图片从100KB改成了120KB，但到底改了啥，版本控制系统不知道，也没法知道。    

不幸的是，Microsoft的Word格式是二进制格式，因此，版本控制系统是没法跟踪Word文件的改动的，前面我们举的例子只是为了演示，如果要真正使用版本控制系统，就要以纯文本方式编写文件。    

因为文本是有编码的，比如中文有常用的GBK编码，日文有Shift_JIS编码，如果没有历史遗留问题，强烈建议使用标准的UTF-8编码，所有语言使用同一种编码，既没有冲突，又被所有平台所支持。    

windows禁止使用记事本编辑文档（原因是Microsoft开发记事本的团队使用了一个非常弱智的行为来保存UTF-8编码的文件，他们自作聪明地在每个文件开头添加了0xefbbbf（十六进制）的字符，你会遇到很多不可思议的问题）    



### 第一步，用命令git add告诉Git，把文件添加到仓库：

$ git add readme.txt  
执行上面的命令，没有任何显示，这就对了，Unix的哲学是“没有消息就是好消息”，说明添加成功。  

### 第二步，用命令git commit告诉Git，把文件提交到仓库：

$ git commit -m "新增加一个readme文件"  
 [master (root-commit) abab012] 新增加一个readme文件  
 1 file changed, 2 insertions(+)  
 create mode 100644 Readme.txt  

git commit命令执行成功后会告诉你，1 file changed：1个文件被改动（我们新添加的readme.txt文件）；2 insertions：插入了两行内容（readme.txt有两行内容）。  

注：git commit 后的-m 必须写（虽然有方法可以不写）   简单明了知道文档的变动      


为什么Git添加文件需要add，commit一共两步呢？因为commit可以一次提交很多文件，所以你可以多次add不同的文件，比如：  

$ git add file1.txt
$ git add file2.txt file3.txt
$ git commit -m "add 3 files."


# 小结
现在总结一下今天学的两点内容：

初始化一个Git仓库，使用git init命令。

添加文件到Git仓库，分两步：

使用命令git add <file>，注意，可反复多次使用，添加多个文件；
使用命令git commit -m <message>，完成。

# 时光机穿梭  

修改Readme.txt内容
Git is a distributed version control system.
Git is free software.

## 运行git status  多运行git status 时刻了解git状态

$ git status  
On branch master  
Changes not staged for commit:  
  (use "git add <file>..." to update what will be committed)  
  (use "git checkout -- <file>..." to discard changes in working directory)  
  
	modified:   readme.txt  
  
no changes added to commit (use "git add" and/or "git commit -a")  

## git diff可以查看文档修改的内容

$ git diff readme.txt    
diff --git a/readme.txt b/readme.txt  
index 46d49bf..9247db6 100644  
--- a/readme.txt  
+++ b/readme.txt  
@@ -1,2 +1,2 @@  
-Git is a version control system.  
+Git is a distributed version control system.  
 Git is free software.  


之后git add Readme.txt 

然后查看git status 
$ git status  
On branch master  
Changes to be committed:  
  (use "git reset HEAD <file>..." to unstage)  
  
	modified:   readme.txt  

git status告诉我们，将要被提交的修改包括readme.txt，下一步，就可以放心地提交了：  

$ git commit -m "add distributed"  
[master e475afc] add distributed  
 1 file changed, 1 insertion(+), 1 deletion(-)  

提交后，我们再用git status命令看看仓库的当前状态：  
  
$ git status  
On branch master  
nothing to commit, working tree clean  

Git告诉我们当前没有需要提交的修改，而且，工作目录是干净（working tree clean）的。  

小结
要随时掌握工作区的状态，使用git status命令。

如果git status告诉你有文件被修改过，用git diff可以查看修改内容。

git add  
git commit -m "xxx"
git status 
随时了解情况


