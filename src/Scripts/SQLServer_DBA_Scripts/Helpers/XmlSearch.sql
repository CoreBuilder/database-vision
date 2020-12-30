-- =============================================
-- XML içinde string arama
-- =============================================

select s.ID from MessageSB s with(nolock) 
where s.messageType = 'ServerMessage'
and CAST(s.[message] AS XML).value('(/Voucher/@ID="AranacakDeger")[1]','VARCHAR(10)')='TRUE'