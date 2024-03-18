集函数可分:
1.COUNT(*);
2.相异集函数 AVG|MAX|MIN|SUMICOUNT(DISTINCT<列名>);
3.完全集函数 AVG|MAX|MIN|COUNT|SUM([ALL]<值表达式>);
4.方差集函数 VAR POP、VAR SAMP、VARIANCE、STDDEV POP、STDDEV SAMP、STDDEV;
5.协方差函数 COVAR POP、COVAR SAMP、CORR;
6.首行函数 FIRST VALUE;
7.区间范围内最大值集函数 AREA MAX;
8.FIRST/LAST 集函数 AVG|MAX|MIN| COUNT|SUM([ALL]<值表达式>)KEEP (DENSE RANKFIRSTILAST ORDER BY 子句);
9.字符串集函数 LISTAGG/LISTAGG2.
SQL>select min(nowprice) from production.product where discount < 7;
SQL>select avg(nowprice) from production.product where discount < 7;
SQL>select sum(nowprice) from production.product where discount >8;
SQL>select count(*)from purchasing.vendor;
SQL>select count(distinct publisher) from production.product;