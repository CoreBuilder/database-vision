-- ==============================================================
-- Service Broker Mesaj yaratma
-- ==============================================================

-- Service Broker Mesaj ve Kontrat yaratma
CREATE MESSAGE TYPE [ProformaMessage] AUTHORIZATION [dbo] VALIDATION = WELL_FORMED_XML	-- Mesaj yaratma
CREATE CONTRACT [ProformaContract] AUTHORIZATION [dbo] ([ProformaMessage] SENT BY ANY)	-- Kontrat yaratma ve mesajı kontrata ekleme
ALTER SERVICE [TestOperatorProdService]  (ADD CONTRACT [ProformaContract])				-- Kontratı servise ekleme