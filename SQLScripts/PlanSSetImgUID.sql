SET NOCOUNT ON

select distinct
concat('ID',p.PatientId) as PatientId,
c.CourseId,
replace(ps.PlanSetupId,',','_') as PlanSetupId,
ps.PlanSetupSer,
plansr.SeriesUID as PlanSeriesInstanceUID,
--plansr.SeriesModality,

--pseries.SeriesId as PlanSeriesId,
rtp.PlanUID as PlanSOPInstanceUID,
--rtp.DicomSeqNumber,
rtp.NoFractions,
(rtp.PrescribedDose*rtp.NoFractions) as TotalDose,
ps.Status,

sset.StructureSetId,
ssetsr.SeriesUID as SSetSeriesInstanceUID,
--ssetsr.SeriesId as SSetSeriesId,
--ssetsr.SeriesModality,
sset.StructureSetUID as SSetSOPInstanceUID,

Image.ImageId,
imgsr.SeriesId as ImageSeriesId,
imgsr.SeriesUID as ImageSeriesInstanceUID,
--imgsr.SeriesModality

rtp.HstryDateTime as PlanInstHstryDateTime,
sset.HstryDateTime as SSetInstHstryDateTime,
imgsr.HstryDateTime as ImgSeriesHstryDateTime,

null

from PlanSetup ps
inner join Course c on c.CourseSer = ps.CourseSer and c.CourseId like '[1-9]%'
inner join Patient p on p.PatientSer = c.PatientSer and p.PatientId not like '$%'

-- Plan Series
inner join RTPlan rtp on rtp.PlanSetupSer = ps.PlanSetupSer
inner join Series plansr on plansr.SeriesSer = rtp.SeriesSer

-- StructureSet Series
inner join StructureSet sset on sset.StructureSetSer=ps.StructureSetSer
inner join Series ssetsr on ssetsr.SeriesSer = sset.SeriesSer

-- Planning CT Series
inner join Image on Image.ImageSer = sset.ImageSer
inner join Series imgsr on imgsr.SeriesSer = Image.SeriesSer

where ps.Status in ('TreatApproval', 'PlanApproval')
and p.PatientId in ('20240503')
