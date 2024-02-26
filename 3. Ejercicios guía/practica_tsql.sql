use GD2015C1
go

/*1
Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/

create function estado_segun_articulo(@articulo char(8), @deposito char(2))
returns nvarchar(255) as
	begin
	Declare @max decimal(12,2)
	Declare @cant decimal(12,2)
	
	Select @max=stoc_stock_maximo, @cant=stoc_cantidad 
		from STOCK
		where stoc_deposito = @deposito
			and stoc_producto=@articulo

	return iif(@cant<@max
				, concat('OCUPACION DEL DEPOSITO',  str(100*@cant/@max) ,'%')
				, 'DEPOSITO COMPLETO')
end
go
/*
Select prod_codigo, depo_codigo, dbo.estado_segun_articulo( prod_codigo, depo_codigo) as estado from Producto, DEPOSITO, STOCK
	where prod_codigo=stoc_producto
		and depo_codigo = stoc_deposito
*/
drop function estado_segun_articulo
go

-----------------------------------------------------------------------------------------
/*2. Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha*/

create function stock_a_la_fecha(@producto char(8), @fecha smalldatetime)
	returns decimal(12) as begin
		declare @cantidad_comprada decimal(12) = (
			select sum(stoc_cantidad) from Stock
				where stoc_producto=@producto
		)

		declare @cantidad_vendida decimal(12) = (
			select sum(item_cantidad) from Item_factura
				join Factura on
					fact_tipo=item_tipo
					and fact_numero=item_numero
					and fact_sucursal=item_sucursal
				where item_producto=@producto
					and fact_fecha <= @fecha
		)

		return @cantidad_comprada - @cantidad_vendida
end
go

if object_id('dbo.stock_a_la_fecha') is not null
drop function dbo.stock_a_la_fecha
go 

-- Alternativa
create function stock_a_la_fecha(@articulo char(8), @fecha smalldatetime)
	returns int as
	begin
		declare @cantidad_comprada int = (
			Select sum(stoc_cantidad) from Stock
				where @articulo=stoc_producto
		)

		declare @cantidad_vendida int = (
			Select sum( 
				CASE	when @articulo=item_producto then item_cantidad
						when @articulo=comp_producto then comp_cantidad
						else 0
				END
			)
			
			from Item_Factura
				join Factura on
					fact_numero= item_numero
					and fact_sucursal=item_sucursal
				left join Composicion on
					comp_producto=item_producto
				where fact_fecha <= @fecha
					and item_producto=@articulo
		)

		declare @stock int = @cantidad_comprada - @cantidad_vendida

		return iif(@stock>0, @stock, 0)
	end
go

/*
Select stoc_producto, f1.fact_fecha, dbo.stock_a_la_fecha(stoc_producto, f1.fact_fecha) AS stoc_en_fecha FROM STOCK stk1
	JOIN Item_Factura if1 ON stk1.stoc_producto = if1.item_producto
	JOIN Factura f1 ON if1.item_numero = f1.fact_numero
	GROUP BY stk1.stoc_producto, f1.fact_fecha
*/
if object_id('dbo.stock_a_la_fecha') is not null
drop function dbo.stock_a_la_fecha
go

-----------------------------------------------------------------------------------------

/*3 Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución*/

if object_id('dbo.elegir_gerente_general') is not null
	drop function dbo.elegir_gerente_general
if object_id('corregir_gerentes') is not null
	drop procedure corregir_gerentes 
GO

create function elegir_gerente_general()
	returns numeric(6) as begin
		return (
			Select top 1 empl_codigo
				from Empleado
				where empl_jefe is null
				order by empl_salario desc, getdate()-empl_ingreso desc
		)
	end
go

create procedure corregir_gerentes as
	begin
		declare @gerente_general numeric(6) = dbo.elegir_gerente_general()

		Update Empleado
			set empl_jefe = @gerente_general
			where empl_jefe is null
				and empl_codigo != @gerente_general				
	end
;

drop function elegir_gerente_general
drop procedure corregir_gerentes 
go

-----------------------------------------------------------------------------------------

/*4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año*/


create function total_vendido_por(@empleado numeric(6), @anio int)
	returns decimal(12,2) as begin
		return(
			select isnull(sum(fact_total), 0) from Factura
				where fact_vendedor=@empleado
					and year(fact_fecha)=@anio
		)
	end
go

create procedure actualizar_comision_empleados as begin
	declare @anio int = year(getDate()) 
	update Empleado
		set empl_comision = dbo.total_vendido_por(empl_codigo, @anio)
end
go

drop procedure actualizar_comision_empleados
drop function dbo.total_vendido_por

-- Alt

if object_id('dbo.total_vendido', 'Fn') is not null
	drop function dbo.total_vendido

go
create function total_vendido(@empleado numeric(6))
	returns decimal(12,2) as
	begin
		return (
			Select isnull(sum(fact_total), 0)
				from Factura
				where fact_vendedor = @empleado
					and year(fact_fecha)=year(getdate())
		)
	end
go

create procedure actualizar_comision as
	begin
		Update Empleado
			set empl_comision = dbo.total_vendido(empl_codigo)
	end
;
go

--Select empl_codigo, dbo.total_vendido(empl_codigo) as total_vendido from Empleado

drop function total_vendido
drop procedure actualizar_comision
go

-----------------------------------------------------------------------------------------

/*5 Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:

Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)*/

if object_id('Fact_table', 'U') is not null
	drop table Fact_table
go

