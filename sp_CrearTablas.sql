IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[jafo].[CrearTablas]') AND type = N'P')
	DROP PROCEDURE jafo.CrearTablas
go

CREATE PROCEDURE jafo.CrearTablas
AS
BEGIN
	-- Crear esquema
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'jafo')
    BEGIN
        EXEC('CREATE SCHEMA jafo');
    END

    -- Crear tablas independientes (sin FK)

	IF OBJECT_ID('jafo.rubro', 'U') IS NOT NULL DROP TABLE jafo.rubro;
	CREATE TABLE jafo.rubro (
		codigo INT IDENTITY PRIMARY KEY,
		descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
	);

	IF OBJECT_ID('jafo.subrubro', 'U') IS NOT NULL DROP TABLE jafo.subrubro;
	CREATE TABLE jafo.subrubro (
		codigo INT IDENTITY PRIMARY KEY,
		descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
		rubro_codigo INT,
		FOREIGN KEY (rubro_codigo) REFERENCES jafo.rubro(codigo)
	);

	 IF OBJECT_ID('jafo.marca', 'U') IS NOT NULL DROP TABLE jafo.marca;
	 CREATE TABLE jafo.marca (
		codigo INT IDENTITY (1, 1) PRIMARY KEY,
		nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
	);

	IF OBJECT_ID('jafo.modelo', 'U') IS NOT NULL DROP TABLE jafo.modelo;
	CREATE TABLE jafo.modelo (
		codigo DECIMAL(18,0) PRIMARY KEY,
		descripcion NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	);

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

    IF OBJECT_ID('jafo.tipo_envio', 'U') IS NOT NULL DROP TABLE jafo.tipo_envio;
    CREATE TABLE jafo.tipo_envio(
        codigo INT IDENTITY PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL
    );

    IF OBJECT_ID('jafo.tipo_medio_pago', 'U') IS NOT NULL DROP TABLE jafo.tipo_medio_pago;
    CREATE TABLE jafo.tipo_medio_pago(
        codigo DECIMAL(18,0) IDENTITY PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL
    );

    IF OBJECT_ID('jafo.concepto', 'U') IS NOT NULL DROP TABLE jafo.concepto;
    CREATE TABLE jafo.concepto(
        codigo DECIMAL(18,0) IDENTITY PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL
    );

    IF OBJECT_ID('jafo.usuario', 'U') IS NOT NULL DROP TABLE jafo.usuario;
    CREATE TABLE jafo.usuario (
        codigo INT IDENTITY PRIMARY KEY,
        nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        pass NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        fecha_creacion DATE NOT NULL
    );

    IF OBJECT_ID('jafo.provincia', 'U') IS NOT NULL DROP TABLE jafo.provincia;
    CREATE TABLE jafo.provincia (
        codigo INT IDENTITY (1, 1) PRIMARY KEY,
        nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL
    );

    -- Crear tablas con dependencias de FK en las anteriores
    IF OBJECT_ID('jafo.localidad', 'U') IS NOT NULL DROP TABLE jafo.localidad;
    CREATE TABLE jafo.localidad (
        codigo INT IDENTITY (1, 1) PRIMARY KEY,
        nombre NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        provincia_codigo INT,
        FOREIGN KEY (provincia_codigo) REFERENCES jafo.provincia(codigo)
    );

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

	IF OBJECT_ID('jafo.usuario_domicilio', 'U') IS NOT NULL DROP TABLE jafo.usuario_domicilio;
	CREATE TABLE jafo.usuario_domicilio (
		usuario_codigo INT,
		domicilio_codigo INT,
		PRIMARY KEY (usuario_codigo, domicilio_codigo),
		FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo),
		FOREIGN KEY (domicilio_codigo) REFERENCES jafo.domicilio(codigo)
	);

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

    IF OBJECT_ID('jafo.vendedor', 'U') IS NOT NULL DROP TABLE jafo.vendedor;
    CREATE TABLE jafo.vendedor (
        codigo INT IDENTITY PRIMARY KEY,
        razon_social NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        cuit NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        mail NVARCHAR(100) COLLATE Modern_Spanish_CI_AS NOT NULL,
        usuario_codigo INT,
        FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo)
    );

    IF OBJECT_ID('jafo.almacen', 'U') IS NOT NULL DROP TABLE jafo.almacen;
    CREATE TABLE jafo.almacen (
        codigo DECIMAL(18,0),
        domicilio_codigo INT,
		 costo_dia_alquiler DECIMAL(18,2),
		PRIMARY KEY (codigo, domicilio_codigo),
        FOREIGN KEY (domicilio_codigo) REFERENCES jafo.domicilio(codigo)
    );

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

    IF OBJECT_ID('jafo.venta', 'U') IS NOT NULL DROP TABLE jafo.venta;
    CREATE TABLE jafo.venta (
        codigo DECIMAL(18,0) PRIMARY KEY,
        cliente_codigo INT,
        fecha DATE NOT NULL,
        total DECIMAL(18,2) NOT NULL,
        FOREIGN KEY (cliente_codigo) REFERENCES jafo.cliente(codigo)
    );

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
	
    IF OBJECT_ID('jafo.medio_pago', 'U') IS NOT NULL DROP TABLE jafo.medio_pago;
    CREATE TABLE jafo.medio_pago (
        codigo DECIMAL(18,0) IDENTITY PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        tipo_medio_pago_codigo DECIMAL(18,0),
        FOREIGN KEY (tipo_medio_pago_codigo) REFERENCES jafo.tipo_medio_pago(codigo)
    );

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

	IF OBJECT_ID('jafo.factura', 'U') IS NOT NULL DROP TABLE jafo.factura;
	CREATE TABLE jafo.factura (
		numero DECIMAL(18,0),
		fecha DATE,
		total DECIMAL(18,2),
		usuario_codigo INT,
		PRIMARY KEY (numero),
		FOREIGN KEY (usuario_codigo) REFERENCES jafo.usuario(codigo)
	);

    IF OBJECT_ID('jafo.detalle_factura', 'U') IS NOT NULL DROP TABLE jafo.detalle_factura;
    CREATE TABLE jafo.detalle_factura (
        tipo NVARCHAR(100),
        publicacion_codigo DECIMAL(18,0),
        factura_numero decimal(18,0),
        concepto_codigo DECIMAL(18,0) NOT NULL,
        cantidad DECIMAL(18,0) NOT NULL,
        subtotal DECIMAL(18,2),
        PRIMARY KEY (tipo, publicacion_codigo, factura_numero),
		FOREIGN KEY (publicacion_codigo) REFERENCES jafo.publicacion(codigo),
		FOREIGN KEY (factura_numero) REFERENCES jafo.factura(numero)
	);

END