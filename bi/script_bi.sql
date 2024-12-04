-----------------TABLAS--------------------------------------------------------
--tiempo
create procedure jafo.creacion_dim_tiempo
as
begin tran
	IF OBJECT_ID('jafo.bi_dim_tiempo', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_tiempo;
	create table jafo.bi_dim_tiempo(
		 id_tiempo int identity(1,1) primary key
		,anio int
		,cuatrimestre int
		,mes int
	)
commit tran
go

--subrubro
CREATE PROCEDURE jafo.creacion_dim_subrubro
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_subrubro', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_subrubro;
	create table jafo.bi_dim_subrubro(
		 codigo int primary key
		,nombre nvarchar(200)
	);
COMMIT TRAN;
GO
--marca
CREATE PROCEDURE jafo.creacion_dim_marca
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_marca', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_marca;
	create table jafo.bi_dim_marca (
		id_marca int primary key,
		descripcion nvarchar(200) 
	);
COMMIT TRAN;
GO

-- tabla rubro
CREATE PROCEDURE jafo.creacion_dim_rubro
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_rubro', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_rubro;
    create table jafo.bi_dim_rubro (
		idRubro int primary key,
		rubro nvarchar(100)
	);
COMMIT TRAN;
GO

--publicacion
CREATE PROCEDURE jafo.creacion_hecho_publicacion
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_hecho_publicacion', 'U') IS NOT NULL DROP TABLE jafo.bi_hecho_publicacion;
	create table jafo.bi_hecho_publicacion(
		 subrubro_id int
		,marca_id int
		,tiempo_id int
		,tiempo_vigente_promedio decimal(18,2)
		,stock_inicial_promedio decimal (18,2)
		primary key (subrubro_id,marca_id,tiempo_id)
		 FOREIGN KEY (subrubro_id) REFERENCES jafo.bi_dim_subrubro
		,FOREIGN KEY (marca_id) REFERENCES jafo.bi_dim_marca
		,FOREIGN KEY (tiempo_id) REFERENCES jafo.bi_dim_tiempo
	);
COMMIT TRAN;
GO


-- Tabla ubicacion
CREATE PROCEDURE jafo.creacion_dim_ubicacion
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_ubicacion', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_ubicacion;
	create table jafo.bi_dim_ubicacion (
		idUbicacion int identity (1,1) primary key,
		provincia nvarchar(100),
		localidad nvarchar(100)
	);
COMMIT TRAN;
GO


-- tabla rango etario
CREATE PROCEDURE jafo.creacion_dim_rango_etario
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_rango_etario', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_rango_etario;
	create table jafo.bi_dim_rango_etario (
		idRangoEtario INT IDENTITY(1,1) PRIMARY KEY,
		descripcion_rango VARCHAR(20)
	);
COMMIT TRAN;
GO


-- Tabla rango horario
CREATE PROCEDURE jafo.creacion_dim_rango_horario
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_rango_horario', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_rango_horario;
	create table jafo.bi_dim_rango_horario(
		idRangoHorario int identity (1,1) primary key,
		descripcion_rango nvarchar(100)
	);
COMMIT TRAN;
GO

-- Tabla de hechos ventas
CREATE PROCEDURE jafo.creacion_hechos_ventas
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_hechos_ventas', 'U') IS NOT NULL DROP TABLE jafo.bi_hechos_ventas;
	create table jafo.bi_hechos_ventas (
		idRangoHorario int,
		idRangoEtario int,
		idRubro int,
		idTiempo int,
		idUbicacionAlmacen int,
		idUbicacionCliente int,
		importe_total decimal(18,2),
		cantidad_ventas int
		primary key (idRangoHorario,idRangoEtario,idRubro,idTiempo,idUbicacionAlmacen,idUbicacionCliente)
		foreign key (idRangoHorario) references jafo.bi_dim_rango_horario(idRangoHorario),
		foreign key (idRangoEtario) references jafo.bi_dim_rango_etario(idRangoEtario),
		foreign key (idRubro) references jafo.bi_dim_rubro(idRubro),
		foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo),
		foreign key (idUbicacionAlmacen) references jafo.bi_dim_ubicacion(idUbicacion),
		foreign key (idUbicacionCliente) references jafo.bi_dim_ubicacion(idUbicacion)
	);
COMMIT TRAN;
GO

--medio de pago
CREATE PROCEDURE jafo.creacion_dim_medio_pago
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_medio_pago', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_medio_pago;
	create table jafo.bi_dim_medio_pago(
		 id_medio_pago int primary key
		,nombre nvarchar(200)
	);
