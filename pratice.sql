-- 1、查询"01"课程比"02"课程成绩高的学生的信息及课程分数
select s.*,sc.score as "01", sc2.score as "02"
from student s
inner join sc on s.sid=sc.sid and sc.CId=01
inner join sc sc2 on s.sid=sc2.sid and sc2.CId=02
where sc.score>sc2.score;

select s.*,sc.*
from student s
inner join sc on s.sid=sc.sid and sc.CId=01

-- 2、查询"01"课程比"02"课程成绩低的学生的信息及课程分数
select s.*,sc.score as "01", sc2.score as "02"
from student s
inner join sc on s.sid=sc.sid and sc.cid=01
inner join sc sc2 on s.sid=sc2.sid and sc2.cid=02
where sc.score<sc2.score;

-- 3、查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩
select s.sid,s.sname,ROUND(AVG(sc.score),2) as "avg_score"
from student s
inner join sc on sc.sid=s.sid
group by s.sid
having AVG(sc.score)>=60;

-- 4、查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩 (包括有成绩的和无成绩的)
(select s.sid,s.sname,ROUND(AVG(sc.score),2) as "avg_score"
from student s
left join sc on sc.sid=s.sid
group by s.sid
having AVG(sc.score)<60)
union
(select s.sid,s.sname,0 as "avg_score"
from student s
where s.sid not in (select distinct sid from sc)); 

-- 5、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩
select s.sid,s.sname,COUNT(sc.cid),SUM(sc.score)
FROM student s
left join sc on s.sid=sc.sid
group by s.sid;

-- 6、查询"李"姓老师的数量
select COUNT(t.Tid)
from teacher t
where t.tname like '李%';

-- 7、查询学过"张三"老师课的同学的信息
select s.*
from student s
left join sc on s.SId=sc.sid
left join course c on c.cid=sc.cid
left join teacher t on t.tid=c.tid
where t.tname='张三';