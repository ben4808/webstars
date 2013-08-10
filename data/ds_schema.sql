drop table if exists obj_types;
drop table if exists deepsky;
drop table if exists deepsky2;

create table obj_types (
   id int(11) not null primary key auto_increment,
   name varchar(100) not null,
   abbr varchar(20) not null
);

create table deepsky (
   id int(11) not null primary key auto_increment,
   ngc varchar(20),
   ic varchar(20),
   obj_type int(11) not null,
   cons int(11),
   ra_h int(2) not null,
   ra_m int(2) not null,
   ra_s decimal(4, 2) not null,
   dec_deg int(2) not null,
   dec_m int(2) not null,
   dec_s decimal(3, 1) not null,
   mag decimal (4, 2),
   size_maj decimal(6, 2),
   size_min decimal(6, 2),
   pa int(4),
   name varchar(255),
   description varchar(255),
   other_ngc varchar(100),
   mess varchar(20),
   cald varchar(20),
   ugc varchar(20),
   mcg varchar(20),
   cgcg varchar(20),
   pgc varchar(20),
   arp varchar(20),
   eso varchar(20),
   pk varchar(20),
   ocl varchar(20),
   gcl varchar(20)
);

create table deepsky2 (
   id int(11) not null primary key auto_increment,
   obj_id varchar(50) not null,
   obj_type int(11) not null,
   ra_h int(2) not null,
   ra_m int(2) not null,
   ra_s decimal(4, 2) not null,
   dec_deg int(2) not null,
   dec_m int(2) not null,
   dec_s decimal(3, 1) not null,
   mag decimal (4, 2)
);

