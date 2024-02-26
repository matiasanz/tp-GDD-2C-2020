use GD2015C1
go

create function es_componente_de(@compuesto char(8), @componente char(8))
	returns bit as begin
		return iif(exists (
			select * from Composicion
				where comp_producto=@compuesto
					and comp_componente=@componente
		), 1, 0)
	end
go

create trigger tg_validar_composicion_entre_items_al_insertar
	on Item_factura	instead of insert as begin		
			if exists(
				select * from (
						select * from inserted
							union all
						select * from item_factura
					) as universo

  				   join inserted i on
							i.item_tipo=universo.item_tipo
						and i.item_numero=universo.item_numero
						and i.item_sucursal=universo.item_sucursal
				 where dbo.es_componente(i.item_producto, universo.item_producto)=1
					or dbo.es_componente(universo.item_producto, i.item_producto)=1
			)
			rollback transaction;
			throw 50000, 'Error: Se intento insertar un item compuesto junto con un componente en la misma factura', 1
	end
go

create trigger tg_validar_composicion_entre_items_al_actualizar
	on Item_factura after update as begin
		if exists(
				select * from (
						select * from inserted
							union all
						select * from item_factura
					) as universo

  				   join inserted i on
							i.item_tipo=universo.item_tipo
						and i.item_numero=universo.item_numero
						and i.item_sucursal=universo.item_sucursal
				 where dbo.es_componente(i.item_producto, universo.item_producto)=1
					or dbo.es_componente(universo.item_producto, i.item_producto)=1
			)
		rollback transaction;
		throw 50001, 'Error: Se intento colocar un item compuesto junto con un componente en la misma factura', 1
	end	
go


drop function dbo.es_componente_de
drop trigger tg_validar_composicion_entre_items_al_insertar
drop trigger tg_validar_composicion_entre_items_al_actualizar