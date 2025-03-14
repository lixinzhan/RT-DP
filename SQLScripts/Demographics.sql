SET NOCOUNT ON

select distinct
p.PatientId,
p.LastName,
p.FirstName,
p.MiddleName,
convert(date, p.DateOfBirth) as DOB,
ltrim(rtrim(p.Sex)) as Sex,
p.SSN,
concat(p.HomePhone,'/',p.MobilePhone,'/',p.WorkPhone) as HMWPhone,
addr.EMailAddress,
addr.AddressType,
ltrim(rtrim(concat(
    COALESCE(addr.AddressLine1,''),' ',
    COALESCE(addr.AddressLine2,''),' ',
    COALESCE(addr.AddressLine3,'')
))) as AddressLine,
addr.CityOrTownship,
addr.StateOrProvince,
addr.Country,
addr.PostalCode,
p.Language,
p.PatientSer

from Patient p
inner join PatientAddress pa on pa.PatientSer = p.PatientSer
inner join Address addr on addr.AddressSer = pa.AddressSer --and addr.AddressType='Home'

where 1=1
and p.PatientId = '20240503'
