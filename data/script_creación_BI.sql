USE [GD2C2020]
GO

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

IF OBJECT_ID('LOS_GEDDES.edad_en_el_anio', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.edad_en_el_anio
go

CREATE FUNCTION LOS_GEDDES.edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint
AS
BEGIN
	return @unAnio-YEAR(@fechaNacimiento)
END
go

IF OBJECT_ID('LOS_GEDDES.rango_edad', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.rango_edad
go


CREATE FUNCTION LOS_GEDDES.rango_edad(@edad bigint) RETURNS bigint 
AS
BEGIN
	DECLARE @rg_edad_18_30   bigint = 1
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

IF OBJECT_ID('LOS_GEDDES.rg_edad_en_el_anio', 'FN') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.rg_edad_en_el_anio

go

CREATE FUNCTION LOS_GEDDES.rg_edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint
AS
BEGIN
	return LOS_GEDDES.rango_edad(LOS_GEDDES.edad_en_el_anio(@fechaNacimiento, @unAnio))
END
go

create table #Compras(
id decimal(18,0),
sucursal bigint,
anio bigint,
mes bigint,
cliente bigint
);

create table #Ventas(
id decimal(18,0),
sucursal bigint,
anio bigint,
mes bigint,
cliente bigint
);

print '
>> Tablas temporales compras y ventas con fecha y año'
insert into #Compras
	select cpra_numero, cpra_sucursal, year(cpra_fecha), MONTH(cpra_fecha), cpra_cliente 
		from LOS_GEDDES.Compras
insert into #Ventas
	select fact_numero, fact_sucursal, year(fact_fecha), MONTH(fact_fecha), fact_cliente 
		from LOS_GEDDES.Facturas

print '
>> Instantes de tiempo'
insert into LOS_GEDDES.Bi_Instantes(inst_mes, inst_anio)
(
	select mes, anio from #Compras
	union 
	select mes, anio from #ventas
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
				join #Compras 
					on clie_id=cliente
		) as Clientes_de_compras
		
		join LOS_GEDDES.Bi_Instantes
			on inst_mes = mes
			and inst_anio=anio
		group by sucursal, inst_id, rg_edad, clie_sexo

	union all

	Select distinct inst_id, sucursal, clie_sexo, rg_edad, count(*)
		from (
			select *, LOS_GEDDES.rg_edad_en_el_anio(clie_fecha_nac, anio) as rg_edad 
				from LOS_GEDDES.Clientes 
				join #Ventas 
					on clie_id=cliente
		) as Clientes_de_ventas
		
		join LOS_GEDDES.Bi_Instantes
			on inst_mes = mes
			and inst_anio=anio
		group by sucursal, inst_id, rg_edad, clie_sexo
);

drop table #Compras
drop table #Ventas