create procedure migrar_tabla_de_hechos as begin
	Create table Fact_table
	( 
		anio	 char(4) not null,
		mes		 char(2) not null,
		familia  char(3) not null,
		rubro	 char(4) not null,
		zona	 char(3) not null,
		cliente  char(6) not null,
		producto char(8) not null,
		cantidad decimal(12,2) not null,
		monto	 decimal(12,2) not null
	)

	Alter table Fact_table
		Add constraint PK_fact_table primary key(anio, mes, familia, rubro, zona, cliente, producto)
	
	Insert into Fact_table
	(anio, mes, familia, rubro, zona, cliente, producto, cantidad, monto)
	(
		Select year(fact_fecha), month(fact_fecha), prod_familia, prod_rubro, depa_zona, clie_codigo, prod_codigo, sum(item_cantidad), sum(fact_total) from Cliente
			join Factura on
				fact_cliente=clie_codigo
			join Item_Factura on
				item_numero=fact_numero
				and item_sucursal=fact_sucursal
			join Producto on
				prod_codigo=item_producto
			join Empleado on
				empl_codigo=fact_vendedor
			join Departamento on
				depa_codigo=empl_departamento
			group by prod_familia, prod_rubro, depa_zona, clie_codigo, prod_codigo, year(fact_fecha), month(fact_fecha)
	)
end
go

drop procedure migrar_tabla_de_hechos

if object_id('Fact_table', 'U') is not null begin
	--Select * from Fact_table
	drop table Fact_table
end
go


-----------------------------------------------------------------------------------------

/*6 Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas 
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.*/

create procedure corregir_factura as begin

	Select item_tipo as tipo_factura, item_numero as numero_factura, item_sucursal as sucursal, comp_producto as combo, comp_componente as componente, item_cantidad, comp_cantidad
		into #candidatos_combos
		from Item_Factura 
		join Composicion on
			item_producto=comp_componente
		where comp_cantidad <= item_cantidad
	
	declare cursor_componentes cursor for
		Select tipo_factura
				, numero_factura
				, sucursal
				, combo
				, cast(min(cc.item_cantidad/c.comp_cantidad) as decimal(12)) as cantidad_combos
			from #candidatos_combos cc
			right join Composicion c on
				c.comp_producto=combo
			group by tipo_factura, numero_factura, sucursal, combo
			having count(distinct cc.componente)>=count(distinct comp_componente)

	declare @sucursal char(4), @fact_tipo char, @fact_numero char(8), @combo char(8), @cantidad_combos decimal(12)

	open cursor_componentes
	fetch next from cursor_componentes
		into @fact_tipo, @fact_numero, @sucursal, @combo, @cantidad_combos

	while @@FETCH_STATUS=0 begin

		Update Item_factura
			set item_cantidad = item_cantidad-@cantidad_combos*comp_cantidad
			from Item_factura
			join Composicion on 
				comp_componente=item_producto
			where comp_producto=@combo
				and item_numero=@fact_numero
				and item_tipo=@fact_tipo
				and item_sucursal=@sucursal
		begin try		
			Insert into item_factura(item_tipo, item_numero, item_sucursal, item_producto, item_cantidad)
				values (@fact_tipo, @fact_numero, @sucursal, @combo, @cantidad_combos) 
		end try

		begin catch
			update Item_Factura
				set item_cantidad=item_cantidad+@cantidad_combos
				where item_numero=@fact_numero
					and item_tipo=@fact_tipo
					and item_sucursal=@sucursal
					and item_producto=@combo
		end catch

		fetch next from cursor_componentes
				into @fact_tipo, @fact_numero, @sucursal, @combo, @cantidad_combos
	end

	delete from Item_factura
		where item_cantidad=0

	close cursor_componentes
	deallocate cursor_componentes

	drop table #candidatos_combos
end
go

--begin transaction
--exec corregir_factura
--rollback transaction
go

drop procedure corregir_factura
go

----------------------------------------------------------------------------------
/*7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
Insertar una línea por cada artículo con los movimientos de stock generados por
las ventas entre esas fechas. La tabla se encuentra creada y vacía.*/

create procedure ventas_entre_fechas
(@fecha_inicio smalldatetime, @fecha_fin smalldatetime) as
begin
	Select item_producto as Codigo, prod_detalle as Detalle, count(*) as cant_mov
	  , avg(item_precio) as [Precio de Venta], IDENTITY(int, 1,1) as Renglon
	  , sum(item_precio*item_cantidad) as Ganancia
		into Ventas
		from Item_Factura
		join Factura on
			item_numero=fact_numero
			and item_sucursal=fact_sucursal
		join Producto on
			item_producto=prod_codigo
		where @fecha_inicio<=fact_fecha and fact_fecha<=@fecha_fin
		group by item_producto, prod_detalle
end
go

--declare @fecha_inicio smalldatetime = datefromparts(2012, 2, 1)
--declare @fecha_fin smalldatetime = datefromparts(2014, 2, 1)

--exec ventas_entre_fechas @fecha_inicio, @fecha_fin
go

drop procedure ventas_entre_fechas
if object_id('Ventas', 'U') is not null
begin
--	Select * from Ventas
	drop table Ventas
end
go

----------------------------------------------------------------------------------
/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe, 
crear y está formada por las siguientes columnas:*/

create procedure generar_tabla_diferencias as
	Select comp_producto as Codigo, compuesto.prod_detalle as Detalle, sum(comp_cantidad) as Cantidad, cast(sum(componente.prod_precio*comp_cantidad) as decimal(12,2)) as Precio_generado, compuesto.prod_precio as Precio_facturado
		into Diferencias
		from Composicion
		join Producto compuesto on
			compuesto.prod_codigo=comp_producto
		join Producto componente on
			componente.prod_codigo=comp_componente
			group by comp_producto, compuesto.prod_detalle, compuesto.prod_precio
;	
go

drop procedure generar_tabla_diferencias
if object_id('Diferencias', 'U') is not null
	drop table Diferencias
go
----------------------------------------------------------------------------------
/*9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.*/

--Estoy descontando el stock de todos los depositos (?)

