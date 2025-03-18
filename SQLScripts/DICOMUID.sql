--
-- Retrieve DICOM UID
--

SET NOCOUNT ON

select
p.PatientId,
c.CourseId,
ps.PlanSetupId,
--ps.PlanSetupSer,
pseries.SeriesUID as PlanSeriesInstanceUID,
--pseries.SeriesModality,

--pseries.SeriesId as PlanSeriesId,
rtp.PlanUID as PlanSOPInstanceUID,
--rtp.DicomSeqNumber,
rtp.NoFractions,
(rtp.PrescribedDose*rtp.NoFractions) as TotalDose,
sset.StructureSetId,
Series.SeriesUID as SSetSeriesInstanceUID,
--Series.SeriesId as SSetSeriesId,
--Series.SeriesModality,
sset.StructureSetUID as SSetSOPInstanceUID,
struct.StructureId,
struct.FileName,

Image.ImageId,
imgsr.SeriesId as ImageSeriesId,
imgsr.SeriesUID as ImageSeriesInstanceUID,
--imgsr.SeriesModality

r.RadiationSer,
r.RefImageSer,
drr.ImageId,
drr.ImageType,
drrsr.SeriesUID,
--drrsr.FrameOfReferenceUID,
drrsl.SliceUID

from PlanSetup ps
inner join Course c on c.CourseSer = ps.CourseSer and c.CourseId like '[1-9]%'
inner join Patient p on p.PatientSer = c.PatientSer and p.PatientId not like '$%'

-- Plan Series
inner join RTPlan rtp on rtp.PlanSetupSer = ps.PlanSetupSer
inner join Series pseries on pseries.SeriesSer = rtp.SeriesSer

-- StructureSet Series
inner join StructureSet sset on sset.StructureSetSer=ps.StructureSetSer
inner join Structure struct on struct.StructureSetSer=sset.StructureSetSer
inner join Series on Series.SeriesSer = sset.SeriesSer

-- Planning CT Series
inner join Image on Image.ImageSer = sset.ImageSer
inner join Series imgsr on imgsr.SeriesSer = Image.SeriesSer

-- DRR Series
inner join Radiation r on r.PlanSetupSer = ps.PlanSetupSer
left join SliceRT srt on srt.RadiationSer = r.RadiationSer
left join Slice drrsl on drrsl.SliceSer = srt.SliceSer
left join Series drrsr on drrsr.SeriesSer = drrsl.SeriesSer
left join Image drr on drr.ImageSer = r.RefImageSer
--left join Series drrsr on drrsr.SeriesSer = drr.SeriesSer

where p.PatientId = '20240503'
