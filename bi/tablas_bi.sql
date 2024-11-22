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
