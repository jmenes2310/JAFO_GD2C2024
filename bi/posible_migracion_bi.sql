
-- Creación de esquema para BI
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'BI')
BEGIN
    EXEC('CREATE SCHEMA BI');
END;

-- Creación de Dimensión Tiempo
IF OBJECT_ID('BI.DimTiempo', 'U') IS NOT NULL DROP TABLE BI.DimTiempo;
CREATE TABLE BI.DimTiempo (
    idTiempo INT IDENTITY(1,1) PRIMARY KEY,
    Anio INT,
    Cuatrimestre INT,
    Mes INT
);

-- Creación de Dimensión Ubicación
IF OBJECT_ID('BI.DimUbicacion', 'U') IS NOT NULL DROP TABLE BI.DimUbicacion;
CREATE TABLE BI.DimUbicacion (
    idUbicacion INT IDENTITY(1,1) PRIMARY KEY,
    Provincia NVARCHAR(50),
    Localidad NVARCHAR(50)
);

-- Creación de Dimensión Cliente (Rango Etario)
IF OBJECT_ID('BI.DimCliente', 'U') IS NOT NULL DROP TABLE BI.DimCliente;
CREATE TABLE BI.DimCliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    RangoEtario NVARCHAR(20)
);

-- Creación de Dimensión Medio de Pago
IF OBJECT_ID('BI.DimMedioPago', 'U') IS NOT NULL DROP TABLE BI.DimMedioPago;
CREATE TABLE BI.DimMedioPago (
    idMedioPago INT IDENTITY(1,1) PRIMARY KEY,
    TipoMedioPago NVARCHAR(50)
);

-- Creación de Dimensión Envío
IF OBJECT_ID('BI.DimEnvio', 'U') IS NOT NULL DROP TABLE BI.DimEnvio;
CREATE TABLE BI.DimEnvio (
    idEnvio INT IDENTITY(1,1) PRIMARY KEY,
    TipoEnvio NVARCHAR(50)
);

-- Creación de Dimensión Producto
IF OBJECT_ID('BI.DimProducto', 'U') IS NOT NULL DROP TABLE BI.DimProducto;
CREATE TABLE BI.DimProducto (
    idProducto INT IDENTITY(1,1) PRIMARY KEY,
    Rubro NVARCHAR(50),
    SubRubro NVARCHAR(50),
    Marca NVARCHAR(50)
);

-- Creación de Tabla de Hechos: Ventas
IF OBJECT_ID('BI.HechosVentas', 'U') IS NOT NULL DROP TABLE BI.HechosVentas;
CREATE TABLE BI.HechosVentas (
    idVenta INT IDENTITY(1,1) PRIMARY KEY,
    idTiempo INT FOREIGN KEY REFERENCES BI.DimTiempo(idTiempo),
    idUbicacion INT FOREIGN KEY REFERENCES BI.DimUbicacion(idUbicacion),
    idCliente INT FOREIGN KEY REFERENCES BI.DimCliente(idCliente),
    idMedioPago INT FOREIGN KEY REFERENCES BI.DimMedioPago(idMedioPago),
    idEnvio INT FOREIGN KEY REFERENCES BI.DimEnvio(idEnvio),
    idProducto INT FOREIGN KEY REFERENCES BI.DimProducto(idProducto),
    Cantidad INT,
    Importe FLOAT,
    CostoEnvio FLOAT
);

-- Migración de datos a las dimensiones

