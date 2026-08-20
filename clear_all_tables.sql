-- =========================================================================
-- TASKMATE APP - CLEAR ALL DATA SCRIPT
-- =========================================================================
-- Use this script when you want to wipe all data for fresh testing.
-- This script uses DELETE instead of TRUNCATE to avoid Foreign Key errors,
-- and it automatically resets the auto-increment (IDENTITY) back to 0.
-- =========================================================================

-- 1. Disable all foreign key constraints temporarily
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all";
GO

-- 2. Clear all transaction tables (Children first)
DELETE FROM dbo.AttendanceLogsTaskMateApp;
DBCC CHECKIDENT ('dbo.AttendanceLogsTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.AttendanceTaskMateApp;
DBCC CHECKIDENT ('dbo.AttendanceTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.ApplyLeaveTaskMateApp;
DBCC CHECKIDENT ('dbo.ApplyLeaveTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.LeaveCarryForwardTaskMateApp;
DBCC CHECKIDENT ('dbo.LeaveCarryForwardTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.PayslipTaskMateApp;
DBCC CHECKIDENT ('dbo.PayslipTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.DailyTaskMateApp;
DBCC CHECKIDENT ('dbo.DailyTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.SubProjectTaskMateApp;
DBCC CHECKIDENT ('dbo.SubProjectTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.EmployeeDetailsTaskMateApp;
DBCC CHECKIDENT ('dbo.EmployeeDetailsTaskMateApp', RESEED, 0);
GO

-- 3. Clear core master tables (Parents last)
DELETE FROM dbo.ProjectTaskMateApp;
DBCC CHECKIDENT ('dbo.ProjectTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.LeaveTypeTaskMateApp;
DBCC CHECKIDENT ('dbo.LeaveTypeTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.UserTaskMateApp;
DBCC CHECKIDENT ('dbo.UserTaskMateApp', RESEED, 0);
GO

-- OPTIONAL: Usually, you don't want to delete Roles, Holidays, and Financial Years
-- every time. But if you want a TRULY blank database, uncomment the below lines:

/*
DELETE FROM dbo.RoleTaskMateApp;
DBCC CHECKIDENT ('dbo.RoleTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.HolidayTaskMateApp;
DBCC CHECKIDENT ('dbo.HolidayTaskMateApp', RESEED, 0);
GO

DELETE FROM dbo.FinancialYearTaskMateApp;
DBCC CHECKIDENT ('dbo.FinancialYearTaskMateApp', RESEED, 0);
GO
*/

-- 4. Re-enable all foreign key constraints
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all";
GO

PRINT 'All selected tables have been cleared and identities have been reset.';
