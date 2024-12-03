-----------------VISTAS--------------------------------------------------------
--1. Promedio de tiempo de publicaciones por cuatrimestre/año y subrubro
IF OBJECT_ID('jafo.view_promedio_tiempo_publicaciones', 'V') IS NOT NULL
    DROP VIEW jafo.view_promedio_tiempo_publicaciones;
GO

create VIEW jafo.view_promedio_tiempo_publicaciones AS
SELECT ds.nombre subrubro, dt.Anio , dt.Cuatrimestre, AVG(hp.tiempo_vigente_promedio) AS TiempoPromedio
FROM jafo.bi_hecho_publicacion hp
JOIN jafo.bi_dim_subrubro ds ON hp.subrubro_id = ds.codigo
JOIN jafo.bi_dim_tiempo dt ON dt.id_tiempo = hp.tiempo_id
GROUP BY ds.nombre, dt.Anio, dt.Cuatrimestre;

go
--2. Promedio de Stock Inicial. Cantidad de stock promedio con que se dan de alta
--las publicaciones según la Marca de los productos publicados por año.
IF OBJECT_ID('jafo.view_promedio_stock_por_marca', 'V') IS NOT NULL
    DROP VIEW jafo.view_promedio_stock_por_marca;
GO

create VIEW view_promedio_stock_por_marca AS
SELECT dm.descripcion, dt.anio, AVG(hp.stock_inicial_promedio) AS StockPromedio
FROM jafo.bi_hecho_publicacion hp
inner JOIN jafo.bi_dim_marca dm ON dm.id_marca = hp.marca_id
inner JOIN jafo.bi_dim_tiempo dt ON dt.id_tiempo = hp.tiempo_id
GROUP BY dm.id_marca, dm.descripcion, dt.Anio;
go

--3 
IF OBJECT_ID('jafo.view_promedio_venta_mensual_por_provincia', 'V') IS NOT NULL
    DROP VIEW jafo.view_promedio_venta_mensual_por_provincia;
GO

CREATE VIEW jafo.view_promedio_venta_mensual_por_provincia AS
SELECT 
    ub.provincia AS Provincia,
    dt.anio AS Año,
    dt.mes AS Mes,
    CAST(SUM(hv.importe_total) AS DECIMAL(18, 2)) / SUM(hv.cantidad_ventas)  AS VentaPromedioMensual
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
IF OBJECT_ID('jafo.view_top_5_rubros_por_rendimiento', 'V') IS NOT NULL
    DROP VIEW jafo.view_top_5_rubros_por_rendimiento;
GO

CREATE VIEW jafo.view_top_5_rubros_por_rendimiento AS
SELECT 
    Año,
    Cuatrimestre,
    Localidad,
    RangoEtario,
    Rubro,
    TotalVentas,
    Ranking
FROM (
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
) subquery
WHERE 
    Ranking <= 5;
GO


--5
IF OBJECT_ID('jafo.view_volumen_ventas_rango_horario', 'V') IS NOT NULL
    DROP VIEW jafo.view_volumen_ventas_rango_horario;
GO

CREATE VIEW jafo.view_volumen_ventas_rango_horario AS
SELECT 
    dt.anio AS Año,
    dt.mes AS Mes,
    rh.descripcion_rango AS RangoHorario,
    SUM(hv.cantidad_ventas) AS CantidadVentas
FROM 
    jafo.bi_hechos_ventas hv
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hv.idTiempo = dt.id_tiempo
INNER JOIN 
    jafo.bi_dim_rango_horario rh ON hv.idRangoHorario = rh.idRangoHorario
GROUP BY 
    dt.anio, dt.mes, rh.descripcion_rango;
GO

--6 
IF OBJECT_ID('jafo.view_top_3_localidades_pagos_cuotas', 'V') IS NOT NULL
    DROP VIEW jafo.view_top_3_localidades_pagos_cuotas;
GO

CREATE VIEW jafo.view_top_3_localidades_pagos_cuotas AS
SELECT 
    Año,
    Mes,
    MedioPago,
    Localidad,
    TotalImporte,
    Ranking
FROM (
    SELECT 
        dt.anio AS Año,
        dt.mes AS Mes,
        mp.nombre AS MedioPago,
        ub.localidad AS Localidad,
        SUM(hp.importe) AS TotalImporte,
        RANK() OVER (
            PARTITION BY dt.anio, dt.mes, mp.id_medio_pago 
            ORDER BY SUM(hp.importe) DESC
        ) AS Ranking
    FROM 
        jafo.bi_hechos_pagos hp
    INNER JOIN 
        jafo.bi_dim_tiempo dt ON hp.dim_tiempo_id = dt.id_tiempo
    INNER JOIN 
        jafo.bi_dim_ubicacion ub ON hp.dim_ubicacion_id = ub.idUbicacion
    INNER JOIN 
        jafo.bi_dim_medio_pago mp ON hp.dim_medio_pago_id = mp.id_medio_pago
    INNER JOIN
		jafo.bi_dim_cantidad_cuotas dcc ON hp.dim_cantidad_cuotas_id = dcc.id_cantidad_cuotas 
		AND dcc.cantidad > 1
    GROUP BY 
        dt.anio, dt.mes, mp.id_medio_pago, mp.nombre, ub.localidad
) subquery
WHERE 
    Ranking <= 3;
