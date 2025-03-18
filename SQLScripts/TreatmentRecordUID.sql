SET NOCOUNT ON

select distinct
concat('ID', p.PatientId) as PatientId,
c.CourseId,
replace(ps.PlanSetupId,',',';') as PlanSetupId,
rtp.NoFractions,
(rtp.PrescribedDose*rtp.NoFractions) as TotalDose,
--stu.StudyId,
stu.StudyUID,
--ser.SeriesId,
--ser.SeriesModality,
--ser.SeriesType,
ser.SeriesUID,
tr.TreatmentRecordUID,
tr.FileName,
tr.TreatmentRecordDateTime,
m.MachineId,

null

from TreatmentRecord tr
inner join Patient p on p.PatientSer=tr.PatientSer

inner join Series ser on ser.SeriesSer=tr.SeriesSer
inner join Study stu on stu.StudySer=ser.StudySer

inner join RTPlan rtp on rtp.RTPlanSer=tr.RTPlanSer
inner join PlanSetup ps on ps.PlanSetupSer=rtp.PlanSetupSer
inner join Course c on c.CourseSer=ps.CourseSer

inner join Machine m on m.ResourceSer=tr.ActualMachineSer

where 1=1
and p.PatientId in ('20240503')
order by PatientId, c.CourseId, ps.PlanSetupId, tr.TreatmentRecordDateTime