create trigger tg_insercion_items_compuestos on Item_factura
	after insert as begin
		update Stock
			set stoc_cantidad = stoc_cantidad - comp_cantidad*(isnull(item_cantidad, 0))
		from inserted
			join Composicion on
				item_producto=comp_producto
			where stoc_producto=comp_componente
	end
go

create trigger tg_modificacion_items_compuestos on Item_factura
	after update as begin
		update Stock
			set stoc_cantidad = stoc_cantidad + comp_cantidad*(isnull(d.item_cantidad, 0)-isnull(i.item_cantidad, 0))
		from inserted i
			join deleted d on
				d.item_tipo=i.item_tipo
				and d.item_numero=i.item_numero
				and d.item_sucursal=i.item_sucursal
				and d.item_producto=i.item_producto
			join Composicion on
				i.item_producto=comp_producto
			where d.item_cantidad!=i.item_cantidad
				and stoc_producto=comp_componente
	end
go

create trigger tg_eliminacion_items_compuestos on Item_factura
	after delete as begin
		update Stock
			set stoc_cantidad = stoc_cantidad + isnull(item_cantidad, 0)
		from deleted
			join Composicion on
				item_producto=comp_producto
			where stoc_producto=comp_componente
	end
go

drop trigger tg_modificacion_items_compuestos
drop trigger tg_eliminacion_items_compuestos
drop trigger tg_insercion_items_compuestos
go
----------------------------------------------------------------------------------
/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/

create trigger tg_validar_stock_por_eliminar_producto
	on Producto instead of delete
	as begin
			
		declare cursor_productos_eliminados cursor for (
			select prod_codigo, sum(stoc_cantidad) from deleted
				join Stock on
					stoc_producto=prod_codigo
				group by prod_codigo
		)

		declare @producto char(8), @stock decimal(12)

		open cursor_productos_eliminados
		fetch next from cursor_productos_eliminados into @producto, @stock

		while @@fetch_status=0 begin
			if (@stock is null or @stock=0) begin
				delete from Stock where stoc_producto=@producto
				delete from Producto where prod_codigo=@producto
			end
				
			else begin
				raiserror('Se intento eliminar un producto del cual existe stock', 16, 1)
			end

			fetch next from cursor_productos_eliminados into @producto, @stock
		end

		fetch next from cursor_productos_eliminados into @producto, @stock
		close cursor_productos_eliminados
		deallocate cursor_productos_eliminados
	end
go

drop trigger tg_validar_stock_por_eliminar_producto
go
----------------------------------------------------------------------------------
/*11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.*/

create function es_jefe(@jefe numeric (6), @a_cargo numeric (6))
	returns bit as
	begin
		return iif( exists (
			Select * from Empleado
				where empl_codigo=@a_cargo
					and (empl_jefe=@jefe
						or dbo.es_jefe(@jefe, empl_jefe)=1
					)
			), 1, 0)
	end
go

create function cantidad_de_empleados_a_cargo(@jefe numeric(6)) 
returns int as
begin
	return (
		Select count(distinct empl_codigo) 
			from Empleado
			where dbo.es_jefe(@jefe, empl_codigo)=1
				and @jefe<empl_codigo
	)
end
go

--Select empl_codigo, dbo.cantidad_de_empleados_a_cargo(empl_codigo) as a_cargo from Empleado

drop function dbo.es_jefe
drop function dbo.cantidad_de_empleados_a_cargo
go
----------------------------------------------------------------------------------
/*12. Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/

create function compuesto_por(@compuesto char(8), @componente char(8))
returns bit as
	begin
		return iif( exists (
			Select * from Composicion
				where comp_producto=@compuesto
					and (
						comp_componente=@componente
						or
						dbo.compuesto_por(comp_componente, @componente)=1
					)
		), 1, 0)
	end
go

create trigger tg_componente_no_recursivo on Composicion
	after Insert as begin
		if exists (Select * from Composicion where dbo.compuesto_por(comp_producto, comp_producto)=1)
			throw 50000, 'Error: Existe al menos un compuesto que se compone a si mismo', 1
	end
go

drop function dbo.compuesto_por
drop trigger tg_componente_no_recursivo
go
----------------------------------------------------------------------------------
/*13. . Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías*/
--TO-DO

create function salario_empleado(@empleado numeric(6))
	returns numeric(12,2) as begin
		return (
			select empl_salario from Empleado
				where empl_codigo=@empleado
		)
	end
go

create function salario_empleados(@jefe numeric(6))
	returns numeric(12,2) as begin
		return (
			select sum(empl_salario) from Empleado
				where empl_jefe=@jefe
		)
	end
go

create trigger tg_validar_salario_jefe_al_Insertar
	on Empleado after Insert as begin
		declare cursor_jefes_de_insertados cursor for (
			select empl_jefe from inserted
		)

		declare @jefe numeric(6)

		open cursor_jefes_de_insertados
		fetch next from cursor_jefes_de_insertados into @jefe

		while @@fetch_status=0 begin
			if dbo.salario_empleado(@jefe) < dbo.salario_empleados(@jefe)/5 begin
				close cursor_jefes_de_insertados
				deallocate cursor_jefes_de_insertados
				rollback;
				throw 60000, 'Existe al menos un jefe que gana menos del 20% que sus empleados', 1
			end

			fetch next from cursor_jefes_de_insertados into @jefe
		end

		close cursor_jefes_de_insertados
		deallocate cursor_jefes_de_insertados
 	end 
go
drop trigger tg_validar_salario_jefe_al_Insertar
drop function dbo.salario_empleados
drop function dbo.salario_empleado
go
----------------------------------------------------------------------------------
/*14. Agregar el/los objetos necesarios para que si un cliente compra un producto
compuesto a un precio menor que la suma de los precios de sus componentes
que imprima la fecha, que cliente, que productos y a qué precio se realizó la
compra. No se deberá permitir que dicho precio sea menor a la mitad de la suma
de los componentes*/