GO

--7. Porcentaje de cumplimiento de envíos en los tiempos programados por
--provincia (del almacén) por año/mes (desvío). Se calcula teniendo en cuenta los
--envíos cumplidos sobre el total de envíos para el período.
IF OBJECT_ID('jafo.vw_cumplimiento_envios', 'V') IS NOT NULL
    DROP VIEW jafo.vw_cumplimiento_envios;
GO

create VIEW jafo.vw_cumplimiento_envios AS
SELECT 
    du.provincia AS Provincia,
    t.anio AS Año,
    t.mes AS Mes,
    SUM(he.cantidad_total) AS TotalEnvios,
    SUM(he.cantidad_a_tiempo) AS EnviosCumplidos,
    CAST(100.0 * SUM(he.cantidad_total) / SUM(he.cantidad_a_tiempo) AS DECIMAL(5, 2)) AS PorcentajeCumplimiento
FROM 
    jafo.bi_hechos_envios he
INNER JOIN jafo.bi_dim_ubicacion du 
	ON he.idUbicacionAlmacen = du.idUbicacion
INNER JOIN jafo.bi_dim_tiempo t 
	ON he.idTiempo = t.id_tiempo
GROUP BY du.provincia, t.anio, t.mes

go

--8. Localidades que pagan mayor costo de envío. Las 5 localidades (tomando la
--localidad del cliente) con mayor costo de envío.
IF OBJECT_ID('jafo.vw_localidades_mas_pagan', 'V') IS NOT NULL
    DROP VIEW jafo.vw_localidades_mas_pagan;
GO

CREATE VIEW jafo.vw_localidades_mas_pagan AS
SELECT TOP 5 du.localidad, SUM(he.costo) AS costo
FROM jafo.bi_hechos_envios he
INNER JOIN jafo.bi_dim_ubicacion du 
	ON he.idUbicacionCliente = du.idUbicacion
GROUP BY du.localidad, he.costo
ORDER BY SUM(he.costo) DESC
GO

--9. Porcentaje de facturación por concepto para cada mes de cada año. Se calcula
--en función del total del concepto sobre el total del período.
IF OBJECT_ID('jafo.porcentaje_facturacion_concepto', 'V') IS NOT NULL
    DROP VIEW jafo.porcentaje_facturacion_concepto;
GO


create view porcentaje_facturacion_concepto as
SELECT 
    dc.nombre_concepto as nombreConcepto,
    SUM(hf.total) AS TotalFacturadoConcepto,
    CAST(
        100.0 * sum(hf.total) 
        / 
        (SELECT 
         SUM(hf.total)
		 FROM jafo.bi_hechos_facturacion hf
		 INNER JOIN 
         jafo.bi_dim_tiempo dt1 ON hf.idTiempo = dt1.id_tiempo
		 where dt.anio = dt1.anio and dt.mes = dt1.mes 
		 GROUP BY dt1.anio, dt1.mes
		) as decimal(18,2)
    ) AS PorcentajeConcepto,
	dt.anio,
	dt.mes
FROM jafo.bi_hechos_facturacion hf
inner join jafo.bi_dim_concepto dc
    on dc.idConcepto = hf.idConcepto
INNER JOIN jafo.bi_dim_tiempo dt 
    ON hf.idTiempo = dt.id_tiempo
GROUP BY dc.nombre_concepto, dt.anio, dt.mes
go

--10. Facturación por provincia. Monto facturado según la provincia del vendedor
--para cada cuatrimestre de cada año.
IF OBJECT_ID('jafo.view_facturacion_por_provincia', 'V') IS NOT NULL
    DROP VIEW jafo.view_facturacion_por_provincia;
GO

CREATE VIEW jafo.view_facturacion_por_provincia AS
SELECT 
    dt.anio AS Año,
    dt.cuatrimestre AS Cuatrimestre,
    ub.provincia AS Provincia,
    SUM(hf.total) AS TotalFacturado
FROM jafo.bi_hechos_detalle_factura hf
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hf.idTiempo = dt.id_tiempo
INNER JOIN 
    jafo.bi_dim_ubicacion ub ON hf.idUbicacionVendedor = ub.idUbicacion
GROUP BY 
	ub.provincia,
    dt.cuatrimestre,
	dt.anio
    
    
GO
