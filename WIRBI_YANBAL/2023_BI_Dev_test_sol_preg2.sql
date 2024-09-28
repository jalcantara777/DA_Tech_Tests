CREATE PROCEDURE GenerarEvolucionClientes
AS
BEGIN
	IF OBJECT_ID ('EvolucionClientes') IS NOT NULL
	BEGIN
		DROP TABLE EvolucionClientes
	END 
    CREATE TABLE EvolucionClientes (
        Anio INT,
        Mes INT,
        Activo INT,
        Nuevo_Cliente INT,
        Repitente INT,
        Reingreso INT,
        Porc_NvoCliente DECIMAL(5,2),
        Porc_Repitente DECIMAL(5,2),
        Porc_Reingreso DECIMAL(5,2)
    );
    INSERT INTO EvolucionClientes (Anio, Mes, Activo, Nuevo_Cliente, Repitente, Reingreso, Porc_NvoCliente, Porc_Repitente, Porc_Reingreso)
    SELECT 
        YEAR(OrderDate) AS Anio,
        MONTH(OrderDate) AS Mes,
        COUNT(DISTINCT CustomerID) AS Activo,
        SUM(CASE WHEN ((DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) > 12) OR (FechaUltimaCompra IS NULL)) THEN 1 ELSE 0 END) AS Nuevo_Cliente,
        SUM(CASE WHEN DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) = 1 THEN 1 ELSE 0 END) AS Repitente,
        SUM(CASE WHEN DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) BETWEEN 2 AND 12 THEN 1 ELSE 0 END) AS Reingreso,
        CONVERT(DECIMAL(5,2), 100.0 * SUM(CASE WHEN ((DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) > 12) OR (FechaUltimaCompra IS NULL)) THEN 1 ELSE 0 END) / COUNT(DISTINCT CustomerID)) AS Porc_NvoCliente,
        CONVERT(DECIMAL(5,2), 100.0 * SUM(CASE WHEN DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) = 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT CustomerID)) AS Porc_Repitente,
        CONVERT(DECIMAL(5,2), 100.0 * SUM(CASE WHEN DATEDIFF(MONTH, FechaUltimaCompra, OrderDate) BETWEEN 2 AND 12 THEN 1 ELSE 0 END) / COUNT(DISTINCT CustomerID)) AS Porc_Reingreso
    FROM 
    (
        SELECT 
            CustomerID,
            OrderDate,
            (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader P2 WHERE P2.CustomerID = P1.CustomerID AND P2.OrderDate < P1.OrderDate) AS FechaUltimaCompra
        FROM Sales.SalesOrderHeader P1
    ) AS SubConsulta
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
    ORDER BY Anio, Mes;
END;

EXEC GenerarEvolucionClientes;

SELECT * FROM EvolucionClientes ORDER BY Anio, Mes