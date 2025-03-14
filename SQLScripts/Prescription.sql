SET NOCOUNT ON

select 
p.PatientId,
c.CourseId, 

pres.NumberOfFractions as PresFractions,

(select ItemValue from PrescriptionAnatomyItem pai 
	where pai.ItemType like N'TOTAL DOSE' and pai.PrescriptionAnatomySer = pa.PrescriptionAnatomySer
) as PresTotalDose,

(SELECT ItemValue FROM PrescriptionAnatomyItem pai 
	WHERE pai.ItemType LIKE N'DOSE PER FRACTION' AND pai.PrescriptionAnatomySer = pa.PrescriptionAnatomySer
) as PresFracDose,

pres.PrescriptionName,
pres.Technique as PresTechnique,
pres.Status as PresStatus,
pres.CreationUserName,
pres.CreationDate,
--pa.AnatomyName,
--pa.AnatomyRole,
--pres.PrescriptionSer
null

from Patient p
inner join Course c on c.PatientSer=p.PatientSer
inner join TreatmentPhase tph on tph.CourseSer = c.CourseSer
inner join Prescription pres on pres.TreatmentPhaseSer = tph.TreatmentPhaseSer
inner join PrescriptionAnatomy pa on pres.PrescriptionSer = pa.PrescriptionSer and pa.AnatomyRole='2'

--order by p.PatientId, c.CourseId

where 1=1
--and convert(date,pres.CreationDate) > dateadd(week, -2, getdate())
and pres.Status NOT IN ( N'Retired' , N'ErrorOut')
and p.PatientId in ('20240503')
