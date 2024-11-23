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

-- tabla rubro
create table jafo.bi_dim_rubro (
	idRubro int primary key,
	rubro nvarchar(100)
)
go

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
	edad int
)

-- Tabla de hechos ventas
create table jafo.bi_hechos_ventas (
	idRangoHorario int,
	idRangoEtario int,
	idRubro int,
	idTiempo int,
	idUbicacionAlmacen int,
	idUbicacionCliente int,
	importe_total decimal(18,2),
	foreign key (idRangoHorario) references jafo.bi_dim_rango_horario(idRangoHorario),
	foreign key (idRangoEtario) references jafo.bi_dim_rango_etario(idRangoEtario),
	foreign key (idRubro) references jafo.bi_dim_rubro(idRubro),
	foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo),
	foreign key (idUbicacionAlmacen) references jafo.bi_dim_ubicacion(idUbicacion),
	foreign key (idUbicacionCliente) references jafo.bi_dim_ubicacion(idUbicacion)
)

--medio de pago
create table jafo.bi_dim_medio_pago(
	 id_medio_pago int primary key
	,nombre nvarchar(200)
)


-- hechos publicacion
create table jafo.bi_hechos_pagos(
	 dim_ubicacion_id int 
	,dim_medio_pago_id int
	,dim_tiempo_id int
	,importe decimal(18,2)
	,cant_cuotas decimal(18,0)
	 foreign key (dim_ubicacion_id) references jafo.bi_dim_ubicacion(idUbicacion)
	,foreign key (dim_medio_pago_id) references jafo.bi_dim_medio_pago(id_medio_pago)
	,foreign key (dim_tiempo_id) references jafo.bi_dim_tiempo(id_tiempo)

)

-- Eliminar tablas de hechos primero, ya que dependen de dimensiones
--DROP TABLE IF EXISTS jafo.bi_hechos_ventas;
--DROP TABLE IF EXISTS jafo.bi_hecho_publicacion;
--drop table if exists jafo.bi_hechos_pagos

---- Eliminar dimensiones relacionadas después
--DROP TABLE IF EXISTS jafo.bi_dim_producto;
--DROP TABLE IF EXISTS jafo.bi_dim_cliente;
--DROP TABLE IF EXISTS jafo.bi_dim_rango_horario;
--DROP TABLE IF EXISTS jafo.bi_dim_rango_etario;
--DROP TABLE IF EXISTS jafo.bi_dim_rubro;
--DROP TABLE IF EXISTS jafo.bi_dim_ubicacion;
--DROP TABLE IF EXISTS jafo.bi_dim_marca;
--DROP TABLE IF EXISTS jafo.bi_dim_subrubro;
--DROP TABLE IF EXISTS jafo.bi_dim_tiempo;
--drop table if exists jafo.bi_dim_medio_pago
--drop table if exists jafo.bi_hechos_pagos;
