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

-- hechos publicacion
create procedure jafo.migracion_bi_hecho_publicacion
as 
begin
	begin try
	begin transaction
		
		insert into jafo.bi_hecho_publicacion
			select 
				ds.codigo, 
				dm.id_marca, 
				dt.id_tiempo, 
				avg(DATEDIFF(day, p.fecha_inicio, p.fecha_fin)),
				avg(jafo.obtener_stock_inicial(p.codigo))
			from jafo.publicacion p
			inner join jafo.producto dp on dp.id = p.producto_id
			inner join jafo.bi_dim_subrubro ds on ds.codigo = dp.subrubro_codigo
			inner join jafo.bi_dim_marca dm on dm.id_marca = dp.marca_codigo
			inner join jafo.bi_dim_tiempo dt on dt.id_tiempo = jafo.obtener_id_tiempo(p.fecha_inicio)
			group by ds.codigo, dm.id_marca, dt.id_tiempo

		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar hechos de publicacion: ', ERROR_MESSAGE())
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

create procedure jafo.migracion_hechos_ventas
as
begin tran
	insert into jafo.bi_hechos_ventas (idRangoHorario, idRangoEtario, idRubro, idTiempo, idUbicacionAlmacen, idUbicacionCliente, importe_total, cantidad_ventas)
	select 
		jafo.getRangoHorarioPorFecha(envio.fecha_entrega) ,
		jafo.getAgeRange(datediff (year,year(c.fecha_nacimiento), getdate() )),
		subr.rubro_codigo,
		 jafo.obtener_id_tiempo(cast(v.fecha as datetime)),
		 jafo.getIdUbicacionPorIdDomicilio(publi.almacen_domicilio_codigo),
		 jafo.getIdUbicacionPorIdDomicilio(envio.domicilio_codigo),
		sum (v.total),
		count(v.codigo)
	from jafo.venta v
	inner join jafo.envio envio
		on envio.venta_codigo = v.codigo
	inner join jafo.cliente c
		on c.codigo = v.cliente_codigo
	inner join jafo.detalle_venta dv
		on dv.venta_codigo = v.codigo
	inner join jafo.publicacion publi
		on publi.codigo = dv.publicacion_codigo
	inner join jafo.producto prod
		on prod.id = publi.producto_id
	inner join jafo.subrubro subr
		on subr.codigo = prod.subrubro_codigo
	group by 
		(jafo.getRangoHorarioPorFecha(envio.fecha_entrega)),
		(jafo.getAgeRange(datediff(year, year(fecha_nacimiento), GETDATE()))),
		subr.rubro_codigo,
		(jafo.obtener_id_tiempo(cast(v.fecha as datetime))),
		(jafo.getIdUbicacionPorIdDomicilio(publi.almacen_domicilio_codigo)),
		(jafo.getIdUbicacionPorIdDomicilio(envio.domicilio_codigo))
commit 

go

--medio pago
create procedure jafo.migracion_dim_medio_pago
as
begin
	begin try
		begin tran
			
			insert into jafo.bi_dim_medio_pago
				select mp.codigo, mp.nombre
				from jafo.medio_pago mp


		commit tran
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar medio pago: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end

go

--cantidad cuotas
create procedure jafo.migracion_dim_cantidad_cuotas
as
begin
	begin try
		begin tran
			
			insert into jafo.bi_dim_cantidad_cuotas
				select distinct p.cantidad_cuotas
				from jafo.pago p


		commit tran
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar cantidad de cuotas: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end

go


--hechos pago
create procedure jafo.migracion_hechos_pago
as
begin
	begin try
		begin tran
			
			insert into jafo.bi_hechos_pagos
				select 
					 jafo.getIdUbicacionPorIdDomicilio(e.domicilio_codigo)
					,dmp.id_medio_pago
					,jafo.obtener_id_tiempo(p.fecha)
					,dcc.id_cantidad_cuotas
					,sum(p.importe)
				from jafo.pago p
				inner join jafo.venta v on p.venta_codigo = v.codigo
				inner join jafo.envio e on e.venta_codigo = v.codigo
				inner join jafo.bi_dim_medio_pago dmp on p.medio_pago_codigo = dmp.id_medio_pago
				inner join jafo.bi_dim_cantidad_cuotas dcc on dcc.cantidad = p.cantidad_cuotas
				group by 
					 jafo.getIdUbicacionPorIdDomicilio(e.domicilio_codigo)
					,dmp.id_medio_pago
					,jafo.obtener_id_tiempo(p.fecha)
					,dcc.id_cantidad_cuotas

		commit tran
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar medio pago: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end
go
-- migracion tipo envio

create procedure jafo.migracion_tipo_envio
as
begin
	begin try
		begin tran
			
			insert into jafo.bi_tipo_envio
				select te.codigo, te.nombre
				from jafo.tipo_envio te

		commit tran
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar tipo envio: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end
go