create function calcular_precio_compuesto(@producto char(8))
	returns decimal(12,2) as begin
		return (
			Select sum(isnull(dbo.calcular_precio_compuesto(comp_componente), prod_precio)*comp_cantidad)
				from Composicion
				join Producto on
					comp_componente=prod_codigo
				where
					comp_producto= @producto
		)
	end
go

create trigger tg_compra_compuesta on Item_factura
	instead of Insert as begin
		declare cursor_items cursor for(
			Select item_tipo, item_numero, item_sucursal, item_producto, item_precio, item_cantidad
				from Inserted
		)
		
		declare @tipo_factura char, @numero_factura char(8), @sucursal char(4), @producto char(8)
			  , @precio_unitario decimal(12,2), @cantidad decimal (12,0)

		open cursor_items

		fetch next from cursor_items into @tipo_factura, @numero_factura, @sucursal, @producto, @precio_unitario, @cantidad 

		while @@FETCH_STATUS=0 begin
			declare @precio_compuesto decimal(12,2)= dbo.calcular_precio_compuesto(@producto) 

			if @precio_compuesto*0.5 > @precio_unitario
					raiserror('Se intento cobrar un producto a menos del 50% del precio de sus componentes', 16, 1)
			
			else begin
				if  @precio_compuesto>@precio_unitario begin
					declare @cliente char(6), @fecha smalldatetime, @precio decimal(12,2)

					Select @cliente=fact_cliente, @fecha=fact_fecha, @precio=fact_total
						from Factura
							where fact_numero=@numero_factura 
								and fact_sucursal=@sucursal
								and fact_tipo=@tipo_factura

					print concat('fecha: ', CONVERT(VARCHAR(10),@fecha,103), ', cliente: ', str(@cliente), ', precio:', str(@precio)) 							
					--para mostrar los items tendria que abrir otro cursor y hacer si es la misma factura (tipo, nro, sucursal), print Select prod_detalle from Producto where prod_codigo=item_producto
				end
				Insert into Item_Factura values (@tipo_factura, @numero_factura, @sucursal, @producto, @precio_unitario, @cantidad)
			end

			fetch next from cursor_items into @tipo_factura, @numero_factura, @sucursal, @producto
							, @precio_unitario, @cantidad 
		end

		close cursor_items
		deallocate cursor_items
	end
go

drop trigger tg_compra_compuesta 
drop function calcular_precio_compuesto
go
----------------------------------------------------------------------------------
/*15. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
Select.
*/
go
create function calcular_precio_compuesto(@producto char(8))
	returns decimal(12,2) as begin
		return (
			Select sum(isnull(dbo.calcular_precio_compuesto(comp_componente), prod_precio)*comp_cantidad)
				from Composicion
				join Producto on
					comp_componente=prod_codigo
				where
					comp_producto= @producto
		)
	end
go

create function calcular_precio(@producto char(8))
	returns decimal(12,2) as begin
		return isnull(dbo.calcular_precio_compuesto(@producto), (
			Select prod_precio from Producto where prod_codigo=@producto
			)
		)
	end
;
go

--Select prod_codigo, dbo.calcular_precio(prod_codigo) from Producto
drop function calcular_precio
drop function calcular_precio_compuesto
go

----------------------------------------------------------------------------------
/*16. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto*/
create procedure descontar_de_stock(@producto char(8), @cantidad decimal(12))
	as begin
		declare cursor_depositos cursor for
			select stoc_deposito, stoc_cantidad
				from Stock
				where stoc_producto=@producto
				order by stoc_cantidad desc
		
	
		declare @deposito char(2), @stock_actual decimal(12)

		open cursor_depositos
		fetch next from cursor_depositos into @deposito, @stock_actual

		while @@fetch_status=0 begin
			if @stock_actual=0 and @stock_actual>=@cantidad			
				update Stock
					set stoc_cantidad = stoc_cantidad-@cantidad
					where stoc_deposito=@deposito
						and stoc_producto=@producto
			
			else begin
				fetch next from cursor_depositos into @deposito, @stock_actual
				if @@fetch_status!=0 begin
					close cursor_depositos
					open cursor_depositos
					
					fetch next from cursor_depositos into @deposito, @stock_actual
				end
			end

			fetch next from cursor_depositos into @deposito, @stock_actual
		end
	
		close cursor_depositos
		deallocate cursor_depositos
	end
go

create trigger tg_descontar_articulos_vendidos_de_deposito on Item_factura
	after insert as begin
		declare cursor_vendidos cursor for (
			select item_producto, sum(item_cantidad) from inserted
				group by item_producto
		)

		declare @producto char(8), @cantidad decimal(12)
		
		open cursor_vendidos
		fetch next from cursor_vendidos into @producto, @cantidad

		while @@fetch_status=0 begin
			exec descontar_de_stock @producto, @cantidad
			fetch next from cursor_vendidos into @producto, @cantidad
		end

		close cursor_vendidos
		deallocate cursor_vendidos
	end
go

drop trigger tg_descontar_articulos_vendidos_de_deposito
drop procedure descontar_de_stock
go
----------------------------------------------------------------------------------
/*. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock*/

create trigger tg_validar_cantidad_stock on Stock
	instead of insert, update as begin
		declare cursor_stock_insertado cursor for(
			select * from inserted
		)

		declare @producto char(8), @deposito char(2), @cantidad decimal(12), @punto_reposicion decimal, @stock_max decimal, @detalle char(100), @prox_repo smalldatetime

		open cursor_stoc_cantidad
		fetch next from cursor_stock_insertado into @producto, @deposito, @cantidad, @punto_reposicion, @stock_max, @detalle, @prox_repo 
		
		while @@fetch_status=0 begin
			if (@cantidad between @punto_reposicion and @stock_max)
				insert into Stock (stoc_producto, stoc_deposito, stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_Reposicion)
					values (@producto, @deposito, @cantidad, @punto_reposicion, @stock_max, @detalle, @prox_repo)

			else begin
				declare @mensaje varchar(255) = concat('La cantidad de stock del producto ', @producto, ' en el deposito ', @deposito, ' es invalida')
				raiserror(@mensaje, 16, 1)
			end

			fetch next from cursor_stock_insertado into @producto, @deposito, @cantidad, @punto_reposicion, @stock_max, @detalle, @prox_repo 
		end

		close cursor_stoc_cantidad
		deallocate cursor_stoc_cantidad
	end