-- Cargar Dimensión Tiempo
INSERT INTO BI.DimTiempo (Anio, Cuatrimestre, Mes)
SELECT DISTINCT YEAR(Fecha) AS Anio,
    CASE 
        WHEN MONTH(Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS Cuatrimestre,
    MONTH(Fecha) AS Mes
FROM Venta;

-- Cargar Dimensión Ubicación
INSERT INTO BI.DimUbicacion (Provincia, Localidad)
SELECT DISTINCT p.Nombre AS Provincia, l.Nombre AS Localidad
FROM Provincia p
JOIN Localidad l ON l.Provincia_Codigo = p.Codigo;

-- Cargar Dimensión Cliente
INSERT INTO BI.DimCliente (RangoEtario)
SELECT DISTINCT 
    CASE 
        WHEN DATEDIFF(YEAR, c.Fecha_Nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, c.Fecha_Nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, c.Fecha_Nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
        ELSE '> 50'
    END AS RangoEtario
FROM Cliente c;

INSERT INTO BI_Dim_RangoEtario (descripcion_rango)
VALUES ('< 25'), ('25-35'), ('35-50'), ('> 50');

INSERT INTO BI_Dim_RangoHorario (descripcion_horario)
VALUES ('00:00-06:00'), ('06:00-12:00'), ('12:00-18:00'), ('18:00-24:00');

-- Cargar Dimensión Medio de Pago
INSERT INTO BI.DimMedioPago (TipoMedioPago)
SELECT DISTINCT tm.Nombre
FROM Tipo_Medio_Pago tm;

-- Cargar Dimensión Envío
INSERT INTO BI.DimEnvio (TipoEnvio)
SELECT DISTINCT te.Nombre
FROM Tipo_Envio te;

-- Cargar Dimensión Producto
INSERT INTO BI.DimProducto (Rubro, SubRubro, Marca)
SELECT DISTINCT r.Descripcion AS Rubro, sr.Descripcion AS SubRubro, m.Description AS Marca
FROM Rubro r
JOIN SubRubro sr ON sr.Rubro_Codigo = r.Codigo
JOIN Marca m ON m.Codigo = sr.Codigo;

-- Migración de datos a la tabla de hechos
INSERT INTO BI.HechosVentas (idTiempo, idUbicacion, idCliente, idMedioPago, idEnvio, idProducto, Cantidad, Importe, CostoEnvio)
SELECT 
    t.idTiempo, u.idUbicacion, c.idCliente, mp.idMedioPago, e.idEnvio, p.idProducto,
    dv.Cantidad, v.Total AS Importe, e.Costo AS CostoEnvio
FROM Venta v
JOIN Detalle_Venta dv ON dv.Venta_Codigo = v.Codigo
JOIN BI.DimTiempo t ON t.Anio = YEAR(v.Fecha) AND t.Mes = MONTH(v.Fecha)
JOIN BI.DimUbicacion u ON u.Provincia = (SELECT p.Nombre FROM Provincia p WHERE p.Codigo = a.Provincia_Codigo)
JOIN BI.DimCliente c ON c.RangoEtario = 
    CASE 
        WHEN DATEDIFF(YEAR, cl.Fecha_Nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, cl.Fecha_Nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, cl.Fecha_Nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
        ELSE '> 50'
    END
JOIN BI.DimMedioPago mp ON mp.TipoMedioPago = (SELECT tm.Nombre FROM Tipo_Medio_Pago tm WHERE tm.Codigo = p.Medio_Pago_Codigo)
JOIN BI.DimEnvio e ON e.TipoEnvio = (SELECT te.Nombre FROM Tipo_Envio te WHERE te.Codigo = env.Tipo_Envio_Codigo)
JOIN BI.DimProducto p ON p.Rubro = r.Descripcion AND p.SubRubro = sr.Descripcion AND p.Marca = m.Description;

-- Vistas para consultas de negocio

-- Promedio de tiempo de publicaciones por cuatrimestre/año y subrubro
CREATE VIEW BI.vPromedioTiempoPublicaciones AS
SELECT dp.SubRubro, dt.Anio, dt.Cuatrimestre, AVG(DATEDIFF(DAY, p.Fecha_Inicio, p.Fecha_Fin)) AS TiempoPromedio
FROM hechos_Publicacion p
JOIN BI.DimSubRubro ds ON p.subrubro_id = ds.id
JOIN BI.DimTiempo dt ON dt.Anio = YEAR(p.Fecha_Inicio)
GROUP BY dp.SubRubro, dt.Anio, dt.Cuatrimestre;

-- Promedio de stock inicial por marca
CREATE VIEW BI.vPromedioStockMarca AS
SELECT dp.Marca, dt.Anio, AVG(p.Stock) AS StockPromedio
FROM Publicacion p
JOIN BI.DimProducto dp ON dp.idProducto = p.Codigo
JOIN BI.DimTiempo dt ON dt.Anio = YEAR(p.Fecha_Inicio)
GROUP BY dp.Marca, dt.Anio;

-- Venta promedio mensual por provincia
CREATE VIEW BI.vVentaPromedioProvincia AS
SELECT du.Provincia, dt.Anio, dt.Mes, AVG(hv.Importe) AS VentaPromedio
FROM BI.HechosVentas hv
JOIN BI.DimUbicacion du ON du.idUbicacion = hv.idUbicacion
JOIN BI.DimTiempo dt ON dt.idTiempo = hv.idTiempo
GROUP BY du.Provincia, dt.Anio, dt.Mes;



--**********************************************************************************************************************************************************************
CREATE TABLE BI_Hechos_Ventas (
    id_hecho INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT,
    id_ubicacion INT,
    id_rango_etario INT,
    id_rango_horario INT,
    id_medio_pago INT,
    id_tipo_envio INT,
    id_rubro INT,
    cantidad_ventas INT,
    total_ventas DECIMAL(18,2),
    costo_envio DECIMAL(18,2),
    total_facturacion DECIMAL(18,2),
    FOREIGN KEY (id_tiempo) REFERENCES BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_ubicacion) REFERENCES BI_Dim_Ubicacion(id_ubicacion),
    FOREIGN KEY (id_rango_etario) REFERENCES BI_Dim_RangoEtario(id_rango_etario),
    FOREIGN KEY (id_rango_horario) REFERENCES BI_Dim_RangoHorario(id_rango_horario),
    FOREIGN KEY (id_medio_pago) REFERENCES BI_Dim_MedioPago(id_medio_pago),
    FOREIGN KEY (id_tipo_envio) REFERENCES BI_Dim_TipoEnvio(id_tipo_envio),
    FOREIGN KEY (id_rubro) REFERENCES BI_Dim_Rubro(id_rubro)
);

--insert ventas 
INSERT INTO BI_Hechos_Ventas (
    id_tiempo, id_ubicacion, id_rango_etario, id_rango_horario, 
    id_medio_pago, id_tipo_envio, id_rubro, 
    cantidad_ventas, total_ventas, costo_envio, total_facturacion
)
SELECT 
    (SELECT id_tiempo FROM BI_Dim_Tiempo WHERE anio = YEAR(v.fecha) AND mes = DATENAME(MONTH, v.fecha)),
    (SELECT id_ubicacion FROM BI_Dim_Ubicacion WHERE provincia = p.nombre AND localidad = l.nombre),
    (CASE 
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) < 25 THEN 1
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN 2
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN 3
         ELSE 4
     END),
    (CASE 
         WHEN DATEPART(HOUR, v.fecha) BETWEEN 0 AND 5 THEN 1
         WHEN DATEPART(HOUR, v.fecha) BETWEEN 6 AND 11 THEN 2
         WHEN DATEPART(HOUR, v.fecha) BETWEEN 12 AND 17 THEN 3
         ELSE 4
     END),
    (SELECT id_medio_pago FROM BI_Dim_MedioPago WHERE nombre_medio_pago = mp.nombre),
    (SELECT id_tipo_envio FROM BI_Dim_TipoEnvio WHERE nombre_tipo_envio = te.nombre),
    (SELECT id_rubro FROM BI_Dim_Rubro WHERE nombre_rubro = r.descripcion AND nombre_subrubro = sr.descripcion),
    COUNT(v.codigo),
    SUM(dv.SubTotal),
    SUM(e.costo),
    SUM(f.total)
FROM Venta v
JOIN Cliente c ON v.cliente_codigo = c.codigo
JOIN Domicilio d ON c.codigo = d.codigo
JOIN Localidad l ON d.localidad_codigo = l.codigo
JOIN Provincia p ON l.provincia_codigo = p.codigo
JOIN Detalle_Venta dv ON v.codigo = dv.venta_codigo
JOIN Publicacion pub ON dv.publicacion_codigo = pub.codigo
JOIN Producto prod ON pub.producto_id = prod.codigo
JOIN SubRubro sr ON prod.subrubro_codigo = sr.codigo
JOIN Rubro r ON sr.rubro_codigo = r.codigo
JOIN Medio_Pago mp ON v.codigo = mp.codigo
JOIN Tipo_Envio te ON e.tipo_envio_codigo = te.codigo
JOIN Factura f ON v.codigo = f.numero
GROUP BY 
    YEAR(v.fecha), DATENAME(MONTH, v.fecha), p.nombre, l.nombre, 
    c.fecha_nacimiento, DATEPART(HOUR, v.fecha), mp.nombre, te.nombre, r.descripcion, sr.descripcion;
