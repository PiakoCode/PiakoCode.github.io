# MySQL指令

启动MySQL服务：`sudo /etc/init.d/mysql start` 或 `sudo service mysql start`

**数据库定义语言(DDL)**
1. DDL（Data Definition Language，数据定义语言）用来创建或者删除存储数据用的数据库以及数据库中的表等对象。 DDL 包含以下几种指令。
    1. CREATE： 创建数据库和表等对象
    2. DROP： 删除数据库和表等对象
    3. ALTER： 修改数据库和表等对象的结构

**数据库操纵语言(DML)**
2. DML（Data Manipulation Language，数据操纵语言）用来查询或者变更表中的记录。 DML 包含以下几种指令。

    1. CREATE： 创建数据库和表等对象
    2. DROP： 删除数据库和表等对象
    3. ALTER： 修改数据库和表等对象的结构

**数据库控制语言(DCL)**
3. DCL（Data Control Language，数据控制语言）用来确认或者取消对数据库中的数据进行的变更。除此之外，还可以对 RDBMS 的用户是否有权限操作数据库中的对象（数据库表等）进行设定。 DCL 包含以下几种指令。
    1. COMMIT： 确认对数据库中的数据进行的变更
    2. ROLLBACK： 取消对数据库中的数据进行的变更
    3. GRANT： 赋予用户操作权限
    4. REVOKE： 取消用户的操作权限

**数据库查询语言(DQL)**


SQL的基本书写规则：
SQL语句要以分号（;）结尾；
SQL语句不区分关键字大小写，插入表中的数据区分大小写；
常数的书写方式是固定的，字符串和日期常数需要使用单引号（'）括起来，数字常数无需加注单引号（直接书写数字即可）；
单词间需要用半角空格或者换行来分隔，不能使用全角空格作为单词的分隔符；


## 增
创建数据库

```mysql
CREATE DATABASE 数据库名;
```

创建表名

```mysql
CREATE TABLE 表名 ( 列名1 数据类型1, 列名2 数据类型2.... );
```

向表中插入数据

```mysql
INSERT INTO 表名 VALUES (数据1,数据2...);
```

指定列名插入数据

```mysql
INSERT INTO 表名 (列名1,列名2...) VALUES(数据1,数据2...);
```

一次性插入多行数据

```mysql
INSERT INTO 表名 (列名1,列名2...) VALUES (数据1,数据2...),(数据1,数据2...)...;
```

添加列

```mysql
ALTER TABLE 表名 ADD 列名 数据类型;
```



## 删

删除表

```mysql
DROP TABLE 表名;
```

删除表中数据

```mysql
DELETE FROM 表名
```

删除列

```mysql
ALTER TABLE 表名 DROP 列名;
```



## 改

修改列的位置

```mysql
# 把列添加到最前面
ALTER TABLE 表名 ADD 列名 数据类型 FIRST;
# 列添加到任意位置
ALTER TABLE 表名 ADD 列名 数据类型 AFTER 其他列;
```

修改列名和数据类型

```MySQL
ALTER TABLE 表名 CHANGE 修改前的列名 修改后的列名 修改后的数类型;
```


设置主键

```MYSQL
ALTER TABLE 表名 MODIFY 列名 数据类型 PRIMARY KEY;
```

设置唯一值

```mysql
ALTER TABLE 表名 MODIFY 列名 数据类型 UNIQUE;
```

设置默认值

```mysql
ALTER TABLE 表名 MODIFY 列名 数据类型 DEFAULT 值;
```



## 查

显示数据库信息

```mysql
SHOW DATABASE;
```

指定数据库

```mysql
use 数据库名;
```

显示当前使用的数据库

```MYSQL
SELECT DATABASE();
```

显示所有的表

```mysql
SHOW TABLES;
```

显示表的列结构

```mysql
DESC 表名;
```

显示各列数据

```mysql
SELECT 列名1,列名2...FROM 表名;
```


## 索引

大多数情况下,建立索引能缩短查找时间。

创建索引

```MYSQL
CREATE INDEX 索引名 ON 表名(列名);
```

显示索引

```MYSQL
SHOW INDEX FROM 表名;
```

删除索引

```MYSQL
DROP INDEX 索引名 FROM 表名;
```

## 复制

........



![](../Algorithm/Picture/Pasted%20image%2020230129213623.png)

MySQL 中没有布尔类型，`AND` 的运算结果是 `1`, `0`, 或者 `NULL`。
![](../Algorithm/Picture/Pasted%20image%2020230129215516.png)
![](../Algorithm/Picture/Pasted%20image%2020230129215457.png)
```SQL
1 > NULL > 0

1 AND NULL -> NULL    NULL AND 0 -> 0
1 OR  NULL -> 1       NULL OR 0  -> NULL
 NOT NULL -> NULL
```
`AND` 运算符的优先级高于 `OR` 运算符
```SQL
1 AND 0 OR 0 -> (1 AND 0) OR 0
```

可以使用括号更改运算顺序
```SQL
SELECT (1 OR 0) AND 0;
```
```text
+----------------+
| (1 OR 0) AND 0 |
+----------------+
|              0 |
+----------------+
1 row in set (0.00 sec)

```


`IN` 运算符用来检查一个字段或值是否包含在一个集合中，如果值包含在集合中返回 `1`，否则返回 `0`。
![](../Algorithm/Picture/Pasted%20image%2020230129221814.png)

`NOT IN` 和 [`IN` 用法](https://www.sjkjc.com/mysql/in/)几乎一样，只是在 `IN` 前面添加一个 `NOT` 关键字，`IN` 的否定操作符。

`BETWEEN` 运算符确定一个值是否介于某两个值之间。`BETWEEN` 运算符常用于比较数字和日期类型的数据。
```SQL
xxx BETWEEN min AND max
xxx NOT BETWEEN min AND max
```
[MySQL BETWEEN 用法与实例](https://www.sjkjc.com/mysql/between/)
[MySQL LIKE 用法与实例](https://www.sjkjc.com/mysql/like/)
[MySQL EXISTS 的用法与实例](https://www.sjkjc.com/mysql/exists/)
使用CASE可以进行排序




## Trick

建立utf8的databse

```mysql
CREATE DATABASE your_database_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

[linux安装mysql](../Web开发/linux安装mysql.md)