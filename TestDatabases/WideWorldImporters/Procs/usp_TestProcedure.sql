SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_TestProcedure]
    @CustomerID int = NULL,
    @RunUnsafeWrites bit = 0,     @CustomerName nvarchar(100),     @NewCategory nvarchar(50)
AS
BEGIN
    -- added lines to match
    -- test
    -- ISSUE: NoCountDisabled | Leaves row-count chatter enabled, increasing client and network noise.
    SET NOCOUNT OFF;

    -- ISSUE: XactAbortDisabled | Allows some run-time errors to leave a transaction partially applied.
    SET XACT_ABORT OFF;

    DECLARE @CustomerIdText nvarchar(20) = N'1';
    DECLARE @Sql nvarchar(max);
    DECLARE @OrderID int = 1;
    DECLARE @Counter int = 1;

    -- ISSUE: SelectStar | Couples callers to every current and future column of Sales.Orders.
    SELECT * FROM Sales.Orders;

    -- ISSUE: TopWithoutOrderBy | Returns an arbitrary set of rows because no ordering is specified.
    SELECT TOP (10) o.OrderID FROM Sales.Orders AS o;

    -- ISSUE: UnnecessaryDistinct | Uses a duplicate-eliminating operation where OrderID is already unique.
    SELECT DISTINCT o.OrderID FROM Sales.Orders AS o;

    -- ISSUE: ReadUncommittedHint | Can return uncommitted, missing, or duplicated rows.
    SELECT o.OrderID FROM Sales.Orders AS o WITH (NOLOCK);

    -- ISSUE: FunctionOnColumn | YEAR on the indexed date column prevents a simple range seek.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE YEAR(o.OrderDate) = 2016;

    -- ISSUE: ImplicitConversion | Compares an int column with nvarchar input and can force conversion.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.CustomerID = @CustomerIdText;

    -- ISSUE: OptionalParameterOr | OR-based optional filtering makes cardinality estimation and seeking difficult.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE @CustomerID IS NULL OR o.CustomerID = @CustomerID;

    -- ISSUE: LeadingWildcardLike | A leading wildcard prevents a normal index seek on Comments.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.Comments LIKE N'%urgent%';

    -- ISSUE: NotInNullableSubquery | NOT IN has surprising results when the subquery can produce NULL.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.CustomerID NOT IN (SELECT i.CustomerID FROM Sales.Invoices AS i);

    -- ISSUE: NonSargableIsNull | Wrapping CustomerID in ISNULL makes the predicate non-sargable.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE ISNULL(o.CustomerID, 0) = 1;

    -- ISSUE: ArithmeticOnColumn | Arithmetic on OrderID prevents direct index matching.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.OrderID + 0 = @OrderID;

    -- ISSUE: NegativePredicate | Inequality often scans broad portions of the table.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.CustomerID <> 1;

    -- ISSUE: CartesianJoin | Omits a join predicate and multiplies Orders by Customers.
    SELECT TOP (1) o.OrderID, c.CustomerID FROM Sales.Orders AS o CROSS JOIN Sales.Customers AS c;

    -- ISSUE: OldStyleJoin | Comma joins obscure join predicates and make accidental cartesian joins easier.
    SELECT TOP (1) o.OrderID FROM Sales.Orders AS o, Sales.OrderLines AS ol WHERE o.OrderID = ol.OrderID;

    -- ISSUE: CorrelatedScalarSubquery | Executes a scalar lookup for every qualifying order row.
    SELECT o.OrderID, (SELECT COUNT(*) FROM Sales.OrderLines AS ol WHERE ol.OrderID = o.OrderID) AS LineCount FROM Sales.Orders AS o;

    -- ISSUE: CorrelatedExists | Runs a correlated EXISTS check per outer row instead of expressing a set join.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE EXISTS (SELECT 1 FROM Sales.OrderLines AS ol WHERE ol.OrderID = o.OrderID AND ol.Quantity > 1);

    -- ISSUE: RepeatedExpression | Repeats the same CASE expression in select and ordering logic.
    SELECT o.OrderID, CASE WHEN o.Comments IS NULL THEN 0 ELSE 1 END AS HasComments FROM Sales.Orders AS o ORDER BY CASE WHEN o.Comments IS NULL THEN 0 ELSE 1 END;

    -- ISSUE: OrderByOrdinal | Ordering by a column position becomes fragile when the select list changes.
    SELECT o.OrderID, o.OrderDate FROM Sales.Orders AS o ORDER BY 2;

    -- ISSUE: NondeterministicPagination | OFFSET pagination has no stable tie breaker.
    SELECT o.OrderID FROM Sales.Orders AS o ORDER BY o.OrderDate OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

    -- ISSUE: UnionInsteadOfUnionAll | Performs needless duplicate removal between disjoint literal branches.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.OrderID = 1 UNION SELECT o.OrderID FROM Sales.Orders AS o WHERE o.OrderID = 2;

    -- ISSUE: CountStarForExistence | Counts all matching rows when only existence is needed.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE (SELECT COUNT(*) FROM Sales.OrderLines AS ol WHERE ol.OrderID = o.OrderID) > 0;

    -- ISSUE: VariableAssignmentSelect | SELECT assignment silently accepts multiple rows and keeps the last value.
    SELECT @OrderID = o.OrderID FROM Sales.Orders AS o;

    -- ISSUE: TableVariableEstimate | A table variable may receive poor cardinality estimates on older compatibility levels.
    DECLARE @OrderIds TABLE (OrderID int PRIMARY KEY);
    INSERT @OrderIds (OrderID) SELECT TOP (5) o.OrderID FROM Sales.Orders AS o;

    -- ISSUE: SelectIntoTempTable | Creates a temp-table schema implicitly instead of declaring it explicitly.
    SELECT TOP (5) o.OrderID INTO #ImplicitOrders FROM Sales.Orders AS o;

    -- ISSUE: CursorRowByRow | Uses a cursor for work that can be expressed set-wise.
    DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR SELECT TOP (2) o.OrderID FROM Sales.Orders AS o;
    OPEN order_cursor;
    FETCH NEXT FROM order_cursor INTO @OrderID;
    CLOSE order_cursor;
    DEALLOCATE order_cursor;

    -- ISSUE: WhileLoopRowByRow | Performs iterative work instead of a set-based operation.
    WHILE @Counter <= 1
    BEGIN
        SET @Counter += 1;
    END;

    -- ISSUE: DynamicSqlConcatenation | Concatenates a value into executable SQL text.
    SET @Sql = N'SELECT OrderID FROM Sales.Orders WHERE CustomerID = ' + CONVERT(nvarchar(20), @CustomerID);
    EXEC (@Sql);

    -- ISSUE: DynamicSqlWithoutParameters | Uses sp_executesql but still embeds the value rather than binding it.
    SET @Sql = N'SELECT OrderID FROM Sales.Orders WHERE OrderID = ' + CONVERT(nvarchar(20), @OrderID);
    EXEC sys.sp_executesql @Sql;

    -- ISSUE: TempTableWithoutCleanup | Leaves an explicitly created temporary object until procedure scope ends.
    CREATE TABLE #Scratch (OrderID int NULL);

    -- ISSUE: CatchSwallowsError | Captures an error but neither rethrows nor returns a failure status.
    BEGIN TRY
        SELECT 1 / NULLIF(@OrderID, @OrderID);
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS IgnoredError;
    END CATCH;

    -- ISSUE: LegacyRaiseError | Uses RAISERROR rather than THROW for new error paths.
    IF @OrderID < 0 RAISERROR (N'Negative order ID', 16, 1);

    -- ISSUE: PrintDiagnostic | PRINT is buffered and unsuitable for structured diagnostics.
    PRINT N'Monster procedure diagnostic';

    -- ISSUE: HardCodedLiteral | Embeds a business identifier instead of accepting it as input or looking it up.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.CustomerID = 1;

    -- ISSUE: MagicDateLiteral | Embeds an unlabelled date constant in query logic.
    SELECT o.OrderID FROM Sales.Orders AS o WHERE o.OrderDate >= '20160101';

    -- ISSUE: AmbiguousDateConversion | Relies on session-sensitive date string conversion.
    SELECT CONVERT(date, '01/02/2016') AS AmbiguousDate;

    -- ISSUE: CoalesceInJoin | Applies COALESCE in a join predicate, inhibiting normal join optimization.
    SELECT TOP (1) o.OrderID FROM Sales.Orders AS o JOIN Sales.Invoices AS i ON COALESCE(o.CustomerID, 0) = COALESCE(i.CustomerID, 0);

    -- ISSUE: SelfJoinWithoutNeed | Self-joins Orders solely to retrieve the same key.
    SELECT TOP (1) o.OrderID FROM Sales.Orders AS o JOIN Sales.Orders AS o2 ON o.OrderID = o2.OrderID;

    -- ISSUE: WideSort | Sorts every order by an unselective text column.
    SELECT o.OrderID FROM Sales.Orders AS o ORDER BY o.Comments;

    -- ISSUE: AggregateWithoutFilter | Aggregates the entire fact-like order-line table for a single scalar result.
    SELECT SUM(ol.Quantity) AS TotalQuantity FROM Sales.OrderLines AS ol;

    -- ISSUE: HavingForRowFilter | Applies a row-level predicate after grouping rather than in WHERE.
    SELECT ol.OrderID FROM Sales.OrderLines AS ol GROUP BY ol.OrderID HAVING ol.OrderID > 0;

    -- ISSUE: RedundantOrderBy | Orders a one-row aggregate result unnecessarily.
    SELECT COUNT(*) AS OrderCount FROM Sales.Orders AS o ORDER BY OrderCount;

    -- ISSUE: MergeStatement | MERGE has documented concurrency and correctness edge cases.
    IF @RunUnsafeWrites = 1
        MERGE Sales.Orders AS target
        USING (SELECT @OrderID AS OrderID) AS source ON target.OrderID = source.OrderID
        WHEN MATCHED THEN UPDATE SET target.Comments = target.Comments;

    -- ISSUE: UpdateWithoutMeaningfulChange | Issues a write that changes no data and still causes logging and locking.
    IF @RunUnsafeWrites = 1
        UPDATE Sales.Orders SET Comments = Comments WHERE OrderID = @OrderID;

    -- ISSUE: DeleteWithWeakPredicate | Deletes based on a broad business value rather than a stable key.
    IF @RunUnsafeWrites = 1
        DELETE FROM Sales.OrderLines WHERE Quantity = -1;

    -- ISSUE: WaitForDelay | Intentionally blocks a worker instead of using asynchronous scheduling.
    IF @RunUnsafeWrites = 1
        WAITFOR DELAY '00:00:01';

    -- ISSUE: ExplicitTransactionWithoutTryCatch | Starts a transaction outside an error-handling boundary.
    IF @RunUnsafeWrites = 1
    BEGIN
        BEGIN TRANSACTION;
        ROLLBACK TRANSACTION;
    END;

    -- ISSUE: SetIdentityInsert | Changes session state and introduces fragile identity-management coupling.
    IF @RunUnsafeWrites = 1
    BEGIN
        SET IDENTITY_INSERT Sales.Orders ON;
        SET IDENTITY_INSERT Sales.Orders OFF;
    END;

    -- ISSUE: UnqualifiedProcedureName | Invokes a system routine without schema qualification.
    EXEC sp_who;

    -- ISSUE: SessionSettingChanged | Changes a session setting and does not restore it.
    SET ROWCOUNT 1;
    SELECT o.OrderID FROM Sales.Orders AS o;

        CREATE TABLE #DemoCustomers (
        CustomerID int,
        CustomerName nvarchar(100),
        CustomerCategoryID int,
        DeliveryMethodID int
    );

    CREATE TABLE #DemoCategories (
        CategoryID int,
        CategoryName nvarchar(50)
    );

    INSERT INTO #DemoCategories
    VALUES (99, @NewCategory);

    INSERT INTO #DemoCustomers
    SELECT CustomerID, CustomerName, CustomerCategoryID, DeliveryMethodID
    FROM Sales.Customers
    WHERE CustomerName LIKE '%' + @CustomerName + '%';

    SET @sql = N'SELECT CustomerID, CustomerName FROM #DemoCustomers WHERE CustomerName LIKE ''%' + @CustomerName + '%''';
    EXEC sp_executesql @sql;

    UPDATE #DemoCustomers
    SET CustomerCategoryID = 1;

    SELECT c.CustomerID, c.CustomerName, o.OrderID
    FROM Sales.Customers c
    LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
    WHERE o.OrderDate >= '2016-01-01';

    SELECT CustomerID, CustomerName
    FROM Sales.Customers
    WHERE DeliveryMethodID = NULL;

    SELECT CustomerID, dbo.GetCustomerType(CustomerID) AS CustomerType
    FROM Sales.Customers;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM #DemoCustomers WHERE CustomerID = @OrderID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;

    SELECT CustomerID, CustomerName
    FROM Sales.Customers WITH (INDEX = 1)
    WHERE CustomerName LIKE @CustomerName;

    SELECT CustomerID
    FROM (
        SELECT CustomerID
        FROM (
            SELECT CustomerID
            FROM (
                SELECT CustomerID FROM Sales.Customers WHERE CustomerName LIKE '%A%'
            ) AS t1
        ) AS t2
    ) AS t3;

    SELECT * FROM dbo.GetCustomerOrdersMulti(@CustomerName);

    DROP TABLE #DemoCategories;
    DROP TABLE #DemoCustomers;
END
GO

