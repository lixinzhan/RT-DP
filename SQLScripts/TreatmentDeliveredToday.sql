--
-- Obtain the patient list that have treatment done on the backup day
--

SET NOCOUNT ON

select distinct
rh.PatientId,
p.LastName,
p.FirstName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
concat(p.HomePhone,'/',p.MobilePhone,'/',p.WorkPhone) as HMWPhone,
p.SSN,
dr.LastName as RadOnc,
--pd.PrimaryFlag,
--pd.OncologistFlag,
rh.CourseId,
rh.PlanSetupId,
rh.FractionNumber,
--txrec.NoOfFractions,
rtp.NoFractions as TotalFractions,
rtp.PrescribedDose as FractionDose,
(rtp.NoFractions*rtp.PrescribedDose) as TotalDose,
m.MachineId,
convert(date, rh.TreatmentStartTime) as TxDate,
(case when rh.FractionNumber = rtp.NoFractions then 'Y' else '' end) as LastFrac
from vv_RadiationHstry rh
inner join vv_RTPlan rtp on rtp.RTPlanSer = rh.RTPlanSer
inner join vv_TreatmentRecord txrec on txrec.TreatmentRecordSer = rh.TreatmentRecordSer
inner join Machine m on m.ResourceSer = txrec.ActualMachineSer
inner join Patient p on p.PatientSer = rh.PatientSer
left join PatientDoctor pd on pd.PatientSer = rh.PatientSer and pd.PrimaryFlag = '1' and pd.OncologistFlag = '1'
left join Doctor dr on dr.ResourceSer = pd.ResourceSer

where rh.TreatmentStartTime > convert(date,GETDATE())
and rh.PatientId not like '$%'

order by rh.PatientId, rh.CourseId, rh.PlanSetupId, rh.FractionNumber
