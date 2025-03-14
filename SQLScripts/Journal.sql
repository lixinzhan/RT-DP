SET NOCOUNT ON

select distinct
--(qn.trans_log_tstamp) LogTime,
p.PatientId,
ltrim(rtrim(pt.pt_last_name)) as LastName,
ltrim(rtrim(pt.pt_first_name)) as FirstName,
convert(date, pt.pt_dob) DOB,
pt.sex_cd,
substring(convert(varchar,qn.note_tstamp,120),1,16) NoteTime,
qnt.quick_note_desc,
replace(replace(concat('"',ltrim(rtrim(qn.quick_note_text)),'"'), char(10),';'),char(13),'') as Note

from pt
inner join quick_note qn on qn.pt_id=pt.pt_id
inner join quick_note_typ qnt on qn.quick_note_typ=qnt.quick_note_typ
inner join Patient p on p.PatientSer = pt.patient_ser

where 1=1
--and qnt.quick_note_desc='QATF'
and qn.valid_entry_ind = 'Y'
--and qn.note_tstamp >= DATEADD(day,1,EOMONTH(DATEADD(month,-2,getdate())))
--and qn.note_tstamp <  DATEADD(day,1,EOMONTH(DATEADD(month,-1,getdate())))
--and qn.trans_log_tstamp >= DATEADD(day,1,EOMONTH(DATEADD(month,-2,getdate())))
--and qn.trans_log_tstamp <  DATEADD(day,1,EOMONTH(DATEADD(month,-1,getdate())))
--and p.PatientId='$20180117'
--order by p.PatientId, NoteTime;

and p.PatientId='20240503'
