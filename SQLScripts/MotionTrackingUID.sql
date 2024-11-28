SET NOCOUNT ON

declare @date_of_interest as datetime
set @date_of_interest = dateadd(DAY,-60,getdate())

select distinct
concat('ID', p.PatientId) as PatientId,
c.CourseId,
ps.PlanSetupId,
stu.StudyId,
stu.StudyUID,
ser.SeriesUID,
tr.TrackingUID,
tr.TrackingId,
(case when tr.TrackingType=1 then 'MW' else 'MP' end) TrackingType,
ser.SeriesModality,
eqp.StationName,
tr.CreationDate,
tr.FileName

from Tracking tr
inner join Series ser on ser.SeriesSer=tr.SeriesSer
inner join Study stu on stu.StudySer=ser.StudySer
inner join Patient p on p.PatientSer=stu.PatientSer

left join PlanSetup ps on ps.PlanSetupSer=tr.PlanSetupSer
left join Course c on c.CourseSer=ps.CourseSer

inner join Equipment eqp on eqp.EquipmentSer=tr.EquipmentSer

where tr.CreationDate > @date_of_interest
and p.PatientId in ('$20180117')
order by PatientId, c.CourseId, ps.PlanSetupId, tr.CreationDate
