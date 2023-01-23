create procedure sp_bg_consultartransaccion
	@nromov varchar(30)
as
begin
	select estado from bd11enccj where nromov=@nromov
end