go

drop trigger tg_validar_cantidad_stock
go
----------------------------------------------------------------------------------
/*18. Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas*/

go

create function puede_gastar(@cliente char(8), @precio decimal(12,2), @fecha smalldatetime)
	returns bit as begin
		declare @total_gastado decimal(12,2), @limite_credito decimal(12,2)

		Select @total_gastado=sum(fact_total), @limite_credito=clie_limite_credito
			from Cliente
			join Factura on
				fact_cliente=clie_codigo
			where clie_codigo=@cliente
				and year(fact_fecha)=year(@fecha)
				and month(fact_fecha)=month(@fecha)
			group by clie_limite_credito

		return iif(@total_gastado + @precio> @limite_credito,1,0)
	end
go

create trigger tg_limite_credito on Factura
	instead of Insert as begin
		declare cursor_facturas cursor for(
			Select * from Inserted
		)

		declare @tipo	   char,		  @sucursal char(4),    @numero char(8)
			  , @fecha	   smalldatetime, @vendedor numeric(6), @precio decimal(12,2)
			  , @impuestos decimal(12,2), @cliente  char(6)

		open cursor_facturas

		fetch next from cursor_facturas into @tipo, @sucursal , @numero 
			  , @fecha, @vendedor , @precio, @impuestos, @cliente

		while @@FETCH_STATUS=0 begin
			
			if dbo.puede_gastar(@cliente, @precio+@impuestos, @fecha)=1 
				Insert into Factura values (@tipo, @sucursal , @numero 
					, @fecha, @vendedor , @precio, @impuestos, @cliente)
			else
				raiserror('Limite de credito alcanzado', 16, 1)

			fetch next from cursor_facturas into @tipo, @sucursal , @numero 
			  , @fecha, @vendedor , @precio, @impuestos, @cliente
		end

		close cursor_facturas	
		deallocate cursor_facturas	
	end
go

drop function dbo.puede_gastar
drop trigger tg_limite_credito
go
----------------------------------------------------------------------------------
/*19. Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) 

>> a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.
	empl_jefe is not null*/
create function maxima_cantidad_empleados()
	returns int as begin
		return (select count(*)/2 from Empleado)
	end
go

create function es_empleado_de_orden_n(@empleado numeric(6), @jefe numeric(6))
	returns bit as begin
		return iif(
			exists(
				select * from Empleado
					where empl_codigo=@empleado
						and (
							empl_jefe=@jefe
							or dbo.es_empleado_de_orden_n(empl_jefe, @jefe)=1
						)
			), 1, 0)
	end
go

create function cantidad_empleados_a_cargo(@jefe numeric(6))
	returns int as begin
		return (
			select isnull(count(*), 0)
				from Empleado
				where dbo.es_empleado_de_orden_n(empl_codigo, @jefe)=1
		)
	end
go
create trigger tg_empleados_validar_minima_antiguedad_y_cantidad_empleados on Empleado
	after insert, update as begin

		declare @maxima_cantidad_empleados int = dbo.maxima_cantidad_empleados()

		if exists (
			select * from inserted i
				join Empleado jefe on
					jefe.empl_codigo=i.empl_jefe
				where jefe.empl_jefe is not null
					and (
						year(getdate()-i.empl_ingreso) < 5
						or dbo.cantidad_empleados_a_cargo(jefe.empl_codigo)>@maxima_cantidad_empleados
					)
		) begin
			rollback;
			throw 60000, 'La insercion de los empleados incumpliria las reglas del negocio', 1
		end
	end
go

create trigger tg_empleados_validar_cantidad_empleados_a_cargo on Empleado
	after delete as begin
		declare @maxima_cantidad_empleados int = dbo.maxima_cantidad_empleados()
		if exists (
			select * from Empleado
				where dbo.cantidad_empleados_a_cargo(empl_codigo)>@maxima_cantidad_empleados
		)begin
			rollback;
			throw 60001, 'La eliminacion de los empleados incumpliria las reglas del negocio', 1
		end
	end
go

drop trigger tg_empleados_validar_minima_antiguedad_y_cantidad_empleados
drop trigger tg_empleados_validar_cantidad_empleados_a_cargo
drop function dbo.maxima_cantidad_empleados
drop function dbo.cantidad_empleados_a_cargo
drop function dbo.es_empleado_de_orden_n
go

----------------------------------------------------------------------------------
/*20. Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.*/
go
create function venta_mensual(@vendedor numeric(6), @fecha smalldatetime)
	returns decimal(12, 2) as
	begin
		return (
			Select sum(fact_total)
				from Factura
				where fact_vendedor=@vendedor
				and year(fact_fecha) = year(@fecha)
				and month(fact_fecha)=year(@fecha)
		)
	end
go	

create function productos_vendidos_por(@vendedor numeric(6))
	returns int as
	begin
		return(
			Select count(distinct item_producto) from Item_Factura
				join Factura on
					fact_tipo=item_tipo
					and fact_numero=item_numero
					and fact_sucursal=item_sucursal
				where fact_vendedor=@vendedor
		)
	end	
GO

create procedure actualizar_comisiones as
	begin
		Update Empleado
			set empl_comision=dbo.venta_mensual(empl_codigo, getDate())*(0.05 + iif(dbo.productos_vendidos_por(empl_codigo)>50, 0.03, 0))
	end
go

