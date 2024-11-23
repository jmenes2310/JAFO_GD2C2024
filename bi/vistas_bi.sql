-----------------VISTAS--------------------------------------------------------
--1. Promedio de tiempo de publicaciones por cuatrimestre/año y subrubro
create VIEW jafo.view_promedio_tiempo_publicaciones AS
SELECT ds.nombre subrubro, dt.Anio , dt.Cuatrimestre, AVG(hp.tiempo_vigente) AS TiempoPromedio
FROM jafo.bi_hecho_publicacion hp
JOIN jafo.bi_dim_subrubro ds ON hp.subrubro_id = ds.codigo
JOIN jafo.bi_dim_tiempo dt ON dt.id_tiempo = hp.tiempo_id
GROUP BY ds.nombre, dt.Anio, dt.Cuatrimestre;

go

--2. Promedio de Stock Inicial. Cantidad de stock promedio con que se dan de alta
--las publicaciones según la Marca de los productos publicados por año.
create VIEW view_promedio_stock_por_marca AS
SELECT dm.descripcion, dt.anio, AVG(hp.stock) AS StockPromedio
FROM jafo.bi_hecho_publicacion hp
inner JOIN jafo.bi_dim_marca dm ON dm.id_marca = hp.marca_id
inner JOIN jafo.bi_dim_tiempo dt ON dt.id_tiempo = hp.tiempo_id
GROUP BY dm.id_marca, dm.descripcion, dt.Anio;
go

--3 
CREATE VIEW jafo.view_promedio_venta_mensual_por_provincia AS
SELECT 
    ub.provincia AS Provincia,
    dt.anio AS Año,
    dt.mes AS Mes,
    AVG(hv.importe_total) AS VentaPromedioMensual
FROM 
    jafo.bi_hechos_ventas hv
INNER JOIN 
    jafo.bi_dim_ubicacion ub ON hv.idUbicacionAlmacen = ub.idUbicacion
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hv.idTiempo = dt.id_tiempo
GROUP BY 
    ub.provincia, dt.anio, dt.mes;
GO

--4

CREATE VIEW jafo.view_top_5_rubros_por_rendimiento AS
SELECT 
    dt.anio AS Año,
    dt.cuatrimestre AS Cuatrimestre,
    ub.localidad AS Localidad,
    re.descripcion_rango AS RangoEtario,
    rb.rubro AS Rubro,
    SUM(hv.importe_total) AS TotalVentas,
    RANK() OVER (
        PARTITION BY dt.anio, dt.cuatrimestre, ub.localidad, re.idRangoEtario 
        ORDER BY SUM(hv.importe_total) DESC
    ) AS Ranking
FROM 
    jafo.bi_hechos_ventas hv
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hv.idTiempo = dt.id_tiempo
INNER JOIN 
    jafo.bi_dim_ubicacion ub ON hv.idUbicacionCliente = ub.idUbicacion
INNER JOIN 
    jafo.bi_dim_rubro rb ON hv.idRubro = rb.idRubro
INNER JOIN 
    jafo.bi_dim_rango_etario re ON hv.idRangoEtario = re.idRangoEtario
GROUP BY 
    dt.anio, dt.cuatrimestre, ub.localidad, re.idRangoEtario, re.descripcion_rango, rb.rubro
HAVING 
    RANK() OVER (
        PARTITION BY dt.anio, dt.cuatrimestre, ub.localidad, re.idRangoEtario 
        ORDER BY SUM(hv.importe_total) DESC
    ) <= 5;
GO

--5
CREATE VIEW jafo.view_volumen_ventas_rango_horario AS
SELECT 
    dt.anio AS Año,
    dt.mes AS Mes,
    rh.descripcion_rango AS RangoHorario,
    COUNT(*) AS CantidadVentas
FROM 
    jafo.bi_hechos_ventas hv
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hv.idTiempo = dt.id_tiempo
INNER JOIN 
    jafo.bi_dim_rango_horario rh ON hv.idRangoHorario = rh.idRangoHorario
GROUP BY 
    dt.anio, dt.mes, rh.descripcion_rango;
GO

