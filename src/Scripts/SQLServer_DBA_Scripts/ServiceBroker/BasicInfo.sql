-- ==============================================================
-- Service Broker helper sorguları
-- ==============================================================

-- Transmission_queue daki message'ları xml olarak gösterir
select convert(nvarchar(max),q.message_body) as xml, q.*  from sys.transmission_queue q with (nolock)

-- Sırada bekleyen mesajları gidecekleri yere göre gruplayarak gösterir
select distinct q.message_type_name, q.to_service_name, COUNT(q.conversation_handle) as msgCount from sys.transmission_queue q ( nolock)
group by q.message_type_name, q.to_service_name