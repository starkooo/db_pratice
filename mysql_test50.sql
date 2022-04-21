-- 1、查询"01"课程比"02"课程成绩高的学生的信息及课程分数
-- 查询学生信息及课程分数
select s.*, sc.score
from student s, sc;
-- 查询有01课程分数的学生信息
select *
from sc
where sc.cid=01;
-- 查询有02课程分数的学生信息
select *
from sc
where sc.cid=02;
-- 以上两种结果需要满足一定条件（1）SId要一致【同一人】（2）且01.score>02.score
select *
from (select * from sc where sc.cid=01) as a
(select * from sc where sc.cid=02) as b
using(sid)
where a.sid=b.sid and a.score>b.score;
-- 简化上表
select a.sid, a.score 01_score, b.score 02_score
from (select * from sc where sc.cid=01) as a
inner join (select * from sc where sc.cid=02) as b
using(sid)
where a.sid=b.sid and a.score>b.score;
-- 查询"01"课程比"02"课程成绩高的学生的信息及课程分数，要将上面得到的表和学生信息表联合
select s.*,r.01_score,r.02_score
from student s
right join
(select a.sid, a.score 01_score, b.score 02_score
from (select * from sc where sc.cid=01) as a
inner join (select * from sc where sc.cid=02) as b
using(sid)
where a.sid=b.sid and a.score>b.score) r
on s.sid = r.sid;
-- 参考答案
select st.*,sc.score as '语文' ,sc2.score '数学' 
from student st
left join sc on sc.sid=st.sid and sc.cid=01 
left join sc sc2 on sc2.sid=st.sid and sc2.cid=02  
where sc.score>sc2.score;



-- 2、查询"01"课程比"02"课程成绩低的学生的信息及课程分数
select s.*, r.01_score, r.02_score
from student s
right join
(select a.sid,a.score 01_score,b.score 02_score
from (select * from sc where cid=01) as a
inner join (select * from sc where cid=02) as b
using(sid)
where a.sid=b.sid and a.score<b.score) r
on s.sid=r.sid;
-- 参考答案
select st.*,sc.score as '语文' ,sc2.score '数学' 
from student st
left join sc on sc.sid=st.sid and sc.cid=01 
left join sc sc2 on sc2.sid=st.sid and sc2.cid=02  
where sc.score<sc2.score;



-- 3、查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩
-- 求出平均成绩大于60分的学生的id和平均成绩
select sid,avg(score)
from sc 
group by sid
having avg(score)>=60;
-- 查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩
select s.sid,s.sname,	r.score
from student s
right join
(select sid,avg(score) as score
from sc 
group by sid
having avg(score)>=60) r
on r.sid=s.sid;
-- 参考答案
select b.sid,b.sname,ROUND(AVG(a.score),2) as avg_score from 
student b 
join sc a on b.sid = a.sid
GROUP BY b.sid,b.sname HAVING avg_score >=60;



-- 4、查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩 (包括有成绩的和无成绩的)
-- 求出平均成绩小于60分的学生的id和平均成绩
select sid,avg(score) as avg_socre
from sc 
group by sid
having avg(score)<60;
-- 求出有成绩的学生id
select distinct sid
from sc;
-- 求出无成绩的学生id
select s.sid,0 as 'avg_score'
from student s
where s.sid not in(select distinct sc.sid from sc);
-- 将有成绩的且小于60分的学生id及平均成绩表（表a）和无成绩的学生id及平均成绩表（表b）联合，并起别名为表r，用于最后一步
(select sid,avg(score) as avg_score
from sc 
group by sid
having avg(score)<60)
union
(select s.sid,0 as 'avg_score'
from student s
where s.sid not in(select distinct sc.sid from sc));
-- 查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩 (包括有成绩的和无成绩的)
select st.sid,st.sname,round(avg_score,2) as '平均成绩'
from student st
right join
((select sid,avg(score) as avg_score
from sc 
group by sid
having avg(score)<60)
union
(select s.sid,0 as 'avg_score'
from student s
where s.sid not in(select distinct sc.sid from sc))) r
on r.sid=st.sid;
-- 参考答案
select b.sid,b.sname,ROUND(AVG(a.score),2) as avg_score from 
	student b 
	left join sc a on b.sid = a.sid
	GROUP BY b.sid,b.sname HAVING avg_score <60
	union
