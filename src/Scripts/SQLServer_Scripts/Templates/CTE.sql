-- ==============================================================
-- CTE Template
-- ==============================================================

;	WITH Invoice ( invoiceID, invoiceNumber, amountcarp2 )
	AS
	(
		select top 100 H.ID, H.invoiceNumber, H.invoiceAmount * 2 
		from HotelInvoice H with(nolock)
	)
	select * from Invoice

-- ==============================================================
-- Recursive CTE Template
-- ==============================================================

WITH myCTE AS 
(
	select a.EmployeeID, a.ContactID from HumanResources.Employee a WHERE a.ManagerID IS NULL -- Manager'ları alır
	UNION ALL
	select e.EmployeeID, e.ContactID from HumanResources.Employee e 
	inner join myCTE b ON b.EmployeeID = e.ManagerID -- executed repeatedly to get results and it will continue until it returns no rows
)
select * from myCTE