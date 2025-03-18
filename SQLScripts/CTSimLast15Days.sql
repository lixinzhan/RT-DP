--
-- List patients having CT Sim done in the last 15 days
--
--    * based on NHPIP code 370
--    * if there are plans/courses for the pt, list them too
--

SET NOCOUNT ON

declare @date_of_interest as datetime
set @date_of_interest = dateadd(DAY,-15,getdate())

select distinct
p.PatientId,
p.LastName,
p.FirstName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
concat(p.HomePhone,'/',p.MobilePhone,'/',p.WorkPhone) as HMWPhone,
p.SSN,
dr.LastName as RadOnc,
act.ActivityCode,
pc.ProcedureCode,
-- substring(convert(varchar, aipc.CompletedDateTime,120),1,10) as SimDate,
convert(date, aipc.CompletedDateTime) as SimDate,

COALESCE(plancrs.CourseId, '') as CourseId,
COALESCE(plancrs.CourseStatus, '') as CourseStatus,
COALESCE(plancrs.CourseCompletedDate, '') as CourseCompletedDate,
replace(COALESCE(plancrs.PlanSetupId, ''),',',';') as PlanSetupId,
COALESCE(plancrs.PlanStatus, '') as PlanStatus,
COALESCE(plancrs.PlanStatusDate, '') as PlanStatusDate

--(case when plancrs.CourseId is null then '' else plancrs.CourseId end) as CourseId,
--(case when plancrs.CourseStatus is null then '' else plancrs.CourseStatus end) as CourseStatus,
--(case when plancrs.CourseCompletedDate is null then '' else convert(varchar,plancrs.CourseCompletedDate,120) end) as CourseCompletedDate,
--(case when plancrs.PlanSetupId is null then '' else plancrs.PlanSetupId end) as PlanSetupId,
--(case when plancrs.PlanStatus is null then '' else plancrs.PlanStatus end) PlanStatus,
--(case when plancrs.PlanStatusDate is null then '' else convert(varchar,plancrs.PlanStatusDate,120) end) PlanStatusDate

from ActInstProcCode aipc
inner join ProcedureCode pc on pc.ProcedureCodeSer = aipc.ProcedureCodeSer and pc.ProcedureCode='370'
inner join ActivityInstance ai on ai.ActivityInstanceSer = aipc.ActivityInstanceSer
inner join Activity act on act.ActivitySer = ai.ActivitySer

inner join ScheduledActivity sa on sa.ActivityInstanceSer = aipc.ActivityInstanceSer
inner join Patient p on p.PatientSer = sa.PatientSer and p.PatientId not like '$%' -- and p.LastName not like '$%'
left join PatientDoctor pd on pd.PatientSer = p.PatientSer and pd.PrimaryFlag = '1' and pd.OncologistFlag = '1'
left join Doctor dr on dr.ResourceSer = pd.ResourceSer

-- find out all Courses/Plans for patients has sim done in the last two weeks
left join (
	select n_c.PatientSer, n_c.CourseId, n_c.ClinicalStatus as CourseStatus, 
			n_c.CompletedDateTime as CourseCompletedDate, 
			n_ps.PlanSetupId, n_ps.CreationDate as PlanCreationDate, 
			n_ps.Status as PlanStatus, n_ps.StatusDate as PlanStatusDate
	from Course n_c
	inner join PlanSetup n_ps on n_ps.CourseSer = n_c.CourseSer and n_ps.Status not in ('Rejected')
	where n_c.CourseId like '[1-9]%'
	) plancrs on plancrs.PatientSer = p.PatientSer and (plancrs.CourseCompletedDate > @date_of_interest or plancrs.CourseCompletedDate is NULL)


where aipc.CompletedDateTime > @date_of_interest
	
order by SimDate DESC, PatientId
