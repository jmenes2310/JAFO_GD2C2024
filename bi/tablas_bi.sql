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
	 FOREIGN KEY (sub_rubro_codigo) REFERENCES jafo.bi_dim_subrubro
	,FOREIGN KEY (marca_codigo) REFERENCES jafo.bi_dim_marca
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
	idAlmacen int primary key,
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