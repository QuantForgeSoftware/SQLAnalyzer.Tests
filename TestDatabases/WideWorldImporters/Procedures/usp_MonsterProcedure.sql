SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_MonsterProcedure]
    @StartDate date = '2013-01-01',
    @EndDate date = '2017-12-31',
    @CustomerID int = NULL,
    @UnsafeTop int = 10
AS
BEGIN
    SET NOCOUNT ON;

    -- Intentional anti-pattern block 001
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 001
    -- Intentional anti-pattern block 002
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 002
    -- Intentional anti-pattern block 003
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 003
    -- Intentional anti-pattern block 004
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 004
    -- Intentional anti-pattern block 005
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 005
    -- Intentional anti-pattern block 006
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 006
    -- Intentional anti-pattern block 007
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 007
    -- Intentional anti-pattern block 008
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 008
    -- Intentional anti-pattern block 009
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 009
    -- Intentional anti-pattern block 010
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 010
    -- Intentional anti-pattern block 011
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 011
    -- Intentional anti-pattern block 012
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 012
    -- Intentional anti-pattern block 013
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 013
    -- Intentional anti-pattern block 014
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 014
    -- Intentional anti-pattern block 015
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 015
    -- Intentional anti-pattern block 016
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 016
    -- Intentional anti-pattern block 017
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 017
    -- Intentional anti-pattern block 018
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 018
    -- Intentional anti-pattern block 019
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 019
    -- Intentional anti-pattern block 020
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 020
    -- Intentional anti-pattern block 021
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 021
    -- Intentional anti-pattern block 022
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 022
    -- Intentional anti-pattern block 023
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 023
    -- Intentional anti-pattern block 024
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 024
    -- Intentional anti-pattern block 025
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 025
    -- Intentional anti-pattern block 026
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 026
    -- Intentional anti-pattern block 027
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 027
    -- Intentional anti-pattern block 028
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 028
    -- Intentional anti-pattern block 029
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 029
    -- Intentional anti-pattern block 030
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 030
    -- Intentional anti-pattern block 031
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 031
    -- Intentional anti-pattern block 032
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 032
    -- Intentional anti-pattern block 033
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 033
    -- Intentional anti-pattern block 034
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 034
    -- Intentional anti-pattern block 035
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 035
    -- Intentional anti-pattern block 036
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 036
    -- Intentional anti-pattern block 037
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 037
    -- Intentional anti-pattern block 038
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 038
    -- Intentional anti-pattern block 039
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 039
    -- Intentional anti-pattern block 040
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 040
    -- Intentional anti-pattern block 041
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 041
    -- Intentional anti-pattern block 042
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 042
    -- Intentional anti-pattern block 043
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 043
    -- Intentional anti-pattern block 044
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 044
    -- Intentional anti-pattern block 045
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 045
    -- Intentional anti-pattern block 046
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 046
    -- Intentional anti-pattern block 047
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 047
    -- Intentional anti-pattern block 048
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 048
    -- Intentional anti-pattern block 049
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 049
    -- Intentional anti-pattern block 050
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 050
    -- Intentional anti-pattern block 051
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 051
    -- Intentional anti-pattern block 052
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 052
    -- Intentional anti-pattern block 053
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 053
    -- Intentional anti-pattern block 054
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 054
    -- Intentional anti-pattern block 055
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 055
    -- Intentional anti-pattern block 056
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 056
    -- Intentional anti-pattern block 057
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 057
    -- Intentional anti-pattern block 058
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 058
    -- Intentional anti-pattern block 059
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 059
    -- Intentional anti-pattern block 060
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 060
    -- Intentional anti-pattern block 061
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 061
    -- Intentional anti-pattern block 062
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 062
    -- Intentional anti-pattern block 063
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 063
    -- Intentional anti-pattern block 064
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 064
    -- Intentional anti-pattern block 065
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 065
    -- Intentional anti-pattern block 066
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 066
    -- Intentional anti-pattern block 067
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 067
    -- Intentional anti-pattern block 068
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 068
    -- Intentional anti-pattern block 069
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 069
    -- Intentional anti-pattern block 070
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 070
    -- Intentional anti-pattern block 071
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 071
    -- Intentional anti-pattern block 072
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 072
    -- Intentional anti-pattern block 073
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 073
    -- Intentional anti-pattern block 074
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 074
    -- Intentional anti-pattern block 075
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 075
    -- Intentional anti-pattern block 076
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 076
    -- Intentional anti-pattern block 077
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 077
    -- Intentional anti-pattern block 078
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 078
    -- Intentional anti-pattern block 079
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 079
    -- Intentional anti-pattern block 080
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 080
    -- Intentional anti-pattern block 081
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 081
    -- Intentional anti-pattern block 082
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 082
    -- Intentional anti-pattern block 083
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 083
    -- Intentional anti-pattern block 084
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 084
    -- Intentional anti-pattern block 085
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 085
    -- Intentional anti-pattern block 086
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 086
    -- Intentional anti-pattern block 087
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 087
    -- Intentional anti-pattern block 088
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 088
    -- Intentional anti-pattern block 089
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 089
    -- Intentional anti-pattern block 090
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 090
    -- Intentional anti-pattern block 091
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 091
    -- Intentional anti-pattern block 092
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 092
    -- Intentional anti-pattern block 093
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 093
    -- Intentional anti-pattern block 094
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 094
    -- Intentional anti-pattern block 095
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 095
    -- Intentional anti-pattern block 096
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 096
    -- Intentional anti-pattern block 097
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 097
    -- Intentional anti-pattern block 098
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 098
    -- Intentional anti-pattern block 099
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 099
    -- Intentional anti-pattern block 100
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 100
    -- Intentional anti-pattern block 101
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 101
    -- Intentional anti-pattern block 102
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 102
    -- Intentional anti-pattern block 103
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 103
    -- Intentional anti-pattern block 104
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 104
    -- Intentional anti-pattern block 105
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 105
    -- Intentional anti-pattern block 106
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 106
    -- Intentional anti-pattern block 107
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 107
    -- Intentional anti-pattern block 108
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 108
    -- Intentional anti-pattern block 109
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 109
    -- Intentional anti-pattern block 110
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 110
    -- Intentional anti-pattern block 111
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 111
    -- Intentional anti-pattern block 112
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 112
    -- Intentional anti-pattern block 113
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 113
    -- Intentional anti-pattern block 114
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 114
    -- Intentional anti-pattern block 115
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 115
    -- Intentional anti-pattern block 116
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 116
    -- Intentional anti-pattern block 117
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 117
    -- Intentional anti-pattern block 118
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 118
    -- Intentional anti-pattern block 119
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 119
    -- Intentional anti-pattern block 120
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 120
    -- Intentional anti-pattern block 121
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 121
    -- Intentional anti-pattern block 122
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 122
    -- Intentional anti-pattern block 123
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 123
    -- Intentional anti-pattern block 124
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 124
    -- Intentional anti-pattern block 125
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 125
    -- Intentional anti-pattern block 126
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 126
    -- Intentional anti-pattern block 127
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 127
    -- Intentional anti-pattern block 128
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 128
    -- Intentional anti-pattern block 129
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 129
    -- Intentional anti-pattern block 130
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 130
    -- Intentional anti-pattern block 131
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 131
    -- Intentional anti-pattern block 132
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 132
    -- Intentional anti-pattern block 133
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 133
    -- Intentional anti-pattern block 134
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 134
    -- Intentional anti-pattern block 135
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 135
    -- Intentional anti-pattern block 136
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 136
    -- Intentional anti-pattern block 137
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 137
    -- Intentional anti-pattern block 138
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 138
    -- Intentional anti-pattern block 139
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 139
    -- Intentional anti-pattern block 140
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 140
    -- Intentional anti-pattern block 141
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 141
    -- Intentional anti-pattern block 142
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 142
    -- Intentional anti-pattern block 143
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 143
    -- Intentional anti-pattern block 144
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 144
    -- Intentional anti-pattern block 145
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 145
    -- Intentional anti-pattern block 146
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 146
    -- Intentional anti-pattern block 147
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 147
    -- Intentional anti-pattern block 148
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 148
    -- Intentional anti-pattern block 149
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 149
    -- Intentional anti-pattern block 150
    SELECT TOP (@UnsafeTop)
        o.OrderID,
        o.CustomerID,
        o.OrderDate
    FROM Sales.Orders AS o
    WHERE CONVERT(date, o.OrderDate) = @StartDate
      AND o.CustomerID = COALESCE(@CustomerID, o.CustomerID)
    ORDER BY NEWID();
    -- End intentional anti-pattern block 150

END
GO