COMMIT TRAN;
GO

-- cantidad de cuotas
CREATE PROCEDURE jafo.creacion_dim_cantidad_cuotas
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_cantidad_cuotas', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_cantidad_cuotas;
	create table jafo.bi_dim_cantidad_cuotas(
		 id_cantidad_cuotas int identity(1,1) primary key
		,cantidad decimal(18,0)
	)
COMMIT TRAN;
GO

-- hechos publicacion
CREATE PROCEDURE jafo.creacion_hechos_pagos
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_hechos_pagos', 'U') IS NOT NULL DROP TABLE jafo.bi_hechos_pagos;
	create table jafo.bi_hechos_pagos(
		 dim_ubicacion_id int 
		,dim_medio_pago_id int
		,dim_tiempo_id int
		,dim_cantidad_cuotas_id int
		,importe decimal(18,2)
		primary key (dim_ubicacion_id,dim_medio_pago_id,dim_tiempo_id,dim_cantidad_cuotas_id)
		 foreign key (dim_ubicacion_id) references jafo.bi_dim_ubicacion(idUbicacion)
		,foreign key (dim_medio_pago_id) references jafo.bi_dim_medio_pago(id_medio_pago)
		,foreign key (dim_tiempo_id) references jafo.bi_dim_tiempo(id_tiempo)
		,foreign key (dim_cantidad_cuotas_id) references jafo.bi_dim_cantidad_cuotas(id_cantidad_cuotas)
	);
COMMIT TRAN;
GO


CREATE PROCEDURE jafo.creacion_dim_tipo_envio
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_tipo_envio', 'U') IS NOT NULL DROP TABLE jafo.bi_tipo_envio;
	create table jafo.bi_tipo_envio(
		 idTipoEnvio int primary key
		,nombre nvarchar(200)
	);
COMMIT TRAN;
GO

CREATE PROCEDURE jafo.creacion_hechos_envios
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_hechos_envios', 'U') IS NOT NULL DROP TABLE jafo.bi_hechos_envios;
	create table jafo.bi_hechos_envios(
		 idUbicacionAlmacen int
		,idUbicacionCliente int
		,idTipoEnvio int
		,idTiempo int
		,cantidad_a_tiempo int
		,cantidad_total int
		,costo decimal(18,2)
		primary key (idUbicacionAlmacen, idUbicacionCliente, idTipoEnvio, idTiempo)
		 foreign key (idUbicacionAlmacen) references jafo.bi_dim_ubicacion(idUbicacion)
		,foreign key (idUbicacionCliente) references jafo.bi_dim_ubicacion(idUbicacion)
		,foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo)
	);
COMMIT TRAN;
GO

CREATE PROCEDURE jafo.creacion_dim_concepto
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_dim_concepto', 'U') IS NOT NULL DROP TABLE jafo.bi_dim_concepto;
	create table jafo.bi_dim_concepto(
		idConcepto int primary key,
		nombre_concepto nvarchar(100)
	);
COMMIT TRAN;
GO

CREATE PROCEDURE jafo.creacion_hechos_facturacion
AS
BEGIN TRAN
    IF OBJECT_ID('jafo.bi_hechos_facturacion', 'U') IS NOT NULL DROP TABLE jafo.bi_hechos_facturacion;
	create table jafo.bi_hechos_facturacion(
		idUbicacionVendedor int,
		idTiempo int,
		idConcepto int,
		total decimal(18,2),
		foreign key (idUbicacionVendedor) references jafo.bi_dim_ubicacion(idUbicacion),
		foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo),
		foreign key (idConcepto) references jafo.bi_dim_concepto(idConcepto),
	);
COMMIT TRAN;
GO

EXEC jafo.creacion_dim_tiempo;
EXEC jafo.creacion_dim_subrubro;
EXEC jafo.creacion_dim_marca;
EXEC jafo.creacion_dim_rubro;
EXEC jafo.creacion_hecho_publicacion;
EXEC jafo.creacion_dim_ubicacion;
EXEC jafo.creacion_dim_rango_etario;
EXEC jafo.creacion_dim_rango_horario;
EXEC jafo.creacion_hechos_ventas;
EXEC jafo.creacion_dim_medio_pago;
exec jafo.creacion_dim_cantidad_cuotas;
EXEC jafo.creacion_hechos_pagos;
EXEC jafo.creacion_dim_tipo_envio;
EXEC jafo.creacion_hechos_envios;
EXEC jafo.creacion_dim_concepto;
EXEC jafo.creacion_hechos_facturacion;
go