drop procedure actualizar_comisiones
drop function dbo.venta_mensual
drop function dbo.productos_vendidos_por
go
----------------------------------------------------------------------------------
/*21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla*/

if object_id('tg_productos_de_misma_familia') is not null
	drop trigger tg_productos_de_misma_familia
go

create trigger tg_productos_de_misma_familia on Item_factura
	instead of Insert as
	begin
		declare cursor_productos cursor for
			Select item_tipo, item_numero, item_sucursal, count(distinct prod_familia)
				from Inserted
				join Producto on item_producto=prod_codigo
				group by item_tipo, item_numero, item_sucursal

		declare @tipo char, @numero char(4), @sucursal char(8), @cant_familias int
		
		open cursor_productos

		fetch next from cursor_productos into @tipo, @numero, @sucursal, @cant_familias

		while @@FETCH_STATUS=0 begin
			
			if @cant_familias>2 begin
					raiserror('Se intento ingresar productos de distinta familia', 16, 1)
					--delete * from Factura where fact_tipo=@tipo and fact_numero=@numero and fact_sucursal=@sucursal
					end
			else
				print 'Inserto'
--				Insert into Item_Factura
--					Select * from Inserted where item_tipo=@tipo and item_numero=@numero and item_sucursal=@sucursal

			fetch next from cursor_productos into @tipo, @numero, @sucursal, @cant_familias
		end

		close cursor_productos
		deallocate cursor_productos
	end
go

drop trigger tg_productos_de_misma_familia
----------------------------------------------------------------------------------
/*22. Se requiere recategorizar los rubros de productos, de forma tal que
>> nigun rubro tenga más de 20 productos asignados
>> si un rubro tiene más de 20 productos asignados, se deberan distribuir en
otros rubros que no tengan mas de 20 productos
>> si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada*/
go
create procedure recategorizar_rubros as
begin
	declare rubros_disponibles cursor for(
		Select rubr_id, 20-count(prod_codigo)
			from Rubro
			left join Producto on
				prod_rubro=rubr_id
			group by rubr_id
			having count(prod_codigo)<20
	)

	declare rubros_con_sobrantes cursor for(
		Select rubr_id, count(prod_codigo)-20
			from Rubro
			join Producto on
				prod_rubro=rubr_id
			group by rubr_id
			having count(prod_codigo)>20
	)

	declare @rubro_disponible char(4), @cantidad_disponible int=0
	declare @rubro_lleno	  char(4), @cantidad_sobrante int
	declare @id char(4) = 1+(Select max(rubr_id) from Rubro)

	open rubros_con_sobrantes
	fetch next from rubros_con_sobrantes into @rubro_lleno, @cantidad_sobrante
	open rubros_disponibles

	while @@FETCH_STATUS=0 begin
			if @cantidad_disponible=0
				fetch next from rubros_disponibles into @rubro_disponible, @cantidad_disponible

			while @@FETCH_STATUS!=0 begin
				print 'lei todos los disponibles'
				close rubros_disponibles
				open rubros_disponibles

				fetch next from rubros_disponibles into @rubro_disponible, @cantidad_disponible

				if @@FETCH_STATUS!=0 begin
					print 'no quedan mas disponibles asi que agrego'
					Insert into Rubro (rubr_id, rubr_detalle) values (@id, 'RUBRO REASIGNADO')
					set @id=@id+1

					continue
				end
			end

			print 'al sig rubro le quedan ' + str(@cantidad_disponible) + ' y al otro le sobran ' + str(@cantidad_sobrante)

			Update top (@cantidad_disponible) Producto
				set prod_rubro= @rubro_disponible
				where prod_rubro=@rubro_lleno
			
			declare @cantidad_hecha int = @cantidad_disponible-@cantidad_sobrante
			set @cantidad_disponible=iif(@cantidad_disponible>@cantidad_sobrante, @cantidad_hecha,  0)
			set @cantidad_sobrante = iif(@cantidad_disponible<@cantidad_sobrante, abs(@cantidad_hecha),  0)

			if @cantidad_sobrante=0 begin
				print 'proximo con sobrantes'
				fetch next from rubros_con_sobrantes into @rubro_lleno, @cantidad_sobrante
			end
	end

	close rubros_disponibles
	deallocate rubros_disponibles
	close rubros_con_sobrantes
	deallocate rubros_con_sobrantes

end
go


--begin transaction
--exec recategorizar_rubros
--Select * from Rubro
--rollback transaction

create trigger validar_rubros_categorizados
	on Producto after Insert as begin
		exec recategorizar_rubros 
	end
go

drop trigger validar_rubros_categorizados
drop procedure recategorizar_rubros 
go

----------------------------------------------------------------------------------
/*23. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.*/

if object_id('tg_no_mas_de_dos_combos') is not null
	drop trigger tg_no_mas_de_dos_combos
go

create trigger tg_no_mas_de_dos_combos on 
	Item_factura instead of Insert as
	begin
		declare cursor_facturas cursor for
			Select item_tipo, item_numero, item_sucursal, count(distinct comp_producto) as cant_combos
				from Inserted
				join Composicion on
					item_producto=comp_producto
				group by item_numero, item_sucursal, item_tipo

		declare @tipo_factura char, @sucursal char(4), @numero_factura char(4), @cant_combos_en_Factura int

		open cursor_facturas 

		fetch next from cursor_facturas into @tipo_factura, @numero_factura, @sucursal, @cant_combos_en_Factura

		while @@FETCH_STATUS=0 begin
			if @cant_combos_en_Factura>2
				raiserror('factura tiene mas de 2 combos', 16, 1)
			else
				Insert into Item_Factura 
					Select * from Inserted
					where item_tipo=@tipo_factura
						and item_numero=@numero_factura
						and item_sucursal=@sucursal


			fetch next from cursor_facturas into @tipo_factura, @numero_factura, @sucursal, @cant_combos_en_Factura
		end

		close cursor_facturas
		deallocate cursor_facturas

