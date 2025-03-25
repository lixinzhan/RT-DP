SET NOCOUNT ON

select distinct
p.PatientId,
p.LastName,
p.FirstName,
convert(date,p.DateOfBirth) as DOB,
dr.LastName as RadOnc,
c.CourseId,
c.ClinicalStatus as CrsStatus,
c.StartDateTime as CrsStartDateTime,
c.CompletedDateTime as CrsCompletedDateTime,
replace(ps.PlanSetupId,',','_') as PlanSetupId,
--ps.PlanSetupId,
ps.Status as PlanStatus,
ps.CreationDate as PlanCreationDate,
ps.HstryDateTime as PlanLastUpdatedDateTime,
rtp.CreationDate as RTPCreationDate,
rtp.PrescribedDose*rtp.NoFractions as TotalDose,
rtp.NoFractions,
(select
	max(vrh.FractionNumber) 
	from vv_RadiationHstry vrh
	where vrh.PlanSetupSer=ps.PlanSetupSer
	group by vrh.PlanSetupId
	) as LastFracDelivered,
(select
	max(vrh.TreatmentStartTime)
	from vv_RadiationHstry vrh
	where vrh.PlanSetupSer=ps.PlanSetupSer
	group by vrh.PlanSetupId
	) as LastDeliveryDateTime,

null
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