--drop procedure jafo.creacion_dim_tiempo;
--drop procedure jafo.creacion_dim_subrubro;
--drop procedure jafo.creacion_dim_marca;
--drop procedure jafo.creacion_dim_rubro;
--drop procedure jafo.creacion_hecho_publicacion;
--drop procedure jafo.creacion_dim_ubicacion;
--drop procedure jafo.creacion_dim_rango_etario;
--drop procedure jafo.creacion_dim_rango_horario;
--drop procedure jafo.creacion_hechos_ventas;
--drop procedure jafo.creacion_dim_medio_pago;
--drop procedure jafo.creacion_dim_cantidad_cuotas;
--drop procedure jafo.creacion_hechos_pagos;
--drop procedure jafo.creacion_dim_tipo_envio;
--drop procedure jafo.creacion_hechos_envios;
--drop procedure jafo.creacion_dim_concepto;
--drop procedure jafo.creacion_hechos_facturacion;

---- Eliminar tablas de hechos primero, ya que dependen de dimensiones
--DROP TABLE IF EXISTS jafo.bi_hechos_ventas;
--DROP TABLE IF EXISTS jafo.bi_hecho_publicacion;
--drop table if exists jafo.bi_hechos_pagos;
--drop table if exists jafo.bi_hechos_facturacion;
--drop table if exists jafo.bi_hechos_envios;
------ Eliminar dimensiones relacionadas después
--DROP TABLE IF EXISTS jafo.bi_dim_rango_horario;
--DROP TABLE IF EXISTS jafo.bi_dim_rango_etario;
--DROP TABLE IF EXISTS jafo.bi_dim_ubicacion;
--DROP TABLE IF EXISTS jafo.bi_dim_marca;
--DROP TABLE IF EXISTS jafo.bi_dim_subrubro;
--DROP TABLE IF EXISTS jafo.bi_dim_rubro;
--DROP TABLE IF EXISTS jafo.bi_dim_tiempo;
--drop table if exists jafo.bi_dim_medio_pago
--drop table if exists jafo.bi_dim_cantidad_cuotas
--drop table if exists jafo.bi_dim_concepto;
--drop table if exists jafo.bi_dim_factura;
--drop table if exists jafo.bi_tipo_envio;

-----------------FUCIONES--------------------------------------------------------
IF OBJECT_ID('jafo.obtener_id_tiempo', 'FN') IS NOT NULL
    DROP FUNCTION jafo.obtener_id_tiempo;
go

CREATE FUNCTION jafo.obtener_id_tiempo (@fecha datetime) 
RETURNS varchar(10)								 
AS
BEGIN
	DECLARE @id int;
	
	SELECT @id = id_tiempo
    FROM jafo.bi_dim_tiempo
    WHERE anio = YEAR(@fecha)
      AND mes = MONTH(@fecha)
      AND cuatrimestre = CASE 
                               WHEN MONTH(@fecha) BETWEEN 1 AND 4 THEN 1
                               WHEN MONTH(@fecha) BETWEEN 5 AND 8 THEN 2
                               WHEN MONTH(@fecha) BETWEEN 9 AND 12 THEN 3
                           END;

    RETURN @id;
END

GO

IF OBJECT_ID('jafo.obtener_stock_inicial', 'FN') IS NOT NULL
    DROP FUNCTION jafo.obtener_stock_inicial;
go

create function jafo.obtener_stock_inicial (@publicacion_codigo decimal(18,0))
returns decimal(18,0)
as
begin
    declare @stock_vendido decimal (18,0)
    declare @stock_actual decimal(18,0)

    set @stock_vendido = (
        select sum(dv.cantidad)
        from publicacion p
        inner join jafo.detalle_venta dv
            on dv.publicacion_codigo = @publicacion_codigo
        group by dv.publicacion_codigo
    )

    set @stock_actual = (select p.stock from publicacion p where p.codigo = @publicacion_codigo)


    return @stock_vendido + @stock_actual
end
go

IF OBJECT_ID('jafo.getAgeRange', 'FN') IS NOT NULL
    DROP FUNCTION jafo.getAgeRange;
go

-- Recibe una edad int y devuelve el id del rango de esa edad
create function jafo.getAgeRange(@age int)
returns int
as
begin
	declare @id int
	if (@age < 24)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('< 25'))
	else if (@age < 35)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('25-35'))
	else if (@age < 50)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('35-50'))
	else
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('> 50'))
	return @id
end
go

-- Recibe una fecha datetime y devuelve el id del rango horario asociado
IF OBJECT_ID('jafo.getRangoHorarioPorFecha', 'FN') IS NOT NULL
    DROP FUNCTION jafo.getRangoHorarioPorFecha;
