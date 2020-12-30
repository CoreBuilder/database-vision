-- =============================================
-- Always On Cluser Info
-- =============================================


SELECT
    member_name,
    member_type_desc AS member_type,
    member_state_desc AS member_state,
    number_of_quorum_votes
FROM sys.dm_hadr_cluster_members