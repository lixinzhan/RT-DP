SET NOCOUNT ON

--use VARIAN
--go

declare @v15upgrdate as datetime
select  @v15upgrdate = '20200125'

select distinct
concat('ID',p.PatientId) as PatientId,
cast(pt.pt_id as VARCHAR) as pt_id,
pt.patient_ser,
--vn.trans_log_tstamp,
--vn.trans_log_mtstamp,
--datediff(day,@v15upgrdate,vn.trans_log_mtstamp) as daysfromv15upgr,
( case	when datediff(day,@v15upgrdate,vn.trans_log_tstamp) >= 0 and vn.revised_ind is null
	    then concat(year(vn.trans_log_tstamp),'Q',((month(vn.trans_log_tstamp)-1)/3+1),'\',vn.doc_file_loc) 
	when year(vn.trans_log_mtstamp) >= 2020 and vn.revised_ind='Y' 
	    then concat(year(vn.trans_log_mtstamp),'Q',((month(vn.trans_log_mtstamp)-1)/3+1),'\',vn.doc_file_loc)
	else vn.doc_file_loc
  end ) as doc_file,

( case	when vn.revised_ind='Y' and datediff(day,@v15upgrdate,vn.trans_log_mtstamp) >= 0 and vn.doc_preview_loc is not null
	    then concat(year(vn.trans_log_mtstamp),'Q',((month(vn.trans_log_mtstamp)-1)/3+1),'\',ltrim(rtrim(vn.doc_preview_loc)))
	when vn.revised_ind is null and year(vn.trans_log_tstamp) >=2020 and vn.doc_preview_loc is not null
	    then concat(year(vn.trans_log_tstamp),'Q',((month(vn.trans_log_tstamp)-1)/3+1),'\',ltrim(rtrim(vn.doc_preview_loc)))
	else vn.doc_preview_loc
  end ) as mht_file,

--month(vn.trans_log_tstamp) as trans_log_month,
--(month(vn.note_tstamp)-1)/3+1 as trans_log_quater,
ltrim(rtrim(nt.note_typ_desc)) as doc_typ_desc,
ltrim(rtrim(vn.template_name)) as template_name,
COALESCE(convert(varchar(32),vn.note_tstamp,120),'') as note_tstamp,
COALESCE(convert(varchar(32),vn.trans_log_tstamp,120),'') as trans_log_tstamp,
COALESCE(convert(varchar(32),vn.trans_log_mtstamp,120),'') as trans_log_mstamp,
COALESCE(convert(varchar(32),vn.appr_tstamp,120),'') as appr_tstamp,
COALESCE(vn.revised_ind,'') as revised_ind,
( case when vn.visit_note_begin_txt is not null 
            then concat('"',ltrim(rtrim(vn.visit_note_begin_txt)),'"') 
       else '' 
  end ) as doc_begin_text

from pt
inner join visit_note vn on vn.pt_id=pt.pt_id
inner join note_typ nt on nt.note_typ=vn.note_typ
inner join Patient p on p.PatientSer=pt.patient_ser

where 1=1
--and doc_file_loc in ('10338832.docx', '10338492.docx', '10338452.docx','10338565.docx','10310672.docx','10340355.docx')
and p.PatientId in ('20240503')