end 
go

drop trigger tg_no_mas_de_dos_combos
go
----------------------------------------------------------------------------------
/*24. Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.*/

create function vive_en_zona(@empleado numeric(6), @zona numeric(6)) 
	returns bit as begin
		return iif( exists (
			Select * from Empleado
				join Departamento on
					depa_codigo=empl_departamento
				where empl_codigo = @empleado
					and depa_zona=@zona
		), 1, 0)
	end

go

create procedure recategorizar_encargados as begin
	Update Deposito
		set depo_encargado=iif(dbo.vive_en_zona(depo_encargado, depo_zona)=1, depo_encargado, (
			Select top 1 empl_codigo from Empleado
				where dbo.vive_en_zona(empl_codigo, depo_zona)=1
				order by (Select count(distinct depo_codigo) from Deposito where depo_encargado=empl_codigo)
			)
		)
			
end
go

drop procedure recategorizar_encargados
drop function dbo.vive_en_zona

go

----------------------------------------------------------------------------------
/*25. Desarrolle el/los elementos de base de datos necesarios para que no se permita
que la composición de los productos sea recursiva, o sea, que si el producto A 
compone al producto B, dicho producto B no pueda ser compuesto por el
producto A, hoy la regla se cumple.
*/

create function es_componente_de(@componente char(8), @compuesto char(8))
returns bit as
	begin
		if exists (
			Select * from Composicion
				where comp_producto=@componente
					and (
						comp_componente=@compuesto
						or dbo.es_componente_de(comp_componente, @compuesto)=1
					) 
		) return 1

		return 0
	end
;
go
create trigger tg_composicion_no_recursiva
	on Composicion instead of Insert as
	begin
		declare cursor_nuevas_composiciones cursor for
			Select comp_producto, comp_componente, comp_cantidad from Inserted

		declare @compuesto char(8), @componente char(8), @cantidad decimal(12)

		open cursor_nuevas_composiciones 

		fetch next from cursor_nuevas_composiciones  into @compuesto, @componente, @cantidad

		while @@FETCH_STATUS=0 begin

			if dbo.es_componente_de(@compuesto, @componente)=1
				raiserror('Se ha intentado Insertar un componente recursivo', 1, 16)
			else
				print 'Voy a Insertar ('+@compuesto + ', ' + @componente + ', '+str(@cantidad)+ ')'

			fetch next from cursor_nuevas_composiciones  into @compuesto, @componente, @cantidad
		end

		close cursor_nuevas_composiciones 
		deallocate cursor_nuevas_composiciones 

	end
go

drop trigger tg_composicion_no_recursiva
drop function dbo.es_componente_de
go
----------------------------------------------------------------------------------
/*26 Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

create trigger tg_item_sin_componentes on Item_factura
instead of Insert as
	if exists(
		Select top 1 comp_producto from Inserted, Composicion
			where comp_componente=item_producto
	)
		throw 50000, 'Error: al menos un producto es componente', 1

	else Insert into item_factura Select * from Inserted
go

drop trigger tg_item_sin_componentes
go
----------------------------------------------------------------------------------
/*27 Se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que 
>> el encargado que le corresponde es cualquiera que
	* no es jefe
	* no es vendedor (no está asignado a ningun cliente)
>> se deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado
>> en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado*/

if object_id('desasignar_depositos_a_encargados') is not null
	drop procedure desasignar_depositos_a_encargados
if object_id('asignar_depositos_a_encargado') is not null
	drop procedure asignar_depositos_a_encargado
go

create procedure desasignar_depositos_a_encargados as
begin
	Update Deposito set
		depo_encargado=null
end

go
create procedure asignar_depositos_a_encargado as
	begin
		--comento esto para no alterar datos
		--exec desasignar_depositos_a_encargados 
		
		declare cursor_depositos cursor for(
			Select distinct depo_codigo from Deposito
		)

		declare cursor_candidato_encargado cursor for 
			Select empl_codigo from Empleado jefe
				where not exists (Select subdito.empl_codigo from Empleado subdito where jefe.empl_codigo=subdito.empl_jefe)
					and not exists (Select clie_codigo from Cliente where clie_vendedor=jefe.empl_codigo)
				order by (Select count(distinct depo_codigo) from Deposito where depo_encargado=jefe.empl_codigo)
		

		declare @deposito char(2),  @candidato char(6)

		open cursor_depositos
		open cursor_candidato_encargado

		fetch next from cursor_depositos into @deposito

		while @@FETCH_STATUS=0	begin --por leer deposito
			fetch next from cursor_candidato_encargado into @candidato

			if @@FETCH_STATUS!=0 begin --por leer encargado
				close cursor_candidato_encargado
				open cursor_candidato_encargado
				
				fetch next from cursor_candidato_encargado into @candidato

				if @@FETCH_STATUS!=0 --por releer encargado
					throw 50000, 'ningun empleado puede ser encargado', 200
			end
	
			--hago esto para no alterar datos		
			print 'depo '+str(@deposito)+', encargado'+ str(@candidato)
--			Update Deposito
--				set depo_encargado=@candidato

			fetch next from cursor_depositos into @deposito
		end


		close cursor_depositos
		deallocate cursor_depositos

		close cursor_candidato_encargado
		deallocate cursor_candidato_encargado
	end
;

exec asignar_depositos_a_encargado

drop procedure desasignar_depositos_a_encargados
drop procedure asignar_depositos_a_encargado
go
----------------------------------------------------------------------------------
/*28 Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes el vendedor que le corresponda, entendiendo que el vendedor que le
corresponde es aquel que le vendió más facturas a ese cliente, si en particular un
cliente no tiene facturas compradas se le deberá asignar el vendedor con más
venta de la empresa, o sea, el que en monto haya vendido más.
*/

