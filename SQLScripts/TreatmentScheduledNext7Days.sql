--
-- List treatment schedules for the next 7 days
--

SET NOCOUNT ON

select distinct
--sa.ScheduledActivitySer,
--sa.ActivityInstanceSer,
--sa.PatientSer,
p.PatientId,
p.LastName,
p.FirstName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
concat(p.HomePhone,'/',p.MobilePhone,'/',p.WorkPhone) as HMWPhone,
p.SSN,
dr.LastName as RadOnc,
substring(convert(varchar, sa.ScheduledStartTime,120),1,10) as ScheduledDate,
substring(convert(varchar, sa.ScheduledStartTime,120),12,5) as ScheduledTime,
sa.ScheduledActivityCode,
sa.ObjectStatus,
sa.WorkFlowActiveFlag,
act.ActivityCode,
(case when sa.ActivityNote is null then '' else sa.ActivityNote end) ActivityNote

from ScheduledActivity sa
inner join Patient p on p.PatientSer = sa.PatientSer
inner join ActivityInstance ai on ai.ActivityInstanceSer = sa.ActivityInstanceSer
inner join Activity act on act.ActivitySer = ai.ActivitySer
left join PatientDoctor pd on pd.PatientSer = p.PatientSer and pd.PrimaryFlag = '1' and pd.OncologistFlag = '1'
left join Doctor dr on dr.ResourceSer = pd.ResourceSer

where 1=1
and convert(date, sa.ScheduledStartTime) >= getdate() --dateadd(WEEKDAY,-1,getdate())
and convert(date, sa.ScheduledStartTime) <= dateadd(DAY,+7,getdate())
and p.PatientId not like '$%'
--and sa.ScheduledActivityCode in ('In Progress', 'Open')
--and sa.WorkFlowActiveFlag = '1'
and act.ActivityCode like '%Treat%'
and sa.ObjectStatus = 'Active'

order by ScheduledDate, PatientId, ScheduledTime
