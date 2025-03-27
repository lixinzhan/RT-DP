SET NOCOUNT ON

select distinct
p.PatientId,
p.LastName,
p.FirstName,
convert(date,p.DateOfBirth) as DOB,
dr.LastName as RadOnc,
c.CourseId,
c.ClinicalStatus as CrsStatus,
COALESCE(convert(varchar(32),c.StartDateTime,120),'') as CrsStartDateTime,
COALESCE(convert(varchar(32),c.CompletedDateTime,120),'') as CrsCompletedDateTime,
COALESCE(replace(ps.PlanSetupId,',','_'),'') as PlanSetupId,
--ps.PlanSetupId,
COALESCE(ps.Status,'') as PlanStatus,
COALESCE(convert(varchar(32),ps.CreationDate,120),'') as PlanCreationDate,
COALESCE(convert(varchar(32),ps.HstryDateTime,120),'') as PlanLastUpdatedDateTime,
COALESCE(convert(varchar(32),rtp.CreationDate,120),'') as RTPCreationDate,
rtp.PrescribedDose*rtp.NoFractions as TotalDose,
rtp.NoFractions,
COALESCE(CAST(
	(select
	max(vrh.FractionNumber)
	from vv_RadiationHstry vrh
	where vrh.PlanSetupSer=ps.PlanSetupSer
	group by vrh.PlanSetupId
	) AS VARCHAR),'') as LastFracDelivered,
COALESCE(convert(varchar(32),
	(select
	max(vrh.TreatmentStartTime)
	from vv_RadiationHstry vrh
	where vrh.PlanSetupSer=ps.PlanSetupSer
	group by vrh.PlanSetupId
	),120),'') as LastDeliveryDateTime

from Patient p
left join Course c on c.PatientSer=p.PatientSer and c.CourseId like '[1-9]%'
left join PlanSetup ps on ps.CourseSer=c.CourseSer and ps.Status not in ('Retired','Rejected')
left join RTPlan rtp on rtp.PlanSetupSer = ps.PlanSetupSer
left join vv_RadiationHstry rh on rh.PlanSetupSer = ps.PlanSetupSer

left join PatientDoctor pd on pd.PatientSer=p.PatientSer and pd.PrimaryFlag='1' and pd.OncologistFlag='1'
left join Doctor dr on dr.ResourceSer=pd.ResourceSer

where 1=1
and p.PatientId in ('20240503')
order by PatientId, c.CourseId, PlanSetupId
