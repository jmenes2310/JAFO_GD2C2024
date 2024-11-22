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