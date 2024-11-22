-----------------TABLAS--------------------------------------------------------
--tiempo
create table jafo.bi_dim_tiempo(
	 id_tiempo int identity(1,1) primary key
	,anio int
	,cuatrimestre int
	,mes int
)

--subrubro
create table jafo.bi_dim_subrubro(
	 codigo int primary key
	,nombre nvarchar(200)
)

--marca
create table jafo.bi_dim_marca (
    id_marca int primary key,
    descripcion nvarchar(200) 
)

--producto
create table jafo.bi_dim_producto(
	 id_producto int primary key
	,sub_rubro_codigo int
	,marca_codigo int
	,idRubro int
	 FOREIGN KEY (sub_rubro_codigo) REFERENCES jafo.bi_dim_subrubro
	,FOREIGN KEY (marca_codigo) REFERENCES jafo.bi_dim_marca
	,FOREIGN KEY (idRubro) REFERENCES jafo.bi_dim_rubro
)

--publicacion
create table jafo.bi_hecho_publicacion(
	 subrubro_id int
	,marca_id int
	,tiempo_id int
	,fecha_inicio datetime
	,tiempo_vigente int
	,stock decimal (18,0)
	 FOREIGN KEY (subrubro_id) REFERENCES jafo.bi_dim_subrubro
	,FOREIGN KEY (marca_id) REFERENCES jafo.bi_dim_marca
	,FOREIGN KEY (tiempo_id) REFERENCES jafo.bi_dim_tiempo
)

-- Tabla ubicacion
create table jafo.bi_dim_ubicacion (
	idUbicacion int identity (1,1) primary key,
	provincia nvarchar(100),
	localidad nvarchar(100)
)
go

-- tabla de almacen
create table jafo.bi_dim_almacen (
	idAlmacen decimal(18,0) primary key,
	ubicacion_id int,
	FOREIGN KEY (ubicacion_id) REFERENCES jafo.bi_dim_ubicacion(idUbicacion)
)
go

-- tabla rubro
create table jafo.bi_dim_rubro (
	idRubro int primary key,
	rubro nvarchar(100)
)
go

-- tabla rango etario
create table jafo.bi_dim_rango_etario (
    idRangoEtario INT IDENTITY(1,1) PRIMARY KEY,
    descripcion_rango VARCHAR(20)
)
go

-- Tabla rango horario
create table jafo.bi_dim_rango_horario(
	idRangoHorario int identity (1,1) primary key,
	descripcion_rango nvarchar(100)
)
go

create table jafo.bi_dim_cliente(
	idCliente int primary key,
	edad int,
	ubicacion_id int,
	FOREIGN KEY (ubicacion_id) REFERENCES jafo.bi_dim_ubicacion(idUbicacion)
)

-- Tabla de hechos ventas
create table jafo.bi_hechos_ventas (
	idRangoHorario int,
	idRangoEtario int,
	idRubro int,
	idTiempo int,
	idAlmacen decimal(18,0),
	idCliente int,
	importe_total decimal(18,2),
	foreign key (idRangoHorario) references jafo.bi_dim_rango_horario(idRangoHorario),
	foreign key (idRangoEtario) references jafo.bi_dim_rango_etario(idRangoEtario),
	foreign key (idRubro) references jafo.bi_dim_rubro(idRubro),
	foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo),
	foreign key (idAlmacen) references jafo.bi_dim_almacen(idAlmacen),
	foreign key (idCliente) references jafo.bi_dim_cliente(idCliente)
)

-- clientes x ubicacion
create table jafo.bi_dim_cliente_ubicacion(
	idCliente int,
	idUbicacion int 
	PRIMARY KEY (idCliente, idUbicacion),
	FOREIGN KEY (idCliente) REFERENCES jafo.bi_dim_cliente(idCliente),
	FOREIGN KEY (idUbicacion) REFERENCES jafo.bi_dim_ubicacion(idUbicacion)
)