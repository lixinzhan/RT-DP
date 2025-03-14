SET NOCOUNT ON
select
pa.PatientId,
--pt.patient_ser,
--pr.pt_id,
convert(date,pt.pt_dob) as DoB,
--pt.pt_last_name,
--pt.pt_middle_name,
--pt.pt_first_name,
pt.sex_cd,
ltrim(rtrim(qs.qstr_name)) as qstr_name,
pr.trans_log_tstamp,
--qs.title,
--qs.appr_flag,
--qs.active_entry_ind,
q.question_id,
concat('"',ltrim(rtrim(q.question_txt)),'"') as question_txt,
ltrim(rtrim(q.question_tag)) as question_tag,
concat('"',ltrim(rtrim(pr.resp)),'"') as resp,
concat('"',ltrim(rtrim(pr.resp_list_txt)),'"') as resp_list_txt,
ltrim(rtrim(q.score_values)) as score_values,
concat('"',ltrim(rtrim(q.string_attr_3)),'"') as string_attr_3

from qstr qs
inner join question q on q.qstr_name = qs.qstr_name
inner join pt_resp pr on pr.qstr_name = q.qstr_name and pr.question_id = q.question_id
inner join pt on pt.pt_id = pr.pt_id
inner join Patient pa on pa.PatientSer = pt.patient_ser

where qs.qstr_name like '%RPR%'
and qs.appr_flag = 'Y'
and qs.active_entry_ind = 'Y'
and pr.valid_entry_ind = 'Y'
and pa.PatientId = '20240503'
