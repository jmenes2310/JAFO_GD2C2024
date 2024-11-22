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

create procedure jafo.migracion_bi_dim_producto
as 
begin 
	begin try
	begin transaction
		insert into jafo.bi_dim_producto
			select p.id, p.subrubro_codigo, p.marca_codigo
			from jafo.producto p

		commit transaction
	end try
	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar producto: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	
	end catch

end

go 

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




-----------------EJECUCIONES--------------------------------------------------------
EXEC JAFO.migracion_bi_dim_tiempo
EXEC jafo.migracion_bi_dim_subrubro
exec jafo.migracion_bi_dim_marca
exec jafo.migracion_bi_dim_producto
exec jafo.migracion_bi_hecho_publicacion



--borrar tablas
truncate table jafo.bi_hecho_publicacion
drop table jafo.bi_dim_producto
drop table jafo.bi_dim_marca
drop table jafo.bi_dim_subrubro
drop table jafo.bi_dim_tiempo


--drop procedure JAFO.migracion_bi_dim_tiempo
--drop procedure jafo.migracion_bi_dim_subrubro
--drop procedure jafo.migracion_bi_dim_marca
--drop procedure jafo.migracion_bi_dim_producto
--drop procedure jafo.migracion_bi_hecho_publicacion