go

create function jafo.getRangoHorarioPorFecha(@fechaHora datetime)
returns int
as
begin
	declare @id int
	if(DATEPART(HOUR,@fechaHora) between 0 and 5) 
		set @id = (select dim.idRangoHorario from jafo.bi_dim_rango_horario dim where dim.descripcion_rango = ('00:00-06:00'))
	else if(DATEPART(HOUR,@fechaHora) between 6 and 11) 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('06:00-12:00'))
	else if(DATEPART(HOUR,@fechaHora) between 12 and 17) 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('12:00-18:00'))
	else 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('18:00-24:00'))
	return @id
end
go

IF OBJECT_ID('jafo.getIdUbicacionPorIdDomicilio', 'FN') IS NOT NULL
    DROP FUNCTION jafo.getIdUbicacionPorIdDomicilio;
go

go
create function jafo.getIdUbicacionPorIdDomicilio(@codigo_domicilio int)
returns int 
as
begin 
	declare @idUbicacion int
	set @idUbicacion = (
		select ubi.idUbicacion
		from jafo.domicilio domi
		inner join jafo.localidad loc
			on loc.codigo = domi.localidad_codigo
		inner join jafo.provincia prov
			on loc.provincia_codigo = prov.codigo
		inner join jafo.bi_dim_ubicacion ubi
			on ubi.localidad = loc.nombre
			and ubi.provincia = prov.nombre
		where domi.codigo = @codigo_domicilio
	)
	return @idUbicacion
end
go

------------------------------ INDICES -----------------------------
-- Para hechos publicacion
create index idx_publicacion_producto_fecha_codigo ON jafo.publicacion (producto_id, fecha_inicio, codigo);

create index idx_producto_id_subrubro_marca ON jafo.producto (id, subrubro_codigo, marca_codigo);

-- para hechos ventas
create index idx_venta_codigo_cliente_fecha ON jafo.venta (codigo, cliente_codigo, fecha, total);
create index idx_envio_venta_fecha_domicilio ON jafo.envio (venta_codigo, fecha_entrega, domicilio_codigo);
create index idx_cliente_codigo_fecha_nacimiento ON jafo.cliente (codigo, fecha_nacimiento);
create index idx_detalle_venta_codigo_publicacion ON jafo.detalle_venta (venta_codigo, publicacion_codigo);
create index idx_subrubro_codigo_rubro ON jafo.subrubro (codigo, rubro_codigo);

create index idx_domicilio_codigo_localidad ON jafo.domicilio (codigo, localidad_codigo);
create index idx_localidad_codigo_provincia_nombre ON jafo.localidad (codigo, provincia_codigo, nombre);
create index idx_provincia_codigo_nombre ON jafo.provincia (codigo, nombre);
create index idx_ubicacion_localidad_provincia ON jafo.bi_dim_ubicacion (localidad, provincia);

-- para hechos pagos
CREATE INDEX idx_pago_medio_pago_fecha_cuotas ON jafo.pago (medio_pago_codigo, fecha, cantidad_cuotas);

CREATE INDEX idx_medio_pago_id ON jafo.bi_dim_medio_pago (id_medio_pago);

CREATE INDEX idx_cantidad_cuotas_cantidad ON jafo.bi_dim_cantidad_cuotas (cantidad);

CREATE INDEX idx_tiempo_fecha ON jafo.bi_dim_tiempo (id_tiempo);


--DROP INDEX jafo.idx_publicacion_producto_fecha_codigo;

--DROP INDEX jafo.idx_producto_id_subrubro_marca;

--DROP INDEX jafo.venta.idx_venta_codigo_cliente_fecha;

--DROP INDEX jafo.envio.idx_envio_venta_fecha_domicilio;

--DROP INDEX jafo.cliente.idx_cliente_codigo_fecha_nacimiento;

--DROP INDEX jafo.detalle_venta.idx_detalle_venta_codigo_publicacion;

--DROP INDEX jafo.subrubro.idx_subrubro_codigo_rubro;

--DROP INDEX jafo.domicilio.idx_domicilio_codigo_localidad;

--DROP INDEX jafo.localidad.idx_localidad_codigo_provincia_nombre;

--DROP INDEX jafo.provincia.idx_provincia_codigo_nombre;

--DROP INDEX jafo.bi_dim_ubicacion.idx_ubicacion_localidad_provincia;

--DROP INDEX jafo.pago.idx_pago_medio_pago_fecha_cuotas;

