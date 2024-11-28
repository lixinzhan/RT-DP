--
-- Search for all RPR entries in Registration for the last two months
--

SET NOCOUNT ON

IF OBJECT_ID (N'tempdb..#tmpRPRList') IS NOT NULL
DROP TABLE #tmpRPRList

select distinct
--pc.ProcedureCode,
p.PatientId,
p.LastName,
p.FirstName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
concat(p.HomePhone,'/',p.MobilePhone,'/',p.WorkPhone) as HMWPhone,
p.SSN,
dr.LastName as RadOnc,
c.CourseId,
--aipc.ActivityInstanceSer,
convert(date,aipc.CompletedDateTime) as RPRDate,
--ai.ObjectStatus,
ct.ActivityCode,
--ct.ProcedureCode,
ct.SimCMUDate,
(case when ct.ActivityCode is not null then 1 else 0 end) SimCMUFlag,
ps.PlanSetupId,
ps.Status as PlanStatus,
c.ClinicalStatus as CourseStatus,
(case when ps.Status='TreatApproval' then '1' else '' end) as TxApprvFlag,
(case when ps.Status='Reviewed' then '1' when ps.Status='PlanApproval' then '1' else '' end) as PlanReviewApprvFlag

into #tmpRPRList

from ActInstProcCode aipc
inner join ProcedureCode pc on pc.ProcedureCodeSer = aipc.ProcedureCodeSer

inner join ActivityInstance ai on ai.ActivityInstanceSer = aipc.ActivityInstanceSer and ai.ObjectStatus = 'Active'
inner join NonScheduledActivity nsa on nsa.ActivityInstanceSer = aipc.ActivityInstanceSer and nsa.ObjectStatus = 'Active'
inner join Patient p on p.PatientSer = nsa.PatientSer

left join PatientDoctor pd on pd.PatientSer = p.PatientSer and pd.PrimaryFlag = '1' and pd.OncologistFlag = '1'
left join Doctor dr on dr.ResourceSer = pd.ResourceSer


inner join ActivityCapture ac on ac.ActivityInstanceSer = aipc.ActivityInstanceSer
left join Course c on c.CourseSer = ac.CourseSer and c.ClinicalStatus != 'COMPLETED'

left join (
	select distinct
	em_ac.CourseSer,
	em_act.ActivityCode,
	em_aipc.CompletedDateTime as SimCMUDate,
	em_pc.ProcedureCode
	from ActivityCapture em_ac
	inner join ActivityInstance em_ai on em_ai.ActivityInstanceSer = em_ac.ActivityInstanceSer and em_ai.ObjectStatus = 'Active'
	inner join Activity em_act on em_act.ActivitySer = em_ai.ActivitySer --and em_act.ActivityCode like 'Sim%'
	inner join ActInstProcCode em_aipc on em_aipc.ActivityInstanceSer = em_ai.ActivityInstanceSer
	inner join ProcedureCode em_pc on em_pc.ProcedureCodeSer = em_aipc.ProcedureCodeSer and em_pc.ProcedureCode = '300x'	
) ct on ct.CourseSer = c.CourseSer

left join PlanSetup ps on ps.CourseSer = c.CourseSer and ps.Status != 'Rejected'

where 1=1
and aipc.CompletedDateTime >= DATEADD(day, -60, GETDATE())
and pc.ProcedureCode = 'RPR Approval Date'

IF OBJECT_ID (N'tempdb..#tmpPtRPRList') IS NOT NULL
DROP TABLE #tmpPtRPRList

select distinct
PatientId,
RPRDate,
max(SimCMUFlag) as SimCMUFlag
into #tmpPtRPRList
from #tmpRPRList
group by PatientId, RPRDate
order by PatientId, RPRDate

update #tmpRPRList
set SimCMUFlag = 1
from #tmpRPRList rpr 
inner join #tmpPtRPRList ptrpr on ptrpr.PatientId=rpr.PatientId and ptrpr.RPRDate=rpr.RPRDate
where ptrpr.SimCMUFlag = 1

select distinct
*
from #tmpRPRList
order by PatientId, CourseId, RPRDate


IF OBJECT_ID (N'tempdb..#tmpPtRPRList') IS NOT NULL
DROP TABLE #tmpPtRPRList

IF OBJECT_ID (N'tempdb..#tmpRPRList') IS NOT NULL
DROP TABLE #tmpRPRList
