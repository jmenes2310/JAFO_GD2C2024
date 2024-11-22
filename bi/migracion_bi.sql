-----------------MIGRACIONES--------------------------------------------------------

--tiempo
create procedure jafo.migracion_bi_dim_tiempo
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.bi_dim_tiempo (anio, cuatrimestre, mes)
			
				select distinct year(Fecha) AS Anio,
					case 
						when MONTH(Fecha) BETWEEN 1 AND 4 then 1
						when MONTH(Fecha) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(Fecha) as Mes
				from jafo.Venta

				union
				
				select distinct year(fecha_inicio) AS Anio,
					case 
						when MONTH(fecha_inicio) BETWEEN 1 AND 4 then 1
						when MONTH(fecha_inicio) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha_inicio) as Mes
				from jafo.publicacion
			
				union

				select distinct year(fecha_fin) AS Anio,
					case 
						when MONTH(fecha_fin) BETWEEN 1 AND 4 then 1
						when MONTH(fecha_fin) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha_fin) as Mes
				from jafo.publicacion

				union

				select distinct year(fecha_entrega) AS Anio,
					case 
						when MONTH(fecha_entrega) BETWEEN 1 AND 4 then 1
						when MONTH(fecha_entrega) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha_entrega) as Mes
				from jafo.envio

				union

				select distinct year(fecha_programada) AS Anio,
					case 
						when MONTH(fecha_programada) BETWEEN 1 AND 4 then 1
						when MONTH(fecha_programada) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha_programada) as Mes
				from jafo.envio

				union

				select distinct year(fecha) AS Anio,
					case 
						when MONTH(fecha) BETWEEN 1 AND 4 then 1
						when MONTH(fecha) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha) as Mes
				from jafo.pago

				union

				select distinct year(fecha_nacimiento) AS Anio,
					case 
						when MONTH(fecha_nacimiento) BETWEEN 1 AND 4 then 1
						when MONTH(fecha_nacimiento) BETWEEN 5 AND 8 then 2
						else 3
					end as Cuatrimestre,
				month(fecha_nacimiento) as Mes
				from jafo.cliente


		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar la dimension tiempo: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--subrubro
create procedure jafo.migracion_bi_dim_subrubro
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.bi_dim_subrubro
			select codigo, descripcion
			from jafo.subrubro
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar dim subrubro: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--marca
go
create procedure jafo.migracion_bi_dim_marca
as
begin
begin try
	begin transaction
		    insert into jafo.bi_dim_marca
				select m.codigo, m.nombre
				from jafo.marca m
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar dim marca: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end
go

--producto
create procedure jafo.migracion_bi_dim_producto
as 
begin 
	begin try
	begin transaction
		insert into jafo.bi_dim_producto
			select p.id, p.subrubro_codigo, p.marca_codigo, sr.rubro_codigo
			from jafo.producto p
			inner join jafo.subrubro sr
				on sr.codigo = p.subrubro_codigo
		commit transaction
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar producto: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	
	end catch

end

go 

-- hechos publicacion
create procedure jafo.migracion_bi_hecho_publicacion
as 
begin
	begin try
	begin transaction
		
		insert into jafo.bi_hecho_publicacion
			select ds.codigo, dm.id_marca, dt.id_tiempo, p.fecha_inicio, DATEDIFF(day, p.fecha_inicio, p.fecha_fin),jafo.obtener_stock_inicial(p.codigo)
			from jafo.publicacion p
			inner join bi_dim_producto dp on dp.id_producto = p.producto_id
			inner join bi_dim_subrubro ds on ds.codigo = dp.sub_rubro_codigo
			inner join bi_dim_marca dm on dm.id_marca = dp.marca_codigo
			inner join bi_dim_tiempo dt on dt.id_tiempo = jafo.obtener_id_tiempo(p.fecha_inicio)

		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Provincia: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

create procedure jafo.migracion_dim_ubicacion
as
begin transaction
	insert into jafo.bi_dim_ubicacion (provincia, localidad)
	select distinct pr.nombre, loc.nombre
	from jafo.domicilio dom
	inner join localidad loc
		on loc.codigo = dom.localidad_codigo
	inner join provincia pr
		on pr.codigo = loc.provincia_codigo
