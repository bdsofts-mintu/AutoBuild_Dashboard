USE [Dashboard]
GO
/****** Object:  StoredProcedure [dbo].[BusinessPlan_Worker_KPI_Test]    Script Date: 01/24/2017 9:52:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mintu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[BusinessPlan_Worker_KPI_Test]
 @FromDate varchar(max), @ToDate varchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;  -- EXEC BusinessPlan_Worker_KPI_Test '2015-01-01', '2016-12-31'
	    	

	SELECT MAX(AWD.CompanyId) CompanyId, AWD.EmployeeCode, AWD.YearName, AWD.MonthId, AWD.[MonthName], MAX(AWD.WorkDays) WorkDays,  (MAX(AWD.WorkDays) * 8) WorkHours, SUM(OTHours) OTHours
			 FROM ( 
					---------------  MGL  ---------------
					SELECT MAX(EI.Unit) CompanyId, WD.EmployeeCode, DATENAME(Year, WD.WorkDate) YearName, DATEPART(m, WD.WorkDate) MonthId, 
					DATENAME(Month, WD.WorkDate) [MonthName], COUNT(*) AS WorkDays, SUM(WD.OTHour) OTHours, SlabType 
					FROM [Hrms5Misami].[dbo].[DaywiseOTHour] WD 
					LEFT JOIN Hrms5Misami..EmployeePIMSInfo EI ON EI.EmployeeCode =  WD.EmployeeCode
					WHERE WD.WorkDate BETWEEN @FromDate AND @ToDate AND EI.[Staff Category] LIKE '%W%' AND EI.DesignationID IN(838,823) --AND EI.EmployeeCode='00020'
					--AND WD.EmployeeCode='00020'
					GROUP BY WD.EmployeeCode, DATENAME(Year, WD.WorkDate), DATEPART(m, WD.WorkDate), DATENAME(Month, WD.WorkDate), WD.SlabType
					
					---------------  MGL  ---------------
					
					---------------  TAL  ---------------
					
					UNION ALL
					SELECT MAX(EI.Unit) CompanyId, WD.EmployeeCode, DATENAME(Year, WD.WorkDate) YearName, DATEPART(m, WD.WorkDate) MonthId, 
					DATENAME(Month, WD.WorkDate) [MonthName], COUNT(*) AS WorkDays, SUM(WD.OTHour) OTHours, SlabType 
					FROM (SELECT * FROM [192.168.20.5].[Hrms5Tarasima].[dbo].[DaywiseOTHour] WHERE WorkDate  BETWEEN @FromDate AND @ToDate) WD 
					LEFT JOIN (SELECT Ei.EmployeeCode, EI.Unit FROM  [192.168.20.5].[Hrms5Tarasima].[dbo].EmployeePIMSInfo EI 
								WHERE  EI.[Staff Category] LIKE '%W%' AND EI.EmployeeStatus='Active') EI ON EI.EmployeeCode =  WD.EmployeeCode
					GROUP BY WD.EmployeeCode, WD.WorkDate, DATENAME(Year, WD.WorkDate), DATEPART(m, WD.WorkDate), DATENAME(Month, WD.WorkDate), WD.SlabType

					---------------  TAL  ---------------

					---------------  RHL & BGL  ---------------
					
					UNION ALL
					SELECT MAX(EI.[Job location Info]) CompanyId, WD.EmployeeCode, DATENAME(Year, WD.WorkDate) YearName, DATEPART(m, WD.WorkDate) MonthId, 
					DATENAME(Month, WD.WorkDate) [MonthName], COUNT(*) AS WorkDays, SUM(WD.OTHour) OTHours, SlabType 
					FROM [192.168.10.8].[HRMS5].[dbo].[DaywiseOTHour] WD 
					LEFT JOIN [192.168.10.8].[HRMS5].[dbo].EmployeePIMSInfo EI ON EI.EmployeeCode =  WD.EmployeeCode
					WHERE WD.WorkDate BETWEEN @FromDate AND @ToDate AND EI.[Staff Category] LIKE '%W%' --AND EI.DesignationID IN(838,823) --AND EI.EmployeeCode='00020'
					--AND WD.EmployeeCode='00020'
					GROUP BY WD.EmployeeCode, DATENAME(Year, WD.WorkDate), DATEPART(m, WD.WorkDate), DATENAME(Month, WD.WorkDate), WD.SlabType
					-------------  RHL & BGL  ---------------
					
					) AWD 
	-- Where AWD.MonthId=1
	 GROUP BY AWD.EmployeeCode, AWD.YearName, AWD.MonthId, AWD.[MonthName]
	 ORDER BY AWD.EmployeeCode, AWD.YearName, AWD.MonthId


	--SELECT EI.[Staff Category], EI.DesignationID, * FROM [192.168.10.8].[HRMS5].[dbo].[DaywiseOTHour] WD 
	--LEFT JOIN [192.168.10.8].[HRMS5].[dbo].EmployeePIMSInfo EI ON EI.EmployeeCode =  WD.EmployeeCode
	--WHERE WD.WorkDate BETWEEN @FromDate AND @ToDate --AND EI.[Staff Category] LIKE '%W%' --AND EI.DesignationID IN(838,823)
END