create function vendedor_para_cliente(@cliente char(6))
returns numeric(6) as begin
	return (
		Select top 1 fact_vendedor from Factura
			where fact_cliente=@cliente
			group by fact_vendedor
			order by count(*)
	)
end
go

create procedure actualizar_vendedor_clientes as
begin

	declare @vendedor_que_vendio_mas numeric(6) = (
		Select top 1 fact_vendedor from Factura
			group by fact_vendedor
			order by sum(fact_total)	
	)

	Update Cliente
		set clie_vendedor = isnull(dbo.vendedor_para_cliente(clie_codigo), @vendedor_que_vendio_mas)
end
go

drop function dbo.vendedor_para_cliente
drop procedure actualizar_vendedor_clientes
----------------------------------------------------------------------------------
/*29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de diferentes productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/
go
create trigger tg_item_validar_componentes on Item_factura 
	instead of Insert as
	begin
		declare compras_cursor cursor for(
			Select item_numero, item_sucursal, count(distinct comp_producto) from Inserted
			join Composicion on
				comp_componente=item_producto
			group by item_numero, item_sucursal
		)

		open compras_cursor 

		declare @fact_numero char(8), @fact_sucursal char(4), @combos_distintos int

		fetch next from compras_cursor into @fact_numero, @fact_sucursal, @combos_distintos

		while @@FETCH_STATUS=0 begin
			if 1 < @combos_distintos begin
				declare @mensaje nvarchar(255) = concat('Error de combo: fact nro ', @fact_numero, ', sucursal ', @fact_sucursal)
				raiserror(@mensaje, 1, 16) 
			end
			else
				print 'Insert'

			fetch next from compras_cursor into @fact_numero, @fact_sucursal, @combos_distintos
		end
		

		close compras_cursor
		deallocate compras_cursor
	end
go

drop trigger tg_item_validar_componentes 

----------------------------------------------------------------------------------

/*30 Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/
go
create function max_unidades_mensuales_compradas_por
(@cliente char(6)) returns int as
	begin
		return (
			Select isnull(max(cantidad), 0) from (
				Select item_producto, sum(item_cantidad) as cantidad from Item_Factura
					join Factura on
						fact_numero=item_numero
						and fact_sucursal=item_sucursal
					where fact_cliente=@cliente
						and month(fact_fecha)= 8 --month(getDate())
						and year(fact_fecha)= 2011--year(getDate())
					group by item_producto
			) as compras_del_cliente
		);
	end
;
go

--Select cliente, max_compra from
--	(Select clie_codigo as cliente, dbo.max_unidades_mensuales_compradas_por(clie_codigo) as max_compra from Cliente) as clientes_y_compras
--	where max_compra>0
-- go

create trigger tg_max_unidades_clientes on Factura
	after Insert as
	begin
		if exists
		(Select * from Inserted where dbo.max_unidades_mensuales_compradas_por(fact_cliente)>100)
		raiserror('Se ha superado el límite máximo de compra de un producto', 1, 16)
	end
;
go

drop trigger tg_max_unidades_clientes 
drop function dbo.max_unidades_mensuales_compradas_por
go

--------alternativa 2
create function cantidad_comprada_en_el_mes(@cliente char(6), @producto char(8), @fecha smalldatetime)
returns int as
begin
	return (
		Select sum(item_cantidad)
			from Item_Factura
			join Factura on
				item_numero=fact_numero
				and item_sucursal=fact_sucursal
			where year(fact_fecha)=year(@fecha)
				and month(fact_fecha)=month(@fecha)
				and item_producto=@producto
				and fact_cliente=@cliente
	)
end 
go	

create trigger validar_cantidad_comprada on Item_factura
	instead of Insert as
	begin
		declare cursor_item cursor
			for (
				Select fact_cliente, fact_fecha, item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio
					from Inserted
					join Factura on
						fact_numero=item_numero
			)

		open cursor_item

		declare @cliente char(6), @fecha smalldatetime, @tipo char, @sucursal char(4), @numero char(4), @producto char(8)
			,	@cantidad decimal(12,0), @precio decimal(12, 2)

		fetch next from cursor_item into @cliente, @fecha, @tipo, @sucursal, @numero, @producto, @cantidad, @precio

		while @@FETCH_STATUS = 0 begin
			IF (dbo.cantidad_comprada_en_el_mes(@cliente, @producto, @fecha) + @cantidad >100)
				raiserror('Se ha superado el límite máximo de compra de un producto', 1, 16)
			else
				Insert into Item_Factura values (@tipo, @sucursal, @numero, @producto, @cantidad, @precio)

			fetch next from cursor_item into @tipo, @sucursal, @numero, @producto, @cantidad, @precio
		end

		close cursor_item
		deallocate cursor_item
	end
go

drop function dbo.cantidad_comprada_en_el_mes
drop trigger validar_cantidad_comprada
go
-------------------------------------------------------------------------
create function hay_composicion_entre(@item char(8), @otro char(8))
	returns bit as begin
		return iif(exists(
			select * from Composicion
				where (
					comp_producto=@item
					and comp_componente=@otro
				) or  (
					comp_producto=@otro
					and comp_componente=@item
				) 
		), 1, 0)
	end
go
create trigger tg_productos_compuestos on Item_factura
	after insert, update as begin
		
		if exists (
			select * from inserted i
				join Item_Factura u on
					i.item_tipo=u.item_tipo
					and i.item_numero=u.item_numero
					and i.item_sucursal=u.item_sucursal
				where dbo.hay_composicion_entre(i.item_producto, u.item_producto)=1
		) begin
			rollback;
			throw 50000, 'Se intento ingresar un item que compone o es compuesto de otro de la misma factura', 1
		end
	end
go

drop trigger tg_productos_compuestos
drop function dbo.hay_composicion_entre

------------------------------------------------------------------------------------

