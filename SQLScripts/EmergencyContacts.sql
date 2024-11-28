SET NOCOUNT ON

select distinct
p.PatientId,
p.LastName,
p.FirstName,
p.MiddleName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
p.PatientSer,
poc.Relationship,
poc.PrimaryFlag as PoC_PrimaryFlag,
poc.EntrustedContactFlag as PoC_EntrustedContactFlag,
poc.LastName as PoC_LastName,
poc.FirstName as PoC_FirstName,
poc.MiddleName as PoC_MiddleName,
ltrim(rtrim(poc.Sex)) as PoC_Sex,
concat(poc.HomePhone,'/',poc.MobilePhone,'/',poc.WorkPhone) as PoC_HMWPhone,
addr.EMailAddress as PoC_EMail,
addr.AddressType as PoC_AddressType,
ltrim(rtrim(concat(addr.AddressLine1,' ',addr.AddressLine2,' ',addr.AddressLine3))) as PoC_AddressLine,
addr.CityOrTownship as PoC_City,
addr.StateOrProvince as PoC_Province,
addr.Country as PoC_Country,
addr.PostalCode as PoC_PostalCode

from Patient p
inner join PointOfContact poc on poc.PatientSer = p.PatientSer
left  join Address addr on addr.AddressSer = poc.AddressSer --and addr.AddressType='Home'

where 1=1
and p.PatientId = '$20180117'