--hechos envio
create procedure jafo.migracion_hechos_envio
as
begin
	begin try
		begin tran
			
			insert into jafo.bi_hechos_envios
				select 
					 jafo.getIdUbicacionPorIdDomicilio(p.almacen_domicilio_codigo)
					,jafo.getIdUbicacionPorIdDomicilio(e.domicilio_codigo)
					,e.tipo_envio_codigo
					,jafo.obtener_id_tiempo(e.fecha_entrega)
					,sum(case 
							when cast(e.fecha_entrega as date) = cast(fecha_programada as date) and DATEPART(HOUR, e.fecha_entrega) between e.horario_inicio and e.hora_fin_inicio
								then 1
								else 0
						 end)
					,count(e.id)
					,sum(e.costo)
				from jafo.envio e
				inner join jafo.detalle_venta dv on dv.venta_codigo = e.venta_codigo
				inner join jafo.publicacion p on p.codigo = dv.publicacion_codigo
				group by
					 jafo.getIdUbicacionPorIdDomicilio(p.almacen_domicilio_codigo)
					,jafo.getIdUbicacionPorIdDomicilio(e.domicilio_codigo)
					,e.tipo_envio_codigo
					,jafo.obtener_id_tiempo(e.fecha_entrega)
		commit tran
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar hechos de envio ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch

end
go

--migracion dim concepto
create procedure jafo.migracion_dim_concepto 
as
begin tran
	insert into jafo.bi_dim_concepto (idConcepto, nombre_concepto)
	select conc.codigo, conc.nombre from jafo.concepto conc
commit tran 
go


-- migracion hechos detalle factura 
create procedure jafo.migracion_hechos_facturacion
as
begin tran
	insert into jafo.bi_hechos_facturacion (idConcepto, idUbicacionVendedor, idTiempo, total)
	select 
		df.concepto_codigo,
		(jafo.getIdUbicacionPorIdDomicilio(ud.domicilio_codigo)),
		(jafo.obtener_id_tiempo(cast(f.fecha as datetime))),
		sum(df.subtotal)
	from jafo.detalle_factura df
	inner join jafo.factura f 
		on df.factura_numero = f.numero 
	inner join jafo.usuario_domicilio ud
		on f.usuario_codigo = ud.usuario_codigo
		and ud.domicilio_codigo = (select top 1 ud1.domicilio_codigo from jafo.usuario_domicilio ud1 where ud.usuario_codigo = ud1.usuario_codigo)
	group by
		df.concepto_codigo,
		(jafo.getIdUbicacionPorIdDomicilio(ud.domicilio_codigo)),
		(jafo.obtener_id_tiempo(cast(f.fecha as datetime)))
commit tran
go

-------------------EJECUCIONES--------------------------------------------------------
EXEC JAFO.migracion_bi_dim_tiempo
EXEC jafo.migracion_bi_dim_subrubro
exec jafo.migracion_bi_dim_marca
exec jafo.migracion_dim_rubro
exec jafo.migracion_bi_hecho_publicacion
exec jafo.migracion_dim_ubicacion
exec jafo.migracion_bi_dim_rango_etario 
exec jafo.migracion_dim_rango_horario
exec jafo.migracion_hechos_ventas
exec jafo.migracion_dim_medio_pago
exec jafo.migracion_dim_cantidad_cuotas
exec jafo.migracion_hechos_pago
exec jafo.migracion_tipo_envio
exec jafo.migracion_hechos_envio
exec jafo.migracion_dim_concepto
exec jafo.migracion_hechos_facturacion

------ Eliminar procedimientos en el orden correcto
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_tiempo;
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_subrubro;
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_marca;
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_producto;
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_hecho_publicacion;
--DROP PROCEDURE IF EXISTS jafo.migracion_dim_ubicacion;
--DROP PROCEDURE IF EXISTS jafo.migracion_dim_rubro; 
--DROP PROCEDURE IF EXISTS jafo.migracion_bi_dim_rango_etario;
--DROP PROCEDURE IF EXISTS jafo.migracion_dim_rango_horario;
--DROP PROCEDURE IF EXISTS jafo.migracion_dim_cliente;
--DROP PROCEDURE IF EXISTS jafo.migracion_hechos_ventas;
--drop procedure if exists jafo.migracion_dim_medio_pago
--drop procedure if exists jafo.migracion_hechos_pago
--drop procedure if exists jafo.migracion_dim_cantidad_cuotas
--drop procedure if exists jafo.migracion_dim_concepto
--drop procedure if exists jafo.migracion_dim_factura
--drop procedure if exists jafo.migracion_hechos_facturacion
--drop procedure if exists jafo.migracion_tipo_envio
--drop procedure if exists jafo.migracion_hechos_envio

--print @@trancount
--rollback tran 