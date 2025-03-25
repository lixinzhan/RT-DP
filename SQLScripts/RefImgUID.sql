SET NOCOUNT ON

select distinct
concat('ID', p.PatientId) as PatientId,
c.CourseId,
replace(ps.PlanSetupId,',','_') as PlanSetupId,
ps.PlanSetupSer,
ps.Status,
drrsr.SeriesUID as RISeriesInstanceUID,
drrsl.SliceUID as RISOPInstanceUID,
drr.ImageId,
drr.ImageType,
drrsl.HstryDateTime as DRRInstHstryDateTime,
null

from PlanSetup ps
inner join Course c on c.CourseSer = ps.CourseSer and c.CourseId like '[1-9]%'
inner join Patient p on p.PatientSer = c.PatientSer and p.PatientId not like '$%'

-- RefImage Series
inner join Radiation r on r.PlanSetupSer = ps.PlanSetupSer
inner join SliceRT srt on srt.RadiationSer = r.RadiationSer
inner join Slice drrsl on drrsl.SliceSer = srt.SliceSer
inner join Series drrsr on drrsr.SeriesSer = drrsl.SeriesSer
left join Image drr on drr.ImageSer = r.RefImageSer

where ps.Status in ('TreatApproval', 'PlanApproval')
and p.PatientId in ('20240503')
