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

--publicacion
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

-- Tabla de hechos ventas
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
)

--medio de pago
create table jafo.bi_dim_medio_pago(
	 id_medio_pago int primary key
	,nombre nvarchar(200)
)

create table jafo.bi_dim_cantidad_cuotas(
	 id_cantidad_cuotas int identity(1,1) primary key
	,cantidad decimal(18,0)
)

-- hechos publicacion
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

)

create table jafo.bi_tipo_envio(
	 idTipoEnvio int primary key
	,nombre nvarchar(200)
)


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
)

create table jafo.bi_dim_concepto(
	idConcepto int primary key,
	nombre_concepto nvarchar(100)
)



create table jafo.bi_hechos_facturacion(
	idUbicacionVendedor int,
	idTiempo int,
	idConcepto int,
	total decimal(18,2),
	foreign key (idUbicacionVendedor) references jafo.bi_dim_ubicacion(idUbicacion),
	foreign key (idTiempo) references jafo.bi_dim_tiempo(id_tiempo),
	foreign key (idConcepto) references jafo.bi_dim_concepto(idConcepto),

)

---- Eliminar tablas de hechos primero, ya que dependen de dimensiones
--DROP TABLE IF EXISTS jafo.bi_hechos_ventas;
--DROP TABLE IF EXISTS jafo.bi_hecho_publicacion;
--drop table if exists jafo.bi_hechos_pagos
--drop table if exists jafo.bi_hechos_facturacion;
--drop table if exists jafo.bi_hechos_envios;
------ Eliminar dimensiones relacionadas después
--DROP TABLE IF EXISTS jafo.bi_dim_rango_horario;
--DROP TABLE IF EXISTS jafo.bi_dim_rango_etario;
--DROP TABLE IF EXISTS jafo.bi_dim_rubro;
--DROP TABLE IF EXISTS jafo.bi_dim_ubicacion;
--DROP TABLE IF EXISTS jafo.bi_dim_marca;
--DROP TABLE IF EXISTS jafo.bi_dim_subrubro;
--DROP TABLE IF EXISTS jafo.bi_dim_tiempo;
--drop table if exists jafo.bi_dim_medio_pago
--drop table if exists jafo.bi_dim_cantidad_cuotas
--drop table if exists jafo.bi_dim_concepto;
--drop table if exists jafo.bi_dim_factura;
--drop table if exists jafo.bi_tipo_envio;

--print @@trancount
--rollback tran 