select a.sid,a.sname,0 as avg_score from 
	student a 
	where a.sid not in (
				select distinct sid from sc);
				


-- 5、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩
-- 求出选课总数
select sid,count(cid) as courses_num, sum(score) as sum_scores
from sc
group by sid;
-- 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩
select s.sid,s.sname, r.courses_num, r.sum_scores
from student s
left join
(select sid,count(cid) as courses_num, sum(score) as sum_scores
from sc
group by sid) r
on r.sid=s.sid;
-- 参考答案
SELECT 
s.Sid,s.Sname,COUNT(sc.Cid) AS sum_course,sum(sc.score) AS sum_score  
FROM student as s LEFT JOIN sc 
ON s.Sid = sc.Sid 
GROUP BY s.sid,s.Sname;



-- 6、查询"李"姓老师的数量
select count(t.tid)
from teacher t
where t.tname like '李%';
-- 参考答案
SELECT COUNT(tid) AS '李师'  FROM teacher WHERE Tname LIKE '李%';



-- 7、查询学过"张三"老师课的同学的信息
-- 查出张三的课程编号
select tid from teacher where tname='张三'; -- tid=01 
-- 查出张三老师教的课程cid
select cid from course 
where tid=(select tid from teacher where tname='张三'); -- cid=02
-- 查出学过张三老师（tid=01）的同学
select sid from sc where cid = (select cid from course where tid=(select tid from teacher where tname='张三'));
-- 查询学过"张三"老师课的同学的信息
select s.*
from student s
right join
(select sid from sc where cid = (select cid from course where tid=(select tid from teacher where tname='张三'))) r
on r.sid=s.sid;
-- 优化
select s.*
from student s
right join sc
on sc.sid=s.sid
where sc.cid in 
(select cid from course where tid=(select tid from teacher where tname='张三'));
-- 参考答案1
SELECT student.*,sc.Cid,sc.score 
FROM student JOIN sc 
on student.Sid = sc.Sid 
WHERE sc.Cid in 
(SELECT Cid FROM course WHERE Tid=
(SELECT Tid FROM  teacher WHERE Tname='张三'));
-- 参考答案2
select st.* from student st 
left join sc on sc.sid=st.sid
left join course c on c.cid=sc.cid
left join teacher t on t.tid=c.tid
where t.tname="张三"



-- 8、查询没学过"张三"老师授课的同学的信息
select * 
from student
where sid not in
(select s.sid
from student s
right join sc
on sc.sid=s.sid
where sc.cid in 
(select cid from course where tid=(select tid from teacher where tname='张三')));
-- 参考答案
 -- 张三老师教的课
 select c.* from course c left join teacher t on t.t_id=c.t_id where  t.t_name="张三"
 -- 有张三老师课成绩的st.s_id
 select sc.s_id from score sc where sc.c_id in (select c.c_id from course c left join teacher t on t.t_id=c.t_id where  t.t_name="张三")
 -- 不在上面查到的st.s_id的学生信息,即没学过张三老师授课的同学信息
 select st.* from student st where st.sid not in(
  select sc.sid from sc where sc.cid in (select c.cid from course c left join teacher t on t.tid=c.tid where  t.tname="张三"));
	
	

-- 9、查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息
select s.*
from student s,sc a,sc b
where s.sid=a.sid and s.sid=b.sid and a.cid=01 and b.cid=02;



-- 10、查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
-- 学过01课程的同学sid
select sid from sc where cid=01;
-- 学过02课程的同学sid
select sid from sc where cid=02;
-- 查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
select s.*
from student s
where s.sid in (select sid from sc where cid=01)
and s.sid not in (select sid from sc where cid=02);



-- 11、查询没有学全所有课程的同学的信息
-- 求学全了全部课程的同学（即同学学的课程等于课程的总数）
select sc.sid
from sc
group by sc.sid
having count(sc.cid) = (select count(cid) from course);
-- 再反向选择
select s.*
from student s
where s.sid not in
(select sc.sid
from sc
group by sc.sid
having count(sc.cid) = (select count(cid) from course));




