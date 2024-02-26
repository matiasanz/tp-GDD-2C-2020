use GD2015C1
go

/*Enunciado: El atributo clie_limite_credito, representa el monto máximo que puede venderse a un cliente
en el mes en curso. Implementar el/los objetos necesarios para que no se permita realizar una 
venta si el monto total facturado en el mes supera el atributo clie_limite_credito. 
Considerar que esta restricción debe cumplirse siempre y validar también que no se pueda hacer 
una factura de un mes anterior.*/

create function gasto_mensual(@cliente char(6), @fecha date)
	returns decimal(12,2) as begin
		return (
			select isnull(sum(fact_total), 9)
				from Factura
				where fact_fecha<=@fecha
					and year(fact_fecha)=year(@fecha)
					and month(fact_fecha)=month(@fecha)
		)
	end
go

create trigger tg_limite_de_credito_clientes_insercion on Factura
	instead of insert as begin	
		declare @fecha_actual date = getdate()
		
		/*Utilizo un cursor ya que me interesa analizar factura por factura y son distintos clientes.
		Una alternativa seria analizar todo el conjunto y tirar excepcion en caso de que alguno no cumpla,
		pero no me parecio acorde al contexto.*/
		declare cursor_facturas cursor for(
			select fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente, clie_limite_credito
			from inserted
				join Cliente on
					clie_codigo = fact_cliente
				where cast(fact_fecha as date)=@fecha_actual
				/* directamente no considero las que no son de la fecha. Una alternativa seria incluir todo
				en el cursor e informar al usuario para mantenerlo al tanto de que no se concreto la insercion,
				pero la desventaja es que serian mas elementos para el cursor. De todas formas, a mi parecer, es valido
				pero me quedo con la mas rapida*/
		)
		
		declare @factura_tipo char, @sucursal char(4), @factura_numero char(8), @fecha smalldatetime
			  , @vendedor numeric(6), @precio_factura_actual decimal(12,2), @impuestos decimal(12,2), @cliente char(6), @limite_credito decimal(12,2)

		open cursor_facturas
		fetch next from cursor_facturas into @factura_tipo, @sucursal, @factura_numero, @fecha, @vendedor, @precio_factura_actual, @impuestos, @cliente, @limite_credito

			while @@FETCH_STATUS=0 begin
				declare @monto_por_comprar decimal(12,2) = @precio_factura_actual + dbo.gasto_mensual(@cliente, @fecha)
				-- Se asume que los impuestos estan incluidos en fact_total

				if @monto_por_comprar > @limite_credito begin
					declare @mensaje varchar(255) = concat('El monto mensual abonado por el cliente ', @cliente, ' supera el limite de credito')
					--seria util incluir datos de la factura
					raiserror(@mensaje, 16, 1)
				end

				else
					insert into Factura(fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
						values (@factura_tipo, @sucursal, @factura_numero, @fecha, @vendedor, @precio_factura_actual, @impuestos, @cliente)

				fetch next from cursor_facturas into @factura_tipo, @sucursal, @factura_numero, @fecha, @vendedor, @precio_factura_actual, @impuestos, @cliente, @limite_credito
			end

		close cursor_facturas
		deallocate cursor_facturas
	end
go

create trigger tg_limite_de_credito_clientes_actualizacion on Factura
	after update as begin
		declare @fecha_actual date=getdate()
		--Dejo que me actualicen la fecha de las facturas, si bien abre una puerta a que se creen facturas de fechas anteriores.

		declare @cliente_en_problemas char(6) = (
			select top 1 clie_codigo from inserted
				join Cliente on
					clie_codigo=fact_cliente
				where dbo.gasto_mensual(clie_codigo, @fecha_actual)>clie_limite_credito
		) 

		if (@cliente_en_problemas is not null) begin
			declare @mensaje varchar(255)= concat('Se interrumpio la actualizacion debido a que el cliente ',@cliente_en_problemas, ' superaria el limite de credito')
			rollback;
			throw 50001, @mensaje, 1
		end
	end
go

begin transaction

insert into Factura
	select 'd', fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total+clie_limite_credito, fact_total_impuestos, fact_cliente from Factura
		join Cliente on clie_codigo=fact_cliente
rollback transaction
go

drop trigger tg_limite_de_credito_clientes_insercion
drop trigger tg_limite_de_credito_clientes_actualizacion
drop function gasto_mensual
go
