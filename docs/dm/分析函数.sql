DM 分析函数为用户分析数据提供了一种更加简单高效的处理方式。如果不使用分析函数，则必须使用连接查询子查询或者视图，甚至复杂的存储过程实现。

引入分析函数后，只需要简单的 SQL语句，并且执行效率方面也有大幅提高。

分析函数可分:
1.COUNT(*);
2.完全分析函数 AVGIMAXIMIN|COUNT|SUM([ALL]<值表达式>),这5个分析函数的参数和作为集函数时的参数一致;
3.方差函数 VAR POP、VAR SAMP、VARIANCE、STDDEV POP、STDDEV SAMP、STDDEV;
4.协方差函数 COVAR POP、COVAR SAMP、CORR;
5.首尾函数 FIRST VALUE、LAST VALUE;
6.相邻函数 LAG 和 LEAD;
7.分组函数 NTILE;
8.排序函数 RANK、DENSE RANK、ROW NUMBER;
9.百分比函数 PERCENT RANK、CUME DIST、RATIO TO REPORT、PERCENTILE CONT、NTH VALUE;
10.字符串函数 LISTAGG;
11.指定行函数 NTH VALUE.

查询折扣大于7 的图书作者以及最大折扣。
SQL>select author, max(discount) over (partition by author) as max from production.product where discount>7;
求折扣小于 7 的图书作者和平均价格。
SQL>select author, avg(nowprice) over (partition by author) as avg from production.product where discount < 7;
求折扣大于 8 的图书作者和书的总价格。
SQL>select author, sum(nowprice) over (partition by author) as sum from production.product where discount >8;
查询信用级别为“很好”的已登记供应商的名称和个数。
SQL>select name, count(*) over (partition by credit) as cnt from purchasing.vendor where credit = 2;