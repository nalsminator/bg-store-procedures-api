/*
select * from Be08enccc where coddeu like '61120%'
select * from Cc08inscriC where idestu like '61120%'
select * from Be09cuota where nromov='356622019'
select * from Cf03estca where idestu='611202018'*/

--insert into a25tabtipca values (convert(date, getdate()), 6.96, 6.95)

--exec sp_bg_grabarpago 2, '356622019', '611202018', 1580

--exec sp_bg_anularpago '173156-2019'

/*declare @interes decimal(15,2)
exec sp_bg_getinterestotal '356622019', @interes output
print @interes*/

--Select sum(saldeu) from be09cuota where saldeu>0 and nromov='356622019'

/*
select * from Be08enccc where nromov='356622019'
select * from Be09cuota where nromov='356622019'
select * from Be10detct where nromov='356622019'
select * from Be11encac where nromov='356622019'

select * from bd11enccj order by hormov desc
select * from bd12detcj where nromov='173155-2019'

select * from bc12encas
select * from bc13detas

select * from Cc08inscriC where idgest=2019 and idtran='23724'

select * from bd11enccj where nrocxc='356622019' and estado=0 order by hormov desc*/


--select Bd11enccj.* FROM Bd11enccj 
--	inner join Bd12detcj on Bd11enccj.nromov=Bd12detcj.nromov 
--	inner join Ba02perso on Bd11enccj.codreg=Ba02perso.codreg 
--	where Bd11enccj.nromov='172959-2019'

--select * from Be08enccc where nromov='398892019'

--	select codcpt, totcap, totint, codccs, nromov from Be11encac order by fecmov desc
--	where nromov='27946-2018'

--select * from Bd11enccj where nromov='173156-2019'

--select * from Be11encac where ntaorg='356622019'

--select codges, abreviatura, totmus, fecreg, codusr from Bd11enccj 
--join ConceptosPago on Bd11enccj.codcpt=ConceptosPago.cod where codreg='611202018' and fecreg between '1/1/2019' and '15/5/2019'

--exec sp_bg_obtenerdetallepagos 61120, '1/1/2019', '15/5/2019', 'COD'

select codges, abreviatura, fecmov, 'BOB', totcxc, totrec, totdes, ((totcxc + totrec) - totdes), be08.estado from Be08enccc  be08 join ConceptosPago cp on be08.grpcta=cp.cod 
where be08.coddeu='611202018' and be08.estado in (0, 3, 7) order by be08.fecmov asc