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

--Droppeo de funciones
if OBJECT_ID('LOS_GEDDES.rango_potencia')is not null
	DROP FUNCTION LOS_GEDDES.rango_potencia

IF OBJECT_ID('LOS_GEDDES.edad_en_el_anio', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.edad_en_el_anio
go

IF OBJECT_ID('LOS_GEDDES.rango_edad', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.rango_edad
go

IF OBJECT_ID('LOS_GEDDES.rg_edad_en_el_anio', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.rg_edad_en_el_anio
go

--Creacion de tablas auxiliares
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
  opau_modelo	     decimal(18,0),
  opau_rg_potencia	 bigint,
  opau_cant_comprada decimal(18,0),
  opau_costo_total	 decimal(18,2),
  opau_cant_vendida  decimal(18,0),
  opau_total_ventas  decimal(18,2),

  Constraint pk_opau	  PRIMARY KEY(opau_id         ),
  Constraint fk_opau_inst FOREIGN KEY(opau_instante   ) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opau_sucu FOREIGN KEY(opau_sucursal	  ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opau_mode FOREIGN KEY(opau_modelo     ) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),	
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
			when @edad > 51 then @rg_edad_mayor50
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
	compra decimal(18,0),
	venta decimal(18,0),
	sucursal bigint,
	anio bigint,
	mes bigint,
	cliente bigint,
	modelo decimal(18,0),
	precio_total decimal(18,2)
)

print '
>> tabla temporal de Operaciones de compraventa'
insert into #Operaciones
(compra, venta, sucursal, anio, mes, cliente, modelo, precio_total)
( 
	select cpra_numero, null, cpra_sucursal, year(cpra_fecha), MONTH(cpra_fecha), cpra_cliente, auto_modelo, cpra_precio_total 
		from LOS_GEDDES.Compras
		left join LOS_GEDDES.Automoviles
			on auto_id=cpra_automovil

	UNION ALL

	select null, fact_numero, fact_sucursal, year(fact_fecha), MONTH(fact_fecha), fact_cliente, auto_modelo, null 
		from LOS_GEDDES.Facturas
		left join LOS_GEDDES.Automoviles
			on auto_id=fact_automovil
);

print '
>> Instantes de tiempo'
insert into LOS_GEDDES.Bi_Instantes(inst_mes, inst_anio)
(
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
(opau_instante, opau_sucursal, opau_modelo, opau_cant_comprada, opau_costo_total, opau_cant_vendida, opau_total_ventas)
(
	select distinct inst_id, sucursal, modelo, sum(iif(compra is not null, 1, 0)) as cantidad_comprada, sum( iif(precio_total is not null, precio_total, 0)) as precio_Compras, sum(iif(venta is not null, 1, 0)) as cantidad_vendida, null
		from #operaciones
		join LOS_GEDDES.Bi_instantes
			on inst_anio=anio
			and inst_mes=mes
		where modelo is not null
		group by modelo, sucursal, inst_id
);

print '
>> Calculo rango de potencia'
update LOS_GEDDES.Bi_Operaciones_automoviles
set opau_rg_potencia = (
	select LOS_GEDDES.rango_potencia(mode_potencia)
		from LOS_GEDDES.Modelos_automoviles
		where mode_codigo=opau_modelo
);

print'
droppeo auxiliares'
drop table #operaciones
go
