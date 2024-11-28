SET NOCOUNT ON

select distinct
concat('ID',p.PatientId) as PatientId,
--c.CourseId,
--ps.PlanSetupId,
--sset.StructureSetId,
--struct.FileName,
lower(reverse(PARSENAME(reverse(replace(struct.FileName,'\Structures','.')),1))) as img_loc
--null

from PlanSetup ps
inner join Course c on c.CourseSer = ps.CourseSer
inner join Patient p on p.PatientSer = c.PatientSer

inner join StructureSet sset on sset.StructureSetSer = ps.StructureSetSer
inner join Structure struct on struct.StructureSetSer = sset.StructureSetSer

where 1=1
--and ps.Status in ('PlanApproval', 'Unapproved', 'ExternalApproval', 'TreatApproval', 'Reviewed')
and ps.StatusDate > '20200101'
and p.PatientId in ('$20180117')
