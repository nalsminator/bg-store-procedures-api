create table ConceptosPago(
cod int null,
abreviatura nvarchar(50) null,
descripcion nvarchar(50) null,
estado nvarchar(50) null
)

insert into ConceptosPago values (102, 'SEM', 'Semestre', 'H')
insert into ConceptosPago values (104, 'TUT', 'Tutoria', 'H')
insert into ConceptosPago values (107, 'INV', 'Invierno', 'H')
insert into ConceptosPago values (108, 'VER', 'Verano', 'H')
insert into ConceptosPago values (501, 'EGR', 'Derecho de Egreso', 'H')
insert into ConceptosPago values (106, 'ROT', 'Internado Rotatorio', 'H')
insert into ConceptosPago values (101, 'VES', 'Vestibular', 'H')