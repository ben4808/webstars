-- mysql -u root -pastron starmap < schema.sql

drop table if exists constellations;
drop table if exists hip_stars;
drop table if exists stars;

create table constellations (
	id int(11) not null primary key auto_increment,
	name varchar(255) not null,
	abbr varchar(10) not null
);

create table hip_stars (
	id int(11) not null primary key auto_increment,
	hip int(11),
	hd int(11),
        cons int(11),
	ra_h int(2) not null,
	ra_m int(2) not null,
	ra_s decimal(4, 2) not null,
	dec_deg int(2) not null,
	dec_m int(2) not null,
	dec_s decimal(3, 1) not null,
	mag decimal(4, 2),
	bayer varchar(25) character set utf8 collate utf8_general_ci,
	flam varchar(25),
	gould varchar(25),
	name varchar(255),
	is_double boolean not null default false,
	is_var boolean not null default false,
        var_name varchar(100),
	max_mag decimal(4, 2),
	min_mag decimal(4, 2)
);

create table stars (
	id int(11) not null primary key auto_increment,
	hd int(11),
        tyc1 int(5),
        tyc2 int(5),
        tyc3 int(1),
	ra_h int(2) not null,
	ra_m int(2) not null,
	ra_s decimal(4, 2) not null,
	dec_deg int(2) not null,
	dec_m int(2) not null,
	dec_s decimal(3, 1) not null,
	mag decimal(4, 2),
	is_double boolean not null default false,
	is_var boolean not null default false
); 	
