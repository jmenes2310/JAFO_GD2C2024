--DURACION APROXIMADA DE MIGRACION COMPLETA: 3:20 (tres minutos y veinte segundos)

-- Crear esquema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'jafo')
	BEGIN
        EXEC('CREATE SCHEMA jafo');
	END


IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[jafo].[CrearTablas]') AND type = N'P')
	DROP PROCEDURE jafo.CrearTablas
go

CREATE PROCEDURE jafo.crear_tabla_rubro
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.rubro', 'U') IS NOT NULL DROP TABLE jafo.rubro;
        CREATE TABLE jafo.rubro (
            codigo INT IDENTITY PRIMARY KEY,
            descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
        );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_subrubro
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.subrubro', 'U') IS NOT NULL DROP TABLE jafo.subrubro;
        CREATE TABLE jafo.subrubro (
            codigo INT IDENTITY PRIMARY KEY,
            descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
            rubro_codigo INT,
            FOREIGN KEY (rubro_codigo) REFERENCES jafo.rubro(codigo)
        );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_marca
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.marca', 'U') IS NOT NULL DROP TABLE jafo.marca;
        CREATE TABLE jafo.marca (
            codigo INT IDENTITY PRIMARY KEY,
            nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
        );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_modelo
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.modelo', 'U') IS NOT NULL DROP TABLE jafo.modelo;
        CREATE TABLE jafo.modelo (
            codigo DECIMAL(18,0) PRIMARY KEY,
            descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
        );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_producto
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.producto', 'U') IS NOT NULL DROP TABLE jafo.producto;
	CREATE TABLE jafo.producto (
		id INT IDENTITY(1,1) PRIMARY KEY,
		codigo nvarchar(100),
		descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
		subrubro_codigo int,
		modelo_codigo DECIMAL(18,0),
		marca_codigo INT,
		FOREIGN KEY (subrubro_codigo) REFERENCES jafo.subrubro(codigo),
		FOREIGN KEY (modelo_codigo) REFERENCES jafo.modelo(codigo),
		FOREIGN KEY (marca_codigo) REFERENCES jafo.marca(codigo)
	);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_tipo_envio
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.tipo_envio', 'U') IS NOT NULL DROP TABLE jafo.tipo_envio;
		CREATE TABLE jafo.tipo_envio(
			codigo INT IDENTITY PRIMARY KEY,
			nombre NVARCHAR(100) NOT NULL
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_tipo_medio_pago
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.tipo_medio_pago', 'U') IS NOT NULL DROP TABLE jafo.tipo_medio_pago;
		CREATE TABLE jafo.tipo_medio_pago(
			codigo DECIMAL(18,0) IDENTITY PRIMARY KEY,
			nombre NVARCHAR(100) NOT NULL
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_concepto
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.concepto', 'U') IS NOT NULL DROP TABLE jafo.concepto;
		CREATE TABLE jafo.concepto(
			codigo INT IDENTITY PRIMARY KEY,
			nombre NVARCHAR(100) NOT NULL
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_usuario
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.usuario', 'U') IS NOT NULL DROP TABLE jafo.usuario;
		CREATE TABLE jafo.usuario (
			codigo INT IDENTITY PRIMARY KEY,
			nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			pass NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			fecha_creacion DATE NOT NULL
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_provincia
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.provincia', 'U') IS NOT NULL DROP TABLE jafo.provincia;
		CREATE TABLE jafo.provincia (
			codigo INT IDENTITY (1, 1) PRIMARY KEY,
			nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
		);    
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_localidad
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.localidad', 'U') IS NOT NULL DROP TABLE jafo.localidad;
		CREATE TABLE jafo.localidad (
			codigo INT IDENTITY (1, 1) PRIMARY KEY,
			nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			provincia_codigo INT,
			FOREIGN KEY (provincia_codigo) REFERENCES jafo.provincia(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_domicilio
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.domicilio', 'U') IS NOT NULL DROP TABLE jafo.domicilio;
		CREATE TABLE jafo.domicilio (
			codigo INT IDENTITY (1, 1) PRIMARY KEY,
			calle NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			numero_calle DECIMAL(18,0) NOT NULL,
			piso DECIMAL(18,0) ,
			depto NVARCHAR(100) COLLATE Modern_Spanish_CI_AS ,
			cp NVARCHAR(100) COLLATE Modern_Spanish_CI_AS ,
			localidad_codigo INT,	
			FOREIGN KEY (localidad_codigo) REFERENCES jafo.localidad(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_usuario_domicilio
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.usuario_domicilio', 'U') IS NOT NULL DROP TABLE jafo.usuario_domicilio;
		CREATE TABLE jafo.usuario_domicilio (
			usuario_codigo INT,
			domicilio_codigo INT,
			PRIMARY KEY (usuario_codigo, domicilio_codigo),
			FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo),
			FOREIGN KEY (domicilio_codigo) REFERENCES jafo.domicilio(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_cliente
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.cliente', 'U') IS NOT NULL DROP TABLE jafo.cliente;
		CREATE TABLE jafo.cliente (
			codigo INT IDENTITY PRIMARY KEY,
			usuario_codigo INT,
			nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			apellido NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			fecha_nacimiento DATE NOT NULL,
			mail NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			dni DECIMAL(18,0) NOT NULL,
			FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_vendedor
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.vendedor', 'U') IS NOT NULL DROP TABLE jafo.vendedor;
		CREATE TABLE jafo.vendedor (
			codigo INT IDENTITY PRIMARY KEY,
			razon_social NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			cuit NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			mail NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
			usuario_codigo INT,
			FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_almacen
AS
BEGIN
    BEGIN TRY
		IF OBJECT_ID('jafo.almacen', 'U') IS NOT NULL DROP TABLE jafo.almacen;
		CREATE TABLE jafo.almacen (
			codigo DECIMAL(18,0),
			domicilio_codigo INT,
			 costo_dia_alquiler DECIMAL(18,2),
			PRIMARY KEY (codigo, domicilio_codigo),
			FOREIGN KEY (domicilio_codigo) REFERENCES jafo.domicilio(codigo)
		);     
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_publicacion
AS
BEGIN
    BEGIN TRY
         IF OBJECT_ID('jafo.publicacion', 'U') IS NOT NULL DROP TABLE jafo.publicacion;
		CREATE TABLE jafo.publicacion (
			codigo DECIMAL(18,0) PRIMARY KEY,
			vendedor_codigo INT,
			descripcion NVARCHAR(100),
			stock DECIMAL(18,0) NOT NULL,
			producto_id INT NOT NULL,
			fecha_inicio DATE NOT NULL,
			fecha_fin DATE NOT NULL,
			precio DECIMAL(18,2) NOT NULL,
			costo DECIMAL(18,2),
			porcentaje_venta DECIMAL(18,2),
			almacen_codigo DECIMAL(18,0),
			almacen_domicilio_codigo INT
			FOREIGN KEY (vendedor_codigo) REFERENCES jafo.vendedor(codigo),
			FOREIGN KEY (almacen_codigo, almacen_domicilio_codigo) REFERENCES jafo.almacen(codigo, domicilio_codigo),
			FOREIGN KEY (producto_id) REFERENCES jafo.producto(id)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_venta
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.venta', 'U') IS NOT NULL DROP TABLE jafo.venta;
		CREATE TABLE jafo.venta (
			codigo DECIMAL(18,0) PRIMARY KEY,
			cliente_codigo INT,
			fecha DATE NOT NULL,
			total DECIMAL(18,2) NOT NULL,
			FOREIGN KEY (cliente_codigo) REFERENCES jafo.cliente(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_envio
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.envio', 'U') IS NOT NULL DROP TABLE jafo.envio;
		CREATE TABLE jafo.envio (
			id INT IDENTITY PRIMARY KEY,
			venta_codigo DECIMAL(18,0),
			domicilio_codigo INT,
			fecha_programada DATETIME,
			horario_inicio DECIMAL(18,0),
			hora_fin_inicio DECIMAL(18,0),
			costo DECIMAL(18,2),
			fecha_entrega DATETIME,
			tipo_envio_codigo INT,
			FOREIGN KEY (venta_codigo) REFERENCES jafo.venta(codigo),
			FOREIGN KEY (domicilio_codigo) REFERENCES jafo.domicilio(codigo),
			FOREIGN KEY (tipo_envio_codigo) REFERENCES jafo.tipo_envio(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_medio_pago
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.medio_pago', 'U') IS NOT NULL DROP TABLE jafo.medio_pago;
		CREATE TABLE jafo.medio_pago (
			codigo DECIMAL(18,0) IDENTITY PRIMARY KEY,
			nombre NVARCHAR(100) NOT NULL,
			tipo_medio_pago_codigo DECIMAL(18,0),
			FOREIGN KEY (tipo_medio_pago_codigo) REFERENCES jafo.tipo_medio_pago(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_pago
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.pago', 'U') IS NOT NULL DROP TABLE jafo.pago;
		CREATE TABLE jafo.pago (
			codigo INT IDENTITY PRIMARY KEY,
			venta_codigo DECIMAL(18,0) NOT NULL,
			importe DECIMAL(18,2) NOT NULL,
			fecha DATE NOT NULL,
			medio_pago_codigo DECIMAL(18,0),
			numero_tarjeta NVARCHAR(100),
			fecha_vencimiento_tarjeta DATE,
			cantidad_cuotas DECIMAL(18,0),
			FOREIGN KEY (venta_codigo) REFERENCES jafo.venta(codigo),
			FOREIGN KEY (medio_pago_codigo) REFERENCES jafo.medio_pago(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE jafo.crear_tabla_detalle_venta
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.detalle_venta', 'U') IS NOT NULL DROP TABLE jafo.detalle_venta;
		CREATE TABLE jafo.detalle_venta (
			venta_codigo DECIMAL(18,0),
			publicacion_codigo DECIMAL(18,0),
			cantidad INT,
			subtotal DECIMAL(18,2) NOT NULL,
			precio DECIMAL(18,2) NOT NULL,
			PRIMARY KEY (venta_codigo, publicacion_codigo),
			FOREIGN KEY (venta_codigo) REFERENCES jafo.venta(codigo),
			FOREIGN KEY (publicacion_codigo) REFERENCES jafo.publicacion(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
CREATE PROCEDURE jafo.crear_tabla_factura
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.factura', 'U') IS NOT NULL DROP TABLE jafo.factura;
		CREATE TABLE jafo.factura (
			numero DECIMAL(18,0),
			fecha DATE,
			total DECIMAL(18,2),
			usuario_codigo INT,
			PRIMARY KEY (numero),
			FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
CREATE PROCEDURE jafo.crear_tabla_detalle_factura
AS
BEGIN
    BEGIN TRY
        IF OBJECT_ID('jafo.detalle_factura', 'U') IS NOT NULL DROP TABLE jafo.detalle_factura;
		CREATE TABLE jafo.detalle_factura (
			publicacion_codigo DECIMAL(18,0),
			factura_numero decimal(18,0),
			concepto_codigo INT NOT NULL,
			cantidad DECIMAL(18,0) NOT NULL,
			subtotal DECIMAL(18,2),
			PRIMARY KEY (concepto_codigo, publicacion_codigo, factura_numero),
			FOREIGN KEY (publicacion_codigo) REFERENCES jafo.publicacion(codigo),
			FOREIGN KEY (factura_numero) REFERENCES jafo.factura(numero),
			FOREIGN KEY (concepto_codigo) REFERENCES jafo.concepto(codigo)
		);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Migracion
-- Rubro
create procedure jafo.migracion_rubro
as 
begin
	begin try
	begin transaction
		insert into jafo.rubro (descripcion)
			select distinct PRODUCTO_RUBRO_DESCRIPCION 
			from gd_esquema.Maestra 
			where PRODUCTO_RUBRO_DESCRIPCION is not null

		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Rubros: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Subrubro 
create procedure jafo.migracion_subrubro
as 
begin
	begin try
	begin transaction
		insert into jafo.subrubro (descripcion, rubro_codigo)
			select distinct PRODUCTO_SUB_RUBRO, jafo.rubro.codigo
			from gd_esquema.Maestra
			LEFT JOIN jafo.rubro on PRODUCTO_RUBRO_DESCRIPCION = jafo.rubro.descripcion
			where PRODUCTO_SUB_RUBRO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar SubRubro: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go
--Provincia
create procedure jafo.migracion_provincia
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.provincia (nombre)
			SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_PROVINCIA
			FROM gd_esquema.Maestra M
			WHERE M.CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Provincia: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Localidad
create procedure jafo.migracion_localidad
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.localidad (nombre, provincia_codigo)
		(
			SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_LOCALIDAD, jafo.provincia.codigo 
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.provincia ON M.CLI_USUARIO_DOMICILIO_PROVINCIA = jafo.provincia.nombre

			UNION

			SELECT DISTINCT M.VEN_USUARIO_DOMICILIO_LOCALIDAD, jafo.provincia.codigo 
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.provincia ON M.VEN_USUARIO_DOMICILIO_PROVINCIA = jafo.provincia.nombre

			UNION 

			SELECT DISTINCT M.ALMACEN_Localidad, jafo.provincia.codigo 
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.provincia ON M.ALMACEN_PROVINCIA = jafo.provincia.nombre
		)
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Localidad: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Domicilio
create procedure jafo.migracion_domicilio
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.domicilio (calle, numero_calle, piso, depto, cp ,localidad_codigo)
			(
				SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_CALLE,
					   M.CLI_USUARIO_DOMICILIO_NRO_CALLE,
					   M.CLI_USUARIO_DOMICILIO_PISO,
					   M.CLI_USUARIO_DOMICILIO_DEPTO,
					   M.CLI_USUARIO_DOMICILIO_CP,
					   jafo.localidad.codigo
				FROM gd_esquema.Maestra M
				INNER JOIN jafo.localidad ON M.CLI_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre

			UNION

			SELECT DISTINCT M.VEN_USUARIO_DOMICILIO_CALLE,
				   M.VEN_USUARIO_DOMICILIO_NRO_CALLE,
				   M.VEN_USUARIO_DOMICILIO_PISO,
				   M.VEN_USUARIO_DOMICILIO_DEPTO,
				   M.VEN_USUARIO_DOMICILIO_CP,
				   jafo.localidad.codigo
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.localidad ON M.VEN_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre

			UNION 

			SELECT DISTINCT M.ALMACEN_CALLE,
				   M.ALMACEN_NRO_CALLE,
				   null,
				   null,
				   null,
				   jafo.localidad.codigo
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.localidad ON M.ALMACEN_Localidad = jafo.localidad.nombre
			)
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Domicilio: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Almacen
create procedure jafo.migracion_almacen
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.almacen (codigo, domicilio_codigo, costo_dia_alquiler)
			SELECT DISTINCT M.ALMACEN_CODIGO, 
						jafo.domicilio.codigo domicilio_codigo,
						M.ALMACEN_COSTO_DIA_AL
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.domicilio  ON calle = M.ALMACEN_CALLE and numero_calle = M.ALMACEN_NRO_CALLE
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Almacen: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Marca
create procedure jafo.migracion_marca
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.marca (nombre)
			SELECT DISTINCT M.PRODUCTO_MARCA
			FROM gd_esquema.Maestra M
			WHERE M.PRODUCTO_MARCA IS NOT NULL;
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Marca: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Modelo
create procedure jafo.migracion_modelo
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.modelo (codigo, descripcion)
			SELECT DISTINCT M.PRODUCTO_MOD_CODIGO, 
							M.PRODUCTO_MOD_DESCRIPCION
			FROM gd_esquema.Maestra M
			WHERE M.PRODUCTO_MOD_CODIGO IS NOT NULL
			  AND M.PRODUCTO_MOD_DESCRIPCION IS NOT NULL
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Modelo: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Usuario
create procedure jafo.migracion_usuario
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.usuario (nombre, pass, fecha_creacion)
			(
			SELECT DISTINCT M.VEN_USUARIO_NOMBRE, 
							M.VEN_USUARIO_PASS, 
							M.VEN_USUARIO_FECHA_CREACION
			FROM gd_esquema.Maestra M
			WHERE M.VEN_USUARIO_NOMBRE IS NOT NULL
			  AND M.VEN_USUARIO_PASS IS NOT NULL
			  AND M.VEN_USUARIO_FECHA_CREACION IS NOT NULL
			)
			UNION 
			(
			SELECT DISTINCT M.CLI_USUARIO_NOMBRE, 
							M.CLI_USUARIO_PASS, 
							M.CLI_USUARIO_FECHA_CREACION
			FROM gd_esquema.Maestra M
			WHERE M.CLI_USUARIO_NOMBRE IS NOT NULL
			  AND M.CLI_USUARIO_PASS IS NOT NULL
			  AND M.CLI_USUARIO_FECHA_CREACION IS NOT NULL
			)
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Usuario: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Cliente
create procedure jafo.migracion_cliente
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.cliente (usuario_codigo, nombre, apellido, fecha_nacimiento, mail, dni)
			SELECT DISTINCT U.codigo, 
							M.CLIENTE_NOMBRE, 
							M.CLIENTE_APELLIDO, 
							M.CLIENTE_FECHA_NAC, 
							M.CLIENTE_MAIL, 
							M.CLIENTE_DNI
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.usuario U
				ON M.CLI_USUARIO_NOMBRE = U.nombre
				AND M.CLI_USUARIO_PASS = U.pass
				AND M.CLI_USUARIO_FECHA_CREACION = U.fecha_creacion
			WHERE M.CLIENTE_NOMBRE IS NOT NULL
			  AND M.CLIENTE_APELLIDO IS NOT NULL
			  AND M.CLIENTE_FECHA_NAC IS NOT NULL
			  AND M.CLIENTE_MAIL IS NOT NULL
			  AND M.CLIENTE_DNI IS NOT NULL
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Cliente: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Vendedor
create procedure jafo.migracion_vendedor
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.vendedor (usuario_codigo, razon_social, cuit, mail)
			SELECT DISTINCT U.codigo, 
							M.VENDEDOR_RAZON_SOCIAL, 
							M.VENDEDOR_CUIT, 
							M.VENDEDOR_MAIL
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.usuario U
				ON M.VEN_USUARIO_NOMBRE = U.nombre
				AND M.VEN_USUARIO_PASS = U.pass
				AND M.VEN_USUARIO_FECHA_CREACION = U.fecha_creacion
			WHERE M.VENDEDOR_RAZON_SOCIAL IS NOT NULL
			  AND M.VENDEDOR_CUIT IS NOT NULL
			  AND M.VENDEDOR_MAIL IS NOT NULL
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Vendedor: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Usuario_domicilio
create procedure jafo.migracion_usuario_domicilio
as 
begin
	begin try
	begin transaction
		CREATE INDEX idx_domicilio ON jafo.domicilio (calle, numero_calle, cp) --para mejorar performance

		INSERT INTO jafo.usuario_domicilio (usuario_codigo, domicilio_codigo)
			(
			SELECT distinct u.codigo AS usuario_codigo, d.codigo AS domicilio_codigo
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.usuario u
					ON (u.nombre = M.VEN_USUARIO_NOMBRE and u.pass = M.VEN_USUARIO_PASS and u.fecha_creacion = VEN_USUARIO_FECHA_CREACION)
			left JOIN jafo.domicilio d
					ON (d.calle = M.VEN_USUARIO_DOMICILIO_CALLE AND d.numero_calle = M.VEN_USUARIO_DOMICILIO_NRO_CALLE AND d.cp = M.VEN_USUARIO_DOMICILIO_CP )

			union

			SELECT distinct u.codigo AS usuario_codigo, d.codigo AS domicilio_codigo
			FROM gd_esquema.Maestra M
			INNER JOIN jafo.usuario u
					ON (u.nombre = M.CLI_USUARIO_NOMBRE and u.pass = M.CLI_USUARIO_PASS and u.fecha_creacion = CLI_USUARIO_FECHA_CREACION)
			left JOIN jafo.domicilio d
					ON (d.calle = M.CLI_USUARIO_DOMICILIO_CALLE AND d.numero_calle = M.CLI_USUARIO_DOMICILIO_NRO_CALLE AND d.cp = M.CLI_USUARIO_DOMICILIO_CP )
	
			)

		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Usuario_Domicilio: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Producto
create procedure jafo.migracion_producto
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.producto (codigo, descripcion, subrubro_codigo, modelo_codigo, marca_codigo)
			select distinct
				PRODUCTO_CODIGO
				,PRODUCTO_DESCRIPCION 
				,subrubro.codigo subrubro_codigo
				,modelo.codigo modelo_codigo
				,marca.codigo marca_codigo
			from gd_esquema.Maestra
			inner join jafo.rubro rubro on PRODUCTO_RUBRO_DESCRIPCION = rubro.descripcion
			inner join jafo.subrubro subrubro on PRODUCTO_SUB_RUBRO = subrubro.descripcion and subrubro.rubro_codigo = rubro.codigo
			inner join jafo.modelo modelo on PRODUCTO_MOD_CODIGO = modelo.codigo
			inner join jafo.marca marca on PRODUCTO_MARCA = marca.nombre
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Producto: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--tipo_medio_pago 
create procedure jafo.migracion_tipo_medio_pago
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.tipo_medio_pago(nombre)
			SELECT	DISTINCT pago_tipo_medio_pago 
			from gd_esquema.Maestra
			where PAGO_TIPO_MEDIO_PAGO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Tipo_Medio_Pago: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--medio_pago
create procedure jafo.migracion_medio_pago
as 
begin
	begin try
	begin transaction
		insert into jafo.medio_pago(nombre, tipo_medio_pago_codigo)
			select distinct PAGO_MEDIO_PAGO, tmp.codigo
			from gd_esquema.Maestra
			inner join jafo.tipo_medio_pago tmp on PAGO_TIPO_MEDIO_PAGO = tmp.nombre
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Medio_Pago: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--venta
create procedure jafo.migracion_venta
as 
begin
	begin try
	begin transaction
		insert into jafo.venta (codigo, cliente_codigo, fecha, total)
			select distinct VENTA_CODIGO, c.codigo, VENTA_FECHA, VENTA_TOTAL
			from gd_esquema.Maestra
			inner join jafo.cliente c 
				on c.nombre = CLIENTE_NOMBRE 
				and c.apellido =  CLIENTE_APELLIDO
				and c.fecha_nacimiento = CLIENTE_FECHA_NAC
				and c.mail = CLIENTE_MAIL
				and c.dni = CLIENTE_DNI
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Venta: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--pago
create procedure jafo.migracion_pago
as 
begin
	begin try
	begin transaction
		insert into jafo.pago (venta_codigo, importe, fecha, medio_pago_codigo, numero_tarjeta, fecha_vencimiento_tarjeta, cantidad_cuotas)
			select distinct venta.codigo, PAGO_IMPORTE, PAGO_FECHA, medio_pago.codigo, PAGO_NRO_TARJETA, PAGO_FECHA_VENC_TARJETA, PAGO_CANT_CUOTAS
			from gd_esquema.Maestra
			inner join jafo.venta venta on venta.codigo = VENTA_CODIGO
			inner join jafo.medio_pago medio_pago on medio_pago.nombre = PAGO_MEDIO_PAGO
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Pago: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--tipo envio
create procedure jafo.migracion_tipo_envio
as 
begin
	begin try
	begin transaction
		insert into jafo.tipo_envio(nombre)
			select distinct envio_tipo
			from gd_esquema.Maestra
			where envio_tipo is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Tipo_Envio: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--envio
create procedure jafo.migracion_envio
as 
begin
	begin try
	begin transaction
		insert into jafo.envio(venta_codigo, domicilio_codigo, fecha_programada, horario_inicio, hora_fin_inicio, costo, fecha_entrega, tipo_envio_codigo)
			select distinct venta_codigo, domicilio.codigo, ENVIO_FECHA_PROGAMADA, ENVIO_HORA_INICIO, ENVIO_HORA_FIN_INICIO, ENVIO_COSTO, ENVIO_FECHA_ENTREGA, te.codigo
			from gd_esquema.Maestra
			inner join jafo.provincia prov 
				on prov.nombre = CLI_USUARIO_DOMICILIO_PROVINCIA
			inner join jafo.localidad localidad 
				on localidad.nombre = CLI_USUARIO_DOMICILIO_LOCALIDAD
				and localidad.provincia_codigo = prov.codigo
			inner join jafo.tipo_envio te on te.nombre = ENVIO_TIPO
			inner join jafo.domicilio domicilio 
				on CLI_USUARIO_DOMICILIO_CALLE = domicilio.calle
				and CLI_USUARIO_DOMICILIO_NRO_CALLE = domicilio.numero_calle
				and CLI_USUARIO_DOMICILIO_CP = domicilio.cp
				and CLI_USUARIO_DOMICILIO_PISO = domicilio.piso
				and CLI_USUARIO_DOMICILIO_DEPTO = domicilio.depto
				and domicilio.localidad_codigo = localidad.codigo
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Envio: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

-- Publicacion
create procedure jafo.migracion_publicacion
as 
begin
	begin try
	begin transaction

		CREATE INDEX IX_Producto_Marca_Modelo_Subrubro ON jafo.producto (marca_codigo, modelo_codigo, subrubro_codigo) --para mejorar performance

		insert into jafo.publicacion(codigo,vendedor_codigo, descripcion, stock, producto_id, fecha_inicio, fecha_fin, precio, costo, porcentaje_venta, almacen_codigo, almacen_domicilio_codigo)
		select PUBLICACION_CODIGO, ven.codigo, PUBLICACION_DESCRIPCION, PUBLICACION_STOCK, prod.id, PUBLICACION_FECHA, PUBLICACION_FECHA_V, PUBLICACION_PRECIO, PUBLICACION_COSTO, PUBLICACION_PORC_VENTA ,alm.codigo, alm.domicilio_codigo
		from (select * from gd_esquema.Maestra where PUBLICACION_CODIGO is not null and VEN_USUARIO_NOMBRE is not null) as maestra
		inner join jafo.vendedor ven
			on maestra.VENDEDOR_CUIT = ven.cuit
			and maestra.VENDEDOR_MAIL = ven.mail
			and maestra.VENDEDOR_RAZON_SOCIAL = ven.razon_social
		inner join jafo.provincia prov
			on maestra.ALMACEN_PROVINCIA = prov.nombre
		inner join jafo.localidad localidad
				on maestra.ALMACEN_Localidad = localidad.nombre
				and localidad.provincia_codigo = prov.codigo
		inner join jafo.domicilio dom
			on dom.calle = maestra.ALMACEN_CALLE
			and dom.numero_calle = maestra.ALMACEN_NRO_CALLE
			and dom.localidad_codigo = localidad.codigo
		inner join jafo.almacen alm
			on alm.codigo = maestra.ALMACEN_CODIGO
			and alm.domicilio_codigo = dom.codigo
		inner join jafo.modelo modelo
				on maestra.PRODUCTO_MOD_CODIGO = modelo.codigo
				and maestra.PRODUCTO_MOD_DESCRIPCION = modelo.descripcion
		inner join jafo.marca marca
			on maestra.PRODUCTO_MARCA = marca.nombre
		inner join jafo.rubro rubro
			on rubro.descripcion = maestra.PRODUCTO_RUBRO_DESCRIPCION
		inner join jafo.subrubro subr
			on subr.descripcion = maestra.PRODUCTO_SUB_RUBRO
			and subr.rubro_codigo = rubro.codigo
		inner join jafo.producto prod
			on maestra.PRODUCTO_DESCRIPCION = prod.descripcion
			and prod.marca_codigo = marca.codigo
			and prod.modelo_codigo = modelo.codigo
			and prod.subrubro_codigo = subr.codigo

		commit transaction

	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Publicacion: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

-- detalle_venta
create procedure jafo.migracion_detalle_venta
as 
begin
	begin try
	begin transaction
		insert into jafo.detalle_venta(venta_codigo, publicacion_codigo, cantidad, subtotal, precio)
			select VENTA_CODIGO,PUBLICACION_CODIGO,VENTA_DET_CANT, VENTA_DET_PRECIO, VENTA_DET_SUB_TOTAL
			from gd_esquema.Maestra
			where PUBLICACION_CODIGO is not null and VENTA_CODIGO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Detalle_Venta: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

-- Factura
create procedure jafo.migracion_factura
as 
begin
	begin try
	begin transaction
		insert into jafo.factura(numero, usuario_codigo, fecha, total)
			select distinct FACTURA_NUMERO, ven.usuario_codigo, FACTURA_FECHA, FACTURA_TOTAL
			from gd_esquema.Maestra
			inner join jafo.publicacion publi
				on publi.codigo = PUBLICACION_CODIGO
			inner join jafo.vendedor ven
				on ven.codigo = publi.vendedor_codigo
			where FACTURA_NUMERO is not null and PUBLICACION_CODIGO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Factura: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Concepto
create procedure jafo.migracion_concepto
as 
begin
	begin try
	begin transaction
		insert into jafo.concepto (nombre)
			select distinct FACTURA_DET_TIPO
			from gd_esquema.Maestra
			where FACTURA_DET_TIPO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Concepto: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go

--Detalle Factura
create procedure jafo.migracion_detalle_factura
as 
begin
	begin try
	begin transaction
		insert into jafo.detalle_factura (concepto_codigo, publicacion_codigo, factura_numero, cantidad, subtotal)
			select conc.codigo, PUBLICACION_CODIGO, FACTURA_NUMERO, FACTURA_DET_CANTIDAD, FACTURA_DET_SUBTOTAL
			from gd_esquema.Maestra
			inner join jafo.concepto conc
				on FACTURA_DET_TIPO = conc.nombre
			where FACTURA_NUMERO is not null and PUBLICACION_CODIGO is not null
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Detalle_Factura: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go



--creacion de tablas
exec jafo.crear_tabla_rubro
exec jafo.crear_tabla_subrubro
exec jafo.crear_tabla_marca
exec jafo.crear_tabla_modelo
exec jafo.crear_tabla_producto
exec jafo.crear_tabla_tipo_envio
exec jafo.crear_tabla_tipo_medio_pago
exec jafo.crear_tabla_concepto
exec jafo.crear_tabla_usuario
exec jafo.crear_tabla_provincia
exec jafo.crear_tabla_localidad
exec jafo.crear_tabla_domicilio
exec jafo.crear_tabla_usuario_domicilio
exec jafo.crear_tabla_cliente
exec jafo.crear_tabla_vendedor
exec jafo.crear_tabla_almacen
exec jafo.crear_tabla_publicacion
exec jafo.crear_tabla_venta
exec jafo.crear_tabla_envio
exec jafo.crear_tabla_medio_pago
exec jafo.crear_tabla_pago
exec jafo.crear_tabla_detalle_venta
exec jafo.crear_tabla_factura
exec jafo.crear_tabla_detalle_factura

--drop procedure jafo.crear_tabla_rubro
--drop procedure jafo.crear_tabla_subrubro
--drop procedure jafo.crear_tabla_marca
--drop procedure jafo.crear_tabla_modelo
--drop procedure jafo.crear_tabla_producto
--drop procedure jafo.crear_tabla_tipo_envio
--drop procedure jafo.crear_tabla_tipo_medio_pago
--drop procedure jafo.crear_tabla_concepto
--drop procedure jafo.crear_tabla_usuario
--drop procedure jafo.crear_tabla_provincia
--drop procedure jafo.crear_tabla_localidad
--drop procedure jafo.crear_tabla_domicilio
--drop procedure jafo.crear_tabla_usuario_domicilio
--drop procedure jafo.crear_tabla_cliente
--drop procedure jafo.crear_tabla_vendedor
--drop procedure jafo.crear_tabla_almacen
--drop procedure jafo.crear_tabla_publicacion
--drop procedure jafo.crear_tabla_venta
--drop procedure jafo.crear_tabla_envio
--drop procedure jafo.crear_tabla_medio_pago
--drop procedure jafo.crear_tabla_pago
--drop procedure jafo.crear_tabla_detalle_venta
--drop procedure jafo.crear_tabla_factura
--drop procedure jafo.crear_tabla_detalle_factura
--migracion
exec jafo.migracion_rubro
exec jafo.migracion_subrubro
exec jafo.migracion_provincia
exec jafo.migracion_localidad
exec jafo.migracion_domicilio
exec jafo.migracion_almacen
exec jafo.migracion_marca
exec jafo.migracion_modelo
exec jafo.migracion_usuario
exec jafo.migracion_cliente
exec jafo.migracion_vendedor
exec jafo.migracion_usuario_domicilio
exec jafo.migracion_producto
exec jafo.migracion_tipo_medio_pago
exec jafo.migracion_medio_pago
exec jafo.migracion_venta
exec jafo.migracion_pago
exec jafo.migracion_tipo_envio
exec jafo.migracion_envio
exec jafo.migracion_publicacion
exec jafo.migracion_detalle_venta
exec jafo.migracion_factura
exec jafo.migracion_concepto
exec jafo.migracion_detalle_factura

go

--borrarTablas
--IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[jafo].[borrarTablas]') AND type = N'P')
--	DROP PROCEDURE jafo.borrarTablas
--go

--create procedure jafo.borrarTablas
--as 
--begin
--	DROP TABLE jafo.usuario_domicilio
--	DROP TABLE jafo.detalle_factura
--	DROP TABLE jafo.detalle_venta
--	DROP TABLE jafo.publicacion
--	DROP TABLE jafo.producto
--	DROP TABLE jafo.pago
--	DROP TABLE jafo.medio_pago
--	DROP TABLE jafo.modelo
--	DROP TABLE jafo.marca
--	DROP TABLE jafo.almacen
--	DROP TABLE jafo.envio
--	DROP TABLE jafo.domicilio
--	DROP TABLE jafo.localidad
--	DROP TABLE jafo.provincia
--	DROP TABLE jafo.venta
--	DROP TABLE jafo.cliente
--	DROP TABLE jafo.factura
--	DROP TABLE jafo.subrubro
--	DROP TABLE jafo.rubro
--	DROP TABLE jafo.tipo_envio
--	DROP TABLE jafo.tipo_medio_pago
--	DROP TABLE jafo.vendedor
--	DROP TABLE jafo.usuario
--	DROP TABLE jafo.concepto

--end

----borrar sps
--IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[jafo].[borrarSps]') AND type = N'P')
--	DROP PROCEDURE jafo.borrarSps
--go

--create procedure jafo.borrarSps
--as 
--begin
	--drop procedure jafo.migracion_rubro
	--drop procedure jafo.migracion_subrubro
	--drop procedure jafo.migracion_provincia
	--drop procedure jafo.migracion_localidad
	--drop procedure jafo.migracion_domicilio
	--drop procedure jafo.migracion_almacen
	--drop procedure jafo.migracion_marca
	--drop procedure jafo.migracion_modelo
	--drop procedure jafo.migracion_usuario
	--drop procedure jafo.migracion_cliente
	--drop procedure jafo.migracion_vendedor
	--drop procedure jafo.migracion_usuario_domicilio
	--drop procedure jafo.migracion_producto
	--drop procedure jafo.migracion_tipo_medio_pago
	--drop procedure jafo.migracion_medio_pago
	--drop procedure jafo.migracion_venta
	--drop procedure jafo.migracion_pago
	--drop procedure jafo.migracion_tipo_envio
	--drop procedure jafo.migracion_envio
	--drop procedure jafo.migracion_publicacion
	--drop procedure jafo.migracion_detalle_venta
	--drop procedure jafo.migracion_factura
	--drop procedure jafo.migracion_concepto
	--drop procedure jafo.migracion_detalle_factura

--end

--drop procedure jafo.CrearTablas
--exec jafo.borrarTablas
--exec jafo.borrarSps

--drop procedure jafo.borrarTablas
--drop procedure jafo.borrarSps

--drop schema jafo
