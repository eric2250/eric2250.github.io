WHERE 子句常用的査询条件由谓词和逻辑运算符组成。
谓词指明了一个条件，该条件求解后，结果为一个布尔值:真、假或未知。
逻辑算符有:AND，OR，NOT。
谓词包括比较谓词(=、>、<、> =、<=、<>)，BETWEEN 谓词、IN 谓词、LIKE谓词、NULL 谓词、EXISTS 谓词.

select * from production.product
select name, author, publisher, nowprice from production.product where nowprice>=10 and nowprice<=20;
select name, author, publisher, nowprice from production.product where nowprice between 10 and 20;
select name, author from production.product where publisher in('中华书局','人民文学出版社');
select name, sex, phone from person.person where email is null;
select name, author from production.product where nowprice < 15 and discount < 7 or publisher='人民文学出版社';