-- 12、查询至少有一门课与学号为"01"的同学所学相同的同学的信息
-- 查询01同学学习的课程
select distinct cid from sc where sid=01;
-- 查询至少有一门课与01同学学习课程相同的同学sid
select distinct sid from sc where cid in (select cid from sc a where sid=01);
-- 查询至少有一门课与学号为"01"的同学所学相同的同学的信息
select s.*
from student s
where s.sid in
(select distinct sid from sc where cid in (select distinct cid from sc a where sid=01));



-- 13、查询和"01"号的同学学习的课程完全相同的其他同学的信息
-- 查询01同学学习的课程
select distinct cid from sc where sid=01;
-- 查询01同学学习的课程数量
select count(*) cid from sc where sid=01;
-- 选出和01号学生课程完全相同的学生sid。
-- 所以用所有学生的选课和01号学生的课程逐个作比较。
-- 因为左连接可以更好地保留那些不符合条件的学生，以备进一步筛选。
select sc.* from sc left join (select distinct cid from sc where sid=01) r on sc.cid=r.cid;

-- 参考答案
SELECT * FROM student WHERE sid IN(
	SELECT g1.sid FROM sc g1 
	LEFT JOIN (SELECT DISTINCT cid FROM sc WHERE sid=01) g2 ON g1.cid=g2.cid
	WHERE g1.sid<>01
	GROUP BY g1.sid
	HAVING COUNT(g1.cid)=(SELECT DISTINCT COUNT(cid) FROM sc WHERE sid=01) AND COUNT(g2.cid)=COUNT(g1.cid) -- 自身课程数=01课程数，且，自身课程=01课程
);



-- 14、查询没学过"张三"老师讲授的任一门课程的学生姓名
-- 查询张三老师的老师代号
select tid from teacher where tname='张三';
-- 查询张三老师教的课程号
select c.cid from course c 
left join teacher t
on c.tid=t.tid
where t.tname='张三'; -- cid=02
-- 查询学过cid=02课程的学生id
select distinct sc.sid from sc
where sc.cid in
(select c.cid from course c 
left join teacher t
on c.tid=t.tid
where t.tname='张三');
-- 查询没学过"张三"老师讲授的任一门课程（cid=02）的学生姓名
select s.sname from student s
where s.sid not in
(select distinct sc.sid from sc
where sc.cid in
(select c.cid from course c 
left join teacher t
on c.tid=t.tid
where t.tname='张三'));
-- 参考答案
select sid,sname from Student
where sid not in 
(select sid from SC
where cid=(select cid 
from Course 
where tid=(select tid 
from Teacher 
where  tname='张三')));



-- 15、查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
-- 查询选了两门课以上且两门课以上不及格的同学的sid
select sid 
from sc 
where score<60 or score=NULL 
group by sid 
HAVING count(cid)>=2;
-- 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
select s.sid,s.sname,avg(sc.score)
from student s
join sc
on sc.sid=s.sid
where s.sid in
(select sid 
from sc 
where score<60 or score=NULL 
group by sid 
HAVING count(cid)>=2)
group by s.sid;




-- 16、检索"01"课程分数小于60，按分数降序排列的学生信息
select s.*,sc.score from student s
join sc
on s.sid=sc.sid
where sc.cid=01 and sc.score<60
order by sc.score desc;



-- 17、按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select s.sid,s.sname,sc1.score as '语文',sc2.score as '数学',sc3.score as '英语',avg(sc.score) as '平均分'
from student s
left join sc on sc.sid=s.sid
left join sc sc1 on sc1.sid=s.sid and sc1.cid=01 
left join sc sc2 on sc2.sid=s.sid and sc2.cid=02 
left join sc sc3 on sc3.sid=s.sid and sc3.cid=03 
group by sc.sid
order by avg(sc.score) desc;
-- 参考答案
SELECT
 st.*,
 GROUP_CONCAT(c.cname) 课程,
 GROUP_CONCAT(sc.score) 分数,
 AVG(sc.score) 平均分 
 FROM student st 
