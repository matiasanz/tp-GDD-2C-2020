USE [GD2C2020]
GO

if OBJECT_ID('#operaciones')is not null
	drop table #operaciones -- SACAR

IF OBJECT_ID('LOS_GEDDES.Bi_Estadisticas_clientes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Estadisticas_clientes

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_automoviles', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_automoviles

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_autopartes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_autopartes

IF OBJECT_ID('LOS_GEDDES.Bi_Instantes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Instantes

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_edades', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_edades

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_potencias', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_potencias

IF OBJECT_ID('LOS_GEDDES.compraventa_mensual_sucursales', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.compraventa_mensual_sucursales

IF OBJECT_ID('LOS_GEDDES.promedio_precios_mensuales_sucursales', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.promedio_precios_mensuales_sucursales

IF OBJECT_ID('LOS_GEDDES.ganancias_mensuales_sucursales', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.ganancias_mensuales_sucursales

IF OBJECT_ID('LOS_GEDDES.tiempo_promedio_en_stock_automoviles', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.tiempo_promedio_en_stock_automoviles

--Creacion de dimensiones
CREATE TABLE LOS_GEDDES.Bi_Instantes(
  inst_id	bigint IDENTITY(1,1),
  inst_mes  tinyint,
  inst_anio smallint

  Constraint pk_instantes PRIMARY KEY(inst_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_potencias(
  rgpo_id  bigint,
  rgpo_min decimal(18,0),
  rgpo_max decimal(18,0)

  Constraint pk_rgpo PRIMARY KEY(rgpo_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_edades(
  rged_id  bigint,
  rged_min smallint,
  rged_max smallint

  Constraint pk_rged PRIMARY KEY(rged_id)
);

--Creacion de tablas de hechos
CREATE TABLE LOS_GEDDES.Bi_Estadisticas_clientes(
  ecli_id		bigint IDENTITY(1,1),
  ecli_instante bigint,
  ecli_sucursal bigint,
  ecli_sexo		char(1),
  ecli_rg_edad	bigint,
  ecli_cantidad bigint,

  Constraint pk_estad_clientes PRIMARY KEY(ecli_id     ),
  Constraint fk_ecli_inst	   FOREIGN KEY(ecli_instante) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_ecli_sucu	   FOREIGN KEY(ecli_sucursal) REFERENCES  LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_ecli_edad	   FOREIGN KEY(ecli_rg_edad ) REFERENCES  LOS_GEDDES.Bi_rangos_edades(rged_id)
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_automoviles(
  opau_id			 bigint IDENTITY(1,1),
  opau_instante		 bigint,
  opau_sucursal		 bigint,
  opau_auto			 bigint,
  opau_modelo		 decimal(18,0),
  opau_rg_potencia	 bigint,
  opau_precio		 decimal(18,2),
  opau_tipo_operacion char(1)

  Constraint pk_opau	  PRIMARY KEY(opau_id         ),
  Constraint fk_opau_inst FOREIGN KEY(opau_instante   ) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opau_sucu FOREIGN KEY(opau_sucursal	  ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opau_rgpo FOREIGN KEY(opau_rg_potencia) REFERENCES LOS_GEDDES.Bi_Rangos_potencias(rgpo_id)   
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_autopartes (
  opap_id			 bigint IDENTITY(1,1),
  opap_instante		 bigint,
  opap_sucursal		 bigint,
  opap_autoparte	 decimal(18,0),
  opap_rubro	     bigint,
  opap_fabricante	 bigint,
  opap_cant_comprada decimal(18,0),
  opap_costo_total	 decimal(18,2),
  opap_cant_vendida  decimal(18,0),
  opap_total_ventas  decimal(18,2)

  Constraint pk_opap	  PRIMARY KEY(opap_id        ),
  Constraint fk_opap_inst FOREIGN KEY(opap_instante  ) REFERENCES LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opap_sucu FOREIGN KEY(opap_sucursal	 ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opap_apte FOREIGN KEY(opap_autoparte ) REFERENCES LOS_GEDDES.Autopartes(apte_codigo),
  Constraint fk_opap_cate FOREIGN KEY(opap_rubro     ) REFERENCES LOS_GEDDES.Categorias_autopartes(cate_codigo),   
  Constraint fk_opap_fabr FOREIGN KEY(opap_fabricante) REFERENCES LOS_GEDDES.Fabricantes(fabr_id)
 );
go

--Creacion de funciones
CREATE FUNCTION LOS_GEDDES.edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint
	AS BEGIN return @unAnio-YEAR(@fechaNacimiento) END
go

CREATE FUNCTION LOS_GEDDES.rango_edad(@edad bigint) RETURNS bigint 
	AS BEGIN
		DECLARE @rg_edad_18_30   bigint = 1 --CUANDO hagamos procedure, se lo pasamos como argumento
		DECLARE @rg_edad_31_50   bigint = 2 
		DECLARE @rg_edad_mayor50 bigint = 3 

		return CASE
			when @edad BETWEEN 18 and 30 then @rg_edad_18_30 
			when @edad BETWEEN 31 and 50 then @rg_edad_31_50
			when @edad > 50 then @rg_edad_mayor50
			else 0
		END
END
go

CREATE FUNCTION LOS_GEDDES.rg_edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint
	AS BEGIN
		return LOS_GEDDES.rango_edad(LOS_GEDDES.edad_en_el_anio(@fechaNacimiento, @unAnio))
	END
go

CREATE FUNCTION LOS_GEDDES.rango_potencia(@potencia decimal(18,0)) RETURNS bigint 
	AS BEGIN
		DECLARE @rg_menor   bigint = 1
		DECLARE @rg_medio   bigint = 2 
		DECLARE @rg_mayor   bigint = 3 

		return CASE
			when @potencia BETWEEN 50 and 150 then @rg_menor 
			when @potencia BETWEEN 151 and 300 then @rg_medio
			when @potencia > 300 then @rg_mayor
			else 0
	END
END
go

create function LOS_GEDDES.instante_en_meses(@mes bigint, @anio bigint) returns bigint as
	begin
		return @mes + @anio*12
	end
;
go

create function LOS_GEDDES.instante_actual_en_meses() returns bigint as
	begin
		declare @fecha_actual datetime = getdate();
		return LOS_GEDDES.instante_en_meses(month(@fecha_actual), year(@fecha_actual));
	end;
go

--Migracion del modelo
print '>> Rangos potencias'
INSERT INTO LOS_GEDDES.Bi_rangos_potencias(rgpo_id, rgpo_min, rgpo_max)
	Values (1, 50,150), (2, 151, 300), (3, 301, null)
;

print '
>> Rangos edades'
INSERT INTO LOS_GEDDES.Bi_rangos_edades(rged_id, rged_min, rged_max)
	Values (0, 0, 17), (1, 18, 30), (2, 31, 50), (3, 51, null)
;
go

create table #operaciones(
	compra		 decimal(18,0),
	venta		 decimal(18,0),
	sucursal	 bigint,
	anio		 bigint,
	mes			 bigint,
	cliente		 bigint,
	automovil	 bigint,
	modelo		 decimal(18,0),
	precio_total decimal(18,2),
)

print '
>> tabla temporal de Operaciones de compraventa'
insert into #Operaciones
(compra, venta, sucursal, anio, mes, cliente, automovil, modelo, precio_total)
( 
	select cpra_numero, null, cpra_sucursal, year(cpra_fecha), MONTH(cpra_fecha), cpra_cliente, auto_id, auto_modelo, cpra_precio_total
		from LOS_GEDDES.Compras
		left join LOS_GEDDES.Automoviles
			on auto_id=cpra_automovil

	UNION ALL

	select null, fact_numero, fact_sucursal, year(fact_fecha), MONTH(fact_fecha), fact_cliente, auto_id, auto_modelo, fact_precio 
		from LOS_GEDDES.Facturas
		left join LOS_GEDDES.Automoviles
			on auto_id=fact_automovil
);

print '
>> Instantes de tiempo'
insert into LOS_GEDDES.Bi_Instantes(inst_mes, inst_anio)(
	select distinct mes, anio from #operaciones
);

print '
>> estadisticas clientes'
INSERT INTO LOS_GEDDES.Bi_Estadisticas_clientes
(ecli_instante, ecli_sucursal, ecli_sexo, ecli_rg_edad, ecli_cantidad)
(
	Select distinct inst_id, sucursal, clie_sexo, rg_edad, count(*)
		from (
			select *, LOS_GEDDES.rg_edad_en_el_anio(clie_fecha_nac, anio) as rg_edad 
				from LOS_GEDDES.Clientes 
				join #Operaciones
					on clie_id=cliente
		) as Clientes
		
		join LOS_GEDDES.Bi_Instantes
			on inst_mes = mes
			and inst_anio=anio
		group by sucursal, inst_id, rg_edad, clie_sexo
);

print '
>> operaciones de automoviles'
insert into LOS_GEDDES.Bi_Operaciones_automoviles
(opau_instante, opau_sucursal, opau_auto, opau_tipo_operacion, opau_modelo, opau_rg_potencia, opau_precio)
(
	select distinct inst_id, sucursal, automovil, iif(compra is not null, 'c', 'v'), modelo, LOS_GEDDES.rango_potencia(mode_potencia), precio_total
		from #operaciones
		join LOS_GEDDES.Bi_instantes
			on inst_anio=anio
			and inst_mes=mes
		join LOS_GEDDES.Modelos_automoviles
			on mode_codigo=modelo
		where modelo is not null
);

print '
>> Operaciones de autopartes'
insert into LOS_GEDDES.Bi_Operaciones_autopartes
(opap_instante, opap_sucursal, opap_autoparte, opap_rubro, opap_fabricante, opap_cant_comprada,opap_costo_total
, opap_cant_vendida  , opap_total_ventas)
(
	select inst_id, sucursal, autoparte, null as rubro, null as fabricante
	, sum(iif(compra is not null, cantidad	  , 0)) as cantidad_comprada
	, sum(iif(compra is not null, precio_total, 0)) as costo_total
	, sum(iif(venta  is not null, cantidad	  , 0)) as cant_vendida
	, sum(iif(venta  is not null, precio_total, 0)) as total_ventas

		from (
				select compra, venta, precio_total, anio, mes, sucursal, ipco_id_autoparte as autoparte, ipco_cantidad as cantidad
					from #Operaciones
					join LOS_GEDDES.Items_por_compra
						on ipco_id_compra=compra
					where 
						compra is not null
						and modelo is null
					
				union all

				select compra, venta, precio_total, anio, mes, sucursal, ipfa_id_autoparte as autoparte, ipfa_cantidad as cantidad
					from #Operaciones
					join LOS_GEDDES.Items_por_factura
						on ipfa_factura_numero=venta
					where 
						compra is null 
						and modelo is null
		) as Operaciones_autopartes

		join LOS_GEDDES.Bi_Instantes
			on inst_anio=anio
			and inst_mes=mes

		group by inst_id, sucursal, autoparte
);

print'
>> Fabricantes y rubros'

update LOS_GEDDES.Bi_Operaciones_autopartes
	set opap_rubro = apte_categoria
	  , opap_fabricante = apte_fabricante
	
	from LOS_GEDDES.Autopartes
	where apte_codigo=opap_autoparte
;
go

--Creacion de vistas
CREATE VIEW LOS_GEDDES.compraventa_mensual_sucursales AS(
	select inst_anio, inst_mes, ciud_nombre, sucu_direccion
		, sum(iif(opau_tipo_operacion='c', 1, 0)) as cantidad_comprada
		, sum(iif(opau_tipo_operacion='v', 1, 0)) as cantidad_vendida
	
		from LOS_GEDDES.Bi_Operaciones_automoviles
		join LOS_GEDDES.Bi_Instantes
			on inst_id=opau_instante
		join LOS_GEDDES.Sucursales
			on sucu_id=opau_sucursal
		join LOS_GEDDES.Ciudades
			on ciud_id=sucu_ciudad
		group by inst_anio, inst_mes, sucu_id, ciud_nombre, sucu_direccion
);
go

CREATE VIEW LOS_GEDDES.promedio_precios_mensuales_sucursales AS

	select inst_anio as anio, inst_mes as mes, ciud_nombre as sucursal_ciudad, sucu_direccion as sucursal_direccion
		,	iif(precio_promedio_compra>0, precio_promedio_compra, null) as [precio promedio compra]
		,   iif(precio_promedio_venta>0, precio_promedio_venta, null) as [precio promedio ventas]
	
		from(
			select opau_instante as instante, opau_sucursal as sucursal 
					, cast(avg(iif(opau_tipo_operacion='c', opau_precio, 0)) as decimal(18,2)) as precio_promedio_compra
					, cast(avg(iif(opau_tipo_operacion='v', opau_precio, 0)) as decimal(18,2)) as precio_promedio_venta
				from LOS_GEDDES.Bi_Operaciones_automoviles
				group by opau_instante, opau_sucursal
		) as operaciones

		join LOS_GEDDES.Sucursales
			on sucu_id=sucursal
		join LOS_GEDDES.Ciudades
			on ciud_id=sucu_ciudad
		join LOS_GEDDES.Bi_Instantes
			on inst_id=instante
;
go

CREATE VIEW LOS_GEDDES.ganancias_mensuales_sucursales AS
	select distinct inst_anio anio, inst_mes mes, ciud_nombre sucursal_ciudad, sucu_direccion sucursal_direccion, sum(ventas.opau_precio - compras.opau_precio) as ganancia_mensual
	
		from LOS_GEDDES.Bi_Operaciones_automoviles ventas
		join LOS_GEDDES.Bi_Operaciones_automoviles compras
			on compras.opau_auto=ventas.opau_auto
			and compras.opau_tipo_operacion='c'
		join LOS_GEDDES.Bi_Instantes
			on inst_id=ventas.opau_instante
		join LOS_GEDDES.Sucursales
			on sucu_id=ventas.opau_sucursal
		join LOS_GEDDES.Ciudades
			on ciud_id=sucu_ciudad
		where ventas.opau_tipo_operacion='v'
		group by inst_anio, inst_mes, sucu_id, ciud_nombre, sucu_direccion
;
go

CREATE VIEW LOS_GEDDES.tiempo_promedio_en_stock_automoviles AS
	select mode_nombre as modelo, 
		avg(
			iif(fecha_venta.inst_anio is null
					, LOS_GEDDES.instante_actual_en_meses()
					, LOS_GEDDES.instante_en_meses(fecha_venta.inst_mes, fecha_venta.inst_anio)
			) - LOS_GEDDES.instante_en_meses(fecha_compra.inst_mes, fecha_compra.inst_anio)
		) as tiempo_promedio_en_stock

		from LOS_GEDDES.Bi_Operaciones_automoviles compras	
		right join LOS_GEDDES.Bi_Operaciones_automoviles ventas
			on ventas.opau_tipo_operacion='v'
			and compras.opau_auto=ventas.opau_auto
		left join LOS_GEDDES.Bi_Instantes fecha_venta
			on fecha_venta.inst_id=ventas.opau_instante
		join LOS_GEDDES.Bi_Instantes fecha_compra
			on fecha_compra.inst_id=compras.opau_instante
		join LOS_GEDDES.Modelos_automoviles
			on compras.opau_modelo=mode_codigo
		where compras.opau_tipo_operacion='c'
		group by mode_nombre
;
go

drop table #operaciones
drop function LOS_GEDDES.edad_en_el_anio
drop function LOS_GEDDES.rango_edad
drop function LOS_GEDDES.rg_edad_en_el_anio
drop function LOS_GEDDES.rango_potencia
drop function LOS_GEDDES.instante_en_meses
drop function LOS_GEDDES.instante_actual_en_meses
