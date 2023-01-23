create procedure sp_bg_lastnromovbd11
	@nromov varchar(20)
as
begin
	select top 1 nromov from bd11enccj where nrocxc=@nromov and estado=0 order by hormov desc
end