--DROP INDEX jafo.bi_dim_medio_pago.idx_medio_pago_id;

--DROP INDEX jafo.bi_dim_cantidad_cuotas.idx_cantidad_cuotas_cantidad;

--DROP INDEX jafo.bi_dim_tiempo.idx_tiempo_fecha;

-----------------MIGRACIONES--------------------------------------------------------
--tiempo
IF OBJECT_ID('jafo.migracion_bi_dim_tiempo', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_bi_dim_tiempo;
GO

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
IF OBJECT_ID('jafo.migracion_bi_dim_subrubro', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_bi_dim_subrubro;
GO

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
IF OBJECT_ID('jafo.migracion_bi_dim_marca', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_bi_dim_marca;
GO

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
IF OBJECT_ID('jafo.migracion_bi_hecho_publicacion', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_bi_hecho_publicacion;
GO

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

IF OBJECT_ID('jafo.migracion_dim_ubicacion', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_dim_ubicacion;
GO

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

IF OBJECT_ID('jafo.migracion_dim_rubro', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_dim_rubro;
GO

create procedure jafo.migracion_dim_rubro
as
begin tran
	insert into jafo.bi_dim_rubro
	select rb.codigo, rb.descripcion
	from jafo.rubro rb
commit
go

IF OBJECT_ID('jafo.migracion_bi_dim_rango_etario', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_bi_dim_rango_etario;
GO

create procedure jafo.migracion_bi_dim_rango_etario 
as
begin transaction
	insert into jafo.bi_dim_rango_etario (descripcion_rango)
	values ('< 25'), ('25-35'), ('35-50'), ('> 50');
commit
go

IF OBJECT_ID('jafo.migracion_dim_rango_horario', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_dim_rango_horario;
GO

create procedure jafo.migracion_dim_rango_horario
as
begin transaction
	insert into jafo.bi_dim_rango_horario 
	values ('00:00-06:00'), ('06:00-12:00'), ('12:00-18:00'), ('18:00-24:00');
commit
go

IF OBJECT_ID('jafo.migracion_hechos_ventas', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_hechos_ventas;
GO

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
IF OBJECT_ID('jafo.migracion_dim_medio_pago', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_dim_medio_pago;
GO

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
IF OBJECT_ID('jafo.migracion_hechos_pago', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_hechos_pago;
GO

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
IF OBJECT_ID('jafo.migracion_tipo_envio', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_tipo_envio;
GO

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
IF OBJECT_ID('jafo.migracion_hechos_envio', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_hechos_envio;
GO

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
IF OBJECT_ID('jafo.migracion_dim_concepto', 'P') IS NOT NULL
    DROP PROCEDURE jafo.migracion_dim_concepto;
GO

create procedure jafo.migracion_dim_concepto 
as
begin tran
	insert into jafo.bi_dim_concepto (idConcepto, nombre_concepto)
	select conc.codigo, conc.nombre from jafo.concepto conc
commit tran 
go

-- hechos facturacion 
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
go

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

create VIEW jafo.view_promedio_stock_por_marca AS
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
    isnull(SUM(hv.cantidad_ventas),0) AS CantidadVentas
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
	IIF(SUM(he.cantidad_a_tiempo) = 0, 0, CAST(100.0 * SUM(he.cantidad_total) / SUM(he.cantidad_a_tiempo) AS DECIMAL(18, 2))) AS PorcentajeCumplimiento
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
SELECT TOP 5 du.localidad, SUM(he.costo) / sum(he.cantidad_total) AS costo_unitario
FROM jafo.bi_hechos_envios he
INNER JOIN jafo.bi_dim_ubicacion du 
	ON he.idUbicacionCliente = du.idUbicacion
GROUP BY du.localidad, he.costo
ORDER BY SUM(he.costo) / SUM(he.cantidad_total) DESC
GO

--9. Porcentaje de facturación por concepto para cada mes de cada año. Se calcula
--en función del total del concepto sobre el total del período.
IF OBJECT_ID('jafo.porcentaje_facturacion_concepto', 'V') IS NOT NULL
    DROP VIEW jafo.porcentaje_facturacion_concepto;
GO

create view jafo.porcentaje_facturacion_concepto as
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
FROM jafo.bi_hechos_facturacion hf
INNER JOIN 
    jafo.bi_dim_tiempo dt ON hf.idTiempo = dt.id_tiempo
INNER JOIN 
    jafo.bi_dim_ubicacion ub ON hf.idUbicacionVendedor = ub.idUbicacion
GROUP BY 
	ub.provincia,
    dt.cuatrimestre,
	dt.anio
GO