LEFT JOIN sc 
on st.sid=sc.sid JOIN course c 
ON sc.cid=c.cid 
GROUP BY sc.sid ORDER BY AVG(sc.score) DESC;



-- 18.查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
-- 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
-- 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

-- 各科及格人数，其他率以此类推
select c.cid,count(1) 
from sc,course c 
where score>=60 and sc.cid=c.cid
group by c.cid;
-- 最终结果
select c.cid,c.cname,max(sc1.score) as '最高分',min(sc2.score) as '最低分',avg(sc3.score) as '平均分',
((select count(1) from sc where score>=60 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '及格率',
((select count(1) from sc where score>=70 and score<80 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '中等率',
((select count(1) from sc where score>=80 and score<90 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '优良率',
((select count(1) from sc where score>=90 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '优秀率'
from course c
left join sc sc1 on sc1.cid=c.cid
left join sc sc2 on sc2.cid=c.cid
left join sc sc3 on sc3.cid=c.cid
group by c.cid
order by c.cid asc;




-- 19、按各科成绩进行排序，并显示排名




-- 20、查询学生的总成绩并进行排名
select s.sid,s.sname,(case when sum(sc.score) is null then 0 else sum(sc.score) end) as sum_score
from student s
left join sc
on sc.sid=s.sid
group by s.sid
order by sum(sc.score) desc;
-- 排名，要通过设置变量(不考虑并列情况)
set @crank=0;
select r.sid,r.sname,r.sum_score as '总成绩',@crank:=@crank+1 as '排名'
from 
(select s.sid,s.sname,(case when sum(sc.score) is null then 0 else sum(sc.score) end) as sum_score
from student s
left join sc
on sc.sid=s.sid
group by s.sid
order by sum(sc.score) desc) r;



-- 21、查询不同老师所教不同课程平均分从高到低显示
select t.tid,t.tname,c.cname,(case when avg(sc.score) is null then 0 else avg(sc.score) end)  as '课程平均分'
from teacher t
left join course c
on t.tid=c.tid
left join sc
on sc.cid=c.cid
group by tid
order by avg(sc.score) desc;




-- 22、查询所有课程的成绩第2名到第3名的学生信息及该课程成绩
-- (不考虑并列)
(select s.*,sc.score
from student s
left join sc
on s.sid=sc.sid
where sc.cid=01
order by sc.score desc limit 1,2)
union all
(select s.*,sc.score
from student s
left join sc
on s.sid=sc.sid
where sc.cid=02
order by sc.score desc limit 1,2)
union all
(select s.*,sc.score
from student s
left join sc
on s.sid=sc.sid
where sc.cid=03
order by sc.score desc limit 1,2);



-- 23、统计各科成绩各分数段人数：课程编号,课程名称,[100-85],[85-70],[70-60],[0-60]及所占百分比
select c.cid,c.cname, 
((select count(1) from sc where sc.score>=85 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '[100-85]',
((select count(1) from sc where sc.score<=85 and sc.score>70 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '[85-70]',
((select count(1) from sc where sc.score<=70 and sc.score>60 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '[70-60]',
((select count(1) from sc where sc.score<=60 and sc.cid=c.cid)/(select count(1) from sc where sc.cid=c.cid)) as '[0-60]'
from course c
group by cid;



-- 24、查询学生平均成绩及其名次
set @rank=0;
select r.sid,r.sname,round(r.avg_score,2),@rank:=@rank+1 as rank
from
(select s.sid,s.sname,(case when avg(sc.score) is null then 0 else avg(sc.score) end) as avg_score
from student s
left join sc
on sc.sid=s.sid
group by sc.sid
order by avg(sc.score) desc) r;




-- 25、查询各科成绩前三名的记录
-- 不考虑并列
-- 求01学科前三名
(select s.sid,s.sname,c.cid,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
inner join course c on sc.cid=c.cid and c.cid=01
group by sid
order by sc.score desc limit 0,3)
union all
(select s.sid,s.sname,c.cid,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
inner join course c on sc.cid=c.cid and c.cid=02
group by sid
order by sc.score desc limit 0,3)
union all
(select s.sid,s.sname,c.cid,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
inner join course c on sc.cid=c.cid and c.cid=03
group by sid
order by sc.score desc limit 0,3)




-- 26、查询每门课程被选修的学生数 
select sc.cid,c.cname,count(1)
from sc
left join course c
on c.cid=sc.cid
group by sc.cid;




-- 27、查询出只有两门课程的全部学生的学号和姓名
select s.sid,s.sname
from student s
left join sc
on sc.sid=s.sid
group by sc.sid
having count(1)=2;



-- 28、查询男生、女生人数
select s.ssex,count(s.ssex)
from student s
group by s.ssex;




-- 29、查询名字中含有"风"字的学生信息
select s.*
from student s
where s.sname like '%风%';



-- 30、查询同名同性学生名单，并统计同名人数
select s.*,count(1)
from student s
group by s.sname,s.ssex
having count(1)>1;



-- 31、查询1990年出生的学生名单
select s.*
from student s
where s.sage like '1990%';



-- 32、查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select c.cid,c.cname,avg(sc.score)
from course c
inner join sc
on sc.cid=c.cid
group by c.cid
order by avg(sc.score) desc,sc.cid asc;



-- 33、查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩
select s.sid,s.sname,avg(sc.score)
from student s
left join sc
on sc.sid=s.sid
group by s.sid
having avg(sc.score)>=85;



-- 34、查询课程名称为"数学"，且分数低于60的学生姓名和分数 
select s.sid,s.sname,c.cname,sc.score
from student s
inner join sc
on sc.sid=s.sid and sc.score<60
inner join course c
on c.cid=sc.cid and c.cname='数学';




-- 35、查询所有学生的课程及分数情况；
select s.sid,s.sname,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
left join course c on c.cid=sc.cid
order by s.sid,c.cname;




-- 36、查询任何一门课程成绩在70分以上的同学姓名、课程名称和分数
select s.sname,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
left join course c on c.cid=sc.cid
where s.sid in
(select s.sid from student s
left join sc on sc.sid=s.sid
group by s.sid having min(score)>=70)
order by s.sid;



-- 37、查询不及格的课程
select s.sid,s.sname,c.cname,sc.score
from student s
inner join sc on sc.sid=s.sid
inner join course c on c.cid=sc.cid and sc.score<60;



-- 38、查询课程编号为01且课程成绩在80分以上的学生的学号和姓名
select s.sid,s.sname
from student s
inner join sc on sc.sid=s.sid and sc.cid=01 and sc.score>=80;



-- 39、求每门课程的学生人数
select c.cid,c.cname,count(1)
from course c
inner join sc on c.cid=sc.cid
group by cid;




-- 40、查询选修"张三"老师所授课程的学生中，成绩最高的学生信息及其成绩
select s.*,sc.score,c.cname,t.tname
from student s
inner join sc on sc.sid=s.sid
inner join course c on sc.cid=c.cid
inner join teacher t on t.tid=c.tid and t.tname='张三'
order by sc.score desc limit 0,1;



-- 41、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select s.sid,s.sname,sc.cid,c.cname,sc.score
from student s
left join sc on sc.sid=s.sid
left join course c on c.cid=sc.cid
where
(select count(1)
from student s2
left join sc sc2 on sc2.sid=s2.sid
left join course c2 on c2.cid=sc2.cid
where sc.score=sc2.score and c.cid!=c2.cid
)>1;




-- 42、查询每门功成绩最好的前两名




-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，
--     若人数相同，按课程号升序排列
select sc.cid,c.cname,count(1) as '选修人数'
from sc
left join course c
on c.cid=sc.cid
group by sc.cid
having count(1)>5
order by count(1) desc,sc.cid asc;



-- 44、检索至少选修两门课程的学生学号
select s.sid,s.sname
from student s
left join sc
on sc.sid=s.sid
group by s.sid
having count(1)>=2
order by s.sid;




-- 45、查询选修了全部课程的学生信息
select s.*
from student s
left join sc
on sc.sid=s.sid
group by s.sid
having count(1)=(select count(1) from course);



-- 46、查询各学生的年龄
select s.sid,s.sname,TIMESTAMPDIFF(year,s.sage,CURRENT_TIMESTAMP) as '年龄'
from student s;