commit
go

create procedure jafo.migracion_dim_rubro
as
begin tran
	insert into jafo.bi_dim_rubro
	select rb.codigo, rb.descripcion
	from jafo.rubro rb
commit
go

create procedure jafo.migracion_bi_dim_rango_etario 
as
begin transaction
	insert into jafo.bi_dim_rango_etario (descripcion_rango)
	values ('< 25'), ('25-35'), ('35-50'), ('> 50');
commit
go

create procedure jafo.migracion_dim_rango_horario
as
begin transaction
	insert into jafo.bi_dim_rango_horario 
	values ('00:00-06:00'), ('06:00-12:00'), ('12:00-18:00'), ('18:00-24:00');
commit
go

-- Borrar
alter procedure jafo.migracion_dim_cliente
as
begin transaction
	insert into jafo.bi_dim_cliente
	select c.codigo,
		   DATEDIFF(year, c.fecha_nacimiento, getdate())
	from cliente c
commit
go

create procedure jafo.migracion_hechos_ventas
as
begin tran
	insert into jafo.bi_hechos_ventas (idRangoHorario, importe_total, idRangoEtario, idRubro, idTiempo, idUbicacionAlmacen, idUbicacionCliente)
	select 
		(select jafo.getRangoHorarioPorFecha(envio.fecha_entrega)),
		v.total,
		(select jafo.getAgeRange(c.edad)),
		prod.idRubro,
		(select jafo.obtener_id_tiempo(cast(v.fecha as datetime))),
		(select jafo.getIdUbicacionPorIdDomicilio(publi.almacen_domicilio_codigo)),
		(select jafo.getIdUbicacionPorIdDomicilio(envio.domicilio_codigo))
	from jafo.venta v
	inner join jafo.envio envio
		on envio.venta_codigo = v.codigo
	inner join jafo.bi_dim_cliente c
		on c.idCliente = v.cliente_codigo
	inner join jafo.detalle_venta dv
		on dv.venta_codigo = v.codigo
	inner join jafo.publicacion publi
		on publi.codigo = dv.publicacion_codigo
	inner join jafo.bi_dim_producto prod
		on prod.id_producto = publi.producto_id
commit 

select jafo.getAgeRange(edad) from jafo.bi_dim_cliente
select jafo.getRangoHorarioPorFecha(fecha_entrega) from jafo.envio
select jafo.getIdUbicacionPorIdDomicilio(almacen.domicilio_codigo) from jafo.almacen
select jafo.obtener_id_tiempo(cast(fecha as datetime)) from venta
select * from jafo.bi_dim_ubicacion
select * from jafo.bi_dim_rango_horario
select * from jafo.bi_hechos_ventas

-----------------EJECUCIONES--------------------------------------------------------
EXEC JAFO.migracion_bi_dim_tiempo
EXEC jafo.migracion_bi_dim_subrubro
exec jafo.migracion_bi_dim_marca
exec jafo.migracion_dim_rubro
exec jafo.migracion_bi_dim_producto
exec jafo.migracion_bi_hecho_publicacion
exec jafo.migracion_dim_ubicacion
exec jafo.migracion_bi_dim_rango_etario 
exec jafo.migracion_dim_rango_horario
exec jafo.migracion_dim_cliente
exec jafo.migracion_hechos_ventas

-- Eliminar procedimientos en el orden correcto
DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_tiempo;
DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_subrubro;
DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_marca;
DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_producto;
DROP PROCEDURE IF EXISTS jafo.migracion_bi_hecho_publicacion;
DROP PROCEDURE IF EXISTS jafo.migracion_dim_ubicacion;
DROP PROCEDURE IF EXISTS jafo.migracion_dim_rubro;
DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_rango_etario;
DROP PROCEDURE IF EXISTS jafo.migracion_dim_rango_horario;
DROP PROCEDURE IF EXISTS jafo.migracion_dim_cliente;
DROP PROCEDURE IF EXISTS jafo.migracion_hechos_ventas;
