USE [GD2C2020]
GO

IF OBJECT_ID('LOS_GEDDES.Bi_Estadisticas_clientes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Estadisticas_clientes

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_automoviles') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_automoviles

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_autopartes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_autopartes

IF OBJECT_ID('LOS_GEDDES.Bi_Instantes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Instantes

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_edades') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_edades

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_potencias') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_potencias

--Creacion de tablas auxiliares
CREATE TABLE LOS_GEDDES.Bi_Instantes(
  inst_id	bigint IDENTITY(1,1),
  inst_mes  tinyint,
  inst_anio smallint

  Constraint pk_instantes PRIMARY KEY(inst_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_potencias(
  rgpo_id  bigint IDENTITY(1,1),
  rgpo_min decimal(18,0),
  rgpo_max decimal(18,0)

  Constraint pk_rgpo PRIMARY KEY(rgpo_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_edades(
  rged_id  bigint IDENTITY(1,1),
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